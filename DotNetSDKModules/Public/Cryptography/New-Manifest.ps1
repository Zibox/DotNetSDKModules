$manifestSplat = @{
    GUID = '39b22242-d0ad-434a-abb5-1eaccb78b63c'
    Path = '.\Public\Cryptography\Cryptography-Modules.psd1'
    RootModule = '.\Public\Cryptography\Cryptography-Modules.psm1'
    Author = 'Zibok - Michael Ashe'
    CompanyName = 'Zibok - Michael Ashe'
    Description = 'Grants ability to generate and decrypt SecureStrings'
    FunctionsToExport = @( 'New-SecureString' , 'Start-SecureStringDecrypt' )
    CmdletsToExport = ''
    VariablesToExport = ''
    AliasesToExport = ''
}

New-ModuleManifest @manifestSplat