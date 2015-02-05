puppet-mongodb_ops_manager
==========================

Install and Manage MongoDB Ops Manager (MMS On Premise)

See:

      http://mms.mongodb.com/help-hosted/v1.5/tutorial/install-on-prem-quick-start/
      http://mms.mongodb.com/help-hosted/v1.5/tutorial/nav/install-on-prem/


It relies on puppet module puppetlabs/mongodb to install the mongodb database.
The mms application and mms mongodb database can be installed on one server.
The backup database should be first installed on another server.

Currently the scripts don't support authentication or replica sets for application and backup databases 


Minimal Usage: 
=============

First setup a backup mongodb on a separate server 

    class { 'mongodb_ops_manager::backup_db':
      logpath      => '/data/backupdb/mongodb.log',
      dbpath       => '/data/backupdb',
      version      => '2.6.4-1',  
    }
  
Then on the mms server setup the application db, the mms application, backup application, 
monitoring and backup agents:

    class { 'mongodb_ops_manager::application_db':
      logpath      => '/data/mmsdb/mongodb.log',
      dbpath       => '/data/mmsdb',
      version      => '2.6.4-1',  
    }
  
    class { 'mongodb_ops_manager::application':
      from_email_addr       => 'mms-admin@company.com',
      reply_to_email_addr   => 'mms-admin@company.com',
      admin_from_email_addr => 'mms-admin@company.com',
      admin_email_addr      => 'mms-admin@company.com',
      bounce_email_addr     => 'mms-admin@company.com',
      mail_hostname         => 'mymailhost.com',
      mail_port             => 25,  
      require               => Class['mongodb_ops_manager::application_db'] 
    }
  
    class { 'mongodb_ops_manager::backup':
      backup_db_host => 'backupserver',
      require        => Class['mongodb_ops_manager::application']
    }  
  
    class { 'mongodb_ops_manager::mms_agent': 
      require => Class['mongodb_ops_manager::backup']
    } 

    class { 'mongodb_ops_manager::backup_agent':
      mmsApiKey => 'mmsApiKey',
      require   => Class['mongodb_ops_manager::mms_agent']   
    } 
 

Detailed Usage:
===============

TO COME:


  
