class role::homer {
  include profile::base
  include profile::emby
  include profile::grafana
  include profile::prometheus
  include profile::transmission
}
