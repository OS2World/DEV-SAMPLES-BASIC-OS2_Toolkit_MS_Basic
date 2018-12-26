TYPE SIZEL
    cx AS LONG
    cy AS LONG
END TYPE

TYPE SWP
    fs AS INTEGER
    cy AS INTEGER
    cx AS INTEGER
    y AS INTEGER
    x AS INTEGER
    hwndInsertBehind AS LONG
    hwnd AS LONG
END TYPE

DECLARE FUNCTION WinGetLastError&(BYVAL hab AS LONG)
DECLARE FUNCTION DosBeep% (BYVAL frequency AS INTEGER,_
                           BYVAL duration  AS INTEGER)
DECLARE FUNCTION WinSetWindowPos%(BYVAL hwnd AS LONG,_
                                  BYVAL hwndInsertBehind AS LONG,_
                                  BYVAL x AS INTEGER,_
                                  BYVAL y AS INTEGER,_
                                  BYVAL cx AS INTEGER,_
                                  BYVAL cy AS INTEGER,_
                                  BYVAL fs AS INTEGER)
DECLARE FUNCTION WinQueryWindowPos%(BYVAL hwnd AS LONG,_
                                    BYVAL pswp AS LONG)
DECLARE FUNCTION WinShowWindow%(BYVAL hwnd AS LONG,_
                                BYVAL fShow AS INTEGER)
DECLARE FUNCTION WinEnableWindow%(BYVAL hwnd AS LONG,_
                                  BYVAL fEnable AS INTEGER)
DECLARE FUNCTION WinIsWindowEnabled%(BYVAL hwnd AS LONG)
DECLARE FUNCTION WinQueryWindowRect%(BYVAL hwnd AS LONG,_
                                     BYVAL prclDest AS LONG)
DECLARE FUNCTION WinQueryWindow&(BYVAL hwnd AS LONG,_
                                 BYVAL cmd AS INTEGER,_
                                 BYVAL fLock AS INTEGER)
DECLARE FUNCTION WinWindowFromID&(BYVAL hwndParent AS LONG,_
                                  BYVAL id AS INTEGER)
DECLARE FUNCTION WinGetPS&(BYVAL hwnd AS LONG)
DECLARE FUNCTION WinReleasePS%(BYVAL hps AS LONG)
DECLARE FUNCTION WinInvalidateRect%(BYVAL hwnd AS LONG,_
                                    BYVAL pwrc AS LONG,_
                                    BYVAL fIncludeChildren AS INTEGER)
DECLARE FUNCTION WinDrawBitmap%(BYVAL hpsDst AS LONG,_
                                BYVAL hbm AS LONG,_
                                BYVAL pwrcSrc AS LONG,_
                                BYVAL pptlDst AS LONG,_
                                BYVAL clrFore AS LONG,_
                                BYVAL clrBack AS LONG,_
                                BYVAL fs AS INTEGER)
DECLARE FUNCTION WinDlgBox%(BYVAL hwndParent AS LONG,_
                            BYVAL hwndOwner AS LONG,_
                            BYVAL pfnDlgProc AS LONG,_
                            BYVAL hmod AS INTEGER,_
                            BYVAL idDlg AS INTEGER,_
                            BYVAL pCreateParams AS LONG)
DECLARE FUNCTION WinDismissDlg%(BYVAL hwndDlg AS LONG,_
                                BYVAL usResult AS INTEGER)
DECLARE FUNCTION WinDefDlgProc&(BYVAL hwndDlg AS LONG,_
                                BYVAL msg AS INTEGER,_
                                BYVAL mp1 AS LONG,_
                                BYVAL mp2 AS LONG)
DECLARE FUNCTION WinSetPointer%(BYVAL hwndDesktop AS LONG,_
                                BYVAL hptrNew AS LONG)
DECLARE FUNCTION WinQuerySysPointer&(BYVAL hwndDesktop AS LONG,_
                                     BYVAL iptr AS INTEGER,_
                                     BYVAL fLoad AS INTEGER)
DECLARE FUNCTION WinSetFocus%(BYVAL hwndDesktop AS LONG,_
                              BYVAL hwndSetFocus AS LONG)
DECLARE FUNCTION WinLoadPointer&(BYVAL hwndDesktop AS LONG,_
                                 BYVAL hmod AS INTEGER,_
                                 BYVAL idres AS INTEGER)
DECLARE FUNCTION WinSetPointer%(BYVAL hwndDesktop AS LONG,_
                                BYVAL hptrNew AS LONG)
DECLARE FUNCTION WinQuerySysPointer&(BYVAL hwndDesktop AS LONG,_
                                     BYVAL iptr AS INTEGER,_
                                     BYVAL fLoad AS INTEGER)
