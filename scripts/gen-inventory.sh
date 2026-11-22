#!/usr/bin/env bash
# Genere config/ansible/inventory.ini a partir des sorties Terraform.
# Usage (racine du depot) : ./scripts/gen-inventory.sh aws
set -euo pipefail
ENV="${1:-aws}"
DIR="infra/envs/${ENV}"
IP="$(terraform -chdir="$DIR" output -raw public_ip)"
USER_SSH="$(terraform -chdir="$DIR" output -raw ssh_user)"
[ -n "$IP" ] || { echo "public_ip vide" >&2; exit 1; }
printf '[web]\n%s ansible_user=%s\n' "$IP" "$USER_SSH" > config/ansible/inventory.ini
echo "Inventaire ecrit : $IP ($USER_SSH)"
