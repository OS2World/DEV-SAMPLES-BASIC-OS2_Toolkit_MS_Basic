'***********************************************************
'*
'* Program Name: GpiMark.BAS
'*
'* Include File: GpiMark.BI
'*
'* Functions   : GpiSetMarkerSet
'*               GpiQueryMarkerSet
'*               GpiSetMarker
'*               GpiQueryMarker
'*               GpiSetMarkerBox
'*               GpiQueryMarkerBox
'*               GpiMarker     not demonstrated (Same as GpiPolyMarker)
'*               GpiPolyMarker
'*
'* Description : This program demomstrates the routines contained
'*               in GpiMark.BI.  It demonstrates the default
'*               marker set only, which are image markers.
'*               Ten lines are drawn containing 4 points each
'*               using a different marker for each line.  The
'*               lines are drawn proportional to the current
'*               window size.
'***********************************************************

'*********         Initialization section        ***********

REM $INCLUDE: 'OS2Def.BI'
REM $INCLUDE: 'PMBase.BI'
REM $INCLUDE: 'WinMan1.BI'         Needed for WinInvalidateRect
REM $INCLUDE: 'GpiCont.BI'         Needed for GpiErase
REM $INCLUDE: 'GpiLine.BI'         Needed for GpiMove and GpiLine
REM $INCLUDE: 'GpiMark.BI'

DECLARE SUB ScreenPaint(hwnd&)
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

bool% = WinDestroyWindow   (hwndFrame&)
bool% = WinDestroyMsgQueue (hmq&)
bool% = WinTerminate       (hab&)

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
    CASE ELSE
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
DIM ptl(3) AS POINTL

  hps&  = WinBeginPaint(hwnd&, 0, 0)
  bool% = GpiErase     (hps&)
'*
'* GpiSetMarkerBox and GpiQueryMarkerBox are only used when a vector
'* font has been selected.  This example program only demonstrates the
'* default marker set which are image markers, so the following two calls
'* have no affect on the program.
'*
  bool% = GpiSetMarkerBox  (hps&, MakeLong(VARSEG(ptl(0)), VARPTR(ptl(0))))
  bool% = GpiQueryMarkerBox(hps&, MakeLong(VARSEG(ptl(0)), VARPTR(ptl(0))))
'*
'* Initialize ptl(0) with points to draw line with and locations
'* to draw markers
'*
  ptl(0).x = 0                  : ptl(0).y = 0
  ptl(1).x = cxClient% / 20     : ptl(1).y = cyClient% / 4
  ptl(2).x = cxClient% / 20 * 3 : ptl(2).y = cyClient% / 2
  ptl(3).x = cxClient% / 20 * 8 : ptl(3).y = cyClient% / 4 * 3
'*
'* Selects default marker set, then draws 10 lines consisting of 4 points
'* each, using a different default marker (marker%) for each line.
'* "marker%" corresponds to the CONST marker types declared in GpiMark.BI      :
'*
'*              CONST  MARKSYMERROR	  =    -1   (not demonstated)
'*              CONST  MARKSYMDEFAULT	  =    0    (not demonstated)
'*              CONST  MARKSYMCROSS	  =    1
'*              CONST  MARKSYMPLUS	  =    2
'*              CONST  MARKSYMDIAMOND	  =    3
'*              CONST  MARKSYMSQUARE	  =    4
'*              CONST  MARKSYMSIXPOINTSTAR  =  5
'*              CONST  MARKSYMEIGHTPOINTSTAR = 6
'*              CONST  MARKSYMSOLIDDIAMOND  =  7
'*              CONST  MARKSYMSOLIDSQUARE   =  8
'*              CONST  MARKSYMDOT	    =  9
'*              CONST  MARKSYMSMALLCIRCLE   =  10
'*              CONST  MARKSYMBLANK	    =  64   (not demonstrated)

  bool% = GpiSetMarkerSet  (hps&, LCIDDEFAULT)
  mset% = GpiQueryMarkerSet(hps&)        'JUST TO ILLUSTRATE GpiQueryMarkerSet
  FOR marker% = 1 to 10
    bool%   = GpiSetMarker  (hps&, marker%)
    marker% = GpiQueryMarker(hps&)       'JUST TO ILLUSTRATE GpiQueryMarker
    bool%   = GpiMove       (hps&,    MakeLong(VARSEG(ptl(0)), VARPTR(ptl(0))))
    bool%   = GpiPolyLine   (hps&, 3, MakeLong(VARSEG(ptl(1)), VARPTR(ptl(1))))
    bool%   = GpiPolyMarker (hps&, 3, MakeLong(VARSEG(ptl(1)), VARPTR(ptl(1))))
'*
'* Increment X values to move line to the right
'*
    ptl(0).x = ptl(0).x + cxClient% / 16
    ptl(1).x = ptl(1).x + cxClient% / 16
    ptl(2).x = ptl(2).x + cxClient% / 16
    ptl(3).x = ptl(3).x + cxClient% / 16
  NEXT marker%

  bool% = WinEndPaint(hps&)

END SUB
