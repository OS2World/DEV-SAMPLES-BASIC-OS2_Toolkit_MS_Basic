REM $INCLUDE: 'os2def.bi'
REM $INCLUDE: 'pmbase.bi'
REM $INCLUDE: 'opendlg.bi'
REM $INCLUDE: 'winmisc.bi'
REM $INCLUDE: 'wintrack.bi'
REM $INCLUDE: 'gpibit.bi'

REM $INCLUDE: 'CAPTURE.INC'

'|***************************************************************************
'|
'| SCROLMOD.BAS:  Support module of CAPTURE.BAS
'|
'|***************************************************************************
'| This module controls the Frame windows scroll bars.  If the scroll bar
'| selected is enabled, this routine repositions the scroll bar position
'| indicator and redisplays the portion of the bitmap that corresponds
'| to the new scroll bar postions.
'|***************************************************************************
'|
SUB ControlScrollBars(hwnd&, scrollbar%, mp2&) STATIC
SHARED hbm&, hwndHorzScroll&, hwndVertScroll&
DIM ptl AS POINTL
'|
'| Get current scroll bar positions and max values.
'| SMBQUERYRANGE returns a LONG integer value, with the upper limit in
'| the high word, and the lower limit in the low word.  Since the lower
'| limit is always zero, only the upper limit is needed; Thus the value
'| returned from SMBQUERYRANGE is shifted right 16 bits and assigned to
'| an INTEGER (SHAORT)
'|
  Hpos% = WinSendMsg(hwndHorzScroll&, SBMQUERYPOS, 0, 0)
  Hmax% = WinSendMsg(hwndHorzScroll&, SBMQUERYRANGE, 0, 0) \ 2 ^ 16
  Vpos% = WinSendMsg(hwndVertScroll&, SBMQUERYPOS, 0, 0)
  Vmax% = WinSendMsg(hwndVertScroll&, SBMQUERYRANGE, 0, 0) \ 2 ^ 16
'|
'| Determine portion of scroll bar that was selected
'|
  CALL BreakLong(mp2&, hcommand%, lowword%)
  SELECT CASE scrollbar%
  '|
  '| Control Horizontal Scroll Bar
  '|
    CASE WMHSCROLL
      SELECT CASE hcommand%
        CASE SBLINELEFT
          Hpos% = Hpos% - 1
        CASE SBPAGELEFT
          Hpos% = Hpos% - 10
        CASE SBLINERIGHT
          Hpos% = Hpos% + 1
        CASE SBPAGERIGHT
          Hpos% = Hpos% + 10
        CASE SBSLIDERTRACK
          Hpos% = lowword%
          LHpos% = lowword%
        CASE SBSLIDERPOSITION
          Hpos% = LHpos%
        CASE ELSE
      END SELECT
    '|
    '| If Hpos% is outside range due to a PAGELEFT or PAGERIGHT
    '| set to minimum or maximum value.
    '|
      IF Hpos% > Hmax% THEN Hpos% = Hmax%
      IF Hpos% < 0 THEN Hpos% = 0
    '|
    '| Reset Scroll bar position indicator only if user is not sliding the
    '| position indicator.
    '|
      IF hcommand% <> SBSLIDERTRACK THEN
        bool& = WinSendMsg(hwndHorzScroll&,_
                           SBMSETPOS,_
                           MakeLong(0, Hpos%),_
                           0)
      END IF
  '|
  '| Control Vertical Scroll bar
  '|
    CASE WMVSCROLL
      SELECT CASE hcommand%
        CASE SBLINEUP
          Vpos% = Vpos% - 1
        CASE SBPAGEUP
          Vpos% = Vpos% - 10
        CASE SBLINEDOWN
          Vpos% = Vpos% + 1
        CASE SBPAGEDOWN
          Vpos% = Vpos% + 10
        CASE SBSLIDERTRACK
          Vpos% = lowword%
          LVpos% = lowword%
        CASE SBSLIDERPOSITION
          Vpos% = LVpos%
        CASE ELSE
      END SELECT
    '|
    '| If Vpos% is outside range due to a PAGEDOWN or PAGEUP
    '| set to minimum or maximum value.
    '|
      IF Vpos% > Vmax% THEN Vpos% = Vmax%
      IF Vpos% < 0 THEN Vpos% = 0
    '|
    '| Reset Scroll bar position indicator only if user is not sliding the
    '| position indicator.
    '|
      IF hcommand% <> SBSLIDERTRACK THEN
        bool& = WinSendMsg(hwndVertScroll&,_
                           SBMSETPOS,_
                           MakeLong(0, Vpos%),_
                           0)
      END IF
  END SELECT
'|
'| Get a presentation space to draw bitmap, and calculate from
'| new scroll bar positions the portion of the bitmap to display
'|
  hps& = WinGetPS(hwnd&)
  ptl.x = 0
  ptl.y = 0
  IF WinIsWindowEnabled(hwndHorzScroll&) THEN ptl.x = -Hpos%
  IF WinIsWindowEnabled(hwndVertScroll&) THEN ptl.y =  Vpos% - Vmax%
  bool% = WinDrawBitmap(hps&, hbm&, 0,_
                        MakeLong(VARSEG(ptl), VARPTR(ptl)),_
                        CLRNEUTRAL, CLRBACKGROUND, DBMNORMAL)
  bool% = WinReleasePS(hps&)
END SUB

