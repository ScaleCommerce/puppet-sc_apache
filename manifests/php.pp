# == Class: sc_apache::php_default
#
# Installation of PHP, PHP Extensions, PHP ini settings
#
# === Variables
#
# [*major_version*]
#  by now this may contain: 5.6, 7.0, 7.1, 7.2, 7.3, 7.4, 8.0, 8.1, 8.2, 8.3
#
# [*modules*]
#  installs php modules
#
# [*ini_settings*]
#  php.ini settings for 'apache2' and 'cli'
#
# === Authors
#
# Andreas Ziethen <az@scale.sc>
# Thomas Lohner <tl@scale.sc>
#
# === Copyright
#
# Copyright 2016 ScaleCommerce GmbH.
#
class sc_apache::php (
  Enum["5.6", "7.0", "7.1", "7.2", "7.3", "7.4", "8.0", "8.1", "8.2", "8.3"] $major_version  = "7.2",
  $modules,
  $ini_settings,
  $manage_repo = true,
){
  # Check some if they are boolean
  validate_bool($manage_repo)

  $php_lib_path = $major_version ? {
    '5.6' => '/usr/lib/php/20131226',
    '7.0' => '/usr/lib/php/20151012',
    '7.1' => '/usr/lib/php/20160303',
    '7.2' => '/usr/lib/php/20170718',
    '7.3' => '/usr/lib/php/20180731',
    '7.4' => '/usr/lib/php/20190902',
    '8.0' => '/usr/lib/php/20200930',
    '8.1' => '/usr/lib/php/20210902',
    '8.2' => '/usr/lib/php/20220829',
    '8.3' => '/usr/lib/php/20220830'
  }

  if ($manage_repo) {
    # add default ppa
    apt::key {'ppa:ondrej/php':
      ensure => present,
      id     => '14AA40EC0831756756D7F66C4F4EA0AAE5267A6C',
    }
    apt::ppa {'ppa:ondrej/php':
      ensure => present,
    }
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
  file { 'php-ini-symlink':
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
      ini_setting { "$context-$name":
        ensure  => present,
        path    => "/etc/php-sc/$context/php.ini",
        section => "PUPPET_OVERRIDES",
        setting => $name,
        value   => $value,
        require => File['php-ini-symlink'],
        notify  => Service['apache2']
      }
    }
  }

  # right now the ppa installer for php >= 8.0 uses an undefined symbol in the apache load config
  # Fixed but not built in https://salsa.debian.org/php-team/php/-/commit/ccf9a053924ef04efd828689f50855f954d7c52c
  # Background: https://bugs.php.net/bug.php?id=78681
  if versioncmp($major_version, '7.4') > 0 {
    file_line { 'php8_fix_loadmodule':
      path               => "/etc/apache2/mods-available/php${major_version}.load",
      line               => "LoadModule php_module /usr/lib/apache2/modules/libphp${major_version}.so",
      append_on_no_match => false,
      match              => '^LoadModule php8_module',
      require            => Package["php${major_version}"],
      notify             => Service[httpd]
    }
  }


  # create files for debugging / testing
  file {'/var/www/localhost/info.php':
    source => "puppet:///modules/sc_apache/info.php",
  }
  file {'/var/www/localhost/extensions.php':
    source => "puppet:///modules/sc_apache/extensions.php",
  }
  file {'/var/www/localhost/version.php':
    source => "puppet:///modules/sc_apache/version.php",
  }
 file {'/var/www/localhost/flush_opcache.php':
    source => "puppet:///modules/sc_apache/flush_opcache.php",
  }

  # install php modules
  each($modules) |$name| {
    case $name {
      # some extension package are prefixed "php-" instead of "php5.6-"
      'geoip': {
        $extension_name = "php-$name"
      }
      default: {
        $extension_name = "php${major_version}-$name"
      }
    }
    package { $extension_name:
      ensure => installed,
      require => [Class['Apache::Mod::Php'],Class['Apt::Update']],
      notify  => Service['httpd'],
    }
  }
}
