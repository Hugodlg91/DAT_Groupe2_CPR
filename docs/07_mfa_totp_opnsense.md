# Procédure 07 — Mise en place du MFA TOTP sur OPNsense

## Objectif

Protéger l'accès d'administration au pare-feu OPNsense par une authentification multi-facteurs de type TOTP (mot de passe à usage unique basé sur le temps), conforme au standard RFC 6238.

## Périmètre

| Élément | Valeur |
|---|---|
| Pare-feu | OPNsense (fw-opn01.cyna.local) |
| Serveur d'authentification | TOTP-Server (Local + TOTP) |
| Compte de test | corentin |
| Longueur du jeton / fenêtre | 6 chiffres / 30 secondes |
| Application | Microsoft Authenticator |

## Prérequis

- Accès administrateur à OPNsense.
- Synchronisation horaire fonctionnelle (le TOTP dépend de l'heure).
- Application d'authentification sur un terminal mobile.

## Étapes réalisées

### 1. Création du serveur d'authentification TOTP

Dans Système → Accès → Serveurs, création d'un serveur d'authentification de type Local + TOTP. Ce module repose sur le composant legacy d'OPNsense et n'expose pas d'endpoint d'API : sa création se fait donc manuellement via l'interface.

### 2. Configuration du compte de test

Sur le compte utilisateur de test, affichage de la graine OTP (Système → Accès → Utilisateurs → édition du compte → afficher la graine OTP), qui génère un QR code.

### 3. Enrôlement dans l'application

Scan du QR code avec l'application d'authentification, qui commence alors à générer un code à 6 chiffres renouvelé toutes les 30 secondes.

### 4. Liaison à l'interface d'administration

Dans Système → Paramètres → Administration, configuration du serveur d'authentification de l'interface avec la base locale ET le serveur TOTP. La base locale est conservée dans la liste pour préserver un accès de secours (compte root), évitant tout verrouillage administratif.

## Problèmes rencontrés et résolutions

Deux causes distinctes ont fait échouer l'authentification de façon prolongée. Elles ont été traitées successivement.

### Problème 1 — Désynchronisation horaire (NTP bloqué)

**Constat.** Les codes TOTP étaient systématiquement rejetés. L'authentification d'un code valide échouait sans message explicite.

**Diagnostic.** L'horloge du pare-feu avait dérivé de plusieurs minutes. Or un code TOTP est calculé à partir de l'heure courante : si l'horloge du serveur et celle du téléphone divergent au-delà de la fenêtre de tolérance, le code est invalide. La vérification a montré que le trafic NTP sortant était bloqué, empêchant la resynchronisation automatique.

**Solution.** Ouverture du flux NTP sortant sur le pare-feu (réalisée par l'ingénieur réseau). Vérification de la resynchronisation :

```bash
date
ping -c 3 pool.ntp.org
```

L'heure du pare-feu est alors revenue alignée sur l'heure réelle.

### Problème 2 — Ordre de saisie du code et du mot de passe

**Constat.** Après correction de l'heure, l'authentification échouait toujours, alors que le mot de passe seul (testé via la base locale) était valide et que le code généré côté serveur correspondait à celui de l'application.

**Diagnostic.** Tous les éléments étant corrects individuellement, le problème se situait dans le format de saisie du champ d'authentification.

**Solution.** OPNsense attend le **code TOTP placé avant le mot de passe**, concaténés sans espace, et non l'inverse. Le format correct est :

```
<code_TOTP><mot_de_passe>
```

Par exemple, pour un code `419028` et un mot de passe `motdepasse`, la saisie est `419028motdepasse`. Une fois ce format appliqué, l'authentification a réussi.

## Validation

Test réalisé via Système → Accès → Tester, avec le serveur TOTP-Server, le compte de test, et la saisie au format code suivi du mot de passe. Le test retourne une authentification réussie.

## Synthèse du diagnostic

| Cause envisagée | Vérification | Conclusion |
|---|---|---|
| Horloge décalée | date / ping pool.ntp.org | Corrigée (NTP rétabli) |
| Mot de passe erroné | test base locale seule | Mot de passe correct |
| Graine désynchronisée | rescan du QR | Graine cohérente |
| Ordre de saisie code/mot de passe | test code avant mot de passe | Cause réelle |

## Résultat

L'authentification multi-facteurs TOTP est opérationnelle et validée sur le pare-feu OPNsense, avec un accès de secours préservé. L'incident illustre l'importance de vérifier à la fois l'environnement (synchronisation horaire, flux réseau) et la procédure d'usage (format de saisie).
