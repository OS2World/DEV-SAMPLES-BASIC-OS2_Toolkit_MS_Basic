'**************************************************************
'*
'* Include File: WinShell.BI
'*
'* Requires:     (includes PMShl.BI)
'*
'* Description:  Code page control (rarely used)
'*
'*************************************************************
'
' * Include Shell API stuff
' 
rem '$include: 'PMShl.BI'      ' OS/2 Shell definitions


DECLARE FUNCTION WinQueryCp%(BYVAL hmq AS LONG)

DECLARE FUNCTION WinSetCp%(BYVAL hmq AS LONG,_
                           BYVAL idCodePage AS INTEGER)

DECLARE FUNCTION WinQueryCpList%(BYVAL hab AS LONG,_
                                 BYVAL ccpMax AS INTEGER,_
                                 BYVAL prgcp AS LONG)

DECLARE FUNCTION WinCpTranslateString%(BYVAL hab AS LONG,_
                                       BYVAL cpSrc AS INTEGER,_
                                       BYVAL pszSrc AS LONG,_
                                       BYVAL cpDst AS INTEGER,_
                                       BYVAL cchDestMax AS INTEGER,_
                                       BYVAL pchDest AS LONG)

'***** WinCpTranslateChar returns a single byte and has a byte parameter.
'      neither of these is possible in BASIC. If this function is needed,
'      use the C language instead.
'
'DECLARE FUNCTION WinCpTranslateChar%(BYVAL hab AS LONG,_
'                                     BYVAL cpSrc AS INTEGER,_
'                                     BYVAL  chSrc AS CHAR,
'                                     BYVAL cpDst AS INTEGER)

DECLARE FUNCTION WinUpper%(BYVAL hab AS LONG,_
                           BYVAL idcp AS INTEGER,_
                           BYVAL idcc AS INTEGER,_
                           BYVAL psz AS LONG)

DECLARE FUNCTION WinUpperChar%(BYVAL hab AS LONG,_
                               BYVAL idcp AS INTEGER,_
                               BYVAL idcc AS INTEGER,_
                               BYVAL c AS INTEGER)

DECLARE FUNCTION WinNextChar&(BYVAL hab AS LONG,_
                              BYVAL idcp AS INTEGER,_
                              BYVAL idcc AS INTEGER,_
                              BYVAL psz AS LONG)

DECLARE FUNCTION WinPrevChar&(BYVAL hab AS LONG,_
                              BYVAL idcp AS INTEGER,_
                              BYVAL idcc AS INTEGER,_
                              BYVAL pszStart AS LONG,_
                              BYVAL psz AS LONG)

DECLARE FUNCTION WinCompareStrings%(BYVAL hab AS LONG,_
                                    BYVAL idcp AS INTEGER,_
                                    BYVAL idcc AS INTEGER,_
                                    BYVAL psz1 AS LONG,_
                                    BYVAL psz2 AS LONG,_
                                    BYVAL reserved AS INTEGER)

CONST WCSERROR =0
CONST WCSEQ    =1
CONST WCSLT    =2
CONST WCSGT    =3
