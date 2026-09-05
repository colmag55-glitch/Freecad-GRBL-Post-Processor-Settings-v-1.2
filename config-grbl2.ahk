;======= GRBL Post Processor Settings LAST UPDATE FIXED 31/08/2026 ===============
#NoEnv
#SingleInstance Force
SetWorkingDir, %A_ScriptDir%
SetTitleMatchMode, 2

;FileCreateDir,%A_ScriptDir%\BUTTONS
;SetWorkingDir,%A_ScriptDir%\BUTTONS 
;------------------------------------------------------

;FileInstall,BUTTONS\Browse4.png,%A_WorkingDir%\Browse4.png
;FileInstall,BUTTONS\Close4.png,%A_WorkingDir%\Close4.png
;FileInstall,BUTTONS\Preview4.png,%A_WorkingDir%\Preview4.png
;FileInstall,BUTTONS\Print-Page.png,%A_WorkingDir%\Print-Page.png
;FileInstall,BUTTONS\Reload4.png,%A_WorkingDir%\Reload4.png
;FileInstall,BUTTONS\movie.ico,%A_WorkingDir%\Resete4.png
;FileInstall,BUTTONS\Save4.png,%A_WorkingDir%\Save4.png



; ============================================================
; GRBL POST PROCESSOR SETTINGS EDITOR
; AutoHotkey v1.1.23.7
;
; Edits:
;   PRECISION
;   TRANSLATE_DRILL_CYCLES
;   PREAMBLE
;   POSTAMBLE
;
; The rest of grbl_post.py is preserved.
;
; A backup is created before saving:
;   grbl_post.py.bak
; ============================================================


; ============================================================
; RUN AS ADMINISTRATOR
; grbl_post.py is normally inside Program Files.
; ============================================================

if !A_IsAdmin
{
    if A_IsCompiled
    {
        Run, *RunAs "%A_ScriptFullPath%"
    }
    else
    {
        Run, *RunAs "%A_AhkPath%" "%A_ScriptFullPath%"
    }

    ExitApp
}


; ============================================================
; SETTINGS
; ============================================================

TargetFile := A_ScriptDir . "\grbl_post.py"

DefaultPrecision := 3
DefaultTranslate := 1

DefaultPreamble =
(
G17 G90
M3 S1000
G4 P0.5
S2000
G4 P0.5
S5000
G4 P0.5
S8000
G4 P1
)

DefaultPostamble =
(
M5
G17 G90
G4 P0.5
G00 X0.0000 Y0.0000
M2 End Of Program 
)

