# BIND

## Create a Basic Zone File

A zone file holds the DNS resource records for all of the domain names
associated with the zone.

Zone files store all of the data served by a DNS server.

The basic format of the zone file is a time to live (TTL) field followed
by the start of authority (SOA) records.

### TTL field

TTL defines the duration in seconds that the record may be cached by
client side programs.

```
$TTL 86400
$TTL 1440m
$TTL 24h
$TTL 1d
```

### SOA section

The SOA section is an intimidating chunk of code for the uninitiated,
but each field in the SOA has a meaningful purpose.

The SOA starts with:

- the zone's primary domain name
- the class of the zone (IN)
- SOA
- the following seven fields in order:
  - MNAME, The master dns server for the zone
  - RNAME, An email address for someone responsible for the domain
  - Serial number
  - Refresh
  - Retry
  - Expire
  - Negative caching TTL

An example:

```
$TTL 12h
@ IN SOA ns1.aeternus.cc mail.aeternus.cc (
     2004010402  ;Serial
     1h          ;Refresh
     15m         ;Retry
     4w          ;Expire
     1h          ;Minimum TTL
)
```

## Record examples

### Address Records

This record maps an IP Address to a hostname.

```
www      IN    A      1.2.3.4
```

This can be used to point subdomain to some other server IP like:

```
my-subdomain      IN    A      2.2.3.5
```

This is also used for pointg your nameservers to IP address, for example:

```
ns1 14400 IN A 1.2.3.4
ns2 14400 IN A 1.2.4.5
```

### CNAME

Used to create an alias from an existing A record.

```
mail     IN    CNAME  www
www      IN    A      1.2.3.4
```

### SRV

The theory behind SRV is that given a known domain name e.g.
example.com, a given service e.g. web (http) which runs on tcp in this
case, a DNS query may be issued to find the host name that provides such
on behalf of the domain - and which may or may not be within the domain.

```
_service._protocolName  IN SRV priority weight portNO subdns.domain.com

_ldap._tcp.example.com.    SRV 0 0 389 ldap.example.net.
_ldap._tcp.dc._msdcs.example.com. SRV 0 0 389 dc1.example.com.
```

## Reference

- [Bind DNS Record examples](http://forum.centos-webpanel.com/dns/bind-dns-record-examples/)
- [CentOS 7 : DNS Server](https://www.server-world.info/en/note?os=CentOS_7&p=dns)
