'****************************************************************
'* 
'* Program Name: Bounce.BAS
'*
'* Description : This program demonstrates much of the interface
'*               and graphics available to PM programs. In
'*               particular, it uses several different resources
'*               defined in Bounce.RC. These include menus,
'*               accelerator tables and dialog boxes. There
'*               are further controls in each dialog box.
'*
'*               This program also demonstrates using the extra
'*               RegBas routines.  Notice the extra EXPORTS in
'*               Bounce.DEF and the naming convention for the
'*               corresponding ClientWndProc's.
'*---------------------------------------------------------------
'* Execution:    This program allows you to set a variety of
'*               controls for a bouncing ball program. All of
'*               the controls are accessible through either the
'*               menus or through accelerators. The dialog boxes
'*               for the various controls are very similar and
'*               self-explanatory.
'*
'*               The following table lists the menu items,
'*               accelerators, and effects for each control:
'*
'* Menu       Accel       Effect
'* ----       -----       ------
'* CONROL
'* Start      SPACE       Erase window and start ball
'* Stop       ESC         Stop ball and erase window
'* Pause      CTRL+S      Pause ball (don't erase)
'* Continue   CTRL+Q      Continue ball movement (don't erase)
'* Exit       ALT+F4      Close window and exit
'* OPTIONS
'* Sound      SCROLL LOCK (toggle) Beeps on each bounce
'* Size       CTRL+Z      Change size or choose random size
'* Velosity   CTRL+V      Change speed of ball (amount movement per timer)
'* Position   CTRL+P      Change current location of ball
'* Trail      CTRL+T      (toggle) Show previous balls (preferred=yes)
'* Angle      CTRL+A      Change angle of ball movement (degrees)
'*
'* Notes:        The program is more interesting with the trail
'*               option chosen. This will leave all previous balls
'*               instead of just the current. Program execution is
'*               slower without trail.
'*
'*               When dialog boxes are displayed while the ball is
'*               moving, the "white box effect" occurs. The symptom
'*               of this effect is that when the dialog box is
'*               removed, the window behind that is not redrawn.
'*               This can not be avoided if the ball is to keep
'*               moving during dialog (which is desired). To
'*               prevent this effect, use CTRL+S to pause movement
'*               before each dialog and CTRL+Q to continue after
'*               each dialog.
'*
'*               Because this program does not have an icon, the
'*               icon is the same as the normal window. This can
'*               create animated icons, but it is not advised to
'*               run more than one copy of Bounce as it will
'*               monopolize your CPU. In fact, before you switch
'*               to any other process, it is advised to pause
'*               Bounce, or the response in the other process
'*               will be exceedingly slow.
'****************************************************************

'*********         Initialization section        ***********

REM $INCLUDE: 'Bounce.INC'

'***********************************************************************
'*** Global variables fall into 3 categories:
'***    1. Flags   -- boolean values (sound, trail, random size)
'***    2. Values  -- scalar values (size, speed, angle, position, limits)
'***    3. Handles -- handles (anchor block and client window; for StopTimer)

COMMON SHARED /Flags/ Audible%, Trail%, RandSize%
COMMON SHARED /Values/ Size&, Delta%, Angle!, globalX%, globalY%, XMax%, YMax%
COMMON SHARED /Handles/ hab&, hwndClient&

DIM aqmsg AS QMSG

flFrameFlags& = FCFTITLEBAR      OR FCFSYSMENU OR _
                FCFSIZEBORDER    OR FCFMINMAX  OR _
                FCFSHELLPOSITION OR FCFTASKLIST OR _
                FCFMENU          OR FCFACCELTABLE

szClientClass$ = "ClassName" + CHR$(0)

hab& = WinInitialize(0)
hmq& = WinCreateMsgQueue(hab&, 0)

bool% = WinRegisterClass(_
          hab&,_
          MakeLong(VARSEG(szClientClass$), SADD(szClientClass$)),_
          RegBas,_
          CSSIZEREDRAW,_
          0)

