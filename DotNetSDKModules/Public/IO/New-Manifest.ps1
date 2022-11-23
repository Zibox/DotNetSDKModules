$manifestSplat = @{
    GUID = 'ec07388f-9b3e-4612-b943-eba4400f29b1'
    Path = '.\Public\IO\IO-Modules.psd1'
    RootModule = '.\Public\IO\IO-Modules.psm1'
    Author = 'Zibok - Michael Ashe'
    CompanyName = 'Zibok - Michael Ashe'
    Description = 'Set of tools utilizing the System.IO .NET class to do file creation, lock testing and stream compression'
    FunctionsToExport = @( 'New-File' , 'Expand-String', 'Compress-String', 'Test-FileLock' )
    CmdletsToExport = ''
    VariablesToExport = ''
    AliasesToExport = ''
}

New-ModuleManifest @manifestSplat