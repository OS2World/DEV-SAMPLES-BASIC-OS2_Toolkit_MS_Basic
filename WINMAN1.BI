'**************************************************************
'*
'* Include File: WinMan1.BI
'*
'* Requires:     none
'*
'* Description:  Window Manager Subsection part 1
'*               (much moved to PMBase.BI)
'*
'*************************************************************

'DECLARE FUNCTION WinRegisterClass%(BYVAL hab AS LONG,_
'                                   BYVAL pszClassName AS LONG,_
'                                   BYVAL pfnWndProc AS LONG,_
'                                   BYVAL flStyle AS LONG,_
'                                   BYVAL cbWindowData AS INTEGER)
'
'DECLARE FUNCTION WinDefWindowProc&(BYVAL hwnd AS LONG,_
'                                   BYVAL msg AS INTEGER,_
'                                   BYVAL mp1 AS LONG,_
'                                   BYVAL mp2 AS LONG)
'
'DECLARE FUNCTION WinDestroyWindow%(BYVAL hwnd AS LONG)
'

DECLARE FUNCTION WinShowWindow%(BYVAL hwnd AS LONG,_
                                BYVAL fShow AS INTEGER)

DECLARE FUNCTION WinQueryWindowRect%(BYVAL hwnd AS LONG,_
                                     BYVAL prclDest AS LONG)

DECLARE FUNCTION WinGetPS&(BYVAL hwnd AS LONG)

DECLARE FUNCTION WinReleasePS%(BYVAL hps AS LONG)

'DECLARE FUNCTION WinEndPaint%(BYVAL hps AS LONG)

DECLARE FUNCTION WinGetClipPS&(BYVAL hwnd AS LONG,_
                               BYVAL hwndClip AS LONG,_
                               BYVAL fs AS INTEGER)

'DECLARE FUNCTION WinBeginPaint&(BYVAL hwnd AS LONG,_
'                                BYVAL hps AS LONG,_
'                                BYVAL prclPaint AS LONG)

DECLARE FUNCTION WinOpenWindowDC&(BYVAL hwnd AS LONG)

DECLARE FUNCTION WinScrollWindow%(BYVAL hwnd AS LONG,_
                                  BYVAL dx AS INTEGER,_
                                  BYVAL dy AS INTEGER,_
                                  BYVAL prclScroll AS LONG,_
                                  BYVAL prclClip AS LONG,_
                                  BYVAL hrgnUpdate AS LONG,_
                                  BYVAL prclUpdate AS LONG,_
                                  BYVAL rgfsw AS INTEGER)

' WinGetClipPS() flags 

CONST PSFLOCKWINDOWUPDATE    = &H0001
CONST PSFCLIPUPWARDS         = &H0002
CONST PSFCLIPDOWNWARDS       = &H0004
CONST PSFCLIPSIBLINGS        = &H0008
CONST PSFCLIPCHILDREN        = &H0010
CONST PSFPARENTCLIP          = &H0020


' WinScrollWindow() flags 

CONST SWSCROLLCHILDREN   = &H0001
CONST SWINVALIDATERGN    = &H0002

'DECLARE FUNCTION WinFillRect%(BYVAL hps AS LONG,_
'                              BYVAL prcl AS LONG,_
'                              BYVAL lColor AS LONG)

' WinInitialize/WinTerminate Interface declarations 

TYPE QVERSDATA
    environment AS INTEGER
    version AS INTEGER
END TYPE

CONST QVOS2          = &H0000
CONST QVCMS          = &H0001
CONST QVTSO          = &H0002
CONST QVTSOBATCH     = &H0003


DECLARE FUNCTION WinQueryVersion&(BYVAL hab AS LONG)

'DECLARE FUNCTION WinInitialize&(BYVAL ushort AS INTEGER)

'DECLARE FUNCTION WinTerminate%(BYVAL hab AS LONG)


'*****************  End of Window Manager COMMON section *****************


DECLARE FUNCTION WinCreateWindow&(BYVAL hwndParent AS LONG,_
                                  BYVAL pszClass AS LONG,_
                                  BYVAL pszName AS LONG,_
                                  BYVAL flStyle AS LONG,_
                                  BYVAL x AS INTEGER,_
                                  BYVAL y AS INTEGER,_
                                  BYVAL cx AS INTEGER,_
                                  BYVAL cy AS INTEGER,_
                                  BYVAL hwndOwner AS LONG,_
                                  BYVAL hwndInsertBehind AS LONG,_
                                  BYVAL id AS INTEGER,_
                                  BYVAL pCtlData AS LONG,_
                                  BYVAL pPresParams AS LONG)

