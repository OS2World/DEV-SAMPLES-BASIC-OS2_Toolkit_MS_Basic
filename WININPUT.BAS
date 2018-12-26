'***********************************************************
'* 
'* Program Name: WinInput.BAS
'*
'* Include File: WinInput.BI
'*
'* Functions   :
'*               WinSetFocus
'*               WinFocusChange
'*               WinSetCapture
'*               WinQueryCapture
'*               WinQueryFocus
'*               WinGetKeyState
'*               WinGetPhysKeyState
'*               WinEnablePhysInput
'*               WinIsPhysInputEnabled
'*               WinSetKeyboardStateTable
'*
'* Description : This is a PM program to demonstrate the
'*               various mouse and keyboard functions.
'*               This also gives an example of using two of
'*               the main messages associated with mouse and
'*               keyboard input (WMCHAR and WMBUTTON1DBLCLK).
'*               Return values for the functions are written
'*               to the file, WinInput.OUT.
'***********************************************************

'*********         Initialization section        ***********

REM $INCLUDE: 'PMBase.BI'
REM $INCLUDE: 'WinInput.BI'

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
             WSVISIBLE,_
             MakeLong (VARSEG(flFrameFlags&),  VARPTR(flFrameFlags&)),_
             MakeLong (VARSEG(szClientClass$), SADD(szClientClass$)),_
             0,_
             0,_
             0,_
             0,_
             MakeLong (VARSEG(hwndClient&), VARPTR(hwndClient&)))

'*********                 Test  section                ***********

OPEN "WinInput.OUT" FOR OUTPUT AS #1

'*** Get original physical input state
   Original% = WinIsPhysInputEnabled (HWNDDESKTOP)
   PRINT #1, "WinIsPhysInputEnabled:", Original%

'*** Disable physical input
   bool%     = WinEnablePhysInput    (HWNDDESKTOP, 0)
   Disabled% = WinIsPhysInputEnabled (HWNDDESKTOP)
   PRINT #1,  "WinEnablePhysInput(0):", Disabled%

'*** Re-enable physical input
   bool%    = WinEnablePhysInput    (HWNDDESKTOP, 1)
   Enabled% = WinIsPhysInputEnabled (HWNDDESKTOP)
   PRINT #1, "WinEnablePhysInput(1):", Disabled%

'*** Set keyboard focus to client window
   Focus% = WinSetFocus (HWNDDESKTOP, hwndClient&)
   PRINT #1, "WinSetFocus:", Focus%

'*** Set mouse capture to desktop
   Capture% = WinSetCapture (HWNDDESKTOP, HWNDDESKTOP)
   PRINT #1, "WinSetCapture:", Capture%

'*** Get handle for keyboard focus (Client)
'    NOTE: Second parameter allows locking the window
   HFocus& = WinQueryFocus (HWNDDESKTOP, 0)
   PRINT #1, "WinQueryFocus:", HEX$(HFocus&)

'*** Get handle for mouse capture (desktop)
'    NOTE: Second parameter allows locking the window
   HCapture& = WinQueryCapture (HWNDDESKTOP, 0)
   PRINT #1, "WinQueryCapture:",  HEX$(HCapture&)

'*** Following section Gets the current keyboard state,
'    sets the escape virtual key (no effect on phys),
'    and simulates a WMCHAR message.  This will cause
'    the WMCHAR message handler to print a value for
'    the virtual key state and 0 for physical key state.
   REM $DYNAMIC
   DIM KeyArray(0 to 255) AS STRING * 1  'Array for key states

'*** Get key state table.  Last parameter determines get/set.
   bool% = WinSetKeyboardStateTable (HWNDDESKTOP,_
           MakeLong(VARSEG(KeyArray(0)), VARPTR(KeyArray(0))), 0)
   PRINT #1, "WinSetKeyboardStateTable:", bool%

   KeyArray(VKESC) = CHR$(&H81) 	'Escape is down and toggled

'*** Set key state table to simulate escape press.
   bool% = WinSetKeyboardStateTable (HWNDDESKTOP,_
           MakeLong(VARSEG(KeyArray(0)), VARPTR(KeyArray(0))), 1)
   PRINT #1, "WinSetKeyboardStateTable:", bool%

'*** Send message to simulate WMCHAR event.
   bool%= WinSendMsg (hwndClient&, WMCHAR, 0, 0)

'**************         Message loop         ***************

WHILE WinGetMsg(hab&, MakeLong(VARSEG(aqmsg), VARPTR(aqmsg)), 0, 0, 0)
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

'*** When a character message is received (from simulation or key
'    press), display virtual and physical key states. These should
'    essentially match except for the simulated case.
     CASE WMCHAR
	IF (mp1& AND KCKEYUP)=0 THEN
          VKeyState% = WinGetKeyState    (HWNDDESKTOP, VKESC)
	  PKeyState% = WinGetPhysKeyState(HWNDDESKTOP, &H0001) 'Esc Scan=&H0001
          PRINT #1, "WinGetKeyState: ",     VKeyState%,
          PRINT #1, "WinGetPhysKeyState: ", PKeyState%,
	END IF

'*** On a double-click, change the keyboard focus to allow closing
'    with keys (Alt+F4).
     CASE WMBUTTON1DBLCLK
	bool% = WinFocusChange (HWNDDESKTOP, hwnd&, FCNOSETFOCUS)
        PRINT #1, "WinSetFocus:", bool%
     CASE WMPAINT     'Paint the window with background color
        hps&  = WinBeginPaint(hwnd&, 0,_
                MakeLong(VARSEG(ClientRect), VARPTR(ClientRect)))
        bool% = WinFillRect(hps&,_
                MakeLong(VARSEG(ClientRect), VARPTR(ClientRect)),0)
        bool% = WinEndPaint(hps&)
     CASE ELSE        'Pass control to system for other messages
        ClientWndProc& = WinDefWindowProc(hwnd&, msg%, mp1&, mp2&)
     END SELECT
END FUNCTION
