# Class: mongodb_ops_manager::automation_agent
#
# install mongodb automation_agent for mongodb ops manager.
#
#
class mongodb_ops_manager::automation_agent(
  $mmsApiKey                            = '',
  $mmsGroupId                           = '',
  $version                              = '2.5.15.1526-1',
  $mmsBaseUrl                           = 'http://127.0.0.1:8080',
  $sslRequireValidMMSServerCertificates = true
)
{

  if $operatingsystemrelease =~ /^6.*/ {
    $platform = ''
  }
  elsif $operatingsystemrelease =~ /^7.*/ {
    $platform    = '.rhel7'
  }

  exec { 'download-mms-automation-agent':
    command => "curl -OL --insecure ${mmsBaseUrl}/download/agent/automation/mongodb-mms-automation-agent-manager-${version}.x86_64${platform}.rpm",
    cwd     => '/tmp',
    path    => '/usr/bin:$PATH',
    creates => "/tmp/mongodb-mms-automation-agent-manager-${version}.x86_64${platform}.rpm",
  }

  package {'mongodb-mms-automation-agent-manager.x86_64':
    ensure   => installed,
    source   => "/tmp/mongodb-mms-automation-agent-manager-${version}.x86_64${platform}.rpm",
    provider => 'rpm',
    require  => Exec['download-mms-automation-agent'],
  }

  file { '/etc/mongodb-mms/automation-agent.config':
    content => template('mongodb_ops_manager/automation-agent.config.erb'),
    owner   => 'mongod',
    group   => 'mongod',
    mode    => '0600',
    require => Package['mongodb-mms-automation-agent-manager.x86_64'],
    notify  => Service['mongodb-mms-automation-agent']
  }
  
  file { '/etc/logrotate.d/mongodb-mms-automation-agent':
    content => template('mongodb_ops_manager/automation-agent-logrotate.conf.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644'
  }

  service { 'mongodb-mms-automation-agent':
    ensure    => running,
    enable    => true,
    hasstatus => true,
    restart   => true,
    require   => File['/etc/mongodb-mms/automation-agent.config']
  }

}
