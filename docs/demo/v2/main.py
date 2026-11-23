"""API de gestion de tâches - application de démonstration du Projet 6."""
import os
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

APP_VERSION = os.getenv("APP_VERSION", "dev")

app = FastAPI(title="Tasks API", version=APP_VERSION)

tasks: dict[int, dict] = {}
_next_id = 1


class TaskIn(BaseModel):
    title: str
    done: bool = False


@app.get("/health")
def health():
    """Utilisé par le healthcheck Docker et par le pipeline après déploiement."""
    return {"status": "ok"}


@app.get("/version")
def version():
    """Permet de voir quelle version tourne (démo mise à jour / rollback)."""
    return {"version": APP_VERSION}


@app.get("/stats")
def stats():
    """Nouveaute v2 : statistiques sur les taches."""
    done = sum(1 for t in tasks.values() if t["done"])
    return {"total": len(tasks), "done": done, "pending": len(tasks) - done}


@app.get("/tasks")
def list_tasks():
    return list(tasks.values())


@app.post("/tasks", status_code=201)
def create_task(task: TaskIn):
    global _next_id
    item = {"id": _next_id, **task.model_dump()}
    tasks[_next_id] = item
    _next_id += 1
    return item


@app.get("/tasks/{task_id}")
def get_task(task_id: int):
    if task_id not in tasks:
        raise HTTPException(status_code=404, detail="Tâche introuvable")
    return tasks[task_id]


@app.delete("/tasks/{task_id}", status_code=204)
def delete_task(task_id: int):
    if tasks.pop(task_id, None) is None:
        raise HTTPException(status_code=404, detail="Tâche introuvable")
