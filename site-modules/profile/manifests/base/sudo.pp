# @summary Manages sudo.
#
# @example Basic usage.
#   class { 'profile::base::sudo':
#     base_specs     => [],
#     nopasswd_specs => [],
#   }
#
# Agreement on priorities:
# - 10: base
# - 30: local users
# - 40: local users with NOPASSWD
#
# @param base_specs
#   List of base sudo rules.
# @param nopasswd_specs
#   List of nopasswd sudo rules.
#
class profile::base::sudo (
  Array[String] $base_specs,
  Array[String] $nopasswd_specs,
) {
  include sudo

  sudo::conf {
    default:
      ensure => present,
    ;
    'base':
      priority => 10,
      content  => $base_specs,
    ;
    'nopasswd':
      priority => 40,
      content  => $nopasswd_specs,
    ;
  }
}
