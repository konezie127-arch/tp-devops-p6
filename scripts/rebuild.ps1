<#
 Reconstruction complete de l'infrastructure ET de l'application, chronometree.
 Prerequis (a faire UNE fois, documentes dans docs/REBUILD.md) :
   - AWS CLI configure (aws configure), Terraform installe
   - GitHub CLI connecte (gh auth login) ; secrets SSH_KEY et SSH_USER, variable ou secret SSH_HOST existants
   - Cle SSH ~/.ssh/p6_key (la cle publique est lue par Terraform)
 Usage (depuis la racine du depot) :
   .\scripts\rebuild.ps1 -Tag <sha-complet-du-commit-a-deployer>
   .\scripts\rebuild.ps1 -Tag <sha> -NoDestroy      # premiere creation, sans destruction
#>
param(
  [Parameter(Mandatory = $true)][string]$Tag,
  [switch]$NoDestroy,
  [string]$Env = "aws"
)

# Avec "Stop", PowerShell 5.1 transforme toute ligne ecrite sur stderr par un programme
# natif (ex. l'avertissement de ssh) en erreur fatale. On reste en "Continue" et on
# verifie explicitement les codes de sortie (Exec) et les erreurs de cmdlets (-ErrorAction Stop).
$ErrorActionPreference = "Continue"
$tfdir  = "infra/envs/$Env"
$key    = Join-Path $HOME ".ssh/p6_key"
$times  = @()
$global:ip = $null

function Exec {
  param([string]$Cmd, [string[]]$Arguments)
  & $Cmd @Arguments
  if ($LASTEXITCODE -ne 0) { throw "Echec : $Cmd $($Arguments -join ' ') (code $LASTEXITCODE)" }
}

function Step {
  param([string]$Name, [scriptblock]$Body)
  Write-Host "==> $Name" -ForegroundColor Cyan
  $sw = [Diagnostics.Stopwatch]::StartNew()
  & $Body
  $sw.Stop()
  $script:times += [pscustomobject]@{ Etape = $Name; Secondes = [math]::Round($sw.Elapsed.TotalSeconds, 1) }
}

$total = [Diagnostics.Stopwatch]::StartNew()
$started = Get-Date

if (-not $NoDestroy) {
  Step "1. terraform destroy" {
    Exec terraform @("-chdir=$tfdir", "destroy", "-auto-approve")
  }
}

Step "2. terraform apply (VM, pare-feu, cle)" {
  Exec terraform @("-chdir=$tfdir", "init", "-input=false")
  Exec terraform @("-chdir=$tfdir", "apply", "-auto-approve")
  $global:ip = (terraform "-chdir=$tfdir" output -raw public_ip).Trim()
  if (-not $global:ip) { throw "public_ip vide" }
  Write-Host "    IP : $($global:ip)"
}

Step "3. inventaire Ansible" {
  & "$PSScriptRoot\gen-inventory.ps1" -Env $Env
}

Step "4. attente SSH + fin de cloud-init" {
  $ok = $false
  $sshOpts = @("-i", $key, "-o", "StrictHostKeyChecking=no", "-o", "UserKnownHostsFile=NUL",
               "-o", "BatchMode=yes", "-o", "ConnectTimeout=5", "-o", "LogLevel=ERROR")
  for ($i = 1; $i -le 40; $i++) {
    ssh @sshOpts "deploy@$($global:ip)" "cloud-init status --wait" *> $null
    if ($LASTEXITCODE -eq 0) { $ok = $true; break }
    Start-Sleep -Seconds 5
  }
  if (-not $ok) { throw "La VM n'est pas joignable en SSH apres 200 s" }
}

Step "5. mise a jour du secret SSH_HOST" {
  Exec gh @("secret", "set", "SSH_HOST", "--body", $global:ip)
}

Step "6. deploiement par le CD GitHub Actions" {
  $before = (gh run list --workflow cd.yml --limit 1 --json databaseId --jq ".[0].databaseId" 2>$null | Out-String).Trim()
  Exec gh @("workflow", "run", "CD", "-f", "release_tag=$Tag")
  $id = $before
  for ($i = 1; $i -le 30 -and $id -eq $before; $i++) {
    Start-Sleep -Seconds 2
    $id = (gh run list --workflow cd.yml --limit 1 --json databaseId --jq ".[0].databaseId" 2>$null | Out-String).Trim()
  }
  if ($id -eq $before) { throw "Le run CD n'est pas apparu apres 60 s" }
  Write-Host "    run CD : $id"
  Exec gh @("run", "watch", $id, "--exit-status")
}

Step "7. verification de la version en ligne" {
  $v = (Invoke-RestMethod "http://$($global:ip)/version" -ErrorAction Stop).version
  Write-Host "    /version -> $v"
  if ($v -ne $Tag) { throw "Version en ligne ($v) differente de la version attendue ($Tag)" }
  $h = (Invoke-RestMethod "http://$($global:ip)/health" -ErrorAction Stop).status
  if ($h -ne "ok") { throw "/health ne repond pas ok" }
}

$total.Stop()
$summary = $times | Format-Table -AutoSize | Out-String
Write-Host ""
Write-Host $summary
Write-Host ("TOTAL : {0:N0} s ({1:N1} min)" -f $total.Elapsed.TotalSeconds, $total.Elapsed.TotalMinutes) -ForegroundColor Green

New-Item -ItemType Directory -Force -Path "docs/measures" | Out-Null
$file = "docs/measures/rebuild-{0}.txt" -f $started.ToString("yyyyMMdd-HHmmss")
@(
  "Reconstruction complete - $($started.ToString('s'))",
  "Fournisseur : $Env | Version deployee : $Tag | IP : $($global:ip)",
  $summary,
  ("TOTAL : {0:N0} s" -f $total.Elapsed.TotalSeconds)
) | Set-Content -Path $file -Encoding ascii
Write-Host "Mesures enregistrees : $file"
