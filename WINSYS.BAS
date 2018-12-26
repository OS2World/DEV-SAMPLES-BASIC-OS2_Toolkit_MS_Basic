'***********************************************************
'* 
'* Program Name: WinSys.BAS
'*
'* Include File: WinSys.BI
'*
'* Functions   :
'*               WinQuerySysValue
'*               WinSetSysValue
'*               WinQuerySysColor
'*               WinSetSysColors
'*
'* Description : This is a test of the WinSys include file.
'*               It queries and sets the system value for
'*               double-click and the system colors for 
'*               frame and background.
'***********************************************************

'*********         Initialization section        ***********

REM $INCLUDE: 'PMBase.BI'
REM $INCLUDE: 'WinSys.BI'
REM $INCLUDE: 'GpiColor.BI'    Needed for LCOLFINDRGB constant

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
             MakeLong(VARSEG(flFrameFlags&),  VARPTR(flFrameFlags&)),_
             MakeLong(VARSEG(szClientClass$), SADD(szClientClass$)),_
             0,_
             0,_
             0,_
             0,_
             MakeLong(VARSEG(hwndClient&), VARPTR(hwndClient&)))

'**************         Sys Calls         *****************

' get original and set new double-click with WinxxxxSysValue

ClickSpeed& = WinQuerySysValue&(HWNDDESKTOP,SVDBLCLKTIME)
bool%       = WinSetSysValue   (HWNDDESKTOP,SVDBLCLKTIME,5000)

' get original colors for frame and background and switch

BackGround& = WinQuerySysColor(HWNDDESKTOP,SYSCLRWINDOW,0)
ForeFrame&  = WinQuerySysColor(HWNDDESKTOP,SYSCLRWINDOWFRAME,0)

bool% = WinSetSysColors(HWNDDESKTOP,  0,_
        LCOLFCONSECRGB, SYSCLRWINDOW, 1,_
        MakeLong(VARSEG(ForeFrame&),  VARPTR(ForeFrame&)))

bool% = WinSetSysColors(HWNDDESKTOP,       0,_
        LCOLFCONSECRGB, SYSCLRWINDOWFRAME, 1,_
        MakeLong(VARSEG(BackGround&),      VARPTR(BackGround&)))

'**************         Message loop         ***************

WHILE WinGetMsg(hab&, MakeLong(VARSEG(aqmsg), VARPTR(aqmsg)), 0, 0, 0)
  bool% = WinDispatchMsg(hab&, MakeLong(VARSEG(aqmsg), VARPTR(aqmsg)))
WEND

'***********         More Sys Calls         ****************

'reset values to originals

bool% = WinSetSysColors(HWNDDESKTOP,       0,_
        LCOLFCONSECRGB, SYSCLRWINDOWFRAME, 1,_
        MakeLong(VARSEG(ForeFrame&),       VARPTR(ForeFrame&)))

bool% = WinSetSysColors(HWNDDESKTOP,  0,_
        LCOLFCONSECRGB, SYSCLRWINDOW, 1,_
        MakeLong(VARSEG(BackGround&), VARPTR(BackGround&)))

bool% = WinSetSysValue (HWNDDESKTOP,SVDBLCLKTIME,ClickSpeed&)

'***********         Finalize section        ***************

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
     CASE ELSE        'Pass control to system for other messages
        ClientWndProc& = WinDefWindowProc(hwnd&, msg%, mp1&, mp2&)
     END SELECT
END FUNCTION
