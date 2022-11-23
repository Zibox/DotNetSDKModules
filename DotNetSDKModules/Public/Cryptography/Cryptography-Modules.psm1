Function New-SecureString {
    <#
        .SYNOPSIS
        Lazy way to send string and convert to secure string.
        .PARAMETER String 
        The string... you want to make secure!
        .OUTPUTS
        [SecureString]
        .NOTES
        11/22/2022 - Decided to actually put proper documentation on these and clean them up!
    #>
    [CmdletBinding()]
    Param(
        [Parameter(  Mandatory = $True,
        Position = 0,
        ValueFromPipeline = $True,
        ValueFromRemainingArguments = $True )]
        [String] $String
    )
    Process {
        $secString = $String | ConvertTo-SecureString -AsPlainText -Force
        Return $secString
    }
}

Function Start-SecureStringDecrypt {
    <#
        .SYNOPSIS
        Lazy way to send string and convert to secure string.
        .PARAMETER String 
        The string... you want to make secure!
        .OUTPUTS
        [SecureString]
        .NOTES
        11/22/2022 - Decided to actually put proper documentation on these and clean them up!
    #>
[CmdletBinding()]
Param (
    [Parameter(  Mandatory = $True,
    Position = 0,
    ValueFromPipeline = $True,
    ValueFromRemainingArguments = $True )]
    [SecureString] $SecureString
)
Process {
    $bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR( $SecureString )
    $ptr = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto( $bstr )
    Return $ptr
    }
}

Export-ModuleMember -Function @( 'New-SecureString' , 'Start-SecureStringDecrypt' )