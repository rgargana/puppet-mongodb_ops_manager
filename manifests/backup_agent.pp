# Class: mongodb_ops_manager::backup_agent
#
# install mongodb backup_agent forops manager (mms on premise).
#
#
class mongodb_ops_manager::backup_agent(
  $mmsApiKey    = '',
  $version      = '2.3.3.209-1',
  $mmsBaseUrl   = 'http://127.0.0.1:8081',
  $mmsBackupUrl = '127.0.0.1:8081',  # no http://
)
{

  exec { 'download-mms-backup-agent':
    command => "curl -OL ${mmsBaseUrl}/download/agent/backup/mongodb-mms-backup-agent-${version}.x86_64.rpm",
    cwd     => '/tmp',
    creates => "/tmp/mongodb-mms-backup-agent-${version}.x86_64.rpm",
  }

  exec { 'install-mms-backup-agent':
    cwd     => '/tmp',
    creates => '/usr/bin/mongodb-mms-backup-agent',
    command => "rpm -U mongodb-mms-backup-agent-${version}.x86_64.rpm",
    require => Exec['download-mms-backup-agent'],
    timeout => 0
  }
  
  file { '/etc/mongodb-mms/backup-agent.config':
    content => template('mongodb_ops_manager/backup-agent.config.erb'),
    owner   => 'mongodb-mms-agent',
    group   => 'mongodb-mms-agent',
    mode    => '0600',
    require => Exec['install-mms-backup-agent'],
  }
  
  service { 'mongodb-mms-backup-agent':
    ensure    => running,
    enable    => true,
    hasstatus => true,
    restart   => true,
    provider  => 'init',
    require   => File['/etc/mongodb-mms/backup-agent.config']
  }

}
    
