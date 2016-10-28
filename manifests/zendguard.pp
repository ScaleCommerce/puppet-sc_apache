# == Class: sc_apache::zendguard
#
# Installation of Zendguard Extension - dependent on php version
#
# === Variables
#
# [*sc_apache::zendguard::ensure*]
#  values: link, absent - used to force deinstall of zendguard extension
#
# === Examples
#
# ---
# classes:
#   - sc_apache::zendguard
#
# sc_apache::zendguard:ensure: absent
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
class sc_apache::zendguard(
  $ensure = 'installed',
) {

  if($ensure == 'installed') {
    $zendguard_file_ensure = 'present'
    $zendguard_link_ensure = 'link'
  } else {
    $zendguard_file_ensure = 'absent'
    $zendguard_link_ensure = 'absent'
  }

  $php_version       = $sc_apache::php::major_version
  $php_lib_path      = $sc_apache::php::php_lib_path

  # install zendguard
  file {"$php_lib_path/ZendGuardLoader.so":
    source  => "puppet:///modules/sc_apache/php-$php_version/ZendGuardLoader.so",
    require => Class['Apache::Mod::Php'],
    ensure => $zendguard_file_ensure,
  }->
  file {"/etc/php-sc/mods-available/zendguard.ini":
    content => "zend_extension=$php_lib_path/ZendGuardLoader.so",
    ensure => $zendguard_file_ensure,
  }->
  file {"/etc/php-sc/apache2/conf.d/02-zendguard.ini":
    ensure => $zendguard_link_ensure,
    target => "/etc/php-sc/mods-available/zendguard.ini",
    notify => Service['apache2'],
  }->
  file {"/etc/php-sc/cli/conf.d/02-zendguard.ini":
    ensure => $zendguard_link_ensure,
    target => "/etc/php-sc/mods-available/zendguard.ini",
  }

  # install opcache for zendguard loader
  case $php_version {
    '5.4', '5.5', '5.6': {
      file {"$php_lib_path/opcache.so":
        source  => "puppet:///modules/$module_name/php-$php_version/opcache.so",
        require => Class['Apache::Mod::Php'],
        notify  => Service['apache2'],
        owner   => root,
        group   => root,
        mode    => '0644',
      }
    }
  }
}
