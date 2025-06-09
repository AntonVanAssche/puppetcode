class role::homer {
  include profile::base
  include profile::emby
  include profile::grafana
  include profile::prometheus
  include profile::transmission
  include profile::wittimr
  include profile::apache::reverse_proxy
  include profile::apache::reverse_proxy_pihole
}
