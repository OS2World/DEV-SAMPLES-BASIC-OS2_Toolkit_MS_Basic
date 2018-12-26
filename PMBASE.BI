'**************************************************************
'*
'* Include File: PMBase.BI
'*
'* Requires:     (WinGen.BI and RegBas.BI included)
'*
'* Description:  Functions and constants necessary for all PM
'*               programs. Everything in this file has been
'*               extracted from others.
'*
'*************************************************************

REM $INCLUDE: 'WinGen.BI'
REM $INCLUDE: 'RegBas.bi'

TYPE RECTL       ' rcl 
    xLeft AS LONG
    yBottom AS LONG
    xRight AS LONG
    yTop AS LONG
END TYPE ' RECTL

DECLARE FUNCTION WinRegisterClass%(BYVAL hab AS LONG,_
                                   BYVAL pszClassName AS LONG,_
                                   BYVAL pfnWndProc AS LONG,_
                                   BYVAL flStyle AS LONG,_
                                   BYVAL cbWindowData AS INTEGER)

DECLARE FUNCTION WinDefWindowProc&(BYVAL hwnd AS LONG,_
                                   BYVAL msg AS INTEGER,_
                                   BYVAL mp1 AS LONG,_
                                   BYVAL mp2 AS LONG)

DECLARE FUNCTION WinDestroyWindow%(BYVAL hwnd AS LONG)

DECLARE FUNCTION WinEndPaint%(BYVAL hps AS LONG)

DECLARE FUNCTION WinBeginPaint&(BYVAL hwnd AS LONG,_
                                BYVAL hps AS LONG,_
                                BYVAL prclPaint AS LONG)

DECLARE FUNCTION WinFillRect%(BYVAL hps AS LONG,_
                              BYVAL prcl AS LONG,_
                              BYVAL lColor AS LONG)

' WinInitialize/WinTerminate Interface declarations 

DECLARE FUNCTION WinInitialize&(BYVAL ushort AS INTEGER)

DECLARE FUNCTION WinTerminate%(BYVAL hab AS LONG)

' Frame window styles 

CONST FCFTITLEBAR        = &H00000001
CONST FCFSYSMENU         = &H00000002
CONST FCFMENU            = &H00000004
CONST FCFSIZEBORDER      = &H00000008
CONST FCFMINBUTTON       = &H00000010
CONST FCFMAXBUTTON       = &H00000020
CONST FCFMINMAX          = &H00000030
CONST FCFVERTSCROLL      = &H00000040
CONST FCFHORZSCROLL      = &H00000080
CONST FCFDLGBORDER       = &H00000100
CONST FCFBORDER          = &H00000200
CONST FCFSHELLPOSITION   = &H00000400
CONST FCFTASKLIST        = &H00000800
CONST FCFNOBYTEALIGN     = &H00001000
CONST FCFNOMOVEWITHOWNER = &H00002000
CONST FCFICON            = &H00004000
CONST FCFACCELTABLE      = &H00008000
CONST FCFSYSMODAL        = &H00010000
CONST FCFSCREENALIGN     = &H00020000
CONST FCFMOUSEALIGN      = &H00040000

' FCFTITLEBAR | FCFSYSMENU | FCFMENU | FCFSIZEBORDER | FCFMINMAX |
'   FCFICON | FCFACCELTABLE | FCFSHELLPOSITION | FCFTASKLIST 
CONST FCFSTANDARD        = &H0000CC3F


DECLARE FUNCTION WinCreateStdWindow&(BYVAL hwndParent AS LONG,_
                                     BYVAL flStyle AS LONG,_
                                     BYVAL pflCreateFlags AS LONG,_
                                     BYVAL pszClientClass AS LONG,_
                                     BYVAL pszTitle AS LONG,_
                                     BYVAL styleClient AS LONG,_
                                     BYVAL hmod AS INTEGER,_
                                     BYVAL idResources AS INTEGER,_
                                     BYVAL phwndClient AS LONG)

' QMSG structure 

TYPE QMSG 
    hwnd AS LONG
    msg AS INTEGER
    mp1 AS LONG
    mp2 AS LONG
    time AS LONG
    ptl AS LONG
END TYPE

' Standard Window Messages 

CONST WMNULL             = &H0000
CONST WMCREATE           = &H0001
CONST WMDESTROY          = &H0002

CONST WMOTHERWINDOWDESTROYED = &H0003

CONST WMENABLE           = &H0004
CONST WMSHOW             = &H0005
CONST WMMOVE             = &H0006
CONST WMSIZE             = &H0007
CONST WMADJUSTWINDOWPOS  = &H0008

CONST WMCALCVALIDRECTS   = &H0009

CONST WMSETWINDOWPARAMS  = &H000a
CONST WMQUERYWINDOWPARAMS = &H000b
CONST WMHITTEST          = &H000c
CONST WMACTIVATE         = &H000d
CONST WMSETFOCUS         = &H000f
CONST WMSETSELECTION     = &H0010

CONST WMCOMMAND          = &H0020
CONST WMSYSCOMMAND       = &H0021
CONST WMHELP             = &H0022
CONST WMPAINT            = &H0023

CONST WMTIMER            = &H0024
CONST WMSEM1             = &H0025
CONST WMSEM2             = &H0026
CONST WMSEM3             = &H0027
CONST WMSEM4             = &H0028

CONST WMCLOSE            = &H0029
CONST WMQUIT             = &H002a
CONST WMSYSCOLORCHANGE   = &H002b
CONST WMSYSVALUECHANGED  = &H002d

' Control notification messages 

CONST WMCONTROL          = &H0030
CONST WMVSCROLL          = &H0031
CONST WMHSCROLL          = &H0032
CONST WMINITMENU         = &H0033
CONST WMMENUSELECT       = &H0034
CONST WMMENUEND          = &H0035
CONST WMDRAWITEM         = &H0036
CONST WMMEASUREITEM      = &H0037
CONST WMCONTROLPOINTER   = &H0038
CONST WMCONTROLHEAP      = &H0039
CONST WMQUERYDLGCODE     = &H003a
CONST WMINITDLG          = &H003b
CONST WMSUBSTITUTESTRING = &H003c
CONST WMMATCHMNEMONIC    = &H003d


CONST WMUSER             = &H1000


DECLARE FUNCTION WinSendMsg&(BYVAL hwnd AS LONG,_
                             BYVAL msg AS INTEGER,_
                             BYVAL mp1 AS LONG,_
                             BYVAL mp2 AS LONG)

DECLARE FUNCTION WinCreateMsgQueue&(BYVAL hab AS LONG,_
                                    BYVAL cmsg AS INTEGER)

DECLARE FUNCTION WinDestroyMsgQueue%(BYVAL hmq AS LONG)


DECLARE FUNCTION WinGetMsg%(BYVAL hab AS LONG,_
                            BYVAL pqmsg AS LONG,_
                            BYVAL hwndFilter AS LONG,_
                            BYVAL msgFilterFirst AS INTEGER,_
                            BYVAL msgFilterLast AS INTEGER)

DECLARE FUNCTION WinDispatchMsg&(BYVAL hab AS LONG,_
                                 BYVAL pqmsg AS LONG)
