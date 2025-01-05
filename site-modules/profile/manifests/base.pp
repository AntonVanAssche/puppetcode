# @summary Base profile for all nodes.
#
# @example Basic usage.
#   include profile::base
#
class profile::base {
  include profile::base::packages
  include profile::base::users
  include profile::base::sudo
  include profile::base::ssh
  include profile::base::firewall
  include profile::base::fail2ban
  include profile::prometheus::node_exporter
  include profile::tailscale
}
