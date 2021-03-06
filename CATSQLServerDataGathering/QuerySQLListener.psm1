<#
.SYNOPSIS
    sends the magic packet to UDP 1434 and returns the results
.DESCRIPTION
    A detailed description of the module.
#>
function QuerySQLListener{ 
    [cmdletbinding( 
        DefaultParameterSetName = '', 
        ConfirmImpact = "low"
    )] 
    Param( 
        [Parameter( 
            Mandatory = $True, 
            Position = 0, 
            ParameterSetName = '', 
            ValueFromPipeline = $True)] 
        [string]$Computer
    ) 
    begin { 
        $ErrorActionPreference = "SilentlyContinue" 
        $Port = 1434
        $ConnectionTimeout = 1000
        $Responses  = @()
    }
    process {
        $UDPClient = new-Object system.Net.Sockets.Udpclient
        $UDPClient.client.ReceiveTimeout = $ConnectionTimeout
        $IPAddress = [System.Net.Dns]::GetHostEntry($Computer).AddressList[0].IPAddressToString
        $UDPClient.Connect($IPAddress,$Port)
        $ToASCII = new-object system.text.asciiencoding
        $UDPPacket = 0x02,0x00,0x00
        Try {
            $UDPEndpoint = New-Object system.net.ipendpoint([system.net.ipaddress]::Any,0)
            $UDPClient.Client.Blocking = $True
            [void]$UDPClient.Send($UDPPacket,$UDPPacket.length)
            $BytesRecived = $UDPClient.Receive([ref]$UDPEndpoint)
            [string]$Response = $ToASCII.GetString($BytesRecived)
            If ($Response) {
                $Response = $Response.Substring(3,$Response.Length-3).Replace(";;","~")
                $Response.Split("~") | ForEach {
                    $Responses += $_
                }
            $socket = $null;
            $UDPClient.close()
            }
        }
        Catch [Exeption] {
            $Error[0].ToString()
            $UDPClient.Close()
        }
    }
    End {
        return ,$Responses
    }
}
Export-ModuleMember -Function QuerySQLListener