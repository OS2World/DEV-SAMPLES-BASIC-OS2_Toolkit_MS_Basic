'³*****************************************************************
'³
'³ Module:       ArcMod.bas
'³
'³ Subprograms:  DemoGpiPointArc
'³               DemoGpiFullArc
'³               DemoGpiPartialArc
'³               DemoGpiPolyFilletSharp
'³               DemoGpiPolySpline
'³               DemoGpiPolyFillet
'³
'³               SetArcParamaters  -- Used by several of the Demo Subs
'³                                    to initialize arc paramaters
'³
'³ Description:  This SUBprogram is identical to the example program
'³               GpiArc.BAS, except it has been broken up into separate
'³               SUBprograms that can be executed separately, and color
'³               has been added.  All subprograms take an agrgument called
'³               "mode%".  This is a flag that signals whether all the Arc
'³               routines are begin executed sequentially or if only a
'³               Arc routine is to be exectued.  If mode% = 1, then the
'³               selected Arc routine fills the entire window with its
'³               specific Arc type.  If mode% = 0 then all Arc types are
'³               drawn together, and each takes up approximately 1/6th of
'³               the Client Window.  For the best picture when "Display all"
'³               is selected, the Window should be maxized.
'³
'³        Note:  Since these routines are virtually identical to the
'³               routines in GpiArc.BAS, documentation has not been added
'³               to this module for the individual SUBprograms.  Refer to
'³               GpiArc.BAS for documented code.
'³          
REM $INCLUDE: 'os2def.bi'
REM $INCLUDE: 'pmbase.bi'
REM $INCLUDE: 'gpiline.bi'
REM $INCLUDE: 'gpiarea.bi'
REM $INCLUDE: 'gpicolor.bi'
REM $INCLUDE: 'gpiarc.bi'

