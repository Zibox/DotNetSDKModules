Function New-File {
        <#
        .SYNOPSIS
        Used to create a file (any type)
        .PARAMETER Path
        Used to specify the full path + file name (including extension)
        .PARAMETER OnCreate
        Close will make the object save to disk and release the lock on it
        Stream will pass the object back and hold the lock.
        .PARAMETER Force
        Switch parameter, will bypass the initial check if the file exists.
        .OUTPUTS
        System.Management.Automation.Runspaces.LocalRunspace
        .NOTES
        11/22/2022 - Decided to actually put proper documentation on these and clean them up!
    #>
    [CmdletBinding()]
    Param (
        [Parameter(  Mandatory = $True,
        Position = 0,
        ValueFromPipeline = $True,
        ValueFromRemainingArguments = $True )]
        [String] $Path,

        [Parameter(  Mandatory = $True, Position = 1 )]
        [ValidateSet('Close', 'Stream' )]
        [String] $OnCreate,

        [Parameter(  Mandatory = $False )]
        [Switch] $Force

    )
    Begin {
        $fileError = @{
            'Exception' = $_.Exception
            'Category' = [System.Management.Automation.ErrorCategory]::OperationStopped
            'ErrorId' = 'NewFileError'
            TargetObject = New-Object psobject -Property @{
                Path = $Path
            }
        }
        If ( ( ! $Force )-and ( Test-Path -Path $Path ) ) {
            Write-Error $fileError
            Return
        }
    }
    Process {
        Switch ( $OnCreate ) {
            'Close' {
                ( $file = [System.IO.File]::Create( $Path ) && $file.Close() ) || Write-Error @fileError && Return
            }
            'Stream' {
                $file = [System.IO.File]::Create( $Path ) || Write-Error @fileError && Return
            }
        }
    }
    End {
        If ( $OnCreate -eq 'Stream' ) {
            Return $file
        }
    }
}

Function Expand-String {
    <#
        .SYNOPSIS
        Used to decompress strings via GZipStream, used in conjunction with Compress-String for initial compression.
        .PARAMETER String
        This is the string that you want to decompress.
        .OUTPUTS
        Decompressed string.
        .NOTES
        11/22/2022 - Decided to actually put proper documentation on these and clean them up!
    #>
    [CmdletBinding()]
    Param(
        [Parameter( Mandatory = $True,
        Position = 0,
        ValueFromPipeline = $True,
        ValueFromRemainingArguments = $True )]
        [String] $String
    )
    Process {
        $errorSplat = @{
            'Exception' = $_.Exception
            'Category' = [System.Management.Automation.ErrorCategory]::OperationStopped
            'ErrorId' = 'ExpandString'
            TargetObject = New-Object psobject -Property @{
                String = $String
            }
        }
        $converted = [System.Convert]::FromBase64String( $String ) || ( Write-Error @errorSplat && Return )
        $memoryStream = [System.IO.MemoryStream]::New( )
        ( $memoryStream.Write( $converted, 0, $converted.Length ) && $memoryStream.Seek( 0,0 ) | Out-Null ) || ( Write-Error @errorSplat && Return )

        ( $streamReader = [System.IO.StreamReader]::New( [System.IO.Compression.GZipStream]::New( $memoryStream,
            [System.IO.Compression.CompressionMode]::Decompress ) ) ) || ( Write-Error @errorSplat && Return )
    }
    End {
        $streamReader.ReadToEnd() || ( Write-Error @errorSplat && Return )
    }
}


Function Compress-String {
    <#
        .SYNOPSIS
        Used to compress strings via GZipStream, used in conjunction with Expand-String to re-expand.
        .PARAMETER String
        This is the string that you want to compress.
        .OUTPUTS
        Base64 GzipStream compressed string.
        .NOTES
        11/22/2022 - Decided to actually put proper documentation on these and clean them up!
    #>
    [CmdletBinding()]
    Param (
        [Parameter( Mandatory = $True,
        Position = 0,
        ValueFromPipeline = $True,
        ValueFromRemainingArguments = $True )]
        [String] $String
    )
    Begin {
        $errorSplat = @{
            'Exception' = $_.Exception
            'Category' = [System.Management.Automation.ErrorCategory]::OperationStopped
            'ErrorId' = 'CompressString'
            TargetObject = New-Object psobject -Property @{
                String = $String
            }
        }
        $memoryStream = [System.IO.MemoryStream]::New( )
        $streamWriter = [System.IO.StreamWriter]::New( $( [System.IO.Compression.GZipStream]::New( $memoryStream ,
            [System.IO.Compression.CompressionMode]::Compress ) ) )
        $strPayload = [System.Collections.Generic.List[string]]::new()
    }
    Process {
        # Why did I do this again?
        $strPayload.Add( $String )
    }
    End {
        ( $streamWriter.Write( [String] $strPayload ) && $streamWriter.Close() ) || ( Write-Error @ErrorSplat && Return )
        $return = [System.Convert]::ToBase64String( $memoryStream.ToArray() )
        Return $return
    }
}

Function Test-FileLock {
    <#
    .SYNOPSIS
    
    .PARAMETER InitialSessionState
    Used to specify various parameters for the runspaces inside the pool.
    .PARAMETER MaxThreads
    Used to specify the max number of threads (runspaces)
    .PARAMETER Open
    Used to specify if you want to open the pool on creation.
    .OUTPUTS
    System.Management.Automation.Runspaces.RunspacePool
    .NOTES
    11/22/2022 - Decided to actually put proper documentation on these and clean them up!
#>
Param (
    [Parameter(  Mandatory = $True,
    Position = 0,
    ValueFromPipeline = $True,
    ValueFromRemainingArguments = $True )]
    [String] $Path
)
Process {
    If ( ( Test-Path -Path $Path ) ) {
        Return $False
    }
    Else {
        $fileInfo = [System.IO.FileInfo]::New( $Path )
        Try {
            $fileCheck = $fileInfo.Open( [System.IO.FileMode]::Open, [System.IO.FileAccess]::ReadWrite, [System.IO.FileShare]::None )
            If ( $fileCheck ) {
                $fileCheck.Close()
            }
            Return $False
        } Catch {
            Return $True
        }

    }
    }
}

Export-ModuleMember -Function @( 'Test-FileLock' , 'Compress-String', 'Expand-String', 'New-File' )
