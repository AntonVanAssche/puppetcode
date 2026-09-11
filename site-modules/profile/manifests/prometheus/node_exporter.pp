# @summary Install Prometheus Node Exporter.
#
# @example Basic usage.
#   class { 'profile::prometheus::node_exporter':
#     version => '1.0.0',
#   }
#
# @param version
#   Version of Node Exporter to install.
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
