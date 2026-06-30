# == Class: sc_apache::tideways
#
# Installation of Tideways Profiler Extension
#
# === Variables
#
# [*sc_apache::tideways::daemon_version*]
#  values: installed, absent, version
#
# [*sc_apache::tideways::php_extension_version*]
#  values: installed, absent, version
#
# [*sc_apache::tideways::cli_version*]
#  values: installed, absent, version
#
# [*sc_apache::tideways::proxy*]
#  values: https://tideways.scale.sc - Hostname of tideways proxy
#
# [*sc_apache::tideways::manage_repo*]
#  values: true, fals - Set this to false if you want to override the apt repo in hiera
#
# === Examples
#
# ---
# classes:
#   - sc_apache::tideways
#
# sc_apache::tideways:cli_version: absent
#
#
# === Authors
#
# Andreas Ziethen <az@scale.sc>
# Thomas Lohner <tl@scale.sc>
#
# === Copyright
#
# Copyright 2018 ScaleCommerce GmbH.
#

class sc_apache::tideways (
  $daemon_version = 'installed',
  $php_extension_version = 'installed',
  $cli_version = 'installed',
  $proxy = 'https://tideways.scale.sc',
  $environment = 'production',
  $manage_repo = true,
  $use_supervisor = true,
){
  include apache::mod::php

  if ($manage_repo) {
    # add default repo
    apt::key {'tideways':
      id     => 'AF578C61148B3485B585E4018CFC7A80A5672AB5',
    }
    apt::source {'tideways':
      location => 'https://packages.tideways.com/apt-packages-main',
      release  => 'any-version',
      repos    => 'main',
    }
  }

  package {'tideways-daemon':
    ensure  => $daemon_version,
    require => [Class['Apache::Mod::Php'], Apt::Source['tideways']],
    notify  => $use_supervisor ? { true => Service['tideways-daemon'], default => undef },
  }
  package {'tideways-php':
    ensure  => $php_extension_version,
    require => [Class['Apache::Mod::Php'], Apt::Source['tideways']],
    notify  => Service['httpd'],
  }
  package {'tideways-cli':
    ensure  => $cli_version,
    require => [Class['Apache::Mod::Php'], Apt::Source['tideways']],
  }

  if $use_supervisor {
    # Define tideways-daemon to the node's supervisor. supervisord::program
    # self-dispatches: a supervisord program conf on supervisor nodes, a
    # zpinit::service TOML on zpinit nodes.
    supervisord::program { 'tideways-daemon':
      command     => "/usr/bin/tideways-daemon --log=/var/log/tideways/daemon.log --server=$proxy --env=$environment",
      autostart   => true,
      autorestart => true,
      user        => tideways,
      require     => Package['tideways-daemon'],
      before      => Service['tideways-daemon'],
    }

    # remove legacy init/systemd/supervisor files; the daemon runs under the
    # node's supervisor instead.
    file { ['/etc/init.d/tideways-daemon', '/etc/supervisor.d/tideways-daemon.conf', '/lib/systemd/system/tideways-daemon.service']:
      ensure  => absent,
      before  => Supervisord::Program['tideways-daemon'],
      require => Package['tideways-daemon'],
    }

    # tideways-daemon runs under whichever supervisor manages this node. site.pp
    # flips the Service provider (supervisor or zpinit), so the tideways-daemon
    # package upgrade notifying this service restarts the daemon via the right
    # control client (supervisorctl or zpctl) -- no backend-specific exec needed.
    service { 'tideways-daemon':
      ensure  => running,
      require => Supervisord::Program['tideways-daemon'],
    }
  }

}
