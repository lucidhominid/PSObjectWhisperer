[CmdletBinding()]
param (
    [Parameter()]
    [String[]]
    $Keys,

    [Parameter()]
    #Planned feature: Cast as any object type.
    #[ValidateScript({
    #    (Invoke-Express "[$_]") -is [Type]
    #})][String]
    [Switch]
    $AsObject <#= 'PSCustomObject'#>,

    [Parameter()]
    [Switch]
    $Ordered,

    [Parameter(
        Mandatory,
        ValueFromPipeline
    )]
    $InputObject
)
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
        Where-Object {$Keys -icontains $_ -or $_ -like $Keys}|
        Select-Object -Unique |
        Sort-Object {
            $ThisItem = $_
            0..($Keys.Count-1)|
                Where-Object{$Keys[$_] -like $ThisItem}|
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
