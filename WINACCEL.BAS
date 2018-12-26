'***********************************************************
'* 
'* Program Name: WinAccel.BAS
'*
'* Include File: WinAccel.BI, WinMenu.BI
'*
'* Functions   :
'*               WinCreateMenu        Not Demonstrated,see below
'*               WinLoadMenu
'*               WinLoadAccelTable
'*               WinSetAccelTable
'*               WinQueryAccelTable
'*               WinCopyAccelTable
'*               WinDestroyAccelTable
'*               WinCreateAccelTable
'*               WinTranslateAccel    Not Demonstrated,see below
'*
'* Description : This program demonstrates loading a menu
'*               (using WinLoadMenu) and an accelerator table
'*               (using WinLoad/SetAccelTable) from a resource file
'*               (WinAccel.RC). The accelerator table is dynamically
'*               changed from using CTRL to ALT with 1, 2 and 3.
'*               This utilizes virtually all of the other accelerator
'*               functions (Query,Copy,Destroy and Create) and is
'*               caused by pressing the 2nd button. WinTranslateAccel
'*               is not demonstrated because it is rarely used, as it
'*               states in the documentation for this function in "OS/2
'*               Programmer's Reference Vol II". WinCreateMenu is not
'*               demonstrated due to complexity of creating an area in
'*               data memory to simulate a binary menu-template-resource.
'*               It is advised touse WinLoadMenu, with a resouce compiled
'*               with the RC resource compiler that comes with the PM
'*               Toolkit or specify the resource ID in WinCreateStdWindow.
'***********************************************************

'*********         Initialization section        ***********

REM $INCLUDE: 'PMBase.BI'
REM $INCLUDE: 'BseDosPC.BI'	 Needed for DOSBeep
REM $INCLUDE: 'WinMan1.BI'	 Needed for WinShowWindow
REM $INCLUDE: 'WinInput.BI'	 Needed for WMBUTTON2DOWN
REM $INCLUDE: 'WinMenu.BI'
REM $INCLUDE: 'WinAccel.BI'

TYPE MyACCELTABLE		 'Accelerator table with 3 accelerators
  cAccel AS INTEGER
  codepage AS INTEGER
  aaccel0 AS ACCEL
  aaccel1 AS ACCEL
  aaccel2 AS ACCEL
END TYPE

CONST IDRESOURCE = 1		'Constants for Resource File
CONST IDMBEEP	 = 2
CONST IDMBEEP1   = 3
CONST IDMBEEP2   = 4
CONST IDMBEEP3   = 5
CONST IDMEXIT    = 6
CONST IDMBYE     = 7 
CONST IDACCEL	 = 8

DIM aqmsg AS QMSG

flFrameFlags& =  FCFTITLEBAR      OR FCFSYSMENU OR _
                 FCFSIZEBORDER    OR FCFMINMAX  OR _
                 FCFSHELLPOSITION OR FCFTASKLIST

szClientClass$ = "ClassName" + CHR$(0)

hab&  = WinInitialize    (0)
hmq&  = WinCreateMsgQueue(hab&, 0)

bool% = WinRegisterClass(_
        hab&,_
        MakeLong(VARSEG(szClientClass$), SADD(szClientClass$)),_
        RegBas,_
        0,_
        0)

hwndFrame& = WinCreateStdWindow (_
             HWNDDESKTOP,_
             WSINVISIBLE,_
             MakeLong(VARSEG(flFrameFlags&),  VARPTR(flFrameFlags&)),_
             MakeLong(VARSEG(szClientClass$), SADD(szClientClass$)),_
             0,_
             0,_
             0,_
             0,_           'Optional: Specify Resource ID here
             MakeLong(VARSEG(hwndClient&), VARPTR(hwndClient&)))

'***********      WinLoad/SetAccelTable    *****************

OPEN "WinAccel.OUT" FOR OUTPUT AS #1

DIM pAccelTable AS MyACCELTABLE 	   'Needed for Copy and CreateAccel

'*** WinLoadAccelTable returns a handle to an accelerator from a resource file
   hAccel& = WinLoadAccelTable (hab&, 0, IDACCEL)
   PRINT #1,"WinLoadAccelTable:", HEX$(hAccel&)

'*** WinSetAccelTable is required to associate an accelerator with a window
   bool%  =  WinSetAccelTable (hab&, hAccel&, hwndFrame&)
   PRINT #1,"WinSetAccelTable:",bool%

   hAccel& = 0		  'Reset handle to make Query be necessary

'***********          WinLoadMenu          *****************

hMenu& = WinLoadMenu (hwndFrame&, 0, IDRESOURCE)
Bool%  = WinShowWindow (hwndFrame&, 1)

'**************         Message loop         ***************

WHILE WinGetMsg(hab&, MakeLong(VARSEG(aqmsg), VARPTR(aqmsg)), 0, 0, 0)

