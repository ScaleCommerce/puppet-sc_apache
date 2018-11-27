class sc_apache::supervisor(
){

  include supervisord

  file { ['/etc/init/apache2.conf', '/etc/init.d/apache2', '/lib/systemd/system/apache2.service.d']:
    ensure  => absent,
    recurse => true,
    require => Package['httpd'],
  }

  supervisord::program { 'apache2':
    command     => '/bin/bash -c "mkdir -p /var/run/apache2 && source /etc/apache2/envvars && exec /usr/sbin/apache2 -DFOREGROUND"',
    autostart   => true,
    autorestart => true,
    require     => Package['httpd'],
    before      => Service['httpd'],
  }~>
  # reload nginx config only if startet for the first time
  # because of order conflict between supervisor and nginx modules
  exec {'nginx_reload':
    command     => "/usr/sbin/apache2ctl -k graceful",
    refreshonly => true,
    require     => Service['httpd'],
  }

  # override default service provider
  Service <| title == "httpd"|> {
    provider => supervisor,
    restart  => "/usr/sbin/apache2ctl -k graceful",
  }
}
