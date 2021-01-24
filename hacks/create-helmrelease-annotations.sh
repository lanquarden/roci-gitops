#!/usr/bin/env bash
shopt -s globstar

# shellcheck disable=SC2155
REPO_ROOT=$(git rev-parse --show-toplevel)
CLUSTER_ROOT="${REPO_ROOT}/cluster"
HELM_REPOSITORIES="${CLUSTER_ROOT}/flux-system/helm-chart-repositories"
RENOVATE_REGEX="registryUrl=(?<registryUrl>.*?)\n *chart: (?<depName>.*?)\n *version: (?<currentValue>.*)\n"
RENOVATE_FAIL=false

# Ensure yq exist
command -v yq >/dev/null 2>&1 || {
    echo >&2 "yq is not installed. Aborting."
    exit 1
}

for helm_release in "${CLUSTER_ROOT}"/**/*.yaml; do
    # ignore flux-system namespace
    # ignore wrong apiVersion
    # ignore non HelmReleases
    if [[ "${helm_release}" =~ "flux-system"
        || $(yq eval '.apiVersion' "${helm_release}") != "helm.toolkit.fluxcd.io/v2beta1"
        || $(yq eval '.kind' "${helm_release}") != "HelmRelease" ]]; then
        continue
    fi

    for helm_repository in "${HELM_REPOSITORIES}"/*.yaml; do
        chart_name=$(yq eval '.metadata.name' "${helm_repository}")
        chart_url=$(yq eval '.spec.url' "${helm_repository}")

        # only helmreleases where helm_release is related to chart_url
        if [[ $(yq eval '.spec.chart.spec.sourceRef.name' "${helm_release}") == "${chart_name}" ]]; then
            # delete "renovate: registryUrl=" line
            sed -i "/renovate: registryUrl=/d" "${helm_release}"
            # insert "renovate: registryUrl=" line
            sed -i "/.*chart: .*/i \ \ \ \ \ \ # renovate: registryUrl=${chart_url}" "${helm_release}"
            echo "Annotated $(basename "${helm_release%.*}") with ${chart_name} for renovatebot..."
            # check if it can be picked up by renovate regex
            grep -Pz "${RENOVATE_REGEX}" ${helm_release} > /dev/null
            if [ $? -ne 0 ]; then
                echo "ERROR: renovate regex does not match this HelmRelease: ${helm_release}"
                RENOVATE_FAIL=true
            fi
            break
        fi
    done
done

if [ "$RENOVATE_FAIL" = true ]; then
    echo "One or more HelmReleases did not match the renovate regex, see details above."
    exit 1
fi
