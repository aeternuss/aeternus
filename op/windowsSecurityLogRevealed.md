# The Windows Security Log Revealed

Audit Policies
==============

Windows uses 9 audit policy categories and 50 audit policy subcategories
to give you more-granular control over which information is logged.

Audit Policy Categories
-----------------------

9 audit policy categories:

-   Audit account logon events
-   Audit logon events
-   Audit account management
-   Audit directory service access
-   Audit object access
-   Audit policy change
-   Audit privilege use
-   Audit process tracking
-   Audit system events

Audit Policy Subcategories
--------------------------

The big advantage of using subcategories is the ability to limit the
number of events that result from the related category, thus reducing
(though not eliminating) unnecessary noise.

Get audit policy:

    auditpol /get /category:*

    auditpol /get /subcategory:*

### Audit: Force audit policy subcategory

But by default, subcategory settings will take effect only if the
top-level policy is undefined.

However, you can reverse this behavior by **enabling** the **Audit:
Force audit policy subcategory** settings (Windows Vista or later) to
override audit policy category settings security option

Top-Level Auditing
------------------

### Audit Account Logon Events

On DCs, this policy tracks all attempts to log on with a domain user
account, regardless of the attempt’s origination. On a workstation or
member server, the policy records any logon attempt that uses a local
account that is stored in the computer’s Security Account Manager (SAM).

The policy has four subcategories:

-   Credential Validation
-   Kerberos Authentication Service
-   Kerberos Service Ticket Operations
-   Other Account Logon Events

### Audit Logon Events

The Audit logon events audit policy actually controls the Logon/Logoff
category. The policy’s main objective is to record all attempts to use
either a domain account or a local account to log on to or off of the
local computer.

The policy has nine subcategories:

-   Logon
-   Logoff
-   Account Lockout
-   IPsec Main Mode
-   IPsec Quick Mode
-   IPsec Extended Mode
-   Special Logon
-   Other Logon/Logoff Events
-   Network Policy Server

### Audit Process Tracking

This policy’s primary purpose is to track each program that is executed
by either the system or by end users.

The policy has four subcategories:

-   Process Creation
-   Process Termination
-   DPAPI Activity
-   RPC Events

### Audit Object Access

Auditing access to all objects that reside outside of AD.

Furthermore, to audit access to an object such as a crucial file, you
must enable more than just this policy; you must also enable auditing
for the specific objects that you want to track.

The policy has 11 subcategories:

-   File System
-   Registry
-   Kernel Object
-   SAM
-   Certification Services
-   Application Generated
-   Handle Manipulation
-   File Share
-   Filtering Platform Packet Drop
-   Filtering Platform Connection
-   Other Object Access Events

### Audit Account Management

Monitor changes to user accounts and groups, is valuable for auditing
the activity of administrators and Help desk staff.

On DCs, the policy logs changes to domain users, domain groups, and
computer accounts.

On member servers, the policy logs changes to local users and groups.

The policy has six subcategories:

-   User Account Management
-   Computer Account Management
-   Security Group Management
-   Distribution Group Management
-   Application Group Management
-   Other Account Management Events

### Audit Directory Service Access

Provide a low-level audit trail of changes to objects in AD.

By using this policy, you can identify exactly which fields of a user
account, or any other AD object, were accessed.

The policy has four subcategories:

-   Directory Service Access
-   Directory Service Changes
-   Directory Service Replication
-   Detailed Directory Services Replication

### Audit Privilege Use

Tracks the exercise of user rights. Usually recommend that you leave it
disabled.

The policy has three subcategories:

-   Sensitive Privilege Use
-   Non Sensitive Privilege Use
-   Other Privilege Use Events

### Audit Policy Change

Notify you of changes to important security policies on the local
system.

The policy has six subcategories (one of which has the same name as the
top-level policy):

-   Audit Policy Change
-   Authentication Policy Change
-   Authorization Policy Change
-   MPSSVC Rule Level Policy Change
-   Filtering Platform Policy Change
-   Other Policy Change Events

### Audit System Events

The policy has five subcategories:

-   Security State Change
-   Security System Extension
-   Security Integrity Events
-   IPsec Driver Events
-   Other System Events

Understanding Authentication and Logon
======================================

Audit account logon events would be better named **Audit authentication
events**.

When you use a domain account to log on to a computer, you might expect
the event to be logged on the DC.

In reality, the logon occurs on the workstation or server that you are
accessing.

Therefore, the event is logged in that computer’s Security log—if Audit
logon events is enabled on that system.

Without DCs logging authentication activity, completing an audit trail
of domain-user logon activity is impossible: You would need to collect
the Security logs from every workstation and server on your network!

Local and Domain Accounts
-------------------------

Windows supports two kinds of user accounts: **domain accounts** and
**local accounts** as shown below.

Local accounts are stored in the SAM of member servers and workstations
and are authenticated by the local system.

Domain accounts are stored in AD and are authenticated by DCs.

![image](/image/windowsSecurityLogRevealed-01.png)

Logon Types
-----------

