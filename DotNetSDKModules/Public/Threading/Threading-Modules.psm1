Function Invoke-PowerShellObject {
    <#
        .SYNOPSIS
        Used to invoke powershell objects inside of their runspaces
        .PARAMETER PowershellObject
        Can use New-PowerShellObject to create these more easily, contains your scriptblocks/params/etc
        .PARAMETER Asynchronous
        Switch param, changes your runspaces to use .BeginInvoke() instead of .Invoke(), must use .EndInvoke() to return output.
        .OUTPUTS
        [PSCustomObject]
        .NOTES
        11/22/2022 - Decided to actually put proper documentation on these and clean them up!
    #>
    [CmdletBinding()]
    Param (
        [Parameter(  Mandatory = $True,
        Position = 0,
        ValueFromPipeline = $True,
        ValueFromRemainingArguments = $True )]
        [System.Management.Automation.PowerShell] $PowerShellObject,

        [Parameter(  Mandatory = $False, Position = 1 )]
        [Switch] $Asynchronous
    )
    Process {
        If ( $Asynchronous ){
            $tempObject = [PSCustomObject] @{
                Runspace = $PowerShellObject.BeginInvoke()
                Powershell = $PowerShellObject
            }
        }
        Else {
            $tempObject = [PSCustomObject] @{
                Runspace = $PowerShellObject.Invoke()
                Powershell = $PowerShellObject
            }
        }
    }
    End {
        Return $tempObject
    }
}


Function New-InitialSessionStateObject {
    <#
        .SYNOPSIS
        Used to generate InitialSessionState class objects for runspaces. Need to expand this out
        but primarily for now I have been binding custom types/calling assemblies/etc via the
        powershell object scripts on invoke.
        .PARAMETER ApartmentState
        Used to define the apartment state of a thread, Enum ApartmentState
            MTA 	    1 	The Thread will create and enter a multithreaded apartment.
            STA 	    0 	The Thread will create and enter a single-threaded apartment.
            Unknown 	2 	The ApartmentState property has not been set.
        .NET doesn't use these but if you are calling COM classes, they do.
        https://learn.microsoft.com/en-us/dotnet/api/system.threading.apartmentstate?view=net-7.0
        .PARAMETER ThreadOptions
        This property determines whether a new thread is created for each invocation of a command.
        Enum PSThread Options
        https://learn.microsoft.com/en-us/dotnet/api/system.management.automation.runspaces.psthreadoptions?view=powershellsdk-7.2.0
        .PARAMETER Functions
        Provide a list of functions that you want to import into the runspace from your current session.
            This is bound to the 'commands' property, can expand this to include alias's, cmdlets, scripts, etc.
            [System.Management.Automation.Runspaces.SessionStateAliasEntry]
            [System.Management.Automation.Runspaces.SessionStateApplicationEntry]
            [System.Management.Automation.Runspaces.SessionStateAssemblyEntry]     
            [System.Management.Automation.Runspaces.SessionStateCmdletEntry]   
            [System.Management.Automation.Runspaces.SessionStateCommandEntry]
            [System.Management.Automation.Runspaces.SessionStateFormatEntry]
            [System.Management.Automation.Runspaces.SessionStateProviderEntry]
            [System.Management.Automation.Runspaces.SessionStateScriptEntry]
            [System.Management.Automation.Runspaces.SessionStateTypeEntry] 
        .PARAMETER Variables
        Provide a list of variables to import into the runspace.
        .OUTPUTS
        Returns a [System.Management.Automation.Runspaces.InitialSessionState] with specified properties/imports.
        .NOTES
        11/22/2022 - Decided to actually put proper documentation on these and clean them up!
    #>
    [CmdletBinding()]
    Param (
        [Parameter( Mandatory = $False )]
        [ValidateSet( 'MTA', 'STA' )]
        [String] $ApartmentState,
        [Parameter( Mandatory = $False )]
        [ValidateSet( 'Default', 'ReuseThread', 'UseCurrentThread', 'UseNewThread' )]
        [String] $ThreadOptions,
        [Parameter( Mandatory = $False )]
        [Array] $Functions,
        [Parameter( Mandatory = $False )]
        [Array] $Variables
    )
    Begin {
        $initialSessionState = [System.Management.Automation.Runspaces.InitialSessionState]::CreateDefault()
        If ( $ApartmentState ) {
            $initialSessionState.ApartmentState = $ApartmentState
        }
        If ( $ThreadOptions ) {
            $initialSessionState.ThreadOptions = $ThreadOptions
        }
        Else {
            $initialSessionState.ThreadOptions = 'Default'
        }
    }
    Process {
        If ( $Functions ) {
            $Functions | ForEach-Object {
                $initialSessionState.Commands.Add( ( [System.Management.Automation.Runspaces.SessionStateFunctionEntry]::New( $_ ,
                    ( Get-Content function:\"$( $_ )" ) ) ) )
            }
        }
        If ( $Variables ) {
            $Variables | ForEach-Object {
                $initialSessionState.Variables.Add( ( [System.Management.Automation.Runspaces.SessionStateVariableEntry]::New( $_ ,
                    ( Get-Variable -Name $_ ).Value , $null ) ) )
            }
        }
    }
    End {
        Return $initialSessionState
    }
}

