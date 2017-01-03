# Tips and tricks for Zimbra

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

## Actions sur COS

### Divers

#### Lister les différentes cos

```bash
zmprov gac
```

#### Obtenir l’ID d’une COS spécifique

```bash
zmprov gc « NOM DE LA COS » | grep zimbraId:gac
```

#### Lister les utilisateurs imacté par une COS

```bash
zmprov sa zimbraCOSId=ID DE LA COSgac
```

#### Compter les utilisateurs impacté par une COS

```bash
zmprov sa zimbraCOSId=ID DE LA COS|wc -lgac
```

#### Supprimer les messages dans les queues

A faire en root

```bash
/opt/zimbra/postfix/sbin/postsuper -d ALL deferredgac
```

## Actions sur les boites mails

### Réindexex les boites mails

#### Lancer le reindex sur toutes les boites d'un domain

```bash
for i in `zmprov -l gaa domaine.ch`; do echo "rim $i start" >> /tmp/rim_start.txt; done
zmprov -f /tmp/rim_start.txt
gac
```

#### Voir le status de reindex

```bash
for i in `zmprov -l gaa domaine.ch`; do echo "rim $i status">>   /tmp/rim_status.txt; done
zmprov -f /tmp/rim_status.txt
gac
```

#### Annuler le reindex

```bash
for i in `zmprov -l gaa domaine.ch`; do echo "rim $i cancel">>   /tmp/rim_cancel.txt; done
zmprov -f /tmp/rim_cancel.txt
gac
```

### Partage

#### Donner les accès full au compte zpstmigration sur une mailbox d’un user

```bash
zmmailbox -z -m user@domaine.ch mfg / account zpstmigration@domaine.ch rwixd
gac
```

#### Donner les accès read-only à tout le domaine domaine.ch

```bash
zmmailbox -z -m conference@domaine.ch mfg /  domain domaine.ch r
gac
```

#### Donner les accès full sur la mailbox

```bash
zmmailbox -z -m info@domaine.ch mfg / account utilisateur@domaine.ch rwixd
gac
```

#### Donner permettre la delegation d’envoi d’email pour la mailbox info

```bash
zmprov ma info@domaine.ch +zimbraPrefAllowAddressForDelegatedSender "info@domaine.ch"
gac
```

#### Donner la permission de l’envoi d’email en tant que info

```bash
zmmailbox -z -m utilisateur@domaine.ch grr account info@domaine.ch sendAs
gac
```

### Cool stuff

#### Increasing the Maximum Allowable Attachment Size

By default, this setting is low. Nowadays it’s acceptable to send attachments larger than 10MB (but not obscenely larger). I don’t like it and I discourage my users from sending large attachments via e-mail but if you feel the need to loosen up this restriction, here are the commands to do that:

```bash
su -l zimbra
zmprov ms `zmhostname` zimbraFileUploadMaxSize 20971520
zmprov mcf zimbraFileUploadMaxSize 20971520
zmprov ms `zmhostname` zimbraMailContentMaxSize 20971520
zmprov mcf zimbraMailContentMaxSize 20971520
zmprov mcf zimbraMtaMaxMessageSize 20971520
zmmtactl restart
20971520 = 20MB in bytes.
gac
```

#### Disabling the Spam Filter

Sometimes it might be desirable to disable spam filtering across an entire domain or COS. For example, if you pay a 3rd party service to do your spam filtering for you.

```bash
zmprov md domain.tld +amavisBannedFilesLover TRUE
zmprov md domain.tld +amavisSpamLover TRUE
gac
```

The first command turns off all filetype filtering for the domain “domain.tld” while the second turns off all spam filtering. If you wanted to do this on a per-account basis, you’d do this:

```bash
zmprov ma user@domain.tld +amavisBannedFilesLover TRUE
zmprov ma user@domain.tld +amavisSpamLover TRUE
gac
```

“ma” stands for “manage account” and “md” stands for “manage domain”. This is used to specify which type of object you are editing/managing. To reverse these changes you would just change the “+” to a “-” in the previous commands or change the “TRUE” to “FALSE”. My understanding is that this:

