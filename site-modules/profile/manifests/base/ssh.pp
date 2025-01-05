# @summary Configure SSH on all nodes
#
# @example Basic usage.
#   include profile::base::ssh
#
class profile::base::ssh {
  service { 'sshd':
    ensure => running,
    enable => true,
  }

  file { '/etc/banner':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => 'puppet:///modules/profile/base/banner',
  }

  class { 'ssh::server':
    storeconfigs_enabled => false,
    options              => {
      'Banner'                 => '/etc/banner',
      'Match User www-data'    => {
        'ChrootDirectory'        => '%h',
        'ForceCommand'           => 'internal-sftp',
        'PasswordAuthentication' => 'yes',
        'AllowTcpForwarding'     => 'no',
        'X11Forwarding'          => 'yes',
      },
      'PasswordAuthentication' => 'yes',
      'UsePAM'                 => 'yes',
      'PermitRootLogin'        => 'no',
      'Port'                   => [22, 2222],
    },
  }
}
