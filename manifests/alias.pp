define powerman::alias (
  String $nodes,
  String $order = '75'
) {

  include powerman
  $cfgfile = $powerman::cfgfile

  concat::fragment { "powerman.conf.alias.${name}":
    target  => $cfgfile,
    content => template('powerman/etc/powerman/alias.erb'),
    order   => $order,
  }
}
