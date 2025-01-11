# @summary: Profile for Wittimr
#
# @example Basic usage
#   include profile::wittimr
#
class profile::wittimr {
  include profile::podman

  $_install_dir = '/opt/wittimr'

  vcsrepo { $_install_dir:
    ensure   => present,
    provider => 'git',
    source   => 'https://github.com/AntonVanAssche/wittimr.git',
    revision => 'websocket',
    notify   => Exec['build-wittimr'],
  }

  exec { 'build-wittimr':
    command => "/usr/bin/podman build -t localhost/wittimr:latest ${_install_dir}",
    unless  => '/usr/bin/podman images | grep -q wittimr',
    creates => '/var/lib/containers/storage/overlay/wittimr',
    require => Vcsrepo[$_install_dir],
  }

  systemd::unit_file { 'wittimr.service':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    active  => true,
    enable  => true,
    content => epp('profile/wittimr/service.epp'),
    require => Exec['build-wittimr'],
  }
}
