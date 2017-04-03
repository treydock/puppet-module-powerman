define powerman::device (
  String $driver,
  String $endpoint,
  String $flags = '',
  String $order = '25',
) {

  include powerman
  $cfgfile = $powerman::cfgfile
  
  concat::fragment { "powerman.conf.device.${name}":
    target  => $cfgfile,
    content => template('powerman/etc/powerman/device.erb'),
    order   => $order,
  }
}
