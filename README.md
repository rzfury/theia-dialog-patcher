# Theia Dialog Patcher (a dialog patcher for Nyaruru Fishy Fight)

This is a Powershell script that can patch and extract dialog file for Nyaruru Fishy Fight.

## Download and Usage

The Powershell script can be [downloaded here](https://raw.githubusercontent.com/rzfury/theia-dialog-patcher/main/TheiaPatcher.ps1) by right-clicking on the link and then choose *Save Link As*.

### Requirements

1. Nyaruru Fishy Fight game installed,
2. Powershell

### Usage

> Before running the script, it's recommended to backup the game first.

1. **In the Windows desktop:** right-click the script and select: *Execute with PowerShell* or *Run with PowerShell*
2. **On the command-line:** launch a terminal application (e.g. *Windows Terminal*), then type: `cd <PATH>`, then: `./TheiaPatcher.ps1`.
3. Follow the instruction on the running script.

If an error that says `TheiaPatcher.ps1 is not digitally signed` shows up. You will have to do one of the following:

#### To be able to run it without using terminal
1. Right-click on `TheiaPatcher.ps1` (if you on Windows 11, do Shift + Right-click),
2. Select Properties,
3. Check the unblock checkbox.

![](https://learn-attachment.microsoft.com/api/attachments/1e085ff6-282a-4896-92e3-a1cd7baef3eb?platform=QnA)

#### Using terminal
1. Open a terminal application,
2. Paste the following command, then press Enter
```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```
3. Do the step-2 on usage to run the script from your terminal app.
   
## How the patch works

Since the game is not obfuscated, it is pretty easy to create a mod for this game.

The patch only modify one file (`Nyaruru/js/nya/nya_achieves.js`). There's a section in the code that handle the loading of a dialog file.

```js
// ...
DataManager.onStoryXLSXLoad = function(buffer, filename) {
// ...
```

The Powershell script will inject the following codes based on your choice of action when running the script.

If you choose to install a dialog file, the patch will inject this code to `onStoryXLSXLoad` on the first lines. This script change the buffer value before executing further.

```js
// import a file handling library
const fs = require('fs');
// the path to dialog file, generated by the script
const langMod = 'path\\to\\lang\\file.xlsx';
// check if `langMod` exists, then set the buffer to `langMod` file
if (fs.existsSync(langMod)) { buffer = fs.readFileSync(langMod); }
```

If you choose to extract the dialog file, the patch will inject this code to `onStoryXLSXLoad` on the first lines. This script save the buffer value to a file.

```js
// import a file handling library
const fs = require('fs');
// the path to save the dialog file, generated by the script
const langMod = 'path\\to\\save\\lang\\file.xlsx';
// write the buffer to a new file in `langMod`
fs.writeFileSync(langMod, buffer);
```

## Doing a translation

The game use spreadsheet file to store the dialogs. You can easily edit the dialog source file with Microsoft Excel, Google Spreadsheet, or any spreadsheet apps.

## Cons / Drawbacks

This patch only affects character dialog. Other UI elements such as menu, popup, etc. will not be affected.

Also, when you change the languages in game, the dialog will not be affected, because when choosing a language from the setting, the patched dialog will always be loaded instead.

## Undoing the patch

To undo the patch, you can restore the original game files by [Verifying the integrity of game files.](https://help.steampowered.com/en/faqs/view/0C48-FCBD-DA71-93EB), or if you have backup of `nya_achieves.js` just restore the original file.
