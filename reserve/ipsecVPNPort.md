# IPSec VPN Port

Behind a Firewall
=================

following ports need to be opened (bidirectional) on this firewall to
allow VPN traffic to pass through: -

For PPTP: \* IP Protocol=TCP, TCP Port number=1723 &lt;- Used by PPTP
control path \* IP Protocol=GRE (value 47) &lt;- Used by PPTP data path

For L2TP: \* IP Protocol Type=UDP, UDP Port Number=500 &lt;- Used by
IKEv1 (IPSec control path) \* IP Protocol Type=UDP, UDP Port Number=4500
&lt;- Used by IKEv1 (IPSec control path) \* IP Protocol Type=ESP (value
50) &lt;- Used by IPSec data path

For SSTP: \* IP Protocol=TCP, TCP Port number=443 &lt;- Used by SSTP
control and data path

For IKEv2: \* IP Protocol Type=UDP, UDP Port Number=500 &lt;- Used by
IKEv2 (IPSec control path) \* IP Protocol Type=UDP, UDP Port Number=4500
&lt;- Used by IKEv2 (IPSec control path) \* IP Protocol Type=ESP (value
50) &lt;- Used by IPSec data path

If RRAS server is directly connected to Internet, then you need to
protect RRAS server from the Internet side (i.e. only allow access to
the services on the public interface that isaccessible from the Internet
side). This can be done using RRAS static filters or running Windows
Firewall on the public interface (or the interface towards the Internet
side). In this scenario following ports need to be opened
(bidirectional) on RRAS box to allow VPN traffic to pass through

For PPTP: \* IP Protocol=TCP, TCP Port number=1723 &lt;- Used by PPTP
control path \* IP Protocol=GRE (value 47) &lt;- Used by PPTP data path

For L2TP: \* IP Protocol Type=UDP, UDP Port Number=500 &lt;- Used by
IKEv1 (IPSec control path) \* IP Protocol Type=UDP, UDP Port Number=4500
&lt;- Used by IKEv1 (IPSec control path) \* IP Protocol Type=UDP, UDP
Port Number=1701 &lt;- Used by L2TP control/data path \* IP Protocol
Type=50 &lt;- Used by data path (ESP)

For SSTP: \* IP Protocol=TCP, TCP Port number=443 &lt;- Used by SSTP
control and data path

For IKEv2: \* IP Protocol Type=UDP, UDP Port Number=500 &lt;- Used by
IKEv2 (IPSec control path) \* IP Protocol Type=UDP, UDP Port Number=4500
&lt;- Used by IKEv2 (IPSec control path) \* IP Protocol Type=UDP, UDP
Port Number=1701 &lt;- Used by L2TP control/data path \* IP Protocol
Type=50 &lt;- Used by data path (ESP)

Reference
=========

-   [IPSec VPN
     Port](https://blogs.technet.microsoft.com/rrasblog/2006/06/14/which-ports-to-unblock-for-vpn-traffic-to-pass-through/)
