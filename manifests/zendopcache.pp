class sc_apache::zendopcache (
  $ensure = 'installed',
){

  $php_lib_path      = $sc_apache::php::php_lib_path
  $php_version       = $sc_apache::php::php_version
  $php_etc_dir       = $sc_apache::php::php_etc_dir
  $libapache_version = $sc_apache::php::libapache_version

  # install zendopcache in php 5.4
  if ($php_version == '5.4') {

    if($ensure == 'installed') {
      $opcache_ini_ensure = 'link'
    } else {
      $opcache_ini_ensure = 'absent'
    }

    package {'php-pear':
      ensure => $ensure,
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
}