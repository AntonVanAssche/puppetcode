# @summary Set up Podman.
#
# Install common tools and dependencies for container runtimes.
#
# @example Basic usage.
#   include profile::podman
#
class profile::podman {
  package { 'podman':
    ensure => present,
  }
}
