# Choria AAA Service

This helm chart installs the [Choria AAA Service](https://github.com/choria-io/aaasvc) that provides centralised
Authentication, Authorization and Auditing.

This is a complicated service with many scenarios and x509 keys needed, I strongly suggest a good read through the
repository README to understand what this does and how.

The helm chart documentation assumes familiarity with the overall design and goals.

## Requirements

A number of x509 Certificates are needed, you'll need access to the CA your fleet uses.

The example will set up a basic static user list authenticator, authorizer and auditor.  Review the values.yaml
reference to see how to integrate with Okta etc.

### JWT Signing Key and Certificate

In all deployment scenarios you will need a key pair that will be used to sign and verify the JWT tokens issued to
users.

These keys do not need to be trusted by Choria so should not follow the `xxx.mcollective` pattern. These do not 
need to be signed by any CA, but you can as below:

```nohighlight
$ mco choria request_cert --certname caaa-signer.example.net
....
```

Place the resulting key and certificate in a directory like this:

```nohighlight
$ find aaasvc
aaasvc/signer-key
aaasvc/signer-key/key.pem
aaasvc/signer-cert
aaasvc/signer-cert/cert.pem
```

They are split into 2 secrets since it's possible to rollout just the signer or just the authenticator, this way you
can protect the signing key in a safe central area with signers in every regional environment.

```nohighlight
$ kubectl -n choria create secret generic aaasvc-signer-key --from-file aaasvc/signer-key
secret/aaasvc-signer-key created
$ kubectl -n choria create secret generic aaasvc-signer-cert --from-file aaasvc/signer-cert
secret/aaasvc-signer-cert created
```

### Users

Authentication is optional, and can be split into another service, in this example we'll perform all 3 parts in one.

A basic users file looks like this:

The password is from:

```nohighlight
$ echo -n secr3t|htpasswd -n -Bi guest
```

```json
[
  {
    "username": "guest",
    "password": "$2y$05$cy7O5HHsVro9E1tEB4LomerPd9vRevFbS/5PS0bscUP7ocG.7XbRu",
    "opa_policy_file":"/aaasvc/authenticator/users/guest.rego",
    "properties": {
      "group": "guest"
    }
  }
]
```

We also need a Open Policy Agent policy for this user:

```nohighlight
package choria.aaa.policy

default allow = false

allow {
  input.agent == "rpcutil"
  input.action == "ping"
  input.properties.group == "guest"
}
```

Place these files on disk and create some secrets and configmaps:

```nohighlight
$ find caaa
aaasvc/users
aaasvc/users/guest.rego
aaasvc/users/users.json
```

```nohighlight
$ kubectl -n choria create secret generic aaasvc-users --from-file aaasvc/users
secret/aaasvc-users created
```

### Choria Privileged Certificate

When enabling request signing you will need a Choria Privileged Certificate, this has to be signed by the same
CA that the nodes live in and must match the pattern `^.+.privileged.mcollective` unless you changed this in your
choria setup

```nohighlight
$ mco choria request_cert --certname signer.privileged.mcollective
....
```

Place the resulting files like this:

```nohighlight
$ find aaasvc
aaasvc/choria
aaasvc/choria/ca.pem
aaasvc/choria/cert.pem
aaasvc/choria/key.pem
```

And create the secret holding these files:

```nohighlight
$ kubectl -n choria create secret generic aaasvc-request-signer --from-file aaasvc/choria
```

### Values

Finally we configure our `values.yaml` to tie all these together, the secret and configmap names I chose above
are the defaults the Chart assumes so keeping to those makes this easier.

```yaml
aaasvc:
    ingressHostname: caaa.example.net
    ingressAnnotations:
      cert-manager.io/cluster-issuer: letsencrypt-choria
      nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
```

This sets up the AAA service to listen on `caaa.example.net` behind lets encrypt TLS certs.  All the rest will use 
sane defaults to set up what we did above.

