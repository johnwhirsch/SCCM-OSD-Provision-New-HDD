$TSProgressUI = New-Object -COMObject Microsoft.SMS.TSProgressUI
$TSProgressUI.CloseProgressDialog()

$disks = 0; Get-WmiObject -Class Win32_DiskDrive | ? { $_.Status -eq "Ok" } | % { $disks++; }

function checkSaveIndex{
    param( [string]$DiskIndex )
    if(!(Get-WmiObject -Class Win32_DiskDrive | ? { $_.Index -eq $DiskIndex })){ 
        Write-Host " !! Index Not Found !! " -ForegroundColor White -BackgroundColor Red;
        $indextoclean = Read-Host "Please enter the index number of the drive you want to format"
        checkSaveIndex -DiskIndex $indextoclean;
    }
    elseif($DiskIndex.length -eq 0){
        Write-Host " !! Index Was Empty !! " -ForegroundColor White -BackgroundColor Red;
        $indextoclean = Read-Host "Please enter the index number of the drive you want to format"
        checkSaveIndex -DiskIndex $indextoclean;
    }
    else{        
        NEW-ITEM -Path "$($env:windir)\temp\bootemup.txt" -ItemType file -force | OUT-NULL
        ADD-CONTENT -Path "$($env:windir)\temp\bootemup.txt" -Value “SELECT DISK $indextoclean”
        ADD-CONTENT -Path "$($env:windir)\temp\bootemup.txt" -Value “CLEAN”
        ADD-CONTENT -Path "$($env:windir)\temp\bootemup.txt" -Value “CREATE PARTITION PRIMARY”
        ADD-CONTENT -Path "$($env:windir)\temp\bootemup.txt" -Value “FORMAT FS=NTFS QUICK”
        ADD-CONTENT -Path "$($env:windir)\temp\bootemup.txt" -Value “ASSIGN”
        ADD-CONTENT -Path "$($env:windir)\temp\bootemup.txt" -value “ACTIVE”

        DISKPART /S "$($env:windir)\temp\bootemup.txt"
    }
}
if($disks -eq 0){
    Write-Host "                                                             " -BackgroundColor Red -ForegroundColor White
    Write-Host " !! Error: No health disks round, please run a diagnostic !! " -BackgroundColor Red -ForegroundColor White
    Write-Host "                                                             " -BackgroundColor Red -ForegroundColor White
}
if((Get-WmiObject -Class Win32_LogicalDisk | ? { $_.DriveType -eq 3 -and $_.Name -ne "X:"}).count -eq 0 -and $disks -gt 0){
    Get-WmiObject -Class Win32_DiskDrive | Select-Object Index,Model,Status,@{label="Size(GB)";expression={[math]::Truncate($_.Size/1000000000)}} | Sort-Object index | FT
    Write-Host "                                                                     " -BackgroundColor Red -ForegroundColor White
    Write-Host " !! CAUTION: THIS WILL COMPLETELY ERASE THE DRIVE THAT YOU SELECT !! " -BackgroundColor Red -ForegroundColor White
    Write-Host "                                                                     " -BackgroundColor Red -ForegroundColor White
    Get-WmiObject -Class Win32_DiskDrive | Select-Object Index,Model,Status,@{label="Size(GB)";expression={[math]::Truncate($_.Size/1000000000)}} | Sort-Object index | FT
    
    $indextoclean = Read-Host "Please enter the index number of the drive you want to format"
        
    checkSaveIndex -DiskIndex $indextoclean;    
}
