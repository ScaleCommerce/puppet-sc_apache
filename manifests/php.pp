# == Class: sc_apache::php
#
# Installation of PHP, PHP Extensions, PHP ini settings
#
# === Variables
#
# [*major_version*]
#  by now this may contain: 5.4, 5.6, 7.0, 7.1
#
# [*modules*]
#  installs php modules
#
# [*ini_settings*]
#  php.ini settings for 'apache2' and 'cli'
#
# === Authors
#
# Andreas Ziethen <az@scale.sc>, Thomas Lohner <tl@scale.sc>
#
# === Copyright
#
# Copyright 2016 ScaleCommerce GmbH.
#
class sc_apache::php (
  $major_version = '5.6',
  $modules = undef,
  $ini_settings = undef,
){

$php_lib_path = $major_version ? {
    '5.4' => '/usr/lib/php5/20100525',
    '5.6' => '/usr/lib/php/20131226',
    '7.0' => '/usr/lib/php/20151012',
    '7.1' => '/usr/lib/php/20160303'
  }

  case $major_version {
    '5.4': {
      # remove other ppa
      apt::ppa {'ppa:ondrej/php':
        ensure => absent,
      }
      # add specific ppa for major version
      apt::key {'ppa:syseleven-platform/php54':
        ensure => present,
        id     => 'C70320183C05E1E9F24532C87736223724911626',
      }
      apt::ppa {'ppa:syseleven-platform/php54':
        ensure => present,
      }
      # set params for class apache::mod::php
      $apache_mod_php_php_version = '5'
      # set variables
      $augeas_symlink_target = '/etc/php5'
    }
    '5.6', '7.0', '7.1': {
      # remove other ppa
      apt::ppa {'ppa:syseleven-platform/php54':
        ensure => absent,
      }
      # add specific ppa for major version
      apt::key {'ppa:ondrej/php':
        ensure => present,
        id     => '14AA40EC0831756756D7F66C4F4EA0AAE5267A6C',
      }
      apt::ppa {'ppa:ondrej/php':
        ensure => present,
      }
      # set params for class apache::mod::php
      $apache_mod_php_php_version = $major_version
      # set variables
      $augeas_symlink_target = "/etc/php/$apache_mod_php_php_version"

      # set cli-php version
      file {'/etc/alternatives/php':
        ensure  => link,
        target  => "/usr/bin/php$major_version",
        require => Package["php$major_version-cli"],
      }
    }
    default: { fail('php_version has to be one of 5.4, 5.6, 7.0, 7.1') }
  }

  package {"php${apache_mod_php_php_version}-cli":
    ensure => installed,
    require => Class['Apt::Update'],
  }

  class {'apache::mod::php':
    php_version => $apache_mod_php_php_version,
  }

  # we need a symlink, because original augeas php.ini-lenses do not match on /etc/php/5.6/apache/php.ini
  # see: http://augeas.net/stock_lenses.html
  file { 'augeas_symlink':
    ensure => link,
    path    => "/etc/php-sc/",
    target  => $augeas_symlink_target,
    owner   => 'root',
    group   => 'root',
    require => Class['Apache::Mod::Php'],
  }

  # apply php ini setting
  # info: apache will be restartet even if only cli settings are changed, needs better implementation
  each($ini_settings) |$context, $items| {
    each($items) |$name, $value| {
      augeas { "$context-$name":
        notify  => Service['apache2'],
        context => "/files/etc/php-sc/$context/php.ini/PUPPET_AUGEAS_OVERRIDES",
        changes => "set $name $value",
        require => File['augeas_symlink'],
      }
    }
  }

  # create files for debugging / testing
  file {'/var/www/localhost/info.php':
    source => "puppet:///modules/sc_apache/info.php",
    notify => Service['apache2'],
  }
  file {'/var/www/localhost/extensions.php':
    source => "puppet:///modules/sc_apache/extensions.php",
    notify => Service['apache2'],
  }

  # install php modules
  each($modules) |$name| {
    if $name == 'imagick' {
      $extension_name = 'php5-imagick'
    } else {
      $extension_name = "php${apache_mod_php_php_version}-$name"
    }
    package { $extension_name:
      ensure => installed,
      require => Class['Apache::Mod::Php'],
      notify  => Service['apache2'],
    }
  }
}
