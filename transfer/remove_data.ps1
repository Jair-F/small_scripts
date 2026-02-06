Param(
    [Parameter(Position=0)]
    [string]$InputFile,

    [Parameter(Position=1)]
    [int]$NumOfKBytes
)

if (-not $InputFile) {
    $InputFile = Read-Host -Prompt 'Input File'
}

# Remove any single or double quotes anywhere in the string
$InputFile = $InputFile -replace '"', '' -replace "'", ''

if (-not (Test-Path -Path $InputFile -PathType Leaf)) {
    Write-Error "Input file '$InputFile' not found."
    exit 1
}

# Remove trailing .bin (case-insensitive)
if ($InputFile.ToLower().EndsWith('.bin')) {
    $OutputFile = $InputFile.Substring(0, $InputFile.Length - 4)
} else {
    $OutputFile = $InputFile
}

# Read 2 bytes at offset 32 to get the number
try {
    $inStream = [System.IO.File]::OpenRead($InputFile)
    try {
        $null = $inStream.Seek(32, [System.IO.SeekOrigin]::Begin)
        $buffer = New-Object byte[] 2
        $read = $inStream.Read($buffer, 0, 2)
        if ($read -ne 2) {
            Write-Error "Could not read 2 bytes at offset 32"
            exit 1
        }
        $numString = [System.Text.Encoding]::ASCII.GetString($buffer)
        # Extract only digits from the 2 bytes
        $NumOfKBytes = [int]($numString -replace '[^0-9]', '')
        if ($NumOfKBytes -eq 0 -and -not ($numString -match '[0-9]')) {
            Write-Error "Error: Could not find a valid number at offset 32"
            exit 1
        }
    } finally {
        $inStream.Close()
    }
} catch {
    Write-Error "Failed to read from input file: $_"
    exit 1
}

# Calculate bytes to skip: random_data (32) + number_string (3) + actual data (NUM_OF_KBYTES * 1024)
[long]$bytesToSkip = ([long]$NumOfKBytes * 1024) + 32 + 3

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
