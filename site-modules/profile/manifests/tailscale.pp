# @summary Install and configure Tailscale
#
# @param authkey
#   Authentication key for Tailscale.
# @param accept_dns
#   Allow Tailscale to manage /etc/resolv.conf.
#   @see https://tailscale.com/kb/1235/resolv-conf
#
# example Basic usage.
#   include profile::tailscale
#
class profile::tailscale (
  String[1]  $authkey,
  Boolean    $accept_dns = true,
) {
  apt::source { 'tailscale':
    location => 'https://pkgs.tailscale.com/stable/raspbian',
    repos    => 'main',
    release  => $facts['os']['distro']['codename'],
    key      => {
      'name'   => 'tailscale.gpg',
      'source' => "https://pkgs.tailscale.com/stable/raspbian/${facts['os']['distro']['codename']}.noarmor.gpg",
    },
  }

  package { 'tailscale':
    ensure  => latest,
    require => Apt::Source['tailscale'],
  }

  service { 'tailscaled':
    ensure  => 'running',
    enable  => true,
    require => Package['tailscale'],
    notify  => Exec['run_tailscale_up'],
  }

  exec { 'run_tailscale_up':
    command     => "/usr/bin/tailscale up --authkey ${authkey} --accept-dns=${accept_dns}",
    provider    => 'shell',
    refreshonly => true,
    unless      => 'test $(/usr/bin/tailscale status | wc -l) -gt 1',
    require     => Service['tailscaled'],
  }
}
