Param(
    [Parameter(Position=0)]
    [string]$InputFile,

    [Parameter(Position=1)]
    [int]$NumOfKBytes
)

if (-not $InputFile) {
    $InputFile = Read-Host -Prompt 'Input File'
    $numPrompt = Read-Host -Prompt 'Num of KB to add (empty=4)'
    if ($numPrompt -ne '') {
        try {
            $NumOfKBytes = [int]$numPrompt
        } catch {
            Write-Error "Invalid number: $numPrompt"
            exit 2
        }
    }
}

if (-not $NumOfKBytes) {
    $NumOfKBytes = 4
    Write-Host "going with default bytes to add: $NumOfKBytes kb"
}

# Remove any single or double quotes anywhere in the string
$InputFile = $InputFile -replace '"', '' -replace "'", ''

$OutputFile = "$InputFile.bin"

if (-not (Test-Path -Path $InputFile -PathType Leaf)) {
    Write-Error "Input file '$InputFile' not found."
    exit 1
}

[long]$bytesToWrite = [long]$NumOfKBytes * 1024

# Create a temporary file in the user's temp folder
$tempFile = [System.IO.Path]::Combine($env:TEMP, ([System.IO.Path]::GetRandomFileName() + '.bin'))

try {
    $rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
    try {
        $remaining = $bytesToWrite
        while ($remaining -gt 0) {
            $chunkSize = [int]([System.Math]::Min(65536, $remaining))
            $buffer = New-Object byte[] $chunkSize
            $rng.GetBytes($buffer)
            [System.IO.File]::WriteAllBytes($tempFile, $buffer) -or $false
            # Append the chunk to the temp file to avoid loading large data into memory
            if ($remaining -eq $bytesToWrite) {
                # First chunk: create file
                [System.IO.File]::WriteAllBytes($tempFile, $buffer)
            } else {
                $fsTemp = [System.IO.File]::Open($tempFile, [System.IO.FileMode]::Append, [System.IO.FileAccess]::Write)
                try { $fsTemp.Write($buffer, 0, $buffer.Length) } finally { $fsTemp.Close() }
            }

            $remaining -= $chunkSize
        }
    } finally {
        $rng.Dispose()
    }

    # Now concatenate temp file + input file into output file using streams
    $outStream = [System.IO.File]::Open($OutputFile, [System.IO.FileMode]::Create, [System.IO.FileAccess]::Write)
    try {
        foreach ($source in @($tempFile, $InputFile)) {
            $inStream = [System.IO.File]::OpenRead($source)
            try {
                $buffer = New-Object byte[] 65536
                while (($read = $inStream.Read($buffer, 0, $buffer.Length)) -gt 0) {
                    $outStream.Write($buffer, 0, $read)
                }
            } finally {
                $inStream.Close()
            }
        }
    } finally {
        $outStream.Close()
    }
} finally {
    if (Test-Path $tempFile) { Remove-Item -LiteralPath $tempFile -Force }
}

Write-Host "Wrote output to $OutputFile"
