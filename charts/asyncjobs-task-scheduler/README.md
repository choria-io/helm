## Choria Asynchronous Jobs Task Scheduler

This Helm chart installs the [Choria Asynchronous Jobs](https://github.com/choria-io/asyncjobs) Task Scheduler used
to support cron-like [Scheduled Task](https://github.com/choria-io/asyncjobs/wiki/Scheduled-Tasks) creation.

## Requirements

### JetStream

You will need a NATS JetStream server such as the one provided by [Choria Streams](choria.io/docs/streams/) or one deployed
using the [NATS Helm Charts](https://github.com/nats-io/k8s).

### Namespace

You need to create a namespace to run the related services in, you could use default but that is not recommended. We'll
assume you created one called `asyncjobs`

```nohighlight
$ kubectl create namespace asyncjobs
```

### NATS Connection Context

You will need username, password, credentials, TLS files and anything else you need for the connection to NATS.

In my case I needed a set of TLS certificates and keys, I store this in a secret called `asyncjobs-tls`.

```nohighlight
$ find asyncjobs/task-scheduler
asyncjobs/task-scheduler/secret
asyncjobs/task-scheduler/secret/tls.crt
asyncjobs/task-scheduler/secret/tls.key
asyncjobs/task-scheduler/secret/ca.crt
$ kubectl -n asyncjobs create secret generic task-scheduler-tls --from-file asyncjobs/task-scheduler/secret
```

You'll see that the chart will mount your secret in `/etc/asyncjobs/secret` so you can reference those in your values later.

In my case the context is made using this:

```
taskScheduler:
  sslSecret: task-scheduler-tls
  context:
    url: nats://broker-broker-ss:4222
    ca: /etc/asyncjobs/secret/ca.crt
    key: /etc/asyncjobs/secret/tls.key
    cert: /etc/asyncjobs/secret/tls.crt
```

Valid keys are: `url`, `token`, `user`, `password`, `creds` (path to a file), `nkey` (path to a file), `cert`, `key`, `ca`,
`jetstream_domain`, `jetstream_api_prefix`, `inbox_prefix`.

## Values

| Variable                  | Description                                                      | Default            |
|---------------------------|------------------------------------------------------------------|--------------------|
| `image.registry`          | Domain name of the docker registry hosting your image            | `docker.io`        |
| `image.repository`        | The docker repository with the image                             | `choria/asyncjobs` |
| `image.tag`               | The tag to deploy                                                | `latest`           |
| `image.pullPolicy`        | The kubernetes pull policy to use                                | `Always`           |
| `image.pullSecret`        | If you need a secret to access a private repository specify here | `""`               |
| `podAnnotations`          | Additional annotations to apply to the pod                       | `{}`               |
| `podLabels`               | Additional labels to apply to the pod                            | `{}`               |
| `prometheus.enabled`      | Add annotations for prometheus discovery                         | `true`             |
| `taskScheduler.replicas`  | How many instances to run                                        | `2`                |
| `taskScheduler.sslSecret` | An optional secret to mount onto `/etc/asyncjobs/secret`         | `""`               |
| `taskScheduler.context`   | A required NATS connection context, see above                    | `{}`               |
