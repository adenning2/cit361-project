# Administrator Elevation
if(!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
    Start-Process powershell.exe -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"{0}`"" -f $PSCommandPath) -Verb RunAs
    Exit
}

# Directory Prompt
Write-Host "Enter the directory to search (leave blank for current directory): " -NoNewline
$searchDirectory = Read-Host
if ([string]::IsNullOrWhiteSpace($searchDirectory)) {
    $searchDirectory = $PSScriptRoot
}

# Search Prompt
Write-Host "Input a filename search term: " -NoNewline
$searchTerm = Read-Host

# Search
function Search-Files {
    param(
        [Parameter(Mandatory = $true)] [string] $path,
        [Parameter(Mandatory = $true)] [string] $findString
    )
    $parentPathLength = ($path -split '\\').Count
    $results = @()

    # Parent Directory
    Write-Host "Searching in: $path" -ForegroundColor Yellow 
    Get-ChildItem -Path $path -ErrorAction SilentlyContinue | ForEach-Object {
        if ($_.Name -like "*$findString*") {
            Write-Host "Found: $($_.FullName)" -ForegroundColor Green 
            $results += $_.FullName
        }
    }

    # Subdirectories
    Get-ChildItem -Path $path -Directory -ErrorAction SilentlyContinue | ForEach-Object {
        $currentPathLength = ($_.FullName -split '\\').Count
        if ($currentPathLength -eq $parentPathLength + 1) {
            Write-Host "Searching in: $($_.FullName)" -ForegroundColor Yellow 
            Get-ChildItem -Path $_.FullName -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
                if ($_.Name -like "*$findString*") {
                    Write-Host "Found: $($_.FullName)" -ForegroundColor Green 
                    $results += $_.FullName
                }
            }
        }
    }

    return $results
}

# Perform Search
$searchResults = Search-Files -path "$searchDirectory" -findString "$searchTerm"

# Save
Write-Host "Do you want to save the search results to a file? (y/n): " -NoNewline 
$saveResponse = Read-Host
if ($saveResponse -eq 'y') {
    Write-Host "Enter the file path to save the results (leave blank for current directory, fileSearch.txt): " -NoNewline 
    $filePath = Read-Host
    if ([string]::IsNullOrWhiteSpace($filePath)) {
        $filePath = "$PSScriptRoot\fileSearch.txt"
    }
    $searchResults | Out-File -FilePath $filePath
    Write-Host "Results saved to $filePath" -ForegroundColor Green 
}

# Exit
Write-Host "Search completed. Press any key to exit." -NoNewline
$null = $Host.UI.RawUI.ReadKey("NoEcho, IncludeKeyDown")