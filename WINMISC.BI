'**************************************************************
'*
'* Include File: WinMisc.BI
'*
'* Requires:     PMBase.BI (RECTL type)
'*
'* Description:  Minor categories:
'*
'*                     Static controls
'*                     Scroll bar controls
'*                   + Timer functions
'*                     Cursor functions
'*                   - Heap functions
'*                   + Atom table functions
'*                   - (WinCatch/WinThrow) removed
'*
'*  + Particularly useful
'*  - Possible conflicts with BASIC's control scheme
'*************************************************************

'*** Static Control Manager 

' Static control styles:
' *
' * NOTE: the top 9 bits of the LOWORD of the window flStyle are used for
' * DT* flags.  The lower 7 bits are for SS* styles.  This gives us up
' * to 128 distinct static control types (we currently use 11 of them).
' 
CONST SSTEXT             = &H0001&
CONST SSGROUPBOX         = &H0002&

CONST SSICON             = &H0003&
CONST SSBITMAP           = &H0004&
CONST SSFGNDRECT         = &H0005&
CONST SSHALFTONERECT     = &H0006&
CONST SSBKGNDRECT        = &H0007&
CONST SSFGNDFRAME        = &H0008&
CONST SSHALFTONEFRAME    = &H0009& 
CONST SSBKGNDFRAME       = &H000a&
CONST SSSYSICON          = &H000b&

' Static control class name 

CONST WCSTATIC       = &Hffff0005

' Static control messages 

CONST SMSETHANDLE        = &H0100
CONST SMQUERYHANDLE      = &H0101



'** Scroll Bar controls Subsection 

' Scroll Bar styles 

CONST SBSHORZ            =0&
CONST SBSVERT            =1&

' Scroll bar class name 


CONST WCSCROLLBAR    = &Hffff0008&

' Scroll Bar messages 

CONST SBMSETSCROLLBAR    = &H01a0
CONST SBMSETPOS          = &H01a1
CONST SBMQUERYPOS        = &H01a2
CONST SBMQUERYRANGE      = &H01a3
CONST SBMSETHILITE       = &H01a4
CONST SBMQUERYHILITE     = &H01a5

' Scroll Bar Commands 

CONST SBLINEUP           =1
CONST SBLINEDOWN         =2
CONST SBLINELEFT         =1
CONST SBLINERIGHT        =2
CONST SBPAGEUP           =3
CONST SBPAGEDOWN         =4
CONST SBPAGELEFT         =3
CONST SBPAGERIGHT        =4
CONST SBSLIDERTRACK      =5
CONST SBSLIDERPOSITION   =6
CONST SBENDSCROLL        =7


TYPE SBCDATA
    cb AS INTEGER
    sHilite AS INTEGER         ' reserved, should be set to zero 
    posFirst AS INTEGER
    posLast AS INTEGER
    posThumb AS INTEGER
END TYPE



'*** Timer manager 

DECLARE FUNCTION WinStartTimer%(BYVAL hab AS LONG,_
                                BYVAL hwnd AS LONG,_
                                BYVAL idTimer AS INTEGER,_
                                BYVAL dtTimeout AS INTEGER)

DECLARE FUNCTION WinStopTimer%(BYVAL hab AS LONG,_
                               BYVAL hwnd AS LONG,_
                               BYVAL idTimer AS INTEGER)

DECLARE FUNCTION WinGetCurrentTime&(BYVAL hab AS LONG)

CONST TIDCURSOR          = &Hffff  ' Reserved cursor timer ID 
CONST TIDSCROLL          = &Hfffe  ' Reserved scrolling timer ID 
CONST TIDFLASHWINDOW     = &Hfffd  ' Reserved for window flashing timer ID 



'*** Cursor manager common subsection 

DECLARE FUNCTION WinDestroyCursor%(BYVAL hwnd AS LONG)

DECLARE FUNCTION WinShowCursor%(BYVAL hwnd AS LONG,_
                                BYVAL fShow AS INTEGER)

DECLARE FUNCTION WinCreateCursor%(BYVAL hwnd AS LONG,_
                                  BYVAL x AS INTEGER,_
                                  BYVAL y AS INTEGER,_
                                  BYVAL cx AS INTEGER,_
                                  BYVAL cy AS INTEGER,_
                                  BYVAL fs AS INTEGER,_
                                  BYVAL prclClip AS LONG)

