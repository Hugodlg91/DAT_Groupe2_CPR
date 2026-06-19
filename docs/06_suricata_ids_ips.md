# Procédure 06 — Déploiement de Suricata (IDS puis IPS) sur OPNsense

## Objectif

Mettre en place la détection d'intrusion réseau avec Suricata sur le pare-feu OPNsense, en mode détection (IDS) dans un premier temps, puis basculer en mode prévention (IPS, blocage actif) sur les interfaces exposées.

## Périmètre

| Élément | Valeur |
|---|---|
| Pare-feu | OPNsense (fw-opn01.cyna.local) |
| Interfaces surveillées | DMZ, WAN |
| Mode initial | IDS (capture PCAP) |
| Mode final | IPS (capture Netmap) |
| Rulesets | ET Open (Emerging Threats) |

## Prérequis

- Accès administrateur à l'interface OPNsense.
- Accès console à la VM OPNsense (filet de sécurité en cas de blocage réseau).

## Étapes réalisées — Phase IDS

### 1. Activation de Suricata

Suricata est intégré nativement à OPNsense (pas de greffon supplémentaire à installer). Dans Services → Détection d'Intrusion → Administration → Paramètres :

- Activation de Suricata.
- Sélection des interfaces à surveiller : DMZ et WAN.
- Mode de capture initial : PCAP live mode (IDS).
- Activation de la sortie EVE pour la journalisation des événements.

### 2. Téléchargement des rulesets

Dans l'onglet Téléchargement, sélection des jeux de règles ET Open (préfixe `emerging-`) : attack_response, exploit, exploit_kit, malware, scan, dos, dns, web_client, web_server, botcc, ciarmy, compromised, dshield, drop, current_events, policy. Téléchargement et application.

## Étapes réalisées — Bascule en IPS

### 3. Prérequis : désactivation du hardware offloading

Le mode IPS d'OPNsense repose sur Netmap, incompatible avec le délestage matériel. Vérification dans Interfaces → Paramètres que les trois options sont désactivées (cases « Désactiver le délestage matériel » cochées) :

- Délestage des sommes de contrôle (CRC).
- Délestage de la segmentation TCP (TSO).
- Délestage des tampons de réception (LRO).

### 4. Activation du mode IPS

Dans Détection d'Intrusion → Administration → Paramètres, changement du mode de capture de PCAP live mode (IDS) vers Netmap (IPS mode), puis application. Suricata redémarre en mode inline.

### 5. Analyse de non-impact sur les accès d'administration

Vérification préalable que le mode IPS (actif sur DMZ et WAN) ne couperait aucun accès d'administration : les flux d'administration transitent par le LAN et le réseau Serveurs, et les tunnels SSH arrivent sur la passerelle de virtualisation sans traverser les interfaces DMZ ou WAN. L'activation de l'IPS était donc sans risque pour la continuité d'accès. La console de la VM OPNsense a été conservée comme accès de secours.

### 6. Politique de blocage ciblée

Création d'une politique de blocage (Détection d'Intrusion → Politique) limitée aux rulesets à faible risque de faux positifs :

- emerging-malware
- emerging-exploit
- emerging-exploit_kit

Action et nouvelle action positionnées sur « Rejeter ». Les rulesets plus bruyants (policy, dns, web) ont été laissés en mode alerte pour ne pas bloquer de trafic légitime.

## Problèmes rencontrés et résolutions

### Avertissements flowbit au démarrage

Au redémarrage en mode IPS, des avertissements de type « flowbit checked but not set » apparaissent dans le journal. Ils sont sans gravité : ils signalent que certaines règles vérifient un drapeau posé par un ruleset non activé. Le moteur fonctionne normalement ; ces avertissements sont une conséquence attendue de la sélection partielle de rulesets.

### Application de la politique non propagée

Après création de la politique, les règles concernées apparaissaient encore en mode alerte. La propagation de la politique vers le moteur n'était pas immédiate. Le contournement fiable a consisté à forcer l'action « Rejeter » directement sur les règles ciblées via l'onglet Règles (filtrage par ruleset, sélection, bouton Rejeter), puis à redémarrer Suricata pour recharger le moteur.

### Test de blocage initial non concluant

Les premiers tests de blocage (requêtes vers un domaine de test public) n'étaient pas concluants : le domaine de test était injoignable, produisant un faux timeout sans rapport avec l'IPS. La méthode retenue a consisté à cibler une signature précise confirmée en mode blocage.

## Validation

Test depuis le serveur DMZ avec un User-Agent malveillant connu correspondant à une signature active en blocage (SID 2002877, « ET MALWARE TROJAN BankSnif/Nethelper ») :

```bash
curl --max-time 15 -A "nethelper" http://www.example.com
```

Résultat : `curl: (28) Operation timed out after 15002 milliseconds with 0 bytes received`. La même URL répondait normalement avec un User-Agent neutre, ce qui isole le blocage au moteur IPS. Côté Suricata, l'alerte correspondante apparaît avec l'action « blocked » sur l'interface DMZ, tandis que le trafic légitime reste en « allowed ».

## Point d'attention

Une partie des règles a été basculée manuellement en « Rejeter ». OPNsense rappelle que les modifications manuelles sont écrasées lors des mises à jour de rulesets. La politique de blocage, elle, persiste aux mises à jour : la protection durable doit donc reposer sur la politique (voir procédure de consolidation IPS).

## Résultat

Suricata est passé du mode détection au mode prévention sur les interfaces DMZ et WAN. Le blocage des menaces malware et exploit est validé en conditions réelles, sans impact sur le trafic légitime ni sur les accès d'administration.
