define powerman::node (
  String $device,
  String $port = '',
  String $order = '50',
) {

  include powerman
  $cfgfile = $powerman::cfgfile

  concat::fragment { "powerman.conf.node.$name":
    target  => $cfgfile,
    content => template('powerman/etc/powerman/node.erb'),
    order   => $order,
  }
}
