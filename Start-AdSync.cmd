;@echo off
;Findstr -rbv ; %0 | powershell -c - 
;goto:sCode

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

#Sleep Timer
function Start-Sleep {
    Param (
        [Parameter(Mandatory)]
        $Activity,
        [Parameter(Mandatory)]
        $Status,
        [Parameter(Mandatory)]
        $Seconds
    )
    $doneDT = (Get-Date).AddSeconds($seconds)
    while($doneDT -gt (Get-Date)) {
        $secondsLeft = $doneDT.Subtract((Get-Date)).TotalSeconds
        $percent = ($seconds - $secondsLeft) / $seconds * 100
        Write-Progress -Activity $Activity -Status $Status -SecondsRemaining $secondsLeft -PercentComplete $percent
        [System.Threading.Thread]::Sleep(500)
    }
    Write-Progress -Activity $Activity -Status $Status -SecondsRemaining 0 -Completed
}

#Pop-up Form for Policy
$form = New-Object System.Windows.Forms.Form
$form.Text = 'Select a Policy'
$form.Size = New-Object System.Drawing.Size(300,200)
$form.StartPosition = 'CenterScreen'

$okButton = New-Object System.Windows.Forms.Button
$okButton.Location = New-Object System.Drawing.Point(75,120)
$okButton.Size = New-Object System.Drawing.Size(75,23)
$okButton.Text = 'OK'
$okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$form.AcceptButton = $okButton
$form.Controls.Add($okButton)

$cancelButton = New-Object System.Windows.Forms.Button
$cancelButton.Location = New-Object System.Drawing.Point(150,120)
$cancelButton.Size = New-Object System.Drawing.Size(75,23)
$cancelButton.Text = 'Cancel'
$cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$form.CancelButton = $cancelButton
$form.Controls.Add($cancelButton)

$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(10,20)
$label.Size = New-Object System.Drawing.Size(280,20)
$label.Text = 'Please select a policy:'
$form.Controls.Add($label)

$listBox = New-Object System.Windows.Forms.ListBox
$listBox.Location = New-Object System.Drawing.Point(10,40)
$listBox.Size = New-Object System.Drawing.Size(260,20)
$listBox.Height = 80

[void] $listBox.Items.Add('Delta')
[void] $listBox.Items.Add('Initial')

$form.Controls.Add($listBox)
$form.Topmost = $true
$result = $form.ShowDialog()

if ($result -eq [System.Windows.Forms.DialogResult]::OK)
{
    $policy = $listBox.SelectedItem
    if ($policy -eq "Initial") {
        $waittime = 180
    }
    else {
        $waittime = 45
    }
    Start-AdSyncSyncCycle -PolicyType $policy
    Start-Sleep -Seconds $waittime -Activity "Syncing" -Status "Running $policy Sync..."
}

$starttime = ((Get-Date).AddHours(6).AddSeconds(-$waittime)).AddSeconds(-10)
Get-ADSyncRunProfileResult | Where-Object {$_.StartDate -gt $starttime} | Format-Table StartDate,ConnectorName,RunProfileName,IsRunComplete,Result

;:sCode 
;pause & goto :eof
