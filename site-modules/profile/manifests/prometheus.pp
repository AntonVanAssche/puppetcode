# @summary Setup Prometheus server.
#
# @param version
#   Version of Prometheus to install.
# @param alerts
#   Rules for alerting.
# @param alertmanager_host
#   Hostname of the Alertmanager server.
# @param scrape_configs
#   Configuration for scraping metrics.
#
# @example Basic usage.
#   include profile::prometheus
#
class profile::prometheus (
  String[1] $version,
  Hash      $alerts            = {},
  String[1] $alertmanager_host = 'localhost',
  Array     $scrape_configs    = [],
) {
  $user  = 'prometheus'
  $group = 'prometheus'

  class { 'prometheus::server':
    version              => $version,
    user                 => $user,
    group                => $group,
    shared_dir           => '/usr/share/prometheus',
    localstorage         => '/var/lib/prometheus/data',
    global_config        => {
      'scrape_interval'     => '15s',
      'evaluation_interval' => '15s',
    },
    scrape_configs       => $scrape_configs,
    alerts               => $alerts,
    alertmanagers_config => [
      {
        'static_configs' => [
          {
            'targets' => [
              "${alertmanager_host}:9093",
            ],
          }
        ],
      }
    ],
  }

  file { '/etc/prometheus/alerts.yml':
    ensure  => file,
    owner   => $user,
    group   => $group,
    mode    => '0644',
    content => 'puppet:///modules/profile/prometheus/alerts.yml',
  }

  firewalld_port { 'prometheus':
    ensure   => present,
    zone     => 'public',
    port     => 9090,
    protocol => 'tcp',
  }
}
