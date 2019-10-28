# Windows - Domain Controller Ports

tcp and udp port 445:: for File Replication Service
tcp and udp port 464:: for Kerberos Password Change
tcp and udp port 53:: |
    for DNS from client to domain controller and domain controller to domain
    controller.
tcp port 139 and udp 138:: 'for File Replication Service between domain controllers.'
tcp port 3268 and 3269:: 'for Global Catalog from client to domain controller.'
udp and tcp port 135:: |
    for domain controllers-to-domain controller and client to domain
    controller operations.
udp port 389:: |
    for LDAP to handle normal queries from client computers to the domain
    controllers.
udp port 88:: for Kerberos authentication
