function Generate-CSR {

param(
    [string]$Domain,
    [string]$SubjAtributes,
    [string]$OutputFolder,
    [string]$SafeName
)


$InfFile = Join-Path $OutputFolder "$SafeName.inf"
$CsrFile = Join-Path $OutputFolder "$SafeName.csr"

$SubjString = "$Domain$SubjAtributes"

@"
[Version]
Signature="`$Windows NT`$"

[NewRequest]
Subject = "CN=$SubjString"

KeyAlgorithm = RSA
KeyLength = 3072
HashAlgorithm = SHA256

MachineKeySet = TRUE
Exportable = TRUE

ProviderName = "Microsoft Software Key Storage Provider"

RequestType = PKCS10

FriendlyName = "$Domain"

[Extensions]
2.5.29.37 = "{text}1.3.6.1.5.5.7.3.1"
"@ | Set-Content $InfFile -Encoding ASCII

certreq.exe -new $InfFile $CsrFile

Write-Host ""
Write-Host "CSR generado correctamente en:" -ForegroundColor Green
Write-Host $CsrFile
Write-Host ""
Get-Content $CsrFile

}