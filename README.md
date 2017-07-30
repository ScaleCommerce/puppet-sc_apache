[![build status](https://gitlab.scale.sc/sc-puppet/puppet-sc_apache/badges/master/build.svg)](https://gitlab.scale.sc/sc-puppet/puppet-sc_apache/commits/master)

# sc_apache

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with sc_apache](#setup)
    * [What sc_apache affects](#what-sc_apache-affects)
    * [Beginning with sc_apache](#beginning-with-sc_apache)
4. [Usage - Configuration options and additional functionality](#usage)

## Overview

ScaleCommerce Wrapper Module for puppetlabs-apache. Manages Supervisord, vhosts, OPCache, ZendGuard Loader, IonCube.

## Module Description

This module uses hiera to configure Apache ressources.

## Setup

### What sc_apache affects

* apache
* apache modules
* supervisord
* ZendGuard Loader
* PHP OPCache
* IonCube Loader
* Local vhosts for monitoring


### Beginning with sc_apache

You will need a working hiera-Setup (https://docs.puppetlabs.com/hiera/3.1/complete_example.html).

Check out our solultion for Puppet-Hiera-Roles (https://github.com/ScaleCommerce/puppet-hiera-roles).

## Usage: Apache vhosts

Put this into your node.yaml or role.yaml. See [Documentation of puppetlabs-apache](https://github.com/puppetlabs/puppetlabs-apache) for details on vhost syntax.
```
---
classes:
  - sc_apache

sc_apache::vhosts:
  # Default vhost matches all servernames which are not configured in any vhost
  default:
    docroot: /var/www/catchall/web
    default_vhost: true
  # other vhosts
  www.example.com:
    server_aliases: ['example.com']
    docroot: /var/www/www.example.com/web
    override: ['All']
  # add php.ini settings per vhost
  www.domain.de:
    server_aliases: ['deomain.de']
    docroot: /var/www/www.domain.de/web
    override: ['All']
    php_values:
      tideways.api_key: 'xxx'
      tideways.framework: 'shopware'
```

## Usage: Apache Modules
```
sc_apache::modules:
  - rewrite
  - auth_basic
  - deflate
  - expires
  - headers
  - remoteip
  - status
  - authz_user
  - authz_groupfile
  - alias
  - authn_core
  - authn_file
  - reqtimeout
  - negotiation
  - autoindex
  - access_compat
  - env
```

## Usage: PHP

```
classes:
  - sc_apache
  - sc_apache::php
  - sc_apache::tideways
  - sc_apache::zendopcache # this class installs zendopcache in php 5.4
  - sc_apache::ioncube
  - sc_apache::zendguard

sc_apache::php::major_version: '5.6'
sc_apache::php::ini_settings:
  apache2:
    session.gc_maxlifetime: 604800
    error_reporting: "E_ALL & ~E_DEPRECATED & ~E_STRICT & ~E_NOTICE"
    max_execution_time: 60
  cli:
    max_execution_time: 1200

sc_apache::php::modules:
  - mysql
  - gd
  - mcrypt
  - curl
  - intl
  - xsl
```