; Python triple quotes: """
Q3 := Chr(34) . Chr(34) . Chr(34)


; ============================================================
; MAIN GUI
; ============================================================

;Gui, Font, s10, Segoe UI

Gui, Color, 111111 ;0A0A0A
Gui, Font, s14 c00FFAA Bold, Segoe UI


Gui, Add, GroupBox, x15 y10 w590 h70, GRBL Post Processor

Gui, Add, Text, x30 y38 w40 h23, File:
Gui, Add, Edit, Cblue x75 y35 w430 h25 vFilePath, %TargetFile%
;Gui, Add, Button, x510 y34 w80 h27 gBrowseFile, Browse...
Gui, Add, Picture, x510 y34 w80 h27 +BackgroundTrans gBrowseFile, %A_ScriptDir%\BUTTONS\Browse4.png


Gui, Add, GroupBox, x15 y90 w590 h90, Basic Settings

Gui, Add, Text, x30 y120 w90 h23, Precision:

Gui, Add, Edit,  Cblue x125 y117 w70 h25 vPrecisionEdit, %DefaultPrecision%

Gui, Add, CheckBox, x215 y118 w360 h25 vTranslateEdit Checked, Translate G81 / G82 / G83 drill cycles


Gui, Add, Text, x30 y195 w150 h23, Preamble:
;Gui, Color, CCFFCC
Gui, Add, Edit, Cblue x30 y220 w560 h145 vPreambleEdit +Multi +WantTab +HScroll +VScroll

;Gui, Add, Edit, Cblue x30 y220 w560 h145 vPreambleEdit +Multi +WantTab +HScroll +VScroll
;GuiControlGet, hPreamble, Hwnd, PreambleEdit


Gui, Add, Text, x30 y375 w150 h23, Postamble:
;Gui, Color, CCFFCC
Gui, Add, Edit, Cblue x30 y400 w560 h145 vPostambleEdit +Multi +WantTab +HScroll +VScroll

;Gui, Add, Edit, x30 y400 w560 h145 vPostambleEdit +Multi +WantTab +HScroll +VScroll
;GuiControlGet, hPostamble, Hwnd, PostambleEdit



;Gui, Add, Button, x30 y560 w120 h35 gLoadFile, Reload
Gui, Add, Picture, x30 y560 w120 h35 +BackgroundTrans gLoadFile, %A_ScriptDir%\BUTTONS\Reload4.png

;Gui, Add, Button, x160 y560 w120 h35 gSaveFile, Save
Gui, Add, Picture, x160 y560 w120 h35 +BackgroundTrans gSaveFile, %A_ScriptDir%\BUTTONS\Save4.png

;Gui, Add, Button, x290 y560 w120 h35 gPreviewConfig, Preview
Gui, Add, Picture, x290 y560 w120 h35 +BackgroundTrans gPreviewConfig, %A_ScriptDir%\BUTTONS\Preview4.png

;Gui, Add, Button, x420 y560 w80 h35 gResetConfig, Reset
Gui, Add, Picture, x420 y560 w80 h35 +BackgroundTrans gResetConfig, %A_ScriptDir%\BUTTONS\Resete4.png

;Gui, Add, Button, x510 y560 w80 h35 gGuiClose, Close
Gui, Add, Picture, x510 y560 w80 h35 +BackgroundTrans gGuiClose, %A_ScriptDir%\BUTTONS\Close4.png

;Gui, Add, Text, x30 y605 w560 h35 vStatusText, Ready.


; Put defaults in controls
GuiControl,, PreambleEdit, %DefaultPreamble%
GuiControl,, PostambleEdit, %DefaultPostamble%

Gui, Show, w620 h630, GRBL Post Processor Settings v 1.2


; Automatically load the Python file
if FileExist(TargetFile)
{
    Gosub, LoadFile
}
else
{
    SetStatus("grbl_post.py not found. Use Browse.")
}

Return


; ============================================================
; BROWSE
; ============================================================

BrowseFile:

FileSelectFile, ChosenFile, 3,, Select grbl_post.py, Python Files (*.py)

if ErrorLevel
{
    Return
}

GuiControl,, FilePath, %ChosenFile%

Gosub, LoadFile

Return


; ============================================================
; LOAD FILE
; ============================================================

LoadFile:

Gui, Submit, NoHide

GuiControlGet, TargetFile,, FilePath

if !FileExist(TargetFile)
{
    MsgBox, 48, File Not Found, % "Could not find:`n`n" . TargetFile
    SetStatus("File not found.")
    Return
}


; ------------------------------------------------------------
; Read complete Python file
; ------------------------------------------------------------

FileRead, Content, %TargetFile%

if ErrorLevel
{
    MsgBox, 16, Error, % "Could not read:`n`n" . TargetFile
    Return
}


; Normalize line endings
Content := StrReplace(Content, "`r`n", "`n")
Content := StrReplace(Content, "`r", "`n")


; ============================================================
; LOAD PRECISION
; ============================================================

if RegExMatch(Content, "m)^([ \t]*PRECISION[ \t]*=[ \t]*)([0-9]+)", Match)
{
    GuiControl,, PrecisionEdit, %Match2%
}


; ============================================================
; LOAD TRANSLATE_DRILL_CYCLES
; ============================================================

if RegExMatch(Content, "m)^([ \t]*TRANSLATE_DRILL_CYCLES[ \t]*=[ \t]*)(True|False)", Match)
{
    if (Match2 = "True")
    {
        GuiControl,, TranslateEdit, 1
    }
    else
    {
        GuiControl,, TranslateEdit, 0
    }
}


; ============================================================
; LOAD PREAMBLE
; ============================================================

PreamblePattern := "ms)^([ \t]*PREAMBLE[ \t]*=[ \t]*)" . Q3 . "(.*?)" . Q3 . "([^\n]*)"

if RegExMatch(Content, PreamblePattern, Match)
{
    PreambleValue := Match2

    ; Remove first newline
    if (SubStr(PreambleValue, 1, 1) = "`n")
    {
        PreambleValue := SubStr(PreambleValue, 2)
    }

    ; Remove final newline
    if (SubStr(PreambleValue, 0) = "`n")
    {
        PreambleValue := SubStr(PreambleValue, 1, -1)
    }

    GuiControl,, PreambleEdit, %PreambleValue%
}


; ============================================================
; LOAD POSTAMBLE
; ============================================================

PostamblePattern := "ms)^([ \t]*POSTAMBLE[ \t]*=[ \t]*)" . Q3 . "(.*?)" . Q3 . "([^\n]*)"

if RegExMatch(Content, PostamblePattern, Match)
{
    PostambleValue := Match2

    ; Remove first newline
    if (SubStr(PostambleValue, 1, 1) = "`n")
    {
        PostambleValue := SubStr(PostambleValue, 2)
    }

    ; Remove final newline
    if (SubStr(PostambleValue, 0) = "`n")
    {
        PostambleValue := SubStr(PostambleValue, 1, -1)
    }

    GuiControl,, PostambleEdit, %PostambleValue%
}


SetStatus("Loaded: " . TargetFile)

Return


SaveFile:

Gui, Submit, NoHide
GuiControlGet, TargetFile,, FilePath

; ------------------------------------------------------------
; Check file exists
; ------------------------------------------------------------

if !FileExist(TargetFile)
{
    MsgBox, 48, Error, % "File not found:`n`n" . TargetFile
    Return
}

; ------------------------------------------------------------
; Check precision
; ------------------------------------------------------------

if !RegExMatch(PrecisionEdit, "^[0-9]+$")
{
    MsgBox, 48, Error, Precision must be a whole number.
    Return
}

; ------------------------------------------------------------
; Read complete Python file
; ------------------------------------------------------------

FileRead, Content, %TargetFile%

if ErrorLevel
{
    MsgBox, 16, Error, Could not read grbl_post.py.
    Return
}

; Normalize line endings
Content := StrReplace(Content, "`r`n", "`n")
Content := StrReplace(Content, "`r", "`n")

; ------------------------------------------------------------
; Create backup
; ------------------------------------------------------------

BackupFile := TargetFile . ".bak"

FileCopy, %TargetFile%, %BackupFile%, 1

if ErrorLevel
{
    MsgBox, 16, Error, % "Could not create backup:`n`n" . BackupFile
    Return
}

; ============================================================
; PRECISION
; ============================================================

Pos := InStr(Content, "PRECISION =")

if (Pos = 0)
{
    MsgBox, 16, Error, Could not find PRECISION in grbl_post.py.
    Return
}

LineEnd := InStr(Content, "`n", false, Pos)

if (LineEnd = 0)
{
    LineEnd := StrLen(Content) + 1
}

OldLine := SubStr(Content, Pos, LineEnd - Pos)

; Find the comment
CommentPos := InStr(OldLine, "#")

if (CommentPos > 0)
{
    Comment := SubStr(OldLine, CommentPos)
}
else
{
    Comment := ""
}

NewLine := "PRECISION = " . PrecisionEdit

if (Comment != "")
{
    NewLine := NewLine . " " . Comment
}

Content := SubStr(Content, 1, Pos - 1)
    . NewLine
    . SubStr(Content, LineEnd)


; ============================================================
; TRANSLATE_DRILL_CYCLES
; ============================================================

Pos := InStr(Content, "TRANSLATE_DRILL_CYCLES =")

if (Pos = 0)
{
    MsgBox, 16, Error, Could not find TRANSLATE_DRILL_CYCLES in grbl_post.py.
    Return
}

LineEnd := InStr(Content, "`n", false, Pos)

if (LineEnd = 0)
{
    LineEnd := StrLen(Content) + 1
}

OldLine := SubStr(Content, Pos, LineEnd - Pos)

CommentPos := InStr(OldLine, "#")

if (CommentPos > 0)
{
    Comment := SubStr(OldLine, CommentPos)
}
else
{
    Comment := ""
}

if TranslateEdit
{
    TranslateValue := "True"
}
else
{
    TranslateValue := "False"
}

NewLine := "TRANSLATE_DRILL_CYCLES = " . TranslateValue

if (Comment != "")
{
    NewLine := NewLine . " " . Comment
}

Content := SubStr(Content, 1, Pos - 1)
    . NewLine
    . SubStr(Content, LineEnd)


; ============================================================
; PREAMBLE
; ============================================================

Q3 := Chr(34) . Chr(34) . Chr(34)

StartMarker := "PREAMBLE = " . Q3

StartPos := InStr(Content, StartMarker)

if (StartPos = 0)
{
    MsgBox, 16, Error, Could not find PREAMBLE in grbl_post.py.
    Return
}

; Find the opening line ending
OpenEnd := InStr(Content, "`n", false, StartPos)

if (OpenEnd = 0)
{
    MsgBox, 16, Error, Invalid PREAMBLE section.
    Return
}

; Find closing """
ClosePos := InStr(Content, Q3, false, OpenEnd + 1)

