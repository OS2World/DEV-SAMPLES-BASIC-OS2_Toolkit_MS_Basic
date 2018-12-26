'**************************************************************
'*
'* Include File: WinFrame.BI
'*
'* Requires:     none
'*
'* Description:  Frame Manager (much moved to PMBase.BI)
'*
'*************************************************************

TYPE FRAMECDATA
    cb AS INTEGER
    flCreateFlags  AS LONG
    hmodResources AS INTEGER
    idResources AS INTEGER
END TYPE

' Frame window styles 

'CONST FCFTITLEBAR    = &H00000001
'CONST FCFSYSMENU     = &H00000002
'CONST FCFMENU        = &H00000004
'CONST FCFSIZEBORDER  = &H00000008
'CONST FCFMINBUTTON   = &H00000010  
'CONST FCFMAXBUTTON   = &H00000020
'CONST FCFMINMAX      = &H00000030  
'CONST FCFVERTSCROLL  = &H00000040
'CONST FCFHORZSCROLL  = &H00000080
'CONST FCFDLGBORDER       = &H00000100
'CONST FCFBORDER          = &H00000200
'CONST FCFSHELLPOSITION   = &H00000400
'CONST FCFTASKLIST        = &H00000800
'CONST FCFNOBYTEALIGN     = &H00001000
'CONST FCFNOMOVEWITHOWNER = &H00002000
'CONST FCFICON            = &H00004000
'CONST FCFACCELTABLE      = &H00008000
'CONST FCFSYSMODAL        = &H00010000
'CONST FCFSCREENALIGN     = &H00020000
'CONST FCFMOUSEALIGN      = &H00040000

' FCFTITLEBAR | FCFSYSMENU | FCFMENU | FCFSIZEBORDER | FCFMINMAX |
'   FCFICON | FCFACCELTABLE | FCFSHELLPOSITION | FCFTASKLIST 
'CONST FCFSTANDARD        = &H0000CC3F


CONST FSICON             = &H00000001
CONST FSACCELTABLE       = &H00000002

CONST FSSHELLPOSITION    = &H00000004

CONST FSTASKLIST         = &H00000008
CONST FSNOBYTEALIGN      = &H00000010
CONST FSNOMOVEWITHOWNER  = &H00000020
CONST FSSYSMODAL         = &H00000040
CONST FSDLGBORDER        = &H00000080
CONST FSBORDER           = &H00000100
CONST FSSCREENALIGN      = &H00000200
CONST FSMOUSEALIGN       = &H00000400
CONST FSSIZEBORDER       = &H00000800

' FSICON | FSACCELTABLE | FSSHELLPOSITION | FSTASKLIST 
CONST FSSTANDARD         = &H0000000F


' Frame Window Flags accessed via WinSet/QueryWindowUShort(QWSFLAGS) 

CONST FFFLASHWINDOW      = &H0001  
CONST FFACTIVE           = &H0002
CONST FFFLASHHILITE      = &H0004
CONST FFOWNERHIDDEN      = &H0008
CONST FFDLGDISMISSED     = &H0010
CONST FFOWNERDISABLED    = &H0020
CONST FFSELECTED         = &H0040
CONST FFNOACTIVATESWP    = &H0080


'DECLARE FUNCTION WinCreateStdWindow&(BYVAL hwndParent AS LONG,_
'                                     BYVAL flStyle AS LONG,_
'                                     BYVAL pflCreateFlags AS LONG,_
'                                     BYVAL pszClientClass AS LONG,_
'                                     BYVAL pszTitle AS LONG,_
'                                     BYVAL styleClient AS LONG,_
'                                     BYVAL hmod AS INTEGER,_
'                                     BYVAL idResources AS INTEGER,_
'                                     BYVAL phwndClient AS LONG)





DECLARE FUNCTION WinFlashWindow%(BYVAL hwndFrame AS LONG,_
                                 BYVAL fFlash AS INTEGER)

' Frame window related messages 

CONST WMFLASHWINDOW      = &H0040
CONST WMFORMATFRAME      = &H0041
CONST WMUPDATEFRAME      = &H0042
CONST WMFOCUSCHANGE      = &H0043

CONST WMSETBORDERSIZE    = &H0044
CONST WMTRACKFRAME       = &H0045
CONST WMMINMAXFRAME      = &H0046
CONST WMSETICON          = &H0047
CONST WMQUERYICON        = &H0048
CONST WMSETACCELTABLE    = &H0049
CONST WMQUERYACCELTABLE  = &H004a
CONST WMTRANSLATEACCEL   = &H004b
CONST WMQUERYTRACKINFO   = &H004c
CONST WMQUERYBORDERSIZE  = &H004d
CONST WMNEXTMENU         = &H004e
CONST WMERASEBACKGROUND  = &H004f
CONST WMQUERYFRAMEINFO   = &H0050
CONST WMQUERYFOCUSCHAIN  = &H0051
CONST WMQUERYFRAMECTLCOUNT = &H0059


' WMQUERYFRAMEINFO constants 

CONST FIFRAME            = &H00000001
CONST FIOWNERHIDE        = &H00000002
CONST FIACTIVATEOK       = &H00000004
CONST FINOMOVEWITHOWNER  = &H00000008



' Frame class name 

CONST WCFRAME        = &Hffff0001

DECLARE FUNCTION WinCreateFrameControls%(BYVAL hwndFrame AS LONG,_
                                         BYVAL pfcdata AS LONG,_
					 BYVAL pszTitle AS LONG)

DECLARE FUNCTION WinFormatFrame%(BYVAL hwndFrame AS LONG,_
                                 BYVAL prclFrame AS LONG,_
                                 BYVAL pswp AS LONG,_
                                 BYVAL cswpMax AS INTEGER,_
                                 BYVAL prclClient AS LONG)

DECLARE FUNCTION WinCalcFrameRect%(BYVAL hwndFrame AS LONG,_
                                   BYVAL prcl AS LONG,_
                                   BYVAL fClient AS INTEGER)

DECLARE FUNCTION WinGetMinPosition%(BYVAL hwnd AS LONG,_
                                    BYVAL pswp AS LONG,_
                                    BYVAL pptl AS LONG)

DECLARE FUNCTION WinGetMaxPosition%(BYVAL hwnd AS LONG,_
                                    BYVAL pswp AS LONG)

' Frame control IDs    

CONST FIDSYSMENU         = &H8002
CONST FIDTITLEBAR        = &H8003
CONST FIDMINMAX          = &H8004
CONST FIDMENU            = &H8005
CONST FIDVERTSCROLL      = &H8006
CONST FIDHORZSCROLL      = &H8007
CONST FIDCLIENT          = &H8008

' Standard WMSYSCOMMAND command values 


CONST SCSIZE             = &H8000
CONST SCMOVE             = &H8001
CONST SCMINIMIZE         = &H8002
CONST SCMAXIMIZE         = &H8003
CONST SCCLOSE            = &H8004
CONST SCNEXT             = &H8005
CONST SCAPPMENU          = &H8006
CONST SCSYSMENU          = &H8007
CONST SCRESTORE          = &H8008
CONST SCNEXTFRAME        = &H8009
CONST SCNEXTWINDOW       = &H8010
CONST SCTASKMANAGER      = &H8011



'** Frame controls 


'* Title bar controls 

' Title bar control class name 

CONST WCTITLEBAR     = &Hffff0009

' Title bar control messages 

CONST TBMSETHILITE           = &H01e3
CONST TBMQUERYHILITE         = &H01e4
