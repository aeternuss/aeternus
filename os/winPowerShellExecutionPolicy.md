# Windows - PowerShell Execution Policy

By default, PowerShell restricts running scripts on end user PCs.

## Execution Policies

Windows PowerShell has four different execution policies:

- **Restricted** - No scripts can be run. Windows PowerShell can be used only in interactive mode.
- **AllSigned** - Only scripts signed by a trusted publisher can be run.
- **RemoteSigned** - Downloaded scripts must be signed by a trusted publisher before they can be run.
- **Unrestricted** - No restrictions; all Windows PowerShell scripts can be run.
- **Undefined** - No execution policy has been set.

## Get Execution Policy

1. Open PowerShell.
2. Type or copy-paste the following command and press the Enter key.

```powershell
Get-ExecutionPolicy -List
```

## Set Execution Policy

1. Open PowerShell as administrator.
2. Execute the following command.

```powershell
Set-ExecutionPolicy Unrestricted -Scope MachinePolicy\|UserPolicy\|Process\|CurrentUser\|LocalMachine [-Force]
```

## Run a process with temporary Policy

1. Open a command prompt or PowerShell.
2. Launch the powershell.exe file with the -ExecutionPolicy Unrestricted argument. For example,

```powershell
Powershell.exe -ExecutionPolicy Unrestricted -File c:\data\test.ps1
```

## Reference

- [How to Change PowerShell Execution Policy in Windows 10](https://winaero.com/blog/change-powershell-execution-policy-windows-10/)
