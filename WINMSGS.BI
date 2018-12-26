'**************************************************************
'*
'* Include File: WinMsgs.BI
'*
'* Requires:     none
'*
'* Description:  Message Control Manager
'*               Much moved to PMBase.BI
'*
'**************************************************************

' QMSG structure

'TYPE QMSG 
'    hwnd AS LONG
'    msg AS INTEGER
'    mp1 AS LONG
'    mp2 AS LONG
'    time AS LONG
'    ptl AS LONG
'END TYPE



' Standard Window Messages 

'CONST WMNULL             = &H0000
'CONST WMCREATE           = &H0001
'CONST WMDESTROY          = &H0002
'
'CONST WMOTHERWINDOWDESTROYED = &H0003
'
'CONST WMENABLE           = &H0004
'CONST WMSHOW             = &H0005
'CONST WMMOVE             = &H0006
'CONST WMSIZE             = &H0007
'CONST WMADJUSTWINDOWPOS  = &H0008
'
'CONST WMCALCVALIDRECTS   = &H0009
'
'CONST WMSETWINDOWPARAMS  = &H000a
'CONST WMQUERYWINDOWPARAMS = &H000b
'CONST WMHITTEST          = &H000c
'CONST WMACTIVATE         = &H000d
'CONST WMSETFOCUS         = &H000f
'CONST WMSETSELECTION     = &H0010
'
'CONST WMCOMMAND          = &H0020
'CONST WMSYSCOMMAND       = &H0021
'CONST WMHELP             = &H0022
'CONST WMPAINT            = &H0023
'
'CONST WMTIMER            = &H0024
'CONST WMSEM1             = &H0025
'CONST WMSEM2             = &H0026
'CONST WMSEM3             = &H0027
'CONST WMSEM4             = &H0028
'
'CONST WMCLOSE            = &H0029
'CONST WMQUIT             = &H002a
'CONST WMSYSCOLORCHANGE   = &H002b
'CONST WMSYSVALUECHANGED  = &H002d
'
'' Control notification messages 
'
'CONST WMCONTROL          = &H0030
'CONST WMVSCROLL          = &H0031
'CONST WMHSCROLL          = &H0032
'CONST WMINITMENU         = &H0033
'CONST WMMENUSELECT       = &H0034
'CONST WMMENUEND          = &H0035
'CONST WMDRAWITEM         = &H0036
'CONST WMMEASUREITEM      = &H0037
'CONST WMCONTROLPOINTER   = &H0038
'CONST WMCONTROLHEAP      = &H0039
'CONST WMQUERYDLGCODE     = &H003a
'CONST WMINITDLG          = &H003b
'CONST WMSUBSTITUTESTRING = &H003c
'CONST WMMATCHMNEMONIC    = &H003d
'
'
'CONST WMUSER             = &H1000

' WMCOMMAND msg source codes 

CONST CMDSRCPUSHBUTTON   =1
CONST CMDSRCMENU         =2
CONST CMDSRCACCELERATOR  =3
CONST CMDSRCOTHER        =0

'
' * The following structure and macro are used to access the
' * WMCOMMAND, WMHELP, and WMSYSCOMMAND message parameters:
' 
TYPE COMMANDMSG 
    source AS INTEGER          ' mp2 
    fMouse AS INTEGER
    cmd AS INTEGER             ' mp1 
    unused AS INTEGER
END TYPE



'
' * The following structure is used by the WinQueryQueueInfo() routine
' 
TYPE MQINFO
    cb AS INTEGER
    pid AS LONG
    tid AS INTEGER
    cmsgs AS INTEGER
    pReserved AS LONG
END TYPE


'DECLARE FUNCTION WinSendMsg&(BYVAL hwnd AS LONG,_
'                             BYVAL msg AS INTEGER,_
'                             BYVAL mp1 AS LONG,_
'                             BYVAL mp2 AS LONG)
'
'DECLARE FUNCTION WinCreateMsgQueue&(BYVAL hab AS LONG,_
'                                    BYVAL cmsg AS INTEGER)
'
'DECLARE FUNCTION WinDestroyMsgQueue%(BYVAL hmq AS LONG)

DECLARE FUNCTION WinQueryQueueInfo%(BYVAL hmq AS LONG,_
                                    BYVAL pmqi AS LONG,_
                                    BYVAL cbCopy AS INTEGER)

DECLARE FUNCTION WinCancelShutdown%(BYVAL hmq AS LONG,_
                                    BYVAL fCancelAlways AS INTEGER)

'DECLARE FUNCTION WinGetMsg%(BYVAL hab AS LONG,_
'                            BYVAL pqmsg AS LONG,_
'                            BYVAL hwndFilter AS LONG,_
'                            BYVAL msgFilterFirst AS INTEGER,_
'                            BYVAL msgFilterLast AS INTEGER)

