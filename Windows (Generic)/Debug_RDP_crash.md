# Create a dump file for mstsc.exe crash

## Registry

```Registry
Windows Registry Editor Version 5.00
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\Windows Error Reporting\localdumps\mstsc.exe]
"DumpFolder"=hex(2):63,00,3a,00,5c,00,63,00,72,00,61,00,73,00,68,00,64,00,75,\
  00,6d,00,70,00,73,00,00,00
"DumpCount"=dword:00000010
"DumpType"=dword:00000001
"CustomDumpFlags"=dword:00000000
```

## Links

* http://msdn.microsoft.com/en-US/windows/desktop/bg162891
* http://blogs.technet.com/b/askperf/archive/2007/05/29/basic-debugging-of-an-application-crash.aspx

## Windbg

```Windbg
SRV*c:\WINDOWS\symbols*http://msdl.microsoft.com/download/symbols
!analyze -v
lmvm
```