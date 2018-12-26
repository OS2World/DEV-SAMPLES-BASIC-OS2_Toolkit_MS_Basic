'***********************************************************
'* 
'* Program Name: Skeleton.BAS
'*
'* Include File: PMBase.BI
'*
'* Functions   :
'*               WinInitialize
'*               WinCreateMsgQueue
'*               WinRegisterClass
'*               WinCreateStdWindow
'*               WinGetMsg
'*               WinDispatchMsg
'*               WinDestroyWindow
'*               WinDestroyMsgQueue
'*               WinTerminate
'*               WinBeginPaint
'*               WinFillRect
'*               WinEndPaint
'*               WinDefWindowProc
'*
'* Description : This is the base PM program which should be
'*               used as a skeleton for developing others.
'*               PMBase.BI contains the function, constant
'*               and type definitions necessary for every PM
'*               program, for more specialized functions,
'*               you will need other include files.
'***********************************************************

'*********         Initialization section        ***********

REM $INCLUDE: 'PMBase.BI'

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

'**************         Message loop         ***************

WHILE WinGetMsg(hab&, MakeLong(VARSEG(aqmsg), VARPTR(aqmsg)), 0, 0, 0)
  bool% = WinDispatchMsg(hab&, MakeLong(VARSEG(aqmsg), VARPTR(aqmsg)))
WEND

'***********         Finalize section        ***************

bool% = WinDestroyWindow   (hwndFrame&)
bool% = WinDestroyMsgQueue (hmq&)
bool% = WinTerminate (hab&)

END

'***********         Window procedure        ***************

FUNCTION ClientWndProc& (hwnd&, msg%, mp1&, mp2&) STATIC
     DIM ClientRect AS RECTL
     ClientWndProc& = 0
     SELECT CASE msg%
     CASE WMPAINT     'Paint the window with background color
        hps&  = WinBeginPaint(hwnd&, 0,_
                MakeLong(VARSEG(ClientRect), VARPTR(ClientRect)))
        bool% = WinFillRect  (hps&,_
                MakeLong(VARSEG(ClientRect), VARPTR(ClientRect)),0)
        bool% = WinEndPaint  (hps&)
     CASE ELSE        'Pass control to system for other messages
        ClientWndProc& = WinDefWindowProc(hwnd&, msg%, mp1&, mp2&)
     END SELECT
END FUNCTION
