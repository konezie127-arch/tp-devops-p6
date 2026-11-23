# Versions de demonstration (mise a jour et rollback)

- v2 : ajoute GET /stats (+ un test). Copier v2/main.py -> app/main.py et v2/test_api.py -> app/tests/test_api.py
- v3 : v2 + demarrage qui plante. Les tests unitaires PASSENT (TestClient sans "with"
  ne lance pas le lifespan), mais le conteneur ne demarre pas : seul le healthcheck
  de deploiement protege la production -> rollback automatique.
