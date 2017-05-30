# sumatra_highlight_helper
AutoHotkey helper script to add, remove and jump between different color highlights in Sumatra PDF reader
 
version 170523 -- free software GPLv3 -- by nod5 -- icon CC BY 3.0, p.yusukekamiyamane.com  
  
## SETUP:
1. Must install Sumatra PDF Prerelease version   
   https://www.sumatrapdfreader.org/prerelease.html  
   (Needed for the highlight command.)  
2. Settings > Advanced Options > SaveIntoDocument = false   
   Settings > Advanced Options > FullPathInTitle = true   
   (All needed for the script to work.)  

## COMMANDS:  
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
  
## NOTE:  
Sumatra Highlight Helper is really "feature request ware".   
I hope the Sumatra PDF devs try and like the features and make them native.  

## SCREENSHOTS:
https://imgur.com/AbQp6ga  
https://imgur.com/pCN6Rbw  
https://imgur.com/5gaVDWJ  
