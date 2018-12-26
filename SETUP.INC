'************************************************************
'* File Name:   Setup.INC
'*
'* Description: INCLUDE file for Setup.BAS.
'*
'*              This file sets up the FUNCTIONs, TYPEs and CONSTants
'*              for Setup.BAS. This file is separated to clean up
'*              the code for Setup.BAS.
'*
'*              Notice that the DECLAREs for many of the individual
'*              FUNCTIONs have been extracted in this file.  This is
'*              due to BASIC's limited compiler workspace.
'************************************************************
REM $INCLUDE: 'PMBase.BI'
REM $INCLUDE: 'WinMan1.BI'
REM $INCLUDE: 'WinMisc.BI'
REM $INCLUDE: 'WinDialg.BI'
REM $INCLUDE: 'WinMsgs.BI'

CONST BMSETCHECK         = &H0125    'Extracted Constants, types and functions
CONST FIDMENU            = &H8005
CONST FIDTITLEBAR        = &H8003
CONST MMSETITEMATTR      = &H0192
CONST MIADISABLED        = &H4000
DECLARE FUNCTION GpiLoadBitmap&( BYVAL HPS AS LONG,_
					 BYVAL HMODULE AS INTEGER,_
					 BYVAL USHORT AS INTEGER,_
					 BYVAL ALONG AS LONG,_
					 BYVAL BLONG AS LONG )

TYPE FILEFINDBUF
	fdateCreation  AS INTEGER
	ftimeCreation  AS INTEGER
	fdateLastAccess AS INTEGER
	ftimeLastAccess AS INTEGER
	fdateLastWrite AS INTEGER
	ftimeLastWrite AS INTEGER
	cbFile	       AS LONG
	cbFileAlloc    AS LONG
	attrFile       AS INTEGER
	cchName        AS STRING * 1
	achName        AS STRING * 13
END TYPE

DECLARE FUNCTION DosFindFirst%( _
        BYVAL P1s AS INTEGER,_ 
        BYVAL P1o AS INTEGER,_
        SEG   P2 AS INTEGER,_
        BYVAL P3 AS INTEGER,_
	SEG   P4 AS FILEFINDBUF,_
        BYVAL P5 AS INTEGER,_
        SEG   P6 AS INTEGER,_
        BYVAL P7 AS LONG)

DECLARE FUNCTION RegBas1&

CONST IDSETUP  = 1                'Resource Constants
CONST IDBITMAP = 2
CONST IDDRPATH = 2
CONST IDSTART  = 3
CONST IDABOUT  = 4

CONST IDSOURCE  = 1
CONST IDDEST    = 2
CONST IDBASE    = 3
CONST IDINCLUDE = 4
CONST IDLIB     = 5
CONST IDCMD     = 6
CONST IDHELP    = 7
CONST IDUTILITY = 8
CONST IDEXAMPLE = 9
CONST IDCHECK   = 20

CONST BNOK      = 10
CONST BNCANCEL  = 11
CONST BNHELP    = 12

DECLARE FUNCTION FarSADD&(s$)                        'Functions in Setup.BAS
DECLARE FUNCTION GetDiskName$()
DECLARE FUNCTION FileExists% (filespec$)
DECLARE FUNCTION Replace$ (full$, oldpart$, newpart$)
DECLARE FUNCTION DisplayMessageBox%(message$, caption$, flStyle%)
DECLARE FUNCTION ValidDrive%(hwnd&, drive$, id%)
DECLARE FUNCTION ValidDir%(hwnd&, new$, old$, id%)

DECLARE SUB WinPrintS(hps AS LONG, PString AS STRING)   'WinStdio functions
DECLARE SUB WinPrint(hps AS LONG, PString AS STRING)
DECLARE SUB WinCLS(hwnd AS LONG, hps&)
DECLARE SUB WinResetStdIO(hwnd&, hps&)
DECLARE SUB WinLocate(hwnd&, hps&, Row%, Col%)
DECLARE FUNCTION WinPos%(hps AS LONG)
DECLARE FUNCTION WinCSRLIN%(hwnd AS LONG, hps AS LONG)
