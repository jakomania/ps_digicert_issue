
. "$PSScriptRoot\Functions\Create-Folder.ps1"
. "$PSScriptRoot\Functions\Generate-CSR.ps1"
. "$PSScriptRoot\Functions\Unzip-Files-Get-Crt.ps1"
. "$PSScriptRoot\Functions\Generate-Files.ps1"

. "$PSScriptRoot\Config\Parameters.ps1"


function Main {
    param(
        [string]$Path
        
    )
    Write-Host "****************************************************" -ForegroundColor Cyan
    Write-Host "Script para emisi�n de certificados en Digicert v1.0" -ForegroundColor Cyan
    Write-Host "****************************************************" -ForegroundColor Cyan
    Write-Host ""

    [string]$Domain = Read-Host "Especifica el dominio"
    Write-Host ""
    
    # Creamos directorio de destino
    $OutputFolder, $SafeName = Create-Folder -Domain $Domain -Path $Path

    # Generamos el CSR y la request de enrollment
    Generate-CSR -Domain $Domain -OutputFolder $OutputFolder -SafeName $SafeName

    # Instrucciones y pausa espera por el fichero zip
    Write-Host ""
    Write-Host "Ahora obten el zip con el certificado desde DigiCert (utilizando el CSR), y pegalo en la carpeta:" -ForegroundColor Cyan
    Write-Host $OutputFolder 
    Write-Host ""
    Write-Host "Pulsa enter para cuando est� listo..." -ForegroundColor Cyan
    $null = Read-Host

    # Descoprime el zip y devuelve el fichero crt
    $CerFile = Unzip-Files-Get-Crt -OutputFolder $OutputFolder -SafeName $SafeName

    # Exporta el certificado y genera los fichreos en diferentes formatos
    Generate-Files -CerFile $CerFile -OpenSSL $OpenSSL
       
}


Main -Path $Path -OpenSSL $OpenSSL