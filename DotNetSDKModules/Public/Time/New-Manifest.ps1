$manifestSplat = @{
    GUID = 'fd5aeeb7-a097-4268-8b5a-c398a8143fb7'
    Path = '.\Public\Time\Time-Modules.psd1'
    RootModule = '.\Public\Time\Time-Modules.psm1'
    Author = 'Zibok - Michael Ashe'
    CompanyName = 'Zibok - Michael Ashe'
    Description = 'Set of functions for helping with millis time - will expand out with more stuff later! '
    FunctionsToExport = @( 'Get-Millis', 'Convert-FromMillis' )
    CmdletsToExport = ''
    VariablesToExport = ''
    AliasesToExport = ''
}

New-ModuleManifest @manifestSplat