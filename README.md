# puppet-module-powerman

[![Puppet Forge](http://img.shields.io/puppetforge/v/treydock/powerman.svg)](https://forge.puppetlabs.com/treydock/powerman)
[![CI Status](https://github.com/treydock/puppet-module-powerman/workflows/CI/badge.svg?branch=master)](https://github.com/treydock/puppet-module-powerman/actions?query=workflow%3ACI)

####Table of Contents

1. [Setup - The basics of getting started with powerman](#setup)
    * [What powerman affects](#what-powerman-affects)
2. [Usage - Configuration options and additional functionality](#usage)
3. [Reference - Module reference](#reference)

## Setup

### What powerman affects

This module will install and configures [powerman](https://github.com/chaos/powerman).

## Usage

Install and configure powerman to listen on all interfaces and define devices, nodes and aliases

```puppet
class { '::powerman':
  listen => '0.0.0.0',
}
powerman::device { 'compute-ipmi':
  driver   => 'ipmipower',
  endpoint => '/usr/sbin/ipmipower -D LAN_2_0 -u admin -p changeme -h bmc-compute[01-04]',
}
powerman::nodes { 'compute[01-04]':
  device => 'compute-ipmi',
  port   => 'bmc-compute[01-04]',
}
powerman::alias { 'compute':
  nodes => 'compute[01-04]',
}
```

To configure a system as a powerman client:

```puppet
class { '::powerman':
  server          => false,
  powerman_server => 'powerman.example.com',
}
```

This is an example of exporting console configurations for all physical servers:

```puppet
if $facts['virtual'] == 'physical' {
  @@powerman::device { "bmc-${::hostname}-ipmi":
    driver   => 'ipmipower',
    endpoint => "/usr/sbin/ipmipower -D LAN_2_0 -u admin -p changeme -h bmc-${::hostname}-ipmi |&",
  }
  @@powerman::node { $::hostname:
    device => "bmc-${::hostname}-ipmi",
    port   => "bmc-${::hostname}",
  }
}
```

Then collect all the exported resources:

```puppet
Powerman::Device <<| |>>
Powerman::Node <<| |>>
Powerman::Alias <<| |>>
```

## Reference

[http://treydock.github.io/puppet-module-powerman/](http://treydock.github.io/puppet-module-powerman/)
