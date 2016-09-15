# == Class: sc_apache
#
# ScaleCommerce Wrapper Module for puppetlabs-apache.
# Manages Supervisord, vhosts, OPCache, ZendGuard Loader, IonCube.
#
# === Variables
#
# [*apache::vhosts*]
#  array with apache vhost config, needed to automaticaly build the docroots
#
# === Examples
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
# for more examples regarding php config etc. see subclasses
#
# === Authors
#
# Andreas Ziethen <az@scale.sc>
#
# === Copyright
#
# Copyright 2016 ScaleCommerce GmbH.
#
class sc_apache (
  $supervisor_init_script = '/etc/supervisor.init/supervisor-init-wrapper',
  $supervisor_conf_script = '/etc/supervisor.d/apache2.conf',
  $supervisor_exec_path   = '/usr/local/bin',
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
  ::apache::mod { 'env': }

  # supervisor
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
    notify => Exec['supervisorctl_apache_update'],
  }

  exec {'supervisorctl_apache_update':
    command => "${supervisor_exec_path}/supervisorctl update",
    refreshonly => true,
  }

  class { '::sc_apache::vhosts':
    vhosts      => hiera_hash('sc_apache::vhosts', {}),
  }
  $sc_php_version = hiera('php::version', '5')
  class { '::sc_apache::php':
    php_version => hiera('apache::mod::php::php_version', $sc_php_version),
  }
}
