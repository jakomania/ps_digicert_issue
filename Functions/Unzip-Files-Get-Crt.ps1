function Unzip-Files-Get-Crt {

    param(
        [string]$OutputFolder,
        [string]$SafeName
    )

    $ZipFile = (Get-ChildItem $OutputFolder -Filter "*.zip" | Select-Object -First 1).FullName

    Write-Host $ZipFile

    Expand-Archive -Path $ZipFile -DestinationPath $OutputFolder -Force

    $DecompressFolder = (Get-ChildItem $OutputFolder -Directory -Filter "$SafeName*" | Select-Object -First 1).FullName

    $CrtFile = (Get-ChildItem $DecompressFolder -Filter "$SafeName*.crt" | Select-Object -First 1).FullName

    return $CrtFile

   
}