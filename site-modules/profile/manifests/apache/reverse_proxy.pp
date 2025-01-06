# @summary Configure Apache as a reverse proxy.
#
# @example Basic usage.
#   include profile::apache::reverse_proxy
#
class profile::apache::reverse_proxy {
  $_servername = $facts['networking']['domain']

  include profile::apache
  include apache::mod::rewrite

  apache::vhost { "${_servername}-non-ssl":
    servername      => $_servername,
    port            => 80,
    docroot         => '/var/www/html/',
    redirect_status => 'permanent',
    redirect_dest   => "https://${_servername}/",
  }
}
