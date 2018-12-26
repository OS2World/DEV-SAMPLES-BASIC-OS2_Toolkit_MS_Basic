'***********************************************************
'* 
'* Program Name: WinRect.BAS
'*
'* Include File: WinRect.BI
'*
'* Functions   :
'*               WinIsRectEmpty
'*               WinSetRect
'*               WinCopyRect
'*               WinEqualRect
'*               WinOffsetRect
'*               WinIntersectRect
'*               WinUnionRect
'*               WinSubtractRect
'*               WinInflateRect
'*               WinSetRectEmpty
'*               WinMakeRect        Not demonstrated
'*               WinMakePoints      Not demonstrated
'*
'* Description : This program demonstrates the rectangle
'*               utility routines built into the Presentation
'*               Manager.  Due to the nature of these calls
'*               (they have no visible effect), each function
'*               is called (in a logical order) and the resulting
'*               information is written to the file "WinRect.OUT".
'*               Since all these routines use the RECTL type,
'*               two routines (1 SUB, 1 FUNCTION) are written
'*               to shorten repetitive code for printing and
'*               getting addresses. WinMakeRect and WinMakePoints
'*               are not demonstarted because they convert from
'*               the WRECT and WPOINT types which are not used
'*               for any existing PM calls.  For this same
'*               reason, these functions have been left out of
'*               "OS/2 Programmer's Reference" Version 1.1.
'***********************************************************

'*********         Initialization section        ***********

REM $INCLUDE: 'PMBase.BI'
REM $INCLUDE: 'OS2Def.BI'     Needed for POINTL
REM $INCLUDE: 'WinRect.BI'

DECLARE FUNCTION Addr&(Rect AS RECTL)	  'MakeLong(VARSEG(),VARPTR())
DECLARE SUB PrintRect(Rect AS RECTL)	  '(L,B)-(R,T)

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

'**************      Rectangle utilities       ***************

'*****
'*** Order of calls is as follows:
'***      1.  WinIsRectEmpty
'***      2.  WinRectEmpty
'***      3.  WinIsRectEmpty
'***      4.  WinPtInRect
'***      5.  WinCopyRect
'***      6.  WinEqualRect
'***      7.  WinOffsetRect
'***      8.  WinEqualRect
'***      9.  WinIntersectRect
'***      10. WinUnionRect
'***      11. WinSubtractRect
'***      12. WinInflateRect
'***      13. WinSetRectEmpty
'***      14. WinIsRectEmpty

OPEN "WinRect.OUT" FOR OUTPUT AS #1

  DIM Rect1 AS RECTL, Rect2 AS RECTL, Rect3 AS RECTL
  DIM Pt AS POINTL

'***      1.  WinIsRectEmpty
  empty%    = WinIsRectEmpty (hab&, Addr(Rect1))
  PRINT #1,  "WinIsRectEmpty:", empty%           'Yes (1)
  CALL PrintRect(Rect1)                          '( 0, 0)-( 0, 0)

'***      2.  WinRectEmpty
  set%      = WinSetRect (hab&, Addr(Rect1), 10, 20, 30, 40)
  PRINT #1,  "WinSetRect:", set%
  CALL PrintRect(Rect1) 			'(10,20)-(30,40)

'***      3.  WinIsRectEmpty
  empty%    = WinIsRectEmpty (hab&, Addr(Rect1))
  PRINT #1,  "WinIsRectEmpty:", empty%          'No (0)
  CALL PrintRect(Rect1) 			'(10,20)-(30,40)

'***      4.  WinPtInRect
  Pt.x = 20
  Pt.y = 30
  ptIn%     = WinPtInRect (hab&, Addr(Rect1), MakeLong(VARSEG(Pt), VARPTR(Pt)))
  PRINT #1,  "WinPtInRect:", ptIn%              'Yes (1)
  PRINT #1,  "(";Pt.x;",";Pt.y;")"              '(20,30)
  CALL PrintRect(Rect1) 			'(10,20)-(30,40)

