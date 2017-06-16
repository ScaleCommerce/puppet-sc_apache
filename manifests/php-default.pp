# == Class: sc_apache::php-default
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
class sc_apache::php-default (
  $major_version  = $sc_apache::php::php_major_version,
  $modules        = $sc_apache::php::modules,
  $ini_settings   = $sc_apache::php::ini_settings,
){

  $php_lib_path = $major_version ? {
    '5.6' => '/usr/lib/php/20131226',
    '7.0' => '/usr/lib/php/20151012',
    '7.1' => '/usr/lib/php/20160303'
  }

  # remove other ppa
  apt::ppa {'ppa:syseleven-platform/php54':
    ensure => absent,
  }
  # add defasult ppa
  apt::key {'ppa:ondrej/php':
    ensure => present,
    id     => '14AA40EC0831756756D7F66C4F4EA0AAE5267A6C',
  }
  apt::ppa {'ppa:ondrej/php':
    ensure => present,
  }

  package {"php${major_version}":
    ensure => installed,
    require => Class['Apt::Update'],
  }

  # set cli-php version
  file {'/etc/alternatives/php':
    ensure  => link,
    target  => "/usr/bin/php${major_version}",
    require => Package["php${major_version}"],
  }

  # set params for class apache::mod::php
  class {'apache::mod::php':
    php_version => $major_version,
    require     => Package["php${major_version}"]
  }

  # we need a symlink, because original augeas php.ini-lenses do not match on /etc/php/5.6/apache/php.ini
  # see: http://augeas.net/stock_lenses.html
  file { 'augeas_symlink':
    ensure => link,
    path    => "/etc/php-sc/",
    target  => "/etc/php/$major_version",
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
    case $name {
      # some extension package are prefixed "php-" indtesd of "php5.6-"
      'imagick, redis, memcached': {
        $extension_name = 'php-$name'
      }
      default: {
        $extension_name = "php${major_version}-$name"
    }
    package { $extension_name:
      ensure => installed,
      require => [Class['Apache::Mod::Php'],Class['Apt::Update']],
      notify  => Service['apache2'],
    }
  }
}
