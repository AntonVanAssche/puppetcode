#!/usr/bin/env bash

set -o errexit  # Abort on nonzero exit code.
set -o nounset  # Abort on unbound variable.
set -o pipefail # Don't hide errors within pipes.
# set -o xtrace # Enable for debugging.

readonly PUPPET_BIN="/opt/puppetlabs/bin/puppet"
readonly R10K_BIN="/opt/puppetlabs/puppet/bin/r10k"
readonly PUPPET_CODE="/opt/puppetcode"
readonly HIERA_CONFIG="${PUPPET_CODE}/hiera.yml"
readonly MODULE_PATH="${PUPPET_CODE}/modules:${PUPPET_CODE}/site-modules"
readonly MANIFEST="${PUPPET_CODE}/manifests/site.pp"

usage() {
    cat <<EOF >&2
Usage: $(basename "${0}") [OPTIONS]

OPTIONS:
    -a  Apply the Puppet manifest.
    -h  Show this help message.
    -i  Install the Puppet code and dependencies.
    -u  Upgrade the Puppet code.
EOF
}

apply() {
    test -x "${PUPPET_BIN}" || \
        { echo "Puppet is not installed or not in PATH." >&2; exit 1; }

    ${PUPPET_BIN} apply \
        --hiera_config="${HIERA_CONFIG}" \
        --modulepath="${MODULE_PATH}" \
        "${MANIFEST}"
}

upgrade() {
    [[ -d "${PUPPET_CODE}" ]] || \
        { echo "Puppet code is not installed." >&2; exit 1; }

    /usr/bin/apt update
    /usr/bin/apt --only-upgrade install puppetcode

    [[ -x "${R10K_BIN}" ]] || \
        { echo "R10k is not installed or not in PATH." >&2; exit 1; }

    ${R10K_BIN} puppetfile install \
        --moduledir "${PUPPET_CODE}/modules" \
        --puppetfile "${PUPPET_CODE}/Puppetfile"
}

install() {
    [[ -d "${PUPPET_CODE}" ]] || \
        { echo "Puppet code is already installed." >&2; exit 1; }

    /usr/bin/cat <<EOF > /etc/apt/sources.list.d/puppetcode.list
deb [signed-by=/etc/apt/keyrings/puppetcode-archive-keyring.gpg] https://packagecloud.io/AntonVanAssche/puppetcode/debian bullseye main
deb-src [signed-by=/etc/apt/keyrings/puppetcode-archive-keyring.gpg] https://packagecloud.io/AntonVanAssche/puppetcode/debian bullseye main
EOF

    [[ -x /usr/bin/curl ]] || /usr/bin/apt install -y curl
    [[ -x /usr/bin/gpg ]] || /usr/bin/apt install -y gpg

    /usr/bin/curl -fsSL https://packagecloud.io/AntonVanAssche/puppetcode/gpgkey | \
        /usr/bin/gpg --dearmor > /etc/apt/keyrings/puppetcode-archive-keyring.gpg
    /usr/bin/curl -fsSL \
        -o /tmp/puppet8-release-bullseye.deb \
        https://apt.puppet.com/puppet8-release-bullseye.deb
    /usr/bin/apt install -y /tmp/puppet8-release-bullseye.deb
    /usr/bin/apt update
    /usr/bin/apt install -y puppetcode

    /opt/puppetlabs/puppet/bin/gem install r10k
    [[ -x "${R10K_BIN}" ]] || \
        { echo "R10k is not installed or not in PATH." >&2; exit 1; }

    ${R10K_BIN} puppetfile install \
        --moduledir "${PUPPET_CODE}/modules" \
        --puppetfile "${PUPPET_CODE}/Puppetfile"
}

while getopts ":ahiu" opt; do
    case ${opt} in
        a)
            apply;;
        h)
            usage;;
        i)
            install;;
        u)
            upgrade;;
        \?)
            echo "Invalid option: ${OPTARG}" >&2
            usage;;
    esac
done
