# PSObjectWhisperer
A WindowsPowerShell module to simplify working with complex objects.

-Functions-

    Get-PropertyPath
        Description:
            Gets all paths to properties of an object with values of the specified types down to the specied depth.
        Input Types:
            Any
        Output Types:
            String[]
        Example:
            PS C:\Windows\System32> Get-LocalUser Administrator | Get-PropertyPath -Depth 2 -TypeFilter Int32, String, Byte
            AccountExpires
            Description
            Enabled
            FullName
            LastLogon
            Name
            ObjectClass
            PasswordChangeableDate
            PasswordExpires
            PasswordLastSet
            PrincipalSource.value__
            SID.AccountDomainSid.BinaryLength
            SID.AccountDomainSid.Value
            SID.BinaryLength
            SID.Value

    Select-Key
        Description:
            Selects the specified and keys or properties of a hashtable or object and returns only those keys and values.
        Input Types:
            Any
        Output Types:
            HashTable
            PSCustomObject
            OrderedDictionary
        Example:
            PS C:\Windows\System32> @{a=5;b=2;c=54} | Select-Key -Key a,c

            Name                           Value
            ----                           -----
            c                              54
            a                              5

-Aliases-

    Convert-ToObject
        Definition:
            Select-Key
        Parameter Override:
            AsObject -> True
        Example:
        PS C:\Windows\System32> @{a=5;b=2;c=54}|ConvertTo-Object -Key a,c

        a  c
        -  -
        5 54

    ConvertTo-HashTable
        Definition:
            Select-Key
        Parameter Override:
            AsObject -> false
        Example:
        PS C:\Windows\System32> [PsCustomObject]@{a=5;b=2;c=54} | ConvertTo-Hashtable -Key a,c -Ordered

        Name                           Value
        ----                           -----
        a                              5
        c                              54
        