#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%
#SingleInstance force
DetectHiddenWindows, On
SetBatchLines -1
SetKeyDelay, -1, 10  ;appears to make jumps more reliable

;highlight colors
redcol := "FFCCCC", greencol := "95E495" 
bluecol := "0099FF", yellowcol := "ffff60" 
xmo := redcol

Menu, TRAY, Tip, sumatra_highlight_helper
Menu, Tray, Add  ;separator line
Menu, Tray, Add, SUMATRA_HIGHLIGHT_HELPER, info 
Menu, Tray, Add, -- how to use --, info 
Menu, Tray, Add  ;separator line
Menu, Tray, Default, SUMATRA_HIGHLIGHT_HELPER
TrayTip, Sumatra Highlight Helper, double click tray icon for info,5
return

info:
MsgBox, ;
(
SUMATRA HIGHLIGHT HELPER
Add, remove and jump between different color highlights in Sumatra PDF

version 170523 -- free software GPLv3 -- made by nod5.dcmembers.com
-- icon CC BY 3.0, p.yusukekamiyamane.com

SETUP:
1. Must install Sumatra PDF Prerelease version 
   https://www.sumatrapdfreader.org/prerelease.html
   (Needed for the highlight command.)
2. Settings > Advanced Options > SaveIntoDocument = false 
   Settings > Advanced Options > FullPathInTitle = true 
   (All needed for the script to work.)

COMMANDS:
H = Highlight selected text + autosaves it into pdfname.pdf.smx

Ctrl+H = Remove all highlighting on this pdf page
Hold CapsLock + move mouse = Remove all highlighting mouse moves over
Win+H = Toggle highlighting visible/hidden

Y = Highlight selected text with red color
U = Highlight selected text with green color
O = Make a blue square dot at the mouse pointer

Ctrl+Win+PgUp/PgDn = Jump to next/prev highlight page
Ctrl+Win+Home/End = Jump to first/Last highlight page

Shift+Ctrl+Win+H/Y/U/O = select jump color filter (yellow/red/green/blue)
Shift+Ctrl+Win+space = toggle jump color filters
Shift+Ctrl+Win+PgUp/PgDn = Jump to next/prev filter color highlight page
Shift+Ctrl+Win+Home/End = Jump to first/Last filter color highlight page

Mouse Lbutton + Rbutton = Highlight selected text
(note: hold down buttons to toggle color for this highlight)

Hold Mouse Lbutton + Mbutton = Remove all highlighting mouse moves over

Mouse Lbutton + ScrollWheel Up/Down = Jump to next/prev highlight page

NOTE:
Sumatra Highlight Helper is really "feature request ware". 
I hope the Sumatra PDF devs try and like the features and make them native.
)
return

#IfWinActive, ahk_class SUMATRA_PDF_FRAME
#h::  ;TOGGLE HIGHLIGHTS
WinGetTitle, xtitle, A
xt := RegExReplace(xtitle, "(^.*\.pdf) - .*$", "$1")
IfExist, %xt%.smx
 FileMove, %xt%.smx, %xt%_OFF.smx, 1
Else IfExist, %xt%_OFF.smx
{
FileMove, %xt%_OFF.smx, %xt%.smx, 1
tooltip, highlight on
settimer,tip,500
}
send r  ;refresh Sumatra, shows updated highlights
return

tip:
SetTimer,tip, Off
tooltip
return

getvars() {
global  
WinGetTitle, xtitle, A
ControlGetText, xedit, Edit1, A 	;page num from editbox (works even when edit is hidden)
xp := xedit
ControlGetText, xlen, Static3, A ;text after editbox. "(6 / 102)" (if virtual pages) or "/ 102".
RegExMatch(xlen,"\((\d+)",xm) ;real pagenum (pagecount from pdf start) --> edit1 num is virtual
xp := if xm1 ? xm1 : xp  			;use real num for command line page jump 
xlen := RegExReplace(xlen,"^.*/ (\d+)(?:\D|)","$1") ;pdf len "/ 102" --> 102
xt := RegExReplace(xtitle, "(^.*(?:pdf|djvu)) - .*$", "$1")
FileRead,smx, %xt%.smx
}

