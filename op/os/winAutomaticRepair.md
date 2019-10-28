# Windows - How to Enable or Disable Automatic Repair

| If you PC crashes 2 times consecutively or fails to boot,
| Windows 10 will run Automatic Repair by default during the next
  startup in an attempt to diagnose and fix your PC.

Enable or Disable Automatic Repair
==================================

Do this command:

``` {.sourceCode .PowerShell}
bcdedit /set {default} recoveryenabled No
```

Similar is

``` {.sourceCode .PowerShell}
bcdedit /set {current} recoveryenabled No
```

They can be the same if you are booted into the default load, so default
would equal current.
