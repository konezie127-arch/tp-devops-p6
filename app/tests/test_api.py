from fastapi.testclient import TestClient
from main import app

client = TestClient(app)


def test_health():
    r = client.get("/health")
    assert r.status_code == 200
    assert r.json() == {"status": "ok"}


def test_version():
    r = client.get("/version")
    assert r.status_code == 200
    assert "version" in r.json()


def test_create_and_get_task():
    r = client.post("/tasks", json={"title": "apprendre Terraform"})
    assert r.status_code == 201
    tid = r.json()["id"]
    assert client.get(f"/tasks/{tid}").json()["title"] == "apprendre Terraform"


def test_delete_task():
    tid = client.post("/tasks", json={"title": "x"}).json()["id"]
    assert client.delete(f"/tasks/{tid}").status_code == 204
    assert client.get(f"/tasks/{tid}").status_code == 404


def test_unknown_task_returns_404():
    assert client.get("/tasks/99999").status_code == 404


def test_stats():
    client.post("/tasks", json={"title": "a", "done": True})
    client.post("/tasks", json={"title": "b"})
    r = client.get("/stats")
    assert r.status_code == 200
    body = r.json()
    assert body["total"] == body["done"] + body["pending"]
    assert body["done"] >= 1
