# @summary Manages sudo.
#
# Agreement on priorities:
# - 10: base
# - 30: local users
# - 40: local users with NOPASSWD
#
# @see https://github.com/saz/puppet-sudo
#
# @example Basic usage.
#   include profile::base::sudo
#
class profile::base::sudo {
  $_base_specs = [
    '%sudo ALL=(ALL) ALL',
    'Defaults:sudo timestamp_timeout = 60',
  ]

  $_nopasswd_specs = [
    '%sudo ALL=(ALL) NOPASSWD: /usr/bin/systemctl poweroff',
    '%sudo ALL=(ALL) NOPASSWD: /usr/bin/systemctl reboot',
    '%sudo ALL=(ALL) NOPASSWD: /usr/bin/systemctl reload sshd',
    "${facts['networking']['hostname']} ALL=(ALL) NOPASSWD: /opt/puppetlabs/bin/puppet",
  ]

  include sudo
  sudo::conf {
    default:
      ensure => present,
      ;
    'base':
      priority => 10,
      content  => $profile::base::sudo::_base_specs,
      ;
    'nopasswd':
      priority => 40,
      content  => $profile::base::sudo::_nopasswd_specs,
      ;
  }
}
