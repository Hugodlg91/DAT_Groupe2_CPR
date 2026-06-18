Start-Transcript -Path "C:\zabbix-install.log"

Write-Output "Début du script GPO Zabbix (100% Online)."


$ZabbixURL = "https://cdn.zabbix.com/zabbix/binaries/stable/7.4/7.4.11/zabbix_agent2-7.4.11-windows-amd64-openssl.msi"


$ZabbixMSI = "C:\zabbix_agent.msi"

$ZabbixServer = "10.0.2.30"


if (-not (Get-Service -Name "Zabbix Agent 2" -ErrorAction SilentlyContinue)) {

    Write-Output "Service introuvable. Téléchargement de l'agent Zabbix depuis internet..."

    try {

        Invoke-WebRequest -Uri $ZabbixURL -OutFile $ZabbixMSI -UseBasicParsing -ErrorAction Stop

        Write-Output "Téléchargement terminé."

    } catch {

        Write-Output "Erreur réseau (URL invalide ou pas d'internet) : $_"

        Stop-Transcript

        exit

    }

    

    Write-Output "Installation silencieuse en cours..."

    $msiArgs = "/i `"$ZabbixMSI`" /qn SERVER=$ZabbixServer SERVERACTIVE=$ZabbixServer HOSTNAME=$env:COMPUTERNAME"

    Start-Process -FilePath "msiexec.exe" -ArgumentList $msiArgs -Wait -NoNewWindow

    

    Write-Output "Pause pour laisser Windows enregistrer le service..."

    Start-Sleep -Seconds 5

    

    Write-Output "Démarrage du service Zabbix..."

    Start-Service "Zabbix Agent 2" -ErrorAction SilentlyContinue

    

    if ((Get-Service "Zabbix Agent 2" -ErrorAction SilentlyContinue).Status -eq "Running") {

        Write-Output "SUCCÈS : Agent installé et démarré."

    } else {

        Write-Output "ÉCHEC : Le service ne tourne pas."

    }

} else {

    Write-Output "L'agent Zabbix est déjà installé sur ce poste."

}

Stop-Transcript
