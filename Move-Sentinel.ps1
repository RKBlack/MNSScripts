﻿function Move-Sentinel {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='Medium')]
    Param (
        [Parameter(Mandatory)]
        [string[]]$AgentPass,
        [Parameter(Mandatory)]
        [string[]]$SiteKey,
        $Force
    )
    Begin {
        if (-not $PSBoundParameters.ContainsKey('Verbose')) {
            $VerbosePreference = $PSCmdlet.SessionState.PSVariable.GetValue('VerbosePreference')
        }
        if (-not $PSBoundParameters.ContainsKey('Confirm')) {
            $ConfirmPreference = $PSCmdlet.SessionState.PSVariable.GetValue('ConfirmPreference')
        }
        if (-not $PSBoundParameters.ContainsKey('WhatIf')) {
            $WhatIfPreference = $PSCmdlet.SessionState.PSVariable.GetValue('WhatIfPreference')
        }
        Write-Verbose ('[{0}] Confirm={1} ConfirmPreference={2} WhatIf={3} WhatIfPreference={4}' -f $MyInvocation.MyCommand, $Confirm, $ConfirmPreference, $WhatIf, $WhatIfPreference)
    }
    Process {
        function Start-Sleep($seconds) {
        $doneDT = (Get-Date).AddSeconds($seconds)
        while($doneDT -gt (Get-Date)) {
            $secondsLeft = $doneDT.Subtract((Get-Date)).TotalSeconds
            $percent = ($seconds - $secondsLeft) / $seconds * 100
            Write-Progress -Activity "Sleeping" -Status "Sleeping..." -SecondsRemaining $secondsLeft -PercentComplete $percent
            [System.Threading.Thread]::Sleep(500)
        }
    Write-Progress -Activity "Sleeping" -Status "Sleeping..." -SecondsRemaining 0 -Completed
}
        if ($Force -or $PSCmdlet.ShouldProcess("ShouldProcess?")) {
            Write-Verbose ('[{0}] Reached command' -f $MyInvocation.MyCommand)
            $ConfirmPreference = 'None'
            $sentinelcli = "C:\Program Files\SentinelOne\" + (Get-ChildItem "C:\Program Files\SentinelOne" | Select-Object Name -ExpandProperty Name) + "\SentinelCtl.exe"
            if (Test-Path $sentinelcli) {
                Write-Host "Starting transfer of agent " + $env:computername + "to site with key " + $SiteKey + ". Please wait."
                Start-Process -FilePath $sentinelcli -ArgumentList "bind '$SiteKey' -k '$AgentPass'" -NoNewWindow
                Start-Sleep -Seconds 30
                Write-Host "Restarting Sentinel Agent. Please wait."
                Start-Process -FilePath $sentinelcli -ArgumentList "reload -a -k '$AgentPass'"
                Start-Sleep -Seconds 30
                Write-Host "Transfer Complete. A system reboot may be required."
            }
            else {
                Write-Host "sentinelctl.exe not found.  Is SentinelOne Installed?"
            }
        }
    }
    End {
        Write-Verbose ('[{0}] Confirm={1} ConfirmPreference={2} WhatIf={3} WhatIfPreference={4}' -f $MyInvocation.MyCommand, $Confirm, $ConfirmPreference, $WhatIf, $WhatIfPreference)
    }
}
