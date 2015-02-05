# Class: mongodb_ops_manager
#
# This module manages mongo ops manager (mms on premise) installations.
#
#
class mongodb_ops_manager::backup (
  $version          = '1.5.3.182-1',
  $https_proxy      = '',
  $db_host          = '127.0.0.1',
  $db_port          = '27017',
  $backup_db_host   = '',
  $backup_db_port   = '27017',
  $user             = 'mongodb-mms',
  $group            = 'mongodb-mms')
{
  exec { 'download-backup-daemon':
    command     => "curl -OL https://downloads.mongodb.com/on-prem-mms/rpm/mongodb-mms-backup-daemon-${version}.x86_64.rpm",
    cwd         => '/tmp',
    environment => ["https_proxy=${https_proxy}"],
    creates     => "/tmp/mongodb-mms-backup-daemon-${version}.x86_64.rpm"
  }
  
  exec { "rpm --install /tmp/mongodb-mms-backup-daemon-${version}.x86_64.rpm":
    command => "rpm --install /tmp/mongodb-mms-backup-daemon-${version}.x86_64.rpm",
    unless  => "rpm -q mongodb-mms-backup-daemon-${version}",
    cwd     => '/tmp',
    require => Exec['download-backup-daemon']
  }

  file { '/opt/mongodb/mms-backup-daemon/conf/conf-daemon.properties':
    ensure  => file,
    owner   => $user,
    group   => $group,
    mode    => '0755',
    content => template('mongodb_ops_manager/conf-daemon.properties.erb'),
    require => Exec["rpm --install /tmp/mongodb-mms-backup-daemon-${version}.x86_64.rpm"]
  }
  
  service { 'mongodb-mms-backup-daemon':
    ensure    => running,
    enable    => true,
    hasstatus => true,
    restart   => true,
    require   => File['/opt/mongodb/mms-backup-daemon/conf/conf-daemon.properties']
  }

}
