# @summary Configure Apache reverse proxy for Pihole.
#
# @param proxy_dest
#   The destination to proxy to.
#
# @example Basic usage.
#   include profile::apache::reverse_proxy_pihole
#
class profile::apache::reverse_proxy_pihole (
  String[1] $proxy_dest = 'localhost',
) {
  $_servername = $facts['networking']['domain']

  apache::vhost { "pihole.${facts['networking']['domain']}_non-ssl":
    servername      => "pihole.${facts['networking']['domain']}",
    port            => 80,
    docroot         => '/var/www/html/',
    redirect_status => 'permanent',
    redirect_dest   => "https://pihole.${facts['networking']['domain']}/",
  }

  apache::vhost { "pihole.${facts['networking']['domain']}_ssl":
    ensure              => present,
    servername          => "pihole.${facts['networking']['domain']}",
    docroot             => '/var/www/html',
    proxy_preserve_host => true,
    proxy_requests      => false,
    port                => 443,
    proxy_dest          => "http://${proxy_dest}:80",
    ssl                 => true,
    rewrites            => [
      {
        rewrite_rule => ['^/$ /admin [R]'],
      },
    ],
  }
}
