# @summary Set up Emby media server.
#
# Install and configure the Emby media server.
#
# @param image
#   Image to pull.
# @param port
#   Port to expose.
# @param protocol
#   TCP or UDP.
# @param registry
#   Registry to pull the image from.
# @param volumes
#   Volume mappings.
#
# @example Basic usage.
#   include profile::emby
#
class profile::emby (
  String[1]            $image,
  String[1]            $port,
  String[1]            $protocol,
  String[1]            $registry,
  Hash[String, String] $volumes,
) {
  include profile::podman
  include profile::apache::reverse_proxy_emby

  $user = 'emby'
  $group = 'emby'

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

  file {
    default:
      ensure => directory,
      owner  => $user,
      group  => $group,
      mode   => '0755',
      ;
    '/mnt/emby':
      ;
    '/mnt/emby/media':
      ;
  }

  systemd::unit_file { 'emby.service':
    ensure  => present,
    owner   => $user,
    group   => $group,
    mode    => '0644',
    active  => true,
    enable  => true,
    content => template('profile/emby/service.erb'),
  }

  firewalld_port { $port:
    ensure   => present,
    zone     => 'public',
    port     => $port,
    protocol => $protocol,
  }
}
