$projectPath = 'E:\Code\DotNetSDKModules'
Set-Location -Path $projectPath
$modules = Get-ChildItem -Path $projectPath -Recurse | Where-Object {$_.Name -like "*.psd1"}
$modules.FullName | ForEach-Object {
    Import-Module -Name $_
}

$threadTotal = '4'

$global:testHash = [System.Collections.Hashtable]::Synchronized( @{} )
0..( $threadTotal - 1 ) | ForEach-Object {
    $testHash[ "$($_)" ] = @()
}
Function Test-Function {
    [CmdletBinding()]
    Param(
        [Int] $MaxNumber
    )
    $return = 1..$MaxNumber
    return $return
}

$testScriptBlock = {
    param ( $i )
    Set-Location 'E:\Code\DotNetSDKModules\Tests\'
    $testHash[ "$($i)" ] = Test-Function -MaxNumber 10000
}


$sessionStateSplat = @{
    Functions = @('Test-Function', 'New-File')
    Variables = 'testHash'
}

$poolSplat = @{
    InitialSessionState =  ( New-InitialSessionStateObject @sessionStateSplat )
    MaxThreads = $threadTotal
    Open = $True
}

$pool = New-RunspacePool @poolSplat

$jobList = ( 0..( $threadTotal - 1 ) ) | ForEach-Object {
    $sbSplat = @{
        ScriptBlock = $testScriptBlock
        Parameters = @{ i = $_ }
        RunSpacePool = $pool
    }
    $tempObject = New-PowerShellSBObject @sbSplat
    Invoke-PowerShellObject -PowerShellObject $tempObject -Asynchronous
}

$testHash

<#
    Name                           Value
    ----                           -----
    0                              {1, 2, 3, 4…}
    1                              {1, 2, 3, 4…}
    3                              {1, 2, 3, 4…}
    2                              {1, 2, 3, 4…}
#>

# Need to build New-ObjectLock test out and get this all pesterified