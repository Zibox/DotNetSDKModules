$manifestSplat = @{
    GUID = '28f3fb90-6fa8-45ea-84a6-e04749f4db8f'
    Path = '.\Public\Threading\Threading-Modules.psd1'
    RootModule = '.\Public\Threading\Threading-Modules.psm1'
    Author = 'Zibok - Michael Ashe'
    CompanyName = 'Zibok - Michael Ashe'
    Description = 'Set of functions for making with runspaces and multi-threaded workloads easier '
    FunctionsToExport = @( 'Invoke-PowerShellObject' , 'New-InitialSessionStateObject', 'New-ObjectLock', 'New-PowerShellSBObject', 'New-Runspace', 'New-RunspacePool' )
    CmdletsToExport = ''
    VariablesToExport = ''
    AliasesToExport = ''
}

New-ModuleManifest @manifestSplat