DECLARE FUNCTION WinEnableWindow%(BYVAL hwnd AS LONG,_
                                  BYVAL fEnable AS INTEGER)

DECLARE FUNCTION WinIsWindowEnabled%(BYVAL hwnd AS LONG)

DECLARE FUNCTION WinEnableWindowUpdate%(BYVAL hwnd AS LONG,_
                                        BYVAL fEnable AS INTEGER)

DECLARE FUNCTION WinIsWindowVisible%(BYVAL hwnd AS LONG)
DECLARE FUNCTION WinQueryWindowText%(BYVAL hwnd AS LONG,_
                                     BYVAL cchBufferMax AS INTEGER,_
                                     BYVAL pchBuffer AS LONG)

DECLARE FUNCTION WinSetWindowText%(BYVAL hwnd AS LONG,_
                                   BYVAL pszText AS LONG)
DECLARE FUNCTION WinQueryWindowTextLength%(BYVAL hwnd AS LONG)
DECLARE FUNCTION WinWindowFromID&(BYVAL hwndParent AS LONG,_
                                  BYVAL id AS INTEGER)

DECLARE FUNCTION WinIsWindow%(BYVAL hab AS LONG,_
                              BYVAL hwnd AS LONG)

DECLARE FUNCTION WinQueryWindow&(BYVAL hwnd AS LONG,_
                                 BYVAL cmd AS INTEGER,_
                                 BYVAL fLock AS INTEGER)

DECLARE FUNCTION WinMultWindowFromIDs%(BYVAL hwndParent AS LONG,_
                                       BYVAL prghwnd AS LONG,_
                                       BYVAL idFirst AS INTEGER,_
                                       BYVAL idLast AS INTEGER)

' WinQueryWindow() codes 

CONST QWNEXT     =0
CONST QWPREV     =1
CONST QWTOP      =2
CONST QWBOTTOM   =3
CONST QWOWNER    =4
CONST QWPARENT   =5
CONST QWNEXTTOP  =6
CONST QWPREVTOP  =7
CONST QWFRAMEOWNER  =8


DECLARE FUNCTION WinSetParent%(BYVAL hwnd AS LONG,_
                               BYVAL hwndNewParent AS LONG,_
                               BYVAL fRedraw AS INTEGER)

DECLARE FUNCTION WinIsChild%(BYVAL hwnd AS LONG,_
                             BYVAL hwndParent AS LONG)

DECLARE FUNCTION WinSetOwner%(BYVAL hwnd AS LONG,_
                              BYVAL hwndNewOwner AS LONG)

DECLARE FUNCTION WinQueryWindowProcess%(BYVAL hwnd AS LONG,_
                                        BYVAL ppid AS LONG,_
                                        BYVAL ptid AS LONG)

DECLARE FUNCTION WinQueryObjectWindow&(BYVAL hwndDesktop AS LONG)

DECLARE FUNCTION WinQueryDesktopWindow&(BYVAL hab AS LONG,_
                                        BYVAL hdc AS LONG)

'** Window positioning functions 

' WinSetMultWindowPos() structure 

TYPE SWP 
    fs AS INTEGER
    cy AS INTEGER
    cx AS INTEGER
    y AS INTEGER
    x AS INTEGER
    hwndInsertBehind AS LONG
    hwnd AS LONG
END TYPE

DECLARE FUNCTION WinSetWindowPos%(BYVAL hwnd AS LONG,_
                                  BYVAL hwndInsertBehind AS LONG,_
                                  BYVAL x AS INTEGER,_
                                  BYVAL y AS INTEGER,_
                                  BYVAL cx AS INTEGER,_
                                  BYVAL cy AS INTEGER,_
                                  BYVAL fs AS INTEGER)

DECLARE FUNCTION WinQueryWindowPos%(BYVAL hwnd AS LONG,_
                                    BYVAL pswp AS LONG)

DECLARE FUNCTION WinSetMultWindowPos%(BYVAL hab AS LONG,_
                                      BYVAL pswp AS LONG,_
                                      BYVAL cswp AS INTEGER)

' WinSetWindowPos() flags 

