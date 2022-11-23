<#
    Most of System.Collections is chock full of things that support the synchrnonized method when spawned
#>
$syncHashTable = [System.Collections.Hashtable]::Synchronized( @{} )
$syncArrayList = [System.Collections.ArrayList]::Synchronized( @() )
$syncQueue = [System.Collections.Queue]::Synchronized( @() )