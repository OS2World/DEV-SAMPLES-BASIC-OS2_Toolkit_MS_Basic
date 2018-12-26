'**************************************************************
'*
'* Include File: WinClip.BI
'*
'* Requires:     none
'*
'* Description:  Clipboard manager
'*
'*************************************************************

' Clipboard messages 

CONST WMRENDERFMT        = &H0060
CONST WMRENDERALLFMTS    = &H0061
CONST WMDESTROYCLIPBOARD = &H0062
CONST WMPAINTCLIPBOARD   = &H0063
CONST WMSIZECLIPBOARD    = &H0064
CONST WMHSCROLLCLIPBOARD = &H0065
CONST WMVSCROLLCLIPBOARD = &H0066
CONST WMDRAWCLIPBOARD    = &H0067

' Standard Clipboard formats 

CONST CFTEXT             =1
CONST CFBITMAP           =2
CONST CFDSPTEXT          =3
CONST CFDSPBITMAP        =4
CONST CFMETAFILE         =5
CONST CFDSPMETAFILE      =6

DECLARE FUNCTION WinSetClipbrdOwner%(BYVAL hab AS LONG,_
                                     BYVAL hwnd AS LONG)

DECLARE FUNCTION WinSetClipbrdData%(BYVAL hab AS LONG,_
                                    BYVAL ulData AS LONG,_
                                    BYVAL fmt AS INTEGER,_
                                    BYVAL rgfFmtInfo AS INTEGER)

DECLARE FUNCTION WinQueryClipbrdData&(BYVAL hab AS LONG,_
                                      BYVAL fmt AS INTEGER)

DECLARE FUNCTION WinQueryClipbrdFmtInfo%(BYVAL hab AS LONG,_
                                         BYVAL fmt AS INTEGER,_
                                         BYVAL prgfFmtInfo AS LONG)

DECLARE FUNCTION WinSetClipbrdViewer%(BYVAL hab AS LONG,_
                                      BYVAL hwndNewClipViewer AS LONG)

' WinSetClipbrdData() flags 

CONST CFIOWNERFREE       = &H0001
CONST CFIOWNERDISPLAY    = &H0002
CONST CFISELECTOR        = &H0100
CONST CFIHANDLE          = &H0200


DECLARE FUNCTION WinEnumClipbrdFmts%(BYVAL hab AS LONG,_
                                     BYVAL fmt AS INTEGER)

DECLARE FUNCTION WinEmptyClipbrd%(BYVAL hab AS LONG)

DECLARE FUNCTION WinOpenClipbrd%(BYVAL hab AS LONG)

DECLARE FUNCTION WinCloseClipbrd%(BYVAL hab AS LONG)

DECLARE FUNCTION WinQueryClipbrdOwner&(BYVAL hab AS LONG,_
                                       BYVAL fLock AS INTEGER)

DECLARE FUNCTION WinQueryClipbrdViewer&(BYVAL hab AS LONG,_
                                        BYVAL fLock AS INTEGER)
