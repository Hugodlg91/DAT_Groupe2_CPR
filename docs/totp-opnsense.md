# Configuration MFA TOTP sur OPNsense

La création du serveur TOTP n'est pas exposée via l'API REST OPNsense.
Configuration manuelle : Système → Accès → Serveurs → Ajouter
- Nom : TOTP-Server
- Type : Local + Timebased One time Password
- Token length : 6 / Time window : 30s
