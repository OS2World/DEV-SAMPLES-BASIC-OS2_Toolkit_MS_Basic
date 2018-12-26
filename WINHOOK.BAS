'***********************************************************
'* 
'* Program Name: WinHook.BAS
'*
'* Include File: WinHook.BI
'*
'* Functions   :
'*               WinSetHook
'*               WinCallMsgFilter
'*               WinReleaseHook
'*
'* Description : This program demonstrates the hook functions.
'*
'*               A message filter hook is created with
'*               WinSetHook and is processed in the FUNCTION
'*               MsgFilterHook.  The function pointer for
'*               WinSetHook is returned from RegMsgFilterHook.
'*
'*               WinCallMsgFilter is used in the message loop
'*               to filter messages through MsgFilterHook.
'*
'*               MsgFilterHook simply writes "Message filtered"
'*               to the file, WinHook.OUT.
'*
'*               Finally, the hook is released with
'*               WinReleaseHook.
'*
'*               This program only demonstrates the calls to the
'*               various hook functions.  For more information
'*               on using hooks, see Chapter 28 of "OS/2
'*               Programmer's Reference, Volume 1".
'***********************************************************

'*********         Initialization section        ***********

REM $INCLUDE: 'PMBase.BI'
REM $INCLUDE: 'WinHook.BI'
DECLARE FUNCTION RegMsgFilterHook&

OPEN "WinHook.OUT" FOR OUTPUT AS #1
DIM aqmsg AS QMSG

flFrameFlags& =  FCFTITLEBAR      OR FCFSYSMENU OR _
                 FCFSIZEBORDER    OR FCFMINMAX  OR _
                 FCFSHELLPOSITION OR FCFTASKLIST

szClientClass$ = "ClassName" + CHR$(0)

hab&  = WinInitialize    (0)
hmq&  = WinCreateMsgQueue(hab&, 0)

'**** Set message filter hook
bool% = WinSetHook(hab&, hmq&, HKMSGFILTER, RegMsgFilterHook, 0)
PRINT #1, "WinSetHook:", bool%

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
  '**** If message not filtered, dispatch to window procedure
  IF NOT(WinCallMsgFilter(hab&, MakeLong(VARSEG(aqmsg), VARPTR(aqmsg)), 0)) THEN
    bool% = WinDispatchMsg(hab&, MakeLong(VARSEG(aqmsg), VARPTR(aqmsg)))
  END IF
WEND

'***********         Finalize section        ***************

bool% = WinDestroyWindow   (hwndFrame&)

'**** Release message filter hook
bool% = WinReleaseHook(hab&, hmq&, HKMSGFILTER, RegMsgFilterHook, 0)
PRINT #1, "WinReleaseHook:", bool%

bool% = WinDestroyMsgQueue (hmq&)
bool% = WinTerminate (hab&)

CLOSE #1

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


'***************** Message Filter Hook Function *******************

FUNCTION MsgFilterHook%(hab&, msgf%, pqmsg&) STATIC
    PRINT #1, "Message filtered"
END FUNCTION
