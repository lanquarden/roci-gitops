# Creating secrets
If you need to seal a secret for with structured data, create a file ``secret.yaml``
with this information and encode it with the help of ``kubectl``

    kubectl create secret generic <secret-name> -n <secret-namespace> --dry-run=client --from-file=<secret-key>=secret.yaml -o yaml > secret_encoded.yaml

Then seal the secret with ``kubeseal``

    kubeseal --format yaml <secret_encoded.yaml ><secret-name>.yaml --controller-name=kube-system-sealed-secrets    

Clean up

    rm secret*

