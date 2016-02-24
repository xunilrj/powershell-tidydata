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

                $new_ | 
                    Add-Member -Name $KeyName -MemberType NoteProperty -Value $measureKey -PassThru | 
                    Add-Member -Name $ValueName -MemberType NoteProperty -Value $measureValue -PassThru
            }            
        }        
	}
}

Set-Alias melt Unpivot-Object