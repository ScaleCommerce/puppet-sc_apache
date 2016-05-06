class sc_apache::php (
  $php_version = '5.6',
  $install_opcache = false,
){
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

  case $php_version {
    '5.4': {
      apt::ppa {['ppa:ondrej/php5-5.6', 'ppa:ondrej/php5']:
        ensure => absent,
      }
      apt::key {"ppa:$version_repo":
        ensure => present,
        id     => $repo_key_sys11,
      }->
      apt::ppa {"ppa:$version_repo":
        ensure => present,
      }
    }
    '5.5': {
      apt::ppa {['ppa:ondrej/php5-5.6', 'ppa:syseleven-platform/php54']:
        ensure => absent,
      }->
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
      }->
      apt::ppa {"ppa:$version_repo":
        ensure => present,
      }
    }
    '7.0': {
      apt::key {"ppa:$version_repo":
        ensure => present,
        id     => $repo_key_ondrej,
      }->
      apt::ppa {"ppa:$version_repo":
        ensure => present,
      }
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
  }->
  package { [hiera_array('php::modules', [])]:
    ensure  => installed,
    require => Package[$libapache_version],
  }

  # php ini settings
  augeas { 'php_ini':
    notify  => Service['apache2'],
    context => "/files/etc/$php_etc_dir/apache2/php.ini/PUPPET_AUGEAS_OVERRIDES",
    changes => hiera_array('php::ini_settings', {}),
    require => Package[[$libapache_version], "$php_extension_name-cli"],
  }
}