define powerman::node (
    $device,
    $port = '',
    $cfgfile = hiera('powerman::cfg::cfgfile',$powerman::params::cfgfile),
    $order = '50',
  ) {
  concat::fragment { "powerman.conf.node.$name":
    target  => $cfgfile,
    content => template("powerman/etc/powerman/node.erb"),
    order   => $order,
  }
}
