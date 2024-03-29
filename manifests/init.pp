# @summary Manage powerman
#
# @example
#   include powerman
#
# @param ensure
#   Module ensure property
# @param manage_epel
#   Boolean that determines if EPEL repo should be managed
# @param server
#   Boolean that sets host to act as powerman server
# @param listen
#   Address to listen on
# @param powerman_server
#   Hostname of powerman server
# @param powerman_port
#   The port of powerman server
# @param tcpwrappers
#   Enable tcpwrappers support
# @param cfgfile
#   Path to powerman.conf
# @param driver_dir
#   Driver directory
# @param driver_list
#   List of drivers to load
# @param aliases
#   Hash of aliases to pass to `powerman::alias`
# @param devices
#   Hash of devices to pass to `powerman::device`
# @param nodes
#   Hash of nodes to pass to `powerman::node`
# @param pid_dir
#   Directory for PID file
# @param user
#   User running powerman service
# @param group
#   Group running powerman service
class powerman (
  Enum['present', 'absent'] $ensure = 'present',
  Boolean $manage_epel = true,
  Boolean $server = true,
  Stdlib::IP::Address $listen = '127.0.0.1',
  Stdlib::Host $powerman_server = $facts['networking']['fqdn'],
  Stdlib::Port $powerman_port = 10101,
  Optional[Boolean] $tcpwrappers = undef,
  Stdlib::Absolutepath $cfgfile = '/etc/powerman/powerman.conf',
  Stdlib::Absolutepath $driver_dir = '/etc/powerman',
  Array $driver_list = ['powerman','ipmipower'],
  Hash $aliases  = {},
  Hash $devices  = {},
  Hash $nodes    = {},
  Stdlib::Absolutepath $pid_dir = '/var/run/powerman',
  String $user = 'daemon',
  String $group = 'daemon',
) {

  if $ensure == 'present' {
    $package_ensure = 'present'
    $cfg_ensure     = 'present'
    if $server {
      $env_ensure     = 'absent'
      $service_ensure = 'running'
      $service_enable = true
    } else {
      $env_ensure     = 'file'
      $service_ensure = 'stopped'
      $service_enable = false
    }
  } else {
    $package_ensure = 'absent'
    $cfg_ensure     = 'absent'
    $env_ensure     = 'absent'
    $service_ensure = 'stopped'
    $service_enable = false
  }

  if dig($facts, 'os', 'family') == 'RedHat' {
    if $manage_epel {
      include epel
      Yumrepo['epel'] -> Package['powerman']
    }
  }

  package { 'powerman':
    ensure => $package_ensure,
  }

  if $server and $ensure == 'present' {
    file { $driver_dir:
      ensure  => 'directory',
      owner   => 'root',
      group   => 'root',
      mode    => '0755',
      require => Package['powerman'],
    }
  }

  if $server or $ensure == 'absent' {
    concat { $cfgfile:
      ensure    => $cfg_ensure,
      owner     => $user,
      group     => 'root',
      mode      => '0640',
      show_diff => false,
      require   => Package['powerman'],
      notify    => Service['powerman'],
    }
  }

  if $server and $ensure == 'present' {
    concat::fragment { 'powerman.conf.header':
      target  => $cfgfile,
      content => template('powerman/etc/powerman/powerman.conf.header.erb'),
      order   => '01',
    }
    $aliases.each |$name, $alias| {
      powerman::alias { $name: * => $alias }
    }
    $devices.each |$name, $device| {
      powerman::device { $name: * => $device }
    }
    $nodes.each |$name, $node| {
      powerman::node { $name: * => $node }
    }

    file { $pid_dir:
      ensure  => 'directory',
      owner   => $user,
      group   => $group,
      mode    => '0755',
      require => Package['powerman'],
      before  => Service['powerman'],
    }
  }

  service { 'powerman':
    ensure     => $service_ensure,
    enable     => $service_enable,
    hasstatus  => true,
    hasrestart => true,
    require    => Package['powerman'],
  }

  file { '/etc/profile.d/powerman.sh':
    ensure  => $env_ensure,
    content => template('powerman/etc/profile.d/powerman.sh.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }
  file { '/etc/profile.d/powerman.csh':
    ensure  => $env_ensure,
    content => template('powerman/etc/profile.d/powerman.csh.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

}
