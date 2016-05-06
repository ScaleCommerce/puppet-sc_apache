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

  $php_lib_path      = $sc_apache::php::php_lib_path
  $php_version       = $sc_apache::php::php_version
  $php_etc_dir       = $sc_apache::php::php_etc_dir
  $libapache_version = $sc_apache::php::libapache_version

  # install zendguard
  file {"$php_lib_path/ZendGuardLoader.so":
    source  => "puppet:///modules/vm_config/php-$php_version/ZendGuardLoader.so",
    require => Package[$libapache_version],
    ensure => $zendguard_file_ensure,
  }->
  file {"/etc/$php_etc_dir/mods-available/zendguard.ini":
    content => "zend_extension=$php_lib_path/ZendGuardLoader.so",
    ensure => $zendguard_file_ensure,
  }->
  file {"/etc/$php_etc_dir/apache2/conf.d/02-zendguard.ini":
    ensure => $zendguard_link_ensure,
    target => "/etc/$php_etc_dir/mods-available/zendguard.ini",
    notify => Service['apache2'],
  }->
  file {"/etc/$php_etc_dir/cli/conf.d/02-zendguard.ini":
    ensure => $zendguard_link_ensure,
    target => "/etc/$php_etc_dir/mods-available/zendguard.ini",
  }
  # also replace opcache.so in php 5.5 and 5.6
  if $php_version == '5.5' or $php_version == '5.6' {
    file {"$php_lib_path/opcache.so":
      source  => "puppet:///modules/vm_config/php-$php_version/opcache.so",
      require => Package[$libapache_version],
      notify  => Service['apache2'],
      owner   => root,
      group   => root,
      ensure  => $zendguard_file_ensure,
    }
  }
}