# Reconstruction complete depuis zero

Objectif : prouver que l'infrastructure ET l'application se reconstruisent sans action
manuelle non documentee.

## Prerequis (une seule fois, hors procedure)
1. Outils : Git, Terraform, AWS CLI, GitHub CLI, WSL2/Ansible (pour les tests manuels).
2. `aws configure` (utilisateur IAM terraform-p6, region eu-north-1).
3. `gh auth login`.
4. Cle SSH `~/.ssh/p6_key` (+ `.pub`).
5. Secrets GitHub : `SSH_KEY` (cle privee), `SSH_USER` (deploy), `SSH_HOST` (mis a jour automatiquement).
6. Une image publiee sur GHCR pour le commit a deployer (CI vert).

## Procedure (une seule commande)
```powershell
.\scripts\rebuild.ps1 -Tag <sha-complet-du-commit>
```
Etapes automatisees et chronometrees :
1. `terraform destroy`
2. `terraform apply` (VM Ubuntu, pare-feu, cle SSH, cloud-init)
3. generation de l'inventaire Ansible
4. attente SSH + fin de cloud-init
5. mise a jour du secret `SSH_HOST` (nouvelle IP)
6. deploiement par le workflow CD (Ansible : Docker, Nginx, application, healthcheck)
7. verification de `/version` et `/health`

Les mesures sont ecrites dans `docs/measures/rebuild-<date>.txt`.

## Verification de non-dependance aux actions manuelles
Aucune etape n'exige la console AWS, un copier-coller d'IP ou une commande hors script.
