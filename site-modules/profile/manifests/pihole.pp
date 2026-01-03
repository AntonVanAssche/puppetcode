# @summary Installs and configures Pi-hole
#
# @param image
#   Image to pull.
# @param password
#   Password for the Pi-hole web interface.
# @param registry
#   Registry to pull the image from.
# @param volumes
#   Volume mappings.
#
# @example Basic usage.
#   include profile::pihole
#
class profile::pihole (
  String[1]            $image,
  String[1]            $password,
  String[1]            $registry,
  Hash[String, String] $volumes,
) {
  include profile::podman

  $user = 'pihole'
  $group = 'pihole'

  group { $group:
    ensure => 'present',
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

  $volumes.each |$k, $v| {
    file { $v:
      ensure => directory,
      owner  => $user,
      group  => $user,
      mode   => '0755',
      before => Systemd::Unit_file['pihole.service'],
    }
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
