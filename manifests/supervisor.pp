# == Class: sc_apache::supervisor
#
# Declares the `apache2` process via supervisord::program. That define
# self-dispatches to a zpinit::service when sc::service_manager is 'zpinit'
# (see the supervisord module), so this works on both backends and the
# Supervisord::Program[apache2] handle keeps resolving for references. The httpd
# service provider is owned by site.pp (the global $sc_service_manager
# collector), so this class no longer overrides it.
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

  # Preserve the original ordering (php configured before httpd starts) without
  # overriding the service provider -- site.pp owns the provider, and a second
  # collector override of the same resource would conflict.
  Class['sc_apache::php'] -> Service['httpd']
}
