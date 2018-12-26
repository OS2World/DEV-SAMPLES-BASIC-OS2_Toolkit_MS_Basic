'************************************************************
'* File Name:   Bounce.INC
'*
'* Description: INCLUDE file for Bounce.BAS.
'*
'*              This file sets up the FUNCTIONs, TYPEs and CONSTants
'*              for Bounce.BAS. This file is separated to clean up
'*              the code for Bounce.BAS.
'*
'*              Notice that the DECLAREs for many of the individual
'*              FUNCTIONs have been extracted in this file.  This is
'*              due to BASIC's limited compiler workspace.
'************************************************************
REM $INCLUDE: 'PMBase.BI'
REM $INCLUDE: 'WinMisc.BI'
REM $INCLUDE: 'WinDialg.BI'
TYPE POINTL
  x AS LONG
  y AS LONG
END TYPE
DECLARE FUNCTION RegBas1&
DECLARE FUNCTION RegBas2&
DECLARE FUNCTION RegBas3&
DECLARE FUNCTION RegBas4&
DECLARE FUNCTION WinInvalidateRect%( BYVAL hwnd AS LONG,_
                                     BYVAL pwrc AS LONG,_
                                     BYVAL fIncludeChildren AS INTEGER)
DECLARE FUNCTION GpiErase% (BYVAL hps AS LONG)
DECLARE FUNCTION GpiMove% (BYVAL hps AS LONG,_
                           BYVAL pptl AS LONG)
DECLARE FUNCTION GpiSetColor% (BYVAL hps AS LONG,_
                               BYVAL col AS LONG)
DECLARE FUNCTION  GpiFullArc&( BYVAL HPS AS LONG,_
			       BYVAL ALONG AS LONG,_
			       BYVAL FIXED AS LONG)
DECLARE FUNCTION DosBeep% (BYVAL freq AS INTEGER,_
                           BYVAL dur AS INTEGER)

CONST BMSETCHECK         = &H0125

CONST PI = 3.1416                'Trigonometric constants
CONST Degree = PI / 180

CONST IDTIMER      = 1           'RESOURCE CONSTANTS
CONST IDMENU       = 1
CONST IDACCEL      = 1
CONST IDMCONTROL   = 2
CONST IDMOPTIONS   = 3
CONST IDMCSTART    = 4
CONST IDMCSTOP     = 5
CONST IDMCPAUSE    = 6
CONST IDMCCONT     = 7
CONST IDMCEXIT     = 8
CONST IDMOSOUND    = 9
CONST IDMOSIZE     = 10
CONST IDMOVELOCITY = 11
CONST IDMOPOS      = 12
CONST IDMOTRAIL    = 13
CONST IDMOANGLE    = 14
CONST IDMOSRAND    = 16
CONST IDMOSSCROLL  = 17
CONST IDMOSCURRENT = 18
CONST IDMOSOK      = 19
CONST IDMOVSCROLL  = 21
CONST IDMOVCURRENT = 22
CONST IDMOVOK      = 23
CONST IDMOPVSCROLL = 25
CONST IDMOPHSCROLL = 26
CONST IDMOPRECT    = 27
CONST IDMOPX       = 28
CONST IDMOPY       = 29
CONST IDMOPOK      = 30
CONST IDMOASCROLL  = 32
CONST IDMOACURRENT = 33
CONST IDMOAOK      = 34
