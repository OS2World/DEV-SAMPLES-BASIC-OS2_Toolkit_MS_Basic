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
DECLARE FUNCTION WinQueryClipbrdData&(BYVAL hab AS LONG,_
                                      BYVAL fmt AS INTEGER)
DECLARE FUNCTION WinQuerySysValue&(BYVAL hwndDesktop AS LONG,_
                                   BYVAL iSysValue AS INTEGER)
DECLARE FUNCTION WinOpenClipbrd%(BYVAL hab AS LONG)
DECLARE FUNCTION WinCloseClipbrd%(BYVAL hab AS LONG)
DECLARE FUNCTION GpiErase%( BYVAL HPS AS LONG )
DECLARE FUNCTION GpiDestroyPS%( BYVAL HPS AS LONG )
DECLARE FUNCTION GpiCreatePS&( BYVAL HAB AS LONG,_
                               BYVAL HDC AS LONG,_
                               BYVAL PSIZEL AS LONG,_
                               BYVAL ULONG AS LONG )
DECLARE FUNCTION DosBeep%(BYVAL frequency AS INTEGER,_
                          BYVAL duration  AS INTEGER)
DECLARE FUNCTION DevCloseDC&(BYVAL HDC AS LONG)
DECLARE FUNCTION DevOpenDC&(BYVAL HAB AS LONG,_
                            BYVAL along AS LONG,_
                            BYVAL PSZ AS LONG,_
                            BYVAL blong AS LONG,_
                            BYVAL PDEVOPENDATA AS LONG,_
                            BYVAL HDC AS LONG)
CONST SVCXICON       = 38
CONST CFBITMAP       = 2
CONST ODMEMORY       = 8&
CONST PUPELS         = &H0008
CONST GPITMICRO      = &H1000
CONST GPIAASSOC      = &H4000
CONST MBICONASTERISK = &H0030
CONST WMMOUSEMOVE    = &H0070
CONST WMBUTTON1DOWN  = &H0071
CONST WMBUTTON1UP    = &H0072
CONST WMBUTTON2UP    = &H0075
CONST FIDMENU        = &H8005
CONST MMSETITEMATTR  = &H0192
CONST MIACHECKED     = &H2000
CONST MIADISABLED    = &H4000
CONST CLRWHITE       = -2

DECLARE SUB MoveBitmap(hwnd&, movex%, movey%)
DECLARE SUB FlingBitmapFromClipBoard(hwnd&, hbm&)
DECLARE FUNCTION MakeCopyOfBitmap&(hbmSource&)
DECLARE SUB CreateBitmapPSandDC(hps&, hdc&)
DECLARE SUB MaximizeOrRestoreTheClientWindow(hwnd&)
DECLARE SUB MaximizeTheClientWindow(hwnd&)
DECLARE SUB ResetCheckedMenuItem(oldChecked%, newChecked%)
DECLARE SUB ClearTheClientWindow(hps&)
DECLARE SUB DisplayHelp()

CONST IDMEXIT                 = 10
CONST IDMSOUND                = 21
CONST IDMMAXIMIZECLIENTWINDOW = 22
CONST IDMCOLOR                = 40
CONST IDMBITMAPS              = 60
CONST IDMCLIPBRD              = 65

