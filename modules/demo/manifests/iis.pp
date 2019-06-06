####
# Class:       intapp open webapp openweb
# Description:
# Customer:    Freshfields Bruckhaus Deringer
# Author:      WM Promus
# Date:        April 2018
###

class demo::iis (
  String $app_pool_name            = 'TestAppPool',
  String $service_account_password = lookup('demo::iis::service_account_password'),
  String $service_account_username = lookup('demo::iis::service_account_username'),
  String $iis_site_name            = 'TestIisSite',
  String $iis_webapp_name          = 'TestWebSite',
  String $path                     = 'C:\\inetpub\\wwwroot\\Test',
  String $logpath                  = 'C:\\inetpub\\logs\\Test',
  String $message                  = "Puppet iis demo",
) {

  require demo::iis_prereqs

  ############################################################################
  # Create application pool and applicationpool                              #
  ############################################################################

  iis_application_pool { $app_pool_name:
    ensure                             => 'present',
    auto_start                         => 'true',
    cpu_action                         => 'NoAction',
    cpu_reset_interval                 => '00:05:00',
    cpu_smp_affinitized                => 'false',
    cpu_smp_processor_affinity_mask    => '4294967295',
    cpu_smp_processor_affinity_mask2   => '4294967295',
    disallow_overlapping_rotation      => 'false',
    disallow_rotation_on_config_change => 'false',
    enable32_bit_app_on_win64          => 'false',
    enable_configuration_override      => 'true',
    identity_type                      => 'SpecificUser',
    idle_timeout                       => '00:00:00',
    idle_timeout_action                => 'Terminate',
    load_balancer_capabilities         => 'HttpLevel',
    load_user_profile                  => 'false',
    log_event_on_process_model         => 'IdleTimeout',
    log_event_on_recycle               => 'Time,Memory,OnDemand,PrivateMemory',
    logon_type                         => 'LogonBatch',
    managed_pipeline_mode              => 'Integrated',
    managed_runtime_version            => 'v4.0',
    manual_group_membership            => 'false',
    max_processes                      => '1',
    orphan_worker_process              => 'false',
    pass_anonymous_token               => 'true',
    password                           => $service_account_password,
    ping_interval                      => '00:00:30',
    ping_response_time                 => '00:01:30',
    pinging_enabled                    => 'true',
    queue_length                       => '1000',
    rapid_fail_protection              => 'true',
    rapid_fail_protection_interval     => '00:05:00',
    rapid_fail_protection_max_crashes  => '5',
    set_profile_environment            => 'true',
    shutdown_time_limit                => '00:01:30',
    start_mode                         => 'AlwaysRunning',
    startup_time_limit                 => '00:01:30',
    state                              => 'started',
    user_name                          => $service_account_username,
    require                            => Class['demo::iis_prereqs'],
  }
  ############################################################################
  # Create IIS sites                                                         #
  ############################################################################

  file { $path:
    ensure  => directory,
  }

  #if !defined(Iis_site[$iis_site_name]) {
    iis_site { $iis_site_name:
      ensure               => 'present',
      applicationpool      => $app_pool_name,
      authenticationinfo   => {
        'basic'                       => false,
        'anonymous'                   => true,
        'windows'                     => true,
        'iisClientCertificateMapping' => false,
        'digest'                      => false,
        'clientCertificateMapping'    => false
      },
      bindings             => {
        'bindinginformation' => '*:81:',
        'protocol'           => 'http',
      },
      enabledprotocols     => 'https',
      limits               => {
        'maxconnections'    => 4294967295,
        'connectiontimeout' => 120,
        'maxbandwidth'      => 4294967295
      },
      logflags             => ['ClientIP', 'Date', 'HttpStatus', 'HttpSubStatus', 'Method', 'Referer', 'ServerIP', 'ServerPort', 'Time', 'TimeTaken', 'UriQuery', 'UriStem', 'UserAgent', 'UserName', 'Win32Status'],
      logformat            => 'W3C',
      loglocaltimerollover => 'false',
      logpath              => $logpath,
      logperiod            => 'Daily',
      physicalpath         => $path,
      preloadenabled       => 'false',
      require              => Iis_application_pool[$app_pool_nameClass],
    }
  #}

  exec { "Start iis_site ${iis_site_name}":
    command  => "Start-Website ${iis_site_name}",
    provider => 'powershell',
    onlyif   => "Import-Module WebAdministration;if((Get-ChildItem IIS:\\Sites | where {\$_.Name -eq \'${iis_site_name}\'} | select -ExpandProperty State) -ne \'Started\') {exit 0} else {exit 1}",
  }

  ############################################################################
  # Create application                                                       #
  ############################################################################

  file { "${path}\\${iis_webapp_name}":
    ensure  => directory,
  }

  file { "${path}\\${iis_webapp_name}\\index.html":
    ensure  => file,
    content => template('demo/index.html.erb'),
  }

  iis_application { "${iis_site_name}\\${iis_webapp_name}":
    ensure             => 'present',
    applicationpool    => $app_pool_name,
    authenticationinfo => {
      'iisClientCertificateMapping' => false,
      'clientCertificateMapping'    => false,
      'anonymous'                   => true,
      'basic'                       => false,
      'windows'                     => true
    },
    enabledprotocols   => 'http',
    physicalpath       => "${path}\\${iis_webapp_name}",
    sitename           => $iis_site_name,
    require            => Iis_site[$iis_site_name],
  }

}