' WinCreateCursor() flags 

CONST CURSORSOLID     = &H0000
CONST CURSORHALFTONE  = &H0001
CONST CURSORFRAME     = &H0002
CONST CURSORFLASH     = &H0004
CONST CURSORSETPOS    = &H8000

TYPE CURSORINFO
    hwnd AS LONG
    x AS INTEGER
    y AS INTEGER
    cx AS INTEGER
    cy AS INTEGER
    fs AS INTEGER
    rclClip AS RECTL
END TYPE

DECLARE FUNCTION WinQueryCursorInfo%(BYVAL hwndDesktop AS LONG,_
                                     BYVAL pCursorInfo AS LONG)

' Heap Manager Interface declarations 

DECLARE FUNCTION WinCreateHeap&(BYVAL selHeapBase AS INTEGER,_
                                BYVAL cbHeap AS INTEGER,_
                                BYVAL cbGrow AS INTEGER,_
                                BYVAL chMinDed AS INTEGER,_
                                BYVAL cbMaxDed AS INTEGER,_
                                BYVAL fOptions AS INTEGER)

DECLARE FUNCTION WinDestroyHeap&(BYVAL hHeap AS LONG)

DECLARE FUNCTION WinAvailMem%(BYVAL hHeap AS LONG,_
                              BYVAL fCompact AS INTEGER,_
                              BYVAL cbMinFree AS INTEGER)

DECLARE FUNCTION WinAllocMem%(BYVAL hHeap AS LONG,_
                              BYVAL cb AS INTEGER)

DECLARE FUNCTION WinReallocMem%(BYVAL hHeap AS LONG,_
                                BYVAL npMem AS INTEGER,_
                                BYVAL cbOld AS INTEGER,_
                                BYVAL cbNew AS INTEGER)

DECLARE FUNCTION WinFreeMem%(BYVAL hHeap AS LONG,_
                             BYVAL npMem AS INTEGER,_
                             BYVAL cbMem AS INTEGER)

DECLARE FUNCTION WinLockHeap&(BYVAL hHeap AS LONG)

CONST HMMOVEABLE     = &H0001      ' Parameters to WinCreateHeap 
CONST HMVALIDSIZE    = &H0002

'** Atom Manager Interface declarations 

DECLARE FUNCTION WinQuerySystemAtomTable&()

DECLARE FUNCTION WinCreateAtomTable&(BYVAL cbInitial AS INTEGER,_
                                     BYVAL cBuckets AS INTEGER)

DECLARE FUNCTION WinDestroyAtomTable&(BYVAL hAtomTbl AS LONG)

DECLARE FUNCTION WinAddAtom%(BYVAL hAtomTbl AS LONG,_
                             BYVAL pszAtomName AS LONG)

DECLARE FUNCTION WinFindAtom%(BYVAL hAtomTbl AS LONG,_
                              BYVAL pszAtomName AS LONG)

DECLARE FUNCTION WinDeleteAtom%(BYVAL hAtomTbl AS LONG,_
                                BYVAL atom AS INTEGER)

DECLARE FUNCTION WinQueryAtomUsage%(BYVAL hAtomTbl AS LONG,_
                                    BYVAL atom AS INTEGER)

DECLARE FUNCTION WinQueryAtomLength%(BYVAL hAtomTbl AS LONG,_
                                     BYVAL atom AS INTEGER)

DECLARE FUNCTION WinQueryAtomName%(BYVAL hAtomTbl AS LONG,_
                                   BYVAL atom AS INTEGER,_
                                   BYVAL pchBuffer AS LONG,_
                                   BYVAL cchBufferMax AS INTEGER)


'** Catch/Throw Interface declarations 
'
' Catch and Throw can not be used with BASIC because they reset the
' program state which BASIC will not allow.
'
'TYPE CATCHBUF
'    reserved0 AS LONG
'    reserved1 AS LONG
'    reserved2 AS LONG
'    reserved3 AS LONG          ' array; in C: LONG reserved[4]
'END TYPE
'
'DECLARE FUNCTION WinCatch%(BYVAL pcatchbuf AS LONG)
'
'DECLARE SUB WinThrow(BYVAL pcatchbuf AS LONG,_
'                     BYVAL nThrowBack AS INTEGER)
