puppet-mongodb_ops_manager
==========================

Install and Manage MongoDB Ops Manager (MMS)

See:

      https://docs.opsmanager.mongodb.com/current/installation/


It relies on puppet module puppetlabs/mongodb to install the mongodb database.
The ops manager application and ops manager mongodb database can be installed on one server.
The backup database should be first installed on another server.

Currently the scripts don't support authentication or replica sets for application or backup mongodb databases.

NOTE: *** This is a very much a first version and currently support readhat/centos 6 and 7. However its a great way to get started ***


Minimal Usage: 
=============

Setup a backup mongodb on a separate server if using the backup daemon 

    class { 'mongodb_ops_manager::backup_db':
      logpath      => '/data/backupdb/mongodb.log',
      dbpath       => '/data/backupdb',
      version      => '2.6.11-1',  
    }
  
On the ops manager server install the application db, the mms application

    class { 'mongodb_ops_manager::application_db':
      logpath      => '/data/mmsdb/mongodb.log',
      dbpath       => '/data/mmsdb',
      version      => '2.6.11-1',  
    }
  
    class { 'mongodb_ops_manager::application':
      mms_host              => 'mms.mycompany.com",
      from_email_addr       => 'mms-admin@company.com',
      reply_to_email_addr   => 'mms-admin@company.com',
      admin_from_email_addr => 'mms-admin@company.com',
      admin_email_addr      => 'mms-admin@company.com',
      bounce_email_addr     => 'mms-admin@company.com',
      mail_hostname         => 'mymailhost.com',
      mail_port             => 25,  
      require               => Class['mongodb_ops_manager::application_db'] 
    }
    
On the ops manager server install also install the backup daemon if doing backup of mongodb databases    
  
    class { 'mongodb_ops_manager::backup':
      backup_db_host => 'backupserver',
      require        => Class['mongodb_ops_manager::application']
    } 
    
Logon to the ops manager server (http://mms.mycompany.com:8080) and register a user and find the mmsApiKey and mmsGroupId.     
    
On the ops manager server install automation agent specifying :
  
    class { 'mongodb_ops_manager::automation_agent':
      mmsApiKey                            => 'mmsApiKey',
      mmsGroupId                           => 'mmsGroupId'
      mmsBaseUrl                           => 'http://mms.mycompany.com:8080',
      sslRequireValidMMSServerCertificates => false
      serverPoolKey                        => 'serverPoolKey' 
      serverPoolProperties                 => hash of '<property:<value>'
} 
    } 

Intially its easier to setup without SSL certificates and then change it to true later. 

NOTE: sslRequireValidMMSServerCertificates defaults to true.
    

Detailed Usage:
===============

TO COME: 


Ulimits:
========

Remove the default ulimit settings that come with the operating system and use the puppet module "arioch/ulimit"   to set the ulimits before configuring the server(s)

    file {'remove_default_ulimit_settings':
      ensure  => absent,
      path    => '/etc/security/limits.d/90-nproc.conf',
      purge   => true,
      force   => true
    }
    
    ulimit::rule {
     'soft_nofile':
      ulimit_domain => '*',
      ulimit_type   => 'soft',
      ulimit_item   => 'nofile',
      ulimit_value  => '64000',
      require       => File['remove_default_ulimit_settings'];
 
     'hard_nofile':
      ulimit_domain => '*',
      ulimit_type   => 'hard',
      ulimit_item   => 'nofile',
      ulimit_value  => '64000',
      require       => File['remove_default_ulimit_settings'];
      
     'soft_nproc':
      ulimit_domain => '*',
      ulimit_type   => 'soft',
      ulimit_item   => 'nproc',
      ulimit_value  => '32000',
      require       => File['remove_default_ulimit_settings'];
 
     'hard_nproc':
      ulimit_domain => '*',
      ulimit_type   => 'hard',
      ulimit_item   => 'nproc',
      ulimit_value  => '32000',
      require       => File['remove_default_ulimit_settings'];
    }


  
