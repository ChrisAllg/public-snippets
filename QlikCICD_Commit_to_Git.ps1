### Commit to Git ###

# GIT FOR WINDOWS NEEDED

$commitMessage = $TaggedApp.name
$org = 'CICD'
git config --global --add safe.directory $Exportdir
cd "$Exportdir"

if (!(Test-Path ".git")) {
    git init
}

# Stage new/modified files, then UNSTAGE deletions (if any)
#git add .

# Add only new files to the staging area
git ls-files --others --exclude-standard | ForEach-Object { git add $_ }

git commit -m $commitMessage

if (!(git remote | Select-String -Pattern "origin")) {
    git remote add origin "https://github.com/chrisallg/CICDDemo2025.git"
}

git checkout main
git pull origin main

# Remove the local app folder
try {
    git push -u origin main
    # Delete local files (excluding .git) after successful push
    Remove-Item -Path $AppExportDir -Recurse -Force
} catch {
    Write-Error "Git push failed. Check network or repository settings."
    exit 1
}

# Recursively remove all empty sub-folders in the Export directory
function Remove-EmptySubDirectories($ExportDir) {
    Get-ChildItem -Path $ExportDir -Directory | ForEach-Object {
        Remove-EmptySubDirectories $_.FullName
        if (-Not (Get-ChildItem -Path $_.FullName -Recurse)) {
            Remove-Item -Path $_.FullName -Force
        }
    }
}

Remove-EmptySubDirectories $Exportdir

Pop-Location
