# == Class: sc_apache::sourceguardian
#
# Installation of sourceguardian Encode
#
# === Variables
#
# [*sc_apache::sourceguardian::ensure*]
#  values: link, absent - used to force deinstall of sourceguardian extension
#
# === Examples
#
# ---
# classes:
#   - sc_apache::sourceguardian
#
# sc_apache::sourceguardian:ensure: absent
#
#
# === Authors
#
# Dennis Heidtmann <dh@scale.sc>
#
# === Copyright
#
# Copyright 2023 ScaleCommerce GmbH.
#
class sc_apache::sourceguardian(
  $ensure = 'link',
) {

  include sc_apache::php

  $php_lib_path      = $sc_apache::php::php_lib_path
  $php_version       = $sc_apache::php::major_version

  # install sourceguardian
  if($ensure == 'link') {
    $sourceguardian_loader_ensure = 'present'
  } else {
    $sourceguardian_loader_ensure = 'absent'
  }
  file {"$php_lib_path/ixed.$php_version.lin":
    source  => "puppet:///modules/sc_apache/php-$php_version/ixed.$php_version.lin",
    require => Package['httpd'],
    ensure => $sourceguardian_loader_ensure,
  }->
  file {"/etc/php-sc/mods-available/sourceguardian.ini":
    content => "zend_extension=$php_lib_path/ixed.$php_version.lin",
    ensure => $sourceguardian_loader_ensure,
  }->
  file {"/etc/php-sc/apache2/conf.d/01-sourceguardian.ini":
    ensure => $ensure,
    target => "/etc/php-sc/mods-available/sourceguardian.ini",
    notify => Service['apache2'],
  }->
  file {"/etc/php-sc/cli/conf.d/01-sourceguardian.ini":
    ensure => $ensure,
    target => "/etc/php-sc/mods-available/sourceguardian.ini",
  }
}