DECLARE FUNCTION WinPeekMsg%(BYVAL hab AS LONG,_
                             BYVAL pqmsg AS LONG,_
                             BYVAL hwndFilter AS LONG,_
			     BYVAL msgFilterFirst AS INTEGER,_
			     BYVAL msgFilterLast AS INTEGER,_
			     BYVAL fs AS INTEGER)

'DECLARE FUNCTION WinDispatchMsg&(BYVAL hab AS LONG,_
'                                 BYVAL pqmsg AS LONG)

DECLARE FUNCTION WinPostMsg%(BYVAL hwnd AS LONG,_
                             BYVAL msg AS INTEGER,_
                             BYVAL mp1 AS LONG,_
                             BYVAL mp2 AS LONG)

' WinPeekMsg() constants 

CONST PMREMOVE       = &H0001
CONST PMNOREMOVE     = &H0000




' WMCALCVALIDRECTS return flags 

CONST CVRALIGNLEFT       = &H0001
CONST CVRALIGNBOTTOM     = &H0002
CONST CVRALIGNRIGHT      = &H0004
CONST CVRALIGNTOP        = &H0008
CONST CVRREDRAW          = &H0010


' WMHITTEST return codes 

CONST HTNORMAL       =0
CONST HTTRANSPARENT  =-1
CONST HTDISCARD      =-2
CONST HTERROR        =-3

' WMSET/QUERYWINDOWPARAMS structures and flags 

TYPE WNDPARAMS 
    fsStatus AS INTEGER
    cchText AS INTEGER
    pszText AS LONG
    cbPresParams AS INTEGER
    pPresParams AS LONG
    cbCtlData AS INTEGER
    pCtlData AS LONG
END TYPE 


' Flags used by WMSET/QUERYWINDOWPARAMS 

CONST WPMTEXT        = &H0001
CONST WPMCTLDATA     = &H0002
CONST WPMPRESPARAMS  = &H0004
CONST WPMCCHTEXT     = &H0008
CONST WPMCBCTLDATA   = &H0010
CONST WPMCBPRESPARAMS = &H0020


DECLARE FUNCTION WinInSendMsg%(BYVAL hab AS LONG)


DECLARE FUNCTION WinBroadcastMsg%(BYVAL hwnd AS LONG,_
                                  BYVAL msg AS INTEGER,_
                                  BYVAL mp1 AS LONG,_
                                  BYVAL mp2 AS LONG,_
                                  BYVAL rgf AS INTEGER)

' WinBroadcastMsg codes 

CONST BMSGPOST           = &H0000
CONST BMSGSEND           = &H0001
CONST BMSGPOSTQUEUE      = &H0002
CONST BMSGDESCENDANTS    = &H0004
CONST BMSGFRAMEONLY      = &H0008



DECLARE FUNCTION WinWaitMsg%(BYVAL hab AS LONG,_
                             BYVAL msgFirst AS INTEGER,_
                             BYVAL msgLast AS INTEGER)

DECLARE FUNCTION WinQueryQueueStatus&(BYVAL hwndDesktop AS LONG)

' WinQueryQueueStatus() constants 

CONST QSKEY          = &H0001
CONST QSMOUSEBUTTON  = &H0002
CONST QSMOUSEMOVE    = &H0004
CONST QSMOUSE        = &H0006      ' QSMOUSEMOVE|QSMOUSEBUTTON 
CONST QSTIMER        = &H0008
CONST QSPAINT        = &H0010
CONST QSPOSTMSG      = &H0020
CONST QSSEM1         = &H0040
CONST QSSEM2         = &H0080
CONST QSSEM3         = &H0100
CONST QSSEM4         = &H0200
CONST QSSENDMSG      = &H0400


DECLARE FUNCTION WinQueryMsgPos%(BYVAL hab AS LONG,_
                                 BYVAL pptl AS LONG)

DECLARE FUNCTION WinQueryMsgTime&(BYVAL hab AS LONG)

DECLARE FUNCTION WinMsgSemWait%(BYVAL hsem AS LONG,_
                                BYVAL dtTimeout AS LONG)

DECLARE FUNCTION WinMsgMuxSemWait%(BYVAL pisemCleared AS LONG,_
                                   BYVAL pmxsl AS LONG,_ 
                                   BYVAL dtTimeout AS LONG)

DECLARE FUNCTION WinPostQueueMsg%(BYVAL hmq AS LONG,_
                                  BYVAL msg AS INTEGER,_
                                  BYVAL mp1 AS LONG,_
                                  BYVAL mp2 AS LONG)
