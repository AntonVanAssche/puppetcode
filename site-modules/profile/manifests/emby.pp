# @summary Set up Emby media server.
#
# Install and configure the Emby media server.
#
# @param gid
#   GID of the Emby group.
# @param image
#   Image to pull.
# @param port
#   Port to expose.
# @param protocol
#   TCP or UDP.
# @param registry
#   Registry to pull the image from.
# @param uid
#   UID of the Emby user.
# @param volumes
#   Volume mappings.
#
# @example Basic usage.
#   include profile::emby
#
class profile::emby (
  Integer              $gid,
  String[1]            $image,
  String[1]            $port,
  String[1]            $protocol,
  String[1]            $registry,
  Integer              $uid,
  Hash[String, String] $volumes,
) {
  include profile::podman

  $_user = 'emby'
  $_group = 'emby'

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
      owner  => $user,
      group  => $group,
      mode   => '0755',
    }
  }

  file {
    default:
      ensure => directory,
      owner  => $_user,
      group  => $_group,
      mode   => '0755',
      ;
    '/mnt/emby':
      ;
    '/mnt/emby/media':
      ;
  }

  $volumes.each |$k, $v| {
    file { $v:
      ensure => directory,
      owner  => $user,
      group  => $group,
      mode   => '0755',
    }
  }

  systemd::unit_file { 'emby.service':
    ensure  => present,
    owner   => $_user,
    group   => $_group,
    mode    => '0644',
    active  => true,
    enable  => true,
    content => epp('profile/emby/service.epp'),
  }

  firewalld_port { $port:
    ensure   => present,
    zone     => 'public',
    port     => $port,
    protocol => $protocol,
  }
}
