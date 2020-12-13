# Creating secrets
If you need to seal a secret for structured data, create a file `secret.yaml`
with this information and encode it with the help of `kubectl`:

```console
$ kubectl create secret generic <secret-name> -n <secret-namespace> --dry-run=client --from-file=<secret-key>=secret.yaml -o yaml > secret_encoded.yaml
```

On the other hand if it is a collection of key value pairs you can do this instead:

```console
$ kubectl create secret generic <secret-name> -n <secret-namespace> --dry-run=client --from-literal=<key1>=<secret1> --from-literal=<key2>=<secret2> -o yaml > secret_encoded.yaml
```

Then seal the secret with `kubeseal`:

```console
$ kubeseal --format yaml <secret_encoded.yaml ><secret-name>.yaml --controller-name=kube-system-sealed-secrets    
```

Clean up

```console
$ rm secret*
```

