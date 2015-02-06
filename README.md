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

Setup a backup mongodb on a separate server 

    class { 'mongodb_ops_manager::backup_db':
      logpath      => '/data/backupdb/mongodb.log',
      dbpath       => '/data/backupdb',
      version      => '2.6.4-1',  
    }
  
On the mms server install the application db, the mms application, backup daemon

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
  
    class { 'mongodb_ops_manager::backup':
      backup_db_host => 'backupserver',
      require        => Class['mongodb_ops_manager::application']
    } 
    
Logon to the mms server (http://mms.mycompany.com:8080) and register a user and find the mmsApiKey.     
    
On the mms server install monitoring and backup agents specifying the mmiApiKey:    
  
    class { 'mongodb_ops_manager::monitoring_agent':
      mmsApiKey => 'mmsApiKey'
    } 

    class { 'mongodb_ops_manager::backup_agent':
      mmsApiKey => 'mmsApiKey'
    } 
 

Detailed Usage:
===============

TO COME:


Ulimits:
========

    Remove the default ulimit settings that come with the operating system:

    sudo rm /etc/security/limits.d/90-nproc.conf
    Edit the /etc/security/limits.conf file to configure the following settings:

    * soft nofile 64000
    * hard nofile 64000
    * soft nproc 32000
    * hard nproc 32000


  
