# @summary Configure Apache reverse proxy for Grafana.
#
# @param proxy_dest
#   The destination to proxy to.
#
# @example Basic usage.
#   include profile::apache::reverse_proxy_grafana
#
class profile::apache::reverse_proxy_grafana (
  String[1] $proxy_dest = 'localhost',
) {
  $_servername = $facts['networking']['domain']

  apache::vhost { "grafana.${facts['networking']['domain']}_non-ssl":
    servername      => "grafana.${facts['networking']['domain']}",
    port            => 80,
    docroot         => '/var/www/html/',
    redirect_status => 'permanent',
    redirect_dest   => "https://grafana.${facts['networking']['domain']}/",
  }

  apache::vhost { "grafana.${facts['networking']['domain']}_ssl":
    ensure              => present,
    servername          => "grafana.${facts['networking']['domain']}",
    docroot             => '/var/www/html',
    proxy_preserve_host => true,
    proxy_requests      => false,
    port                => 443,
    proxy_dest          => "http://${proxy_dest}:3000",
    ssl                 => true,
  }
}