Function New-ObjectLock {
    <#
        .SYNOPSIS
        Used to lock an object to a thread for the duration of a scriptblock execution.
        .PARAMETER Object
        This is your input object that you want to lock.
        .PARAMETER ScriptBlock
        This is the scriptblock that you want to execute
        .OUTPUTS
        None
        .NOTES
        11/22/2022 - Decided to actually put proper documentation on these and clean them up!
    #>
    [CmdletBinding()]
    Param (
        [Parameter( Mandatory = $True,
        Position = 0,
        ValueFromPipeline = $True,
        ValueFromRemainingArguments = $True )]
        $Object,

        [Parameter( Mandatory = $True,
        Position = 1,
        ValueFromPipeline = $True,
        ValueFromRemainingArguments = $True )]
        [ScriptBlock] $ScriptBlock
    )
    Process {
        $lockError = @{
            'Exception' = $_.Exception
            'Category' = [System.Management.Automation.ErrorCategory]::OperationStopped
            'ErrorId' = 'ThreadLockError'
            TargetObject = New-Object psobject -Property @{
                ScriptBlock = $_ScriptBlock
                Object = $_Object
            }
        }
        $threadId = [System.Threading.Thread]::CurrentThread.ManagedThreadId
        ( Set-Variable -Scope 'Private' -Name '_Object' -Value $Object -Option 'ReadOnly' -Force ) || ( Write-Error @lockError && Return )
        ( Set-Variable -Scope 'Private' -Name '_ScriptBlock' -Value $ScriptBlock -Option 'ReadOnly' -Force ) || ( Write-Error @lockError && Return )

        ( Set-Variable -Scope 'Private' -Name 'threadId' -Value $threadId -Option 'ReadOnly' -Force) || ( Write-Error @lockError && Return )
        ( Set-Variable -Scope 'Private' -Name 'locked' -Value $false -Option 'ReadOnly' -Force ) || ( Write-Error @lockError && Return )
        

        $lockSuccess = "Thread $( $threadId ) is locked on object $( $_inputObject )"
        $unlockSuccess = "Thread $( $threadId ) lock removed on object $( $_inputObject )"

        ( ( [System.Threading.Monitor]::Enter( $Object ) && ( $locked = $True ) ) || Write-Error @lockError && Return ) && Write-Verbose $lockSuccess
        ( . $ScriptBlock || Write-Error @lockError && Return ) && Write-Verbose "Successfully executed script block on $( $threadId )" 
        ( If ( $locked -eq $True ) {
            [System.Threading.Monitor]::Enter( $Exit ) && Write-Verbose $unlockSuccess } ) || Write-Error @lockError && Return
    }
}

