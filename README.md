## Choria Helm Chart Repository

This is a repository of Helm Charts related to the [Choria](https://choria.io) eco system.

This is a work in progress and not yet ready for wider use.

## Installation

To use this repository you have to add it to your Helm installtion:

```
$ helm repo add choria https://choria-io.github.io/helm
$ helm repo update
```

## Required Certificate Authority

Where possible the charts will auto enroll their components in a [Cert Manager](https://cert-manager.io/)
manager Certificate Authority. This is not set up by these charts.

One the initial configuration is completed and Cert Manager is running in your cluster
follow the [CA](https://cert-manager.io/docs/configuration/ca/) guide to configure a self signed CA.

**WARNING:** Do not use Letsencrypt certificates unless you know what you are doing.

The Certificate Authority you are establishing will be used for various aspects that
are safe to auto enroll, you should have the ability to issue certificates from your CLI
for clients and privileged certificates should you need that. See specific Chart readme files
for details.

## Charts

|Chart|Description|
|-----|-----------|
|[broker](https://github.com/choria-io/helm/tree/master/charts/provisioner)|Installs and configure [Choria Broker](https://github.com/choria-io/go-choria)|
|[provisioner](https://github.com/choria-io/helm/tree/master/charts/provisioner)|Installs and configure [Choria Provisioner](https://github.com/choria-io/provisioning-agent)|
