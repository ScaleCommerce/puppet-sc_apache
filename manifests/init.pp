# == Class: sc-apache
#
# Full description of class dummy here.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if
#   it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should be avoided in favor of class parameters as
#   of Puppet 2.6.)
#
# === Examples
#
#  class { 'dummy':
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#  }
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
  class { '::sc_apache::install':
    vhosts      => hiera_hash('apache::vhosts', {}),
    php_version => hiera('php::version'),
    install_opcache => hiera('vm::install_opcache', false),
  }

  class { '::sc_apache::php': }->
  class { '::sc_apache::tideways': }->
  class { '::sc_apache::zendopcache': }->
  class { '::sc_apache::zendguard': }->
  class { '::sc_apache::ioncube': }
}
