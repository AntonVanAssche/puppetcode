# @summary Configure Apache reverse proxy for wittimr.
#
# @example Basic usage.
#   class { 'profile::apache::reverse_proxy_wittimr':
#     servername => 'wittimr.local',
#   }
#
# @param servername
#   The servername to use for the virtual host.
# @param proxy_dest
#   The destination to proxy to.
#
class profile::apache::reverse_proxy_wittimr (
  Stdlib::Fqdn $servername,
  String[1]    $proxy_dest = 'localhost',
) {
  apache::vhost { "${servername}_ssl":
    ensure              => present,
    docroot             => '/var/www/html',
    servername          => $servername,
    proxy_preserve_host => true,
    proxy_requests      => false,
    port                => 443,
    proxy_dest          => "http://${proxy_dest}:8080",
    ssl                 => true,
  }
}
