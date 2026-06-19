# Procédure 04 — Configuration des règles de détection et du FIM

## Objectif

Vérifier le chargement des règles de détection, configurer la surveillance d'intégrité des fichiers (FIM) sur le contrôleur de domaine, et définir les seuils d'alerte du SIEM.

## Périmètre

| Élément | Valeur |
|---|---|
| Manager | SRV-WAZUH (10.0.2.20) |
| Cible FIM | SRV-AD01 (10.0.2.10) |
| Répertoire surveillé ajouté | C:\Users (temps réel) |
| Seuil d'enregistrement | niveau 3 |
| Seuil de notification email | niveau 12 |

## Prérequis

- Agent Wazuh actif sur SRV-AD01 (voir procédure 02).
- Accès au dashboard et au manager.

## Étapes réalisées

### 1. Vérification du ruleset chargé

Contrôle des fichiers de règles chargés par le manager :

```bash
ls /var/ossec/ruleset/rules/ | wc -l
```

Le jeu de règles complet est présent (168 fichiers de règles), incluant notamment les règles génériques système et syslog ainsi que le mapping MITRE ATT&CK. La présence des fichiers attendus (règles OSSEC de base, règles syslog) est confirmée.

### 2. Configuration du FIM sur SRV-AD01

La configuration de l'agent surveille déjà de façon ciblée les répertoires système critiques. Ajout de la surveillance en temps réel du répertoire des profils utilisateurs, zone sensible d'un contrôleur de domaine.

Dans la configuration de l'agent SRV-AD01, dans le bloc `<syscheck>` :

```xml
<directories check_all="yes" realtime="yes">C:\Users</directories>
```

- `check_all="yes"` : contrôle l'ensemble des attributs (taille, propriétaire, permissions, hash).
- `realtime="yes"` : détection en temps réel des modifications, sans attendre le prochain cycle de scan.

### 3. Définition des seuils d'alerte

Dans le fichier `/var/ossec/etc/ossec.conf` du manager, vérification et ajustement des seuils dans le bloc `<alerts>` :

```xml
<alerts>
  <log_alert_level>3</log_alert_level>
  <email_alert_level>12</email_alert_level>
</alerts>
```

- Seuil d'enregistrement à partir du niveau 3 : couvre les échecs d'authentification (niveau 5), les modifications de fichiers critiques (niveau 7) et les escalades de privilèges (niveau 10).
- Seuil de notification réservé au niveau 12 (alertes critiques uniquement), pour éviter le bruit.

### 4. Validation et application

Application de la séquence sûre :

```bash
/var/ossec/bin/wazuh-analysisd -t
systemctl restart wazuh-manager
```

## Résultat

Le ruleset complet est chargé et opérationnel. La surveillance d'intégrité est active sur les répertoires sensibles de SRV-AD01, dont C:\Users en temps réel. Les seuils d'alerte sont définis pour enregistrer les événements pertinents et ne notifier que les incidents critiques.
