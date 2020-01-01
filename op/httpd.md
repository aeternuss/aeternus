# Apache Httpd

The Apache web server is the most popular way of serving web content on the Internet.

## How to Configure Apache Server

Apache configuration files contain one directive per line. The backslash "\" may be used as the last character on a line to indicate that the directive continues onto the next line.

### Basic directives of Apache Server

#### ServerName

The ServerName directive is used to set the host name of the server, this is how the server identifies itself.

You can set this directive either in the server's configuration or virtual hosts.

This is the only value you need to set to get your server running after installation.

### Listen

The Listen directive tells Apache what IP addresses and/or ports it should listen to for incoming requests.

```config
Listen <port>
Listen <ip_address>:<port>
```

### DocumentRoot

The DocumentRoot directive sets the location of the server's public files, like htdocs. This is the default Apache web server document directory.

### User & Group

It's a good idea to configure Apache to run under a specific user and group instead of root. Ideally, the user and group you set should not be able to login to the server and no login shell.

```bash
groupadd <group>
useradd -d /var/www -g <group> -s /bin/false <user>
```

### ServerRoot

Apache's important files, like the server's configuration, error, and log files are kept at the top of the directory tree. This location is the ServerRoot.

### ErrorLog & LogLevel

When an error occurs, Apache logs the error to a log file. The location of the error log is determined by ErrorLog directive.

The Loglevel directive controls the level of the messages logged in the error logs.

### PidFile

The PidFile directive control the location of the Pid file.

### IncludeOptional

It is possible to seperate server configuration and settings into multiple files. These multiple files can then be includedin the original server config file.

---

## How to Setup Apache Virtual Hosts

Virtual hosts allow one server to host multiple domians or interfaces by using a matching system.

### Running serveral name-based web sites on a single IP address

```httpd
Listen 80

<VirtualHost *:80>
    DocumentRoot "/path/to/dommainname1/document"
    ServerName www.domainname1.com

    # Other directive here
</VirtualHost>

<VirtualHost *:80>
    DocumentRoot "/path/to/domainname2/document"
    Servername www.domainname2.com

    # Other directive here
</VirtualHost>
```

### Name-based hosts on more than one IP address

The server has two IP address. Any request to an address other than 172.20.30.50 will be serverd from the main server.

```httpd
Listen 80

# This is the main server running on IP addr1
ServerName www.addr1.com
DocumentRoot "/path/to/addr1/document"

<VirtualHost 172.20.30.50>
    DocumentRoot "/path/to/domainname1/document"
    ServerName www.domainname1.com

    # Other directive here
</VirtualHost>

<VirtualHost 172.20.30.50>
    DocumentRoot "/path/to/domainname2/document"
    ServerName www.domainname2.com

    # Other directive here
</VirtualHost>
```

### Serving the same content on different IP addresses

```httpd
<VirtualHost 192.168.1.10 172.20.30.10>
    DocumentRoot "/path/to/document"
    ServerName server.domainname.com
    ServerAlias server
</VirtualHost>
```

### Running different sites on different ports

```httpd
Listen 80
Listen 8080

<VirtualHost 172.20.30.40:80>
    ServerName www.domainname1.com
    DocumentRoot "/path/to/domain1-80/document"
</VirtualHost>

<VirtualHost 172.20.30.40:8080>
    ServerName www.domainname1.com
    DocumentRoot "/path/to/domain1-8080/document"
</VirtualHost>

<VirtualHost 172.20.30.40:80>
    ServerName www.domainname2.com
    DocumentRoot "/path/to/domain2-80/document"
</VirtualHost>

<VirtualHost 172.20.30.40:8080>
    ServerName www.domainname2.com
    DocumentRoot "/path/to/domain2-8080/document"
</VirtualHost>
```

### IP-based Virtual hosting

```httpd
Listen80

<VirtualHost 172.20.30.40>
    DocumentRoot "/path/to/addr1/document"
    ServerName www.domainname.com
</VirtualHost>

<VirtualHost 172.20.30.50>
    DocumentRoot "/path/to/addr2/document"
    ServerName www.domainname.com
</VirtualHost>
```

### Mixed port-based, ip-based and name-based Virtual hosts

```httpd
Listen 80
Listen 172.20.30.40:8080
Listen 172.20.30.50:8080

<VirtualHost 172.20.30.40:80>
    DocumentRoot "/path/to/40-80-domain1/document"
    ServerName www.domainname1.com
</VirtualHost>

<VirtualHost 172.20.30.40:80>
    DocumentRoot "/path/to/40-80-domain2/document"
    ServerName www.domainname2.com
</VirtualHost>

<VirtualHost 172.20.30.40:8080>
    DocumentRoot "/path/to/40-8080-domain1/document"
    ServerName www.domainname1.com
</VirtualHost>

<VirtualHost 172.20.30.50:80>
    DocumentRoot "/path/to/50-80/document"
    ServerName www.domainname.com
</VirtualHost>

<VirtualHost 172.20.30.50:8080>
    DocumentRoot "/path/to/50-8080/document"
    ServerName www.domainname.com
</VirtualHost>
```

