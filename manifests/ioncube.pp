class sc_apache::ioncube(
  $ensure = 'link',
) {

  $php_lib_path      = $sc_apache::php::php_lib_path
  $php_version       = $sc_apache::php::php_version
  $php_etc_dir       = $sc_apache::php::php_etc_dir
  $libapache_version = $sc_apache::php::libapache_version

  # install ioncube
  if($ensure == 'link') {
    $ioncube_loader_ensure = 'present'
  } else {
    $ioncube_loader_ensure = 'absent'
  }
  file {"$php_lib_path/ioncube_loader_lin_$php_version.so":
    source  => "puppet:///modules/vm_config/php-$php_version/ioncube_loader_lin_$php_version.so",
    require => Package[$libapache_version],
    ensure => $ioncube_loader_ensure,
  }->
  file {"/etc/$php_etc_dir/mods-available/ioncube.ini":
    content => "zend_extension=$php_lib_path/ioncube_loader_lin_$php_version.so",
    ensure => $ioncube_loader_ensure,
  }->
  file {"/etc/$php_etc_dir/apache2/conf.d/01-ioncube.ini":
    ensure => $ensure,
    target => "/etc/$php_etc_dir/mods-available/ioncube.ini",
    notify => Service['apache2'],
  }->
  file {"/etc/$php_etc_dir/cli/conf.d/01-ioncube.ini":
    ensure => $ensure,
    target => "/etc/$php_etc_dir/mods-available/ioncube.ini",
  }
}