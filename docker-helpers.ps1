function Copy-DockerContainerIdToClipboard {
    $list = $(get-containers)
    list-containers $list
    $container_id = $(get-selectedcontainerid $list)

    if ($container_id -eq -1) {
        return
    }

   
    Set-Clipboard $container_id
}

function Stop-DockerContainer {
    $list = $(get-containers)
    list-containers $list
    $container_id = $(get-selectedcontainerid $list)

    if ($container_id -eq -1) {
        return
    }

    $confirm = Read-Host "To stop '$container_id' press y/Y"

    if ($confirm.ToLower() -ne "y") {
        return
    }

    docker stop $container_id

    Write-Host "$container_id stopped"
}

function Stop-AllDockerContainers {
    $confirm = Read-Host "To stop ALL containers press y/Y"

    if ($confirm.ToLower() -ne "y") {
        return
    }

    $(get-containers) | ForEach-Object {
        docker stop $(get-containerid $_ )
        Write-Host $_ -ForegroundColor DarkGreen -NoNewline
        Write-Host " stopped"
    }

}

function get-containers {
    $containers = @($(docker container ls --format="{{ .ID }} - {{ .Image }} {{ .Names }}"))
    return $containers
}

function list-containers {
    param(
        $list
    )

    $list = @($list)

    for ($i = 0; $i -lt $list.Length; $i = $i + 1) {
        Write-Host "$($i + 1). $($list[$i])"
    }
}

function get-selectedcontainerid { 
    param(
        $list
    )

    $list = @($list)

    $index = Read-Host "Enter container's index"

    if (($index -lt 1) -or ($index -gt $list.Length)) { 
        Write-Host "Index out of range" -ForegroundColor DarkRed
        return -1
    }

    $container_id = $(get-containerid $($list[$index - 1]))
    return $container_id
}

function get-containerid {
    param(
        $container_string
    )

    return $container_string.Split(' ')[0]
}