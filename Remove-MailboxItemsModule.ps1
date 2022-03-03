#To install, run the command Import-Module .\Remove-MailboxItemsModule.ps1
#Example: Remove-MailboxItems -StartDate "01/01/2001" -EndDate "12/31/2014" -DayRange 30 -UserPrincipalName "user@contoso.com"
#This example would remove ALL items in the user's mailbox within the date ragnge in blocks of 30 days.

function Remove-MailboxItems () {

    param (
        [Parameter(Mandatory)]
        [string]$StartDate,
        [Parameter(Mandatory)]
        [string]$EndDate,
        [Parameter(Mandatory)]
        [string]$UserPrincipalName,
        [Parameter(Mandatory)]
        [double]$DayRange
    )

    #Format Dates
    $fstartdate = Get-Date "$startdate"
    $fenddate = Get-Date "$enddate"
    $fnextstartdate = $fstartdate
    $fnextenddate = $fnextstartdate.AddDays($DayRange)
    $fremainderdays = (New-TimeSpan -Start $fstartdate -End $fenddate).Days % $DayRange - 1
    

    #Run delete for each block of dates
    Write-Host "Removing mail items for $UserPrincipalName from $StartDate to $EndDate in blocks of $DayRange days."
    Read-Host "Press ENTER to continue..." 
    while ($fnextenddate -lt $fenddate) {
        $gnextstartdate = '{0:MM/dd/yyyy}' -f (Get-Date $fnextstartdate)
        $gnextenddate = '{0:MM/dd/yyyy}' -f (Get-Date $fnextenddate)
        Write-Host "Deleting mail items for $UserPrincipalName from $gnextstartdate to $gnextenddate"
        Search-Mailbox -Identity $UserPrincipalName -SearchQuery "received:$gnextstartdate..$gnextenddate" -DeleteContent -Force
        $fnextstartdate = $fnextenddate.AddDays(1)
        $fnextenddate = $fnextenddate.AddDays($DayRange)
    }
    $gnextstartdate = '{0:MM/dd/yyyy}' -f (Get-Date $fnextstartdate)
    $gnextenddate = '{0:MM/dd/yyyy}' -f (Get-Date $fnextenddate)
    $flastenddate = $fnextstartdate.AddDays($fremainderdays)
    $glastenddate = '{0:MM/dd/yyyy}' -f (Get-Date $flastenddate)
    Write-Host "Deleting from $gnextstartdate to $glastenddate"
    Search-Mailbox -Identity $UserPrincipalName -SearchQuery "received:$gnextstartdate..$gnextenddate" -DeleteContent -Force
}
