param(
    [Parameter(Mandatory)][string] $GCodeFile,
    [Parameter(Mandatory)][int] $BaseTemp,
    [double] $Step = -5,
    [double] $LevelHeight = 10,
    [double] $BaseHeight = 1.6
)

if(!(Test-Path $GCodeFile)) {
    throw "File $GCodeFile not found!"
}

$file = Get-Item $GCodeFile

if($file.Extension.ToLower() -ne ".gcode") {
    throw "File must be a gcode!"
}

$currentTemp = $BaseTemp
$gcode = Get-Content $GCodeFile
$mgcode = $gcode | ForEach-Object {
    if ($_ -match "^G0.*Z([0-9\.]+)") {
        $z = [double]$Matches[1]
        $level = [int][Math]::Floor(($z - $BaseHeight) / $LevelHeight)
        $temp = $BaseTemp + $level * $Step
        Write-Debug "Z: $z Level: $level Temp: $temp"
        if ($level -ge 0 -and $currentTemp -ne $temp) {
            Write-Host "Z: $z Level: $level Temp: $temp"
            "M104 S$temp"
        }
        $currentTemp = $temp
    }
    $_
}

$outFileName = "$($file.BaseName)_$BaseTemp-$currentTemp$($file.Extension)"
Write-Host "Output: $outFileName"
$mgcode | Out-File $outFileName
