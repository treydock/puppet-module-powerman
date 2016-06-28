class powerman::params {
  $service_enable = true
  $service_ensure = true
  $cfgfile = "/etc/powerman/powerman.conf"
  $driver_dir = "/etc/powerman"
  $driver_list = ["powerman","ipmipower"]
  $powerman_server = $::fqdn
  $powerman_port = '10101'
  $loopback = false
}
