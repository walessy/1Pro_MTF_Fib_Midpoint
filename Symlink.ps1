param (
    [ValidateSet("Create", "Remove")]
    [string]$Action = "Create"
)

# Define paths and strategy name
$strategyName = Split-Path -Path (Get-Location) -Leaf
$BaseSourcePath = "C:\Projects\MetaTraderComponants"
$Mt4InstallPath = "C:\Projects\OLD\Mt4 20241003\2 AP2\Signal\Instance1"
$Mt5InstallPath = ""
$MapSourcePath = Join-Path $BaseSourcePath $strategyName

# Component types to map
$components = @("Indicators", "Experts", "Files", "Images", "Libraries", "Logs", "Presets", "Projects", "Scripts", "SharedProjects")

# Check platform availability
$mt4Available = Test-Path $Mt4InstallPath
$mt5Available = Test-Path $Mt5InstallPath
if (-not $mt4Available -and -not $mt5Available) { Write-Error "No valid platform paths. Exiting."; exit 1 }

if ($Action -eq "Create") {
    # Copy common files to Include folders
    $commonPath = Join-Path $MapSourcePath "common"
    if (Test-Path $commonPath) {
        if ($mt4Available) {
            $mt4IncludeDest = Join-Path $Mt4InstallPath "MQL4\Include\$strategyName"
            New-Item -ItemType Directory -Path $mt4IncludeDest -Force | Out-Null
            Copy-Item -Path "$commonPath\*" -Destination $mt4IncludeDest -Recurse -Force
            Write-Host "Copied common files to $mt4IncludeDest"
        }
        if ($mt5Available) {
            $mt5IncludeDest = Join-Path $Mt5InstallPath "MQL5\Include\$strategyName"
            New-Item -ItemType Directory -Path $mt5IncludeDest -Force | Out-Null
            Copy-Item -Path "$commonPath\*" -Destination $mt5IncludeDest -Recurse -Force
            Write-Host "Copied common files to $mt5IncludeDest"
        }
    } else {
        Write-Warning "Common path $commonPath not found. Skipping include files."
    }

    # Create junctions for MT4 components
    $mt4SourcePath = Join-Path $MapSourcePath "mt4"
    if ($mt4Available -and (Test-Path $mt4SourcePath)) {
        foreach ($comp in $components) {
            $sourceFolder = Join-Path $mt4SourcePath $comp
            if (Test-Path $sourceFolder) {
                $targetFolder = Join-Path $Mt4InstallPath "MQL4\$comp\$strategyName"
                if (Test-Path $targetFolder) { Remove-Item $targetFolder -Force -Recurse }
                New-Item -ItemType Junction -Path $targetFolder -Target $sourceFolder -Force | Out-Null
                Write-Host "Created junction: $targetFolder -> $sourceFolder"
            }
        }
    }

    # Create junctions for MT5 components
    $mt5SourcePath = Join-Path $MapSourcePath "mt5"
    if ($mt5Available -and (Test-Path $mt5SourcePath)) {
        foreach ($comp in $components) {
            $sourceFolder = Join-Path $mt5SourcePath $comp
            if (Test-Path $sourceFolder) {
                $targetFolder = Join-Path $Mt5InstallPath "MQL5\$comp\$strategyName"
                if (Test-Path $targetFolder) { Remove-Item $targetFolder -Force -Recurse }
                New-Item -ItemType Junction -Path $targetFolder -Target $sourceFolder -Force | Out-Null
                Write-Host "Created junction: $targetFolder -> $sourceFolder"
            }
        }
    }

    Write-Host "Setup complete."
} else {
    # Remove include folders and junctions
    if ($mt4Available) {
        $mt4IncludeDest = Join-Path $Mt4InstallPath "MQL4\Include\$strategyName"
        if (Test-Path $mt4IncludeDest) { Remove-Item $mt4IncludeDest -Force -Recurse; Write-Host "Removed $mt4IncludeDest" }
        foreach ($comp in $components) {
            $targetFolder = Join-Path $Mt4InstallPath "MQL4\$comp\$strategyName"
            if (Test-Path $targetFolder) { Remove-Item $targetFolder -Force -Recurse; Write-Host "Removed $targetFolder" }
        }
    }
    if ($mt5Available) {
        $mt5IncludeDest = Join-Path $Mt5InstallPath "MQL5\Include\$strategyName"
        if (Test-Path $mt5IncludeDest) { Remove-Item $mt5IncludeDest -Force -Recurse; Write-Host "Removed $mt5IncludeDest" }
        foreach ($comp in $components) {
            $targetFolder = Join-Path $Mt5InstallPath "MQL5\$comp\$strategyName"
            if (Test-Path $targetFolder) { Remove-Item $targetFolder -Force -Recurse; Write-Host "Removed $targetFolder" }
        }
    }
    Write-Host "Cleanup complete."
}