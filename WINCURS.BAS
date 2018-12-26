'************************************************************************
'* 
'* Program Name: WinCurs.BAS
'*
'* Include File: WinMisc.BI
'*
'* Functions   :
'*               WinCreateCursor
'*               WinDestroyCursor
'*               WinShowCursor
'*               WinQueryCursorInfo
'*
'* Description : This is a PM program which demonstrates
'*               the use of WinCreateCursor, WinShowCursor,
'*               WinDestroyCursor and WinQueryCursorInfo. The
'*               program displays a cursor in the current window
'*               that is proportional to the window size in the
'*               center of the window.  When the size of the window
'*               is adjusted the cursor information is written to an
'*               output file called "WinCurs.OUT".
'*
'************************************************************************

'*********         Initialization section        ***********

REM $INCLUDE: 'PMBase.BI'
REM $INCLUDE: 'WinMisc.BI'

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
        CSSIZEREDRAW,_
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


    OPEN "WinCurs.OUT" FOR OUTPUT AS #1

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
     DIM Cursor AS CURSORINFO
     ClientWndProc& = 0
     SELECT CASE msg%
     CASE WMPAINT     'Paint the window with background and place cursor
        hps&  = WinBeginPaint(hwnd&, 0,_
		MakeLong(VARSEG(ClientRect), VARPTR(ClientRect)))

'*** WinDestroyCursor destroys previous cursor before window is repainted

	bool% = WinDestroyCursor(hwnd&)

        bool% = WinFillRect(hps&,_
		MakeLong(VARSEG(ClientRect), VARPTR(ClientRect)),0)

'*** Compute center of window and make size proprotional to window size

        x&  = (ClientRect.xLeft + ClientRect.xRight) / 2   'Center
        y&  = (ClientRect.yBottom + ClientRect.yTop) / 2
	cx& = x& / 10					   'Proportional
	cy& = y& / 10

'*** Create and Show cursor

        bool% = WinCreateCursor(hwnd&, x&, y&, cx&, cy&,CURSORFLASH,0)
	bool% = WinShowCursor(hwnd&,1)

'*** Get cursor info and print to file

	bool% = WinQueryCursorInfo(HWNDDESKTOP,_
                MakeLong(VARSEG(cursor),VARPTR(cursor)))
	print #1,"Position: (";cursor.x;",";cursor.y;")"
	print #1,"Size: (";cursor.cx;",";cursor.cy;")"
	print #1,"Flags:";HEX$(cursor.fs)
	print #1,"-----------------------------"

        bool% = WinEndPaint(hps&)

     CASE ELSE	      'Pass control to system for other messages
        ClientWndProc& = WinDefWindowProc(hwnd&, msg%, mp1&, mp2&)
     END SELECT
END FUNCTION
