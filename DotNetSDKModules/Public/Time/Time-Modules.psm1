Function Get-Millis {
    Param (
        $unixtimeStamp
    )
    $epochStart = Get-Date 01.01.1970
    $millisStamp = ($epochStart + ([System.TimeSpan]::frommilliseconds($unixTimeStamp))).ToLocalTime()
    $millisStampOutput = $millisStamp.ToString("yyyy-MM-dd HH:mm:ss.ffffff")
    return $millisStampOutput
}
Function Convert-FromMillis {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $True, Position = 0)]
        [ValidateLength(19,19)]
        [String] $Millis
    )
    Process {
        $temp = [System.DateTimeOffset]::FromUnixTimeMilliseconds( $Millis / 1000000 )
    }
    End {
        return $temp.LocalDateTime
    }    
}