hwndFrame& = WinCreateStdWindow (_
          HWNDDESKTOP,_
          WSVISIBLE,_
          MakeLong (VARSEG(flFrameFlags&), VARPTR(flFrameFlags&)),_
          MakeLong (VARSEG(szClientClass$), SADD(szClientClass$)),_
          0,_
          0,_
          0,_
          IDMENU,_
          MakeLong (VARSEG(hwndClient&), VARPTR(hwndClient&)))

'**************         Message loop         ***************

WHILE WinGetMsg(hab&, MakeLong(VARSEG(aqmsg), VARPTR(aqmsg)), 0, 0, 0)
  bool% = WinDispatchMsg(hab&, MakeLong(VARSEG(aqmsg), VARPTR(aqmsg)))
WEND

'***********         Finalize section        ***************

    bool% = WinStopTimer(hab&, hwndClient&, IDTIMER)

bool% = WinDestroyWindow(hwndFrame&)
bool% = WinDestroyMsgQueue(hmq&)
bool% = WinTerminate(hab&)

END

'***********         Window procedures        ***************

'*****
'* ClientWndProc is the main window procedure. The messages do the following:
'*
'* WMCREATE:  Initializes global flags and values
'* WMSIZE:    Sets XMax and YMax and causes a WMPAINT
'* WMMOVE:    Causes WMPAINT
'* WMCOMMAND: Transfers control to dialog or toggles flag
'* WMPAINT:   Erases invalid rect
'* WMTIMER:   Moves ball

FUNCTION ClientWndProc& (hwnd&, msg%, mp1&, mp2&) STATIC
     ClientWndProc&=0
     SELECT CASE msg%
'* WMCREATE:  Initializes global flags and values
     CASE WMCREATE
        Audible%  = 0            'Sound (boolean)
        Trail%    = 0            'Trail (boolean)
        RandSize% = 0            'Random size (boolean)
        Delta%    = 10           'Speed (delta p) (value)
        Angle!    = 45 * Degree  'Angle (value)
        GlobalX%  = 10           'Position (values)
        GlobalY%  = 10
        RANDOMIZE TIMER
'* WMSIZE:    Sets XMax and YMax and causes a WMPAINT
     CASE WMSIZE
        CALL BreakLong(mp2&, YMax%, XMax%)
        bool% = WinInvalidateRect(hwnd&, 0, 0)
'* WMMOVE:    Causes WMPAINT
     CASE WMMOVE
        bool% = WinInvalidateRect(hwnd&, 0, 0)
