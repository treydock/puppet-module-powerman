define powerman::node (
    $nodename,
    $device,
    $port = '',
    $cfgfile = hiera('powerman::cfg::cfgfile',$powerman::params::cfgfile),
    $order = '50',
  ) {
  concat::fragment { "powerman.conf.node.$nodename":
    target  => $cfgfile,
    content => template("powerman/etc/powerman/node.erb"),
    order   => $order,
  }
}
