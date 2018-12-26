'**************************************************************
'*
'* Include File: WinDialg
'*
'* Requires:     none
'*
'* Description:  Dialog Manager
'*
'*************************************************************

'*** Dialog Manager COMMON subsection 

DECLARE FUNCTION WinLoadDlg&(BYVAL hwndParent AS LONG,_
                             BYVAL hwndOwner AS LONG,_
                             BYVAL pfnDlgProc AS LONG,_
                             BYVAL hmod AS INTEGER,_
                             BYVAL idDlg AS INTEGER,_
                             BYVAL pCreateParams AS LONG)

DECLARE FUNCTION WinDlgBox%(BYVAL hwndParent AS LONG,_
                            BYVAL hwndOwner AS LONG,_
                            BYVAL pfnDlgProc AS LONG,_
                            BYVAL hmod AS INTEGER,_
                            BYVAL idDlg AS INTEGER,_
                            BYVAL pCreateParams AS LONG)

DECLARE FUNCTION WinDismissDlg%(BYVAL hwndDlg AS LONG,_
                                BYVAL usResult AS INTEGER)

DECLARE FUNCTION WinQueryDlgItemShort%(BYVAL hwndDlg AS LONG,_
                                       BYVAL idItem AS INTEGER,_
                                       BYVAL pResult AS LONG,_
                                       BYVAL fSigned AS INTEGER)

DECLARE FUNCTION WinSetDlgItemShort%(BYVAL hwndDlg AS LONG,_
                                     BYVAL idItem AS INTEGER,_
                                     BYVAL usValue AS INTEGER,_
                                     BYVAL fSigned AS INTEGER)

DECLARE FUNCTION WinSetDlgItemText%(BYVAL hwndDlg AS LONG,_
                                    BYVAL idItem AS INTEGER,_
                                    BYVAL pszText AS LONG)

DECLARE FUNCTION WinQueryDlgItemText%(BYVAL hwndDlg AS LONG,_
                                      BYVAL idItem AS INTEGER,_
                                      BYVAL cchBufferMax AS INTEGER,_
                                      BYVAL pchBuffer AS LONG)

DECLARE FUNCTION WinQueryDlgItemTextLength%(BYVAL hwndDlg AS LONG,_
                                            BYVAL idItem AS INTEGER)


DECLARE FUNCTION WinDefDlgProc&(BYVAL hwndDlg AS LONG,_
                                BYVAL msg AS INTEGER,_
                                BYVAL mp1 AS LONG,_
                                BYVAL mp2 AS LONG)

' Special item IDs 

CONST DIDOK      =1
CONST DIDCANCEL  =2
CONST DIDERROR   = &Hffff

DECLARE FUNCTION WinAlarm%(BYVAL hwndDesktop AS LONG,_
                           BYVAL rgfType AS INTEGER)

' WinAlarm Codes 

CONST WAWARNING              =0
CONST WANOTE                 =1
CONST WAERROR                =2

CONST WACWINALARMS           =3

DECLARE FUNCTION WinMessageBox%(BYVAL hwndParent AS LONG,_
                                BYVAL hwndOwner AS LONG,_
                                BYVAL pszText AS LONG,_
                                BYVAL pszCaption AS LONG,_
                                BYVAL idWindow AS INTEGER,_
                                BYVAL flStyle AS INTEGER)

' Message box types 

CONST MBOK                   = &H0000
CONST MBOKCANCEL             = &H0001
CONST MBRETRYCANCEL          = &H0002
CONST MBABORTRETRYIGNORE     = &H0003
CONST MBYESNO                = &H0004
CONST MBYESNOCANCEL          = &H0005
CONST MBCANCEL               = &H0006
CONST MBENTER                = &H0007
CONST MBENTERCANCEL          = &H0008

CONST MBNOICON               = &H0000
CONST MBCUANOTIFICATION      = &H0000
CONST MBICONQUESTION         = &H0010
CONST MBICONEXCLAMATION      = &H0020
CONST MBCUAWARNING           = &H0020
CONST MBICONASTERISK         = &H0030
CONST MBICONHAND             = &H0040
CONST MBCUACRITICAL          = &H0040

CONST MBDEFBUTTON1           = &H0000
CONST MBDEFBUTTON2           = &H0100
CONST MBDEFBUTTON3           = &H0200

