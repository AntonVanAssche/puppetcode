# @summary: Install and configure Apache.
#
# @example Basic usage.
#   class { 'profile::apache':
#     servername => 'host.local',
#   }
#
# @param servername
#   The servername to use for the virtual host.
#
class profile::apache (
  Stdlib::Fqdn $servername,
) {
  openssl::certificate::x509 { $servername:
    ensure     => present,
    commonname => $servername,
  }

  class { 'apache':
    default_vhost                => false,
    default_ssl_cert             => "/etc/ssl/certs/${servername}.crt",
    default_ssl_key              => "/etc/ssl/certs/${servername}.key",
    default_ssl_reload_on_change => true,
    service_restart              => '/usr/bin/systemctl reload apache2.service', # graceful restart
    log_formats                  => {
      'default' => '%{X-Forwarded-For}i %l %u [%{%d/%b/%Y %T}t.%{msec_frac}t %{%z}t] \"%r\" %s %b %D \"%{Referer}i\" \"%{User-agent}i\"', # lint:ignore:140chars
    },
    require                      => OpenSSL::Certificate::X509[$servername],
  }

  $user  = $apache::user
  $group = $apache::group

  logrotate::rule { 'apache2':
    ensure        => present,
    path          => '/var/log/apache2/*.log',
    rotate        => 30,
    rotate_every  => 'day',
    delaycompress => false,
    ifempty       => false,
    missingok     => true,
    sharedscripts => true,
    postrotate    => '/etc/init.d/apache2 reload > /dev/null',
  }
}
