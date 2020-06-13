## Choria Network Broker

This helm chart installs the Choria Network Broker inside a specific namespace.

## Requirements

At start the broker will auto enroll with a Cert Manager managed Certificate Authority.
Please follow the steps outlined in [README.md](../README.md) to create the initial environment
and add the Choria Helm Repository.

## Values

|Variable|Description|Default|
|--------|-----------|-------|
|`broker.publicName`|When running behind load balancers this will be the url advertised to clients|`""`|
|`broker.certManagerIssuer`|The `Issuer` set up to manager the Certificate Authority|`choria-ca`|
|`broker.createService`|When `true` a `Service` that exposes `servicePort` is created|`false`|
|`broker.servicePort`|The port to expose when `broker.createService` is enabled|`4222`|
|`broker.clusterSize`|The number of pods to start in a cluster|`1`| 

See `helm show values choria/provisioner` for full list of available values.
