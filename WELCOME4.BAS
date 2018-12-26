'------------------------------------------------------------------------------
' WELCOME4.BAS -- A Program that Creates a Top-Level Window and Three Children
'------------------------------------------------------------------------------
REM $INCLUDE: 'PMBase.BI'
REM $INCLUDE: 'OS2Def.BI'
REM $INCLUDE: 'WinFrame.BI'
REM $INCLUDE: 'WinMan1.BI'
REM $INCLUDE: 'WinPoint.BI'
REM $INCLUDE: 'WinButtn.BI'
REM $INCLUDE: 'WinMisc.BI'
REM $INCLUDE: 'WinEntry.BI'
REM $INCLUDE: 'WinDialg.BI'
REM $INCLUDE: 'GpiColor.BI'

CONST IDBUTTON = 1
CONST IDSCROLL = 2
CONST IDENTRY  = 3

DIM aqmsg AS QMSG
DIM rcl AS RECTL

szClientClass$ = "Welcome4" + CHR$(0)

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

    '--------------------------------------------------------
    ' Find dimensions of client window for sizes of children
    '--------------------------------------------------------

bool% = WinQueryWindowRect (hwndClient&, MakeLong(VARSEG(rcl), VARPTR(rcl)))
rcl.xRight = rcl.xRight \ 3                      ' divide width in thirds

    '---------------------------
    ' Create push button window
    '---------------------------

button$ = "Big Button" + CHR$(0)
bool% = WinCreateWindow (_
           hwndClient&,_                             ' Parent window handle
           WCBUTTON,_                                ' Window class
           MakeLong(VARSEG(button$), SADD(button$)),_' Window text
           WSVISIBLE OR BSPUSHBUTTON,_               ' Window style
           10,_                                      ' Window position
           10,_
           rcl.xRight - 20,_                         ' Window size
           rcl.yTop - 20,_
           hwndClient&,_                             ' Owner window handle
           HWNDBOTTOM,_                              ' Placement window handle
           IDBUTTON,_                                ' Child window ID
           0,_                                       ' Control data
           0)                                        ' Presentation parameters

    '--------------------------
    ' Create scroll bar window
    '--------------------------

bool% = WinCreateWindow (_
           hwndClient&,_                             ' Parent window handle
           WCSCROLLBAR,_                             ' Window class
           0,_                                       ' Window text
           WSVISIBLE OR SBSVERT,_                    ' Window style
           rcl.xRight + 10,_                         ' Window position
           10,_
           rcl.xRight - 20,_                         ' Window size
           rcl.yTop - 20,_
           hwndClient&,_                             ' Owner window handle
           HWNDBOTTOM,_                              ' Placement window handle
           IDSCROLL,_                                ' Child window ID
           0,_                                       ' Control data
           0)                                        ' Presentation parameters

    '---------------------------
    ' Create entry field window
    '---------------------------

bool% = WinCreateWindow (_
           hwndClient&,_                             ' Parent window handle
           WCENTRYFIELD,_                            ' Window class
           0,_                                       ' Window text
           WSVISIBLE OR ESMARGIN OR ESAUTOSCROLL,_   ' Window style
           2 * rcl.xRight + 10,_                     ' Window position
           10,_
           rcl.xRight - 20,_                         ' Window size
           rcl.yTop - 20,_
           hwndClient&,_                             ' Owner window handle
           HWNDBOTTOM,_                              ' Placement window handle
           IDENTRY,_                                 ' Child window ID
           0,_                                       ' Control data
           0)                                        ' Presentation parameters

WHILE (WinGetMsg(hab&, MakeLong(VARSEG(aqmsg), VARPTR(aqmsg)), 0, 0, 0))
  bool% = WinDispatchMsg(hab&, MakeLong(VARSEG(aqmsg), VARPTR(aqmsg)))
WEND

bool% = WinDestroyWindow(hwndFrame&)
bool% = WinDestroyMsgQueue(hmq&)
bool% = WinTerminate(hab&)

END

FUNCTION ClientWndProc&(hwnd&, msg%, mp1&, mp2&)
     DIM rcl AS RECTL

     ClientWndProc& = 0
     SELECT CASE msg%
        CASE WMCOMMAND
            SELECT CASE mp1& AND 255
               CASE IDBUTTON
                   bool% = WinAlarm (HWNDDESKTOP, WANOTE)
                   EXIT FUNCTION
               CASE ELSE
            END SELECT
        CASE WMERASEBACKGROUND
            ClientWndProc& = 1
            EXIT FUNCTION
        CASE ELSE
     END SELECT
     ClientWndProc& = WinDefWindowProc(hwnd&, msg%, mp1&, mp2&)
END FUNCTION
