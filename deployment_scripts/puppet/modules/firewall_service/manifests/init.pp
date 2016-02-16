class firewall_service {
  exec { 'neutron-db-sync':
    command => 'neutron-db-manage --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugin.ini --service fwaas upgrade head',
    path => '/usr/bin',
    refreshonly => true,
    tries => 10,
    try_sleep => 10,
  }
  exec { "neutron-server":
    command => "/usr/sbin/service neutron-server restart",
    require => Exec["neutron-db-sync"],}
  exec { "apache2":
    command => "/usr/sbin/service apache2 restart",
    require => Exec["neutron-db-sync"],}
}
