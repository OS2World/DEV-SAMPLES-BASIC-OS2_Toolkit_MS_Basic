'***********************************************************
'*
'* Program Name: GpiArc.BAS
'*
'* Include File: GpiArc.BI
'*
'* Functions   : GpiSetArcParams
'*               GpiQueryArcParams
'*               GpiPointArc
'*               GpiFullArc
'*               GpiPartialArc
'*               GpiPolyFilletSharp
'*               GpiPolySpline
'*               GpiPolyFillet
'*
'* Description : This program demonstrates how to call the various
'*               routines contained in GpiArc.BI.  Multiple arcs
'*               are displayed using each of the GpiArc routines.
'*               The arcs are not calculated to be drawn proportional
'*               to the current size of the Client window.  For proper
'*               display, the Client window must be maximized.  The
'*               Client window is initially maximized using
'*               WinSetWindowPos.  The arcs displayed are created
'*               with and positioned on the screen as follows:
'*             +---------------------------------------------------+
'*             | GpiPartialArc   GpiFullArc     GpiPointArc        |
'*             |                                                   |
'*             | GpiPolySpline   GpiPolyFillet  GpiPolyFilletSharp |
'*             +---------------------------------------------------+
'***********************************************************

'*********         Initialization section        ***********

REM $INCLUDE: 'OS2Def.BI'
REM $INCLUDE: 'PMBase.BI'
REM $INCLUDE: 'WinMan1.BI'   Needed for WinInvalidateRect
REM $INCLUDE: 'GpiCont.BI'   Needed for GpiErase
REM $INCLUDE: 'GpiLine.BI'   Needed for GpiMove
REM $INCLUDE: 'GpiArea.BI'   Needed for CONST used by GpiFullArc
REM $INCLUDE: 'GpiArc.BI'

