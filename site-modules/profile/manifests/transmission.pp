# @summary Set up Transmission BitTorrent client.
#
# Installs the Transmission BitTorrent client and sets
# up a basic configuration.
#
# @param gid
#   GID for the Transmission group.
# @param image
#   Image to pull.
# @param ports
#   Ports to expose.
# @param registry
#   Registry to pull the image from.
# @param uid
#   UID for the Transmission user.
# @param volumes
#   Volume mappings.
#
# @example Basic usage.
#   include profile::transmission
#
class profile::transmission (
  Integer              $gid,
  String[1]            $image,
  Hash[String, Tuple]  $ports,
  String[1]            $registry,
  Integer              $uid,
  Hash[String, String] $volumes,
) {
  include profile::podman

  $_user = 'transmission'
  $_group = 'transmission'

  user { $_user:
    ensure => present,
    uid    => $uid,
    gid    => $gid,
    system => true,
  }

  group { $_group:
    ensure => present,
    gid    => $gid,
    system => true,
  }

  $volumes.each |$k, $v| {
    file { $v:
      ensure => directory,
      owner  => $_user,
      group  => $_group,
      mode   => '0755',
    }
  }

  systemd::unit_file { 'transmission.service':
    ensure  => present,
    owner   => $_user,
    group   => $_group,
    mode    => '0644',
    active  => true,
    enable  => true,
    content => epp('profile/transmission/service.epp'),
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
