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
# [*modules*]
#  array with apache modules to install
#  works only with modules which are covered by the orginal puppetlabs-apache module
#  see here: https://github.com/puppetlabs/puppetlabs-apache/tree/master/manifests/mod
#
# [*custom_modules*]
#  array with modules which are not covered by puppetlabs-apache module
#  will be installed as package
#
# How apache (httpd) is supervised is selected by the global hiera key
# `sc::service_manager` (`supervisor` (default) or `zpinit`), NOT by a
# per-module flag: `supervisor` includes sc_apache::supervisor (supervisord
# program + provider override), `zpinit` includes sc_apache::zpinit (writes the
# zpinit service TOML; the httpd service is flipped to provider => zpinit in
# site.pp).
#
# === hiera example
#
# sc_apache::modules:
#   - rewrite
#   - auth_basic
#   - deflate
#   - ...
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
  $modules                = undef,
  $custom_modules         = undef,
){

  Class['Apt::Update'] -> Class['Apache']

  include apache
  include apt

  if $custom_modules {
    if $modules {
      $tmp_modules = [$modules, $custom_modules]
      $allmodules = unique(flatten($tmp_modules))
    } else {
      $allmodules = $custom_modules
    }
  } else {
    if $modules {
      $allmodules = $modules
    }
  }


  if $allmodules {
    each($allmodules) |$name| {
      if defined( "apache::mod::${name}") {
        include "apache::mod::$name"
      } else {
        apache::mod { "$name":
          package_ensure => present,
          notify  => Service['httpd'],
        }
      }
    }
  } else {
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
    include apache::mod::env

    ::apache::mod { 'access_compat': }
    ::apache::mod { 'authz_groupfile': }
  }


  $service_manager = lookup('sc::service_manager', Enum['supervisor', 'zpinit'], 'first', 'supervisor')
  case $service_manager {
    'zpinit': { class { '::sc_apache::zpinit': } }
    default:  { class { '::sc_apache::supervisor': } }
  }

  class { 'sc_apache::vhosts':
    vhosts         => $vhosts,
    vhost_defaults => $vhost_defaults,
  }

}
