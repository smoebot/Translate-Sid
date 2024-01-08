Function Translate-SID {
<#
    .SYNOPSIS
        Determines User or Group detail from SID
    .DESCRIPTION
        Connects to AD and translates SID via Get-AD-Object, then performs more lookups depending on object class
    .PARAMETER sid
        The sid of the AD-Object that you are looking up
    .INPUTS
        String
    .OUTPUTS
        An object representing the decoded URL and relevant data about the URL
    .NOTES
        Version:        0.1
        Author:         Joel Ashman
        Creation Date:  2020-02-17
        Purpose/Change: Initial script
    .EXAMPLE
        Translate-Sid -sid S-1-5-21-3326329815-2907898539-2989652515-223100
    #>

  # Parameters
  param (
    [Parameter(Mandatory=$True,Position=1)]
        [string]$sid = ""
  )

  # get local GC for doing the AD queries
  $localSite = (Get-ADDomainController -Discover).Site; $newTargetGC = Get-ADDomainController -Discover -Service 6 -SiteName $localSite
  If (!$newTargetGC) {$newTargetGC = Get-ADDomainController -Discover -Service 6 -NextClosestSite}; $localGC = "$($newTargetGC.HostName)" + ":3268"
  $sidResult = (Get-ADObject –IncludeDeletedObjects -Filter "objectSid -eq '$sid'" -properties name, objectclass, isdeleted, modified, objectguid -server $localGC); $guid = $sidResult.objectguid.guid
  if ($sidResult.ObjectClass -eq "user") {
    $userInfo = Get-AdUser -Filter {ObjectGUID -eq $guid} -server $localGC -properties Name, ObjectGUID, DistinguishedName, City, Co, Department, mail, Manager, Title, UserPrincipalName, msExchExtensionAttribute31, msExchExtensionAttribute32, SamAccountName, PasswordLastSet, TelephoneNumber, LastLogonDate, Enabled, WhenCreated
    $userInfo
  }
  elseif ($sidResult.ObjectClass -eq "group") {
    $groupInfo =Get-ADGroup -Filter {ObjectGUID -eq $guid} -server $localGC -properties Name, ObjectGUID, CanonicalName, DistinguishedName, Description, ManagedBy, SamAccountName, Modified, Created
    $groupInfo
  }
  else { # Need a search for Computer and Domain objects In here
    Write-Output "`nSomething isn't right`nTrying a System.Security.Principal.SecurityIdentifier Lookup and Translation`n"
    $objSID = New-Object System.Security.Principal.SecurityIdentifier($sid)
    $objUser = $objSID.Translate([System.Security.Principal.NTAccount]) 
    $unknownDomain = $objSID.AccountDomainSid.value
    $unknownUser = $objUser.value
    Get-ADDomain -Identity $unknownDomain -server ad.example.com
  }
}
