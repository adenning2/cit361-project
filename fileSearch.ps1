# Re-run the script as administrator
if(!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
    Start-Process powershell.exe -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"{0}`"" -f $PSCommandPath) -Verb RunAs
    Exit
}

# Prompt for the directory to search
Write-Host "Enter the directory to search (leave blank for current directory): " -NoNewline -ForegroundColor Green -BackgroundColor Black
$searchDirectory = Read-Host
if ([string]::IsNullOrWhiteSpace($searchDirectory)) {
    $searchDirectory = $PSScriptRoot
}

# Prompt for word in file name
Write-Host "Input a filename search term: " -NoNewline -ForegroundColor Green -BackgroundColor Black
$wordInput = Read-Host

# Function to search for files recursively
function Search-Files {
    param(
        [Parameter(Mandatory = $true)] [string] $path,
        [Parameter(Mandatory = $true)] [string] $findString
    )
    $parentPathLength = ($path -split '\\').Count
    $results = @()

    # Searching in the parent directory
    Write-Host "Searching in: $path" -ForegroundColor Yellow -BackgroundColor Black
    Get-ChildItem -Path $path -ErrorAction SilentlyContinue | ForEach-Object {
        if ($_.Name -like "*$findString*") {
            Write-Host "Found: $($_.FullName)" -ForegroundColor Green -BackgroundColor Black
            $results += $_.FullName
        }
    }

    # Searching in subdirectories
    Get-ChildItem -Path $path -Directory -ErrorAction SilentlyContinue | ForEach-Object {
        $currentPathLength = ($_.FullName -split '\\').Count
        if ($currentPathLength -eq $parentPathLength + 1) {
            Write-Host "Searching in: $($_.FullName)" -ForegroundColor Yellow -BackgroundColor Black
            Get-ChildItem -Path $_.FullName -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
                if ($_.Name -like "*$findString*") {
                    Write-Host "Found: $($_.FullName)" -ForegroundColor Green -BackgroundColor Black
                    $results += $_.FullName
                }
            }
        }
    }
    
        if ($_.Name -like "*$findString*") {
            Write-Host "Found: $($_.FullName)" -ForegroundColor Green -BackgroundColor Black
            $results += $_.FullName
        }

    return $results
}

# Perform the search
$searchResults = Search-Files -path "$searchDirectory" -findString "$wordInput"

# Ask to save results
Write-Host "Do you want to save the search results to a file? (y/n): " -NoNewline -ForegroundColor Green -BackgroundColor Black
$saveResponse = Read-Host
if ($saveResponse -eq 'y') {
    Write-Host "Enter the file path to save the results (leave blank for current directory, fileSearch.txt): " -NoNewline -ForegroundColor Green -BackgroundColor Black
    $filePath = Read-Host
    if ([string]::IsNullOrWhiteSpace($filePath)) {
        $filePath = "$PSScriptRoot\fileSearch.txt"
    }
    $searchResults | Out-File -FilePath $filePath
    Write-Host "Results saved to $filePath" -ForegroundColor Green -BackgroundColor Black
}

# End of script
Write-Host "Search completed. Press any key to exit." -ForegroundColor Green -BackgroundColor Black
$null = $Host.UI.RawUI.ReadKey("NoEcho, IncludeKeyDown")