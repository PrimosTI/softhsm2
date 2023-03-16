# Sharing HSM tokens to another host over network with SSH

Sometimes may be useful to share the HSM (Hardware Security Module) token remotely. This can be done exposing the token
via a [Unix Domain Socket] by running `p11-kit server` command on the `ghcr.io/primosti/softhsm2` container. Then, the
token can be accessed by using the PKCS #11 module `p11-kit-client.so` to connect to this socket on the client side.

This is useful, for example, to protect a key material available to other applications in another hosts, maintaining
these materials isolated and protected. As example, consider the following scenarios:

- Connect to a SSH server using a key material;
- Stablish a mutual TLS connection using a key material;
- Store certificates and keys available to applications running on other hosts;

Normally, on this scenarios, when a key material is needed, these keys are stored in a file (encrypted by a password -
*I hope*) and the application accesses the file to read the key material (with the password). This is not safe, because
the key material can be exposed, if the application is compromised. With a PKCS #11 token, the key material access is
protected by a PIN and the application can only operate with the key material, not reading it.

## How to share the token over network with SSH

Once the [Unix Domain Socket] has been shared by the `p11-kit server` command, this socket can be accessed remotely by
another container wrapping it in a TCP socket. All we need is a TCP listener service that will receive the remote
connection and forward the traffic to the socket.

Although, PKCS #11 implements the PIN code to protect the token against unauthorized access, this measure is not enough
to protect the token over network traffic. It is necessary to protect the token access with a secure channel.

This example covers a solution to protect the shared token over a secure channel using SSH protocol. Two services
and a client container were implemented to exemplify this scenario:

The following diagram illustrates how that interaction works:

![share-token-diagram]

|Service / Files|Description|
|-|-|
|**client**|A container that accesses the shared token over network.|
|<nobr>[/etc/pkc11/modules/p11-ssh-connect.conf](services/client/etc/pkcs11/modules/p11-kit-ssh-connect.module)</nobr>|PKCS #11 module configuration file, to automatically connect to the shared token over network. This permits to some tools to access the token without any configuration. Read [GnuTLS: PKCS #11 Initialization] and [pkcs11.conf(5)]|
|<nobr>[/srv/bin/p11-kit-ssh-connect.sh](services/client/srv/bin/p11-kit-ssh-connect.sh)</nobr>|Script to connect to the shared token over network.|
|<nobr>*[/srv/keys](../volumes/keys/)*</nobr>|Directory where are stored the keys for the SSH connection. This keys are shared to example purposes only.|
|**hsm**|The container that has access to the HSM (Hardware Security Module) and shares the token through a [Unix Domain Socket].|
|<nobr>[/srv/data/tokens](../volumes/data/tokens/)</nobr>|Directory where SoftHSMv2 uses as backend to store token objects. Note: The */srv/data* directory is a volume mouted to persist the token data.|
|<nobr>[/srv/run/sockets/token1.sock](services/hsm/volumes/sockets/)</nobr>|The socket that shares the token. Note: The */srv/run/sockets* directory is a volume that is shared with the *proxy* container.|
|**proxy**|The service that listens for SSH connections and forwards traffic to [Unix Domain Socket].|
|<nobr>[/srv/bin/p11-kit-ssh-proxy.sh](services/proxy/srv/bin/p11-kit-ssh-proxy.sh)</nobr>|Script to listen for SSH connections to forward traffic to the shared [Unix Domain Socket].|
|<nobr>[/srv/run/sockets/token1.sock](services/hsm/volumes/sockets/)</nobr>|The socket that shares the token. Note: The */srv/run/sockets* directory is a volume that is shared with the *hsm* container.|
|<nobr>*[/srv/keys](../volumes/keys/)*</nobr>|Directory where are stored the keys for the SSH connection. This keys are shared to example purposes only.|

## How to test this solution

1. First, run the solution containers.

```sh
docker compose up
```

2. Then, access the `client` container shell.

```sh
docker exec -it client ash
```

3. Then, from the `client` container shell, operate on the token.

```sh
# You can use "p11tool" to operate with the token.
# Use "p11tool --help" to see all available options.
#
# For example, to list the available tokens:
p11tool --list-tokens
```

## Security considerations

**Warning:** Sharing the token remotely can have security implications. Take security measures to protect the token from
unauthorized access.

Some security measures includes:

- Use strong Security Officer (SO) PIN and User PIN to protect the token.
- Define a specific user and group for the container.
- Set the permissions of the exposed socket to be accessible only by a specific user and group.
- When sharing the token over network, use a secure connection with mutual authentication (e.g. TLS).
- Protect the access to the SoftHSMv2 storage. Read more about [SoftHSMv2 storage internals].

> YOU MUST ANALYZE YOUR OWN SCENARIO AND TAKE THE APPROPRIATE SECURITY MEASURES, BY YOUR OWN RISK.

# License

Copyright © 2023 Primos TI

Licensed under the MIT License. See LICENSE in the project root for license information.


[Unix Domain Socket]: https://man7.org/linux/man-pages/man7/unix.7.html
[SoftHSMv2 storage internals]: https://xakcop.com/post/softhsmv2/
[share-token-diagram]: diagram.png "Sharing HSM tokens to another host over network with SSH"
[GnuTLS: PKCS #11 Initialization]: https://www.gnutls.org/manual/html_node/PKCS11-Initialization.html
[pkcs11.conf(5)]: https://man.archlinux.org/man/pkcs11.conf.5.en