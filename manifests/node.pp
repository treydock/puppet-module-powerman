# @summary Manage powerman node
#
# @param device
#   Node device
# @param port
#   Node port
# @param order
#   Order in powerman.conf
define powerman::node (
  String $device,
  Optional[String] $port = undef,
  String $order = '50',
) {
  include powerman

  concat::fragment { "powerman.conf.node.${name}":
    target  => $powerman::cfgfile,
    content => template('powerman/etc/powerman/node.erb'),
    order   => $order,
  }
}
