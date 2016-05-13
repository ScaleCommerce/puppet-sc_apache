# == Class: sc_apache::php
#
# Installation of PHP, PHP Extensions, PHP ini settings
#
# === Variables
#
# [*php::version*]
#  by now this may contain: 5.4, 5.5, 5.6, 7.0
#
# === Examples
#
# ---
# php::version: '5.6'
#
# php::modules:
#   - php5-mysql
#   - php5-gd
#   - php5-mcrypt
#   - php5-cli
#   - php5-curl
#   - php5-intl
#   - php5-xsl
#
# sc_apache::php_ini_settings:
#   max_execution_time: 1800
#   memory_limit: 30M
#
# === Authors
#
# Andreas Ziethen <az@scale.sc>
#
# === Copyright
#
# Copyright 2016 ScaleCommerce GmbH.
#
class sc_apache::php (
  $php_version = '5.6',
  $php_modules = hiera_array('php::modules', []),
){
  # set some variables an pathes which depend on php version
  $version_repo = $php_version ? {
    '5.4' => 'syseleven-platform/php54',
    '5.5' => 'ondrej/php5',
    '5.6' => 'ondrej/php5-5.6',
    '7.0' => 'ondrej/php'
  }

  $repo_key_sys11   = 'C70320183C05E1E9F24532C87736223724911626'
  $repo_key_ondrej  = '14AA40EC0831756756D7F66C4F4EA0AAE5267A6C'

  $php_lib_path = $php_version ? {
    '5.4' => '/usr/lib/php5/20100525',
    '5.5' => '/usr/lib/php5/20121212',
    '5.6' => '/usr/lib/php5/20131226',
    '7.0' => '/usr/lib/php/20151012'
  }

  case $php_version {
    '7.0': {
      $libapache_version  = 'libapache2-mod-php7.0'
      $php_etc_dir        = 'php7'
      $php_etc_real_dir   = 'php/7.0'
      $php_extension_name = 'php7.0'
    }
    default: {
      $libapache_version  = 'libapache2-mod-php5'
      $php_etc_dir        = 'php5'
      $php_extension_name = 'php5'
    }
  }

  # set key and repository and install package
  case $php_version {
    '5.4': {
      apt::ppa {['ppa:ondrej/php5-5.6', 'ppa:ondrej/php5']:
        ensure => absent,
      }
      apt::key {"ppa:$version_repo":
        ensure => present,
        id     => $repo_key_sys11,
      }
      apt::ppa {"ppa:$version_repo":
        ensure => present,
      }
    }
    '5.5': {
      apt::ppa {['ppa:ondrej/php5-5.6', 'ppa:syseleven-platform/php54']:
        ensure => absent,
      }
      apt::ppa {"ppa:$version_repo":
        ensure => present,
      }
    }
    '5.6': {
      apt::ppa {['ppa:syseleven-platform/php54', 'ppa:ondrej/php5']:
        ensure => absent,
      }
      apt::key {"ppa:$version_repo":
        ensure => present,
        id     => $repo_key_ondrej,
      }
      apt::ppa {"ppa:$version_repo":
        ensure => present,
      }
    }
    '7.0': {
      apt::key {"ppa:$version_repo":
        ensure => present,
        id     => $repo_key_ondrej,
      }
      apt::ppa {"ppa:$version_repo":
        ensure => present,
      }->
      file { 'augeas_symlink':
        ensure => link,
        path    => "/etc/$php_etc_dir",
        target  => "/etc/$php_etc_real_dir",
        owner   => 'root',
        group   => 'root',
        before  => Augeas['php_ini'],
      }
    }
    default: { fail('php_version has to be one of 5.4, 5.5, 5.6, 7.0') }
  }

  package {$libapache_version:
    ensure => installed,
    require => Apt::Ppa["ppa:$version_repo"],
  }

  # install php modules
  package { [$php_modules]:
    ensure  => installed,
    require => [Package[$libapache_version], Apt::Ppa["ppa:$version_repo"]],
  }

  $php_ini_settings = hiera_hash("sc_apache::php_ini_settings", {})
  each($php_ini_settings) |$name, $value| {
    augeas { $name:
      notify  => Service['apache2'],
      context => "/files/etc/$php_etc_dir/apache2/php.ini/PUPPET_AUGEAS_OVERRIDES",
      changes => "set $name $value",
      require => Package[[$libapache_version], "$php_extension_name-cli"],
    }
  }
}