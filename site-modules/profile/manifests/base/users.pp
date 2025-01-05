# @summary Manage users and groups
#
# @example Basic usage
#   include profile::base::users
#
class profile::base::users {
  $_group = $facts['networking']['hostname']
  $_user = $facts['networking']['hostname']

  group { $_group:
    ensure => present,
    gid    => 1000,
  }

  user { $_user:
    ensure     => present,
    uid        => 1000,
    gid        => 1000,
    managehome => true,
    home       => "/home/${_user}",
  }

  file_line { "${_user}_set_vi":
    path  => "/home/${_user}/.bashrc",
    match => '^set -o (vi|emacs)$',
    line  => 'set -o vi',
  }
}
