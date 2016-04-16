# Class: mongodb_ops_manager::application_db
#
# install mongodb for ops manager (mms on premise) application.
#
#
class mongodb_ops_manager::application_db(
  $logpath     = '/var/log/mongodb/mongodb.log',
  $dbpath      = '/var/lib/mongodb',
  $dbparent    = '/data',
  $port        = 27017,
#  $repo_location = undef,
  $version  = undef,)
{

  if !defined(Class['epel']) {
    class { 'epel': }
  }

  if $operatingsystemrelease =~ /^7.*/ {
    file {'/etc/tmpfiles.d/mongod.conf':
      ensure  => file,
      owner   => root,
      group   => root,
      mode    => '0644',
      content => 'D /var/run/mongodb 0755 mongod mongod -',
      require => Class['epel']
    }
  }

  class {'::mongodb::globals':
    manage_package_repo => true,
    server_package_name => 'mongodb-enterprise',
    repo_location       => 'https://repo.mongodb.com/yum/redhat/$releasever/mongodb-enterprise/3.0/$basearch/',
    version             => '3.0.8-1.el6',
    }

  class {'::mongodb::client':
    package_name => 'mongodb-enterprise-shell'
  }

  file_line { 'add small files to mongodb config':
    path => '/etc/mongod.conf',
    line => 'storage:
   mmapv1:
     smallFiles: true',
  }

  class {'::mongodb::server':
    auth    => false,
    verbose => true,
    logpath => $logpath,
    dbpath  => $dbpath,
    port    => $port,
    require => Class['::mongodb::globals']
  }
}