'* WMCOMMAND: Transfers control to dialog or toggles flag
     CASE WMCOMMAND
        CALL BreakLong(mp1&, HiWord%, LoWord%)
       '*****
       '* WMCOMMAND (Menu or acceltable)
       '*
       '* IDMCSTART:    Start timer and clear window
       '* IDMCSTOP:     Stop timer and clear window
       '* IDMCPAUSE:    Stop timer and leave window as is
       '* IDMCCONT:     Start timer with window as is
       '* IDMCEXIT:     Close window and exit program
       '* IDMOSOUND:    Toggle sound flag
       '* IDMOSIZE:     Display size dialog (ClientWndProc1)
       '* IDMOVELOCITY: Display velocity dialog (ClientWndProc2)
       '* IDMOPOS:      Display position dialog (ClientWndProc3)
       '* IDMOANGLE:    Display angle dialog (ClientWndProc4)
       '* IDMOTRAIL:    Toggle trail flag
        SELECT CASE LoWord%                    'ID in Low word
       '* IDMCSTART:    Start timer and clear window
	  CASE IDMCSTART
	    bool% = WinStartTimer(hab&, hwndClient&, IDTIMER, 10)
            bool% = WinInvalidateRect(hwnd&, 0, 0)
       '* IDMCSTOP:     Stop timer and clear window
	  CASE IDMCSTOP
	    bool% = WinStopTimer(hab&, hwndClient&, IDTIMER)
            bool% = WinInvalidateRect(hwnd&, 0, 0)
       '* IDMCPAUSE:    Stop timer and leave window as is
	  CASE IDMCPAUSE
	    bool% = WinStopTimer(hab&, hwndClient&, IDTIMER)
       '* IDMCCONT:     Start timer with window as is
	  CASE IDMCCONT
	    bool% = WinStartTimer(hab&, hwndClient&, IDTIMER, 10)
       '* IDMCEXIT:     Close window and exit program
	  CASE IDMCEXIT
	    bool% = WinSendMsg(hwnd&, WMCLOSE, 0, 0)
       '* IDMOSOUND:    Toggle sound flag
	  CASE IDMOSOUND
	    Audible% = NOT(Audible%)
       '* IDMOSIZE:     Display size dialog (ClientWndProc1)
	  CASE IDMOSIZE
	    bool% = WinDlgBox (HWNDDESKTOP, hwnd&, RegBas1, 0, LoWord%, 0)
       '* IDMOVELOCITY: Display velocity dialog (ClientWndProc2)
	  CASE IDMOVELOCITY
	    bool% = WinDlgBox (HWNDDESKTOP, hwnd&, RegBas2, 0, LoWord%, 0)
       '* IDMOPOS:      Display position dialog (ClientWndProc3)
	  CASE IDMOPOS
	    bool% = WinDlgBox (HWNDDESKTOP, hwnd&, RegBas3, 0, LoWord%, 0)
       '* IDMOANGLE:    Display angle dialog (ClientWndProc4)
	  CASE IDMOANGLE
	    bool% = WinDlgBox (HWNDDESKTOP, hwnd&, RegBas4, 0, LoWord%, 0)
       '* IDMOTRAIL:    Toggle trail flag
	  CASE IDMOTRAIL
	    Trail% = NOT(Trail%)
	  CASE ELSE
	END SELECT
'* WMPAINT:   Erases invalid rect
     CASE WMPAINT
        hps&  = WinBeginPaint(hwnd&, 0,_
                MakeLong(VARSEG(ClientRect), VARPTR(ClientRect)))
        bool% = WinFillRect(hps&,_
                MakeLong(VARSEG(ClientRect), VARPTR(ClientRect)),0)
        bool% = WinEndPaint(hps&)
'* WMTIMER:   Moves ball
     CASE WMTIMER
        bool% = WinInvalidateRect(hwnd&, 0, 0)
        CALL MoveBall(hwnd&)
     CASE ELSE        'Pass control to system for other messages
        ClientWndProc& = WinDefWindowProc(hwnd&, msg%, mp1&, mp2&)
     END SELECT
END FUNCTION

'************************************************
'*  ClientWndProc1-4 are dialog procedures
'*
'*  ClientWndProc1 is size
'*  ClientWndProc2 is velocity
'*  ClientWndProc3 is position
'*  ClientWndProc4 is angle
'*
'*  The main functionality of each is the same:
'*      1. Initialize
'*      2. Scrollbar
'*      3. Dismiss
'*
'*  The main difference is the conversion of
'*  the global variable to the scroll variable.
'************************************************

'*****
'* ClientWndProc1 is the size dialog procedure
'*
'* Features of size dialog are:
'*
'*        Text region to display current size
'*        Scroll bar to change size
'*        Check box to choose random size
'*        Button to conclude dialog
'*
'* Global variable: Size&, RandSize%
'*
'* Conversion:      FIXED -> IEEE     <==> IEEE = FIXED / (2 ^ 16)
'*                  IEEE -> 1 decimal <==> 1Dec = INT(10 * IEEE) / 10
'*****

FUNCTION ClientWndProc1&(hwnd&, msg%, mp1&, mp2&) STATIC
  ClientWndProc1& = 0
  SELECT CASE msg%
     CASE WMINITDLG
