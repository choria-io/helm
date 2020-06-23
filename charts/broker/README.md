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
