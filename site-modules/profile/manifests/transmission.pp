# @summary Set up Transmission BitTorrent client.
#
# @example Basic usage.
#   include profile::transmission
#
# @param image
#   Container image to run.
# @param ports
#   Ports to expose. Defaults to the Transmission web interface
#   and peer port.
#
class profile::transmission (
  String[1] $image = 'lscr.io/linuxserver/transmission',
  Hash      $ports = { 'tcp' => ['9091', '51413'], 'udp' => ['51413'], },
) {
  include profile::podman
  include profile::apache::reverse_proxy_transmission

  $user  = 'transmission'
  $group = 'transmission'

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
    '/var/lib/podman/volumes/configs/transmission/config':
    ;
    '/mnt/transmission/downloads':
    ;
    '/mnt/transmission/watch':
    ;
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

  $ports.each |$protocol, $port_list| {
    $port_list.each |$port| {
      firewalld_port { "${port}/${protocol}":
        ensure   => present,
        zone     => 'public',
        port     => $port,
        protocol => $protocol,
      }
    }
  }
}
