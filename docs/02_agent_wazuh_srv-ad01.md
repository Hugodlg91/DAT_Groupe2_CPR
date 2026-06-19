# Procédure 02 — Déploiement de l'agent Wazuh sur SRV-AD01

## Objectif

Déployer un agent Wazuh sur le contrôleur de domaine SRV-AD01 afin de remonter ses journaux de sécurité Windows vers le SIEM et permettre sa supervision.

## Périmètre

| Élément | Valeur |
|---|---|
| Machine | SRV-AD01 |
| IP | 10.0.2.10 (VLAN 20 — Serveurs) |
| OS | Windows Server 2022 |
| Rôle | Contrôleur de domaine cyna.local |
| Manager Wazuh | 10.0.2.20 |
| ID agent obtenu | 001 |

## Prérequis

- SIEM Wazuh opérationnel (voir procédure 01).
- Accès administrateur sur SRV-AD01.
- Flux réseau autorisé entre l'agent et le manager sur les ports 1514/UDP et 1515/TCP.

## Étapes réalisées

### 1. Génération de la commande de déploiement depuis le dashboard

Dans le dashboard Wazuh, section de déploiement d'un nouvel agent, sélection des paramètres :

- Système d'exploitation : Windows.
- Adresse du manager : 10.0.2.20.
- Nom de l'agent : SRV-AD01.

Le dashboard génère une commande PowerShell complète intégrant le téléchargement du paquet MSI et l'enregistrement auprès du manager.

### 2. Installation de l'agent sur SRV-AD01

Connexion en RDP à SRV-AD01 via tunnel SSH :

```bash
ssh -L 13389:10.0.2.10:3389 root@<passerelle>
```

Puis connexion RDP sur `localhost:13389`.

Exécution dans une console PowerShell en administrateur de la commande générée, de la forme :

```powershell
Invoke-WebRequest -Uri <url_msi> -OutFile $env:tmp\wazuh-agent.msi
msiexec.exe /i $env:tmp\wazuh-agent.msi /q WAZUH_MANAGER="10.0.2.20" WAZUH_AGENT_NAME="SRV-AD01"
```

### 3. Démarrage du service

Démarrage du service de l'agent :

```powershell
NET START WazuhSvc
```

### 4. Vérification de l'enregistrement

Dans le dashboard Wazuh, section Agents, l'agent SRV-AD01 apparaît avec l'identifiant 001 et le statut Active. La version de l'agent correspond à celle du manager (4.14.5).

## Résultat

L'agent Wazuh est déployé et actif sur SRV-AD01 (ID 001, statut Active). Les journaux de sécurité Windows du contrôleur de domaine sont désormais collectés et analysés par le SIEM.
