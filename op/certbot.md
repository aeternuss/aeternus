# Certbot

Certbot is a free, open source software tool for automatically using
Let's Encrypt certificates on manually-administrated websites to enable HTTPS.

## Installation

```bash
dnf install certbot
```

## Command

```bash
-------------------------------------------------------------------------------

  certbot [SUBCOMMAND] [options] [-d DOMAIN] [-d DOMAIN] ...

Certbot can obtain and install HTTPS/TLS/SSL certificates.  By default,
it will attempt to use a webserver both for obtaining and installing the
certificate. The most common SUBCOMMANDS and flags are:

obtain, install, and renew certificates:
    (default) run   Obtain & install a certificate in your current webserver
    certonly        Obtain or renew a certificate, but do not install it
    renew           Renew all previously obtained certificates that are near
expiry
   -d DOMAINS       Comma-separated list of domains to obtain a certificate for

  (the certbot apache plugin is not installed)
  --standalone      Run a standalone webserver for authentication
  (the certbot nginx plugin is not installed)
  --webroot         Place files in a server's webroot folder for authentication
  --manual          Obtain certificates interactively, or using shell script
hooks

   -n               Run non-interactively
  --test-cert       Obtain a test certificate from a staging server
  --dry-run         Test "renew" or "certonly" without saving any certificates
to disk

manage certificates:
    certificates    Display information about certificates you have from Certbot
    revoke          Revoke a certificate (supply --cert-path)
    delete          Delete a certificate

manage your account with Let's Encrypt:
    register        Create a Let's Encrypt ACME account
  --agree-tos       Agree to the ACME server's Subscriber Agreement
   -m EMAIL         Email address for important account notifications

More detailed help:

  -h, --help [TOPIC]    print this message, or detailed help on a topic;
                        the available TOPICS are:

   all, automation, commands, paths, security, testing, or any of the
   subcommands or plugins (certonly, renew, install, register, nginx,
   apache, standalone, webroot, etc.)
-------------------------------------------------------------------------------
```

## Manual

If you’d like to obtain a certificate running certbot on a machine other than your target webserver or
perform the steps for domain validation yourself, you can use the manual plugin.

You can use the plugin to obtain a certificate by specifying `certonly` and `--manual` on the command line.

The manual plugin can use either the `http` or the `dns` challenge.
You can use the `--preferred-challenges` option to choose the challenge of your preference.

```
certbot certonly --manual -d <domain.com> --preferred-challenges dns
```

## Examples

### Wildcard Certificates

If you’d like to obtain a wildcard certificate from Let’s Encrypt or run certbot
on a machine other than your target webserver, you can use one of Certbot’s DNS plugins.


```
certbot certonly -d <domain.com> -d <*.domain.com> \
--manual --preferred-challenges dns --server https://acme-v02.api.letsencrypt.org/directory
```
