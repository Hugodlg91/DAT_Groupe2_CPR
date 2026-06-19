# Procédure de restauration de machine virtuelle (PRA)

## Objectif

Permettre la remise en service rapide d'une machine virtuelle en cas de panne, corruption ou suppression accidentelle.

## Prérequis

* Accès à l'interface Proxmox.
* Présence d'une sauvegarde valide de la machine virtuelle.
* Espace de stockage disponible sur l'hyperviseur.

## Procédure de restauration

1. Se connecter à l'interface Proxmox.
2. Sélectionner le stockage contenant les sauvegardes.
3. Ouvrir l'onglet **Backups**.
4. Sélectionner la dernière sauvegarde valide de la machine virtuelle concernée.
5. Cliquer sur **Restore**.
6. Vérifier l'identifiant de la machine virtuelle (VMID).
7. Sélectionner le stockage de destination (*local-lvm*).
8. Lancer la restauration.
9. Attendre la fin de l'opération.
10. Démarrer la machine virtuelle restaurée.
11. Vérifier le bon fonctionnement du système et des services.

## Vérifications post-restauration

* La machine virtuelle démarre correctement.
* Les données sont présentes.
* La connectivité réseau est opérationnelle.
* Les services applicatifs fonctionnent normalement.
* La supervision remonte correctement l'état de la machine.

## Test réalisé

Un test de restauration a été effectué sur une machine virtuelle Ubuntu dédiée aux essais. Après création d'un fichier témoin, une sauvegarde Proxmox a été réalisée. La machine virtuelle a ensuite été supprimée puis restaurée avec succès à partir du fichier de sauvegarde. Les vérifications post-restauration ont confirmé la récupération correcte du système et des données.
