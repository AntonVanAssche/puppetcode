# @summary: Install and configure Apache.
#
# @example Basic usage.
#   include profile::apache
#
class profile::apache {
  $_servername = $facts['networking']['domain']

  openssl::certificate::x509 { $_servername:
    ensure     => present,
    commonname => $_servername,
  }

  class { 'apache':
    default_vhost                => false,
    default_ssl_cert             => "/etc/ssl/certs/${_servername}.crt",
    default_ssl_key              => "/etc/ssl/certs/${_servername}.key",
    default_ssl_reload_on_change => true,
    service_restart              => '/usr/bin/systemctl reload apache2.service', # graceful restart
    log_formats                  => {
      'default' => '%{X-Forwarded-For}i %l %u [%{%d/%b/%Y %T}t.%{msec_frac}t %{%z}t] \"%r\" %s %b %D \"%{Referer}i\" \"%{User-agent}i\"', # lint:ignore:140chars
    },
    require                      => OpenSSL::Certificate::X509[$_servername],
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
