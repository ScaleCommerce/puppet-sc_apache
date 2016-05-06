# == Class: sc_apache::vhosts
#
# Settings for Apache vhosts
#
# === Variables
#
# [*apache::vhosts*]
#  array of vhost settings
#
# === Examples
#
# hiera-Example:
# ---
# classes:
#   - sc_apache
#
#  sc_apache::vhosts:
#    default: # Default vhost matches all servernames which are not configured in any vhost
#      docroot: /var/www/catchall/web
#      default_vhost: true
#    www.example.com: # Normal vhost
#      server_aliases: ['example.com']
#      docroot: /var/www/www.example.com/web
#      override: ['All']
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
  $supervisor_init_script = '/etc/supervisor/supervisor-init-wrapper',
  $supervisor_conf_script = '/etc/supervisor/conf.d/apache2.conf',
){

  include apache
  include apt
  include apache::mod::php
  include apache::mod::rewrite
  include apache::mod::setenvif
  include apache::mod::auth_basic
  include apache::mod::deflate
  include apache::mod::expires
  include apache::mod::headers
  include apache::mod::remoteip
  include apache::mod::status
  include apache::mod::authz_user
  include apache::mod::alias
  include apache::mod::authn_core
  include apache::mod::authn_file
  include apache::mod::reqtimeout
  include apache::mod::negotiation
  include apache::mod::autoindex

  ::apache::mod { 'access_compat': }

  # supervisor
  if $::virtual == 'docker' {
    file { '/etc/init/apache2.conf':
      ensure => absent,
    }->
    file { '/etc/init.d/apache2':
      ensure => link,
      target => $supervisor_init_script,
    }

    file { $supervisor_conf_script:
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => template("${module_name}/apache.supervisor.conf.erb"),
      notify => Exec['supervisorctl_update'],
    }

    exec {'supervisorctl_update':
      command => '/usr/bin/supervisorctl update',
      refreshonly => true,
    }
  }

  $vhost_defaults = hiera_hash('apache::vhosts_defaults', {})

  file {'/var/www/html':
    ensure => absent,
    force  => true,
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