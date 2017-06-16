# == Class: sc_apache::php
#
# Installation of PHP, PHP Extensions, PHP ini settings
#
# === Variables
#
# [*major_version*]
#  by now this may contain: 5.4, 5.6, 7.0, 7.1
#
# [*modules*]
#  installs php modules
#
# [*ini_settings*]
#  php.ini settings for 'apache2' and 'cli'
#
# === Authors
#
# Andreas Ziethen <az@scale.sc>, Thomas Lohner <tl@scale.sc>
#
# === Copyright
#
# Copyright 2016 ScaleCommerce GmbH.
#
class sc_apache::php (
  $major_version = '5.6',
  $modules = undef,
  $ini_settings = undef,
){

  case $major_version {
    '5.4': {
      class{'sc_apache::php54':
      }
    }
    '5.6', '7.0', '7.1': {
      class{'sc_apache::php_default':
      }
    }
    default: { fail('php_version has to be one of 5.4, 5.6, 7.0, 7.1') }
  }

}
