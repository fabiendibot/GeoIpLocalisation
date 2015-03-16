Function Get-GEOIpInformation {
<#
.SYNOPSIS
    Function to output Geo informations about an IP, and also the localisation on Google maps.
.DESCRIPTION
    Function to output Geo informations about an IP, and also the localisation on Google maps.
    It uses a public Geo REST API: FreeGeoIP
    This API has a limitation, you can't use it more than 10 000 times / hour :)
    If you don't specify any IP Address, it'll use your public ip instead
.EXAMPLE
    Get-GEOIpInformation -IP '199.16.156.6','88.125.147.37' -ShowUI
.EXAMPLE
    Get-GEOIpInformation -verbose
#>
    [CmdletBinding()]
    param (
        [String[]]$Ip,
        [Switch]$ShowUI
    )
 
    Begin {
        $Output = @()
        $API = "freegeoip.net/json"
    }
    Process {
        $Ip | % {
        if ($ip) { $url = $API + "/$_" }
            Try {
                Write-Verbose "Invoke Public REST API with $url"
                Invoke-RestMethod -Uri $url | % {
                    Write-verbose "Ok, Parsing datas..."
                    $props = [ordered]@{"ip"=$_.ip;
                                        "country_code"=$_.country_code;
                                        "country_name"=$_.country_name;
                                        "region_code"=$_.region_code;
                                        "region_name"=$_.region_name;
                                        "city"=$_.city;
                                        "zipcode"=$_.zipcode;
                                        "latitude"=$_.latitude;
                                        "longitude"=$_.longitude;
                                        "metro_code"=$_.metro_code;
                                        "area_code"=$_.area_code}
                }
            }
            Catch {
                throw "Error. Can't Contact website"
            }
            Finally {
                Write-Verbose "OK. Adding parsed data to returnin object"
                $Output += New-Object -TypeName PSCustomObject -Property $props
            }
        }
    }
    End {
        Write-Verbose "Printing results..."
        $Output
        if ($ShowUI) {
            $Output | % {
                if (!($_.Error)) {
                    Write-Verbose "Printing map in favorited navigator..."
                    Start-Process -FilePath "http://maps.google.com/maps?q=$($_.latitude),$($_.longitude)"
                }
            }
        }
    }
}