'* Conversion:      FIXED -> IEEE     <==> IEEE = FIXED / (2 ^ 16)
'*                  IEEE -> 1 decimal <==> 1Dec = INT(10 * IEEE) / 10
        dialog$ = LTRIM$(STR$(INT(10 * Size& /  (2 ^ 16)) / 10)) + CHR$(0)
        'Set number
        bool% = WinSetDlgItemText (hwnd&,_
                                   IDMOSCURRENT,_
                                   MakeLong(VARSEG(dialog$), SADD(dialog$)))
        'Set scroll bar
        bool% = WinSendDlgItemMsg (hwnd&,_
                                   IDMOSSCROLL,_
                                   SBMSETSCROLLBAR,_
                                   10 * Size& / (2 ^ 16),_
                                   MakeLong(200, 0))
        'Set check box
        temp% = RandSize%
        bool% = WinSendDlgItemMsg (hwnd&,_
                                   IDMOSRAND,_
                                   BMSETCHECK,_
                                   temp%,_
                                   0)
     CASE WMHSCROLL
	CALL BreakLong(mp2&, HiWord%, LoWord%)
        SELECT CASE HiWord%
	   CASE SBLINELEFT
              Size& = Size& - &H199A      '&H199A / &H10000 = .1
	   CASE SBPAGELEFT
	      Size& = Size& - &H10000
	   CASE SBLINERIGHT
	      Size& = Size& + &H199A
	   CASE SBPAGERIGHT
	      Size& = Size& + &H10000
	   CASE SBSLIDERTRACK
              Size& = LoWord% * &H199A&
	   CASE ELSE
        END SELECT

        'Bounds checking
	IF Size& < &H1000 THEN Size& = &H1000
        IF Size& > &H140000 THEN Size& = &H140000

        'Set number
        dialog$ = LTRIM$(STR$(INT(10 * Size& /  (2 ^ 16)) / 10)) + CHR$(0)
        bool% = WinSetDlgItemText (hwnd&,_
                                   IDMOSCURRENT,_
                                   MakeLong(VARSEG(dialog$), SADD(dialog$)))
        'Set scrollbar if not already set (by sliding)
        IF HiWord% <> SBSLIDERTRACK THEN
          bool% = WinSendDlgItemMsg (hwnd&,_
                                     IDMOSSCROLL,_
                                     SBMSETSCROLLBAR,_
                                     10 * Size& / (2 ^ 16),_
                                     MakeLong(200, 0))
        END IF
     CASE WMCONTROL
        'Toggle Random size flag
        RandSize% = NOT(RandSize%)
        'Set check box
	temp% = RandSize%
	bool% = WinSendDlgItemMsg(hwnd&, IDMOSRAND, BMSETCHECK, temp%, 0)
     CASE WMCOMMAND
	bool% = WinDismissDlg(hwnd&, 1)
     CASE ELSE
	ClientWndProc1& = WinDefDlgProc (hwnd&, msg%, mp1&, mp2&)
  END SELECT
END FUNCTION

'*****
'* ClientWndProc2 is the velocity dialog procedure
'*
'* Features of velocity dialog are:
'*
'*        Text region to display current velocity
'*        Scroll bar to change velocity
'*        Button to conclude dialog
'*
'* Global variable: Delta%
'*
'* Conversion:      None
'*****

