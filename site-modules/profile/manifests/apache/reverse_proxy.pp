# @summary Configure Apache as a reverse proxy.
#
# @example Basic usage.
#   class { 'profile::apache::reverse_proxy':
#     servername => 'host.local',
#   }
#
# @param servername
#   The servername to use for the virtual host.
#
class profile::apache::reverse_proxy (
  Stdlib::Fqdn $servername,
) {
  include profile::apache
  include apache::mod::rewrite

  apache::vhost { "${servername}-non-ssl":
    servername      => $servername,
    port            => 80,
    docroot         => '/var/www/html/',
    redirect_status => 'permanent',
    redirect_dest   => "https://${servername}/",
  }
}
