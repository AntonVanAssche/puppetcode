# @summary Configure Apache reverse proxy for Emby.
#
# @param proxy_dest
#   The destination to proxy to.
#
# @example Basic usage.
#   include profile::apache::reverse_proxy_emby
#
class profile::apache::reverse_proxy_emby (
  String[1] $proxy_dest = 'localhost',
) {
  $_servername = $facts['networking']['domain']

  apache::vhost { "emby.${facts['networking']['domain']}_non-ssl":
    servername      => "emby.${facts['networking']['domain']}",
    port            => 80,
    docroot         => '/var/www/html/',
    redirect_status => 'permanent',
    redirect_dest   => "https://emby.${facts['networking']['domain']}/",
  }

  apache::vhost { "emby.${facts['networking']['domain']}_ssl":
    ensure              => present,
    servername          => "emby.${facts['networking']['domain']}",
    docroot             => '/var/www/html',
    proxy_preserve_host => true,
    proxy_requests      => false,
    port                => 443,
    proxy_dest          => "http://${proxy_dest}:${profile::emby::port}",
    ssl                 => true,
  }
}
