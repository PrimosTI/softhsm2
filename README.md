# Virtual PKCS #11 Module SoftHSMv2 by Primos TI

This project maintain a container images for [SoftHSMv2] and tools to manage that module.

- Maintained by: <br> [Primos TI]
- License: <br> [MIT](LICENSE)

## What is SoftHSMv2?

SoftHSMv2 is an implementation of a cryptographic store accessible through a PKCS #11 interface. You can use it to
explore PKCS #11 without having a Hardware Security Module. It is being developed as a part of the OpenDNSSEC project.

For more information about SoftHSMv2 please visit the main project on [SoftHSMv2].

## What is PKCS #11?

PKCS #11 is a Public-Key Cryptography Standard that defines a standard method to access cryptographic services from
tokens/devices such as hardware security modules (HSM), smart cards, etc.

# How to use this image

## Initializing a new token

1. First run the container.

```sh
docker run --name softhsm2 -i -t ghcr.io/primosti/softhsm2 ash
```

2. Then initialize a new token from the container's interactive shell:

```sh
softhsm2-util --init-token --free --label "Your token label"
```

## Persistent storage

If you remove the container all your data will be lost, and the next time you run the image the store will be
reinitialized. To avoid this loss of data, you should mount a volume that will persist even after the container is
removed. Backup can thus be done as a regular file copy.

All of the tokens and their objects are stored in the location given by `/srv/config/softhsm2.conf` (defaults to:
`/srv/data/tokens`).

To persist the tokens store, you should mount the tokens data directory like:

1. Create a data directory on a suitable volume on your host system, e.g. `/var/softhsm/tokens`.

2. Start your `softhsm2` container like this:

```sh
docker run --name softhsm2 -i -t -v /var/softhsm/tokens:/srv/data/tokens ghcr.io/primosti/softhsm2 ash
```

## Container directory structure

```text
/srv/                   - container's service directory.
├─ config/              - configuration directory.
│  └─ softhsm2.conf     - configuration file for SoftHSMv2.
├─ data/                - data directory for SoftHSMv2.
└─ run/                 - XDG runtime directory (for `p11-kit server`).

/usr/lib/pkcs11/        - PKCS #11 modules directory.
└─ p11-kit-client.so    - PKCS #11 module library to access tokens exposed by
                          `p11-kit server`.

/usr/local/lib/softhsm/ - SoftHSMv2 library directory.
└─ libsofthsm2.so       - SoftHSMv2 PKCS #11 module library.
```

These paths can be changed by setting the environment variables `SOFTHSM2_CONF`, `XDG_RUNTIME_DIR` and `softhsm2.conf`
file.

## Environment variables

### `SOFTHSM2_CONF`

The path to the configuration file for SoftHSMv2. Default: `/srv/config/softhsm2.conf`.

### `XDG_RUNTIME_DIR`

XDG Base Directory for runtime files (for `p11-kit server`). Default: `/srv/run`.

## Tools

### SoftHSMv2 tools

`softhsm2-dump-file`: A tool for dumping the contents of a token file.

`softhsm2-keyconv`: A tool for converting keys between different formats.

`softhsm2-util`: The main tool for managing tokens and objects in SoftHSMv2.

### PKCS #11 tools

The following tools are installed and configured to use SoftHSMv2 PKCS #11 module by default on the container:

`p11-kit`: Tool for operating on configured PKCS #11 modules.

`p11-kit server`: Run a server process that exposes PKCS #11 module remotely via a Unix socket.

`p11tool`: Tool for operating on PKCS #11 modules.

`openssl`: Cryptography toolkit configured to use SoftHSMv2 PKCS #11 module. To use it, add `-engine pkcs11` to the
command line.

#### Examples

