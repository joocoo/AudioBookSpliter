# Audio Book Splitter Script
# Author: Jacob Daffer
# Date: 2023-09-08

# Inputs :
#   - CSV File with the following columns:
#     - Starting Time
#     - Ending Time
#     - Chapter Name
#   - Audio Book File
#   - Output Directory

# Outputs:
#   - Split Audio Files

# Notes:
#   - This script requires the ffmpeg.exe to run.

# Import Modules

# parameters
param(
    [Parameter(Mandatory=$true)]
    [string]$csvFile,
    [Parameter(Mandatory=$true)]
    [string]$audioFile,
    [Parameter(Mandatory=$true)]
    [string]$outputDirectory
)

# functions
function validateFile(){
    if (Test-Path $csvFile) {
        Write-Host "CSV File Exists"
    } else {
        Write-Host "CSV File Does Not Exist"
        exit
    }
    # validate columns
    $csv_columns = $csv | Get-Member -MemberType NoteProperty | Select-Object -Property Name
    $csv_columns = $csv_columns.Name -join ","
    if ($csv_columns -eq "chapterName,endTime,startTime") {
        Write-Host "CSV File Seems Valid"
    } else {
        Write-Host "CSV File Columns Not Validated"
        exit
    }
}



function createCommandList(){
    $commandList = @()
    $i = 0
    foreach ($row in $csv) {
        $startTime = $row.startTime
        $endTime = $row.endTime
        $chapterName = $row.chapterName
        $command = "ffmpeg -i '$audioFile' -ss $startTime -to $endTime -c copy '$outputDirectory\$chapterName.$codec'"
        Write-Host $i " : " $command
        $commandList += $command
        $i++
    }
    return $commandList
}

function requestToExecute{
    $response = Read-Host "Execute Commands? (y/n)"
    if ($response -eq "y") {
        executeCommands($commandList)
    } else {
        Write-Host "Exiting"
        exit
    }
}

function executeCommands(){
    # create output directory
    New-Item -ItemType Directory -Force -Path $outputDirectory
    # execute commands
    foreach ($command in $commandList) {
        Write-Host "Executing: $command"
        Invoke-Expression $command
    }
}

# main
$csv = Import-Csv $csvFile
validateFile($csv)
$codec = $(ffprobe -v error -select_streams a:0 -show_entries stream=codec_name -of default=noprint_wrappers=1:nokey=1 $audioFile)
$commandList = createCommandList($csv, $codec)
requestToExecute($commandList)