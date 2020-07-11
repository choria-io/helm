# Choria Server Provisioner

This helm chart installs the [Choria Server Provisioner](https://github.com/choria-io/provisioning-agent) inside a specific namespace.

## Requirements

At start the broker will auto enroll with a Cert Manager managed Certificate Authority.
Please follow the steps outlined in [README.md](../README.md) to create the initial environment
and add the Choria Helm Repository.

### Helper

A helper script is required to configure and enroll machines into the Certificate Authority, a sample
script can be found in the contrib directory of this chart.

The script constructs the configuration for nodes and also enroll them into the CA if required.
The sample script does that with the Cert Manager Issuer created by the `ca` chart and makes a
good starting point.

Place your helper in a directory and create a ConfigMap with it:

```nohighlight
$ find provisioner
provisioner
provisioner/helper
provisioner/helper/provision-helper

$ kubectl -n choria create configmap provisioner-helper --from-file provisioner/helper                                                                                            <18:32:35
configmap/provisioner-helper created
```

### Tokens, usernames and passwords

You'll need a few passwords and tokens:

 * token - a long random string used as a psk for accessing the provisioning agent
 * choria password - password the Choria Servers will authenticate with to the broker
 * provisioner password - password the Choria Server Provisioner will authenticate with to the broker

The last 2 is required when using the embedded Choria Broker.

### JWT Verifier

Choria supports 2 modes of obtaining provisioning details, either by compiling the settings into the
binary or by placing the values into a signed JWT.  The JWT approach works with the Open Source binaries without
any recompiling.

First we need a certificate and key used to sign the JWT, these do not need to be signed by any CA.

```nohighlight
$ find provisioner
provisioner/jwt-signer-cert
provisioner/jwt-signer-cert/signer.pem
provisioner/jwt-signer-key
provisioner/jwt-signer-key/signer-key.pem
```

Next we'll use the private key to create a JWT token and sign it:

```nohighlight
choria tool jwt provision.jwt provisioner/jwt-signer-key/signer-key.pem \
    --insecure \                                  # No TLS to the provisioning network
    --token tokent0kentok3n \                     # Token Choria will use to access the agent
    --srv example.net   \                         # SRV records in _choria-provisioner._tcp.<domain>
    --default \                                   # Provision unless disabled by config
    --username choria \                           # User to connect to the middleware with
    --password s3cret                             # Password to connect with
```

Next we verify that the Public certificate can decode the JWT:

```nohighlight
$ choria tool jwt provision.jwt provisioner/jwt-signer-cert/signer.pem
JWT Token provision.jwt

                         Token: *****
                        Secure: false
                    SRV Domain: exaple.net
       Provisioning by default: true
               Broker Username: choria
               Broker Password: *****
              Standard Claims: {
                                 "iat": 1592158183,
                                 "iss": "choria cli",
                                 "nbf": 1592158183,
                                 "sub": "choria_provisioning"
                               }
```

If you place this file in `/etc/choria/provisioner.jwt` in an Open Source Choria then `choria buildinfo` will 
show these settings are in effect.

Finally we need to create a Kubernetes Secret holding the Public certificate:

```nohighlight
$ kubectl -n choria create secret generic jwt-signer-cert --from-file provisioner/jwt-signer-cert
secret/jwt-signer-cert created
```

### Values

Given this, the following `values.yaml` will wire it all up.

```yaml
auth:
  provisioner: provs3cret
  choria: s3cret

provisioner:
  token: tokent0kentok3n
``` 

|Value|Description|Default|
|-----|-----------|-------|
|`pki.enabled`|Support requesting CSRs from the nodes and enable x509 enrolment|`true`|
|`pki.serviceAccount`|Service account to use for gaining access to Cert Manager|`choria-csraccess`|
|`broker.embedded`|Enables the embedded Choria Broker|`true`|
|`broker.createService`|Expose the embedded broker to the outside via a Service|`true`|
|`broker.port`|Port to configure the Service to listen on|`4223`|
|`broker.url`|URL to the broker serving provisioning, can be a remote server when embedded not used|`nats://localhost:4222`|
|`broker.connectSecret`|When a remote broker is used this configures TLS if needed|`""`|
|`jwt.enabled`|Enable JWT signature checks before provisioning a node|`true`|
|`jwt.signerSecret`|The Public Certificate used to validate incoming JWT files|`jwt-signer-cert`|
|`auth.provisioner`|When using the embedded broker, the password for the `provisioning` user|`""`|
|`auth.choria`|When using the embedded broker, the password for the `choria` user|`""`|
|`helper.configMap`|The ConfigMap holding the helper script|`provisioner-helper`|
|`provisioner.workers`|How many concurrent provisioner workers to run|`4`|
|`provisioner.interval`|How often to check for new nodes in addition to listening for events|`5m`|
|`provisioner.loglevel`|The logging level|`info`|
|`provisioner.token`|The token to use when accessing Choria Provisioner Agent actions|`""`|
|`provisioner.insecure`|Disable TLS when connecting to the Provisioner Broker|`true`|
|`probisioner.certManagerIssuer`|The name of the Issuer to access Cert Manager|`choria-ca`|

See `helm show values choria/provisioner` for full list of available values.
