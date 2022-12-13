Function Get-IPRange {
    [CmdletBinding()]
    Param(
        [ValidatePattern('^((25[0-5]|(2[0-4]|1\d|[1-9]|)\d)\.?\b){4}\/([8-9]|[1-2]\d|3[1-3])$')]
        [String] $Subnet
    )
    Begin {
        [String] $ip = ( $Subnet -Split '\/' )[0]
        [Int32] $cidr = ( $Subnet -Split '\/' )[1]
        [String[]] $ipBinary = ForEach ( $Octet in ( $ip -Split '\.' ) ) {
            $octetBinary = [Convert]::ToString( $octet,2 )
            $octetBinary = ( '0' *  ( 8 - ( $octetBinary ).Length ) + $octetBinary )
            $octetBinary
        }
        [String] $ipBinary = $ipBinary -Join ''
        [Int32] $hostBits = ( 32 - $cidr )
        [String] $networkID = ( $ipBinary.Substring( 0 , $cidr ) )
        [String] $hostID = ( $ipBinary.Substring( $cidr,$hostBits) ) -Replace ('1','0')
        [Int32] $hostMax = ( [Convert]::ToInt32( ( '1' * $hostBits ), 2 ) - 1 )
    }
    Process {
        $ips = For ( $hostCount = 1;  $hostCount -le $hostMax; $hostCount ++ ) {
            [String] $nextHostBinary = [Convert]::ToString( ( [Convert]::ToInt32( $hostID, 2 ) + $hostCount ), 2 )
            [Int32] $bitExpandZeroCount = $networkId.Length - $nextHostBinary.Length
            [String] $nextHostBinary = ( '0' * $bitExpandZeroCount ) + $nextHostBinary
            [String] $nextIPBinary = $networkID + $nextHostBinary
            [String[]] $ip = For ( $octet = 1; $octet -le 4; $octet ++ ) {
                $startCharacter = ( $octet - 1 ) * 8
                $octBin = $nextIPBinary.Substring( $startCharacter, 8 )
                [Convert]::ToInt32( $octBin,2 )
            }
            $ip -Join '.'
        }
    }
    End {
        Return $ips
    }
}

# Naming Patterns
<# Naming Patterns
    No single letter variables.
    Don't abbreviate variable names
    Don't put types in your variable names, do strong type variables (at least when initiated).
    Do put units in variable names (ms, seconds)
    Avoid utils/helper names, these belong to other base types.
    
#>
<#
    More abstraction = more coupling (not always a bad thing, but needs to be heavily considered)
        if you're just saving yourself from creating a variable, not worth.
        Just saving yourself a line or two? Still not worth it!
    If you have a bunch of different options with complex construction, maybe worth it

#>