FUNCTION ClientWndProc2&(hwnd&, msg%, mp1&, mp2&) STATIC
  ClientWndProc2& = 0
  SELECT CASE msg%
     CASE WMINITDLG
        dialog$ = LTRIM$(STR$(Delta%)) + CHR$(0)
        'Set number
        bool% = WinSetDlgItemText (hwnd&,_
                                   IDMOVCURRENT,_
                                   MakeLong(VARSEG(dialog$), SADD(dialog$)))
        'Set scroll bar
        bool% = WinSendDlgItemMsg(hwnd&,_
                                  IDMOVSCROLL,_
                                  SBMSETSCROLLBAR,_
                                  Delta%,_
                                  MakeLong(50,1))
     CASE WMHSCROLL
	CALL BreakLong(mp2&, HiWord%, LoWord%)
	SELECT CASE HiWord%
	   CASE SBLINELEFT
	      Delta% = Delta% - 1
	   CASE SBPAGELEFT
	      Delta% = Delta% - 5
	   CASE SBLINERIGHT
	      Delta% = Delta% + 1
	   CASE SBPAGERIGHT
	      Delta% = Delta% + 5
	   CASE SBSLIDERTRACK
	      Delta% = LoWord%
	   CASE ELSE
        END SELECT

        'Bounds checking
	IF Delta% < 1 THEN Delta% = 1
        IF Delta% > 50 THEN Delta% = 50

        dialog$ = LTRIM$(STR$(Delta%)) + CHR$(0)
        'Set number
        bool% = WinSetDlgItemText (hwnd&,_
                                   IDMOVCURRENT,_
                                   MakeLong(VARSEG(dialog$), SADD(dialog$)))
        'Set scrollbar if not already set (by sliding)
        IF HiWord% <> SBSLIDERTRACK THEN
          bool% = WinSendDlgItemMsg (hwnd&,_
                                     IDMOVSCROLL,_
                                     SBMSETSCROLLBAR,_
                                     VAL(dialog$),_
                                     MakeLong(50,0))
        END IF
     CASE WMCOMMAND
	bool% = WinDismissDlg(hwnd&, 1)
     CASE ELSE
	ClientWndProc2& = WinDefDlgProc (hwnd&, msg%, mp1&, mp2&)
  END SELECT
END FUNCTION

'*****
'* ClientWndProc3 is the position dialog procedure
'*
'* Features of position dialog are:
'*
'*        Text regions to display current coordinates
'*        Vertical scroll bar to change Y (note: values must be YMax-Y)
'*        Horizontal scroll bar to change X
'*        Button to conclude dialog
'*
'* Global variable: GlobalX%, GlobalY%
'*
'* Conversion:      X:none
'*                  Y Scroll:YMax - Y
'*****

FUNCTION ClientWndProc3&(hwnd&, msg%, mp1&, mp2&) STATIC
  ClientWndProc3& = 0
  SELECT CASE msg%
     CASE WMINITDLG
        dialog$ = LTRIM$(STR$(GlobalX%)) + CHR$(0)
        'Set number
        bool% = WinSetDlgItemText (hwnd&,_
                                   IDMOPX,_
                                   MakeLong(VARSEG(dialog$), SADD(dialog$)))
        'Set scroll bar
        bool% = WinSendDlgItemMsg (hwnd&,_
                                   IDMOPHSCROLL,_
                                   SBMSETSCROLLBAR,_
                                   GlobalX%,_
                                   MakeLong(XMax%, 0))

	dialog$ = LTRIM$(STR$(GlobalY%)) + CHR$(0)
        'Set number
        bool% = WinSetDlgItemText (hwnd&,_
                                   IDMOPY,_
                                   MakeLong(VARSEG(dialog$), SADD(dialog$)))
        'Set scroll bar
        bool% = WinSendDlgItemMsg (hwnd&,_
                                   IDMOPVSCROLL,_
                                   SBMSETSCROLLBAR,_
                                   YMax% - GlobalY%,_
                                   MakeLong(YMax%, 0))
     CASE WMHSCROLL
	CALL BreakLong(mp2&, HiWord%, LoWord%)
	SELECT CASE HiWord%
	   CASE SBLINELEFT
	      GlobalX% = GlobalX% - 1
	   CASE SBPAGELEFT
	      GlobalX% = GlobalX% - 10
	   CASE SBLINERIGHT
	      GlobalX% = GlobalX% + 1
	   CASE SBPAGERIGHT
	      GlobalX% = GlobalX% + 10
	   CASE SBSLIDERTRACK
	      GlobalX% = LoWord%
	   CASE ELSE
        END SELECT

        'Bounds checking
	IF GlobalX% < 0 THEN GlobalX% = 0
        IF GlobalX% > XMax% THEN GlobalX% = XMax%

	dialog$ = LTRIM$(STR$(GlobalX%)) + CHR$(0)
        'Set number
        bool% = WinSetDlgItemText (hwnd&,_
                                   IDMOPX,_
                                   MakeLong(VARSEG(dialog$), SADD(dialog$)))
        'Set scrollbar if not already set (by sliding)
        IF HiWord% <> SBSLIDERTRACK THEN
          bool% = WinSendDlgItemMsg (hwnd&,_
                                     IDMOPHSCROLL,_
                                     SBMSETSCROLLBAR,_
                                     VAL(dialog$),_
                                     MakeLong(XMax%,0))
        END IF
     CASE WMVSCROLL
	CALL BreakLong(mp2&, HiWord%, LoWord%)
	SELECT CASE HiWord%
	   CASE SBLINELEFT
	      GlobalY% = GlobalY% + 1
	   CASE SBPAGELEFT
	      GlobalY% = GlobalY% + 10
	   CASE SBLINERIGHT
	      GlobalY% = GlobalY% - 1
	   CASE SBPAGERIGHT
	      GlobalY% = GlobalY% - 10
	   CASE SBSLIDERTRACK
	      GlobalY% = YMax% - LoWord%
	   CASE ELSE
        END SELECT

        'Bounds checking
	IF GlobalY% < 0 THEN GlobalY% = 0
        IF GlobalY% > YMax% THEN GlobalY% = YMax%

        dialog$ = LTRIM$(STR$(GlobalY%)) + CHR$(0)
        'Set number
        bool% = WinSetDlgItemText (hwnd&,_
                                   IDMOPY,_
                                   MakeLong(VARSEG(dialog$), SADD(dialog$)))
        'Set scrollbar if not already set (by sliding)
        IF HiWord% <> SBSLIDERTRACK THEN
          bool% = WinSendDlgItemMsg (hwnd&,_
                                     IDMOPVSCROLL,_
                                     SBMSETSCROLLBAR,_
                                     YMax% - VAL(dialog$),_
                                     MakeLong(YMax%,0))
        END IF
     CASE WMCOMMAND
	bool% = WinDismissDlg(hwnd&, 1)
     CASE ELSE
	ClientWndProc3& = WinDefDlgProc (hwnd&, msg%, mp1&, mp2&)
  END SELECT
