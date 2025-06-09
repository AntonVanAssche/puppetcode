# @summary Configure Apache reverse proxy for wittimr.
#
# @param proxy_dest
#   The destination to proxy to.
#
# @example Basic usage.
#   include profile::apache::reverse_proxy_wittimr
#
class profile::apache::reverse_proxy_wittimr (
  String[1] $proxy_dest = 'localhost',
) {
  $_servername = $facts['networking']['domain']

  apache::vhost { "${_servername}_ssl":
    ensure              => present,
    docroot             => '/var/www/html',
    servername          => $_servername,
    proxy_preserve_host => true,
    proxy_requests      => false,
    port                => 443,
    proxy_dest          => "http://${proxy_dest}:8080",
    ssl                 => true,
  }
}