if (ClosePos = 0)
{
    MsgBox, 16, Error, Could not find end of PREAMBLE.
    Return
}

PreambleValue := PreambleEdit

PreambleValue := StrReplace(PreambleValue, "`r`n", "`n")
PreambleValue := StrReplace(PreambleValue, "`r", "`n")

NewBlock := StartMarker . "`n" . PreambleValue . "`n" . Q3

Content := SubStr(Content, 1, StartPos - 1)
    . NewBlock
    . SubStr(Content, ClosePos + 3)


; ============================================================
; POSTAMBLE
; ============================================================

StartMarker := "POSTAMBLE = " . Q3

StartPos := InStr(Content, StartMarker)

if (StartPos = 0)
{
    MsgBox, 16, Error, Could not find POSTAMBLE in grbl_post.py.
    Return
}

OpenEnd := InStr(Content, "`n", false, StartPos)

if (OpenEnd = 0)
{
    MsgBox, 16, Error, Invalid POSTAMBLE section.
    Return
}

ClosePos := InStr(Content, Q3, false, OpenEnd + 1)

if (ClosePos = 0)
{
    MsgBox, 16, Error, Could not find end of POSTAMBLE.
    Return
}

PostambleValue := PostambleEdit

PostambleValue := StrReplace(PostambleValue, "`r`n", "`n")
PostambleValue := StrReplace(PostambleValue, "`r", "`n")

