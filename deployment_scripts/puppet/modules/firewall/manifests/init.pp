class firewall{
  ini_setting {'add_fwaas_service_plugin':
    ensure => present,
    section => 'DEFAULT',
    path => '/etc/neutron/neutron.conf',
    setting => 'service_plugins',
    value => 'neutron.services.l3_router.l3_router_plugin.L3RouterPlugin,neutron.services.metering.metering_plugin.MeteringPlugin,firewall',
  }
  file_line { 'service_provider':
    ensure => present,
    line   => 'service_provider = FIREWALL:Iptables:neutron.agent.linux.iptables_firewall.OVSHybridIptablesFirewallDriver:default',
    path   => '/etc/neutron/neutron.conf',
  require => Ini_setting["add_fwaas_service_plugin"],}
  ini_setting {'enable_neutron_driver':
    ensure => present,
    section => 'fwaas',
    path => '/etc/neutron/fwaas_driver.ini',
    setting => 'driver',
    value => 'neutron.services.firewall.drivers.linux.iptables_fwaas.IptablesFwaasDriver',
  require => File_line["service_provider"],}
  ini_setting {'enable_neutron':
    ensure => present,
    section => 'fwaas',
    path => '/etc/neutron/fwaas_driver.ini',
    setting => 'endbled',
    value => 'True',
  require => Ini_setting["enable_neutron_driver"],}
  exec { 'enable_fwaas_dashboard':
    command => "/bin/sed -i \"s/'enable_firewall': False/'enable_firewall': True/\" /usr/share/openstack-dashboard/openstack_dashboard/local/local_settings.py",
    unless => "/bin/egrep \"'enable_firewall': True\" /usr/share/openstack-dashboard/openstack_dashboard/local/local_settings.py",
  require => Ini_setting["enable_neutron"],}
  service { "neutron-server":
    ensure => "running",
    enable => "true",
  require => Exec["enable_fwaas_dashboard"],}
  service { "apache2":
    ensure => "running",
    enable => "true",
  require => Service["neutron-server"],}
}


