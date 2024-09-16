$ErrorActionPreference = 'Stop'

Add-Type -AssemblyName System.Windows.Forms

Function Main {
  Write-Output 'THEIA DIALOG PATCHER v0.1'
  Write-Output ''
  Write-Output 'A script that can extract and patch the dialog for Nyaruru Fishy Fight.'
  Write-Output 'Still an early version, please backup the game before proceeding.'
  Write-Output ''
  Write-Output 'Available actions:'
  Write-Output '1 = Install a dialog mod.'
  Write-Output '2 = Extract the dialog source.'
  Write-Output '3 = Restore modified game file (nya_achieves.js).'
  Write-Output ''

  $Action = Read-Host 'Choose 1-3 (press ENTER when you done, CTRL+C to exit)'

  if ($Action -eq '1') {
    InstallDialogMod
    exit 1
  }

  if ($Action -eq '2') {
    ExtractDialogSource
    exit 1
  }

  if ($Action -eq '3') {
    RestoreOriginalFile
    exit 1
  }

  Write-Output "No action for `"$Action`"."
}

Function InstallDialogMod {
  Write-Output '- Select you modded dialog file...'

  $LangModPath = Get-DialogModPath

  if ($LangModPath -eq '') {
    Write-Output 'ERROR: Selected location cannot be empty.'
    exit 1
  }
  
  Write-Output "Modded dialog location: $LangModPath"

  $DefaultNyaruruGamePath = "C:\Program Files (x86)\Steam\steamapps\common\Nyaruru"
  $NyaruruGamePath = "$DefaultNyaruruGamePath"

  if (-Not (Test-Path $DefaultNyaruruGamePath)) {
    Write-Output '- Locate the Nyaruru installation folder...'
    $NyaruruGamePath = Get-NyaruruPath
  }

  Write-Output "Nyaruru game location: $NyaruruGamePath"

  if ($NyaruruGamePath -eq '') {
    Write-Output 'ERROR: Nyaruru game location cannot be empty.'
    exit 1
  }

  $NyaFolder = "$NyaruruGamePath\js\nya"
  $NyaAchieves = "$NyaFolder\nya_achieves.js"
  $NyaAchievesBackup = "$NyaAchieves.bak"
  $NyaModdedLangPath = "$NyaruruGamePath\dialog.xlsx"

  Write-Output 'Checking nya_achieves.js...'
  if (-Not (Test-Path $NyaAchieves)) {
    Write-Output "ERROR: Path is probably not a valid Nyaruru game location, cannot find $NyaAchieves"
    exit 1
  }
  
  if (-Not (Test-Path $NyaAchievesBackup)) {
    Write-Output 'Creating backup for nya_achieves.js...'
    Copy-Item $NyaAchieves -Destination $NyaAchievesBackup
  }

  Write-Output 'Reading nya_achieves.js...'
  $NyaAchievesContent = Get-Content $NyaAchieves

  if ($NyaAchievesContent[0] -eq '/** MODDED */') {
    Write-Output 'nya_achieves.js has been modded before, restoring the original...'
    Copy-Item $NyaAchievesBackup -Destination $NyaAchieves -Force
    $NyaAchievesContent = Get-Content $NyaAchieves
  }
  
  $SearchString = 'DataManager.onStoryXLSXLoad = function(buffer, filename) {'
  $JSNyaModdedLangPath = $NyaModdedLangPath -replace '\\', '\\'
  $TheCode = @"
  const fs = require('fs');
  const langPath = '$JSNyaModdedLangPath';
  if (fs.existsSync(langPath)) { buffer = fs.readFileSync('$JSNyaModdedLangPath'); }
"@

  Write-Output 'Applying codes...'
  $NyaAchievesContent = Get-Content $NyaAchieves -Raw
  $NyaAchievesContent = $NyaAchievesContent.Replace('NYA.ACHIEVES = {};', "/** MODDED */`nNYA.ACHIEVES = {};")
  $NyaAchievesContent = $NyaAchievesContent.Replace($SearchString, "$SearchString`n$TheCode")
  Set-Content -Path $NyaAchieves -Value $NyaAchievesContent
  
  Write-Output 'Copying the modded dialog file to the game location...'
  Copy-Item $LangModPath -Destination $NyaModdedLangPath -Force

  Write-Output "Successfully patched the dialog mod! You can now launch the game."
}