;---- .SMX HIGHLIGHT FORMAT ----
;...
;
;[highlight]
;page = 15
;rect = 105 154 151 12       ;X Y W H  where 0 0 is upper left corner
;color = #ffff60
;opacity = 0.8
;
;[...

;note: rect drawn highlights (Ctrl+Lbutton) have decimals in .smx:
;rect = 91.9728 228.302 186.451 122.296

save_smx(xt,smx)
{
ifnotexist, %xt%.smx
 return
FileDelete, %xt%.smx
FileAppend, %smx%, %xt%.smx
ifwinactive, ahk_class SUMATRA_PDF_FRAME
 send r ;reload pdf, remembers page
}

^h::  ;REMOVE ALL HIGHLIGHTING ON ACTIVE PAGE
getvars() 
if smx =
 return
smx := RegExReplace(smx,"Us)\[highlight]\Rpage = " xp "\R.*opacity.*(?:\R\R|\R)", "")
save_smx(xt,smx)
return

Lbutton & Mbutton::  ;REMOVE HIGHLIGHT UNDER MOUSE POINTER
Send {Lbutton up}

CapsLock:: ;REMOVE HIGHLIGHT UNDER MOUSE POINTER 
getvars() 
if smx =
 return
sleep 100

loop,3
{
	ControlGetText, xpos, SUMATRA_PDF_NOTIFICATION_WINDOW1, A
	if (xpos != "" and InStr(xpos,"pt") != 0 )  ;need pos in pt measure, not mm or in
	 break
	send m
	sleep 30
}
if xpos = 
{
send {Esc} ;close notification win
return 
}

Control, Hide, , SUMATRA_PDF_NOTIFICATION_WINDOW1, A

SetTimer, pos_update, 10
if (a_thislabel == "CapsLock")
 KeyWait, CapsLock
else
{
KeyWait, Lbutton
KeyWait, Mbutton
}
SetTimer, pos_update, Off
tooltip
send {Esc} ;close notification win
save_smx(xt,smx)
return

pos_update: 
ControlGetText, xpos, SUMATRA_PDF_NOTIFICATION_WINDOW1, A
;tooltip, %xpos%
RegExMatch(xpos,": (\d+)[,\.]. x (\d+)[,\.].",xpos) ;x and y pos without decimals
xhigh := StrSplit(smx,"[highlight]")
For Key,Value in xhigh
{
RegExMatch(value,"rect = ([0-9\.]+) ([0-9\.]+) ([0-9\.]+) ([0-9\.]+)",xr)  
if ( xpos1 >= round(xr1) and xpos1 <= round(xr1+xr3) and xpos2 >= round(xr2) and xpos2 <= round(xr2 + xr4) )
 smx := RegExReplace(smx,"Us)\[highlight]\Rpage = " xp "\Rrect = " xr1 " " xr2 " " xr3 " " xr4 ".*opacity.*(?:\R\R|\R)", "")
}
return

+^#Home::  ;JUMP FIRST/LAST PAGE WITH (COLOR FILTER) HIGHLIGHT
+^#End::
^#Home::  ;JUMP FIRST/LAST PAGE WITH HIGHLIGHT
^#End::
getvars() 
if smx =
 return
xhigh := StrSplit(smx,"[highlight]") ;array
xhigh.Remove(1,1) ;trim text before first highlight section

xhighfilter := Object() 
For Key,Value in xhigh
if InStr(Value, xmo)   ;filter color
 xhighfilter.insert(Value) ;sub array with (filter color) highlights

xmatch := InStr(a_thislabel, "+") ? xhighfilter : xhigh
xmax := 0, xmin := 99999
For Key,Value in xmatch
{
RegExMatch(Value,"U)page = (\d+)\R",xp)
xmax := xp1 > xmax ? xp1 : xmax  ;highest page in arr
xmin := xp1 < xmin ? xp1 : xmin  ;lowest page 
}
x := InStr(a_thislabel, "Home") ? xmin : xmax
if (x == 0 or x == 99999)
 return
WinGet, xpath, ProcessPath, A
Run "%xpath%" "%xt%" -reuse-instance -page %x%  ;command line, instead of editbox input
return

+^#h::			;SET SHIFT JUMP COLOR FILTER
+^#y::
+^#u::
+^#o::
xthis := SubStr(a_thislabel, 4)
xmo := xthis=="h" ? yellowcol : xthis=="y" ? redcol : xthis=="u" ? greencol : bluecol
xflash(100, xmo)
return

+^#Space::   ;TOGGLE SHIFT JUMP COLOR FILTER
xmo := xmo == redcol ? greencol : xmo==greencol ? bluecol : xmo==bluecol ? yellowcol : redcol
xflash(100, xmo)
return


;size = w/h of square, xmo = color, mpos 1 = position at mouse pointer
xflash(size, xmo, mpos:="win", timeout:=1)  
{
;flash notify color
if (mpos == "mouse")
{
 CoordMode, Mouse, Screen
 MouseGetPos, mposx, mposy
 mposx -= 8, mposy -= 8
} 
else  ;mpos win
{
WinGetActiveStats, wint, winw, winh, winx, winy
mposx := winx + winw/2 - size/2
mposy := winy + winh/2 - size/2
}
Gui +ToolWindow -SysMenu -Caption -resize
Gui, Color, %xmo%
if mpos
 Gui, Show, x%mposx% y%mposy% w%size% h%size%
else
 Gui, Show, w%size% h%size%
if timeout
	{
	sleep 200
	Gui, destroy
	}
}
return

Lbutton & WheelDown:: 
Send {Lbutton up}
goto ^#PgDn
return

Lbutton & WheelUp:: 
Send {Lbutton up}
goto ^#PgUp
return

+^#PgUp::  ;JUMP NEXT/PREV PAGE WITH (FILTER COLOR) HIGHLIGHT
+^#PgDn::
^#PgUp::  ;JUMP NEXT/PREV PAGE WITH HIGHLIGHT
^#PgDn::
getvars() 
if smx =
 return
xcount := InStr(a_thislabel, "Up") ? xp : xlen - xp  
;ex: @70 of 100p --> if PgUp 70, if PgDn 30  --> number of pages loop at most checks
xcol := InStr(a_thislabel, "+") ? ".*\Rcolor = #" xmo : ""  ;if Shift: jump only (xmode) highlights
x := xp
loop, %xcount%
{
x := InStr(a_thislabel, "Up") ? xp-a_index : xp+a_index  ;step one page back/forward
if ( RegExMatch(smx,"U)page = " x "\R" xcol) != 0 ) ;match page (and color, if shift is down)
	{
	WinGet, xpath, ProcessPath, A  ;sumatra.exe
	Run "%xpath%" "%xt%" -reuse-instance -page %x% ;command line, instead of editbox input
	;https://github.com/sumatrapdfreader/sumatrapdf/wiki/Command-line-arguments
	;says -reuse-instance option has "behaviour undefined" but works
	;if two processes are open with same file the command operates on the active sumatra window
	break
	} 
}
return

;BLUE RECTANGLE HIGHLIGHT AT MOUSE POINTER POS
o::
getvars() 

ControlGetFocus, xcontr, A
if (xcontr == "Edit2")  ;let through input when find text box has focus 
{
hotkey, IfWinActive, ahk_class SUMATRA_PDF_FRAME
hotkey, %a_thislabel%, toggle ;temp disable hotkey
send %a_thislabel%
hotkey, %a_thislabel%, toggle
return
}

if smx =
 return
sleep 100
loop,3
{
	ControlGetText, xpos, SUMATRA_PDF_NOTIFICATION_WINDOW1, A
	if (xpos != "" and InStr(xpos,"pt") != 0 )  ;need pos in pt measure, not mm or in
	 break
	send m
	sleep 30
}
if xpos =
 return
send {Esc} ;close notification win

RegExMatch(xpos,": (\d+)[,\.]. x (\d+)[,\.].",xpos) ;x and y pos without decimals
if (xp == "") or (xpos1 == "") or (xpos2 == "") 
 return
xpos1 := xpos1-3 < 1 ? 1 : xpos1-3
xpos2 := xpos2-3 < 1 ? 1 : xpos2-3

xblob = 
(

[highlight]
page = %xp%
rect = %xpos1% %xpos2% 9 9
color = #%bluecol%
opacity = 0.8

)

bluerect = 1
FileAppend, %xblob%, %xt%.smx
ifwinactive, ahk_class SUMATRA_PDF_FRAME
 send r ;reload pdf, remembers page
return

~Lbutton & Rbutton::  ;highlight text
time1 := A_TickCount
hmold =
SetTimer, hmode, 10
KeyWait, Rbutton
SetTimer, hmode, off
Gui, destroy
if (hm == "abort")
 return
Send {Lbutton up}
Send {Rbutton up}
goto %hm%  ;h/y/u --> yellow/red/green highlight
return

hmode:   ;set color filter based on button press duration
tdif := A_TickCount-time1
hm := tdif<350 ? "h" : tdif<900 ? "y": tdif<1400 ? "u" : "abort"
hmcol := hm=="h" ? yellowcol : hm=="y" ? redcol : hm=="u" ? greencol : ""
size := 30
if (hm == "abort") or (hm == "h")
 gui, destroy
else if (hmold != hm)
 xflash(size, hmcol, "mouse", 0)
hmold := hm
return

u::
y::
h::  ;AUTOSAVE TO SMX AFTER HIGHLIGHT
WinGetTitle, xtitle, A
xt := RegExReplace(xtitle, "(^.*\.pdf) - .*$", "$1")

ControlGetFocus, xcontr, A
if (xcontr == "Edit2")  ;let through input when find text box has focus 
{
hotkey, IfWinActive, ahk_class SUMATRA_PDF_FRAME
hotkey, %a_thislabel%, toggle ;temp disable hotkey
send %a_thislabel%
hotkey, %a_thislabel%, toggle
return
}

IfNotExist, %xt%.smx
 IfExist, %xt%_OFF.smx
  FileMove, %xt%_OFF.smx, %xt%.smx, 1  ;first toggle on if off, so smx can be updated
sleep 50
send r
hotkey, IfWinActive, ahk_class SUMATRA_PDF_FRAME
hotkey, h, toggle ;temp disable hotkey so native highlight command works
send h
hotkey, h, toggle

if (a_thislabel != "h")   ;highlight with different color
{
getvars() ;xp smx xt
xhigh := StrSplit(smx,"[highlight]")
xhighcount1 := xhigh.MaxIndex()  ;old count
FileGetSize, xsize1, %xt%.smx
}

send ^s  ;automate save popup wins ;only possible method for now
;todo test ways to optimize speed for handling of this window

WinWaitActive, Save As ahk_class #32770

;fill dialog window with active pdf file path
if xt not contains :
 return
ControlSetText, Edit1,%xt%, Save As ahk_class #32770
send {enter}
WinWaitActive, Confirm Save As ahk_class #32770
send !y

if (a_thislabel != "h")   ;highlight with different color
{
bluerect = 
Loop
	{
	FileGetSize, xsize2, %xt%.smx
	if (xsize1 != xsize2)  ;wait for .smx writing
	 break
	sleep 50
	if (a_index := 80 or bluerect ) ;abort after 4 seconds or if bluerect hotkey triggered
	 return
	}
 
getvars() ;xp smx xt
xhigh := StrSplit(smx,"[highlight]")
xhighcount2 := xhigh.MaxIndex() ;new count
xhightcount1 := xhightcount1 == "" ? 0 : xhightcount1

tempcol := a_thislabel == "y" ? redcol : greencol

For Key,Value in xhigh
	{
	if (a_index <= xhighcount1)
	 continue
	                          ;X Y W H  where 0 0 is upper left corner 
	RegExMatch(value,"rect = ([0-9\.]+) ([0-9\.]+) ([0-9\.]+) ([0-9\.]+)",xr) 
	smx := RegExReplace(smx,"Us)(\[highlight]\Rpage = " xp "\Rrect = " xr1 " " xr2 " " xr3 " " xr4 "\Rcolor = #)......", "$1" tempcol)
}
save_smx(xt,smx)
}
return
#IfWinActive
