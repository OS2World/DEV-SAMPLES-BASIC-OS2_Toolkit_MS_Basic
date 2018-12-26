'-------------------------------------------------------
' WELCOME.BAS -- A Program that Creates a Client Window
'-------------------------------------------------------
REM $INCLUDE: 'PMBase.BI'
REM $INCLUDE: 'WinFrame.BI'
REM $INCLUDE: 'WinPoint.BI'

DIM aqmsg AS QMSG

szClientClass$ = "Welcome" + CHR$(0)

flFrameFlags& = FCFTITLEBAR	 OR FCFSYSMENU OR _
		FCFSIZEBORDER	 OR FCFMINMAX  OR _
		FCFSHELLPOSITION OR FCFTASKLIST

hab& = WinInitialize(0)
hmq& = WinCreateMsgQueue(hab&, 0)

bool% = WinRegisterClass(_
             hab&,_                             ' Anchor block handle
             MakeLong(VARSEG(szClientClass$),_  ' Name of class being registered
                        SADD(szClientClass$)),_
             RegBas,_                           ' Window procedure for class
             0,_                                ' Class style
             0)                                 ' Extra bytes to reserve

hwndFrame& = WinCreateStdWindow (_
             HWNDDESKTOP,_                      ' Parent window handle
             WSVISIBLE,_                        ' Style of frame window
             MakeLong (VARSEG(flFrameFlags&),_  ' Pointer to control data
                       VARPTR(flFrameFlags&)),_
             MakeLong (VARSEG(szClientClass$),_ ' Client window class name
                         SADD(szClientClass$)),_
             0,_                                ' Title bar text
             0,_                                ' Style of client window
             0,_                                ' Module handle for resources
             0,_                                ' ID of resources
             MakeLong (VARSEG(hwndClient&),_    ' Pointer to client window handle
                       VARPTR(hwndClient&)))

bool% = WinSendMsg(hwndFrame&, WMSETICON,_
		    WinQuerySysPointer(HWNDDESKTOP, SPTRAPPICON, FALSE),_
		    0)

WHILE (WinGetMsg(hab&, MakeLong(VARSEG(aqmsg), VARPTR(aqmsg)), 0, 0, 0))
  bool% = WinDispatchMsg(hab&, MakeLong(VARSEG(aqmsg), VARPTR(aqmsg)))
WEND

bool% = WinDestroyWindow(hwndFrame&)
bool% = WinDestroyMsgQueue(hmq&)
bool% = WinTerminate(hab&)

END

FUNCTION ClientWndProc&(hwnd&, msg%, mp1&, mp2&)
     ClientWndProc& = WinDefWindowProc(hwnd&, msg%, mp1&, mp2&)
END FUNCTION
