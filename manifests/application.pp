# Class: mongodb_ops_manager::application
#
# install mms application
#
#
class mongodb_ops_manager::application (
  $version               = '1.5.3.182-1',
  $https_proxy           = '',
  $mms_host              = '127.0.0.1',
  $from_email_addr       = 'mms-admin@example.net',
  $reply_to_email_addr   = 'mms-admin@example.net',
  $admin_from_email_addr = 'mms-admin@example.net',
  $admin_email_addr      = 'mms-admin@example.net',
  $bounce_email_addr     = 'mms-admin@example.net',
  $mail_hostname         = '127.0.0.1',
  $mail_port             = 25,
  $aws_accesskey         = undef,
  $aws_secretkey         = undef,
  $email_dao_class       = 'com.xgen.svc.core.dao.email.JavaEmailDao',
  $db_host               = '127.0.0.1',
  $db_port               = '27017',
  $user                  = 'mongodb-mms',
  $group                 = 'mongodb-mms')
  
{

  # needed to do a sudo in redhat
  file_line { '/etc/sudoers':
    ensure => present,
    path   => '/etc/sudoers',
    line   => 'Defaults:root !requiretty'
  }
  
  exec { 'download-mms-onprem':
    command     => "curl -OL https://downloads.mongodb.com/on-prem-mms/rpm/mongodb-mms-${version}.x86_64.rpm",
    cwd         => '/tmp',
    environment => ["https_proxy=${https_proxy}"],
    creates     => "/tmp/mongodb-mms-${version}.x86_64.rpm",
    require     => File_line['/etc/sudoers']
  }
  
  exec { "rpm --install /tmp/mongodb-mms-${version}.x86_64.rpm":
    command => "rpm --install /tmp/mongodb-mms-${version}.x86_64.rpm",
    cwd     => '/tmp',
    unless  => "rpm -q mongodb-mms-${version}",
    require => Exec['download-mms-onprem']
  }
  
  file { '/opt/mongodb/mms/conf/conf-mms.properties':
    ensure  => file,
    owner   => $user,
    group   => $group,
    mode    => '0755',
    content => template('mongodb_ops_manager/conf-mms.properties.erb'),
    require => Exec["rpm --install /tmp/mongodb-mms-${version}.x86_64.rpm"]
  }
  
  service { 'mongodb-mms':
    ensure    => running,
    enable    => true,
    hasstatus => true,
    restart   => true,
    require   => File['/opt/mongodb/mms/conf/conf-mms.properties']
  }
}
