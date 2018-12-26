'³*****************************************************************
'³
'³ Module:       MarkMod.bas
'³
'³ Subprograms:  DemoMark
'³
'³ Description:  DemoMark is passed two paramaters, the handle of the
'³               presentation space, and the ID of the marker to use.
'³               A graph of 20 random points is generated, proportional
'³               to the current size of the Client window, plotting each
'³               point with the marker specified by "marker%" which is
'³               determined by the submenu item selected under GraphMarkers.
'³
'³*****************************************************************
REM $INCLUDE: 'os2def.bi'
REM $INCLUDE: 'pmbase.bi'
REM $INCLUDE: 'gpiline.bi'
REM $INCLUDE: 'gpicolor.bi'
REM $INCLUDE: 'GPIMARK.BI'

COMMON /Gdemo/ cxClient%, cyClient%

SUB DemoMark(hps&, marker%)
SHARED cxClient%, cyClient%
DIM ptl(20) AS POINTL

  xincr% = cxClient% / 20     'Divide Client window by 20
  RANDOMIZE TIMER             'Obtain seed for RND function
  '³
  '³ Generate 21 random Y corrdinate values and store points
  '³ in ptl()
  '³
  FOR I% = 0 to 20
    ptl(I%).x = I% * xincr%
    ptl(I%).y = INT((cyClient% + 1) * RND)
  NEXT I%
  '³
  '³ - GpiSetMarker selects the Marker from the default marker set to be used.
  '³     marker% - 40 is need only because the value passed in marker%
  '³     is actually the ID of the menuitem which happens to be 40 greater
  '³     than the actual marker ID required by BpiSetMarker
  '³
  '³ - GpiMove postions graphics pointer to first point in graph
  '³ - GpiPolyLine draws the graph from the points stored in ptl(), without
  '³   markers
  '³ - GpiSetColor changes color to RED to make the markers standout
  '³ - GpiPolyMarker draws the selected marker at each point contained
  '³   ptl()
  '³
  bool% = GpiSetMarker(hps&, marker%-40)
  bool% = GpiMove(hps&, MakeLong(VARSEG(ptl(0)), VARPTR(ptl(0))))
  bool% = GpiPolyLine(hps&, 20&, MakeLong(VARSEG(ptl(1)), VARPTR(ptl(1))))
  bool% = GpiSetColor(hps&, CLRRED)
  bool% = GpiPolyMarker(hps&, 19&, MakeLong(VARSEG(ptl(1)), VARPTR(ptl(1))))

END SUB


