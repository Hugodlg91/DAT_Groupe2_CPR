# Procédure 08 — Tests de sécurité et validation des détections

## Objectif

Valider l'efficacité de la chaîne de détection mise en place (SIEM Wazuh, FIM, IDS/IPS Suricata) en réalisant des actions malveillantes contrôlées et en vérifiant la remontée des alertes correspondantes.

## Périmètre

| Test | Cible | Outil |
|---|---|---|
| Scan de ports | SRV-AD01 (10.0.2.10) | nmap depuis CLT-W11 |
| Échecs d'authentification | SRV-AD01 | net use depuis CLT-W11 |
| Corrélation de reconnaissance | SRV-AD01 | net use + règle 100100 |
| Intégrité fichiers (FIM) | SRV-AD01 (C:\Users) | création de fichier |
| Blocage IDS/IPS | serveur DMZ | curl User-Agent malveillant |

## Prérequis

- SIEM, agents, règles et IPS configurés (procédures 01 à 07).
- Accès à CLT-W11 et au serveur DMZ.

## Test 1 — Scan de ports

### Réalisation

Installation de nmap sur CLT-W11, puis scan complet du contrôleur de domaine :

```powershell
nmap -sV -p- 10.0.2.10
```

### Résultat

Le scan identifie les services caractéristiques d'un contrôleur de domaine Active Directory : 53 (DNS), 88 (Kerberos), 135 (RPC), 139/445 (SMB), 389/636 (LDAP/LDAPS), 464 (kpasswd), 3268/3269 (Global Catalog), 3389 (RDP), 9389 (AD Web Services). Les ports ouverts correspondent aux services attendus ; le reste est filtré.

### Observation importante

Le scan de découverte de ports en lui-même ne génère pas d'alerte de détection. Analyse :

- Wazuh surveille les journaux de l'hôte, pas le trafic réseau : il ne perçoit le scan que par ses effets indirects.
- Suricata écoute sur DMZ et WAN uniquement, pas sur le flux interne entre le VLAN postes et le VLAN serveurs.

Il existe donc un angle mort : la découverte réseau interne entre VLANs n'est couverte par aucune détection. Cet angle mort est traité au test 3.

## Test 2 — Détection d'échecs d'authentification

### Réalisation

Génération d'échecs d'authentification SMB depuis CLT-W11 :

```powershell
for ($i=1; $i -le 5; $i++) {
    net use \\10.0.2.10\C$ /user:fakeuser$i wrongpass 2>&1
    Start-Sleep -Milliseconds 300
}
```

Chaque tentative retourne « Le mot de passe réseau spécifié est incorrect », confirmant un échec d'authentification franc.

### Résultat

Wazuh capte les 5 événements (Event ID Windows 4625) via l'agent de SRV-AD01, règle native 60122 (« Logon Failure »), niveau 5. La source est correctement identifiée (10.0.1.100) dans le champ `data.win.eventdata.ipAddress`.

## Test 3 — Détection de reconnaissance (règle personnalisée)

### Réalisation

La répétition d'échecs rapprochés (test 2) déclenche la règle de corrélation 100100. Vérification dans le dashboard :

```
rule.id:100100
```

### Résultat

Une alerte de niveau 10 « Multiples echecs d'authentification - possible scan ou tentative de reconnaissance » est levée, mappée MITRE ATT&CK T1110. L'angle mort identifié au test 1 (distinction entre échec isolé et tentative de reconnaissance) est ainsi couvert.

## Test 4 — Intégrité des fichiers (FIM)

### Réalisation

Création d'un fichier dans le répertoire surveillé en temps réel sur SRV-AD01 :

```powershell
New-Item C:\Users\test-fim.txt -ItemType File
```

### Résultat

Wazuh génère en temps réel une alerte « File added to the system » (règle 554, niveau 5), avec le chemin exact, le hash SHA256 et le propriétaire du fichier, mappée PCI DSS. La détection en mode temps réel est confirmée.

## Test 5 — Blocage IDS/IPS

### Réalisation

Depuis le serveur DMZ, requête avec un User-Agent correspondant à une signature malware active en blocage :

```bash
curl --max-time 15 -A "nethelper" http://www.example.com
```

### Résultat

La connexion expire sans réponse (`curl: (28) Operation timed out ... with 0 bytes received`), alors que la même URL répond normalement avec un User-Agent neutre. Côté Suricata, l'alerte SID 2002877 apparaît avec l'action « blocked » sur l'interface DMZ. Le blocage IPS est confirmé.

## Nettoyage post-tests

Suppression des artefacts de test sur SRV-AD01 :

```powershell
Remove-Item C:\Users\test-fim.txt
cmdkey /delete:test
```

La suppression du fichier de test génère une dernière alerte FIM « File deleted », confirmant que la surveillance détecte également les suppressions.

## Synthèse des résultats

| Test | Détection attendue | Résultat |
|---|---|---|
| Scan de ports | — (angle mort identifié) | Non détecté directement, traité par règle 100100 |
| Échecs d'authentification | Alerte 60122 niveau 5 | 5 alertes générées |
| Reconnaissance corrélée | Alerte 100100 niveau 10 | Alerte générée |
| Intégrité fichiers | Alerte FIM temps réel | Alerte générée (ajout et suppression) |
| Blocage IPS | Trafic bloqué | Connexion bloquée, action « blocked » |

## Résultat

La chaîne de détection est validée de bout en bout. Les tests confirment le bon fonctionnement du FIM, de la détection d'échecs d'authentification, de la règle de corrélation personnalisée et du blocage IPS. L'angle mort de la découverte réseau interne a été identifié et partiellement comblé par la règle de corrélation, avec une recommandation d'extension de la surveillance réseau interne.
