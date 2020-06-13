## Choria CA

This helm charts configures a private CA with RBAC integrated with [Cert Manager](https://cert-manager.io).

## Prerequisites

To use this repository you have to add it to your Helm installtion:

```
$ helm repo add choria https://choria-io.github.io/helm
$ helm repo update
```

You should already have Cert Manager setup and working in your environment.

## Creating a CA

There are many different tools to create Certificate Authorities - one can even copy an existing Puppet one - [EasyRSA](https://github.com/OpenVPN/easy-rsa)
works well. Cert Manager also supports integrating with Vault.

You should pick a CA that's easy to issue Certificates from as depending on your use case you'll have to issue a
number of additional certs using the tools of the CA.

The CA has once you have a CA certificate and key, place them in a directory:

```nohighlight
$ find ca
ca
ca/tls.key
ca/tls.crt
```

And create a Kubernetes Secret:

```nohighlight
$ kubectl -n choria create secret generic choria-ca --from-file ca
```

At this point we can install the CA Issuer, Role, RoleBinding and ServiceAccount.

```nohighlight
$ helm install --namespace choria ca choria/ca 
```