'*** Check for button here (instead of ClientWndProc) to keep the anchor
'    block handle available for Accel functions.
  IF aqmsg.msg = WMBUTTON2DOWN THEN	     'Change AccelTable on button 2

'*** WinQueryAccelTable returns accelerator handle for the window
    hAccel& =  WinQueryAccelTable(hab&, hwndFrame&)
    PRINT #1, "WinQueryAccelTable:", HEX$(hAccel&)

'*** WinCopyAccelTable copies the accelerator table for hAccel& to pAccelTable
    size% = WinCopyAccelTable(hAccel&,_
            MakeLong(VARSEG(pAccelTable), VARPTR(pAccelTable)),_
            LEN(pAccelTable))
    PRINT #1, "WinCopyAccelTable:",size%
    PRINT #1, "AccelTable:"
    PRINT #1, "cAccel:    ";pAccelTable.cAccel
    PRINT #1, "codepage:  ";pAccelTable.codepage
    PRINT #1, "Table entries: "
    PRINT #1, "     Entry #";1
    PRINT #1, "       Flags:   ";HEX$(pAccelTable.aaccel0.fs)
    PRINT #1, "       Key:     ";CHR$(pAccelTable.aaccel0.akey)
    PRINT #1, "       Command: ";pAccelTable.aaccel0.cmd
    PRINT #1, "     Entry #";2
    PRINT #1, "       Flags:   ";HEX$(pAccelTable.aaccel1.fs)
    PRINT #1, "       Key:     ";CHR$(pAccelTable.aaccel1.akey)
    PRINT #1, "       Command: ";pAccelTable.aaccel1.cmd
    PRINT #1, "     Entry #";3
    PRINT #1, "       Flags:   ";HEX$(pAccelTable.aaccel2.fs)
    PRINT #1, "       Key:     ";CHR$(pAccelTable.aaccel2.akey)
    PRINT #1, "       Command: ";pAccelTable.aaccel2.cmd
    PRINT #1, ""

'*** WinDestroyAccelTable destroys current accelerator table so new can be made
    bool%   =  WinDestroyAccelTable (hAccel&)
    PRINT #1, "WinDestroyAccelTable:", bool%

'*** Change accelerator from CTRL n to ALT n
    pAccelTable.aaccel0.fs = AFALT OR AFCHAR
    pAccelTable.aaccel1.fs = AFALT OR AFCHAR
    pAccelTable.aaccel2.fs = AFALT OR AFCHAR

'*** WinCreateAccelTable returns handle for new accelerator table
    hAccel& = WinCreateAccelTable(hab&,_
              MakeLong(VARSEG(pAccelTable), VARPTR(pAccelTable)))
    PRINT #1, "WinCreateAccelTable:", HEX$(hAccel&)

'*** WinSetAccelTable is required to associate an accelerator with a window
    bool%  =  WinSetAccelTable (hab&, hAccel&, hwndFrame&)
    PRINT #1,"WinSetAccelTable:", bool%
  END IF
  bool% = WinDispatchMsg(hab&, MakeLong(VARSEG(aqmsg), VARPTR(aqmsg)))
WEND
     
'***********         Finalize section        ***************

CLOSE #1

bool% = WinDestroyWindow   (hwndFrame&)
bool% = WinDestroyMsgQueue (hmq&)
bool% = WinTerminate       (hab&)

END

'***********         Window procedure        ***************

FUNCTION ClientWndProc& (hwnd&, msg%, mp1&, mp2&) STATIC
     DIM ClientRect AS RECTL
     ClientWndProc& = 0
     SELECT CASE msg%
     CASE WMPAINT     'Paint the window with background color
        hps&  = WinBeginPaint(hwnd&, 0,_
                MakeLong(VARSEG(ClientRect), VARPTR(ClientRect)))
        bool% = WinFillRect(hps&,_
                MakeLong(VARSEG(ClientRect), VARPTR(ClientRect)),0)
        bool% = WinEndPaint(hps&)
     CASE WMCOMMAND	'WMCOMMAND sent for any menu msg
	  CALL BreakLong(mp1&, HiWord%, LoWord%)
	  SELECT CASE LoWord%	   'MenuItem ID is in low word of mp1
               CASE IDMBEEP1
		     X% = DosBeep(110,100)
               CASE IDMBEEP2
		     X% = DosBeep(110,100)
		     X% = DosBeep(220,100)
               CASE IDMBEEP3
		     X% = DosBeep(110,100)
		     X% = DosBeep(220,100)
		     X% = DosBeep(440,100)
               CASE IDMBYE
                     Quit& = WinSendMsg(HWND&,WMClose,0,0)     
	       CASE ELSE	   'Should never be any other case
	  END SELECT
     CASE ELSE        'Pass control to system for other messages
        ClientWndProc& = WinDefWindowProc(hwnd&, msg%, mp1&, mp2&)
     END SELECT
END FUNCTION
