'************************************************************************
'* 
'* Program Name: WinHeap.BAS
'*
'* Include File: WinMisc.BI
'*
'* Functions   :
'*               WinCreateHeap
'*               WinDestroyHeap
'*               WinAvailMem
'*               WinAllocMem
'*               WinReallocMem
'*               WinFreeMem
'*               WinLockMem
'*
'* Description : This program demonstrates allocating memory using
'*               the heap functions provided with the Presentation
'*               Manager. The allocated memory information is written
'*               to a data file called "WinHeap.OUT".
'************************************************************************

'*********         Initialization section        ***********

REM $INCLUDE: 'PMBase.BI'
REM $INCLUDE: 'WinMisc.BI'
CONST TRUE = 1
CONST KByte = 1024

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

'**************       WinHeap        **************

OPEN "WinHeap.OUT" FOR OUTPUT AS #1

' Creating heap of 16K
     hHeap& = WinCreateHeap(0,16*KByte,2*KByte,0,0,HMVALIDSIZE OR HMMOVEABLE)
     Avail% = WinAvailMem  (hHeap&,TRUE,0)
     PRINT #1,"Available Memory after WinCreateHeap:  ";HEX$(Avail%)

' Allocating 1K block on heap
     Alloc% = WinAllocMem(hHeap&,KByte)
     Avail% = WinAvailMem(hHeap&,TRUE,0)
     PRINT #1,"Available Memory after WinAllocMem 1024 bytes:  ";HEX$(Avail%)

' Reallocating block to 1/2K
     RAlloc%= WinReallocMem(hHeap&,Alloc%,KByte,KByte/2)
     Avail% = WinAvailMem  (hHeap&,TRUE,0)
     PRINT #1,"Available Memory after WinReallocMem 1024 to 512 bytes: ";HEX$(Avail%)

' Freeing up 1/2K block of heap
     Free%    = WinFreeMem (hHeap&,Alloc%,KByte/2)
     Avail%   = WinAvailMem(hHeap&,TRUE,0)
     PRINT #1,"Available Memory after WinFreeMem 512 bytes:  ";HEX$(Avail%)

'Locking and getting Address of heap
     WLock& = WinLockHeap(hHeap&)
     PRINT #1,"Address of beginning of the heap after WinLockHeap: ";HEX$(WLock&)

' Destroying the 16K heap
     hHeap& = WinDestroyHeap(hHeap&)
     Avail% = WinAvailMem   (hHeap&,TRUE,16*KByte)
     PRINT #1,"Available Memory after WinDestroyHeap:  ";Avail%

CLOSE #1

'**************         Message loop         ***************

WHILE WinGetMsg(hab&, MakeLong(VARSEG(aqmsg), VARPTR(aqmsg)), 0, 0, 0)
  bool% = WinDispatchMsg(hab&, MakeLong(VARSEG(aqmsg), VARPTR(aqmsg)))
WEND

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
     CASE ELSE	      'Pass control to system for other messages
        ClientWndProc& = WinDefWindowProc(hwnd&, msg%, mp1&, mp2&)
     END SELECT
END FUNCTION
