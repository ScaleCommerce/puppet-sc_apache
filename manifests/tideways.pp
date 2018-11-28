# == Class: sc_apache::tideways
#
# Installation of Tideways Profiler Extension
#
# === Variables
#
# [*sc_apache::tideways::ensure*]
#  values: link, absent - used to force deinstall of tideways extension
#
# === Examples
#
# ---
# classes:
#   - sc_apache::tideways
#
# sc_apache::tideways:ensure: absent
#
#
# === Authors
#
# Andreas Ziethen <az@scale.sc>
#
# === Copyright
#
# Copyright 2016 ScaleCommerce GmbH.
#

class sc_apache::tideways (
  $daemon_version = 'installed',
  $php_extension_version = 'installed',
  $cli_version = 'installed',
  $proxy = 'https://tideways.scale.sc',
){
  include apache::mod::php

  apt::key {'tideways':
    id     => '6A75A7C5E23F3B3B6AAEEB1411CD8CFCEEB5E8F4',
  }
  apt::source {'tideways':
    location => 'http://s3-eu-west-1.amazonaws.com/qafoo-profiler/packages',
    release  => 'debian',
    repos    => 'main',
  }

  package {'tideways-daemon':
    ensure  => $daemon_version,
    require => [Class['Apache::Mod::Php'], Apt::Source['tideways']],
  }
  package {'tideways-php':
    ensure  => $php_extension_version,
    require => [Class['Apache::Mod::Php'], Apt::Source['tideways']],
    notify  => Service['apache2'],
  }
  package {'tideways-cli':
    ensure  => $cli_version,
    require => [Class['Apache::Mod::Php'], Apt::Source['tideways']],
  }

  supervisord::program { 'tideways-daemon':
    command     => "/usr/bin/tideways-daemon --log=/var/log/tideways/daemon.log --pidfile=/var/run/tideways/tideways-daemon.pid --server=https://tideways.scale.sc",
    autostart   => true,
    autorestart => true,
    user        => tideways,
    require     => Package['tideways-daemon'],
    before      => Service['tideways-daemon'],
  }

  service { 'tideways-daemon':
    ensure   => running,
    provider => supervisor,
    require  => Package['tideways-daemon'],
  }

  # remove legacy files
  file { ['/etc/init.d/tideways-daemon', '/etc/supervisor.d/tideways-daemon.conf']:
    ensure  => absent,
    before  => Supervisord::Program['tideways-daemon'],
    require => Package['tideways-daemon'],
  }

}
