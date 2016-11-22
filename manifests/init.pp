# == Class: sc_apache
#
# ScaleCommerce Wrapper Module for puppetlabs-apache.
# Manages Supervisord, vhosts, OPCache, ZendGuard Loader, IonCube.
#
# === Variables
#
# [*vhosts*]
#  array with apache vhost config, needed to automaticaly build the docroots
#
# [*vhost_defaults*]
#  array with apache vhost default params
#
# [*supervisor_init_script*]
#  full path to supervisor init wrapper script
#
# [*supervisor_conf_script*
#  full path to supervisor conf script
#
# [*supervisor_exec_path*]
#  path to supervisor executable
#
# [*modules*]
#  array with apache modules to install
#
# === Authors
#
# Andreas Ziethen <az@scale.sc>, Thomas Lohner <tl@scale.sc>
#
# === Copyright
#
# Copyright 2016 ScaleCommerce GmbH.
#
class sc_apache (
  $vhosts = {},
  $vhost_defaults = {},
  $supervisor_init_script = '/etc/supervisor.init/supervisor-init-wrapper',
  $supervisor_conf_script = '/etc/supervisor.d/apache2.conf',
  $supervisor_exec_path   = '/usr/local/bin',
  $modules                = undef,
){

  Class['Apt::Update'] -> Class['Apache']

  include apache
  include apt

  if $modules {
    each($modules) |$name| {
      apache::mod { "$name":
        package_ensure => present,
        notify  => Service['apache2'],
      }
    }
  }


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
    notify  => Exec['supervisorctl_apache_update'],
  }

  exec {'supervisorctl_apache_update':
    command     => "${supervisor_exec_path}/supervisorctl update",
    refreshonly => true,
  }

  class { 'sc_apache::vhosts':
    vhosts         => $vhosts,
    vhost_defaults => $vhost_defaults,
  }

}
