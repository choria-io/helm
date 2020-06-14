## Choria Helm Chart Repository

This is a repository of Helm Charts related to the [Choria](https://choria.io) eco system.

This is a work in progress and not yet ready for wider use.

## Installation

To use this repository you have to add it to your Helm installtion:

```
$ helm repo add choria https://choria-io.github.io/helm
$ helm repo update
```

### Required Namespace

It's best to install the Choria components in their own Namespace but Helm cannot create this for you.

By default these Charts assume Namespace `choria`:

```nohighlight
$ kubectl create namespace choria
namespace/choria created
```

### Required Certificate Authority

Where possible the charts will auto enroll their components in a [Cert Manager](https://cert-manager.io/)
manager Certificate Authority.

**WARNING:** Do not use Letsencrypt certificates unless you know what you are doing.

The Certificate Authority you are establishing will be used for various aspects that
are safe to auto enroll, you should have the ability to issue certificates from your CLI
for clients and privileged certificates should you need that. See specific Chart readme files
for details.

The charts that do integrate with the CA all default to `choria-ca` as Issuer name.

The [ca](https://github.com/choria-io/helm/tree/master/charts/ca) chart can create the Issuer, Role, RoleBindings and ServiceAccount needed.

## Charts

|Chart|Description|
|-----|-----------|
|[broker](https://github.com/choria-io/helm/tree/master/charts/broker)|Installs and configure [Choria Broker](https://github.com/choria-io/go-choria)|
|[ca](https://github.com/choria-io/helm/tree/master/charts/ca)|Creates a self hosted CA integrated with [Cert Manager](https://cert-manager.io)|
|[provisioner](https://github.com/choria-io/helm/tree/master/charts/provisioner)|Installs and configure [Choria Provisioner](https://github.com/choria-io/provisioning-agent)|
