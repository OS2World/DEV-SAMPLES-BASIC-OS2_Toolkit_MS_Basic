'**************************************************************
'*
'* Include File: WinAccel.BI
'*
'* Requires:     none
'*
'* Description:  Accelerator Manager
'*
'*************************************************************

' ACCEL fs bits
' *
' * NOTE: the first six AF code bits have the same value
' * as their KC counterparts
' 
CONST AFCHAR         = &H0001
CONST AFVIRTUALKEY   = &H0002
CONST AFSCANCODE     = &H0004
CONST AFSHIFT        = &H0008
CONST AFCONTROL      = &H0010
CONST AFALT          = &H0020
CONST AFLONEKEY      = &H0040
CONST AFSYSCOMMAND   = &H0100
CONST AFHELP         = &H0200

TYPE ACCEL 
    fs   AS INTEGER
    akey AS INTEGER
    cmd  AS INTEGER
END TYPE

TYPE ACCELTABLE
    cAccel AS INTEGER
    codepage AS INTEGER
    aaccel AS ACCEL	     ' array; in C:ACCEL aaccel[1]
END TYPE

DECLARE FUNCTION WinLoadAccelTable&(BYVAL hab AS LONG,_
                                    BYVAL hmod AS INTEGER,_
                                    BYVAL idAccelTable AS INTEGER)

DECLARE FUNCTION WinCreateAccelTable&(BYVAL hab AS LONG,_
                                      BYVAL pAccelTable AS LONG)

DECLARE FUNCTION WinDestroyAccelTable%(BYVAL haccel AS LONG)

DECLARE FUNCTION WinCopyAccelTable%(BYVAL haccel AS LONG,_
                                    BYVAL pAccelTable AS LONG,_
                                    BYVAL cbCopyMax AS INTEGER)

DECLARE FUNCTION WinTranslateAccel%(BYVAL hab AS LONG,_
                                    BYVAL hwnd AS LONG,_
                                    BYVAL haccel AS LONG,_
                                    BYVAL pqmsg AS LONG)

DECLARE FUNCTION WinSetAccelTable%(BYVAL hab AS LONG,_
                                   BYVAL haccel AS LONG,_
                                   BYVAL hwndFrame AS LONG)

DECLARE FUNCTION WinQueryAccelTable&(BYVAL hab AS LONG,_
                                     BYVAL hwndFrame AS LONG)