Function ExtractDialogSource {
  $DefaultNyaruruGamePath = "C:\Program Files (x86)\Steam\steamapps\common\Nyaruru"
  $NyaruruGamePath = "$DefaultNyaruruGamePath"

  if (-Not (Test-Path $DefaultNyaruruGamePath)) {
    Write-Output '- Locate the Nyaruru installation folder...'
    $NyaruruGamePath = Get-NyaruruPath
  }

  Write-Output "Nyaruru game location: $NyaruruGamePath"

  if ($NyaruruGamePath -eq '') {
    Write-Output 'ERROR: Nyaruru game location cannot be empty.'
    exit 1
  }

  $NyaFolder = "$NyaruruGamePath\js\nya"
  $NyaAchieves = "$NyaFolder\nya_achieves.js"
  $NyaAchievesBackup = "$NyaAchieves.bak"
  $NyaSourceLangPath = "$NyaruruGamePath\source.xlsx"

  Write-Output 'Checking nya_achieves.js...'
  if (-Not (Test-Path $NyaAchieves)) {
    Write-Output "ERROR: Path is probably not a valid Nyaruru game location, cannot find $NyaAchieves"
    exit 1
  }

  if (Test-Path $NyaAchievesBackup) {
    Write-Output 'Restoring the original nya_achieves.js...'
    Copy-Item $NyaAchievesBackup -Destination $NyaAchieves -Force
    $NyaAchievesContent = Get-Content $NyaAchieves
  } else {
    Write-Output 'Creating backup for nya_achieves.js...'
    Copy-Item $NyaAchieves -Destination $NyaAchievesBackup
  }

  $SearchString = 'DataManager.onStoryXLSXLoad = function(buffer, filename) {'
  $JSNyaSourceLangPath = $NyaSourceLangPath -replace '\\', '\\'
  $TheCode = @"
  const fs = require('fs');
  const langPath = '$JSNyaSourceLangPath';
  fs.writeFileSync(langPath, buffer);
"@

  Write-Output 'Applying codes...'
  $NyaAchievesContent = Get-Content $NyaAchieves -Raw
  $NyaAchievesContent = $NyaAchievesContent.Replace('NYA.ACHIEVES = {};', "/** MODDED */`nNYA.ACHIEVES = {};")
  $NyaAchievesContent = $NyaAchievesContent.Replace($SearchString, "$SearchString`n$TheCode")
  Set-Content -Path $NyaAchieves -Value $NyaAchievesContent

  Write-Output 'Successfully patched the extraction script!'
  Write-Output "The next step is to launch the game once, and then the file should be located at $NyaSourceLangPath"
}

Function RestoreOriginalFile {
  $DefaultNyaruruGamePath = "C:\Program Files (x86)\Steam\steamapps\common\Nyaruru"
  $NyaruruGamePath = "$DefaultNyaruruGamePath"

  if (-Not (Test-Path $DefaultNyaruruGamePath)) {
    Write-Output '- Locate the Nyaruru installation folder...'
    $NyaruruGamePath = Get-NyaruruPath
  }

  Write-Output "Nyaruru game location: $NyaruruGamePath"

  if ($NyaruruGamePath -eq '') {
    Write-Output 'ERROR: Nyaruru game location cannot be empty.'
    exit 1
  }

  $NyaFolder = "$NyaruruGamePath\js\nya"
  $NyaAchieves = "$NyaFolder\nya_achieves.js"
  $NyaAchievesBackup = "$NyaAchieves.bak"

  if (-Not (Test-Path $NyaFolder)) {
    Write-Output 'ERROR: The path seems to be not a valid Nyaruru game location'
    exit 
  }

  if (-Not (Test-Path $NyaAchievesBackup)) {
    Write-Output 'The backup file is missing! (nya_achieves.js.bak)'
    Write-Output 'If you already have a backup of the game, you can restore it that way.'
    Write-Output 'If you installed it through Steam, you can do "Verifying the integrity of game files" to restore the modified game files,'
    Write-Output 'You can find about it in here https://help.steampowered.com/en/faqs/view/0C48-FCBD-DA71-93EB.'
    exit 1
  }

  Write-Output 'Restoring the original nya_achieves.js...'
  Copy-Item $NyaAchievesBackup -Destination $NyaAchieves -Force

  Write-Output 'The file has been successfully restored!'
}

Function Get-DialogModPath {
  $BrowseLang = New-Object System.Windows.Forms.OpenFileDialog -Property @{
    InitialDirectory = [Environment]::GetFolderPath('MyDocuments')
    Filter           = 'SpreadSheet (*.xlsx)|*.xlsx'
  }
  $BrowseLang.ShowDialog() | Out-Null
  return $BrowseLang.FileName
}

Function Get-NyaruruPath {
  $BrowseNyaruru = New-Object System.Windows.Forms.FolderBrowserDialog
  $BrowseNyaruru.ShowDialog() | Out-Null
  return $BrowseNyaruru.SelectedPath
}

Main
