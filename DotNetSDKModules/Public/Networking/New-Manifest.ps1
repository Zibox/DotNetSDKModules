$manifestSplat = @{
    GUID = '5b7b08da-1179-4a61-b1f8-b62357310cbd'
    Path = '.\Public\Networking\Network-Modules.psd1'
    RootModule = '.\Public\Networking\Network-Modules.psm1'
    Author = 'Zibok - Michael Ashe'
    CompanyName = 'Zibok - Michael Ashe'
    Description = 'Set of functions for helping with networking needs'
    FunctionsToExport = @( 'Get-IPRange' )
    CmdletsToExport = ''
    VariablesToExport = ''
    AliasesToExport = ''
}

New-ModuleManifest @manifestSplat