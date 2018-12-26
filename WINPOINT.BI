'**************************************************************
'*
'* Include File: WinPoint.BI
'*
'* Requires:     none
'*
'* Description:  Mouse pointer manager
'*
'*************************************************************

DECLARE FUNCTION WinSetPointer%(BYVAL hwndDesktop AS LONG,_
                                BYVAL hptrNew AS LONG)

DECLARE FUNCTION WinShowPointer%(BYVAL hwndDesktop AS LONG,_
                                 BYVAL fShow AS INTEGER)

DECLARE FUNCTION WinQuerySysPointer&(BYVAL hwndDesktop AS LONG,_
                                     BYVAL iptr AS INTEGER,_
                                     BYVAL fLoad AS INTEGER)

CONST SPTRARROW            =1
CONST SPTRTEXT             =2
CONST SPTRWAIT             =3
CONST SPTRMOVE             =5
CONST SPTRSIZENWSE         =6
CONST SPTRSIZENESW         =7
CONST SPTRSIZEWE           =8
CONST SPTRSIZENS           =9
CONST SPTRAPPICON          =10
CONST SPTRICONINFORMATION  =11
CONST SPTRICONQUESTION     =12
CONST SPTRICONERROR        =13
CONST SPTRICONWARNING      =14
CONST SPTRCPTR             =14    ' count loaded by pmwin 

CONST SPTRILLEGAL          =18
CONST SPTRFILE             =19
CONST SPTRFOLDER           =20
CONST SPTRMULTFILE         =21
CONST SPTRPROGRAM          =22

CONST SPTRHANDICON         =11    ' backward compatibility 
CONST SPTRQUESICON         =12
CONST SPTRBANGICON         =13
CONST SPTRNOTEICON         =14

DECLARE FUNCTION WinLoadPointer&(BYVAL hwndDesktop AS LONG,_
                                 BYVAL hmod AS INTEGER,_
                                 BYVAL idres AS INTEGER)

DECLARE FUNCTION WinDestroyPointer%(BYVAL hptr AS LONG)

DECLARE FUNCTION WinCreatePointer&(BYVAL hwndDesktop AS LONG,_
                                   BYVAL hbmPointer AS LONG,_
                                   BYVAL fPointer AS INTEGER,_
                                   BYVAL xHotspot AS INTEGER,_
                                   BYVAL yHotspot AS INTEGER)

DECLARE FUNCTION WinQueryPointer&(BYVAL hwndDesktop AS LONG)

DECLARE FUNCTION WinSetPointerPos%(BYVAL hwndDesktop AS LONG,_
                                   BYVAL x AS INTEGER,_
                                   BYVAL y AS INTEGER)

DECLARE FUNCTION WinQueryPointerPos%(BYVAL hwndDesktop AS LONG,_
                                     BYVAL pptl AS LONG)

TYPE POINTERINFO
    fPointer AS INTEGER
    xHotspot AS INTEGER
    yHotspot AS INTEGER
    hbmPointer AS LONG
END TYPE

DECLARE FUNCTION WinQueryPointerInfo%(BYVAL hptr AS LONG,_
                                      BYVAL pPointerInfo AS LONG)


DECLARE FUNCTION WinDrawPointer%(BYVAL hps AS LONG,_
                                 BYVAL x AS INTEGER,_
                                 BYVAL y AS INTEGER,_
                                 BYVAL hptr AS LONG,_
                                 BYVAL fs AS INTEGER)

' WinDrawPointer() constants 

CONST DPNORMAL      = &H0000
CONST DPHALFTONED   = &H0001
CONST DPINVERTED    = &H0002

DECLARE FUNCTION WinGetSysBitmap&(BYVAL hwndDesktop AS LONG,_
                                  BYVAL ibm AS INTEGER)

' System bitmaps (NOTE: these are 1-based) 

CONST SBMPSYSMENU          =1
CONST SBMPSBUPARROW        =2
CONST SBMPSBDNARROW        =3
CONST SBMPSBRGARROW        =4
CONST SBMPSBLFARROW        =5
CONST SBMPMENUCHECK        =6
CONST SBMPCHECKBOXES       =7
CONST SBMPBTNCORNERS       =8
CONST SBMPMINBUTTON        =9
CONST SBMPMAXBUTTON        =10
CONST SBMPRESTOREBUTTON    =11
CONST SBMPCHILDSYSMENU     =12
CONST SBMPDRIVE            =15
CONST SBMPFILE             =16
CONST SBMPFOLDER           =17
CONST SBMPTREEPLUS         =18
CONST SBMPTREEMINUS        =19
CONST SBMPPROGRAM          =22
CONST SBMPMENUATTACHED     =23
CONST SBMPSIZEBOX          =24
