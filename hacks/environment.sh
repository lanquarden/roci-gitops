#!/usr/bin/env bash


# Set main environment variables
export REPO_ROOT=$(git rev-parse --show-toplevel)
export CLUSTER_ROOT="${REPO_ROOT}/cluster"
export PUB_CERT="${CLUSTER_ROOT}/secrets/pub-sealed-secrets.pem"
export SECRETS_ENV="${CLUSTER_ROOT}/secrets/.secrets.env"
export GENERATED_SECRETS="${CLUSTER_ROOT}/secrets/generated_secrets.yaml"


# check needed binaries
need() {
    which "$1" &>/dev/null || die "Binary '$1' is missing but required"
}


need "kubectl"
need "kubeseal"
need "yq" 
need "envsubst"
need "sed"
need "tee"

# Check secrets env file exists
[ -f "${SECRETS_ENV}" ] || {
    echo >&2 "Secret enviroment file doesn't exist. Aborting."
    exit 1
}
# Check secrets env file is text (git-crypt has decrypted it)
file "${SECRETS_ENV}" | grep "ASCII text" >/dev/null 2>&1 || {
    echo >&2 "Secret enviroment file isn't a text file. Aborting."
    exit 1
}

# Export environment variables
set -a
source "${SECRETS_ENV}"
set +a
