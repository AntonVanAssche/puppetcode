# @summary Configure Prometheus Alertmanager.
#
# @param version
#   Version of Alertmanager to install.
# @param discord_webhook_url
#   Discord webhook URL to send alerts to.
#
# @example Basic usage.
#   include profile::prometheus::alertmanager
#
class profile::prometheus::alertmanager (
  String[1] $version,
  String[1] $discord_webhook_url,
) {
  $_user = 'alertmanager'
  $_group = 'alertmanager'

  file { '/etc/alertmanager/templates':
    ensure => directory,
    owner  => $_user,
    group  => $_group,
    mode   => '0750',
  }

  $_receivers = {
    'name' => 'discord',
    'discord_configs' => [
      {
        'send_resolved' => true,
        'webhook_url'   => $discord_webhook_url,
      },
    ],
  }

  class { 'prometheus::alertmanager':
    version         => $version,
    user            => $_user,
    group           => $_group,
    storage_path    => '/var/lib/prometheus/alertmanager',
    validate_config => true,
    route           => {
      'group_by'        => ['alertname', 'job'],
      'group_wait'      => '1m',
      'group_interval'  => '5m',
      'repeat_interval' => '24h',
      'receiver'        => $_receivers['name'],
    },
    receivers       => [$_receivers],
  }

  firewalld_port { 'alertmanager':
    ensure   => present,
    port     => 9093,
    protocol => 'tcp',
    zone     => 'public',
  }
}
