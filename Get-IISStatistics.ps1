Function Get-IISStatistics {

param (
        [parameter(Mandatory=$true, Position = 0)]
        [string]$Path,

        [parameter(Mandatory=$false)]
        [ValidateSet('0','1','2','3','4','5')]
        [string]$Decimal
    )

#Get Location of IIS LogFile
$File = $path

#Get the file, pipe to Where-Object and skip the first 3 line (headers, etc.)
$Log = Get-Content $File | where {$_ -notLike "#[D,S-V]*" }

#Replace unwanted text in the line containing the columns
$Columns = (($Log[0].TrimEnd()) -replace "#Fields: ", "" -replace "-","" -replace "\(","" -replace "\)","").Split(" ")

#Get all rows for Decision Engine Proxy Checking Service.
$Rows = $Log | where {$_ -like "*/DecisionEngine.Proxy/CheckingService.svc*"}
# Create an instance of a System.Data.DataTable
$IISLog = New-Object System.Data.DataTable "IISLog"

#Loop through each Column, create a new column through Data.DataColumn and add it to the DataTable
foreach ($Column in $Columns) {
    $NewColumn = New-Object System.Data.DataColumn $Column, ([string])
    $IISLog.Columns.Add($NewColumn)
    }


#Loop Through each Row and add the Rows.
foreach ($Row in $Rows) {
    $Row = $Row.Split(" ")
    $AddRow = $IISLog.newrow()

for($i=0;$i -lt $Count; $i++) {
    $ColumnName = $Columns[$i]
    $AddRow.$ColumnName = $Row[$i]
    }
    $IISLog.Rows.Add($AddRow)
}

$timeTaken = $IISLog.timetaken

#IISLog will dispay data we need
$timeLapse = foreach ($timelapse in $timeTaken){
    $timelapse/1000
}

foreach ($time in $timeLapse){
    
    $total += @([string]$time)
}

#Calculate $total number of requests
$totalCount = ($total).count

$date = Get-Date -format "dd/MM/yyyy"
# Calculate the average, maximum and minimum
Write-Output "IIS Performance Analysis: $date"
$average = [math]::Round(($total | Measure-Object -Average).Average, $decimalPoint)
Write-Output "Average: $average s"
$maximum = [math]::Round(($total | Measure-Object -Maximum).Maximum, $decimalPoint)
Write-Output "Maximum: $maximum s"
$minimum = [math]::Round(($total | Measure-Object -Minimum).Minimum, $decimalPoint)
Write-Output "Minimum: $minimum s"
# Calculate the Median
$total = $total | sort

if ($total.count%2) {
    #odd
    $median = [math]::Round($total[[math]::Floor($total.count/2)], $decimalPoint)
}
else {
    #even
    $median = [math]::Round(($total[$total.Count/2],$total[$total.count/2-1] | measure -Average).average, $decimalPoint)
}
    
Write-Output "Median: $median s"

#Calculate the % above the $median value
$aboveMedian = foreach ($value in $total){
    if ($value -gt $median){
        $value
    }
}

$aboveMedianCount = ($aboveMedian).Count
$percentGreaterMedian = [math]::Round(($aboveMedianCount/$totalCount)*100, $decimalPoint)
Write-Output "% > Median: $percentGreaterMedian %"

}