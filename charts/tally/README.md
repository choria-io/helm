## Choria Network Tally

This helm chart installs the Choria Network Telly inside a specific Namespace.

Tally listens passively to the lifecycle events emitted by Choria and reports on active hosts, versions and their
major events like startup and shutdown.

## Requirements

At start tally will auto enroll with a Cert Manager managed Certificate Authority.
Please follow the steps outlined in [README.md](../README.md) to create the initial environment
and add the Choria Helm Repository.

## Values

|Variable|Description|Default|
|--------|-----------|-------|
|`tally.component`|The component to watch events for|`server`|
|`tally.prefix`|Prefix to add to generated statistics|`choria_tally`|
|`tally.certManagerIssuer`|The Issuer name to reach Cert Manager in the namespace|`choria-ca`|
|`tally.serviceAccount`|The ServiceAccount to use for the pod which gives it access to the Issuer|`choria-csraccess`|
|`tally.loglevel`|The loglevel to use|`info`| 
|`tally.port`|The port to expose Prometeheus metrics on|`8080`|
|`tally.brokerURls`|The URLs to connect to|`nats://broker-ss:4222`|

See `helm show values choria/tally` for full list of available values.
