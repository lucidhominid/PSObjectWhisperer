[CmdletBinding()]
param (
    [Parameter()]
    [String[]]
    $Key = "*",

    [Parameter(
        ParameterSetName = 'AsObject'
    )][Switch]
    $AsObject,

    [Parameter(
        ParameterSetName = 'AsObject'
    )][ArgumentCompleter({
        param($commandName,$parameterName,$wordToComplete,$commandAst,$fakeBoundParameters)
        [AppDomain]::CurrentDomain.GetAssemblies().GetTypes() |
            Where-Object {
                $_.Name -like "$wordToComplete*" -or
                $_.FullName -like "$wordToComplete*" 
            } |
            Foreach-Object{
                [System.Management.Automation.CompletionResult]::new(
                    $_.Name,
                    $_.FullName, 
                    'ParameterValue',
                    ($_|Format-List|Out-String)
                )
            }
    })][String]
    $Type = 'PSCustomObject',

    [Parameter(
        ParameterSetName = 'Ordered'
    )][Switch]
    $Ordered,

    [Parameter(
        Mandatory,
        ValueFromPipeline
    )]$InputObject
)
begin{
    
    # Aliases
    Switch($PSCmdlet.MyInvocation.InvocationName){
        'ConvertTo-Object' {
            $AsObject = $true
        }
        'ConvertTo-Hashtable' {
            $AsObject = $false
        }
    }
}
process{

    $Out = ''
    if($Ordered){
        $Out += '[Ordered]'
    }
    $Out += '@{'
    $Pairs = [String[]]$InputObject.Keys + (
        $InputObject |
            Get-Member -MemberType Properties
        ).Name |
        Where-Object {$Key -icontains $_ -or $_ -like $Key}|
        Select-Object -Unique |
        Sort-Object {
            $ThisItem = $_
            0..($Key.Count-1)|
                Where-Object{$Key[$_] -like $ThisItem}|
                Select-Object -first 1
        }|
        ForEach-Object {
            $KeyGuid = New-Guid
            New-Variable -Name $KeyGuid -Value $_
            $ValueGuid = New-Guid
            New-Variable -Name $ValueGuid -Value $(
                if($_ -is [int]){
                    $InputObject[[int]$_]
                }else{
                    $InputObject."$_",,$InputObject["$_"]|
                        Where-Object {$_ -ne $null}|
                        Select-Object -First 1
                }
            )
            
            [PSCustomObject]@{
                AsString = "`${$KeyGuid} = `${$ValueGuid}"
                KeyName  = $_
                KeyValue = Get-Variable $ValueGuid -ValueOnly
            }
        }
    $Out += $Pairs.AsString -join ';'
    $Out += '}'
    if($AsObject){
        try{
            $Result = Invoke-Expression "[$Type]$Out"
            if($Result -notlike "System.Collections.Hashtable"){
                $Result
            }else {
                Throw "BAD!"
            }
        }catch{
            
            $Done = $null
            $ThisType = [AppDomain]::CurrentDomain.GetAssemblies().GetTypes() | 
                Where-Object Name -like $Type
            $ThisType.DeclaredConstructors.GetParameters()|
                Group-Object Member|
                ForEach-Object{
                    if(!$Done){
                        $Arguments = $_.Group |
                            ForEach-Object {
                                $Pairs |
                                    Where-Object KeyValue -Is $_.ParameterType |
                                    Where-Object {$Arguments.Keyname -iNotContains $_.KeyName}  |
                                    Select-Object -First 1
                            }
                        if($Arguments.count -eq $_.Group.count){
                            try{
                                Invoke-Expression "[$Type]::new($(
                                    (
                                        0..($Arguments.count -1)|
                                            Foreach-Object {
                                                "`$Arguments[$_]"
                                            }
                                    )-join','
                                ))"
                                $Done = $true
                            }catch{
                                $Done = $null
                            }
                        }
                    }
                    
                }
        }
    }else {
        Invoke-Expression $Out        
    }
}
