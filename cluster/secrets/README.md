# Secret Management

The method used is a three step process, with [git-crypt](https://github.com/AGWA/git-crypt) the actual secrets are
encrypted and stored in git. These inturn are being used to create [generic secrets](https://kubernetes.io/docs/concepts/configuration/secret/)
. Next these secrets are [sealed](https://github.com/bitnami-labs/sealed-secrets) so they can again be safely stored in
git.

The script `hacks/create_secrets.sh` automates these steps and generates the needed sealed secrets for the cluster.
