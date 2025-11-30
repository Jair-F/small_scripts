Param(
    [Parameter(Position=0)]
    [string]$InputFile,

    [Parameter(Position=1)]
    [int]$NumOfKBytes
)

if (-not $InputFile) {
    $InputFile = Read-Host -Prompt 'Input File'
    $numPrompt = Read-Host -Prompt 'Num of KB to remove (empty=4)'
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
    Write-Host "going with default bytes to remove: $NumOfKBytes kb"
}

# Remove any single or double quotes anywhere in the string
$InputFile = $InputFile -replace '"', '' -replace "'", ''

# Remove trailing .bin (case-insensitive)
if ($InputFile.ToLower().EndsWith('.bin')) {
    $OutputFile = $InputFile.Substring(0, $InputFile.Length - 4)
} else {
    $OutputFile = $InputFile
}

if (-not (Test-Path -Path $InputFile -PathType Leaf)) {
    Write-Error "Input file '$InputFile' not found."
    exit 1
}

[long]$bytesToSkip = [long]$NumOfKBytes * 1024

try {
    $inStream = [System.IO.File]::OpenRead($InputFile)
} catch {
    Write-Error "Failed to open input file: $_"
    exit 1
}

try {
    if ($bytesToSkip -gt $inStream.Length) {
        Write-Error "Skip bytes ($bytesToSkip) larger than file size ($($inStream.Length))."
        $inStream.Close()
        exit 1
    }

    $null = $inStream.Seek($bytesToSkip, [System.IO.SeekOrigin]::Begin)

    try {
        $outStream = [System.IO.File]::Open($OutputFile, [System.IO.FileMode]::Create, [System.IO.FileAccess]::Write)
    } catch {
        Write-Error "Failed to open output file '$OutputFile' for writing: $_"
        $inStream.Close()
        exit 1
    }

    try {
        $buffer = New-Object byte[] 65536
        while (($read = $inStream.Read($buffer, 0, $buffer.Length)) -gt 0) {
            $outStream.Write($buffer, 0, $read)
        }
    } finally {
        $outStream.Close()
    }
} finally {
    $inStream.Close()
}

Write-Host "Wrote output to $OutputFile"