NewBlock := StartMarker . "`n" . PostambleValue . "`n" . Q3

Content := SubStr(Content, 1, StartPos - 1)
    . NewBlock
    . SubStr(Content, ClosePos + 3)


; ============================================================
; Convert line endings back to Windows format
; ============================================================

Content := StrReplace(Content, "`n", "`r`n")


; ============================================================
; Write temporary file
; ============================================================

TempFile := TargetFile . ".tmp"

FileDelete, %TempFile%

FileAppend, %Content%, %TempFile%

if ErrorLevel
{
    FileDelete, %TempFile%

    MsgBox, 16, Error, % "Could not write temporary file:`n`n" . TempFile
    Return
}


; ============================================================
; Replace original
; ============================================================

FileMove, %TempFile%, %TargetFile%, 1

if ErrorLevel
{
    FileDelete, %TempFile%

    MsgBox, 16, Error, % "Could not replace grbl_post.py.`n`nYour backup is still here:`n`n" . BackupFile
    Return
}


; ============================================================
; DONE
; ============================================================

SetStatus("Saved successfully.")

MsgBox, 64, Saved, % "Successfully changed:`n`n"
    . "PRECISION = " . PrecisionEdit . "`n"
    . "TRANSLATE_DRILL_CYCLES = " . TranslateValue . "`n`n"
    . "Backup:`n" . BackupFile

Return

; ============================================================
; CHECK FILE
; ============================================================

if !FileExist(TargetFile)
{
    MsgBox, 48, File Not Found, % "Could not find:`n`n" . TargetFile
    Return
}


; ============================================================
; CHECK PRECISION
; ============================================================

if !RegExMatch(PrecisionEdit, "^[0-9]+$")
{
    MsgBox, 48, Invalid Precision, Precision must be a whole number such as 3 or 4.
    Return
}


; ============================================================
; CHECK TRIPLE QUOTES
; ============================================================

if InStr(PreambleEdit, Q3)
{
    MsgBox, 48, Invalid Preamble, The preamble cannot contain three consecutive double quotes.
    Return
}

if InStr(PostambleEdit, Q3)
{
    MsgBox, 48, Invalid Postamble, The postamble cannot contain three consecutive double quotes.
    Return
}


; ============================================================
; READ COMPLETE PYTHON FILE
; ============================================================

FileRead, Content, %TargetFile%

if ErrorLevel
{
    MsgBox, 16, Error, Could not read grbl_post.py.
    Return
}

