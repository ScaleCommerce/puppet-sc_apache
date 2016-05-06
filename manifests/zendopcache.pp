# == Class: sc_apache::zendopcache
#
# Installation of Zend Opcache Extension
#
# === Variables
#
# [*sc_apache::zendopcache::ensure*]
#  values: link, absent - used to force deinstall of zendopcache extension
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

class sc_apache::zendopcache (
  $ensure = 'installed',
){

  $php_lib_path      = $sc_apache::php::php_lib_path
  $php_version       = $sc_apache::php::php_version
  $php_etc_dir       = $sc_apache::php::php_etc_dir
  $libapache_version = $sc_apache::php::libapache_version
  $version_repo      = $sc_apache::php::version_repo

  # install zendopcache in php 5.4
  if ($php_version == '5.4') {

    if($ensure == 'installed') {
      $opcache_ini_ensure = 'link'
    } else {
      $opcache_ini_ensure = 'absent'
    }

    package {'php-pear':
      ensure => $ensure,
      require => Apt::Ppa["ppa:$version_repo"],
    }->
    package {['build-essential', 'php5-dev']:
      ensure => $ensure,
    }->
    exec {'pecl_install_zendopcache':
      command => '/usr/bin/pecl install zendopcache',
      creates => "$php_lib_path/opcache.so",
    }->
    file {"/etc/$php_etc_dir/mods-available/opcache.ini":
      content => "zend_extension=$php_lib_path/opcache.so",
    }->
    file {"/etc/$php_etc_dir/apache2/conf.d/03-opcache.ini":
      ensure => $opcache_ini_ensure,
      target => "/etc/$php_etc_dir/mods-available/opcache.ini",
      notify => Service['apache2'],
    }->
    file {"/etc/$php_etc_dir/cli/conf.d/03-opcache.ini":
      ensure => $opcache_ini_ensure,
      target => "/etc/$php_etc_dir/mods-available/opcache.ini",
    }
  }
  # also replace opcache.so in php 5.5 and 5.6
  if $php_version == '5.5' or $php_version == '5.6' {
    file {"$php_lib_path/opcache.so":
      source  => "puppet:///modules/sc_apache/php-$php_version/opcache.so",
      require => Package[$libapache_version],
      notify  => Service['apache2'],
      owner   => root,
      group   => root,
    }
  }
}