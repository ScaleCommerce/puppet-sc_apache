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
  $ensure = 'installed',
){
  if($ensure == 'installed') {
    $apt_ensure = 'present'
  } else {
    $apt_ensure = 'absent'
  }

  include apache::mod::php

  apt::key {'tideways':
    ensure => $apt_ensure,
    id     => '6A75A7C5E23F3B3B6AAEEB1411CD8CFCEEB5E8F4',
    source => 'https://s3-eu-west-1.amazonaws.com/qafoo-profiler/packages/EEB5E8F4.gpg',
  }
  apt::source {'tideways':
    ensure   => $apt_ensure,
    location => 'http://s3-eu-west-1.amazonaws.com/qafoo-profiler/packages',
    release  => 'debian',
    repos    => 'main',
  }
  package {['tideways-daemon', 'tideways-php', 'tideways-cli']:
    ensure  => $ensure,
    require => [Class['Apache::Mod::Php'], Apt::Source['tideways']],
    notify  => Service['apache2'],
  }

  # supervisor
  file { '/etc/init.d/tideways-daemon':
    ensure => link,
    target => $sc_apache::supervisor_init_script,
  }

  file { '/etc/supervisor.d/tideways-daemon.conf':
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template("${module_name}/tideways.supervisor.conf.erb"),
    notify => Class[supervisord::reload],
  }

}
