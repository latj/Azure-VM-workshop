[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [ValidateSet('windows', 'linux')]
    [string]
    $OS,
    [Parameter(Mandatory=$true)]
    [ValidateSet('Generate', 'List')]
    [string]
    $GenerateOrList
)

if($GenerateOrList -eq "Generate"){
    $postParams = @{type=$os;createdby=$env:username;resourcegroup='test';costcenter='noway';generate='true'} | ConvertTo-Json
    $result = Invoke-WebRequest -Uri https://generatehostnamedemo.azurewebsites.net/api/Gethostname?code=FD7Xdx777b3iObR31DMWoWJEzXwmy1zmNA_gG9rJb_ftAzFuwdHCNg== -Method POST -Body $postParams
    $name = $result.Content | ConvertFrom-Json 
    $name.hostnames.name
}

if($GenerateOrList -eq "List"){
    $result = Invoke-WebRequest -Uri "https://generatehostnamedemo.azurewebsites.net/api/Listhostnames?code=UaCqmEHNDe0jYLfEL-xI2UZy06Au24sx8Yt8L_aYEc-eAzFuC67iiA==&type=$os" -Method Get
    $name = $result.Content | ConvertFrom-Json 
    $name.hostnames
}