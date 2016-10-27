# == Class: sc_apache::vhosts
#
# Settings for Apache vhosts
#
# === Variables
#
# [*apache::vhosts*]
#  array of vhost settings
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
class sc_apache::vhosts (
  $vhosts = {},
  $vhost_defaults = {},
){

  file {'/var/www/html':
    ensure => absent,
    force  => true,
    require => Class['Apache']
  }

  file { '/var/www/localhost/opcache/':
    ensure => directory,
    require => File['/var/www/localhost'],
  }

  file { '/var/www/localhost/opcache/opcachestats.php':
    owner   => root,
    group   => root,
    mode    => '0644',
    source  => 'puppet:///modules/sc_apache/zabbix/opcache/opcachestats.php',
    require => File['/var/www/localhost/opcache'],
  }

  file { '/var/www/localhost/opcache/index.php':
    owner   => root,
    group   => root,
    mode    => '0644',
    source  => 'puppet:///modules/sc_apache/zabbix/opcache/index.php',
    require => File['/var/www/localhost/opcache'],
  }

  file { '/var/www/localhost/opcache/.htaccess':
    owner   => root,
    group   => root,
    mode    => '0644',
    source  => 'puppet:///modules/sc_apache/zabbix/opcache/.htaccess',
    require => File['/var/www/localhost/opcache'],
  }

  # iterate over vhosts and create docroots
  each($vhosts) |$name, $vhost| {
    exec { "${name}-docroot":
      command => "/bin/mkdir -p ${vhost['docroot']}",
      creates => "${vhost['docroot']}",
      before => Apache::Vhost["$name"],
    }
  }

  create_resources('apache::vhost',$vhosts, $vhost_defaults)
}
