Start-Transcript -Path "C:\wazuh-install.log"

Write-Output "Début du script GPO au démarrage (Version Finale)."


$wazuhManager = "10.0.2.20"

$msiUrl = "https://packages.wazuh.com/4.x/windows/wazuh-agent-4.14.5-1.msi"

$installerPath = "C:\wazuh-agent.msi"

$confPath = "C:\Program Files (x86)\ossec-agent\ossec.conf"


$service = Get-Service -Name "WazuhSvc" -ErrorAction SilentlyContinue

if (-not $service) {

    Write-Output "Service introuvable. Téléchargement du MSI..."

    try {

        Invoke-WebRequest -Uri $msiUrl -OutFile $installerPath -UseBasicParsing -ErrorAction Stop

    } catch {

        Write-Output "Erreur réseau lors du téléchargement : $_"

        Stop-Transcript ; exit

    }

    

    Write-Output "Installation silencieuse..."

    $msiArgs = "/i `"$installerPath`" /q WAZUH_MANAGER=`"$wazuhManager`""

    Start-Process -FilePath "msiexec.exe" -ArgumentList $msiArgs -Wait -NoNewWindow

    Start-Sleep -Seconds 5

}


# --- Correction à la volée de la configuration ---

if (Test-Path $confPath) {

    $config = Get-Content $confPath -Raw

    if ($config -match "0.0.0.0") {

        Write-Output "Alerte : IP 0.0.0.0 détectée dans la conf. Correction forcée vers $wazuhManager."

        $config = $config -replace "0.0.0.0", $wazuhManager

        Set-Content -Path $confPath -Value $config -Encoding UTF8

    }

}


Write-Output "Démarrage du service Wazuh..."

Start-Service -Name "WazuhSvc" -ErrorAction SilentlyContinue


if ((Get-Service -Name "WazuhSvc").Status -eq "Running") {

    Write-Output "SUCCÈS : L'agent Wazuh est opérationnel."

} else {

    Write-Output "ÉCHEC : Le service refuse de démarrer."

}

Stop-Transcript 
