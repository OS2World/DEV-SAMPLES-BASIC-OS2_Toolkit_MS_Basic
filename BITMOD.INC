DECLARE FUNCTION WinMessageBox%(BYVAL hwndParent AS LONG,_
                                BYVAL hwndOwner AS LONG,_
                                BYVAL pszText AS LONG,_
                                BYVAL pszCaption AS LONG,_
                                BYVAL idWindow AS INTEGER,_
                                BYVAL flStyle AS INTEGER)
DECLARE FUNCTION WinGetScreenPS&(BYVAL hwnd AS LONG)
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
CONST RTBITMAP  = 2
CONST ODMEMORY  = 8&
CONST PUPELS    = &H0008
CONST GPITMICRO = &H1000
CONST GPIAASSOC = &H4000
CONST MBOKCANCEL     = &H0001
CONST MBICONASTERISK = &H0030
CONST MBIDOK         =1

CONST IDBBITMAP1        = 100
CONST IDBBITMAP2        = 200
CONST IDBBITMAP3        = 300
CONST ShowAllSysBitmaps = 70