Content := StrReplace(Content, "`r`n", "`n")
Content := StrReplace(Content, "`r", "`n")


; ============================================================
; CREATE BACKUP
; ============================================================

BackupFile := TargetFile . ".bak"

FileCopy, %TargetFile%, %BackupFile%, 1

if ErrorLevel
{
    MsgBox, 16, Error, % "Could not create backup:`n`n" . BackupFile . "`n`nNothing was changed."
    Return
}


; ============================================================
; REPLACE PRECISION
; ============================================================



PrecisionReplacement := "$1" . PrecisionEdit
NewContent := RegExReplace(Content, "m)^([ \t]*PRECISION[ \t]*=[ \t]*)[0-9]+[^\n]*", PrecisionReplacement, PrecisionCount, 1)

if (PrecisionCount = 0)
{
    MsgBox, 16, Error, % "Could not find PRECISION in:`n`n" . TargetFile . "`n`nBackup was created. Original file was not changed."
    Return
}


; ============================================================
; REPLACE TRANSLATE_DRILL_CYCLES
; ============================================================

if TranslateEdit
    TranslateValue := "True"
else
    TranslateValue := "False"

TranslateReplacement := "$1" . TranslateValue . "$2"
NewContent := RegExReplace(NewContent, "m)^([ \t]*TRANSLATE_DRILL_CYCLES[ \t]*=[ \t]*)(True|False)([^\r\n]*)", TranslateReplacement, TranslateCount, 1)

if (TranslateCount = 0)
{
    MsgBox, 16, Error, % "Could not find TRANSLATE_DRILL_CYCLES in:`n`n" . TargetFile . "`n`nBackup was created. Original file was not changed."
    Return
}


; ============================================================
; REPLACE PREAMBLE
; ============================================================

PreambleValue := PreambleEdit

PreambleValue := StrReplace(PreambleValue, "`r`n", "`n")
PreambleValue := StrReplace(PreambleValue, "`r", "`n")

PreambleReplacement := "$1" . Q3 . "`n" . PreambleValue . "`n" . Q3 . "$3"

NewContent := RegExReplace(NewContent,"ms)^([ \t]*PREAMBLE[ \t]*=[ \t]*)" . Q3 . ".*?" . Q3 . "([^\n]*)",PreambleReplacement,PreambleCount, 1)


if (PreambleCount = 0)
{
    MsgBox, 16, Error, % "Could not find PREAMBLE in:`n`n" . TargetFile . "`n`nBackup was created. Original file was not changed."
    Return
}


; ============================================================
; REPLACE POSTAMBLE
; ============================================================

PostambleValue := PostambleEdit

PostambleValue := StrReplace(PostambleValue, "`r`n", "`n")
PostambleValue := StrReplace(PostambleValue, "`r", "`n")

PostambleReplacement := "$1" . Q3 . "`n" . PostambleValue . "`n" . Q3 . "$3"

;NewContent := RegExReplace(NewContent,"ms)^([ \t]*POSTAMBLE[ \t]*=[ \t]*)" . Q3 . ".*?" . Q3 . "([^\n]*)",PostambleReplacement,PostambleCount,1)

PrecisionReplacement := "$1" . PrecisionEdit . "$2"
NewContent := RegExReplace(Content, "m)^([ \t]*PRECISION[ \t]*=[ \t]*)[0-9]+([^\r\n]*)", PrecisionReplacement, PrecisionCount, 1)


if (PostambleCount = 0)
{
    MsgBox, 16, Error, % "Could not find POSTAMBLE in:`n`n" . TargetFile . "`n`nBackup was created. Original file was not changed."
    Return
}


; ============================================================
; RESTORE WINDOWS LINE ENDINGS
; ============================================================

NewContent := StrReplace(NewContent, "`n", "`r`n")


; ============================================================
; WRITE TEMPORARY FILE
; ============================================================

TempFile := TargetFile . ".tmp"

FileDelete, %TempFile%

FileAppend, %NewContent%, %TempFile%

if ErrorLevel
{
    FileDelete, %TempFile%

    MsgBox, 16, Error, % "Could not create temporary file:`n`n" . TempFile . "`n`nOriginal file was not changed."

    Return
}


; ============================================================
; REPLACE ORIGINAL FILE
; ============================================================

FileMove, %TempFile%, %TargetFile%, 1