CONST MBAPPLMODAL            = &H0000
CONST MBSYSTEMMODAL          = &H1000
CONST MBHELP                 = &H2000
CONST MBMOVEABLE             = &H4000


' Message box return codes 

CONST MBIDOK                 =1
CONST MBIDCANCEL             =2
CONST MBIDABORT              =3
CONST MBIDRETRY              =4
CONST MBIDIGNORE             =5
CONST MBIDYES                =6
CONST MBIDNO                 =7
CONST MBIDHELP               =8
CONST MBIDENTER              =9
CONST MBIDERROR              = &Hffff

' Dialog codes: returned by WMQUERYDLGCODE msg     

CONST DLGCENTRYFIELD     = &H0001    ' Entry field item understands EMSETSEL) 
CONST DLGCBUTTON         = &H0002    ' Button item 
CONST DLGCRADIOBUTTON    = &H0004    ' Radio button 
CONST DLGCSTATIC         = &H0008    ' Static item 
CONST DLGCDEFAULT        = &H0010    ' Default push button 
CONST DLGCPUSHBUTTON     = &H0020    ' Normal (Non-default) push button 
CONST DLGCCHECKBOX       = &H0040    ' Check box button control 
CONST DLGCSCROLLBAR      = &H0080    ' Scroll bar 
CONST DLGCMENU           = &H0100    ' Menu 
CONST DLGCTABONCLICK     = &H0200


DECLARE FUNCTION WinProcessDlg%(BYVAL hwndDlg AS LONG)

DECLARE FUNCTION WinSendDlgItemMsg&(BYVAL hwndDlg AS LONG,_
                                    BYVAL idItem AS INTEGER,_
                                    BYVAL msg AS INTEGER,_
                                    BYVAL mp1 AS LONG,_
                                    BYVAL mp2 AS LONG)

DECLARE FUNCTION WinMapDlgPoints%(BYVAL hwndDlg AS LONG,_
                                  BYVAL prgwptl AS LONG,_
                                  BYVAL cwpt AS INTEGER,_
                                  BYVAL fCalcWindowCoords AS INTEGER)


DECLARE FUNCTION WinEnumDlgItem&(BYVAL hwndDlg AS LONG,_
                                 BYVAL hwnd AS LONG,_
                                 BYVAL code AS INTEGER,_
                                 BYVAL fLock AS INTEGER)

DECLARE FUNCTION WinSubstituteStrings%(BYVAL hwnd AS LONG,_
                                       BYVAL pszSrc AS LONG,_
                                       BYVAL cchDstMax AS INTEGER,_
                                      BYVAL pszDst AS LONG)

' WinEnumDlgItem() constants 

CONST EDIFIRSTTABITEM        =0
CONST EDILASTTABITEM         =1
CONST EDINEXTTABITEM         =2
CONST EDIPREVTABITEM         =3
CONST EDIFIRSTGROUPITEM      =4
CONST EDILASTGROUPITEM       =5
CONST EDINEXTGROUPITEM       =6
CONST EDIPREVGROUPITEM       =7

'** Dialog template definitions 

' Variable-sized dialog template items: 

TYPE DLGITEM 
    fsItemStatus AS INTEGER
    cChildren AS INTEGER
    cchClassName AS INTEGER
    offClassName AS INTEGER
    cchText AS INTEGER
    offText AS INTEGER
    flStyle AS LONG
    x AS INTEGER
    y AS INTEGER
    cx AS INTEGER
    cy AS INTEGER
    id AS INTEGER
    offPresParam AS INTEGER
    offCtlData AS INTEGER
END TYPE

' Dialog Template structure 

TYPE DLGTEMPLATE 
    cbTemplate AS INTEGER
    Atype AS INTEGER
    codepage AS INTEGER
    offadlgti AS INTEGER          ' Is always 12 for pm 1.1 
    fsTemplateStatus AS INTEGER
    iItemFocus AS INTEGER
    coffPresParams AS INTEGER	  ' Reserved to be 0 for pm 1.1
    adlgti AS DLGITEM		  ' array; in C:DLGITEM adlgti[1]
END TYPE

DECLARE FUNCTION WinCreateDlg&(BYVAL hwndParent AS LONG,_
                               BYVAL hwndOwner AS LONG,_
                               BYVAL pfnDlgProc AS LONG,_
                               BYVAL pdlgt AS LONG,_
                               BYVAL pCreateParams AS LONG)
