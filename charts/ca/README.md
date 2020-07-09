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
works well. Cert Manager also supports integrating with Vault. There's a full EasyRSA example at the bottom of this page.

You should pick a CA that's easy to issue Certificates from as depending on your use case you'll have to issue a
number of additional certs using the tools of the CA.

Once you have a CA certificate and key, place them in a directory:

```nohighlight
$ find ca
ca
ca/tls.key
ca/tls.crt
```

And create a Kubernetes Secret:

```nohighlight
$ kubectl -n choria create secret generic choria-ca --from-file ca
secret/choria-ca created
```

At this point we can install the CA Issuer, Role, RoleBinding and ServiceAccount.

```nohighlight
$ helm install --namespace choria ca choria/ca 
```

### EasyCA Example

Below an example of creating a Root CA and an Intermediate CA, the Intermediate will be uploaded to Kubernetes and used
to provision Choria instances

#### Create the Root CA

This CA called `offline` is the Root CA and should be kept offline or on an encrypted volume.

```
$ EASYRSA_PKI=offline easyrsa init-pki
$ EASYRSA_PKI=offline easyrsa build-ca
Using SSL: openssl LibreSSL 2.6.5

Enter New CA Key Passphrase:
Re-Enter New CA Key Passphrase:
Generating RSA private key, 2048 bit long modulus
......+++
......................+++
e is 65537 (0x10001)
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Common Name (eg: your user, host, or server name) [Easy-RSA CA]:Example Root CA

CA creation complete and you may now import and sign cert requests.
Your new CA certificate file for publishing is at:
offline/ca.crt
```

Next we create a `choria` CA, signed by the `offline` CA:

```
$ EASYRSA_PKI=choria easyrsa init-pki
$ EASYRSA_PKI=choria easyrsa build-ca subca
Using SSL: openssl LibreSSL 2.6.5

Enter New CA Key Passphrase:
Re-Enter New CA Key Passphrase:
...
-----
Common Name (eg: your user, host, or server name) [Easy-RSA CA]:Choria CA

NOTE: Your intermediate CA request is at choria/reqs/ca.req
and now must be sent to your parent CA for signing. Place your resulting cert
at choria/ca.crt prior to signing operations.
```

Now we sign the `choria` CA using `offline`:

```
$ EASYRSA_PKI=offline easyrsa import-req choria/reqs/ca.req choria
Using SSL: openssl LibreSSL 2.6.5

The request has been successfully imported with a short name of: choria
You may now use this name to perform signing operations on this request.
$ EASYRSA_PKI=offline easyrsa sign-req ca choria
...
subject=
    commonName                = Choria CA


Type the word 'yes' to continue, or any other input to abort.
  Confirm request details: yes
...
Write out database with 1 new entries
Data Base Updated

Certificate created at: offline/issued/choria.crt

$ cp offline/issued/choria.crt choria/ca.crt
```

Next we prepare the Kubernetes Issuer:

```
$ mkdir issuer
$ openssl rsa -in ./choria/private/ca.key -out issuer/tls.key
Enter pass phrase for ./choria/private/ca.key:
writing RSA key
$ cp ./choria/ca.crt issuer/tls.crt
$ find issuer
issuer
issuer/tls.key
issuer/tls.crt
```

We add the CA as a secret to Kubernetes

```
$ kubectl -n choria create secret generic choria-ca --from-file issuer
$ kubectl -n choria get secrets
NAME                  TYPE                                  DATA   AGE
choria-ca             Opaque                                2      8s
```

**Very Importantly remove the unencrypted CA from your disk**

```
$ rm -rf issuer
```