```bash
zmprov ma user@domain.tld -amavisBannedFilesLover TRUE
zmprov ma user@domain.tld -amavisSpamLover TRUE
Accomplishes the same exact thing that this does:
gac
```

```bash
zmprov ma user@domain.tld +amavisBannedFilesLover FALSE
zmprov ma user@domain.tld +amavisSpamLover FALSE
gac
```

Now, it’s also possible to completely disable spam and virus filtering, here’s how to do it:

```bash
zmprov -l ms `zmhostname` -zimbraServiceEnabled antivirus
zmprov -l ms `zmhostname` -zimbraServiceEnabled antispam
gac
```

However, if you do this, you will end up with an ugly “***UNCHECKED***” tag inserted into the subject line of every e-mail. To get rid of that you’ll need to edit /opt/zimbra/amavisd/sbin/amavisd and change the following value:

```bash
$undecipherable_subject_tag = '***UNCHECKED*** ';
gac
```

to:

```bash

$undecipherable_subject_tag = '';
gac
```

And then restart Zimbra:

```bash
/etc/init.d/zimbra restart
gac
```

Enabling RBLs

```bash
zmprov mcf zimbraMtaRestriction "reject_rbl_client cbl.abuseat.org" zimbraMtaRestriction "reject_rbl_client bl.spamcop.net" zimbraMtaRestriction "reject_rbl_client dnsbl.sorbs.net" zimbraMtaRestriction "reject_rbl_client sbl.spamhaus.org" zimbraMtaRestriction "reject_rbl_client relays.mail-abuse.org"
gac
```

This will enable the following RBLs:

* cbl.abuseat.org
* bl.spamcop.net
* dnsbl.sorbs.net
* sbl.spamhaus.org
* relays.mail-abuse.org

To see which zimbraMtaRestriction options are enabled:

```bash
zmprov gacf | grep zimbraMtaRestriction
gac
```

You can also add/remove RBLs from the administration console; you’ll find the option under Configure->Global Settings->MTA in the “DNS Checks” section. I haven’t found how how to remove a single RBL via the CLI without wiping out the whole list

#### Archiving/exporting/importing a user’s inbox

This is handy if you want to move a user from one server to another, or if you need to export and archive the mailbox of a user who no longer exists.

```bash
zmmailbox -z -m user@domain.tld getRestURL "//?fmt=tgz" > /tmp/user_inbox.tar.gz
gac
```

Then, to import to another server:

```bash
zmmailbox -s -m user@domain.tld postRestURL "//?fmt=tgz&resolve=reset" /tmp/user_inbox.tar.gz
gac
```

#### Working with grants

Retrieve grants for a user’s folder (Calendar, in this example):

```bash
zmmailbox -z -m user@domain gfg /Calendar
gac
```

Grant read only access to user1@domain’s calendar to user2@domain

```bash
zmmailbox -z -m user1@domain mfg /Calendar account user2@domain r
gac
```

Remove all grants to user2@domain on user1@domain’s Calendar

```bash
zmmailbox -z -m user1@domain mfg /Calendar account user2@domain ''
gac
```

Permissions are represented by the following letters: r, w, i, x, d, a

* (r)ead – search, view overviews and items
* (w)rite – edit drafts/contacts/notes, set flags
* (i)nsert – copy/add to directory, create subfolders action
* (x) – workflow actions, like accepting appointments
* (d)elete – delete items and subfolders, set \Deleted flag
* (a)dminister – delegate admin and change permissions

So if you wanted to give all rights to user2@domain from the previous example, you’d replace the ‘r’ with ‘rwixda’.

#### Working with mountpoints

Mount “/Inbox/Shared Data” from user1@domain.tld’s account to “/Inbox/User1 Shared Data” on user2@domain.tld’s account:

```bash
zmmailbox -z -m user2@domain.tld cm "/Inbox/User1 Shared Data" user1@domain.tld "/Inbox/Shared Data"
gac
```

To delete the mountpoint*:

