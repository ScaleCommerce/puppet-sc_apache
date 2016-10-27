# == Class: sc_apache::ioncube
#
# Installation of Ioncube Encode
#
# === Variables
#
# [*sc_apache::ioncube::ensure*]
#  values: link, absent - used to force deinstall of ioncube extension
#
# === Examples
#
# ---
# classes:
#   - sc_apache::ioncube
#
# sc_apache::ioncube:ensure: absent
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
class sc_apache::ioncube(
  $ensure = 'link',
) {

  $php_lib_path      = $sc_apache::php::php_lib_path
  $php_version       = $sc_apache::php::major_version
  $php_etc_dir       = $sc_apache::php::php_etc_dir

  # install ioncube
  if($ensure == 'link') {
    $ioncube_loader_ensure = 'present'
  } else {
    $ioncube_loader_ensure = 'absent'
  }
  file {"$php_lib_path/ioncube_loader_lin_$php_version.so":
    source  => "puppet:///modules/sc_apache/php-$php_version/ioncube_loader_lin_$php_version.so",
    require => Package['httpd'],
    ensure => $ioncube_loader_ensure,
  }->
  file {"/etc/php-sc/mods-available/ioncube.ini":
    content => "zend_extension=$php_lib_path/ioncube_loader_lin_$php_version.so",
    ensure => $ioncube_loader_ensure,
  }->
  file {"/etc/php-sc/apache2/conf.d/01-ioncube.ini":
    ensure => $ensure,
    target => "/etc/php-sc/mods-available/ioncube.ini",
    notify => Service['apache2'],
  }->
  file {"/etc/php-sc/cli/conf.d/01-ioncube.ini":
    ensure => $ensure,
    target => "/etc/php-sc/mods-available/ioncube.ini",
  }
}
