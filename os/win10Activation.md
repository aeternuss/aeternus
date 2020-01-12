# Win10 Activation

Make sure the os or office is VOL version.

## Serial Number

- Professional KMS: W269N-WFGWX-YVC9B-4J6C9-T83GX
- Enterprise KMS: NPPR9-FWDCX-D2C8J-H872K-2YT43
- Home KMS: TX9XD-98N7V-6WMQ6-BX7FG-H8Q99
- Education KMS: NW6C2-QMPVW-D7KKK-3GKT6-VCFB2

## Active

```powershell
slmgr /upk
# use corrent sn
slmgr /ipk W269N-WFGWX-YVC9B-4J6C9-T83GX
slmgr /skms kms.03k.org
slmgr /ato
```

## Office

```powershell
cd "C:\Program Files (x86)\Microsoft Office\Office16"
cscript ospp.vbs /inpkey:XQNVK-8JYDB-WJ9W3-YJ8YR-WFG99
cscript ospp.vbs /sethst:kms.03k.org
cscript ospp.vbs /act
```

## Check version

```powershell
wmic os get caption
```

## KMS Server

- kms.03k.org
- zh.us.to
- kms.library.hk
