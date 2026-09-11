# @summary Configure firewalld.
#
# @example Basic usage.
#   include profile::base::firewall
#
# @param allowed_services
#   Allowed services.
# @param allowed_ports
#   Allowed ports.
#
class profile::base::firewall (
  Array[String[1]] $allowed_services = [],
  Array[String[1]] $allowed_ports    = [],
) {
  firewalld_zone {
    default:
      ensure => present,
    ;
    'public':
      target           => 'default',
      masquerade       => true,
      icmp_blocks      => [],
      purge_rich_rules => true,
      purge_services   => true,
      purge_ports      => true,
    ;
    'drop':
      target           => '%%DROP%%',
      purge_ports      => true,
      purge_rich_rules => true,
      purge_services   => true,
    ;
  }

  $allowed_services.each |$_service| {
    firewalld_service { $_service:
      ensure => present,
      zone   => 'public',
      ;
    }
  }

  $allowed_ports.each |$_port| {
    firewalld_port { $_port:
      ensure => present,
      zone   => 'public',
      ;
    }
  }
}
