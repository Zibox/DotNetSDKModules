$manifestSplat = @{
    GUID = 'cad2e3ff-57ae-4170-ba5c-77db603f8b54'
    Path = '.\Public\SQL\SQL-Modules.psd1'
    RootModule = '.\Public\SQL\SQL-Modules.psm1'
    Author = 'Zibok - Michael Ashe'
    CompanyName = 'Zibok - Michael Ashe'
    Description = 'Set of functions for connecting via the SqlClient.SqlConnection class and executing queries via SqlClient.SqlCommand '
    FunctionsToExport = @( 'New-SQLCommand' , 'New-SqlConnection' )
    CmdletsToExport = ''
    VariablesToExport = ''
    AliasesToExport = ''
}

New-ModuleManifest @manifestSplat