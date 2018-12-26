'--------------------------------------------
' WELCO.BAS -- A Program with a Message Loop
'--------------------------------------------
REM $INCLUDE: 'PMBase.BI'

DIM aqmsg AS QMSG

flFrameFlags& = FCFTITLEBAR	 OR FCFSYSMENU OR _
		FCFSIZEBORDER	 OR FCFMINMAX  OR _
		FCFSHELLPOSITION OR FCFTASKLIST

hab& = WinInitialize(0)
hmq& = WinCreateMsgQueue(hab&, 0)

hwndFrame& = WinCreateStdWindow (_
             HWNDDESKTOP,_                     ' Parent window handle
             WSVISIBLE,_                       ' Style of frame window
             MakeLong (VARSEG(flFrameFlags&),_ ' Pointer to control data
                       VARPTR(flFrameFlags&)),_
             0,_                               ' Client window class name
             0,_                               ' Title bar text
             0,_                               ' Style of client window
             0,_                               ' Module handle for resources
             0,_                               ' ID of resources
             0)                                ' Pointer to client window handle

WHILE (WinGetMsg(hab&, MakeLong(VARSEG(aqmsg), VARPTR(aqmsg)), 0, 0, 0))
  bool% = WinDispatchMsg(hab&, MakeLong(VARSEG(aqmsg), VARPTR(aqmsg)))
WEND

bool% = WinDestroyWindow(hwndFrame&)
bool% = WinDestroyMsgQueue(hmq&)
bool% = WinTerminate(hab&)

END


'*** ClientWndProc needed to eliminate unresolved externals from REGBAS.LIB
FUNCTION ClientWndProc&(hwnd&, msg%, mp1&, mp2&)
END FUNCTION
