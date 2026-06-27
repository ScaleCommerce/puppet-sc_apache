# == Class: sc_apache::supervisor
#
# Supervisord wiring for apache. Declares the `apache2` supervisord program and
# overrides the httpd service onto the `supervisor` provider. Gated by
# `sc_apache::use_supervisor` so nodes not using supervisord (e.g. zpinit) can
# opt out from data without editing this module.
#
class sc_apache::supervisor {

  supervisord::program { 'apache2':
    command     => '/bin/bash -c "mkdir -p /var/run/apache2 && pkill -F /var/run/apache2/apache2.pid || true; rm -f /var/run/apache2/apache2.pid; sleep 1; source /etc/apache2/envvars && exec /usr/sbin/apache2 -DFOREGROUND"',
    autostart   => true,
    autorestart => true,
    before      => Service['httpd'],
    require     => [Package['httpd'], Class['sc_apache::vhosts']],
  }

  # remove legacy files
  file { ['/etc/init/apache2.conf', '/etc/init.d/apache2', '/etc/supervisor.d/apache2.conf']:
    ensure  => absent,
    before  => [Service['httpd'], Supervisord::Program[apache2]],
    require => Package['httpd'],
  }

  Service <| title == "httpd" |> {
    provider => supervisor,
    require  => Class['sc_apache::php'],
  }
}
