'--------------------------------------------------------------
' WELCOME2.BAS -- A Program that Creates Two Top-Level Windows
'--------------------------------------------------------------
REM $INCLUDE: 'PMBase.BI'
REM $INCLUDE: 'WinFrame.BI'
REM $INCLUDE: 'WinMan1.BI'
REM $INCLUDE: 'WinPoint.BI'
REM $INCLUDE: 'GpiColor.BI'
DECLARE FUNCTION RegBas1&

DIM aqmsg AS QMSG

szClientClass1$ = "Welcome2.1" + CHR$(0)
szClientClass2$ = "Welcome2.2" + CHR$(0)

flFrameFlags& = FCFTITLEBAR	 OR FCFSYSMENU OR _
		FCFSIZEBORDER	 OR FCFMINMAX  OR _
		FCFSHELLPOSITION OR FCFTASKLIST

hab& = WinInitialize(0)
hmq& = WinCreateMsgQueue(hab&, 0)

bool% = WinRegisterClass(_
             hab&,_                             ' Anchor block handle
             MakeLong(VARSEG(szClientClass1$),_ ' Name of class being registered
                        SADD(szClientClass1$)),_
             RegBas,_                           ' Window procedure for class
             CSSIZEREDRAW,_                     ' Class style
             0)                                 ' Extra bytes to reserve

bool% = WinRegisterClass(_
             hab&,_                             ' Anchor block handle
             MakeLong(VARSEG(szClientClass2$),_ ' Name of class being registered
                        SADD(szClientClass2$)),_
             RegBas1,_                          ' Window procedure for class
             CSSIZEREDRAW,_                     ' Class style
             0)                                 ' Extra bytes to reserve

hwndFrame1& = WinCreateStdWindow (_
              HWNDDESKTOP,_                      ' Parent window handle
              WSVISIBLE,_                        ' Style of frame window
              MakeLong (VARSEG(flFrameFlags&),_  ' Pointer to control data
                        VARPTR(flFrameFlags&)),_
              MakeLong (VARSEG(szClientClass1$),_' Client window class name
                          SADD(szClientClass1$)),_
              0,_                                ' Title bar text
              0,_                                ' Style of client window
              0,_                                ' Module handle for resources
              0,_                                ' ID of resources
              MakeLong (VARSEG(hwndClient1&),_   ' Pointer to client window handle
                        VARPTR(hwndClient1&)))

hwndFrame2& = WinCreateStdWindow (_
              HWNDDESKTOP,_                      ' Parent window handle
              WSVISIBLE,_                        ' Style of frame window
              MakeLong (VARSEG(flFrameFlags&),_  ' Pointer to control data
                        VARPTR(flFrameFlags&)),_
              MakeLong (VARSEG(szClientClass2$),_' Client window class name
                          SADD(szClientClass2$)),_
              0,_                                ' Title bar text
              0,_                                ' Style of client window
              0,_                                ' Module handle for resources
              0,_                                ' ID of resources
              MakeLong (VARSEG(hwndClient2&),_   ' Pointer to client window handle
                        VARPTR(hwndClient2&)))

bool% = WinSendMsg(hwndFrame1&, WMSETICON,_
		     WinQuerySysPointer(HWNDDESKTOP, SPTRAPPICON, FALSE),_
		     0)

bool% = WinSendMsg(hwndFrame2&, WMSETICON,_
		     WinQuerySysPointer(HWNDDESKTOP, SPTRAPPICON, FALSE),_
		     0)

WHILE (WinGetMsg(hab&, MakeLong(VARSEG(aqmsg), VARPTR(aqmsg)), 0, 0, 0))
  bool% = WinDispatchMsg(hab&, MakeLong(VARSEG(aqmsg), VARPTR(aqmsg)))
WEND

bool% = WinDestroyWindow(hwndFrame1&)
bool% = WinDestroyWindow(hwndFrame2&)
bool% = WinDestroyMsgQueue(hmq&)
bool% = WinTerminate(hab&)

END

FUNCTION ClientWndProc&(hwnd&, msg%, mp1&, mp2&)
     szText$ = "Welcome to Window No. 1" + CHR$(0)
     DIM rcl AS RECTL

     ClientWndProc& = 0
     SELECT CASE msg%
	CASE WMPAINT
	    hps& = WinBeginPaint(hwnd&, 0, 0)
            bool% = WinQueryWindowRect(hwnd&, MakeLong(VARSEG(rcl), VARPTR(rcl)))
            bool% = WinDrawText(hps&,_
                                -1,_
                                MakeLong(VARSEG(szText$), SADD(szText$)),_
                                MakeLong(VARSEG(rcl), VARPTR(rcl)),_
                                CLRNEUTRAL,_
                                CLRBACKGROUND,_
                                DTCENTER OR DTVCENTER OR DTERASERECT)
            bool% = WinEndPaint(hps&)
	CASE ELSE
            ClientWndProc& = WinDefWindowProc(hwnd&, msg%, mp1&, mp2&)
	END SELECT
END FUNCTION

FUNCTION ClientWndProc1&(hwnd&, msg%, mp1&, mp2&)
     szText$ = "Welcome to Window No. 2" + CHR$(0)
     DIM rcl AS RECTL

     ClientWndProc1& = 0
     SELECT CASE msg%
	CASE WMPAINT
	    hps& = WinBeginPaint(hwnd&, 0, 0)
            bool% = WinQueryWindowRect(hwnd&, MakeLong(VARSEG(rcl), VARPTR(rcl)))
            bool% = WinDrawText(hps&,_
                                -1,_
                                MakeLong(VARSEG(szText$), SADD(szText$)),_
                                MakeLong(VARSEG(rcl), VARPTR(rcl)),_
                                CLRNEUTRAL,_
                                CLRBACKGROUND,_
                                DTCENTER OR DTVCENTER OR DTERASERECT)
            bool% = WinEndPaint(hps&)
        CASE WMCLOSE
            REM
	CASE ELSE
            ClientWndProc1& = WinDefWindowProc(hwnd&, msg%, mp1&, mp2&)
	END SELECT
END FUNCTION
