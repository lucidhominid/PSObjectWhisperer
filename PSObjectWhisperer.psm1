$ModuleRootPath =  Split-Path -Path $MyInvocation.MyCommand.Path

Get-ChildItem $ModuleRootPath\Functions -filter *.ps1 | 
    ForEach-Object{
        .(
            [Scriptblock]::Create(
                "Function $($_.Name -replace '\.ps1'){$((Get-Content $_.FullName) -join "`n")}"
            )
        )
    }
