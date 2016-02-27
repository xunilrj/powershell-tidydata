filter Unpivot-Object{    
	param($Measures, $KeyName = 'Key', $ValueName = 'Value', $As, [ScriptBlock]$TransformKey, [ScriptBlock]$TransformValue)
    begin{
        if($As -ne $null){
            $KeyName = $As[0]
            $ValueName = $As[1]
        }
    }
	process{
        foreach($measure in $Measures){
            if($_ -is [PSCustomObject]){
                $new_ = $_ | ConvertTo-Json -Depth 10 | ConvertFrom-Json
                $measureProp = $new_.PsObject.Properties[$measure]

                foreach($toRemove in $Measures){ $new_.PsObject.Members.Remove($toRemove) | Out-Null }

                $measureKey = $measureProp.Name
                $measureValue = $measureProp.Value
                
                if($TransformKey -ne $null){
                    $context = New-Object System.Collections.Generic.List[PSVariable]
                    $context.Add((New-Object "PSVariable" @("_", $measureKey)))
                    $measureKey = $TransformKey.InvokeWithContext(@{}, $context)[0]
                }

                if($TransformValue -ne $null){
                    $context = New-Object System.Collections.Generic.List[PSVariable]
                    $context.Add((New-Object "PSVariable" @("_", $measureValue)))
                    $measureValue = $TransformValue.InvokeWithContext(@{}, $context)[0]
                }   
                
                if($measureKey -ne $null){
                    Write-Verbose $measureKey.GetType()             
                }

                if($measureKey -is [System.Collections.Hashtable]){
                    foreach($key in $measureKey.Keys){
                        $p = $measureKey[$key]
                        $new_ | Add-Member -Name $key -MemberType NoteProperty -Value $p | Out-Null
                    }                    
                }
                else{
                    $new_ | Add-Member -Name $KeyName -MemberType NoteProperty -Value $measureKey -PassThru | Out-Null
                }

                $new_ | Add-Member -Name $ValueName -MemberType NoteProperty -Value $measureValue -PassThru
            }            
        }        
	}
}

filter Transform-Member{
    [CmdletBinding()]
    param(
    [Parameter(Position = 0)]
    $Name, 
    [Parameter(Position = 1)]
    $Transformation,        
    [Parameter(ValueFromPipeline = $true)]
    $Input)    
    process{
        $new_ = $_ | ConvertTo-Json -Depth 10 | ConvertFrom-Json
        $prop = $new_.PsObject.Properties[$Name]

        $new_.PsObject.Members.Remove($Name) | Out-Null 

        $propKey = $prop.Name
        $propValue = $prop.Value

        $transformed = $null

        if($Transformation -is [ScriptBlock]){
            $context = New-Object System.Collections.Generic.List[PSVariable]
            $context.Add((New-Object "PSVariable" @("_", $propValue)))
            $transformed = $Transformation.InvokeWithContext(@{}, $context)[0]
        }elseif ($Transformation -is [HashTable]){
            if($Transformation.ContainsKey($propValue)){
                $transformed = $Transformation[$propValue]
            }
            else{
                $transformed = $propValue
            }
        }
        
        if($transformed -is [System.Collections.Hashtable]){
            foreach($key in $transformed.Keys){
                $value = $transformed[$key]
                $new_ | Add-Member -Name $key -MemberType NoteProperty -Value $value | Out-Null
            }                    
        }
        else{
            $new_ | Add-Member -Name $propKey -MemberType NoteProperty -Value $transformed -PassThru | Out-Null
        }

        $new_
    }
}

filter Split-Member{
    [CmdletBinding()]
    param(
    [Parameter(Position = 0)]
    $Name, 
    [Parameter(Position = 1)]
    $Regex,
    [Parameter(ValueFromPipeline = $true)]
    $Input)
    begin{
        $r = [regex]::new($Regex)
    }
    process{
       $_ | Transform-Member $Name {
            $result = $r.Matches($_)
            $hash = @{}
            foreach($item in $r.GetGroupNames()){
                if($item -eq "0") {continue}

                $hash.Add($item, $result.Groups[ $r.GroupNumberFromName($item) ].Value)
            }

            $hash
       } 
    }
}

filter Rename-Member{
    [CmdletBinding()]
    param(
    [Parameter(Position = 0)]
    $Name, 
    [Parameter(Position = 1)]
    $As,
    [Parameter(ValueFromPipeline = $true)]
    $Input)    
    process{
        $prop = $_.PsObject.Properties[$Name]
        $_.PsObject.Members.Remove($Name) | Out-Null 

        $_ | Add-Member -Name $As -Value $prop.Value -MemberType NoteProperty -PassThru
    }
}

filter Cast-Member{    
    [CmdletBinding()]
    param(
    [Parameter(Position = 0)]
    $Name, 
    [Parameter(Position = 1)]
    $Type,
    [Parameter(ValueFromPipeline = $true)]
    $Input)
    begin{
        $Type = $Type -as [Type]
    }
    process{
        $_ | Transform-Member $Name {
                if($_ -ne $null ) {[System.Convert]::ChangeType($_, $Type)}
                else {$_}
             }
    }
}

Set-Alias melt Unpivot-Object
Set-Alias lookup Transform-Member
Set-Alias rename Rename-Member
Set-Alias cast Cast-Member