DECLARE FUNCTION WinQuerySysValue&(BYVAL hwndDesktop AS LONG,_
                                   BYVAL iSysValue AS INTEGER)
DECLARE FUNCTION WinPostMsg%(BYVAL hwnd AS LONG,_
                             BYVAL msg AS INTEGER,_
                             BYVAL mp1 AS LONG,_
                             BYVAL mp2 AS LONG)
DECLARE FUNCTION WinMessageBox%(BYVAL hwndParent AS LONG,_
                                BYVAL hwndOwner AS LONG,_
                                BYVAL pszText AS LONG,_
                                BYVAL pszCaption AS LONG,_
                                BYVAL idWindow AS INTEGER,_
                                BYVAL flStyle AS INTEGER)
DECLARE FUNCTION WinGetScreenPS&(BYVAL hwndDesktop AS LONG)
DECLARE FUNCTION WinCalcFrameRect%(BYVAL hwndFrame AS LONG,_
                                   BYVAL prcl AS LONG,_
                                   BYVAL fClient AS INTEGER)
DECLARE FUNCTION WinQueryDlgItemShort%(BYVAL hwndDlg AS LONG,_
                                       BYVAL idItem AS INTEGER,_
                                       BYVAL pResult AS LONG,_
                                       BYVAL fSigned AS INTEGER)

DECLARE FUNCTION WinSetDlgItemShort%(BYVAL hwndDlg AS LONG,_
                                     BYVAL idItem AS INTEGER,_
                                     BYVAL usValue AS INTEGER,_
                                     BYVAL fSigned AS INTEGER)
DECLARE FUNCTION WinSendDlgItemMsg&(BYVAL hwndDlg AS LONG,_
                                    BYVAL idItem AS INTEGER,_
                                    BYVAL msg AS INTEGER,_
                                    BYVAL mp1 AS LONG,_
                                    BYVAL mp2 AS LONG)
DECLARE FUNCTION WinSetClipbrdData%(BYVAL hab AS LONG,_
                                    BYVAL ulData AS LONG,_
                                    BYVAL fmt AS INTEGER,_
                                    BYVAL rgfFmtInfo AS INTEGER)
DECLARE FUNCTION WinQueryClipbrdData&(BYVAL hab AS LONG,_
                                      BYVAL fmt AS INTEGER)
DECLARE FUNCTION WinEmptyClipbrd%(BYVAL hab AS LONG)
DECLARE FUNCTION WinOpenClipbrd%(BYVAL hab AS LONG)
DECLARE FUNCTION WinCloseClipbrd%(BYVAL hab AS LONG)
DECLARE FUNCTION GpiErase%( BYVAL HPS AS LONG )
DECLARE FUNCTION GpiDestroyPS%( BYVAL HPS AS LONG )
DECLARE FUNCTION GpiCreatePS&( BYVAL HAB AS LONG,_
                               BYVAL HDC AS LONG,_
                               BYVAL PSIZEL AS LONG,_
                               BYVAL ULONG AS LONG )
DECLARE FUNCTION DevCloseDC&(BYVAL HDC AS LONG)
DECLARE FUNCTION DevOpenDC&(BYVAL HAB AS LONG,_
                            BYVAL along AS LONG,_
                            BYVAL PSZ AS LONG,_
                            BYVAL blong AS LONG,_
                            BYVAL PDEVOPENDATA AS LONG,_
                            BYVAL HDC AS LONG)
DECLARE FUNCTION DosClose%( BYVAL filehandle AS INTEGER)
CONST FIDVERTSCROLL  = &H8006
CONST FIDHORZSCROLL  = &H8007
CONST CLRBACKGROUND  = 0
CONST CLRNEUTRAL     = 7
CONST DBMNORMAL      = &H0000
CONST DBMSTRETCH     = &H0004
CONST SWPSIZE        = &H0001
CONST SWPMOVE        = &H0002
CONST QWPARENT       = 5
CONST CFIHANDLE      = &H0200
CONST CFBITMAP       = 2
CONST MIACHECKED     = &H2000
CONST MIADISABLED    = &H4000
CONST MMSETITEMATTR  = &H0192
CONST WMMINMAXFRAME  = &H0046
CONST SPTRARROW      = 1
CONST SPTRWAIT       = 3
CONST SPTRMOVE       = 5
CONST SEGDISCARDABLE = &H0004
CONST ODMEMORY       = 8&
CONST PUPELS         = &H0008
CONST GPITMICRO      = &H1000
CONST GPIAASSOC      = &H4000
CONST MBOKCANCEL     = &H0001
CONST MBICONASTERISK = &H0030
CONST MBICONHAND     = &H0040
CONST MBIDOK         = 1
CONST MBIDCANCEL     = 2
CONST FIDMENU        = &H8005
CONST SVCXSCREEN     = 20
CONST SVCYSCREEN     = 21
CONST SVCXSIZEBORDER = 4
CONST SVCYSIZEBORDER = 5

