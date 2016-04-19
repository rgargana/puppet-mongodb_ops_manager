# Class: mongodb_ops_manager::application
#
# install mms application
#
#
class mongodb_ops_manager::application (
  $version               = '2.0.1.332-1',
  $https_proxy           = '',
  $url_prefix            = 'http://',
  $mms_host              = '127.0.0.1',
  $mms_central_url_port  = '8080',
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
  $group                 = 'mongodb-mms',
  $pem_key_file          = '',
  $pem_key_file_password = '',
  )

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
    path        => '/usr/bin:$PATH',
    environment => ["https_proxy=${https_proxy}"],
    creates     => "/tmp/mongodb-mms-${version}.x86_64.rpm",
    require     => File_line['/etc/sudoers']
  }

  exec { "rpm --install /tmp/mongodb-mms-${version}.x86_64.rpm":
    command => "rpm --install /tmp/mongodb-mms-${version}.x86_64.rpm",
    path    => '/bin:$PATH',
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

  if ($operatingsystemrelease =~ /^7.1/) or ($operatingsystemrelease =~ /^7.2/) {
    # Ops Manager will not start automatically on boot up on RHEL 7.1 and 7.2
    exec { "fix RHEL Bug 1285492":
      command => "rm /etc/init.d/mongodb-mms && cp /opt/mongodb/mms/bin/mongodb-mms /etc/init.d && sed -i '/ABS_PATH=\"$( resolvepath \$0 )\"/c\\ABS_PATH=\"$( resolvepath /opt/mongodb/mms/bin/mongodb-mms )\"' /etc/init.d/mongodb-mms",
      cwd     => '/tmp',
      onlyif  => '/usr/bin/test -L /etc/init.d/mongodb-mms',
      before  => Service['mongodb-mms'],
      require => File['/opt/mongodb/mms/conf/conf-mms.properties']
    }
  }

  service { 'mongodb-mms':
    ensure    => running,
    enable    => true,
    hasstatus => true,
    restart   => true,
    provider  => 'init',
    require   => File['/opt/mongodb/mms/conf/conf-mms.properties']
  }

}
