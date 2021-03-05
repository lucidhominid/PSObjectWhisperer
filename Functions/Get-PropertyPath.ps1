[CmdletBinding()]
param (
    #Parameter: InputObject - The object to assess.
    [Parameter(ValueFromPipeline)]
    $InputObject,
    #Parameter: Depth - Maximum property path depth
    [Parameter()]
    [int]$Depth = 10,
    #Parameter: TypeFilter - Types specified in this array will not have their properties expanded
    [Parameter()]
    [Type[]]$TypeFilter = ([String],[Int],[Double],[Decimal],[Float]),
    #Hidden Parameter: Level - Tracks the current depth level. Starts at 0
    [Parameter(DontShow)]
    [Int]$CurrentDepth = 0
)
#Convert hastables to a custom object so they can be worked with as well.
if($InputObject -is [Hashtable]){
    $ProcessObject = $InputObject |
        Select-Key $InputObject.Keys -AsObject
}else{
    $ProcessObject = $InputObject
}
# Only proceed if we have not reached the specified depth.
if($ProcessObject -and $CurrentDepth -le $Depth){
    Write-Verbose "Depth: $CurrentDepth"
    ($ProcessObject| 
        Get-Member -MemberType Properties).Name | 
        Foreach-Object{
            # Foreach property that's value does not match the TypeFilter. Recursively run this function
            $ThisProp = $_
            if(($ProcessObject.$_)){
                If($TypeFilter -notcontains ($ProcessObject.$_).GetType()){
                    $ProcessObject.$_|
                        Get-PropertyPath -CurrentDepth ($CurrentDepth+1) -Depth $Depth|
                        Select-Object -Unique | 
                        ForEach-Object{
                            # Add this property name to the results and join them all with '.'
                            if($_ -notlike "$ThisProp*"){
                                (($ThisProp,$_) -join '.').Trim('.')
                            }
                        }
                }
                else{
                    # Output the property name
                    $_
                }
            }else{
                # Output the property name
                $_
            }
        }   
}else{
    # Done!
    Write-Verbose "Maximum Depth Reached!"
}