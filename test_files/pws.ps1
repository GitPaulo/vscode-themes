<#
.SYNOPSIS
    Cross-platform deployment utilities for a fictional web service.

.DESCRIPTION
    Provides logging, configuration, backup/restore, service management,
    and monitoring.  Designed to exercise syntax highlighting in editors.

.NOTES
    Requires PowerShell 7+
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

#region Globals -------------------------------------------------------------------
$Script:Version       = '1.4.7'
$Script:LogDir        = '/var/log/deploy-tools'
$Script:DefaultBackup = '/var/backups/deploy-tools'
$Script:ConfigFile    = '/etc/deploy-tools/config.json'
$Script:Services      = @{
    Web    = 'nginx'
    App    = 'myapp'
    Worker = 'myapp-worker'
}
#endregion

#region Utility: Logging -----------------------------------------------------------
function Write-Log {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][ValidateSet('INFO','WARN','ERROR','DEBUG')]
        [string]$Level,
        [Parameter(Mandatory)]
        [string]$Message
    )
    $ts = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $color = switch ($Level) {
        'INFO'  { 'Green' }
        'WARN'  { 'Yellow' }
        'ERROR' { 'Red' }
        'DEBUG' { 'Cyan' }
    }
    Write-Host "$ts [$Level] $Message" -ForegroundColor $color
    "$ts [$Level] $Message" | Out-File -Append -FilePath "$Script:LogDir/deploy.log"
}
#endregion

#region Utility: Config ------------------------------------------------------------
function Get-DeployConfig {
    [CmdletBinding()]
    param()
    if (-not (Test-Path $Script:ConfigFile)) {
        Write-Log -Level ERROR -Message "Missing config: $Script:ConfigFile"
        throw "Config not found"
    }
    return Get-Content $Script:ConfigFile -Raw | ConvertFrom-Json
}
#endregion

#region Backup & Restore -----------------------------------------------------------
function Invoke-Backup {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [string]$TargetDir = $Script:DefaultBackup
    )
    if ($PSCmdlet.ShouldProcess("Backup to $TargetDir")) {
        $ts = Get-Date -Format 'yyyyMMdd_HHmmss'
        $archive = Join-Path $TargetDir "deploy-backup-$ts.tgz"
        Write-Log INFO "Starting backup to $archive"
        tar -czf $archive /etc/deploy-tools /var/lib/myapp /var/log/myapp
        Write-Log INFO "Backup complete: $archive"
    }
}

function Invoke-Restore {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)][string]$Archive
    )
    if (-not (Test-Path $Archive)) {
        Write-Log ERROR "Archive not found: $Archive"
        return
    }
    if ($PSCmdlet.ShouldProcess("Restore from $Archive")) {
        tar -xzf $Archive -C /
        Write-Log INFO "Restore completed"
    }
}
#endregion

#region Service Management ---------------------------------------------------------
function Invoke-ServiceAction {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][ValidateSet('start','stop','restart')]
        [string]$Action
    )
    foreach ($svc in $Script:Services.Keys) {
        $unit = $Script:Services[$svc]
        Write-Log INFO "systemctl $Action $unit"
        try {
            systemctl $Action $unit
        } catch {
            Write-Log WARN "Service $unit failed to $Action"
        }
    }
}

function Get-ServiceStatus {
    [CmdletBinding()]
    param()
    foreach ($svc in $Script:Services.Keys) {
        $unit = $Script:Services[$svc]
        $state = (systemctl is-active $unit) -replace '\r',''
        '{0,-10} : {1}' -f $svc, $state
    }
}
#endregion

#region Monitoring -----------------------------------------------------------------
function Test-DiskUsage {
    [CmdletBinding()]
    param([int]$Limit = 80)
    df -h --output=pcent,target | Select-Object -Skip 1 | ForEach-Object {
        $parts = $_ -split '\s+'
        $use = [int]($parts[0].TrimEnd('%'))
        if ($use -gt $Limit) {
            Write-Log WARN "High disk usage: $_"
        } else {
            Write-Log DEBUG "Disk usage OK: $_"
        }
    }
}

function Start-MonitorLoop {
    [CmdletBinding()]
    param([int]$Interval = 60)
    Write-Log INFO "Starting monitor loop every $Interval s"
    while ($true) {
        Test-DiskUsage -Limit 85
        Start-Sleep -Seconds $Interval
    }
}
#endregion

#region Utility: HTTP request example ----------------------------------------------
function Get-RemoteJson {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][Uri]$Uri
    )
    try {
        $resp = Invoke-RestMethod -Uri $Uri -Method Get -TimeoutSec 10
        Write-Log DEBUG "Fetched $($resp | ConvertTo-Json -Depth 2)"
        return $resp
    }
    catch {
        Write-Log ERROR "HTTP request failed: $_"
        throw
    }
}
#endregion

#region Scheduled Task Example ------------------------------------------------------
function Register-BackupTask {
    [CmdletBinding()]
    param(
        [string]$Schedule = 'Daily'
    )
    $action  = New-ScheduledTaskAction -Execute pwsh -Argument "-File `"$PSCommandPath`" backup"
    $trigger = New-ScheduledTaskTrigger -At 3am -Daily
    Register-ScheduledTask -Action $action -Trigger $trigger -TaskName 'DeployToolsBackup' -Force
    Write-Log INFO "Scheduled daily backup at 3am"
}
#endregion

#region Class Example ---------------------------------------------------------------
class DeploySummary {
    [string]$Host
    [datetime]$Timestamp
    [hashtable]$Services
    DeploySummary([string]$host,[hashtable]$services) {
        $this.Host      = $host
        $this.Timestamp = Get-Date
        $this.Services  = $services
    }
    [string] ToString() {
        return "DeploySummary for $($this.Host) at $($this.Timestamp)"
    }
}
#endregion

#region Main -----------------------------------------------------------------------
function Invoke-Main {
    [CmdletBinding()]
    param(
        [Parameter(Position=0)][ValidateSet(
            'backup','restore','start','stop','restart','status',
            'tail-logs','version','monitor'
        )][string]$Command,
        [string]$Argument
    )

    New-Item -ItemType Directory -Force -Path $Script:LogDir,$Script:DefaultBackup | Out-Null
    $config = Get-DeployConfig

    switch ($Command) {
        'backup'    { Invoke-Backup -TargetDir ($Argument ?? $Script:DefaultBackup) }
        'restore'   { Invoke-Restore -Archive $Argument }
        'start'     { Invoke-ServiceAction -Action start }
        'stop'      { Invoke-ServiceAction -Action stop }
        'restart'   { Invoke-ServiceAction -Action restart }
        'status'    { Get-ServiceStatus }
        'tail-logs' {
            if ($Argument) { journalctl -fu $Script:Services[$Argument] }
            else { $Script:Services.Values | ForEach-Object { journalctl -fu $_ & } | Wait-Job }
        }
        'version'   { "$PSCommandPath version $Script:Version" }
        'monitor'   { Start-MonitorLoop }
        default     { Get-Help $PSCommandPath -Detailed }
    }
}
#endregion

# Entry point
if ($MyInvocation.InvocationName -ne '.') {
    Invoke-Main @args
}
