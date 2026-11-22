# Contrat fournisseur (portabilité multi-cloud)

Tout fournisseur doit fournir :
- 1 VM Linux **Ubuntu 22.04 ou 24.04** (2 vCPU / 1-2 Go RAM suffisent)
- Une **IP publique**
- Accès **SSH par clé** (clé publique injectée à la création)
- Ports entrants ouverts : **22** (SSH), **80** (HTTP), **443** (HTTPS)

Seule la couche `infra/` (Terraform) dépend du fournisseur.
Ansible, Docker/Compose, Nginx, les scripts de déploiement et le pipeline GitHub Actions
n'utilisent que ce contrat.

## Interface commune des modules Terraform
Entrées : `name`, `size`, `region`, `ssh_public_key`, `open_ports`
Sorties : `public_ip`, `ssh_user`

## Règles de portabilité
- Registre d'images : GHCR (pas d'ECR ou équivalent propriétaire)
- Pas de service managé propriétaire (RDS, S3...) dans l'application
- Etat Terraform local (pas de backend S3)
- Utilisateur SSH = variable Ansible, jamais codé en dur
- Amorçage via cloud-init
- Secrets du pipeline génériques : SSH_HOST, SSH_USER, SSH_KEY
