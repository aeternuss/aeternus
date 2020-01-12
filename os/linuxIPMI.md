# Linux - IPMI

## Kernel Modules

The following kernel modules must be loaded on a 2.6-based kernel in order for ipmitool to work:

- ipmi_msghandler
  > Incoming and outgoing message handler for IPMI interfaces.
- ipmi_si 
  > An IPMI system interface driver for the message handler. This
  > module supports various IPMI system interfaces such as KCS, BT,
  > SMIC, and even SMBus in 2.6 kernels.
- ipmi_devintf
  > Linux character device interface for the message handler.

## ipmitool

### User Management

BMC default has tow user:
- user id: 1, hidden user
- user id: 2, ADMIN

Privilege level:
- 2: user
- 3: Operator
- 4: Administrator

List User:

  ```bash
  ipmitool -H <BMC_IP> -I lanplus -U <BMC_USER> -P <BMC_PASSWORD> user list <ChannelNo>
  ```

Add User:

  ```bash
  ipmitool -H <BMC_IP> -I lanplus -U <BMC_USER> -P <BMC_PASSWORD> user set name <user id> <username>
  ```

Set User password:

  ```bash
  ipmitool -H <BMC_IP> -I lanplus -U <BMC_USER> -P <BMC_PASSWORD> user set password <user id> <password>
  ```

Set User Privilege:

  ```bash
  ipmitool -H <BMC_IP> -I lanplus -U <BMC_USER> -P <BMC_PASSWORD> user priv <user id> <privilege level> <ChannelNo>
  ```

Enable/Disable User:

  ```bash
  ipmitool -H <BMC_IP> -I lanplus -U <BMC_USER> -P <BMC_PASSWORD> user enable/disable <user id>
  ```

### Network Configuration

- Print Network Information

  ```bash
  ipmitool -H <BMC_IP> -I lanplus -U <BMC_USER> -P <BMC_PASSWORD> lan print <ChannelNo>
  ```

- Set Network Mode

  ```bash
  ipmitool -H <BMC_IP> -I lanplus -U <BMC_USER> -P <BMC_PASSWORD> lan set <ChannelNo> ipsrc <static/dhcp>
  ```

- Set IPAddress

  ```bash
  ipmitool -H <BMC_IP> -I lanplus -U <BMC_USER> -P <BMC_PASSWORD> lan set <ChannelNo> ipaddr <IPAddress>
  ```

- Set NetMask

  ```bash
  ipmitool -H <BMC_IP> -I lanplus -U <BMC_USER> -P <BMC_PASSWORD> lan set <ChannelNo> netmask <NetMask>
  ```

- Set Default Gateway

  ```bash
  ipmitool -H <BMC_IP> -I lanplus -U <BMC_USER> -P <BMC_PASSWORD> lan set <ChannelNo> defgw ipaddr <defaultGW>
  ```