Logon vs. Authentication
------------------------

A user can use of a domain account to log on interactively, after which
the user accesses a shared folder through a network logon as shown in
the diagram below.

![image](/image/windowsSecurityLogRevealed-02.png)

A user can also use a local account to log on to the same two computers
as shown below.

![image](/image/windowsSecurityLogRevealed-03.png)

Account Logon Events
====================

When you enable these policies on a DC, all domain account
authentication that occurs on that DC will be logged.

NTLM Events
-----------

Windows logs **event ID 4776** for NTLM authentication activity (both
Success and Failure).

Failure

:   ! Error Code: 0x0

Kerberos Events
---------------

Failure

:   Event\_ID: 4768 AND ! Error Code: 0x0

Failure

:   Event\_ID: 4771

Event ID
--------

Logon/Logoff Events
===================

Track all logon sessions for the local computer.

Logon Events
------------

Event ID

:   4624, 4625

![image](/image/windowsSecurityLogRevealed-04.png)

Logon/Logoff events on a system give you a complete record of all
attempts to access that computer, regardless of the type of account
used.

------------------------------------------------------------------------

Event ID

:   4634, 4647

Detailed Tracking Events
========================

The category’s primary purpose is to give you the ability to track
programs that are executed on the system and to link those process
events to logon sessions that are reported by Logon/Logoff events and to
file access events that are generated by the Object Access category.

Process Creation
----------------

Process Termination
-------------------

DPAPI Activity
--------------

The DPAPI Activity subcategory reports activity concerning the DPAPI.

Per Microsoft: "The Data Protection API (DPAPI) helps to protect data in
Windows 2000 and later operating systems. DPAPI is used to help protect
private keys, stored credentials (in Windows XP and later), and other
confidential information that the operating system or a program wants to
keep confidential.

Object Access Events
====================

In addition to tracking files, you can track Success and Failure access
attempts on folders, services, registry keys, and printer objects.

Activating Object Access auditing is a two-step procedure.

-   First, enable the Audit object access policy on the system that
    contains the objects that you want to monitor.
-   Second, select specific objects and define the types of access you
    want to monitor.

Note that all five of these categories share the same event IDs for
object open, access, close, and delete events. Therefore, it’s important
that you filter events based not just on event ID but on subcategory as
well.

Object Access Auditing
----------------------

Several common audit goals have corresponding audit settings.

To determine the name of the deleted object, you must correlate the
Handle ID(event ID 4660) with other events (i.e., event IDs 4656, 4663,
and 4658).

Think about the most important objects you have and which access you are
looking for. Then, begin selectively auditing objects.

Account Management Events
=========================

Track maintenance of user, group, and computer objects in AD as well as
to track local users and groups in member server and workstation SAMs.

AD supports two types of groups: distribution and security.

-   

    Distribution groups

    :   serve as distribution lists (DLs) for Microsoft Outlook and
        Microsoft Exchange Server users. These groups are irrelevant to
        security; you can’t grant permissions or rights to distribution
        groups or use them for any security-related purpose.

-   

    Security groups

    :   as the name indicates, are used to grant or deny access; for
        what it’s worth, security groups can also be used as
        distribution groups.

A group is also configured to be one of four scopes.

A group’s scope determines the computers on which the group can be used
to control access and the types of users and groups that can be members
of the group.

Directory Service Access Events
===============================

Directory Service Access events make low-level auditing available for
all types of objects in AD. Directory Service Access events not only
identify the object that was accessed and by whom but also document
exactly which object properties were accessed.

First, you must enable the audit policy at the system level, then
activate auditing on the specific objects you want to monitor.

To enable auditing on an AD object, do the following:

-   Right-click an object in the MMC Active Directory Users and
    Computers snap-in and select Properties.
-   Select the Security tab in the Properties dialog box. (If you don’t
    see the Security tab, click View and then check Advance Features)
-   Click Advanced.
-   Select the Auditing tab in the Advanced Security Settings dialog
    box.
-   Specify the permissions that you want to audit when users request
    access to the object.

Directory Service Changes
-------------------------

Limiting Auditing for Some Attributes
-------------------------------------

You can selectively disable auditing for certain object attributes.

In this case, you can set the attribute’s searchFlags property to
**0x100** to prevent that attribute from being audited: Launch ADSI Edit
and connect to the Schema Naming Context.

Change Control Monitoring for AD
--------------------------------

-   Tracking Changes to Administrator Authority in AD
-   Tracking Changes to Group Policy

Privilege Use Events
====================

The Privilege Use category logs two events.

Policy Change Events
====================

Provides notification of changes to important security policies on the
local system, such as to the system’s audit policy or, in the case of
DCs, trust relationships.

System Events
=============

Provide an eclectic mix of events that are relevant to security.

Audit Policy
============

Reference
=========

-   [The Windows Security Log
    Revealed](https://www.ultimatewindowssecurity.com/securitylog/book/Default.aspx)
-   [Security Log
    Encyclopedia](https://www.ultimatewindowssecurity.com/securitylog/encyclopedia/default.aspx)
