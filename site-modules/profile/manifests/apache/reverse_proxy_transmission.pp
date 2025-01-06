# @summary Configure Apache reverse proxy for Transmission.
#
# @param proxy_dest
#   The destination to proxy to.
#
# @example Basic usage.
#   include profile::apache::reverse_proxy_transmission
#
class profile::apache::reverse_proxy_transmission (
  String[1] $proxy_dest = 'localhost',
) {
  $_servername = $facts['networking']['domain']

  apache::vhost { "transmission.${facts['networking']['domain']}_non-ssl":
    servername      => "transmission.${facts['networking']['domain']}",
    port            => 80,
    docroot         => '/var/www/html/',
    redirect_status => 'permanent',
    redirect_dest   => "https://transmission.${facts['networking']['domain']}/",
  }

  apache::vhost { "transmission.${facts['networking']['domain']}_ssl":
    ensure              => present,
    servername          => "transmission.${facts['networking']['domain']}",
    docroot             => '/var/www/html',
    proxy_preserve_host => true,
    proxy_requests      => false,
    port                => 443,
    proxy_dest          => "http://${proxy_dest}:${profile::transmission::ports['tcp'][0]}",
    ssl                 => true,
  }
}
