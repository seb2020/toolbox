# How to rename a Zimbra Domain

```bash
zmprov -l renamedomain satom-monthey.ch satomsa.ch
```
# Warning 

Attention si ressources dans le domaine !!!! Il faut d'abord les mettre dans un autre domaine et ensuite les redéplacer dans le nouveau.
* https://bugzilla.zimbra.com/show_bug.cgi?id=47159
* https://bugzilla.zimbra.com/show_bug.cgi?id=46499#c14

Sinon :

```bash
[] WARN: handleEntry(encountered invalid entry type):entry=[meetingroom1@olddomain]
[] WARN: handleEntry(encountered invalid entry type):entry=[meetingroom2@olddomain]
[] WARN: handleEntry(encountered invalid entry type):entry=[projector@olddomain]
ERROR: account.DOMAIN_NOT_EMPTY (domain not empty: olddomain (remaining entries: [uid=projector,ou=people,dc=olddomain] [uid=meetingroom2,ou=people,dc=olddomain] [uid=meetingroom1,ou=people,dc=olddomain] ...)) (cause: com.zimbra.cs.ldap.LdapException$LdapContextNotEmptyException context not empty - unable delete: subordinate objects must be deleted first)L'ancien domaine et le nouveau sont en "Shutdown". Impossible de faire des changements.Pour enlever le mode "Shutdown"zmprov -l md olddomain zimbraDomainRenameInfo ''zmprov -l md olddomain zimbraDomainStatus activezmprov fc domain oldomainEnsuite, depuis la console déplacer de domaine les ressources. Relancer le rename. Et redeplacer les ressources
```