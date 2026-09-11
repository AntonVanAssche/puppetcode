# @summary Installs and configures Pi-hole.
#
# @example Basic usage.
#   class { 'profile::pihole':
#     password => 'mysecret',
#   }
#
# @param password
#   Password for the Pi-hole web interface.
#
class profile::pihole (
  String[1] $password,
) {
  include profile::podman

  $user = 'pihole'
  $group = 'pihole'

  group { $group:
    ensure => present,
    system => true,
  }

  user { $user:
    ensure  => present,
    system  => true,
    require => Group[$group],
  }

  file_line { 'disable_dns_stub':
    path   => '/etc/systemd/resolved.conf',
    line   => 'DNSStubListener=no',
    match  => '^#?DNSStubListener=yes',
    notify => Service['systemd-resolved'],
    before => Systemd::Unit_file['pihole.service'],
  }

  file { '/etc/resolv.conf':
    ensure => link,
    target => '/run/systemd/resolve/resolv.conf',
    notify => Service['systemd-resolved'],
  }

  file {
    default:
      ensure => directory,
      owner  => $user,
      group  => $group,
      mode   => '0755',
    ;
    '/var/lib/podman/volumes/configs/pihole':
    ;
    '/var/lib/podman/volumes/configs/dnsmasq.d':
    ;
  }

  service { 'systemd-resolved':
    ensure  => running,
    enable  => true,
    restart => true,
    require => File['/etc/resolv.conf'],
  }

  systemd::unit_file { 'pihole.service':
    ensure  => present,
    active  => true,
    enable  => true,
    mode    => '0600', # Unit includes the web password.
    content => template('profile/pihole/service.erb'),
  }

  firewalld_service { 'dns':
    ensure => present,
    zone   => 'public',
  }
}
