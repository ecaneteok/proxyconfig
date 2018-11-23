# .\ProxyConfig.ps1 -s -Proxy 172.31.255.22:8080 -acs "http://xxxxxx:8080/proxy.pac"
# .\ProxyConfig.ps1 -u
[CmdletBinding()]
Param(
    [Parameter(Mandatory = $False, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = "UnSetProxy")]
    [AllowEmptyString()]
    [Switch]$u,
    [Parameter(Mandatory = $False, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = "SetProxy")]
    [AllowEmptyString()]
    [Switch]$s,
    [Parameter(Mandatory = $False, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = "UnSetProxy")]
    [Parameter(Mandatory = $True, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = "SetProxy")]        
    [String[]]$Proxy,
    [Parameter(Mandatory = $False, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = "SetProxy")]
    [AllowEmptyString()]
    [String[]]$acs                      
)

Begin {
    $regKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings"        
}
    
Process {
    if ($s) {
        Set-ItemProperty -path $regKey ProxyEnable -value 1
        Write-Output "Set Windows Config ProxyEnable 1"
        Set-ItemProperty -path $regKey ProxyServer -value $proxy                            
        Write-Output "Set Windows Config ProxyServer $proxy"
        if ($acs) {                        
            Set-ItemProperty -path $regKey AutoConfigURL -Value $acs          
            Write-Output "Set Windows Config AutoConfigURL $acs"
        }

        [Environment]::SetEnvironmentVariable("http_proxy", "http://$proxy", "Machine");
        Write-Output "Set Environment Variable (Machine) http_proxy 'http://$proxy'"
        [Environment]::SetEnvironmentVariable("https_proxy", "http://$proxy", "Machine");
        Write-Output "Set Environment Variable (Machine) https_proxy 'http://$proxy'"

        .\nuget.exe config -set http_proxy=http://$proxy
        Write-Output "Set NuGet http_proxy http://$proxy"
        .\nuget.exe config -set https_proxy=http://$proxy
        Write-Output "Set NuGet https_proxy http://$proxy"

        npm config set proxy http://$proxy
        Write-Output "Set NPM http_proxy http://$proxy"
        npm config set https-proxy http://$proxy
        Write-Output "Set NPM https_proxy http://$proxy"

        git config --global http.proxy http://$proxy
        Write-Output "Set GIT http_proxy http://$proxy"
        git config --global https.proxy http://$proxy
        Write-Output "Set GIT https_proxy http://$proxy"
    }
    elseif ($u) {
        Set-ItemProperty -path $regKey ProxyEnable -value 0
        Write-Output "Set Windows Config ProxyEnable 0"
        [Environment]::SetEnvironmentVariable("http_proxy", $null, "Machine");
        Write-Output "Set Environment Variable (Machine) http_proxy 'NULL'"
        [Environment]::SetEnvironmentVariable("https_proxy", $null, "Machine");
        Write-Output "Set Environment Variable (Machine) https_proxy 'NULL'"

        .\nuget.exe config -set http_proxy=
        Write-Output "Set NuGet http_proxy NULL"
        .\nuget.exe config -set https_proxy=
        Write-Output "Set NuGet https_proxy NULL"
            
        npm config rm proxy
        npm config rm https-proxy
        npm config --global rm proxy
        npm config --global rm https-proxy
        npm config delete http-proxy
        npm config delete https-proxy
        Write-Output "Remove NPM http_proxy"

        git config --global --unset http.proxy
        Write-Output "UnSet GIT http_proxy"
        git config --global --unset https.proxy
        Write-Output "UnSet GIT https_proxy"
    }
}
    
End {
    if ($s) {
        Write-Output "Proxy is now enabled"
        Write-Output "Proxy Server : $proxy"
        if ($acs) {            
            Write-Output "Automatic Configuration Script : $acs"
        }
        else {            
            Write-Output "Automatic Configuration Script : Not Defined"
        }
    }
    elseif ($u) {
        Write-Output "Proxy is now disabled"
    }
}