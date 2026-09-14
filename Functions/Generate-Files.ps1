
function Generate-Files {

param(
    
    [string]$CerFile,    
    [string]$OpenSSL
)

$ErrorActionPreference = "Stop"

if (!(Test-Path $CerFile)) {
    throw "No existe el fichero CER"
}

if (!(Test-Path $OpenSSL)) {
    throw "OpenSSL no encontrado"
}

$OutputFolder = Split-Path (Split-Path $CerFile)

#
# Vincula el certificado emitido
# con la clave privada generada
# al crear el CSR
#
certreq.exe -machine -accept $CerFile

#
# Cargamos el CER
#
$CertFromFile = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($CerFile)

#
# Localizamos el certificado instalado

 $Cert = Get-ChildItem Cert:\LocalMachine\My |
 Where-Object {
     $_.Thumbprint -eq $CertFromFile.Thumbprint
 } |
 Select-Object -First 1



if (!$Cert.HasPrivateKey) {
    throw "No tiene clave privada asociada"
}

$PfxPassword = Read-Host "Introduce password" -AsSecureString

$PfxFile = Join-Path $OutputFolder "wildcard.pfx"

Export-PfxCertificate `
    -Cert $Cert `
    -FilePath $PfxFile `
    -Password $PfxPassword `
    -ChainOption BuildChain `
    -Force

#
# Password en texto para OpenSSL
#
$BSTR = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($PfxPassword)
$PlainPwd = [Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

#
# Certificado PEM
#
& $OpenSSL pkcs12 `
    -in $PfxFile `
    -clcerts `
    -nokeys `
    -out "$OutputFolder\certificate.pem" `
    -passin "pass:$PlainPwd"

#
# Clave cifrada
#
& $OpenSSL pkcs12 `
    -in $PfxFile `
    -nocerts `
    -out "$OutputFolder\private-encrypted.key" `
    -passin "pass:$PlainPwd" `
    -passout "pass:$PlainPwd"

#
# Clave sin cifrar
#
& $OpenSSL pkey `
    -in "$OutputFolder\private-encrypted.key" `
    -out "$OutputFolder\private.key" `
    -passin "pass:$PlainPwd"

if ($LASTEXITCODE -ne 0) {
    throw "Error generando private.key"
}
#
# Cadena
#
$ChainFile = "$OutputFolder\chain.pem"

& $OpenSSL pkcs12 `
    -in $PfxFile `
    -cacerts `
    -nokeys `
    -out $ChainFile `
    -passin "pass:$PlainPwd"

$Content = Get-Content $ChainFile -Raw
$Certificates = [regex]::Matches(
    $Content,
    '-----BEGIN CERTIFICATE-----.+?-----END CERTIFICATE-----',
    [System.Text.RegularExpressions.RegexOptions]::Singleline
) | ForEach-Object {
    $_.Value
}
[array]::Reverse($Certificates)
$Certificates -join "`r`n" | Set-Content $ChainFile
#
# Full Chain
#
Get-Content `
    "$OutputFolder\certificate.pem",
    "$OutputFolder\chain.pem" |
        Set-Content "$OutputFolder\fullchain.pem"

Write-Host ""
Write-Host "Generados correctamente:" -ForegroundColor Green
Write-Host "wildcard.pfx"
Write-Host "certificate.pem"
Write-Host "chain.pem"
Write-Host "fullchain.pem"
Write-Host "private-encrypted.key"
Write-Host "private.key"

}