```bash
zmmailbox -z -m user2@domain.tld df "/Inbox/User1 Shared Data"
gac
```

*Be extremely careful when doing this! Make sure that you are deleting the mountpoint and not the source directory (in the example above, this would be the “/Inbox/Shared Data” directory on user1@domain.tld’s account)

#### Enabling the Dumpster

The dumpster feature allows users (and more importantly, admins) to recover deleted messages. There are four settings that control this behavior:

* **zimbraDumpsterEnabled** – TRUE/FALSE determines whether the dumpster feature is enabled
* **zimbraDumpsterPurgeEnabled** – TRUE/FALSE determines whether users can empty/purge their dumpster
* **zimbraDumpsterUserVisibleAge** – nd where n is the number of days you’d like to allow users to view/recover the messages stored in the dumpster.
* **zimbraMailDumpsterLifetime** – nd where n is the number of days you’d like to keep items stored in the dumpster before automatically purging them.

Let’s say for example, you want to keep all deleted messages (for legal/auditing purposes) for two years and you don’t want the users to be able to purge the messages they’ve deleted. You’d run a command similar to this one (as the zimbra user):

```bash
zmprov mc default zimbraDumpsterEnabled "TRUE" zimbraDumpsterPurgeEnabled "FALSE" zimbraDumpsterUserVisibleAge "1d" zimbraMailDumpsterLifetime "730d"
gac
```

This will enable the dumpster for the ‘default’ COS; disable purging; allow users to see the messages in their dumpster less than a day old; and keep messages in the dumpster for two years (730 days). This is just an example, of course but it should provide a good understanding as to how to use these options.

#### Listing all user accounts for a domain

```bash
zmprov -l gaa domain.com
gac
```

#### Setting a password from the command line

```bash
zmprov sp user@domain 'b3%356sf^578685'
gac
```

#### Enable local authentication fallback (useful for using both LDAP and local authentication simultaneously)

```bash
zmprov md domain.tld zimbraAuthFallbackToLocal TRUE
zmcontrol restart
gac
```

#### Getting a list of all folders for an account

```bash
zmmailbox -z -m user@domain.tld gaf
gac
```

#### Get a list of message IDs for the first 1000 messages in “/OLD Mail/Inbox” and save them to a file

```bash
zmmailbox -z -m user@domain.tld search -t message -l 1000 'in:"/Old Mail/Inbox"' | awk '{print $2}' | sed -e '1,4d' | tr '\n' ',' | sed -e 's/,,//g' > messageids.txt 
gac
```

Then, do something with those messages; in this example, we’re going to move them to “/To Be Deleted”:

```bash
zmmailbox -z -m user@domain.tld mm `cat messageids.txt` "/To Be Deleted"
gac
```

#### Raise the number of items that Zimbra Desktop or the Zimbra Web Client will display per page

```bash
zmprov ma user@domain.tld zimbraPrefMailItemsPerPage 500
gac
```

Zimbra will only allow any single user account to have 10000 contacts total, this is how you raise that limit

```bash
zmprov ma user@domain.tld zimbraContactMaxNumEntries 20000
gac
```

*Note: Before you do this, take some time to examine whether it’s really necessary. Make sure the account doesn’t have a bunch of duplicate contacts.

#### List all contacts for an account

```bash
zmmailbox -z -m user@domain.tld gact
gac
```

#### List all contacts for an account and save the IDs to a file

```bash
zmmailbox -z -m user@domain.tld gact | grep 'Id: [0-9].*$' | tr '\n' ',' | sed -e 's/Id: //g' -e 's/,$//g' > contactids.txt
gac
```

Then, do something with those contact IDs; in this example we’re going to delete them:

```bash
zmmailbox -z -m user@domain.tld dct `cat contactids.txt`
gac
```

#### Route a user’s e-mail to another mail server

```bash
zmprov ma user@domain.tld zimbraMailTransport smtp:someothermailhost.domain.tld:25
gac
```

… or set a user’s mail transport back to the default setting:

```bash
zmprov ma user@domain.tld zimbraMailTransport lmtp:domain.tld:7025
gac
```