'***********************************************************
'* 
'* Program Name: WinFrame.BAS
'*
'* Include File: WinFrame.BI
'*
'* Functions   :
'*               WinCreateFrameControls
'*               WinFlashWindow
'*               WinCalcFrameRect
'*               WinGetMaxPosition
'*               WinGetMinPosition
'*               WinFormatFrame
'*
'* Description : This program demonstrates the functions 
'*               contained in the WinFrame.BI include file.
'*               Because many of the calls do not cause an
'*               obvious change to the window, some 
'*               information is written to the file, 
'*               WinFrame.OUT.
'***********************************************************

'*********         Initialization section        ***********

REM $INCLUDE: 'PMBase.BI'
REM $INCLUDE: 'OS2Def.BI'
REM $INCLUDE: 'WinMan1.BI'
REM $INCLUDE: 'WinFrame.BI'

DIM aqmsg                              AS QMSG
DIM aswp                               AS SWP
DIM swparr(FIDCLIENT - FIDSYSMENU + 1) AS SWP
DIM FrameRect                          AS RECTL
DIM afcd                               AS FRAMECDATA

OPEN "WinFrame.OUT" FOR OUTPUT AS #1

flFrameflags& =  FCFSYSMENU       OR_
                 FCFSIZEBORDER    OR FCFMINMAX OR_
                 FCFSHELLPOSITION OR FCFTASKLIST

szClientClass$ = "ClassName" + CHR$(0)

hab&  = WinInitialize    (0)
hmq&  = WinCreateMsgQueue(hab&, 0)

bool% = WinRegisterClass(hab&,_
        MakeLong(VARSEG(szClientClass$), SADD(szClientClass$)),_
        RegBas, 0, 0)

hwndFrame& = WinCreateStdWindow(_
             HWNDDESKTOP,_
             WSINVISIBLE,_
             MakeLong(VARSEG(flFrameflags&),  VARPTR(flFrameflags&)),_
             MakeLong(VARSEG(szClientClass$), SADD(szClientClass$)),_
             0, 0, 0, 0,_
             MakeLong(VARSEG(hwndClient&),    VARPTR(hwndClient&)))

'*********         Frame function calls         ************

'The call below to WinCreateFrameControls sets title bar

titlebar$          = "NewTitle" + CHR$(0)
afcd.cb            = 10
afcd.flCreateFlags = FCFTITLEBAR
bool% = WinCreateFrameControls(     hwndFrame&,_
        MakeLong(VARSEG(afcd),      VARPTR(afcd)),_
        MakeLong(VARSEG(titlebar$), SADD(titlebar$)))
bool% = WinShowWindow (hwndFrame&, 1)

bool% = WinFlashWindow(hwndFrame&, 1)  'Causes window to flash

' The following calls set and check various positions on 

bool% = WinCalcFrameRect(hwndFrame&,_
        MakeLong(VARSEG(FrameRect), VARPTR(FrameRect)), 0)
  PRINT #1, "WinCalcFrameRect:";
  PRINT #1, "("; FrameRect.xLeft;  ","; FrameRect.yBottom; ")-";
  PRINT #1, "("; FrameRect.xRight; ","; FrameRect.yTop;    ")"

bool% = WinSetWindowPos  (hwndFrame&, 0, 0, 0, 0, 0, SWPMAXIMIZE)
bool% = WinGetMaxPosition(hwndFrame&,_
        MakeLong(VARSEG(aswp), VARPTR(aswp)))
  PRINT #1, "WinGetMaxPosition:"
  PRINT #1, aswp.fs,
  PRINT #1, "("; aswp.x;  ","; aswp.y;  ")",
  PRINT #1, "("; aswp.cx; ","; aswp.cy; ")"

bool% = WinSetWindowPos  (hwndFrame&, 0, 0, 0, 0, 0, SWPMINIMIZE)
bool% = WinGetMinPosition(hwndFrame&,_
        MakeLong(VARSEG(aswp), VARPTR(aswp)), 0)
  PRINT #1, "WinGetMinPosition:"
  PRINT #1, aswp.fs,
  PRINT #1, "("; aswp.x;  ","; aswp.y;  ")",
  PRINT #1, "("; aswp.cx; ","; aswp.cy; ")"

bool% = WinSetWindowPos(hwndFrame&, 0, 0, 0, 0, 0, SWPRESTORE)
bool% = WinFormatFrame(_
     hwndFrame&,_
     MakeLong(VARSEG(FrameRect),   VARPTR(FrameRect)),_
     MakeLong(VARSEG(swparr(0)),   VARPTR(swparr(0))),_
     FIDCLIENT - FIDSYSMENU + 1,_
     MakeLong(VARSEG(hwndClient&), VARPTR(hwndClient&)))
  PRINT #1, "WinFormatFrame:"
  FOR i% = 0 TO FIDCLIENT - FIDSYSMENU + 1
    PRINT #1, swparr(i%).fs,
    PRINT #1, "("; swparr(i%).x;  ","; swparr(i%).y;  ")",
    PRINT #1, "("; swparr(i%).cx; ","; swparr(i%).cy; ")"
  NEXT i%

'*************         Message loop          ***************

WHILE (WinGetMsg(hab&, MakeLong(VARSEG(aqmsg), VARPTR(aqmsg)), 0, 0, 0))
  bool% = WinDispatchMsg(hab&, MakeLong(VARSEG(aqmsg), VARPTR(aqmsg)))
WEND

'*************         Finalize section         ************

bool% = WinDestroyWindow   (hwndFrame&)
bool% = WinDestroyMsgQueue (hmq&)
bool% = WinTerminate       (hab&)

END

'***********         Window procedure          *************

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
