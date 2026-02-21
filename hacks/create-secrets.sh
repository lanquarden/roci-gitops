#!/usr/bin/env bash


# Wire up the env and validations
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "${__dir}/environment.sh"


# Create secrets file
truncate -s 0 "${GENERATED_SECRETS}"

#
# Helm Secrets
#

# Generate Helm Secrets
txt=$(find "${CLUSTER_ROOT}" -type f -name "helmsecrets.txt")

# make sure globstar is set
shopt -s globstar


if [[ ( -n $txt ) ]];
then
    # shellcheck disable=SC2129
    printf "%s\n%s\n%s\n" "#" "# Auto-generated helm secrets -- DO NOT EDIT." "#" >> "${GENERATED_SECRETS}"

    for file in ${CLUSTER_ROOT}/**/helmsecrets.txt; do
        # Get the path and basename of the txt file
        # e.g. "deployments/default/pihole/pihole"
        secret_path=$(dirname "$file")
        # Get the filename without extension
        # e.g. "pihole"
        secret_name=$(basename "${secret_path}")
        # Get the namespace (based on folder path of manifest)
        namespace=$(basename "$(dirname "${secret_path}")")
        echo "[*] Generating helm secret '${secret_name}' in namespace '${namespace}'..."
        # Create secret
        envsubst < "$file" |
            # Create the Kubernetes secret
            kubectl -n "${namespace}" create secret generic "${secret_name}-helm-values" \
                --from-file=/dev/stdin --dry-run=client -o json |
            # Seal the Kubernetes secret
            kubeseal --format=yaml --cert="${PUB_CERT}" |
            # Remove null keys
            yq -y 'del(.metadata.creationTimestamp)' - |
            yq -y 'del(.spec.template.metadata.creationTimestamp)' - |
            # Format yaml file
            sed \
                -e 's/stdin\:/values.yaml\:/g' \
                -e '/^[[:space:]]*$/d' \
                -e '1s/^/---\n/' |
            # Write secret
            tee -a "${GENERATED_SECRETS}" >/dev/null 2>&1
    done
fi

#
# Generic Secrets
#
create_generic_literal_secret () {
    secret_name=$1
    namespace=$2
    literals="${@:3}"
    literals_expanded=""

    echo "[*] Generating generic secret '${secret_name}' in namespace '${namespace}'..."

    # shellcheck disable=SC2068
    for literal in ${literals[@]}
    do
       literals_expanded=$literals_expanded" --from-literal=${literal}"
    done

    kubectl create secret generic $secret_name --namespace $namespace \
        $literals_expanded --dry-run=client -o json |
        kubeseal --format yaml --cert="${PUB_CERT}" |
        # remove null keys
        yq -y 'del(.metadata.creationTimestamp)' - |
        yq -y 'del(.spec.template.metadata.creationTimestamp)' - |
        # Format yaml file
        sed -e '1s/^/---\n/' |
        # Write secret
        tee -a "${GENERATED_SECRETS}" >/dev/null 2>&1
}

create_generic_file_secret () {
    secret_name=$1
    namespace=$2
    key=$3
    file=$4

    echo "[*] Generating generic secret '${secret_name}' in namespace '${namespace}'..."

    # Create secret
    envsubst < "$file" |
        kubectl create secret generic $secret_name --namespace $namespace \
            --from-file=$key=/dev/stdin --dry-run=client -o json |
            kubeseal --format yaml --cert="${PUB_CERT}" |
            # remove null keys
            yq -y 'del(.metadata.creationTimestamp)' - |
            yq -y 'del(.spec.template.metadata.creationTimestamp)' - |
            # Format yaml file
            sed -e '1s/^/---\n/' |
            # Write secret
            tee -a "${GENERATED_SECRETS}" >/dev/null 2>&1
}

# shellcheck disable=SC2129
printf "%s\n%s\n%s\n" "#" "# Auto-generated generic secrets -- DO NOT EDIT." "#" >> "${GENERATED_SECRETS}"

# cert manager cloudflare api key
create_generic_literal_secret "cloudflare-api-key" "network" \
    "api-key=${CERT_MANAGER_CLOUDFLARE_API_KEY}"

# cloudflare dynamic dns
create_generic_literal_secret "cloudflare-ddns" "network" \
    "cloudflare-ddns-hosts=${CLOUDFLARE_DDNS_HOSTS}" \
    "cloudflare-ddns-token=${CLOUDFLARE_DDNS_TOKEN}" \
    "cloudflare-ddns-user=${CLOUDFLARE_DDNS_USER}" \
    "cloudflare-ddns-zones=${CLOUDFLARE_DDNS_ZONES}"

# influxdb minio access key
create_generic_file_secret influxdb-ceph monitoring credentials \
    cluster/monitoring/influxdb/influxdb-ceph-secret.txt

# Remove empty new-lines
sed -i '/^[[:space:]]*$/d' "${GENERATED_SECRETS}"

# Validate Yaml
if ! yq '.' "${GENERATED_SECRETS}" >/dev/null 2>&1; then
    echo "Errors in YAML"
    exit 1
fi

exit 0
