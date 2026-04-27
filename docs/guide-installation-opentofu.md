# Guide d'installation — OpenTofu

> **Version ciblée : OpenTofu >= 1.7**
> OpenTofu est le fork open source de Terraform, maintenu par la Linux Foundation. Il est utilisé dans le projet CYNA pour provisionner l'infrastructure AWS (EKS, EC2, VPC, RDS).

---

## Prérequis

| Critère | Détail |
|---|---|
| Systèmes supportés | Linux (Ubuntu/Debian, RHEL/CentOS/Fedora), macOS, Windows |
| Droits | Administrateur local / `sudo` |
| Réseau | Accès Internet requis pour le téléchargement |

---

## Installation

### Linux — Ubuntu / Debian

```bash
curl -fsSL https://get.opentofu.org/install-opentofu.sh | sh -s -- --install-method deb
tofu --version
```

### Linux — RHEL / CentOS / Fedora

```bash
curl -fsSL https://get.opentofu.org/install-opentofu.sh | sh -s -- --install-method rpm
tofu --version
```

### macOS (Homebrew)

```bash
brew install opentofu
tofu --version
```

### Windows (Chocolatey)

```powershell
choco install opentofu
tofu --version
```

### Installation manuelle (binaire)

1. Télécharger l'archive depuis [github.com/opentofu/opentofu/releases](https://github.com/opentofu/opentofu/releases)
2. Décompresser l'archive :

```bash
unzip opentofu_*_linux_amd64.zip -d /usr/local/bin/
chmod +x /usr/local/bin/tofu
```

3. Vérifier l'installation :

```bash
tofu --version
```

---

## Premier projet — structure de base

Organisation recommandée d'un module OpenTofu :

```
mon-projet/
├── main.tf
├── variables.tf
└── outputs.tf
```

### `main.tf`

```hcl
terraform {
  required_version = ">= 1.7"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = {
    Name    = "cyna-vpc"
    Project = "CYNA"
  }
}
```

### `variables.tf`

```hcl
variable "aws_region" {
  description = "Région AWS cible"
  type        = string
  default     = "eu-west-3"
}

variable "vpc_cidr" {
  description = "Plage CIDR du VPC principal"
  type        = string
  default     = "10.0.0.0/16"
}
```

### `outputs.tf`

```hcl
output "vpc_id" {
  description = "ID du VPC créé"
  value       = aws_vpc.main.id
}
```

---

## Commandes essentielles

| Commande | Description | Exemple |
|---|---|---|
| `tofu init` | Initialise le répertoire de travail, télécharge les providers | `tofu init` |
| `tofu validate` | Vérifie la syntaxe et la cohérence des fichiers `.tf` | `tofu validate` |
| `tofu fmt` | Formate les fichiers selon le style canonique HCL | `tofu fmt -recursive` |
| `tofu plan` | Génère et affiche le plan d'exécution sans appliquer | `tofu plan -out=tfplan` |
| `tofu apply` | Applique les changements sur l'infrastructure | `tofu apply tfplan` |
| `tofu destroy` | Détruit toutes les ressources gérées par le module | `tofu destroy` |

---

## Intégration dans le projet CYNA

OpenTofu est le socle IaC de l'infrastructure CYNA. Il gère le provisionnement de l'ensemble des ressources AWS :

- **VPC & Subnets** — segmentation réseau (`10.0.0.0/16`), subnets publics/privés, route tables
- **Cluster EKS** — déploiement du plan de contrôle Kubernetes et des node groups pour les conteneurs SaaS et E-commerce
- **Instances EC2** — serveurs applicatifs et bastions d'accès sécurisé
- **RDS** — bases de données managées (clients sensibles, données E-commerce)

Les modules Terraform/OpenTofu sont versionnés dans ce dépôt et exécutés via une pipeline CI/CD (Ansible + GitHub Actions) pour garantir la reproductibilité des environnements.

---

## Ressources utiles

- Documentation officielle : [opentofu.org/docs](https://opentofu.org/docs)
- Dépôt GitHub : [github.com/opentofu/opentofu](https://github.com/opentofu/opentofu)
- Registry des providers : [registry.opentofu.org](https://registry.opentofu.org)
