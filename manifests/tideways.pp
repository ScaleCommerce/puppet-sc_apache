class sc_apache::tideways (
  $ensure = 'installed',
){
  if($ensure == 'installed') {
    $apt_ensure = 'present'
  } else {
    $apt_ensure = 'absent'
  }

  $libapache_version = $sc_apache::php::libapache_version

  apt::key {'tideways':
    ensure => $apt_ensure,
    id     => '6A75A7C5E23F3B3B6AAEEB1411CD8CFCEEB5E8F4',
    source => 'https://s3-eu-west-1.amazonaws.com/qafoo-profiler/packages/EEB5E8F4.gpg',
  }
  apt::source {'tideways':
    ensure   => $apt_ensure,
    location => 'http://s3-eu-west-1.amazonaws.com/qafoo-profiler/packages',
    release  => 'debian',
    repos    => 'main',
  }
  package {['tideways-daemon', 'tideways-php', 'tideways-cli']:
    ensure  => $ensure,
    require => Package[$libapache_version],
    notify  => Service['apache2'],
  }
}