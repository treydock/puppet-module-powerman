class powerman::params {
  $service_enable = true
  $service_ensure = true
  $powerman_server = $::fqdn
  $powerman_port = '10101'
  $cfgfile = "/etc/powerman/powerman.conf"
  $loopback = false
  $tcpwrappers = true
  $driver_dir = "/etc/powerman"
  $driver_list = ["powerman","ipmipower"]
}
