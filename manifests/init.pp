class powerman(
    $service_enable = hiera('powerman::service::enable',$powerman::params::service_enable),
    $service_ensure = hiera('powerman::service::ensure',$powerman::params::service_ensure),
    $powerman_server = hiera('powerman::service::hostname',$powerman::params::power_server),
    $powerman_port = hiera('powerman::service::port',$powerman::params::powerman_port),
    $loopback = hiera('powerman::cfg::loopback',$powerman::params::loopback),
    $cfgfile = hiera('powerman::cfg::cfgfile',$powerman::params::cfgfile),
    $driver_dir = hiera('powerman::cfg::driver_dir',$powerman::params::driver_dir),
    $driver_list = hiera('powerman::cfg::driver_list',$powerman::params::driver_list),
  ) inherits powerman::params {
  # packages
  package { "powerman":
    ensure => present,
  }

  # config files
  file { "$driver_dir":
    ensure  => directory,
    owner   => root,
    group   => root,
    mode    => '0755',
    require => Package["powerman"],
  }
  concat { "$cfgfile":
    ensure => present,
    owner   => root,
    group   => root,
    mode    => '0644',
    require => Package["powerman"],
  }
  concat::fragment { "powerman.conf.header":
    target  => $cfgfile,
    content => template("powerman/etc/powerman/powerman.conf.header.erb"),
    order   => 01,
  }

  # services
  service { "powerman":
    enable    => $service_enable,
    ensure    => $service_ensure,
    require   => [File[$driver_dir],
                  Concat[$cfgfile]],
    subscribe => Concat[$cfgfile],
  }
}