DECLARE SUB ScreenPaint(hwnd&)
DECLARE FUNCTION MakeFixed&(realnum#)

DIM aqmsg AS QMSG

flFrameFlags& =  FCFTITLEBAR      OR FCFSYSMENU OR _
                 FCFSIZEBORDER    OR FCFMINBUTTON OR _
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

bool% = WinSetWindowPos(hwndFrame&, 0, 0, 0, 0, 0, SWPMAXIMIZE)

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
SHARED cxClient%, cyClient%

  ClientWndProc&=0
  SELECT CASE msg%
    CASE WMSIZE
      CALL BreakLong(mp2&, cyClient%, cxClient%)
    CASE WMPAINT
      bool% = WinInvalidateRect%(hwnd&, 0, 0)
      CALL ScreenPaint(hwnd&)
    CASE ELSE        'Pass control to system for other messages
      ClientWndProc& = WinDefWindowProc(hwnd&, msg%, mp1&, mp2&)
  END SELECT

END FUNCTION

'**********************************************************************
'*                                                                    *
'* SUBprogram ScreenPaint:  Called from ClientWndProc& when a WMPAINT *
'*                          message is received.                      *
'*                                                                    *
'**********************************************************************
SUB ScreenPaint(hwnd&)
SHARED cxClient%, cyClient%
DIM ptl(3) AS POINTL, arcp AS ARCPARAMS

  hps&  = WinBeginPaint(hwnd&, 0, 0)
  bool% = GpiErase     (hps&)
'*
'* Set Arc parameters to be used by GpiArc, GpiFullArc, GpiPartialArc,
'* then Query the Arc parameters to demonstrate GpiQueryArcParams.
'* The below parameters will produce a unit circle.
'*
  arcp.LP = 1
  arcp.LQ = 1
  arcp.LR = 0
  arcp.LS = 0
  bool%   = GpiSetArcParams  (hps&, MakeLong(VARSEG(arcp), VARPTR(arcp)))
  bool%   = GpiQueryArcParams(hps&, MakeLong(VARSEG(arcp), VARPTR(arcp)))
'*
'* Initialize ptl() with starting points for GpiPointArc
'*
  ptl(0).x = cxClient% / 3 * 2 : ptl(0).y = cyClient% / 3 * 2
  ptl(1).x = cxClient% / 6 * 5
  ptl(2).x = cxClient%         : ptl(2).y = ptl(0).y
  Ystart&  = cyClient%
  Yend&    = ptl(0).y
'*
'* Draw multiple arcs, decreasing first control point after each arc.
'*
  FOR Y& = cyClient% TO ptl(0).y STEP - 5
    ptl(1).y = Y&
    bool%    = GpiMove    (hps&, MakeLong(VARSEG(ptl(0)), VARPTR(ptl(0))))
    bool%    = GpiPointArc(hps&, MakeLong(VARSEG(ptl(1)), VARPTR(ptl(1))))
  NEXT Y&
'*
'* Set ptl() to center point of circle for GpiFullArc, then draw multiple
'* circles using same center point but increasing size of each circle.
'*
  ptl(1).x = cxClient% / 2 - 7
  ptl(1).y = cyClient% / 4 * 3
  bool%    = GpiMove(hps&, MakeLong(VARSEG(ptl(1)), VARPTR(ptl(1))))
  FOR I#   = 1 to 106 step 5
    bool%  = GpiFullArc(hps&, DROOUTLINE, MakeFixed(I#))
  NEXT
'*
'* Initialize ptl() to center of arc for GpiPartialArc, then draw
'* multiple arcs using same start angle, but decreasing sweep angle.
'*
  ptl(1).x = 0
  startA&  = MakeFixed(315)
  FOR I%   = 1 to 24
    multiplier& = MakeFixed(210 - I% * 4)
    sweepA&     = MakeFixed(99 - I% * 4)
    bool%       = GpiMove      (hps&, MakeLong(VARSEG(ptl(1)), VARPTR(ptl(1))))
    bool%       = GpiPartialArc(hps&,_
                  MakeLong(VARSEG(ptl(1)), VARPTR(ptl(1))),_
                  multiplier&, startA&, sweepA&)
  NEXT I%
'*
'* Initialize ptl() to starting control points GpiSpline
'*
  ptl(0).x = 0   : ptl(0).y = 0
  ptl(1).x = 20  : ptl(1).y = cyClient% * 1.08
  ptl(2).x = 142 : ptl(2).y = 80
  ptl(3).x = 213 : ptl(3).y = 80
'*
'* Draw multiple Splines, using same start and end points, with
'* decreasing first and second control points
'*
  FOR I% = 1 to 30
    bool%    = GpiMove      (hps&, MakeLong(VARSEG(ptl(0)), VARPTR(ptl(0))))
    bool%    = GpiPolySpline(hps&, 3, MakeLong(VARSEG(ptl(1)), VARPTR(ptl(1))))
    ptl(1).y = ptl(1).y - 8
    ptl(2).y = ptl(2).y - 8
  NEXT
'*
'* Initialize ptl() to starting control points for GpiPolyFillet
'*
  ptl(0).x = cxClient% / 3     : ptl(0).y = cyClient% / 2
  ptl(1).x = cxClient% / 3 * 2 : ptl(1).y = ptl(0).y
  ptl(2).x = ptl(1).x          : ptl(2).y = 0
  ptl(3).x = ptl(0).x          : ptl(3).y = 0
'*
'* Draw multiple Fillets within a rectangle decreasing in size
'* with the lower left corner remaining constant
'*
  FOR I% = 1 to 30
    bool%    = GpiMove      (hps&,    MakeLong(VARSEG(ptl(3)), VARPTR(ptl(3))))
    bool%    = GpiPolyFillet(hps&, 4, MakeLong(VARSEG(ptl(0)), VARPTR(ptl(0))))
    ptl(0).y = ptl(0).y - 6
    ptl(1).x = ptl(1).x - 6
    ptl(1).y = ptl(1).y - 6
    ptl(2).x = ptl(2).x - 6
  NEXT
'*
'* Initialize ptl() to control points for GpiPolyFilletSharp
'*
  ptl(0).x = cxClient% / 3 * 2 : ptl(0).y = 0
  ptl(1).x = ptl(0).x          : ptl(1).y = cyClient% / 3 * 2
  ptl(2).x = cxClient%         : ptl(2).y = cyClient% / 3
  sharpness# = 6#
'*
'* Draw multiple Fillets using same control points, but with
'* decrease sharpness value
'*
  FOR I% = 1 to 30
    sharp& = MakeFixed(sharpness#)
    bool%  = GpiMove           (hps&, MakeLong(VARSEG(ptl(0)), VARPTR(ptl(0))))
    bool%  = GpiPolyFilletSharp(hps&, 2&,_
             MakeLong(VARSEG(ptl(1)), VARPTR(ptl(1))),_
             MakeLong(VARSEG(sharp&), VARPTR(sharp&)))
    sharpness# = sharpness# - .2#
  NEXT

  bool% = WinEndPaint(hps&)

END SUB

'**********************************************************************
'*                                                                    *
'* FUNCTION MakeFixed:  Make a fixed-point, 32-bit real number needed *
'*                      for several functions in GpiArc.BI            *
'*                                                                    *
'**********************************************************************
FUNCTION MakeFixed&(realnum#)
  MakeFixed& = realnum# * 2 ^ 16
END FUNCTION
