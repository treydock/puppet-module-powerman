define powerman::device(
    $driver,
    $endpoint,
    $flags = '',
    $cfgfile = hiera('powerman::cfg::cfgfile',$powerman::params::cfgfile),
    order = '25',
  ) {
  concat::fragment { "powerman.conf.device.$name":
    target  => $cfgfile,
    content => template("powerman/etc/powerman/device.erb"),
    order   => $order,
  }
}
