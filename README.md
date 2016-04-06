# sc_apache

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with sc_apache](#setup)
    * [What sc_apache affects](#what-sc_apache-affects)
    * [Beginning with sc_apache](#beginning-with-sc_apache)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Overview

ScaleCommerce Wrapper Module for puppetlabs-apache. Manages Supervisord, vhosts, OPCache, ZendGuard Loader, IonCube.

## Module Description

This module uses hiera to configure Apache ressources.

## Setup

### What sc_apache affects

* apache
* supervisord
* ZendGuard Loader
* PHP OPCache
* IonCube Loader
* Local vhosts for monitoring


### Beginning with sc_apache

You will need a working hiera-Setup (https://docs.puppetlabs.com/hiera/3.1/complete_example.html).

Check out our solultion for Puppet-Hiera-Roles (https://github.com/ScaleCommerce/puppet-hiera-roles).

## Usage

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
  # Normal vhost
  www.example.com:
    server_aliases: ['example.com']
    docroot: /var/www/www.example.com/web
    override: ['All']
```
