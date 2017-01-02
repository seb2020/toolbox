# Tips and tricks for Zimbra

## CLI

Get all COS
```bash
zmprov gac
```

Get specific ID from a COS
```bash
zmprov gc "COS name" | grep zimbraId:
```

Get all users from a COS
```bash
zmprov sa zimbraCOSId=XXXX
```

## GAL

Force sync
```bash
zmprov gds galsync@domain.ch
# name zimbra 
# type gal objectClass: zimbraDataSource 
objectClass: zimbraGalDataSource 
zimbraCreateTimestamp: 20130420203714Z 
zimbraDataSourceEnabled: TRUE 
zimbraDataSourceFolderId: 257 
zimbraDataSourceId: b8b900f9-6525-4bbb-8ea0-f7a81f552025 
zimbraDataSourceName: zimbra 
zimbraDataSourcePollingInterval: 15m 
zimbraDataSourceType: gal 
zimbraGalLastSuccessfulSyncTimestamp: 20131218093029Z 
zimbraGalStatus: enabled 
zimbraGalType: zimbra

zmgsautil forcesync -a galsync@domain.ch -n zimbra
```