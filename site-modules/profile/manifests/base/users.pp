# @summary Manage users and groups
#
# @example Basic usage
#   include profile::base::users
#
class profile::base::users (
  String[1] $group = $facts['networking']['hostname'],
  String[1] $user  = $facts['networking']['hostname'],
) {
  group { $group:
    ensure => present,
    gid    => 1000,
  }

  user { $user:
    ensure     => present,
    uid        => 1000,
    gid        => 1000,
    managehome => true,
    home       => "/home/${user}",
  }

  file_line { "${user}_set_vi":
    path  => "/home/${user}/.bashrc",
    match => '^set -o (vi|emacs)$',
    line  => 'set -o vi',
  }
}