END FUNCTION

'*****
'* ClientWndProc4 is the angle dialog procedure
'*
'* Features of angle dialog are:
'*
'*        Text region to display current angle
'*        Scroll bar to change angle
'*        Button to conclude dialog
'*
'* Global variable: Angle!
'*
'* Conversion:      radian = delta * Degree (conversion constant Degree=PI/180)
'*****

FUNCTION ClientWndProc4&(hwnd&, msg%, mp1&, mp2&) STATIC
  ClientWndProc4& = 0
  'Place Angle! between 0 and 360 degrees
  WHILE Angle! < 0
    Angle! = Angle! + 360 * Degree
  WEND
  SELECT CASE msg%
     CASE WMINITDLG
        dialog$ = LTRIM$(STR$(INT(Angle! / Degree) MOD 360)) + CHR$(0)
        'Set number
        bool% = WinSetDlgItemText (hwnd&,_
                                   IDMOACURRENT,_
                                   MakeLong(VARSEG(dialog$), SADD(dialog$)))
        'Set scroll bar
        bool% = WinSendDlgItemMsg (hwnd&,_
                                   IDMOASCROLL,_
                                   SBMSETSCROLLBAR,_
                                   VAL(dialog$),_
                                   MakeLong(359,0))
     CASE WMHSCROLL
	CALL BreakLong(mp2&, HiWord%, LoWord%)
	SELECT CASE HiWord%
	   CASE SBLINELEFT
	      Angle! = Angle! - Degree
	   CASE SBPAGELEFT
	      Angle! = Angle! - 10 * Degree
	   CASE SBLINERIGHT
	      Angle! = Angle! + Degree
	   CASE SBPAGERIGHT
	      Angle! = Angle! + 10 * Degree
	   CASE SBSLIDERTRACK
	      Angle! = LoWord% * Degree
	   CASE ELSE
        END SELECT

	dialog$ = LTRIM$(STR$(INT(Angle! / Degree) MOD 360)) + CHR$(0)
        'Set number
        bool% = WinSetDlgItemText (hwnd&,_
                                   IDMOACURRENT,_
                                   MakeLong(VARSEG(dialog$), SADD(dialog$)))
        'Set scrollbar if not already set (by sliding)
        IF HiWord% <> SBSLIDERTRACK THEN
          bool% = WinSendDlgItemMsg (hwnd&,_
                                     IDMOASCROLL,_
                                     SBMSETSCROLLBAR,_
                                     VAL(dialog$),_
                                     MakeLong(359,0))
        END IF
     CASE WMCOMMAND
	bool% = WinDismissDlg(hwnd&, 1)
     CASE ELSE
	ClientWndProc4& = WinDefDlgProc (hwnd&, msg%, mp1&, mp2&)
  END SELECT
