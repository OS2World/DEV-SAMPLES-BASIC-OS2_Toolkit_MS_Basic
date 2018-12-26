'***********************************************************
'* 
'* Program Name: WinTrack.BAS
'*
'* Include File: WinTrack.BI
'*
'* Functions   :
'*               WinTrackRect
'*               WinShowTrackRect  Not shown; see below
'*
'* Description : This program demonstrates using the tracking
'*               rectangle.  Every time mouse button 1 is
'*               pressed, the mouse (or keyboard) movement
'*               is tracked and the new location is printed to
'*               the file "WinTrack.OUT".  WinShowTrackRect is
'*               not demonstrated because the only time this
'*               function would be used is during asynchronous
'*               drawing in different threads.  Since BASIC
'*               does not support multi-threaded applications,
'*               this function is not useful.  It has been left
'*               in the INCLUDE file for possible future
'*               implementations.
'***********************************************************

'*********         Initialization section        ***********

REM $INCLUDE: 'PMBase.BI'
REM $INCLUDE: 'OS2Def.BI'      Needed for POINTL for TRACKINFO
REM $INCLUDE: 'WinTrack.BI'
REM $INCLUDE: 'WinInput.BI'    Needed for mouse messages

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

OPEN "WinTrack.OUT" FOR OUTPUT AS #1

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
     DIM ti         AS TRACKINFO
     DIM ClientRect AS RECTL
     ClientWndProc& = 0
     SELECT CASE msg%
     CASE WMBUTTON1DOWN 	      'Track mouse whenever button is down

        IF ti.cxBorder  = 0 THEN      'Initialize track info
	  ti.cxBorder	= 1
	  ti.cyBorder	= 1
	  ti.cxGrid	= 4
	  ti.cyGrid	= 4
	  ti.cxKeyboard = 4
	  ti.cyKeyboard = 4

	  ti.rclTrack.xLeft   = 0
	  ti.rclTrack.yBottom = 0
	  ti.rclTrack.xRight  = 32
	  ti.rclTrack.yTop    = 32

	  ti.rclBoundary.xLeft	 = 0
	  ti.rclBoundary.yBottom = 0
	  ti.rclBoundary.xRight  = 640
	  ti.rclBoundary.yTop	 = 480

	  ti.ptlMinTrackSize.x = 2
	  ti.ptlMinTrackSize.y = 2

	  ti.ptlMaxTrackSize.x = 512
	  ti.ptlMaxTrackSize.y = 512

	  ti.fs = TFMOVE OR TFSTANDARD
	END IF

	'*** Track rectangle and print new location to file

	bool% = WinTrackRect (HWNDDESKTOP, 0, MakeLong(VARSEG(ti), VARPTR(ti)))
        PRINT #1, "("; ti.rclTrack.xLeft;  ","; ti.rclTrack.yBottom; ") - ";
        PRINT #1, "("; ti.rclTrack.xRight; ","; ti.rclTrack.yTop;    ")"
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
