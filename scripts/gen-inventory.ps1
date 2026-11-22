# Genere config/ansible/inventory.ini a partir des sorties Terraform.
# Usage (depuis la racine du depot) : .\scripts\gen-inventory.ps1 -Env aws
param([string]$Env = "aws")

$dir  = "infra/envs/$Env"
$ip   = (terraform -chdir=$dir output -raw public_ip).Trim()
$user = (terraform -chdir=$dir output -raw ssh_user).Trim()

if (-not $ip) { throw "public_ip vide : terraform apply a-t-il ete execute ?" }

$content = "[web]`n$ip ansible_user=$user`n"
Set-Content -Path "config/ansible/inventory.ini" -Value $content -NoNewline -Encoding ascii
Write-Host "Inventaire ecrit : $ip ($user)"
