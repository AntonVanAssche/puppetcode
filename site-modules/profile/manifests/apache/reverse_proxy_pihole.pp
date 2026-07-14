# @summary Configure Apache reverse proxy for Pihole.
#
# @example Basic usage.
#   class { 'profile::apache::reverse_proxy_pihole':
#     servername => 'pihole.local',
#   }
#
# @param servername
#   The servername to use for the virtual host.
# @param proxy_dest
#   The destination to proxy to.
#
class profile::apache::reverse_proxy_pihole (
  Stdlib::Fqdn $servername,
  String[1] $proxy_dest = 'localhost',
) {
  apache::vhost { "${servername}_non-ssl":
    servername      => $servername,
    port            => 80,
    docroot         => '/var/www/html/',
    redirect_status => 'permanent',
    redirect_dest   => "https://${servername}/",
  }

  apache::vhost { "${servername}_ssl":
    ensure              => present,
    servername          => $servername,
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
