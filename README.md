puppet-mongodb_ops_manager
==========================

Install and Manage MongoDB Ops Manager (MMS On Premise)

See:

      http://mms.mongodb.com/help-hosted/v1.5/tutorial/install-on-prem-quick-start/
      http://mms.mongodb.com/help-hosted/v1.5/tutorial/nav/install-on-prem/


It relies on puppet module puppetlabs/mongodb to install the mongodb database.
The mms application and mms mongodb database can be installed on one server.
The backup database should be first installed on another server.

Currently the scripts don't support authentication or replica sets for application and backup mongodb databases. 
NOTE: *** This is a very much a first version and currently support readhat/centos. ***  


Minimal Usage: 
=============

Setup a backup mongodb on a separate server if using the backup daemon 

    class { 'mongodb_ops_manager::backup_db':
      logpath      => '/data/backupdb/mongodb.log',
      dbpath       => '/data/backupdb',
      version      => '2.6.4-1',  
    }
  
On the mms server install the application db, the mms application

    class { 'mongodb_ops_manager::application_db':
      logpath      => '/data/mmsdb/mongodb.log',
      dbpath       => '/data/mmsdb',
      version      => '2.6.4-1',  
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
    
On the mms server install also install the backup daemon if doing backup of mongodb databases    
  
    class { 'mongodb_ops_manager::backup':
      backup_db_host => 'backupserver',
      require        => Class['mongodb_ops_manager::application']
    } 
    
Logon to the mms server (http://mms.mycompany.com:8080) and register a user and find the mmsApiKey.     
    
On the mms server install monitoring agent specifying the mmiApiKey:    
  
    class { 'mongodb_ops_manager::monitoring_agent':
      mmsApiKey => 'mmsApiKey'
    } 
    
On the mms server install backup agent specifying the mmiApiKey (if backing up mongodb database) :        

    class { 'mongodb_ops_manager::backup_agent':
      mmsApiKey => 'mmsApiKey'
    } 
 

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


  
