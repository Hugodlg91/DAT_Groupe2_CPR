# Procédure 05 — Règle de corrélation personnalisée (détection de reconnaissance)

## Objectif

Créer une règle de détection personnalisée qui corrèle les échecs d'authentification rapprochés pour lever une alerte de niveau élevé, afin de distinguer une tentative de reconnaissance ou de force brute d'un échec d'authentification isolé.

## Contexte

Les tentatives d'accès échouées sont détectées individuellement par la règle native 60122 (« Logon Failure »), de niveau 5. Prises isolément, ces alertes ne permettent pas de distinguer un simple échec ponctuel d'une attaque par balayage d'authentification. Une règle de corrélation est nécessaire pour qualifier ce comportement.

## Périmètre

| Élément | Valeur |
|---|---|
| Fichier de règles | /var/ossec/etc/rules/local_rules.xml |
| Identifiant de la règle | 100100 |
| Niveau | 10 |
| Déclenchement | 3 échecs (règle 60122) en 120 secondes |
| Mapping | MITRE ATT&CK T1110 (Brute Force) |

## Prérequis

- Manager Wazuh opérationnel.
- Règle native 60122 fonctionnelle (échecs d'authentification Windows détectés).

## Étapes réalisées

### 1. Édition du fichier de règles locales

L'édition est réalisée via l'éditeur de règles intégré au dashboard (Server management → Rules → édition de `local_rules.xml`), ce qui assure la validation de syntaxe et le rechargement automatique des règles après sauvegarde.

### 2. Ajout de la règle de corrélation

Ajout, sous le groupe d'exemple existant, du bloc suivant :

```xml
<group name="local,authentication_failures,attack,">
  <rule id="100100" level="10" frequency="3" timeframe="120">
    <if_matched_sid>60122</if_matched_sid>
    <description>Multiples echecs d'authentification - possible scan ou tentative de reconnaissance</description>
    <group>authentication_failures,pci_dss_10.2.4,pci_dss_11.4,mitre,</group>
    <mitre>
      <id>T1110</id>
    </mitre>
  </rule>
</group>
```

Logique de la règle :

- `if_matched_sid` 60122 : la règle se base sur les déclenchements de la règle native d'échec d'authentification.
- `frequency` 3 et `timeframe` 120 : déclenchement si au moins 3 occurrences surviennent en 120 secondes.
- `level` 10 : niveau élevé permettant la distinction visuelle et le traitement prioritaire.

## Problème rencontré et résolution

### Description

La version initiale de la règle incluait la condition `<same_source_ip />`, destinée à exiger que les échecs proviennent d'une même adresse source. Dans cette configuration, la règle ne se déclenchait pas, malgré la génération d'échecs d'authentification suffisants.

### Diagnostic

L'analyse des événements bruts a révélé que les événements Windows (canal EventChannel) placent l'adresse source dans le champ `data.win.eventdata.ipAddress`, et non dans le champ `srcip` standard que la condition `same_source_ip` interroge pour réaliser la corrélation. La corrélation par adresse source ne pouvait donc pas fonctionner avec ce type d'événement.

### Solution

La condition `<same_source_ip />` a été retirée. La corrélation s'effectue alors sur la fréquence des échecs (3 occurrences en 120 secondes), indépendamment du champ d'adresse source. Le `timeframe` a été porté à 120 secondes pour offrir une marge de déclenchement adaptée au rythme d'un scan.

## Validation

Après sauvegarde et rechargement (message « Cluster reloaded in 1 node »), génération d'échecs d'authentification rapprochés depuis un poste client. L'alerte de niveau 10 « Multiples echecs d'authentification - possible scan ou tentative de reconnaissance » est apparue dans le dashboard (filtre `rule.id:100100`).

## Résultat

La règle 100100 est opérationnelle. Elle transforme une série d'échecs d'authentification isolés en une alerte de reconnaissance qualifiée, de niveau 10, mappée sur le framework MITRE ATT&CK. Cette règle comble un angle mort de détection des tentatives de balayage d'authentification.
