class powerman(
  Enum['present', 'absent'] $ensure = 'present',
  Boolean $server = true,
  Boolean $client = true,
  Optional[String] $listen = undef,
  String $powerman_server = $::fqdn,
  Integer $powerman_port = 10101,
  Boolean $loopback = false,
  Boolean $tcpwrappers = false,
  String $cfgfile = '/etc/powerman/powerman.conf',
  String $driver_dir = '/etc/powerman',
  Array $driver_list = ['powerman','ipmipower'],
  Hash $aliases  = {},
  Hash $devices  = {},
  Hash $nodes    = {},
) inherits powerman::params {

  $_listen = pick($listen, $powerman_server)

  if $ensure == 'present' {
    $package_ensure = 'present'
    $file_ensure    = 'file'
    if $server {
      $service_ensure = 'running'
      $service_enable = true
    } else {
      $service_ensure = 'stopped'
      $service_enable = false
    }
  } else {
    $package_ensure = 'absent'
    $file_ensure    = 'absent'
    $service_ensure = 'stopped'
    $service_enable = false
  }

  package { 'powerman':
    ensure => $package_ensure,
  }

  if $server {
    file { $driver_dir:
      ensure  => 'directory',
      owner   => 'root',
      group   => 'root',
      mode    => '0755',
      require => Package['powerman'],
    }
    concat { $cfgfile:
      ensure    => 'present',
      owner     => 'root',
      group     => 'root',
      mode      => '0644',
      show_diff => false,
      require   => Package['powerman'],
    }
    concat::fragment { 'powerman.conf.header':
      target  => $cfgfile,
      content => template('powerman/etc/powerman/powerman.conf.header.erb'),
      order   => '01',
    }
    create_resources('powerman::alias', $aliases)
    create_resources('powerman::device', $devices)
    create_resources('powerman::node', $nodes)

    # services
    service { 'powerman':
      ensure     => $service_ensure,
      enable     => $service_enable,
      hasstatus  => true,
      hasrestart => true,
      subscribe  => Concat[$cfgfile],
    }
  } else {
    service { 'powerman':
      ensure  => $service_ensure,
      enable  => $service_enable,
      require => Package['powerman'],
    }

    file { '/etc/profile.d/powerman.sh':
      ensure  => $file_ensure,
      content => template('powerman/etc/profile.d/powerman.sh.erb'),
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
    }
    file { '/etc/profile.d/powerman.csh':
      ensure  => $file_ensure,
      content => template('powerman/etc/profile.d/powerman.csh.erb'),
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
    }
  }

}
