'----------------------------------------------------------------------------
' WELCOME3.BAS -- A Program that Creates a Top-Level Window and Two Children
'----------------------------------------------------------------------------
REM $INCLUDE: 'PMBase.BI'
REM $INCLUDE: 'OS2Def.BI'
REM $INCLUDE: 'WinFrame.BI'
REM $INCLUDE: 'WinMan1.BI'
REM $INCLUDE: 'WinMan2.BI'
REM $INCLUDE: 'WinPoint.BI'
REM $INCLUDE: 'GpiColor.BI'
DECLARE FUNCTION RegBas1&

DIM aqmsg AS QMSG

szClientClass$ = "Welcome3" + CHR$(0)
szChildClass$  = "Welcome3.Child" + CHR$(0)

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
             CSSIZEREDRAW,_                     ' Class style
             0)                                 ' Extra bytes to reserve

bool% = WinRegisterClass(_
             hab&,_                             ' Anchor block handle
             MakeLong(VARSEG(szChildClass$),_   ' Name of class being registered
                        SADD(szChildClass$)),_
             RegBas1,_                          ' Window procedure for class
             CSSIZEREDRAW,_                     ' Class style
             4)                                 ' Extra bytes to reserve

    '-------------------------
    ' Create top-level window
    '-------------------------

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

    '--------------------------
    ' Create two child windows
    '--------------------------

flFrameFlags& = flFrameFlags& AND NOT(FCFTASKLIST)

name1$ = "Child No. 1" + CHR$(0)
hwndChildFrame1& = WinCreateStdWindow (_
             hwndClient&,_                      ' Parent window handle
             WSVISIBLE,_                        ' Style of frame window
             MakeLong (VARSEG(flFrameFlags&),_  ' Pointer to control data
                       VARPTR(flFrameFlags&)),_
             MakeLong (VARSEG(szChildClass$),_  ' Client window class name
                         SADD(szChildClass$)),_
             MakeLong (VARSEG(name1$),_         ' Title bar text
                         SADD(name1$)),_
             0,_                                ' Style of client window
             0,_                                ' Module handle for resources
             0,_                                ' ID of resources
             MakeLong(VARSEG(hwndChildClient1&),_' Pointer to client window handle
                      VARPTR(hwndChildClient1&)))

name2$ = "Child No. 2" + CHR$(0)
hwndChildFrame2& = WinCreateStdWindow (_
             hwndClient&,_                      ' Parent window handle
             WSVISIBLE,_                        ' Style of frame window
             MakeLong (VARSEG(flFrameFlags&),_  ' Pointer to control data
                       VARPTR(flFrameFlags&)),_
             MakeLong (VARSEG(szChildClass$),_  ' Client window class name
                         SADD(szChildClass$)),_
             MakeLong (VARSEG(name2$),_         ' Title bar text
                         SADD(name2$)),_
             0,_                                ' Style of client window
             0,_                                ' Module handle for resources
             0,_                                ' ID of resources
             MakeLong(VARSEG(hwndChildClient2&),_' Pointer to client window handle
                      VARPTR(hwndChildClient2&)))

bool% = WinSendMsg(hwndChildFrame1&, WMSETICON,_
		     WinQuerySysPointer(HWNDDESKTOP, SPTRAPPICON, FALSE),_
		     0)

bool% = WinSendMsg(hwndChildFrame2&, WMSETICON,_
		     WinQuerySysPointer(HWNDDESKTOP, SPTRAPPICON, FALSE),_
		     0)

    '-----------------------------------------------------
    ' Set reserved area of window to text string pointers
    '-----------------------------------------------------

msg1$ = "I'm a child ..."+CHR$(0)
bool% = WinSetWindowPtr(hwndChildClient1&, QWLUSER, MakeLong(VARSEG(msg1$),SADD(msg1$)))
msg2$ = "... Me too!"+CHR$(0)
bool% = WinSetWindowPtr(hwndChildClient2&, QWLUSER, MakeLong(VARSEG(msg2$),SADD(msg2$)))

WHILE (WinGetMsg(hab&, MakeLong(VARSEG(aqmsg), VARPTR(aqmsg)), 0, 0, 0))
  bool% = WinDispatchMsg(hab&, MakeLong(VARSEG(aqmsg), VARPTR(aqmsg)))
WEND

bool% = WinDestroyWindow(hwndFrame&)
bool% = WinDestroyMsgQueue(hmq&)
bool% = WinTerminate(hab&)

END

FUNCTION ClientWndProc&(hwnd&, msg%, mp1&, mp2&)
     szText$ = "I'm the parent of two children" + CHR$(0)
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
     DIM rcl AS RECTL

     ClientWndProc1& = 0
     SELECT CASE msg%
	CASE WMPAINT
	    hps& = WinBeginPaint(hwnd&, 0, 0)
            bool% = WinQueryWindowRect(hwnd&, MakeLong(VARSEG(rcl), VARPTR(rcl)))
            bool% = WinDrawText(hps&,_
                                -1,_
                                WinQueryWindowPtr(hwnd&, QWLUSER),_
                                MakeLong(VARSEG(rcl), VARPTR(rcl)),_
                                CLRNEUTRAL,_
                                CLRBACKGROUND,_
                                DTCENTER OR DTVCENTER OR DTERASERECT)
            bool% = WinEndPaint(hps&)
        CASE WMCLOSE
            bool% = WinDestroyWindow (WinQueryWindow (hwnd&, QWPARENT, FALSE))
	CASE ELSE
            ClientWndProc1& = WinDefWindowProc(hwnd&, msg%, mp1&, mp2&)
	END SELECT
END FUNCTION
