# OpenDKIM sur Zimbra

Via la ligne de commande, il y a la possibilité de faire du OpenDKIM sur Zimbra Open Source.

```bash
zimbra@mail:~$ /opt/zimbra/libexec/zmdkimkeyutil -a -d domaine.ch
DKIM Data added to LDAP for domain domaine.ch with selector 0C017E98-7A2B-11E4-B7AE-9B85B51075DA
Public signature to enter into DNS:
0C017E98-7A2B-11E4-B7AE-9B85B51075DA._domainkey IN      TXT     ( "v=DKIM1; k=rsa; "
          "p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDvJg+rj5tni35Z8PoHd7slwHxx0Frzm70BX690ju+cxgrJU/slTt+vMRmecVqhuu8fYhgjvnwYe7d0Sek3+f76+tSdhwrChdipQOURWZoFsEaNTHB3gF/QSxM7Z169JAz1a+u2jeGYXQTpPtrVmuCEd95JnU9kEFgGEkEHVDyEnQIDAQAB" )  ; ----- DKIM key 0C017E98-7A2B-11E4-B7AE-9B85B51075DA for domaine.ch
```

Ensuite, il faut ajouter les informations dans le DNS comme indiqué.

Pour tester si tout fonctionne correctement

```bash
/opt/zimbra/opendkim/sbin/opendkim-testkey -d domaine.ch -s 0C017E98-7A2B-11E4-B7AE-9B85B51075DA -x /opt/zimbra/conf/opendkim.conf
```