'***      5.  WinCopyRect
  copy%     = WinCopyRect (hab&, Addr(Rect2), Addr(Rect1))
  PRINT #1,  "WinCopyRect:", copy%
  CALL PrintRect(Rect1) 			'(10,20)-(30,40)
  CALL PrintRect(Rect2) 			'(10,20)-(30,40)

'***      6.  WinEqualRect
  equal%    = WinEqualRect (hab&, Addr(Rect1), Addr(Rect2))
  PRINT #1,  "WinEqualRect:", equal%            'Yes (1)
  CALL PrintRect(Rect1) 			'(10,20)-(30,40)
  CALL PrintRect(Rect2) 			'(10,20)-(30,40)

'***      7.  WinOffsetRect
  offsRect% = WinOffsetRect (hab&, Addr(Rect2), 5, 10)
  PRINT #1,  "WinOffsetRect:", offsRect%
  CALL PrintRect(Rect2) 			'(15,30)-(35,50)

'***      8.  WinEqualRect
  equal%    = WinEqualRect (hab&, Addr(Rect1), Addr(Rect2))
  PRINT #1,  "WinEqualRect:", equal%            'No (0)
  CALL PrintRect(Rect1) 			'(10,20)-(30,40)
  CALL PrintRect(Rect2) 			'(15,30)-(35,50)

'***      9.  WinIntersectRect
  inters%   = WinIntersectRect (hab&, Addr(Rect3), Addr(Rect1), Addr(Rect2))
  PRINT #1,  "WinIntersectRect:", inters%
  CALL PrintRect(Rect1) 			'(10,20)-(30,40)
  CALL PrintRect(Rect2) 			'(15,30)-(35,50)
  CALL PrintRect(Rect3) 			'(15,30)-(30,40)

'***      10. WinUnionRect
  union%    = WinUnionRect (hab&, Addr(Rect3), Addr(Rect1), Addr(Rect2))
  PRINT #1, "WinUnionRect:", union%
  CALL PrintRect(Rect1) 			'(10,20)-(30,40)
  CALL PrintRect(Rect2) 			'(15,30)-(35,50)
  CALL PrintRect(Rect3) 			'(10,20)-(35,50)

'***      11. WinSubtractRect
  subtract% = WinSubtractRect (hab&, Addr(Rect3), Addr(Rect1), Addr(Rect2))
  PRINT #1,  "WinSubtractRect:", subtract%
  CALL PrintRect(Rect1) 			'(10,20)-(30,40)
  CALL PrintRect(Rect2) 			'(15,30)-(35,50)
  CALL PrintRect(Rect3) 			'(10,20)-(30,40)

'***      12. WinInflateRect
  inflate%  = WinInflateRect (hab&, Addr(Rect1), 10, -5)
  PRINT #1,  "WinInflateRect:", inflate%
  CALL PrintRect(Rect1) 			'( 0,25)-(40,35)

'***      13. WinSetRectEmpty
  setEmpty% = WinSetRectEmpty (hab&, Addr(Rect1))
  PRINT #1,  "WinSetRectEmpty:", setEmpty%
  CALL PrintRect(Rect1) 			'( 0, 0)-( 0, 0)

'***      14. WinIsRectEmpty
  empty%    = WinIsRectEmpty (hab&, Addr(Rect1))
  PRINT #1,  "WinIsRectEmpty:", empty%          'Yes (1)
  CALL PrintRect(Rect1) 			'( 0, 0)-( 0, 0)

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
     ClientWndProc&=0
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

FUNCTION Addr&(Rect AS RECTL)
  Addr& = MakeLong(VARSEG(Rect), VARPTR(Rect))
END FUNCTION

SUB PrintRect(Rect AS RECTL)
  PRINT #1,"(";Rect.xLeft;",";Rect.yBottom;") - (";Rect.xRight;",";Rect.yTop;")"
  PRINT #1,"-----------------------------"
END SUB
