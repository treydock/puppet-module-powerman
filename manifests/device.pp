# @summary Manage powerman device
#
# @param driver
#   The device driver
# @param endpoint
#   Device endpoint
# @param flags
#   Device flags
# @param order
#   Order in powerman.conf
define powerman::device (
  String $driver,
  String $endpoint,
  Optional[String] $flags = undef,
  String $order = '25',
) {

  include powerman

  concat::fragment { "powerman.conf.device.${name}":
    target  => $powerman::cfgfile,
    content => template('powerman/etc/powerman/device.erb'),
    order   => $order,
  }
}
