## Choria Network Broker

This helm chart installs the Choria Network Broker inside a specific namespace.

## Requirements

At start the broker will auto enroll with a Cert Manager managed Certificate Authority.
Please follow the steps outlined in [README.md](../README.md) to create the initial environment
and add the Choria Helm Repository.

## Pod Affinity

Generally you'd want to run more than one instance of the broker, it does not need to be an odd number,
and if you do you'd want to ensure the brokers run on different underlying nodes. 

```yaml
broker:
  clusterSize: 3

podAffinity:
  podAntiAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
    - labelSelector:
        matchExpressions:
        - key: app
          operator: In
          values:
          - broker
      topologyKey: "kubernetes.io/hostname"
```

Above will create 3 broker instances and spread them across your kubernetes nodes.

```nohighlight
$ kubectl get pod -o wide -n choria
NAME                            READY   STATUS    RESTARTS   AGE     IP           NODE     NOMINATED NODE   READINESS GATES
broker-0                        1/1     Running   0          2m22s   10.2.2.14    knode1   <none>           <none>
broker-1                        1/1     Running   0          2m29s   10.2.0.244   knode2   <none>           <none>
broker-2                        1/1     Running   0          2m43s   10.2.1.82    knode3   <none>           <none>
```

## Values

|Variable|Description|Default|
|--------|-----------|-------|
|`broker.publicName`|When running behind load balancers this will be the url advertised to clients|`""`|
|`broker.certManagerIssuer`|The `Issuer` set up to manager the Certificate Authority|`choria-ca`|
|`broker.createService`|When `true` a `Service` that exposes `servicePort` is created|`false`|
|`broker.servicePort`|The port to expose when `broker.createService` is enabled|`4222`|
|`broker.clusterSize`|The number of pods to start in a cluster|`1`|
|`broker.serviceLeafnodePort`|When > 0 and `broker.createService` is true expose the leafnode port on this port|`0`|
|`broker.resources`|Define the containers resources (requests and limits)|`{}`|
|`streaming.enabled`|Enables the Choria Streaming Server|`false`|
|`streaming.storageClassName`|When set enables creating a PVC for Streaming storage|`""`|
|`streaming.pvcName`|The name of the PVC to create|`streaming`|
|`streaming.storageSize`|The size of the PVC to create|`10Gi`|
|`streaming.eventRetention`|How long to retain lifecycle events for, 0 disables|`24h`|
|`streaming.stateRetention`|How long to retain Autonomous Agent events - including Scout events, 0 disables|`24h`|
|`provisioning.provisionerPassword`|Password for Choria Provisioner to connect|`""`|
|`provisioning.tokenSignerSecret`|Secret holding the public certificate that signed the `provisioner.jwt` on nodes|`""`|

### Provisioning

The Broker can host the Choria Provisioner used to Provision new nodes.

**NOTE:** Requires Choria Server version 0.23.0 at least

To do this a secret needs to be made holding the Public Certificate of the `provisioning.jwt` signer.

```nohighlight
$ find broker
broker/provisioning/signer-cert
broker/provisioning/signer-cert/cert.pem
```

Now we create the secret:

```nohighlight
$ kubectl -n choria create secret generic provisioning-signer-cert --from-file broker/provisioning/signer-cert
secret/provisioning-signer-cert created
```

We can then enable provisioning by setting the `provisioning` values:

```yaml
provisioning:
  provisionerPassword: tooManySecrets
  tokenSignerSecret: provisioning-signer-cert
```

### Leafnodes

You can instruct the broker to connect to a remote network as a Leafnode:

```yaml
leafnodes:
  ngs:
    url: nats-leaf://connect.ngs.global:7422
    credentialSecret: broker-leafnode-ngs
```

Here the `broker-leafnode-ngs` secret has NGS credentials in a file calls `connection.creds` inside it.

See `helm show values choria/broker` for full list of available values.
