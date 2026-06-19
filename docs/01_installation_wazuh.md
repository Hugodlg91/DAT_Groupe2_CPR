# Procédure 01 — Installation et vérification du SIEM Wazuh

## Objectif

Mettre en service le SIEM Wazuh en installation all-in-one (manager, indexer et dashboard sur une seule machine) sur le serveur SRV-WAZUH, et vérifier que l'ensemble des services est opérationnel.

## Périmètre

| Élément | Valeur |
|---|---|
| Machine | SRV-WAZUH |
| IP | 10.0.2.20 (VLAN 20 — Serveurs) |
| OS | Debian |
| Version Wazuh | 4.14.5 |
| Type d'installation | all-in-one |

## Prérequis

- Système d'exploitation installé et accessible en SSH.
- Accès root sur la machine.
- Accès réseau sortant pour le téléchargement des paquets Wazuh.

## Étapes réalisées

### 1. Connexion à la machine

Connexion SSH au serveur via la passerelle de virtualisation :

```bash
ssh -J root@<passerelle> root@10.0.2.20
```

### 2. Lancement du script d'installation all-in-one

Téléchargement et exécution du script officiel d'installation :

```bash
curl -sO https://packages.wazuh.com/4.x/wazuh-install.sh
bash wazuh-install.sh -a
```

L'option `-a` réalise une installation complète (manager + indexer + dashboard) sur la même machine. La durée d'installation est de l'ordre de 10 à 15 minutes.

### 3. Récupération des identifiants

À la fin de l'installation, le script génère les identifiants d'administration. Ils sont affichés en fin de console et stockés dans l'archive `wazuh-install-files.tar` générée dans le répertoire courant. Le mot de passe du compte `admin` y est conservé.

### 4. Accès au dashboard

Le dashboard est accessible en HTTPS sur le port 443 de la machine :

```
https://10.0.2.20
```

L'accès depuis un poste d'administration se fait via un tunnel SSH redirigeant le port local 8443 vers le port 443 du serveur :

```bash
ssh -L 8443:10.0.2.20:443 root@<passerelle>
```

Puis dans le navigateur : `https://localhost:8443`.

### 5. Vérification de l'état des services

Vérification que les composants principaux sont actifs :

```bash
systemctl status wazuh-manager
systemctl status wazuh-indexer
systemctl status wazuh-dashboard
```

Les trois services doivent être en état `active (running)`. La version du manager est confirmée en 4.14.5.

## Point d'attention rencontré

Le changement du mot de passe du compte `admin` n'est pas réalisable directement depuis l'interface graphique : ce compte est réservé et la modification doit passer par l'outil en ligne de commande prévu à cet effet :

```bash
/usr/share/wazuh-indexer/plugins/opensearch-security/tools/wazuh-passwords-tool.sh
```

Cette particularité est notée pour toute opération ultérieure de rotation des identifiants.

## Résultat

Le SIEM Wazuh est installé et opérationnel : manager, indexer et dashboard actifs, version 4.14.5, dashboard accessible et fonctionnel. La plateforme est prête à recevoir les agents.
