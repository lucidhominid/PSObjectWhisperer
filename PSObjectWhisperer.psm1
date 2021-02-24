$ModuleRootPath =  Split-Path -Path $MyInvocation.MyCommand.Path
$ModuleName     = (Split-Path -Path $ModuleRootPath -Leaf) #-replace '\.ps1(?=$)'
$Global:_PSAutoToolNamespace = Add-type -Path $ModuleRootPath\$ModuleName.cs -ReferencedAssemblies System.Drawing -PassThru

Get-ChildItem $ModuleRootPath\Functions -filter *.ps1 | 
    ForEach-Object{
        .(
            [Scriptblock]::Create(
                "Function $($_.Name -replace '\.ps1'){$((Get-Content $_.FullName) -join "`n")}"
            )
        )
    }
