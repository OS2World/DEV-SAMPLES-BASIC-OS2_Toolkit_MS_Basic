'**************************************************************
'*
'* Include File: WinMan2.BI
'*
'* Requires:     none
'*
'* Description:  Window Manager Subsection part 2
'*
'*************************************************************

DECLARE FUNCTION WinSetActiveWindow%(BYVAL hwndDesktop AS LONG,_
                                     BYVAL hwnd AS LONG)


' WMCREATE structure 

TYPE CREATESTRUCT 
    pPresParams AS LONG
    pCtlData AS LONG
    id AS INTEGER
    hwndInsertBehind AS LONG
    hwndOwner AS LONG
    cy AS INTEGER
    cx AS INTEGER
    y AS INTEGER
    x AS INTEGER
    flStyle AS LONG
    pszText AS LONG
    pszClass AS LONG
    hwndParent AS LONG
END TYPE

' WinQueryClassInfo() structure 

TYPE CLASSINFO
    flClassStyle AS LONG
    pfnWindowProc AS LONG
    cbWindowData AS INTEGER
END TYPE

DECLARE FUNCTION WinSubclassWindow&(BYVAL hwnd AS LONG,_
                                    BYVAL pfnwp AS LONG)

DECLARE FUNCTION WinQueryClassName%(BYVAL hwnd AS LONG,_
                                    BYVAL cchMax AS INTEGER,_
                                    BYVAL pch AS LONG)

DECLARE FUNCTION WinQueryClassInfo%(BYVAL hab AS LONG,_
                                    BYVAL pszClassName AS LONG,_
                                    BYVAL pClassInfo AS LONG)

DECLARE FUNCTION WinQueryActiveWindow&(BYVAL hwndDesktop AS LONG,_
                                       BYVAL fLock AS INTEGER)

' For multi-threaded program - not useable with BASIC
' DECLARE FUNCTION WinIsThreadActive%(BYVAL hab AS LONG)

DECLARE FUNCTION WinQuerySysModalWindow&(BYVAL hwndDesktop AS LONG,_
                                         BYVAL fLock AS INTEGER)

DECLARE FUNCTION WinLockWindow&(BYVAL hwnd AS LONG,_
                                BYVAL fLock AS INTEGER)

DECLARE FUNCTION WinRegisterWindowDestroy%(BYVAL hwnd AS LONG,_
                                           BYVAL fRegister AS INTEGER)

DECLARE FUNCTION WinSetSysModalWindow%(BYVAL hwndDesktop AS LONG,_
                                       BYVAL hwnd AS LONG)

DECLARE FUNCTION WinQueryWindowLockCount%(BYVAL hwnd AS LONG)

DECLARE FUNCTION WinQueryWindowUShort%(BYVAL hwnd AS LONG,_
                                       BYVAL index AS INTEGER)

DECLARE FUNCTION WinSetWindowUShort%(BYVAL hwnd AS LONG,_
                                     BYVAL index AS INTEGER,_
                                     BYVAL us AS INTEGER)

DECLARE FUNCTION WinQueryWindowULong&(BYVAL hwnd AS LONG,_
                                      BYVAL index AS INTEGER)

DECLARE FUNCTION WinSetWindowULong%(BYVAL hwnd AS LONG,_
                                    BYVAL index AS INTEGER,_
                                    BYVAL ul AS LONG)

DECLARE FUNCTION WinQueryWindowPtr&(BYVAL hwnd AS LONG,_
                                    BYVAL index AS INTEGER)

DECLARE FUNCTION WinSetWindowPtr%(BYVAL hwnd AS LONG,_
                                  BYVAL index AS INTEGER,_
                                  BYVAL p AS LONG)

DECLARE FUNCTION WinSetWindowBits%(BYVAL hwnd AS LONG,_
                                   BYVAL index AS INTEGER,_
                                   BYVAL flData AS LONG,_
                                   BYVAL flMask AS LONG)

' Standard WinQueryWindowUShort/ULong() indexes 

CONST QWSUSER    =0
CONST QWSID      =-1
CONST QWSMIN     =-1

CONST QWLUSER    =0
CONST QWLSTYLE   =-2
CONST QWPPFNWP   =-3
CONST QWLHMQ     =-4
CONST QWLMIN     =-4

' WCFRAME WinQueryWindowUShort/ULong() indexes 

CONST QWLHHEAP       = &H0004
CONST QWLHWNDFOCUSSAVE = &H0018

CONST QWSFLAGS       = &H0008
CONST QWSRESULT      = &H000a
CONST QWSXRESTORE    = &H000c
CONST QWSYRESTORE    = &H000e
CONST QWSCXRESTORE   = &H0010
CONST QWSCYRESTORE   = &H0012
CONST QWSXMINIMIZE   = &H0014
CONST QWSYMINIMIZE   = &H0016


' Window enumeration 


DECLARE FUNCTION WinBeginEnumWindows&(BYVAL hwnd AS LONG)

DECLARE FUNCTION WinGetNextWindow&(BYVAL henum AS LONG)

DECLARE FUNCTION WinEndEnumWindows%(BYVAL henum AS LONG)


DECLARE FUNCTION WinWindowFromPoint&(BYVAL hwnd AS LONG,_
                                     BYVAL pptl AS LONG,_
                                     BYVAL fChildren AS INTEGER,_
                                     BYVAL fLock AS INTEGER)

DECLARE FUNCTION WinMapWindowPoints%(BYVAL hwndFrom AS LONG,_
                                     BYVAL hwndTo AS LONG,_
                                     BYVAL prgptl AS LONG,_
                                     BYVAL cwpt AS INTEGER)

' More window painting stuff 

DECLARE FUNCTION WinValidateRect%(BYVAL hwnd AS LONG,_
                                  BYVAL prcl AS LONG,_
                                  BYVAL fIncludeChildren AS INTEGER)

DECLARE FUNCTION WinValidateRegion%(BYVAL hwnd AS LONG,_
                                    BYVAL hrgn AS LONG,_
                                    BYVAL fIncludeChildren AS INTEGER)

DECLARE FUNCTION WinWindowFromDC&(BYVAL hdc AS LONG)

DECLARE FUNCTION WinQueryWindowDC&(BYVAL hwnd AS LONG)

DECLARE FUNCTION WinGetScreenPS&(BYVAL hwndDesktop AS LONG)

DECLARE FUNCTION WinLockWindowUpdate%(BYVAL hwndDesktop AS LONG,_
                                      BYVAL hwndLockUpdate AS LONG)

DECLARE FUNCTION WinLockVisRegions%(BYVAL hwndDesktop AS LONG,_
                                    BYVAL fLock AS INTEGER)

DECLARE FUNCTION WinQueryUpdateRect%(BYVAL hwnd AS LONG,_
                                     BYVAL prcl AS LONG)

DECLARE FUNCTION WinQueryUpdateRegion%(BYVAL hwnd AS LONG,_
                                       BYVAL hrgn AS LONG)

DECLARE FUNCTION WinExcludeUpdateRegion%(BYVAL hps AS LONG,_
                                         BYVAL hwnd AS LONG)
