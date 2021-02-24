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
# Only proceed if we have not reached the specified depth
if($InputObject -and $CurrentDepth -le $Depth){
    Write-Verbose "Depth: $CurrentDepth"
    ($InputObject| 
        Get-Member -MemberType Properties).Name | 
        Foreach-Object{
            # Foreach property that's value does not match the TypeFilter. Recursively run this function
            $ThisProp = $_
            if(($InputObject.$_)){
                If($TypeFilter -notcontains ($InputObject.$_).GetType()){
                    $inputObject.$_|
                        Get-PropertyPath -CurrentDepth ($CurrentDepth+1) -Depth $Depth| 
                        ForEach-Object{
                            # Add this property name to the results and join them all with '.'
                            (($ThisProp,$_) -join '.').Trim('.')
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