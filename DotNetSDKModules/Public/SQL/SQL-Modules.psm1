Function New-SQLCommand {
    <#
    .SYNOPSIS
    Used to execute a query against a database.
    .PARAMETER SQLConnection
    System.Data.Common.DbConnection - Can use New-SQLConnection to get this.
    .PARAMETER Query
    Used to specify the query that you want to execute.
    .PARAMETER SelectQuery
    Switch parameter, specifies that this is a select query so that ExecuteReader() is used.
    .PARAMETER Columns
    Specifies the columns of the database that you are pulling from.
    .OUTPUTS
    If you run a Select query, [System.Collections.Generic.List[PSCustomObject]]@() of results.
    .NOTES
    11/22/2022 - Decided to actually put proper documentation on these and clean them up!
#>
[CmdletBinding()]
Param (
    [Parameter( Mandatory = $True,
    Position = 0,
    ValueFromPipeline = $True,
    ValueFromRemainingArguments = $True )]
    [Parameter( Mandatory = $True,
    ParameterSetName = 'Select',
    Position = 0,
    ValueFromPipeline = $True,
    ValueFromRemainingArguments = $True )]
    [System.Data.SqlClient.SqlConnection] $SQLConnection,

    [Parameter( Mandatory = $True,
    Position = 1,
    ValueFromPipeline = $True,
    ValueFromRemainingArguments = $True )]
    [Parameter( Mandatory = $True,
    ParameterSetName = 'Select',
    Position = 1,
    ValueFromPipeline = $True,
    ValueFromRemainingArguments = $True )]
    [String] $Query,

    [Parameter (Mandatory = $True,
    ParameterSetName = 'Select')]
    [Switch] $SelectQuery,

    [Parameter (Mandatory = $True,
    ParameterSetName = 'Select',
    Position = 3)]
    [Array] $Columns
)
Begin {
	
    [System.Data.Common.DbCommand] $sqlCommand = [System.Data.SqlClient.SqlCommand]::New( $Query , $SQLConnection )
}
Process {
    If ( $SelectQuery -eq $True ) {
        [System.Data.Common.DbDataReader] $reader = $sqlCommand.ExecuteReader()
    }
    Else {
        $sqlCommand.ExecuteNonQuery() | Out-Null
    }
}
End {
    If ( $SelectQuery -eq $True ) {
        $return = [System.Collections.Generic.List[PSCustomObject]]@()
        While ( $reader.Read() ) {
            $tempObject = [PSCustomObject] @{}

            ForEach ( $column in $Columns ) {
                $tempObject | Add-Member -MemberType 'NoteProperty' -Name $column -Value $reader.GetValue( $reader.GetOrdinal( "$($column)" ) )
            }
            $return.Add( $tempObject ) 
        }
        Return $return
        }
    }
}

Function New-SQLConnection {
    <#
        .SYNOPSIS
        Used to create a System.Data.Common.DbConnection and connect to it, if desired.
        .PARAMETER ConnectionString
        SQL connection string
        .PARAMETER Connect
        Switch parameter, causes the .Open() method to be called prior to being returned.
        .NOTES
        11/22/2022 - Decided to actually put proper documentation on these and clean them up!
    #>
	[OutputType('System.Data.SqlClient.SqlConnection')]
    [CmdletBinding()]
    Param (
        [Parameter(  Mandatory = $True,
        Position = 0,
        ValueFromPipeline = $True,
        ValueFromRemainingArguments = $True )]
		[String] $ConnectionString,
        [Parameter( Mandatory = $False )]
        [Switch] $Connect
    )
    Process {
        [System.Data.SqlClient.SqlConnection] $sqlConnection = [System.Data.SqlClient.SqlConnection]::New( $ConnectionString )
    }
    End {
        If ( $Connect ) {
            Try {
                $sqlConnection.Open()
            }
            Catch {
                Write-Error -Message ( 'Failed to open connection to database -' + $Error[0].ToString() )
            }
        }
        Return $sqlConnection
    }
}
Export-ModuleMember -Function @( 'New-SQLCommand' , 'New-SQLConnection' )