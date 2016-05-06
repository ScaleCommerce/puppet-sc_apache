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

){
  class { '::sc_apache::vhosts':
    vhosts      => hiera_hash('apache::vhosts', {}),
  }
  class { '::sc_apache::php': }
}
