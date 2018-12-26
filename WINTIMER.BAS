'************************************************************************
'* 
'* Program Name: WinTimer.BAS
'*
'* Include File: WinMisc.BI
'*
'* Functions   :
'*               WinStartTimer
'*               WinStopTimer
'*               WinGetCurrentTime
'*
'* Description : This is a PM program which demonstrates
'*               the use of WinStartTimer, WinStopTimer and
'*               WinGetCurrentTime.  The program monitors sets a
'*               time out for every second (1000 milliseconds). When
'*               a time out occurs, a WMTIMER message is sent and
'*               the current time (from WinGetCurrentTime) is written
'*               to a file ("WinTimer.OUT")
'*
'************************************************************************

'*********         Initialization section        ***********

REM $INCLUDE: 'PMBase.BI'
REM $INCLUDE: 'WinMisc.BI'

CONST IDTIMER = 1     ' Constant for WinStartTimer, WinStopTimer

DIM aqmsg AS QMSG
DIM SHARED hab&

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

'***********          WinStartTimer          ***************

    OPEN "WinTimer.OUT" FOR OUTPUT AS #1
    bool% = WinStartTimer(hab&, hwndClient&, IDTIMER, 1000)

'**************         Message loop         ***************

WHILE WinGetMsg(hab&, MakeLong(VARSEG(aqmsg), VARPTR(aqmsg)), 0, 0, 0)
  bool% = WinDispatchMsg(hab&, MakeLong(VARSEG(aqmsg), VARPTR(aqmsg)))
WEND

'***********          WinStopTimer          ***************

    bool% = WinStopTimer(hab&, hwndClient&, IDTIMER)
    CLOSE #1

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
     CASE WMTIMER      'Occurs every second (1000 milliseconds)
	CurrTime& = WinGetCurrentTime(hab&)
        PRINT #1,  "WinGetCurrentTime:", CurrTime&
     CASE ELSE	      'Pass control to system for other messages
        ClientWndProc& = WinDefWindowProc(hwnd&, msg%, mp1&, mp2&)
     END SELECT
END FUNCTION
