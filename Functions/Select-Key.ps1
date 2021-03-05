[CmdletBinding()]
param (
    [Parameter()]
    [String[]]
    $Key = "*",

    [Parameter(DontShow)]
    #Planned feature: Cast as any object type.
    #[ValidateScript({
    #    (Invoke-Express "[$_]") -is [Type]
    #})][String]
    [Switch]
    $AsObject <#= 'PSCustomObject'#>,

    [Parameter(DontShow)]
    [Switch]
    $Ordered,

    [Parameter(
        Mandatory,
        ValueFromPipeline
    )]
    $InputObject
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
    if($AsObject){
        $Out += '[PSCustomObject]'
    }elseif($Ordered){
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
            
            "`${$KeyGuid} = `${$ValueGuid}"
        }
    $Out += $Pairs -join ';'
    $Out += '}'
    Invoke-Expression $Out
}