TYPE MyBITMAPINFO
    cbFix AS LONG
    cx AS INTEGER
    cy AS INTEGER
    cPlanes AS INTEGER
    cBitCount AS INTEGER
    argbColor AS STRING * 48  'array of 16 RGB values
END TYPE

TYPE BITMAPFORMAT
  Planes AS LONG
  BitCount AS LONG
END TYPE

DECLARE SUB ControlScrollBars(hwnd&, scrollbar%, mp2&)
DECLARE SUB CalculateMinimumFrameWindowSize(hwnd&)
DECLARE SUB SetScrollBarStatus()
DECLARE SUB StopCountDownToCapture(hwnd&)
DECLARE SUB ResetCheckedMenuItem(oldChecked%, newChecked%)
DECLARE SUB CheckIfFrameIsGreaterThanMaximum()
DECLARE SUB SetCaptureRectToEntireScreen()
DECLARE SUB SetCaptureRectToClientWindow(hwnd&)
DECLARE SUB MaximizeOrRestoreTheClientWindow(hwnd&)
DECLARE SUB MaximizeTheClientWindow(hwnd&)
DECLARE SUB SetTheFrameWindowSize(hwnd&, menuSelection%)
DECLARE SUB CaptureScreenToBitmap(hwnd&)
DECLARE SUB DisplayCapturedBitmap()
DECLARE SUB SaveBitmapToFile(hab&, hwnd&, hbm&)
DECLARE SUB LoadBitmapFromFile(hwndFrame&, hwnd&, hbm&)
DECLARE SUB CopyBitmapToClipBoard(hab&, hwnd&, hbm&)
DECLARE SUB LoadBitmapFromClipBoard(hab&, hbm&, hwnd&)
DECLARE SUB PasteClipboardOverCurrentBitmap(hwnd&)
DECLARE SUB CreateBitmapPSandDC(hps&, hdc&)
DECLARE SUB SetStatusOfEditMenuItems(attribute%)
DECLARE SUB SetSystemPointerToWaitPointer()
DECLARE SUB SetSystemPointerToStandardPointer()

DECLARE FUNCTION SelectPortionOfScreenToCapture%()
DECLARE FUNCTION MakeCopyOfBitmap&(hbm&)
DECLARE FUNCTION DisplayMessageBox%(message$, caption$, style%)

CONST IDTIMER      = 1

CONST IDRESOURCE        = 1
CONST IDPOINTER         = 2
CONST IDMEDIT           = 10
CONST   LOADBITMAPFILE  = 11
CONST   LOADCLIPBOARD   = 12
CONST   SAVEBITMAP      = 13
CONST   COPYTOCLIPBOARD = 14
CONST   PASTECLIPBOARD  = 15
CONST   ERASEWINDOW     = 16
CONST   EXITPROGRAM     = 17
CONST IDMCAPTURE        = 20
CONST   ENTIRESCREEN    = 21
CONST   CLIENTWINDOW    = 22
CONST   PARTIALSCREEN   = 23
CONST     USINGTRACK    = 24
CONST     USINGFRAME    = 25
CONST IDMOPTIONS        = 30
CONST   HIDEWINDOW      = 31
CONST   SHOWWINDOW      = 32
CONST   ACTUALSIZE      = 33
CONST   STRETCH              = 34
CONST   IDMDELAY             = 40
CONST WINDOWSIZE             = 120
CONST   SETFRAMEWINDOWSIZE   = 121
CONST   MAXIMIZEFRAMEWINDOW  = 122
CONST   RESTOREWINDOW        = 123
CONST   MAXIMIZECLIENTWINDOW = 124
CONST   RESTORECLIENTWINDOW  = 125

CONST IDDSETFRAMESIZE   = 1
CONST XENTRYFIELD       = 2
CONST YENTRYFIELD       = 3
CONST OKBUTTON          = 4
CONST CANCELBUTTON      = 5
CONST MAXIMIZEBUTTON    = 6
CONST RESTOREBUTTON     = 7
CONST XSCROLLBAR        = 8
CONST YSCROLLBAR        = 9

COMMON /SetWindowSizeDialogBox/ hwndFrame&, cxScreen%, cyScreen%,_
                                newXFrame%, newYFrame%, minFrame%
COMMON /ScrollBarHandles/ hbm&, hwndHorzScroll&, hwndVertScroll&

