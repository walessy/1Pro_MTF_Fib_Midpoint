# Get the current folder name as the strategy name
$strategyName = Split-Path -Path (Get-Location) -Leaf
$gitRepoPath = "C:\Projects\$strategyName"  # Path to cloned GitHub repository
$mt4InstallPath = "C:\Projects\MT4"  # Path to MT4 installation
$mt5InstallPath = "C:\Projects\MT5"  # Path to MT5 installation (adjust if different)

# Merge mt4\include and mt5\include into common folder
$commonPath = Join-Path $gitRepoPath "common"
$mt4IncludePath = Join-Path $gitRepoPath "mt4\include"
$mt5IncludePath = Join-Path $gitRepoPath "mt5\include"

# Copy mt4\include contents to common
if (Test-Path $mt4IncludePath) {
    Copy-Item -Path "$mt4IncludePath\*" -Destination $commonPath -Recurse -Force
    Write-Host "Copied mt4\include contents to common"
}

# Copy mt5\include contents to common
if (Test-Path $mt5IncludePath) {
    Copy-Item -Path "$mt5IncludePath\*" -Destination $commonPath -Recurse -Force
    Write-Host "Copied mt5\include contents to common"
}

# Define mappings: source (Git repo) to target (MT4/MT5 installation)
$mappings = @(
    # Common folder mappings (shared by MQL4 and MQL5)
    @{
        Source = $commonPath
        TargetMQL4 = Join-Path $mt4InstallPath "MQL4\Include\$strategyName"
        TargetMQL5 = Join-Path $mt5InstallPath "MQL5\Include\$strategyName"
    },
    # MT4 Indicators
    @{
        Source = Join-Path $gitRepoPath "mt4\Indicators"
        TargetMQL4 = Join-Path $mt4InstallPath "MQL4\Indicators\$strategyName"
    },
    # MT5 Indicators
    @{
        Source = Join-Path $gitRepoPath "mt5\Indicators"
        TargetMQL5 = Join-Path $mt5InstallPath "MQL5\Indicators\$strategyName"
    }
)

# Function to create junction point
function Create-Junction {
    param (
        [string]$Source,
        [string]$Target
    )
    if (-not (Test-Path $Source)) {
        Write-Warning "Source path $Source does not exist. Skipping."
        return
    }
    if (Test-Path $Target) {
        Write-Warning "Target path $Target already exists. Skipping."
        return
    }
    # Ensure parent directory exists
    $parent = Split-Path -Path $Target -Parent
    if (-not (Test-Path $parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }
    New-Item -ItemType Junction -Path $Target -Target $Source -Force
    Write-Host "Created junction: $Target -> $Source"
}

# Process each mapping
foreach ($mapping in $mappings) {
    if ($mapping.TargetMQL4) {
        Create-Junction -Source $mapping.Source -Target $mapping.TargetMQL4
    }
    if ($mapping.TargetMQL5) {
        Create-Junction -Source $mapping.Source -Target $mapping.TargetMQL5
    }
}

Write-Host "Setup complete. Verify junctions and test MT4/MT5 functionality."