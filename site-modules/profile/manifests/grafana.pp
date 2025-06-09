# @summary Installs and configures Grafana server.
#
# @param version
#   Version of Grafana to install.
#
# @example Basic usage.
#   include profile::grafana
#
class profile::grafana (
  String[1] $version,
) {
  include profile::apache::reverse_proxy_grafana

  class { 'grafana':
    version                  => $version,
    manage_package_repo      => true,
    provisioning_datasources => {
      'apiVersion'  => 1,
      'datasources' => [
        {
          'name'   => 'Prometheus',
          'uid'    => 'prometheus',
          'type'   => 'prometheus',
          'access' => 'proxy',
          'url'    => 'http://localhost:9090',
        },
        {
          'name' => 'Alertmanager',
          'type' => 'alertmanager',
          'url'  => 'http://localhost:9093',
        },
      ],
    },
    provisioning_dashboards  => {
      'apiVersion' => 1,
      'providors'  => [
        {
          'name'            => 'dashboards',
          'orgId'           => 1,
          'folder'          => '',
          'type'            => 'file',
          'disableDeletion' => false,
          'editable'        => true,
          'options'         => {
            'path'                      => '/var/lib/grafana/dashboards',
            'foldersFromFilesStructure' => true,
            'puppetsource'              => 'puppet:///modules/profile/grafana/dashboards',
          },
        },
      ],
    },
  }

  firewalld_port { 'grafana':
    ensure   => present,
    zone     => 'public',
    port     => 3000,
    protocol => 'tcp',
  }
}
