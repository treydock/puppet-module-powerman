# @summary Manage powerman device alias
#
# @param nodes
#   Nodes for the alias
# @param order
#   Order in powerman.conf
define powerman::alias (
  String $nodes,
  String $order = '75'
) {
  include powerman

  concat::fragment { "powerman.conf.alias.${name}":
    target  => $powerman::cfgfile,
    content => template('powerman/etc/powerman/alias.erb'),
    order   => $order,
  }
}
