# @summary Install Prometheus Node Exporter.
#
# @param version
#   Version of Node Exporter to install.
#
# @example Basic usage.
#   include profile::prometheus::node_exporter
#
class profile::prometheus::node_exporter (
  String[1] $version
) {
  $_user = 'node_exporter'
  $_group = 'node_exporter'

  class { 'prometheus::node_exporter':
    version => $version,
    user    => $_user,
    group   => $_group,
  }

  firewalld_port { 'node_exporter':
    ensure   => present,
    zone     => 'public',
    port     => 9100,
    protocol => 'tcp',
  }
}
