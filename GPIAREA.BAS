'***********************************************************
'*
'* Program Name: GpiArea.BAS
'*
'* Include File: GpiArea.BI
'*
'* Functions   : GpiSetPattern
'*               GpiQueryPattern
'*               GpiBeginArea
'*               GpiEndArea
'*               GpiSetPatternSet
'*               GpiQueryPatternSet
'*               GpiSetPatternRefPoint
'*               GpiQueryPatternRefPoint
'*               GpiSetMix
'*               GpiQueryMix
'*               GpiSetBackMix
'*               GpiQueryBackMix
'*
'* Description : GpiArea.BAS fills the window with 16 diamonds
'*               drawn proportionally to the size of the Client
'*               window, and paints each diamond with a different
'*               pattern.  CALLs to routines in GpiArea.BI not
'*               used in the SUBprogram "ScreenPaint" are
'*               demonstrated in the SUBprogram following "ScreenPaint"
'***********************************************************

'*********         Initialization section        ***********

REM $INCLUDE: 'OS2Def.BI'
REM $INCLUDE: 'PMBase.BI'
REM $INCLUDE: 'WinMan1.BI'   Needed for WinInvalidateRect
REM $INCLUDE: 'GpiCont.BI'   Needed for GpiErase
REM $INCLUDE: 'GpiLine.BI'   Needed for GpiPolyLine & GpiMove
REM $INCLUDE: 'GpiArea.BI'

DECLARE SUB ScreenPaint(hwnd&)
DECLARE SUB DemonstrateCallsNotUsedInScreenPaint(hwnd&)

DIM aqmsg AS QMSG
DIM SHARED ClientRect as RECTL

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
        CSSIZEREDRAW,_
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

bool% = WinDestroyWindow  (hwndFrame&)
bool% = WinDestroyMsgQueue(hmq&)
bool% = WinTerminate      (hab&)
END

'***********         Window procedure        ***************

FUNCTION ClientWndProc& (hwnd&, msg%, mp1&, mp2&) STATIC

  ClientWndProc& = 0
  SELECT CASE msg%
    CASE WMCREATE
      CALL DemonstrateCallsNotUsedInScreenPaint(hwnd&)
    CASE WMPAINT
      bool% = WinInvalidateRect%(hwnd&, 0, 0)
      CALL ScreenPaint(hwnd&)
    CASE ELSE        'Pass control to system for other messages
      ClientWndProc& = WinDefWindowProc(hwnd&, msg%, mp1&, mp2&)
  END SELECT

END FUNCTION

'*
'* SUBprogram ScreenPaint:  Called from ClientWndProc& when a WMPAINT
'*                          message is received.
'*
SUB ScreenPaint(hwnd&)
DIM aptl(4) AS POINTL

  hps&  = WinBeginPaint(hwnd&, 0,_
          MakeLong(VARSEG(ClientRect), VARPTR(ClientRect)))
  bool% = GpiErase(hps&)

  patterncntr& = 1
'*
'* Divide Window by 8th's and 4th's
'*
  xdiv8& = ClientRect.xRight / 8
  ydiv8& = ClientRect.yTop / 8
  xdiv4& = ClientRect.xRight / 4
  ydiv4& = ClientRect.yTop / 4
  row& = ydiv8&

  FOR I%    = 1 TO 4
    column& = 0
    FOR N%  = 1 TO 4
'*
'* Set Fill Pattern.  The pattern is set the Queried to
'* demonstrate both GpiSetPattern and GpiQueryPattern
'* The Query is not neccessary.  Skip Pattern 15 since it is
'* the same as the background color.  "patterncntr&" corresponds
'* to the CONSTants for the pattern names in GpiArea.BI:
'*
'*    CONST  PATSYMDENSE1    =      1
'*    CONST  PATSYMDENSE2    =      2
'*    CONST  PATSYMDENSE3    =      3
'*    CONST  PATSYMDENSE4    =      4
'*    CONST  PATSYMDENSE5    =      5
'*    CONST  PATSYMDENSE6    =      6
'*    CONST  PATSYMDENSE7    =      7
'*    CONST  PATSYMDENSE8    =      8
'*    CONST  PATSYMVERT      =      9
'*    CONST  PATSYMHORIZ     =      10
'*    CONST  PATSYMDIAG1     =      11
'*    CONST  PATSYMDIAG2     =      12
'*    CONST  PATSYMDIAG3     =      13
'*    CONST  PATSYMDIAG4     =      14
'*    CONST  PATSYMNOSHADE   =      15
'*    CONST  PATSYMSOLID     =      16
'*    CONST  PATSYMHALFTONE  =      17
'*
      bool%       = GpiSetPattern  (hps&, patterncntr&)
      pattercntr& = GpiQueryPattern(hps&)

      patterncntr& = patterncntr& + 1&
      if patterncntr& = 15 then patterncntr& = 16
'*
'* Initialize aptl() with points for polygon to be
'* drawn with GpiPolyLine
'*
      aptl(1).x = column&          : aptl(1).y = row&
      aptl(2).x = column& + xdiv8& : aptl(2).y = row& + ydiv8&
      aptl(3).x = column& + xdiv4& : aptl(3).y = row&
      aptl(4).x = column& + xdiv8& : aptl(4).y = row& - ydiv8&
'*
'* Mark Beginning of area to be filled
'*
      bool% = GpiBeginArea(hps&, BAALTERNATE OR BABOUNDARY)
'*
'* Move to first point of polygon then draw polygon
'*
      bool% = GpiMove    (hps&, MakeLong(VARSEG(aptl(1)), VARPTR(aptl(1))))
      bool% = GpiPolyLine(hps&, 3,_
              MakeLong(VARSEG(aptl(2)), VARPTR(aptl(2))))
'*
'* Mark end of area to be filled and fill area
'*
      bool%   = GpiEndArea(hps&)

      column& = column& + xdiv4&
    NEXT N%
    row& = row& + ydiv4&
  NEXT I%

  bool% = WinEndPaint(hps&)

END SUB
'*
'* The SUBprogram is called when the WMCREATE message is received.
'* It simply Sets then Querys values used in GpiArea.BI to
'* demonstrate GpiArea.BI calls not used in ScreenPaint
'*
SUB DemonstrateCallsNotUsedInScreenPaint(hwnd&)
DIM pptl AS POINTL

  hps&  = WinGetPS(hwnd&)

    bool% = GpiSetPatternSet  (hps&, LCIDDEFAULT)
    pat&  = GpiQueryPatternSet(hps&)

    bool% = GpiSetPatternRefPoint  (hps&, MakeLong(VARSEG(pptl), VARPTR(pptl)))
    bool% = GpiQueryPatternRefPoint(hps&, MakeLong(VARSEG(pptl), VARPTR(pptl)))

    bool% = GpiSetMix  (hps&, FMDEFAULT)
    mix&  = GpiQueryMix(hps&)

    bool% = GpiSetBackMix  (hps&, BMDEFAULT)
    bmix& = GpiQueryBackMix(hps&)

  bool% = WinReleasePS(hps&)

END SUB
