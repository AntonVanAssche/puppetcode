# @summary Setup mdadm.
#
# @example Basic usage.
#   include profile::mdadm
#
class profile::mdadm {
  package { 'mdadm':
    ensure => present,
  }

  systemd::dropin_file { 'mdcheck_start.timer':
    ensure         => present,
    filename       => 'override.conf',
    unit           => 'mdcheck_start.timer',
    content        => file('profile/mdadm/reschedule.conf'),
    notify_service => false,
    daemon_reload  => true,
  }
}
