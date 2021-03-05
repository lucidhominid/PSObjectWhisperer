$ModuleRootPath =  Split-Path -Path $MyInvocation.MyCommand.Path
Get-ChildItem $ModuleRootPath\Functions -filter *.ps1 | 
    ForEach-Object{
            $ThisFunctionName = $_.Name -replace '\.ps1'
            $ThisFunction = [Scriptblock]::Create(
                "Function $ThisFunctionName {$((Get-Content $_.FullName) -join "`n")}"
            )
            .$ThisFunction
            ($ThisFunction.ast.EndBlock.statements.body.beginblock.Statements| 
                Where-Object {
                    $_.condition.extent.text -like "`$PSCmdlet.MyInvocation.InvocationName"
                }).Clauses.Item1.Value|
                Where-Object {$_ -ne $null}|
                ForEach-Object{
                    New-Alias -Name $_ -Value $ThisFunctionName -Force
                }
    }
