# Projet 6 - Cloud DevOps & Infrastructure as Code

Automatisation de la chaîne code -> tests -> image conteneur -> infrastructure (Terraform)
-> configuration (Ansible) -> déploiement -> healthcheck -> rollback.

## Structure
- `app/` : API FastAPI, tests, Dockerfile
- `deploy/` : docker-compose (et plus tard deploy.sh / rollback.sh)
- `config/` : Nginx (et plus tard Ansible)
- `infra/` : Terraform, un module par fournisseur (`modules/`) et un dossier par environnement (`envs/`)
- `scripts/` : génération d'inventaire Ansible, déploiement, rollback (à venir)
- `.github/workflows/` : pipelines GitHub Actions
- `docs/` : documentation, dont `PROVIDER_CONTRACT.md` (contrat multi-cloud)

## Lancer en local
```bash
cd app
pip install -r requirements.txt -r requirements-dev.txt
pytest tests -v
uvicorn main:app --reload      # http://localhost:8000/docs
```

## Avec Docker
```bash
docker build -t tasks-api:local --build-arg APP_VERSION=local app
docker run --rm -p 8000:8000 tasks-api:local
```

## État d'avancement
- [x] Étape 1 : application + tests + Dockerfile
- [x] Étape 2 : CI GitHub Actions (tests, build, push GHCR)
- [x] Étape 3 : Compose + Nginx
- [ ] Étape 4 : Terraform, module AWS (fournisseur n°1) puis un second fournisseur
- [ ] Étape 5 : Ansible
- [ ] Étape 6 : CD, healthcheck, rollback
