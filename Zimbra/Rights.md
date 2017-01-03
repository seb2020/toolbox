# 

## Donner les accès full au compte zpstmigration sur une mailbox d’un user
```bash
zmmailbox -z -m user@domaine.ch mfg / account zpstmigration@domaine.ch rwixd
```

## Donner les accès read-only à tout le domaine  domaine.ch
```bash
zmmailbox -z -m calendrier@domaine.ch mfg /  domain domaine.ch r
```

## Donner les accès full sur la mailbox
```bash
zmmailbox -z -m ecoles@domaine.ch mfg / account prenom.nom@domaine.ch rwixd
```

## Donner permettre la delegation d’envoi d’email pour la mailbox « ecoles »
```bash
zmprov ma ecoles@domaine.ch +zimbraPrefAllowAddressForDelegatedSender "ecoles@domaine.ch"
```

## Donner la permission de l’envoi d’email en tant que « ecoles »
```bash
zmmailbox -z -m prenom.nom@domaine.ch grr account ecoles@domaine.ch sendAs
```


Vérifier dans la console d'admin Zimbra que l'ACL a bien été mise sur le compte