if ErrorLevel
{
    FileDelete, %TempFile%

    MsgBox, 16, Error, % "Could not replace:`n`n" . TargetFile . "`n`nBackup remains at:`n" . BackupFile

    Return
}


; ============================================================
; SUCCESS
; ============================================================

SetStatus("Saved successfully.")

MsgBox, 64, Saved, % "grbl_post.py was updated successfully.`n`nBackup created:`n" . BackupFile

Return


; ============================================================
; PREVIEW
; ============================================================

PreviewConfig:

Gui, Submit, NoHide

if TranslateEdit
{
    TranslateValue := "True"
}
else
{
    TranslateValue := "False"
}

PreviewText := "GRBL POST PROCESSOR CONFIGURATION`r`n"
PreviewText .= "================================`r`n`r`n"

PreviewText .= "PRECISION = " . PrecisionEdit . "`r`n"
PreviewText .= "TRANSLATE_DRILL_CYCLES = " . TranslateValue . "`r`n`r`n"

PreviewText .= "PREAMBLE = " . Q3 . "`r`n"
PreviewText .= PreambleEdit . "`r`n"
PreviewText .= Q3 . "`r`n`r`n"

PreviewText .= "POSTAMBLE = " . Q3 . "`r`n"
PreviewText .= PostambleEdit . "`r`n"
PreviewText .= Q3 . "`r`n"

Gui, 2:New
Gui, Font, s15 cBlck Bold, Segoe UI
;Gui, Color, CCFFCC
Gui, 2:Add, Edit, x10 y10 w700 h450 +Multi +ReadOnly +HScroll +VScroll vPreviewEdit, %PreviewText%

;Gui, 2:Add, Button, x10 y470 w100 h30 gPrintPreview, Print Page
Gui, 2:Add, Picture, x10 y470 w100 h30 +BackgroundTrans gPrintPreview, %A_ScriptDir%\BUTTONS\Print-Page.png

;Gui, 2:Add, Button, x120 y470 w100 h30 gClosePreview, Close
Gui, 2:Add, Picture, x120 y470 w100 h30 +BackgroundTrans gClosePreview, %A_ScriptDir%\BUTTONS\Close4.png

Gui, 2:Show, w720 h515, Configuration Preview v 1.2

Return


; ============================================================
; PRINT PREVIEW
; ============================================================

PrintPreview:

Gui, 2:Submit, NoHide

; Create a temporary text file containing the preview.
PrintFile := A_Temp . "\GRBL_Config_Print.txt"

FileDelete, %PrintFile%

FileAppend, %PreviewEdit%, %PrintFile%

if ErrorLevel
{
    MsgBox, 16, Print Error, Could not create the temporary print file.
    Return
}

; Open the Windows Print dialog for the text file.
Run, rundll32.exe %SystemRoot%\System32\shscrap.dll,DoOrganizeFavDlg

; Use Notepad's print command.
Run, notepad.exe /p "%PrintFile%"

; Give Notepad time to send the document to the printer.
Sleep, 1500

; Remove temporary file.
FileDelete, %PrintFile%

Return




; ============================================================
; CLOSE PREVIEW
; ============================================================

ClosePreview:

Gui, 2:Destroy

Return


; ============================================================
; RESET
; ============================================================

ResetConfig:

MsgBox, 36, Reset Configuration, Reset all settings to the original defaults?

IfMsgBox, Yes
{
    GuiControl,, PrecisionEdit, 3
    GuiControl,, TranslateEdit, 1
    GuiControl,, PreambleEdit, %DefaultPreamble%
    GuiControl,, PostambleEdit, %DefaultPostamble%

    SetStatus("Defaults restored. Click Save to save them.")
}

Return


; ============================================================
; STATUS
; ============================================================

SetStatus(Text)
{
    GuiControl,, StatusText, %Text%
}


EditBackground(wParam, lParam)
{
    global hPreamble, hPostamble

    if (lParam = hPreamble || lParam = hPostamble)
    {
        DllCall("SetBkColor", "Ptr", wParam, "UInt", 0xCCFFCC)

        static hBrush := DllCall("CreateSolidBrush", "UInt", 0xCCFFCC, "Ptr")
        return hBrush
    }
}

; ============================================================
; CLOSE PROGRAM
; ============================================================

^Esc::ExitApp

GuiClose:

GuiEscape:

Gui, Destroy
ExitApp

Return