```sh
# Show all current slots on SoftHSMv2
softhsm2-util --show-slots

# Initialize a new token on SoftHSMv2
softhsm2-util --init-token --free --label "soft-token-1"

# Generate a new private key (also may use: --generate-rsa with --bits)
p11tool --login --generate-ecc --curve secp256r1 --id 100001 --label "key-1" "pkcs11:token=soft-token-1"

# List all objects
p11tool --list-all

# Show key content
p11tool --export "pkcs11:token=soft-token-1;object=key-1;type=public" | openssl ec -pubin -in /dev/stdin -text

# Generate a self-signed certificate with OpenSSL using the key stored in SoftHSMv2
# (to save the certificate file, removes "-text" and add "-out <file>" angument)
openssl req -x509 -new -text -subj "/CN=Sample Certificate" -days 365 -engine pkcs11 -keyform engine -key 100001
```

# How to build this image

## Build and run

1. On the project (where is the Dockerfile) directory, build the image.

```sh
docker build --tag softhsm2 .
```

2. Run the container.

```sh
docker run --name softhsm2 -i -t softhsm2 ash
```

## Build with a specific version of tools

### SoftHSMv2

To use a specific version of SoftHSMv2, set the following build arguments:

- `SOFTHSM2_VERSION`: The version of SoftHSMv2 to use. Default: `2.6.1`.

Or specify the url of the source tarball:

- `SOFTHSM2_SOURCE`: The url of the source tarball. Default: `https://github.com/opendnssec/SoftHSMv2/archive/${SOFTHSM2_VERSION}.tar.gz`.

```text
Copyright (c) 2010 .SE, The Internet Infrastructure Foundation
                   http://www.iis.se

Copyright (c) 2010 SURFnet bv
                   http://www.surfnet.nl/en

All rights reserved.
```

For more information about SoftHSMv2 please visit the main project on [SoftHSMv2]

### OpenSC libp11

To use a specific version of OpenSC libp11, set the following build arguments:

- `LIBP11_VERSION`: The version of OpenSC to use. Default: `0.4.12`.

Or specify the url of the source tarball:

- `LIBP11_SOURCE`: The url of the source tarball. Default: `https://github.com/OpenSC/libp11/releases/download/libp11-${LIBP11_VERSION}/libp11-${LIBP11_VERSION}.tar.gz`.

```text
Copyright (c) The OpenSC libp11 Project https://github.com/OpenSC/libp11
```

For more information about libp11 please visit the main project on [libp11].

# How to share the token remotely

Sometimes may be useful to share the token remotely. For example, to use it in another container, or to use it in a
different host. This can be done exposing the token via a [Unix Domain Socket] by running `p11-kit server` command on
the `ghcr.io/primosti/softhsm2` container. Then, the token can be accessed by using the PKCS #11 module
`p11-kit-client.so` to connect to this socket on the client side.

## Security considerations

**Warning:** Sharing the token remotely can have security implications. Take security measures to protect the token from
unauthorized access.

Some security measures include:

- Use strong Security Officer (SO) PIN and User PIN to protect the token.
- Define a specific user and group for the container.
- Set the permissions of the exposed socket to be accessible only by a specific user and group.
- When sharing the token over network, use a secure connection with mutual authentication (e.g. TLS).
- Protect the access to the SoftHSMv2 storage. Read more about [SoftHSMv2 storage internals].

> YOU MUST ANALYZE YOUR OWN SCENARIO AND TAKE THE APPROPRIATE SECURITY MEASURES, BY YOUR OWN RISK.

## Sharing the token examples

There are some examples of how to share the token remotely, for different cases:

- [Sharing tokens to the host applications](docs/share-token-to-host.md).
- Sharing tokens to another containers on the same host (soon).
- Sharing tokens to another host over network (soon).
- Sharing tokens over a web API (soon).

# License

Copyright © 2023 Primos TI

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

[Primos TI]: https://www.primosti.com.br
[libp11]: https://github.com/OpenSC/libp11
[SoftHSMv2]: https://github.com/opendnssec/SoftHSMv2
[Unix Domain Socket]: https://man7.org/linux/man-pages/man7/unix.7.html
[SoftHSMv2 storage internals]: https://xakcop.com/post/softhsmv2/
