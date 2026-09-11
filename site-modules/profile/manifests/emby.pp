# @summary Set up Emby media server.
#
# Install and configure the Emby media server.
#
# @example Basic usage.
#   include profile::emby
#
# @param image
#   Container image to run.
# @param port
#   The port to expose Emby on.
#
class profile::emby (
  String[1]    $image = 'docker.io/emby/embyserver_arm64v8',
  Stdlib::Port $port  = 8096,
) {
  include profile::podman
  include profile::apache::reverse_proxy_emby

  $user  = 'emby'
  $group = 'emby'

  group { $group:
    ensure => present,
    system => true,
  }

  user { $user:
    ensure => present,
    system => true,
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
    '/var/lib/podman/volumes/configs/emby/config':
    ;
    '/mnt/emby/media/films':
    ;
    '/mnt/emby/media/series':
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

  firewalld_port { "${port}/tcp":
    ensure   => present,
    zone     => 'public',
    port     => $port,
    protocol => 'tcp',
  }
}
