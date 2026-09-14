
function Create-Folder {

param(
    [string]$Domain,
    [string]$Path
)


$StringDate = Get-Date -UFormat "%d-%m-%Y"

$SafeName = $Domain.Replace('*','star').Replace('.','_')

$FolderStruct = Join-Path $SafeName $StringDate

$OutputFolder = Join-Path $Path $FolderStruct

$Res = Read-Host "Especifica ruta donde crear la estructura de directorios destino o pulsa enter para default ($Path)" 


if ($Res -ne "" ) {
    $OutputFolder = Join-Path $Res $FolderStruct
}

New-Item -ItemType Directory -Path $OutputFolder -Force | Out-Null

Write-Host ""
Write-Host "Creada carpeta en:" -ForegroundColor Green
Write-Host "$OutputFolder"

return $OutputFolder, $SafeName

}