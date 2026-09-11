
function Create-Folder {

param(
    [string]$Domain,
    [string]$Path
)


$StringDate = Get-Date -UFormat "%d%m%Y"

$SafeName = $Domain.Replace('*','star').Replace('.','_')

$OutputFolder = Join-Path $Path "$SafeName-$StringDate"

$Res = Read-Host "Especifica ruta donde se creará la carpeta destino o pulsa enter para default ($Path)" 


if ($Res -ne "" ) {
    $OutputFolder = Join-Path $Res "$SafeName-$StringDate-TEST"
}

New-Item -ItemType Directory -Path $OutputFolder -Force | Out-Null

Write-Host ""
Write-Host "Creada carpeta en:" -ForegroundColor Green
Write-Host "$OutputFolder"

return $OutputFolder, $SafeName

}