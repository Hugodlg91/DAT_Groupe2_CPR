# Procédure 03 — Auto-surveillance du SIEM et enrichissement FIM

## Objectif

Mettre en place la supervision du serveur Wazuh par lui-même et étendre la surveillance d'intégrité des fichiers (FIM) à sa propre configuration et à ses règles, afin de détecter toute tentative d'altération ou de contournement de l'outil de supervision.

## Périmètre

| Élément | Valeur |
|---|---|
| Machine | SRV-WAZUH |
| IP | 10.0.2.20 |
| Composant | Module syscheck (FIM) + agent interne 000 |
| Fichier modifié | /var/ossec/etc/ossec.conf |

## Prérequis

- SIEM Wazuh opérationnel (voir procédure 01).
- Accès root sur SRV-WAZUH.

## Incident rencontré et résolution

### Description de l'incident

La première approche envisagée consistait à installer un agent Wazuh classique sur le serveur lui-même, comme sur les autres machines :

```bash
apt install wazuh-agent
```

Cette commande a entraîné la **désinstallation du paquet wazuh-manager**. Sur une installation all-in-one, les paquets `wazuh-agent` et `wazuh-manager` sont mutuellement exclusifs : l'installation de l'un provoque le retrait de l'autre.

### Conséquence secondaire

Le retrait puis la réinstallation du manager a provoqué un désalignement du mot de passe de l'utilisateur d'API interne (`wazuh-wui`), se traduisant par une erreur 401 à l'ouverture du dashboard.

### Résolution

1. Restauration du manager :

```bash
apt remove wazuh-agent
apt install wazuh-manager
```

2. Réalignement du mot de passe de l'utilisateur d'API via l'API de sécurité (obtention d'un jeton avec le compte interne, puis mise à jour de l'utilisateur), et report de la même valeur dans le fichier de configuration du dashboard :

```
/usr/share/wazuh-dashboard/data/wazuh/config/wazuh.yml
```

3. Redémarrage des services concernés.

### Méthode correcte retenue

L'auto-surveillance ne nécessite pas d'agent séparé. Le manager dispose nativement d'un agent interne (identifiant 000). La supervision du serveur se fait donc via cet agent interne et le module de contrôle d'intégrité, sans installer de paquet supplémentaire.

## Étapes réalisées (méthode retenue)

### 1. Sauvegarde de la configuration

Réflexe systématique avant toute modification :

```bash
cp /var/ossec/etc/ossec.conf /var/ossec/etc/ossec.conf.bak-$(date +%F)
```

### 2. Enrichissement de la surveillance d'intégrité

Ajout, dans le bloc `<syscheck>` du fichier `/var/ossec/etc/ossec.conf`, de la surveillance de la configuration et des règles du SIEM :

```xml
<directories report_changes="yes" check_all="yes">/var/ossec/etc</directories>
<directories check_all="yes">/var/ossec/ruleset</directories>
```

L'attribut `report_changes="yes"` permet de journaliser le détail des modifications apportées aux fichiers surveillés.

### 3. Validation de la syntaxe

Vérification de la configuration avant redémarrage :

```bash
/var/ossec/bin/wazuh-analysisd -t
```

Le test doit retourner une confirmation de configuration valide.

### 4. Application

Redémarrage du manager pour prendre en compte la nouvelle configuration :

```bash
systemctl restart wazuh-manager
```

## Procédure sûre de modification (à réutiliser)

Toute modification de configuration Wazuh suit désormais la séquence : **sauvegarde → validation `wazuh-analysisd -t` → redémarrage**. Cette discipline évite les interruptions de service liées à une erreur de syntaxe.

## Résultat

Le serveur Wazuh se supervise lui-même via son agent interne (000). La surveillance d'intégrité couvre sa propre configuration et ses règles. Toute modification des fichiers de configuration ou des règles est désormais détectée et journalisée.