DECLARE SUB SetArcParamaters()
DECLARE FUNCTION MakeFixed&(realnum#)

COMMON /Gdemo/ cxClient%, cyClient%


'³***************************************************************************
SUB DemoGpiPointArc(hps&,mode%)
SHARED arcp AS ARCPARAMS, cxClient%, cyClient%
DIM ptl(2) AS POINTL

  If mode% = 1 THEN
    ptl(0).x = 0 : ptl(0).y = 0
    ptl(1).x = cxClient% / 2
    ptl(2).x = cxClient% : ptl(2).y = 0
    Ystart&  = cyClient% / 4 * 3
    Yend&    = 0
  ELSE
    ptl(0).x = cxClient% / 3 * 2 : ptl(0).y = cyClient% / 3 * 2
    ptl(1).x = cxClient% / 6 * 5
    ptl(2).x = cxClient% : ptl(2).y = ptl(0).y
    Ystart&  = cyClient%
    Yend&    = ptl(0).y
  END IF
  colorcntr% = 1
  FOR Y& = Ystart& TO Yend& STEP -5
    bool% = GpiSetColor(hps&, colorcntr%)
    bool% = GpiBeginArea(hps&,(BAALTERNATE OR BABOUNDARY))
    ptl(1).y = Y&
    bool% = GpiMove(hps&, MakeLong(VARSEG(ptl(0)), VARPTR(ptl(0))))
    bool% = GpiPointArc(hps&, MakeLong(VARSEG(ptl(1)), VARPTR(ptl(1))))
    bool% = GpiEndArea(hps&)
    colorcntr% = colorcntr% + 1
    if colorcntr% = 16 then colorcntr% = 1
  NEXT Y&
END SUB


'³***************************************************************************
SUB DemoGpiFullArc(hps&,mode%)
SHARED arcp AS ARCPARAMS, cxClient%, cyClient%
DIM ptl AS POINTL

  IF mode% = 1 THEN
    ptl.x = cxClient% / 2     : ptl.y = cyClient% / 2
    max% = 216
  ELSE
    ptl.x = cxClient% / 2 - 7 : ptl.y = cyClient% / 4 * 3
    max% = 106
  END IF
  bool% = GpiMove(hps&, MakeLong(VARSEG(ptl), VARPTR(ptl)))
  colorcntr% = 1
  FOR I# = max% to 1 step -5
    bool% = GpiSetColor(hps&, colorcntr%)
    bool% = GpiFullArc(hps&, DROOUTLINEFILL, MakeFixed(I#))
    colorcntr% = colorcntr% + 1
    if colorcntr% = 16 then colorcntr% = 1
  NEXT
END SUB


'³***************************************************************************
SUB DemoGpiPartialArc(hps&,mode%)
SHARED arcp AS ARCPARAMS, cxClient%, cyClient%
DIM ptl AS POINTL

  IF mode% = 1 THEN
    ptl.x = cxClient% / 3 : ptl.y = cyClient% / 2
    mult% = 259
  ELSE
    ptl.x = 0 : ptl.y = cyClient% / 4 * 3
    mult% = 210
  END IF
  startA& = MakeFixed(315)
  colorcntr% = 1
  FOR I% = 1 to 24
    bool% = GpiSetColor(hps&, colorcntr%)
    bool% = GpiBeginArea(hps&,(BAALTERNATE OR BABOUNDARY))
    multiplier& = MakeFixed(mult% - I% * 4)
    sweepA& = MakeFixed(99 - I% * 4)
    bool% = GpiMove(hps&, MakeLong(VARSEG(ptl), VARPTR(ptl)))
    bool% = GpiPartialArc(hps&, MakeLong(VARSEG(ptl), VARPTR(ptl)),_
    multiplier&, startA&, sweepA&)
    bool% = GpiEndArea(hps&)
    colorcntr% = colorcntr% + 1
    if colorcntr% = 16 then colorcntr% = 1
  NEXT I%
END SUB


'³***************************************************************************
SUB DemoGpiPolyFilletSharp(hps&,mode%)
SHARED cxClient%, cyClient%
DIM ptl(2) AS POINTL

  IF mode% = 1 THEN
    ptl(0).x = 0         : ptl(0).y = 0
    ptl(1).x = 0         : ptl(1).y = cyClient%
    ptl(2).x = cxClient% : ptl(2).y = cyClient% / 3 * 2
  ELSE
    ptl(0).x = cxClient% / 3 * 2 : ptl(0).y = 0
    ptl(1).x = ptl(0).x          : ptl(1).y = cyClient% / 3 * 2
    ptl(2).x = cxClient%         : ptl(2).y = cxClient% / 3
  END IF
  sharpness# = 6
  colorcntr% = 1
  FOR I% = 1 to 30
    bool% = GpiSetColor(hps&, colorcntr%)
    bool% = GpiBeginArea(hps&,(BAALTERNATE OR BABOUNDARY))
    sharp& = MakeFixed(sharpness#)
    bool% = GpiMove(hps&, MakeLong(VARSEG(ptl(0)), VARPTR(ptl(0))))
    bool% = GpiPolyFilletSharp(hps&, 2&,_
                               MakeLong(VARSEG(ptl(1)),VARPTR(ptl(1))),_
                               MakeLong(VARSEG(sharp&), VARPTR(sharp&)))
    bool% = GpiEndArea(hps&)
    colorcntr% = colorcntr% + 1
    if colorcntr% = 16 then colorcntr% = 1
    sharpness# = sharpness# - .2#
  NEXT
END SUB


'³***************************************************************************
SUB DemoGpiPolySpline(hps&,mode%)
SHARED cxClient%, cyClient%
DIM ptl(3) AS POINTL, lastptl(3) AS POINTL

  IF mode% = 1 THEN
    ptl(0).x = 0                 : ptl(0).y = 0
    ptl(1).x = cxClient% / 6     : ptl(1).y = cyClient% * 2.08
    ptl(2).x = cxClient% / 4 * 3 : ptl(2).y = 0
    ptl(3).x = cxClient%         : ptl(3).y = cyClient% / 4 * 3
    max% = 40
  ELSE
    ptl(0).x = 0                  : ptl(0).y = 0
    ptl(1).x = cxClient% / 18     : ptl(1).y = cyClient% * 1.08
    ptl(2).x = cxClient% / 12 * 3 : ptl(2).y = 0
    ptl(3).x = cxClient% / 3      : ptl(3).y = CyClient% / 8 * 3
    max% = 20
  END IF
  colorcntr% = 1
  FOR I% = 1 to max%
    IF I% <> 1 THEN
      bool% = GpiSetColor(hps&, colorcntr%)
      bool% = GpiBeginArea(hps&,(BAALTERNATE OR BABOUNDARY))
    END IF
    bool% = GpiMove(hps&, MakeLong(VARSEG(ptl(0)), VARPTR(ptl(0))))
    bool% = GpiPolySpline(hps&, 3&, MakeLong(VARSEG(ptl(1)),VARPTR(ptl(1))))
    IF I% <> 1 THEN
      bool% = GpiPolySpline(hps&, 3&, MakeLong(VARSEG(lastptl(1)), VARPTR(lastptl(1))))
      bool% = GpiEndArea(hps&)
      colorcntr% = colorcntr% + 1
      if colorcntr% = 16 then colorcntr% = 1
    END IF
    M% = 3
    FOR N% = 0 to 3
      lastptl(N%) = ptl(M%)
      M% = M% - 1
    NEXT N%
    ptl(1).y = ptl(1).y - 9
    ptl(2).y = ptl(2).y - 9
  NEXT I%
END SUB


'³***************************************************************************
SUB DemoGpiPolyFillet(hps&,mode%)
SHARED cxClient%, cyClient%
DIM ptl(3) AS POINTL

  IF mode% = 1 THEN
    ptl(0).x = 0         : ptl(0).y = cyClient%
    ptl(1).x = cxClient% : ptl(1).y = cyClient%
    ptl(2).x = cxClient% : ptl(2).y = 0
    ptl(3).x = 0         : ptl(3).y = 0
    max% = 50
  ELSE
    ptl(0).x = cxClient% / 3     : ptl(0).y = cyClient% / 2
    ptl(1).x = cxClient% / 3 * 2 : ptl(1).y = cyClient% / 2
    ptl(2).x = cxClient% / 3 * 2 : ptl(2).y = 0
    ptl(3).x = cxClient% / 3     : ptl(3).y = 0
    max% = 30
  END IF
  colorcnt% = 1
  FOR I% = 1 to max%
    bool% = GpiSetColor(hps&, colorcntr%)
    bool% = GpiBeginArea(hps&,(BAALTERNATE OR BABOUNDARY))
    bool% = GpiMove(hps&, MakeLong(VARSEG(ptl(3)), VARPTR(ptl(3))))
    bool% = GpiPolyFillet(hps&, 4&, MakeLong(VARSEG(ptl(0)), VARPTR(ptl(0))))
    bool% = GpiEndArea(hps&)
    colorcntr% = colorcntr% + 1
    if colorcntr% = 16 then colorcntr% = 1
    ptl(0).y = ptl(0).y - 6
    ptl(1).x = ptl(1).x - 6
    ptl(1).y = ptl(1).y - 6
    ptl(2).x = ptl(2).x - 6
  NEXT
END SUB


'³***************************************************************************
SUB SetArcParamaters
SHARED arcp AS ARCPARAMS
  arcp.LP = 1
  arcp.LQ = 1
  arcp.LR = 0
  arcp.LS = 0
  bool% = GpiSetArcParams(hps&, MakeLong(Varseg(arcp), Varptr(arcp)))
END SUB

