$target = "agrobot-inf"
if (-not (Test-Path $target)) { New-Item -ItemType Directory -Name $target }
$exclude = @(".git", ".idea", ".venv", $target, "move_files.py", "move_all.ps1", "milestone1", "milestone2", "milestone3", "milestone4", "readme.md", "README.md", "LICENSE", "agrobot")

Get-ChildItem -Path . -Force | Where-Object { 
    $_.Name -notin $exclude -and 
    $_.Name -notmatch '^\.$' -and 
    $_.Name -notmatch '^\.\.$' 
} | ForEach-Object {
    Write-Host "Moving $($_.Name)"
    Move-Item -Path $_.FullName -Destination $target
}
Write-Host "Done!"
