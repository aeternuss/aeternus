# Exchange Admin Audit log

Exchange has an administrator audit log function that provides flexible
and comprehensive logging of all changes to configuration, policy, and
access control settings of the Exchange environment.

In Exchange, all configuration changes (including those performed in the
Exchange Management Console or the web-based Exchange Control Panel) are
executed as PowerShell commands.

With the Exchange administrator audit log you can detect:

-   Exports of mailboxes
-   Copies of entire mailbox databases
-   Security configuration changes to Exchange
-   Access control changes to groups, roles, and permissions
-   Modifications to Exchange policies involving retention, mobile
    device policy, information rights management, federation, and more

Configuration
=============

In Exchange, all administrative, configuration and policy operations are
ultimately performed via PowerShell cmdlet:

    Set-AdminAuditLogConfig -AdminAuditLogEnabled $true -AdminAuditLogCmdlets * -AdminAuditLogAgeLimit 120.00:00:00

Storage
=======

The Exchange administrator audit log is not a normal text file based log
or a Windows event log.

Administrator audit log events are stored as email messages inside a
special audit mailbox.

Query
=====

-   Search-AdminAuditLog:

        Search-AdminAuditLog  -Cmdlets New-SendConnector -StartDate 10/07/2015 -EndDate 11/1/2015

-   New-AdminAuditLogSearch:

        New-AdminAuditLogSearch -Name "Mailbox Changes" -Cmdlets Set-Mailbox -StartDate 10/07/2015 -EndDate 11/01/2015 -StatusMailRecipients mailbox@example.com

LOGbinder for Exchange
======================

Exchange logs collection tool.

:   [LOGbinder for
    Exchange™](https://www.logbinder.com/products/logbinderex/)

Reference
=========

-   [Exchange Administrator Audit
    Logging](https://www.ultimatewindowssecurity.com/exchange/adminaudit/default.aspx)
