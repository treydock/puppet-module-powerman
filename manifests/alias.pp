define powerman::alias(
    $nodes,
    $cfgfile = hiera('powerman::cfg::cfgfile',$powerman::params::cfgfile),
    $order = '75'
  ) {
  concat::fragment { "powerman.conf.alias.$name":
    target  => $cfgfile,
    content => template("powerman/etc/powerman/alias.erb"),
    order   => $order,
  }
}