END FUNCTION

'**************************************************************
'* MoveBall is the procedure that handles the actual ball
'* movement. This process is fairly simple:
'*
'*        1. Increment position
'*        2. Check for bounce
'*        3. Draw ball which entails:
'*                a. Erasing previous ball if Trail is not set
'*                b. Changing color if Wall (local flag) is set
'*                c. Sounding beep if Audible and Wall are set
'*                d. Computing size if RandSize is set
'*                e. (Finally) Drawing current ball
'**************************************************************

SUB MoveBall(hwnd&) STATIC
	DIM ClientRect AS RECTL, Ball AS POINTL, PrevBall AS POINTL
	hps&  = WinBeginPaint(hwnd&, 0,_
		MakeLong(VARSEG(ClientRect), VARPTR(ClientRect)))
	PrevBall.x = globalX%
	PrevBall.y = globalY%

'*        1. Increment position
        globalX% = globalX% + Delta% * COS(Angle!)
        globalY% = globalY% + Delta% * SIN(Angle!)


'*        2. Check for bounce
	IF (globalY% > ClientRect.yTop) OR (globalY% < ClientRect.yBottom) THEN
          Wall% = 1
	  Angle! = 2 * PI - Angle!
	  globalX% = globalX% + Delta% * COS(Angle!)
	  globalY% = globalY% + Delta% * SIN(Angle!)
	END IF
	IF (globalX% > ClientRect.xRight) OR (globalX% < ClientRect.xLeft) THEN
          Wall% = 1
	  Angle! = PI - Angle!
	  globalX% = globalX% + Delta% * COS(Angle!)
	  globalY% = globalY% + Delta% * SIN(Angle!)
        END IF

'*        3. Draw ball which entails:
'*                a. Erasing previous ball if Trail is not set
	IF Trail% = 0 THEN
	  bool% = GpiSetColor(hps&, 0)
	  bool% = GpiMove(hps&, MakeLong(VARSEG(PrevBall), VARPTR(PrevBall)))
	  GFA&	= GpiFullArc (hps&, 3, Size&)
        END IF

'*                b. Changing color if Wall (local flag) is set
        IF Wall% THEN
          Wall% = 0
          ColorIndex% = ((ColorIndex% + 1) MOD 15) + 1

'*                c. Sounding beep if Audible and Wall are set
	  IF Audible% THEN
	    x% = DosBeep(110*Size&/(2^16),1)
	    x% = DosBeep(108*Size&/(2^16),1)
	    x% = DosBeep(110*Size&/(2^16),1)
          END IF

        END IF

'*                d. Computing size if RandSize is set
        IF RandSize% THEN Size& = RND * &H200000

'*                e. (Finally) Drawing current ball
	Ball.x = globalX%
	Ball.y = globalY%
	bool% = GpiMove(hps&, MakeLong(VARSEG(Ball), VARPTR(Ball)))
	bool% = GpiSetColor(hps&, ColorIndex%)
	GFA&  = GpiFullArc (hps&, 3, Size&)
	bool% = WinEndPaint(hps&)
END SUB
