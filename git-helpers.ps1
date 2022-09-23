#region To inspect .git/object contents
function gcf {
    [CmdletBinding()]
    param (
        [Parameter(Position=0)]
        [string]
        $object_hash
    )

    Write-Verbose "GCF::HASH: '$object_hash'"
    Write-Verbose "git cat-file -p $object_hash"
    Write-Output "{{" 
    Write-Output "      $object_hash"
    git cat-file -p $object_hash
    Write-Output ""
    Write-Output "}}" 

}

function gcf-mp {
    [CmdletBinding()]
    param(
        [Parameter(Position=0)]
        [string]
        $object_name
    )

    $obj = $(Get-Item $object_name)
    Write-Verbose "GCF::MP::HHASH: '$object_name'"
    Write-Verbose "GCF::MP: $($obj.Directory.Name)$($obj.Name)"
    gcf "$($obj.Directory.Name)$($obj.Name)"
}

function gcf-t {
    [CmdletBinding()]
    param()

    Write-Verbose "gcf-t"
    $objects = $(Get-ChildItem -Recurse -File | Sort-Object LastWriteTime)

    foreach($obj in $objects) {
        Write-Verbose "GCF::T::SHORT: $obj"
        
        gcf-mp $obj.FullName
    }
}
#endregion To inspect .git/object contents

function GitShow-FileNameOnly { 
	[CmdletBinding()]
	param(
		[Parameter(Position=0)]
		[string]
		$revision="HEAD"
	)
	
	git show --pretty="" --name-only $revision
}
Set-Alias -Name gsfno -Value GitShow-FileNameOnly

function GitShow-FileContentInRevision {
	[CmdletBinding()]
	param(
		[Parameter(Position=0,Mandatory=1)]
		[string]
		$revision,
		
		[Parameter(Position=1,Mandatory=1)]
		[string]
		$fileName
	)
	
	git show "$($revision):$($fileName)"
}
Set-Alias -Name gsfcir -Value GitShow-FileContentInRevision


function GitShow-SaveFileContentInRevision {
	[CmdletBinding()]
	param(
		[Parameter(Position=0,Mandatory=1)]
		[string]
		$revision,
		
		[Parameter(Position=1,Mandatory=1)]
		[string]
		$fileName,

        [Parameter(Position=2,Mandatory=1)]
        [string]
        $outputPath
	)
	
	git show "$($revision):$($fileName)" > "$outputPath"
}
Set-Alias -Name gssfcir -Value GitShow-SaveFileContentInRevision

function GitGrep-InAllHistory {
    # This cmdled grep pattern inside all git history,
    # including commits that not ancestor of curren commit
    [CmdletBinding()]
    param(
        [Parameter(Position=0, Mandatory=1)]
        [string]
        $pattern
    )

    git grep "$pattern" $(git rev-list --all)
}
Set-Alias -Name ggiah -Value GitGrep-InAllHistory

function GitGrep-InCommitHistory {

    [CmdletBinding()]
    param(
        [Parameter(Position=0, Mandatory=1)]
        [string]
        $pattern
    )

    git grep "$pattern" $(git log --format="%h")
}
Set-Alias -Name ggich -Value GitGrep-InCommitHistory
