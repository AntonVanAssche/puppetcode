# @summary Set up Transmission BitTorrent client.
#
# Installs the Transmission BitTorrent client and sets
# up a basic configuration.
#
# @param image
#   Image to pull.
# @param ports
#   Ports to expose.
# @param registry
#   Registry to pull the image from.
# @param volumes
#   Volume mappings.
#
# @example Basic usage.
#   include profile::transmission
#
class profile::transmission (
  String[1]            $image,
  Hash[String, Tuple]  $ports,
  String[1]            $registry,
  Hash[String, String] $volumes,
) {
  include profile::podman
  include profile::apache::reverse_proxy_transmission

  $user = 'transmission'
  $group = 'transmission'

  group { $group:
    ensure => present,
    system => true,
  }

  user { $user:
    ensure => present,
    system => true,
  }

  $volumes.each |$k, $v| {
    file { $v:
      ensure => directory,
      owner  => $user,
      group  => $group,
      mode   => '0755',
    }
  }

  systemd::unit_file { 'transmission.service':
    ensure  => present,
    owner   => $user,
    group   => $group,
    mode    => '0644',
    active  => true,
    enable  => true,
    content => template('profile/transmission/service.erb'),
  }

  $ports.each |$k, $v| {
    $v.each |$v| {
      firewalld_port { "${k}_${v}":
        ensure   => present,
        zone     => 'public',
        port     => $v,
        protocol => $k,
      }
    }
  }
}
