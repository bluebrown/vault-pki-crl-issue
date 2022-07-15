# Vault PKI CRL Issue

This project provides an automated way to reproduce an issue regarding the vault PKI CRL.

## Start

Use docker compose to start vault and nginx. The init container take care of initializing the pki, and providing the certificates to nginx.

```bash
docker compose up -d
./script/client-cert.sh
curl -k https://localhost:8443 --cert client/client.crt --key client/client.key
```

## CRL Error

After making the request, the following error can be observed in the nginx logs.

```bash
docker logs vault-pki-test-nginx-1 2>&1 | grep 'client SSL certificate verify error'
```

```bash
2022/07/15 20:01:48 [info] 31#31: *1 client SSL certificate verify error:
(3:unable to get certificate CRL) while reading client request headers, client: 192.168.96.1, server:
localhost, request: "GET / HTTP/1.1", host: "localhost:8443"
```

The client certificate verification works as expected if no CRL is used. This can be tested by commeting out the respective directive in the [nginx.conf](./nginx/nginx.conf).

```console
ssl_crl /etc/nginx/certificates/intermediate.crl.pem;
```

## PKI

The pki is created with the [pki script](./script/pki.sh). The script follows the steps described in the tutorial: <https://learn.hashicorp.com/tutorials/vault/pki-engine>.
