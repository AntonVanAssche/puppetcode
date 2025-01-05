# @summary Set up fail2ban.
#
# @example Basic usage.
#   include profile::base::fail2ban
#
class profile::base::fail2ban {
  class { 'fail2ban':
    package_ensure     => 'latest',
  }
}
