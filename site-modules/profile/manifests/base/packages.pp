# @summary Install default packages and set some package resource defaults.
#
# @param install
#   Array of packages that should be installed.
# @param uninstall
#   Array of packages that shouldn't be installed.
#
# @example Install default packages.
#   include profile::base
#
class profile::base::packages (
  Array[String[1]]  $install    = [],
  Array[String[1]]  $uninstall  = [],
) {
  $install.each |$_package| {
    package { $_package:
      ensure   => present,
    }
  }

  if $uninstall {
    $uninstall.each |$_package| {
      package { $_package:
        ensure => absent,
        notify => Exec['apt-update'],
      }
    }
  }

  exec { 'apt-update':
    command     => '/usr/bin/apt update',
    refreshonly => true,
  }

  exec { 'apt-auto-remove':
    command     => '/usr/bin/apt autoremove --purge -y',
    refreshonly => true,
  }
}