Function New-PowerShellSBObject {
    <#
        .SYNOPSIS
        Creates a [System.Management.Automation.PowerShell] type object, binds a scriptblock + params to it.
        .PARAMETER ScriptBlock
        ScriptBlock object to bind to System.Management.Automation.PowerShell object
        .PARAMETER Parameters
        Hashtable of parameters that belong with the scriptblock parameter.
        .PARAMETER Runspace
        Adds a runspace to the powershell object
        .PARAMETER RunspacePool
        Adds a runspace pool to the powershell object.
        .OUTPUTS
        System.Management.Automation.PowerShell
        .NOTES
        11/22/2022 - Decided to actually put proper documentation on these and clean them up!
    #>
    [CmdletBinding()]
    Param (
        [Parameter(  Mandatory = $True,
        Position = 0,
        ValueFromPipeline = $True,
        ValueFromRemainingArguments = $True )]
        [ScriptBlock] $ScriptBlock,

        [Parameter(  Mandatory = $False,
        Position = 1,
        ValueFromPipeline = $True,
        ValueFromRemainingArguments = $True )]
        [Hashtable] $Parameters,

        [Parameter(  Mandatory = $True,
        ParameterSetName = 'Runspace',
        Position = 2,
        ValueFromPipeline = $True,
        ValueFromRemainingArguments = $True )]
        [System.Management.Automation.Runspaces.Runspace] $Runspace,

        [Parameter(  Mandatory = $True,
        ParameterSetName = 'RunspacePool',
        Position = 2,
        ValueFromPipeline = $True,
        ValueFromRemainingArguments = $True )]
        [System.Management.Automation.Runspaces.RunspacePool] $RunspacePool
    )
    Process {
        [System.Management.Automation.PowerShell] $powershell = [Powershell]::Create()
        If ( $Parameters ) {
            [void]( $powershell.AddScript( $ScriptBlock ).AddParameters( $Parameters ) )
        }
        Else {
            [void]( $powershell.AddScript( $ScriptBlock ) )
        }
        If ( $Runspace ) {
            $powershell.Runspace = $Runspace
        }
        If ( $RunspacePool ) {
            $powershell.RunspacePool = $RunspacePool
        }
    }
    End {
        Return $powershell
    }
}

Function New-Runspace {
    <#
        .SYNOPSIS
        Used to create a new Runspace object, local only currently.
        .PARAMETER InitialSessionState
        Used to specify various parameters for the runspace.
        .PARAMETER Open
        Used to specify if you want to open the runspace on creation.
        .OUTPUTS
        System.Management.Automation.Runspaces.LocalRunspace
        .NOTES
        11/22/2022 - Decided to actually put proper documentation on these and clean them up!
    #>
    [CmdletBinding()]
    Param(
        [InitialSessionState] $InitialSessionState,
        [Switch] $Open
    )
    Process {
        [System.Management.Automation.Runspaces.LocalRunspace] $runspace = [RunspaceFactory]::CreateRunspace( $InitialSessionState )
    }
    End {
        If ( $Open ) {
            $runspace.Open()
        }
        Return $runspace
    }
}

Function New-RunspacePool {
    <#
        .SYNOPSIS
        Used to create a new Runspace Pool object
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
    [CmdletBinding()]
    Param(
        [Parameter( Mandatory = $True,
        Position = 0,
        ValueFromPipeline = $True,
        ValueFromRemainingArguments = $True )]
        [System.Management.Automation.Runspaces.InitialSessionState] $InitialSessionState,
        
        [Parameter( Mandatory = $True,
        Position = 1,
        ValueFromPipeline = $True,
        ValueFromRemainingArguments = $True )]
        [Int] $MaxThreads,

        [Parameter( Mandatory = $False )]
        [Switch] $Open
    )
    Process {
        [System.Management.Automation.Runspaces.RunspacePool] $pool = [RunspaceFactory]::CreateRunspacePool( 1, $MaxThreads, $InitialSessionState, $host )
    }
    End {
        If ( $Open ) {
            $pool.Open()
        }
        Return $pool
    }
}

Export-ModuleMember -Function @( 'New-RunspacePool' , 'New-Runspace', 'New-PowerShellSBObject', 'New-ObjectLock', 'New-InitialSessionStateObject', 'Invoke-PowerShellObject' )