### Using Virtual_host and mod_proxy together

The following example allows a front-end machine to proxy a virtual host through to server running on another machine.

```httpd
<VirtualHost *:*>
    ServerName www.domainname.com

    ProxyPreserveHost On
    ProxyPass           "/" "http://192.168.111.2/"
    ProxyPassReverse    "/" "http://192.168.111.2/"
</VirtualHost>
```

### Using _default vhosts

`_default_ vhosts for all ports`

Catching every request to any unspecified IP address and port, i.e., an address/port combination that is not used for any other virtual host.

```httpd
<VirtualHost _default:*>
    DocumentRoot "/path/to/document"
</VirtualHost>
```

`_default_ vhosts for different ports`

The default vhost for port 80 (Which must appear before any default vhost with a wildcard port) catches all requests that were sent to an unspecified IP address. The main server is never used to serve a request.

```httpd
<VirtualHost _default_:80>
    DocumentRoot "/www/default80"
    # ...
</VirtualHost>

<VirtualHost _default_:*>
    DocumentRoot "/www/default"
    # ...
```

`_default_ vhosts for one port`

A request to an unspecified address on port 80 is servedfrom the default vhost.

```httpd
<VirtualHost _default_:80>
    DocumentRoot "/www/default"
...
</VirtualHost>
```

`Any use of * in a virtual host declaration will have higher procedence that _default_.`

---

## How to Redirect HTTP to HTTPS on Apache Server

To force all web traffic to use HTTPS, you can also configure your virtual host file.

Normally, there are two important sections of a virtual host configurations if an SSL certificate is enabled;

- The first contains configurations for the non-secure port 80.
- The second is for the secure port 443.

```httpd
## conf.d/http_domainname.conf
<VirtualHost *:80>
   ServerName www.domainname.com
   <Location />
     Redirect permanent / https://www.domainname.com/
   </Location>
</VirtualHost>

## conf.d/https_domainname.conf
<VirtualHost *:443>
   ServerName www.domainname.com
   DocumentRoot /usr/local/apache2/htdocs

   ServerAdmin you@example.com
   ErrorLog logs/ssl_error.log
   TransferLog logs/ssl_access.log

   SSLEngine On
   SSLCertificateFile /etc/ssl/apache2/server.pem
   SSLCertificateKeyFile /etc/ssl/apache2/server.key
# etc...
</VirtualHost>
```

---

## How to Setup Apache Server Working with Subversion Server

Subversion repository can be served by the Apache web server over the HTTP protocol using the modules: `mod_dav_svn.so` and `mod_authz_svn.so`.

### Setup mod_dav_svn

Make sure the module mod_dav_svn has been installed and loaded.

Installing mod_dav_svn:

```bash
yum install mod_dav_svn
```

Loading dav_svn_module, create file dav_svn.conf in httpd config directory (/etc/httpd/conf.d/):

```httpd
## dav_svn.conf
LoadModule dav_svn_module modules/mod_dav_svn.so
LoadModule authz_svn_module modules/mod_authz_svn.so
```

### Configure Apache server

To Configuration SVN, three parts have to setting.

- SVN
- Authentication
- Authoriztion

```httpd
## conf.d/subversion.conf
<VirtualHost *:80>
    ServerName www.domainname.com

    <Location /svn>
        ## 1. SVN configuration
        DAV svn
        SVNParentPath /path/to/svn
        SVNListParentPath On

        ## 2. Authentication
        AuthType Basic
        AuthName "Subversion Repositories"
        Require Valid-user

        ## Auth/LDAP
        AuthBasicProvider ldap
        AuthzLDAPAuthoritative on
        AuthLDAPRemoteUserAttribute uid
        #AuthLDAPBindDN "CN=ldapuser,CN=Users,DC=your,DC=domain"
        #AuthLDAPBindPassword ldappassword
        AuthLDAPURL ldap://your.domain:389/DC=your,DC=domain?uid

        ### Auth/htpasswd file
        #AuthUserFile /path/to/passwd

        ## 3. Authorization
        AuthzSVNAccessFile /path/to/authz
    </Location>
</VirtualHost>
```

---

## Reference

- [Configure Apache Server](https://www.scriptarticle.com/apache-server-configuration-file/)
- [VirtualHost Examples](https://httpd.apache.org/docs/2.4/vhosts/examples.html)
- [How to Redirect HTTP to HTTPS on Apache](https://www.tecmint.com/redirect-http-to-https-on-apache/)
