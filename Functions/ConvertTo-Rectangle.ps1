[CmdletBinding()]
param (
    [Parameter(
        ValueFromPipeline
    )][Object[]]
    $InputObject
)
begin{
    $Converter = [System.Windows.RectConverter]::New()
}
process{
    Try{
        $ErrorActionPreference = 'Stop'
        $Converter.ConvertFrom($InputObject)
    }Catch{
        Try{
            $Converter.ConvertFrom((
                (
                    "$(
                        'x','Left','y','To','width','right','height','bottom'|
                            Foreach-Object {
                                $InputObject.$_
                            }
                    )$InputObject,0,0,0,0" -split'[^\d]+' -match '\d+'
                )[0..3] -join ','
            ))
        }Catch{
            throw $_.Exception
        }
    }
}