# @summary Configure Samba
#
# @example Basic usage.
#   include profile::samba
#
class profile::samba {
  file { '/mnt/nas':
    ensure  => directory,
    owner   => $facts['networking']['hostname'],
    group   => $facts['networking']['hostname'],
    mode    => '0755',
    require => User[$facts['networking']['hostname']],
  }

  class { 'samba':
    workgroup           => 'COCK',
    netbios_name        => $facts['networking']['hostname'],
    server_string       => "Samba Server on ${facts['networking']['hostname']}",
    interfaces          => [$facts['networking']['ip']],
    hosts_deny          => [],
    local_master        => false,
    domain_master       => false,
    log_file            => '/var/log/samba/log.%I-%M',
    security            => 'user',
    shares              => {
      'printers' => {
        ensure => absent,
      },
      'print$'   => {
        ensure => absent,
      },
      'homes' => {
        comment    => 'Home Directories',
        path       => '/home',
        browseable => false,
        writable   => true,
      },
      'nas'   => {
        comment        => 'Nas Share',
        path           => '/mnt/nas',
        directory_mask => '0755',
        create_mask    => '0644',
        browseable     => true,
        writable       => true,
      },
    },
  }

  firewalld_service { 'samba':
    ensure => present,
    zone   => 'public',
  }
}