CONST SWPSIZE        = &H0001
CONST SWPMOVE        = &H0002
CONST SWPZORDER      = &H0004
CONST SWPSHOW        = &H0008
CONST SWPHIDE        = &H0010
CONST SWPNOREDRAW    = &H0020
CONST SWPNOADJUST    = &H0040
CONST SWPACTIVATE    = &H0080
CONST SWPDEACTIVATE  = &H0100
CONST SWPEXTSTATECHANGE  = &H0200
CONST SWPMINIMIZE    = &H0400
CONST SWPMAXIMIZE    = &H0800
CONST SWPRESTORE     = &H1000
CONST SWPFOCUSACTIVATE   = &H2000
CONST SWPFOCUSDEACTIVATE = &H4000

' Window painting 

DECLARE FUNCTION WinUpdateWindow%(BYVAL hwnd AS LONG)

DECLARE FUNCTION WinInvalidateRect%(BYVAL hwnd AS LONG,_
                                    BYVAL pwrc AS LONG,_
                                    BYVAL fIncludeChildren AS INTEGER)

DECLARE FUNCTION WinInvalidateRegion%(BYVAL hwnd AS LONG,_
                                      BYVAL hrgn AS LONG,_
                                      BYVAL fIncludeChildren AS INTEGER)


' Drawing helpers 

DECLARE FUNCTION WinInvertRect%(BYVAL hps AS LONG,_
                                BYVAL prcl AS LONG)

DECLARE FUNCTION WinDrawBitmap%(BYVAL hpsDst AS LONG,_
                                BYVAL hbm AS LONG,_
                                BYVAL pwrcSrc AS LONG,_
                                BYVAL pptlDst AS LONG,_
                                BYVAL clrFore AS LONG,_
                                BYVAL clrBack AS LONG,_
                                BYVAL fs AS INTEGER)

' WinDrawBitmap() flags 

CONST DBMNORMAL      = &H0000
CONST DBMINVERT      = &H0001
CONST DBMHALFTONE    = &H0002
CONST DBMSTRETCH     = &H0004
CONST DBMIMAGEATTRS	= &H0008


DECLARE FUNCTION WinDrawText%(BYVAL hps AS LONG,_
                              BYVAL cchText AS INTEGER,_
                              BYVAL lpchText AS LONG,_
                              BYVAL prcl AS LONG,_
                              BYVAL clrFore AS LONG,_
                              BYVAL clrBack AS LONG,_
                              BYVAL rgfCmd AS INTEGER)
'
' * WinDrawText() codes:
' * From DTLEFT to DTEXTERNALLEADING, the codes are designed to be OR'ed with
' * SSTEXT to create variations of the basic text static item.
' 
CONST DTLEFT             = &H0000
CONST DTEXTERNALLEADING  = &H0080
CONST DTCENTER           = &H0100
CONST DTRIGHT            = &H0200
CONST DTTOP              = &H0000
CONST DTVCENTER          = &H0400
CONST DTBOTTOM           = &H0800
CONST DTHALFTONE         = &H1000
CONST DTMNEMONIC         = &H2000
CONST DTWORDBREAK        = &H4000
CONST DTERASERECT        = &H8000
CONST DTQUERYEXTENT      = &H0002
CONST DTTEXTATTRS	    = &H0040


DECLARE FUNCTION WinDrawBorder%(BYVAL hps AS LONG,_
                                BYVAL prcl AS LONG,_
                                BYVAL cx AS INTEGER,_
                                BYVAL cy AS INTEGER,_
                                BYVAL clrFore AS LONG,_
                                BYVAL clrBack AS LONG,_
                                BYVAL rgfCmd AS INTEGER)

' WinDrawBorder() flags 

CONST DBPATCOPY          = &H0000
CONST DBPATINVERT        = &H0001
CONST DBDESTINVERT       = &H0002
CONST DBAREAMIXMODE      = &H0003

CONST DBROP              = &H0007
CONST DBINTERIOR         = &H0008
CONST DBAREAATTRS	    = &H0010
CONST DBSTANDARD         = &H0100
CONST DBDLGBORDER        = &H0200



'* Resource loading functions 

DECLARE FUNCTION WinLoadString%(BYVAL hab AS LONG,_
                                BYVAL hmod AS INTEGER,_
                                BYVAL id AS INTEGER,_
                                BYVAL cchMax AS INTEGER,_
                                BYVAL pchBuffer AS LONG)

DECLARE FUNCTION WinLoadMessage%(BYVAL hab AS LONG,_
                                 BYVAL hmod AS INTEGER,_
                                 BYVAL id AS INTEGER,_
                                 BYVAL cchMax AS INTEGER,_
                                 BYVAL pchBuffer AS LONG)
