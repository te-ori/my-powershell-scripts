function prompt {
    write-Host (Get-Location) -ForegroundColor DarkGreen
    Write-Host "--> " -NoNewline -ForegroundColor Green
    return " "
}

function Show-WindowsHelpersHealthInfo {
    Write-Host "Healty..."
}

function Stop-Process {
    param (
        [Parameter(Position = 0)]
        [string]
        $name,

        [Parameter(Position = 1)]
        [string]
        $operator = "="
    )

    if ($operator -eq "%") {
        $name = "*$name*"
    }

    $processes = (Get-Process -Name $name);
    Write-Host "$($processes.Count) process found"

    $processes | ForEach-Object -Process {
        Write-Host "$($_.ProcessName) ($($_.Id))" 
        $_.Kill(); 
    }
    
    # Get-Process -Name $name | ForEach-Object -Process   { 
    #     Write-Host "$($_.ProcessName) ($($_.Id)) not killed" -ForegroundColor Red;
    # }

    Write-Host "done."
}

$aspnet_temp = $env:ASPNET_TEMP
function Clear-AspNetTempFiles {
    param (
        [Parameter(Position = 0, Mandatory)]
        [string]
        $temp_folder_path, 

        [Parameter(Position = 1)]
        [string]
        $appPoolName = 'DefaultAppPool'
    )

    $targetPath = "$aspnet_temp\$temp_folder_path"

    if ( !(Test-Path $targetPath)) {
        Write-Host "'$targetPath' not found."
        return
    }

    $appPool = Get-IISAppPool $appPoolName

    if ($null -eq $appPool ) {
        Write-Host "AppPool '$appPoolName' does not found" -ForegroundColor DarkRed
    }
    else {

        $appPool.Stop()

        Write-Host "App pool get stopping" -NoNewline
    
        do {
            Write-Host "." -NoNewline
            Start-Sleep -Milliseconds 100
        } while ($appPool.State -ne "Stopped")
    }

    Write-Host
    Write-Host "Cleaning temp files"
    Remove-Item $targetPath -Recurse -Force
    Write-Host "Temp files cleared"

    $appPool.Start()
    Write-Host "App pool started"
}

function Hide-Taskbar {
    $p = 'HKCU:SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3';
    $v = (Get-ItemProperty -Path $p).Settings;
    $v[8] = 3;
    Set-ItemProperty -Path $p -Name Settings -Value $v;
    Stop-Process -f -ProcessName explorer
}

function Show-Taskbar {
    $p = 'HKCU:SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3';
    $v = (Get-ItemProperty -Path $p).Settings;
    $v[8] = 2;
    Set-ItemProperty -Path $p -Name Settings -Value $v;
    Stop-Process -f -ProcessName explorer
}

function Copy-CurrentPath {
    Get-Location | Set-Clipboard
}

function _Remove-Target {
    param (
        [Parameter(Position = 0)]
        [string]
        $target,

        [Parameter(Position = 1)]
        [string]
        $root,

        [bool]
        $gredy = $false
    );

    Write-Verbose "_Current Dir is '$root'"
    $target_full = "$root\$target" 

    if (Test-Path $target_full) {
        Write-Host "$target_full is removing... " -ForegroundColor Yellow -NoNewline
        Remove-Item $target_full -Recurse -Force
        Write-Host "OK" -ForegroundColor Green 

        if ($gredy -eq $false) {
            return
        }
    }

    foreach ($directory in (Get-Item $root).GetDirectories()) {
        Write-Verbose $directory.FullName

        if ($verbose) {
            _Remove-Target $target $directory.FullName -gredy $gredy -Verbose
        }
        else {
            _Remove-Target $target $directory.FullName -gredy $gredy
        }
    }
}

function Remove-Target {
    param (
        [Parameter(Position = 0)]
        [string]
        $target,

        [Parameter(Position = 1)]
        [string]
        $root = (Get-Location) ,

        [bool]
        $gredy = $false
    );

    $back = $Host.PrivateData.VerboseForegroundColor;
    $Host.PrivateData.VerboseForegroundColor = 'Gray'

    Write-Verbose "Target is '$target'"
    Write-Verbose "Current Dir is '$root'"
    Write-Verbose "Gredy: $gredy"

    if ($verbose) {
        _Remove-Target $target $root -gredy $gredy -Verbose
    }
    else {
        _Remove-Target $target $root -gredy $gredy
    }

    $Host.PrivateData.VerboseForegroundColor = $back

}

function Get-DefaultBrowserPath {
    #Get the default Browser path
    # New-PSDrive -Name HKCR -PSProvider registry -Root Hkey_Classes_Root | Out-Null
    # $browserPath = ((Get-ItemProperty 'HKCR:\http\shell\open\command').'(default)').Split('"')
    # return $browserPath

    return "C:\Program Files\Mozilla Firefox\firefox.exe"
}

function Remove-DuplicateItems {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = 1)]     
        $list
    )

    $map = @{}

    foreach ($e in $list) {
        if ($map[$e] -ne 1) {
            $map[$e] = 1
        }
    }

    return $map.Keys
}


Write-Host "WINDOWS helpers loaded"