# Conventions de nommage CYNA
Pour garantir la cohérence de l'IaC et de l'Active Directory, les règles suivantes s'appliquent :
- **Serveurs (Linux/Windows)** : `SRV-[ROLE][NUMERO]` (ex: `SRV-AD01`, `SRV-WAZUH`)
- **Postes Clients** : `CLT-[OS]-[SITE]` (ex: `CLT-W11-GENEVE`, `CLT-W11-PARIS`)
- **Équipements Réseau** : `FW-[MODELE][NUMERO]` (ex: `FW-OPN01`)
- **Comptes Utilisateurs AD** : `[premiere_lettre_prenom].[nom]` (ex: `a.martin`)
