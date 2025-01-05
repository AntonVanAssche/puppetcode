node default {
  include profile::base
}

node /homer/ {
  include role::homer
}

node /marge/ {
  include role::marge
}
