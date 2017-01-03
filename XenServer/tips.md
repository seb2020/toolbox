# Xen CLI

## Startup and shutdown a VM

```bash
xe vm-start vm={vm name}
xe vm-shutdown vm={vm name}
```

## Get VM name

```bash
xe vm-list
```

## Get version

```bash
[root@raq200 ~]# cat /etc/xensource-inventory
PRIMARY_DISK='/dev/disk/by-id/ata-WDC_WD2000FYYZ-01UL1B1_WD-WMC1P0130319'
DOM0_VCPUS='8'
PRODUCT_VERSION='7.0.0'
DOM0_MEM='2048'
CONTROL_DOMAIN_UUID='84ecf009-19ec-4033-9bf9-458f3d421581'
XEN_VERSION='4.6.1'
MANAGEMENT_ADDRESS_TYPE='IPv4'
KERNEL_VERSION='3.10.96'
COMPANY_NAME_SHORT='Citrix'
PARTITION_LAYOUT='ROOT,BACKUP,LOG,BOOT,SWAP,SR'
PRODUCT_VERSION_TEXT='7.0'
INSTALLATION_UUID='3f113c86-3bc6-4c22-bcf9-af1d78b2080a'
LINUX_KABI_VERSION='3.10.0+10'
PRODUCT_BRAND='XenServer'
BRAND_CONSOLE='XenCenter'
PRODUCT_VERSION_TEXT_SHORT='7.0'
MANAGEMENT_INTERFACE='xenbr0'
PRODUCT_NAME='xenenterprise'
STUNNEL_LEGACY='true'
BUILD_NUMBER='125380c'
PLATFORM_VERSION='2.1.0'
PLATFORM_NAME='XCP'
BACKUP_PARTITION='/dev/disk/by-id/ata-WDC_WD2000FYYZ-01UL1B1_WD-WMC1P0130319-part2'
INSTALLATION_DATE='2016-07-28 20:26:59.820624'
COMPANY_NAME='Citrix Systems, Inc.'
```

## Add HD to physical server

```bash
xe host-list                         # to get host UUID
xe sr-create host-uuid=<host UUID> shared=false type=lvm \
   content-type=user device-config:device=/dev/sdb1 name-label="Another disk"
```

## Get snapshot

```bash
xe snapshot-list
```

## Take snapshot

```bash
xe vm-list
xe vm-snapshot new-name-label="Before update kernel" vm=UUID-vm
```

## Restore snapshot

```bash
xe snapshot-list
xe snapshot-revert snapshot-uuid=UUID-snapshot
```
