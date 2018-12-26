'**************************************************************
'*
'* Include File: WinMenu.BI
'*
'* Requires:     PMBase.BI (RECTL type)
'*
'* Description:  Menu Manager
'*
'*************************************************************

' Menu control styles

CONST MSACTIONBAR        = &H00000001&
CONST MSTITLEBUTTON      = &H00000002&
CONST MSVERTICALFLIP     = &H00000004&

DECLARE FUNCTION WinLoadMenu&(BYVAL hwndFrame AS LONG,_
                              BYVAL hmod AS INTEGER,_
                              BYVAL idMenu AS INTEGER)

' Menu class name

CONST WCMENU         = &Hffff0004&

' Menu control messages

CONST MMINSERTITEM           = &H0180
CONST MMDELETEITEM           = &H0181
CONST MMQUERYITEM            = &H0182
CONST MMSETITEM              = &H0183
CONST MMQUERYITEMCOUNT       = &H0184
CONST MMSTARTMENUMODE        = &H0185
CONST MMENDMENUMODE          = &H0186
CONST MMDISMISSMENU          = &H0187
CONST MMREMOVEITEM           = &H0188
CONST MMSELECTITEM           = &H0189
CONST MMQUERYSELITEMID       = &H018a
CONST MMQUERYITEMTEXT        = &H018b
CONST MMQUERYITEMTEXTLENGTH  = &H018c
CONST MMSETITEMHANDLE        = &H018d
CONST MMSETITEMTEXT          = &H018e
CONST MMITEMPOSITIONFROMID   = &H018f
CONST MMITEMIDFROMPOSITION   = &H0190
CONST MMQUERYITEMATTR        = &H0191
CONST MMSETITEMATTR          = &H0192
CONST MMISITEMVALID          = &H0193

' WinCreateMenu is not the advised method of creating a menu.
' It requires creating a binary resource area in the data
' segment using a variant record (which is not supported in BASIC)
' documented in Chapter 17 of "OS/2 Programmer's Reference, Volume I".
' It is advised to use the resource compiler and WinLoadMenu instead.
DECLARE FUNCTION WinCreateMenu&(BYVAL hwndParent AS LONG,_
                                BYVAL lpmt AS LONG)

' Owner Item Structure (Also used for listboxes)

TYPE OWNERITEM 
    hwnd AS LONG
    hps AS LONG
    fsState AS INTEGER
    fsAttribute AS INTEGER
    fsStateOld AS INTEGER
    fsAttributeOld AS INTEGER
    rclItem AS RECTL
    idItem AS INTEGER ' field contains idItem for menus, iItem for lb.
    hItem AS LONG
END TYPE

' Menu item

TYPE MENUITEM 
    iPosition AS INTEGER
    afStyle AS INTEGER
    afAttribute AS INTEGER
    id AS INTEGER
    hwndSubMenu AS LONG
    hItem AS LONG
END TYPE

CONST MITEND         =-1
CONST MITNONE        =-1
CONST MITMEMERROR    =-1
CONST MITERROR       =-1
CONST MIDNONE        =MITNONE
CONST MIDERROR       =-1

' Menu item styles & attributes

CONST MISTEXT            = &H0001

CONST MISBITMAP          = &H0002
CONST MISSEPARATOR       = &H0004

CONST MISOWNERDRAW       = &H0008

CONST MISSUBMENU         = &H0010
CONST MISSYSCOMMAND      = &H0040
CONST MISHELP            = &H0080
CONST MISSTATIC          = &H0100
CONST MISBUTTONSEPARATOR = &H0200
CONST MISBREAK           = &H0400
CONST MISBREAKSEPARATOR  = &H0800

CONST MIANODISMISS       = &H0020
CONST MIAFRAMED          = &H1000
CONST MIACHECKED         = &H2000
CONST MIADISABLED        = &H4000
CONST MIAHILITED         = &H8000
