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
$stopwatch =  [system.diagnostics.stopwatch]::StartNew()
$threadtotal = 10
$testDataSB = { $testData = ( 1..1000000 ) | ForEach-Object { Get-Random } }
$projectPath = 'E:\Code\DotNetSDKModules'
Set-Location -Path $projectPath
$modules = Get-ChildItem -Path $projectPath -Recurse | Where-Object {$_.Name -like "*.psd1"}
$modules.FullName | ForEach-Object {
    Import-Module -Name $_
}

$poolSplat = @{
    InitialSessionState =  ( New-InitialSessionStateObject)
    MaxThreads = '10'
    Open = $True
}

$pool = New-RunspacePool @poolSplat

$jobList = ( 0..( $threadTotal - 1 ) ) | ForEach-Object {
    $sbSplat = @{
        ScriptBlock = $testDataSB
        RunSpacePool = $pool

    }
    $tempObject = New-PowerShellSBObject @sbSplat
    Invoke-PowerShellObject -PowerShellObject $tempObject -Asynchronous
}

While ($jobList.runspace.IsCompleted -contains $False) {}
$stopwatch.Stop()

# IsRunning Elapsed          ElapsedMilliseconds ElapsedTicks
#--------- -------          ------------------- ------------
# False 00:00:22.0193512               22019    220193512
$testDataSB = { $testData = ( 1..1000000 ) | ForEach-Object { Get-Random } }
$stopwatch =  [system.diagnostics.stopwatch]::StartNew()
$jobs = (1..10) | ForEach-Object {
        Start-Job -ScriptBlock $testDataSB
    }
while ($jobs.State -contains $running) {}
$stopwatch.Stop()


# Need to build New-ObjectLock test out and get this all pesterified

