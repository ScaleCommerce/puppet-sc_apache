# == Class: sc_apache::zpinit
#
# zpinit wiring for apache: writes the `apache2` zpinit service TOML. It does
# NOT declare a service resource -- the apache module's `Service[httpd]` is
# flipped to `provider => zpinit` in site.pp (driven by `sc::service_manager`),
# and `before => Service['httpd']` makes the TOML land before that service is
# started. Counterpart of sc_apache::supervisor; selected when
# `sc::service_manager: zpinit`.
#
class sc_apache::zpinit {

  # Same launcher as the supervisord variant, but as an argv array: zpinit execs
  # argv directly with no shell, so the bash wrapper must be explicit.
  zpinit::service { 'apache2':
    command     => ['/bin/bash', '-c', 'mkdir -p /var/run/apache2 && pkill -F /var/run/apache2/apache2.pid || true; rm -f /var/run/apache2/apache2.pid; sleep 1; source /etc/apache2/envvars && exec /usr/sbin/apache2 -DFOREGROUND'],
    autorestart => true,
    before      => Service['httpd'],
    require     => [Package['httpd'], Class['sc_apache::vhosts']],
  }

  # remove legacy files
  file { ['/etc/init/apache2.conf', '/etc/init.d/apache2', '/etc/supervisor.d/apache2.conf']:
    ensure  => absent,
    require => Package['httpd'],
  }
}
