function Remove-MailboxItems () {

    param (
        [Parameter(Mandatory)]
        [string[]]$StartDate,
        [Parameter(Mandatory)]
        [string[]]$EndDate,
        [Parameter(Mandatory)]
        [string[]]$UserPrincipalName,
        [Parameter(Mandatory)]
        [int[]]$DayRange
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
        $gnextstartdate = Get-Date $fnextstartdate -Format MM/dd/yyyy
        $gnextenddate = Get-Date $fnextenddate -Format MM/dd/yyyy
        Write-Host "Deleting from $gnextstartdate to $gnextenddate"
        Search-Mailbox -Identity $UserPrincipalName -SearchQuery {received:$gnextstartdate..$gnextenddate} -DeleteContent -Force
        $fnextstartdate = $fnextenddate.AddDays(1)
        $fnextenddate = $fnextenddate.AddDays($DayRange)
    }
    $gnextstartdate = Get-Date $fnextstartdate -Format MM/dd/yyyy
    $gnextenddate = Get-Date $fnextenddate -Format MM/dd/yyyy
    $flastenddate = $fnextstartdate.AddDays($fremainderdays)
    $glastenddate = Get-Date $flastenddate -Format MM/dd/yyyy
    Write-Host "Deleting from $gnextstartdate to $glastenddate"
    Search-Mailbox -Identity $UserPrincipalName -SearchQuery {received:$gnextstartdate..$gnextenddate} -DeleteContent -Force
}
