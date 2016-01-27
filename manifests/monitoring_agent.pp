# Class: mongodb_ops_manager::monitoring_agent
#
# install mongodb monitoring_agent for mongodb ops manager (mms on premise).
#
#
class mongodb_ops_manager::monitoring_agent(
  $mmsApiKey   = '',
  $version     = '2.5.15.1526-1',
  $platform    = 'rhel7',
  $mmsBaseUrl  = 'http://127.0.0.1:8080',
)
{

  exec { 'download-mms-monitoring-agent':
    command => "curl -OL ${mmsBaseUrl}/download/agent/automation/mongodb-mms-automation-agent-manager-${version}.x86_64.${platform}.rpm",
    cwd     => '/tmp',
    creates => "/tmp/mongodb-mms-automation-agent-manager-${version}.x86_64$.{platform}.rpm",
  }

  exec { 'install-mms-monitoring-agent':
    cwd     => '/tmp',
    creates => '/usr/bin/mongodb-mms-monitoring-agent',
    command => "rpm -U  \"/tmp/mongodb-mms-automation-agent-manager-${version}.x86_64.${platform}.rpm\"",
    require => Exec['download-mms-monitoring-agent'],
    timeout => 0
  }
  
 # file { '/etc/mongodb-mms/automation-agent.config':
 #   content => template('mongodb_ops_manager/automation-agent.config.erb'),
 #   owner   => 'mongodb-mms-agent',
 #   group   => 'mongodb-mms-agent',
 #   mode    => '0600',
 #   require => Exec['install-mms-monitoring-agent'],
 # }
  
 # service { 'mongodb-mms-monitoring-agent':
 #   ensure    => running,
 #   enable    => true,
 #   hasstatus => true,
 #   restart   => true,
 #   provider  => 'init',
 #   require   => File['/etc/mongodb-mms/monitoring-agent.config']
 # }  
  
 
}