'�*****************************************************************
'�
'� Module:       LineMod.bas
'�
'� Subprograms:  DemoLine
'�
'� Description:  DemoLine initially fills the Client window with
'�               lines a varying types and colors.  A blue transparent
'�               blue box is then drawn in the middle of the window,
'�               and then a ren diamond is drawn in the middle of the
'�               box.  This is the same routine found in GpiLine.BAS
'�               minus all the CALLs that do not have a visible affect.
'�
'�******************************************************************

REM $INCLUDE: 'os2def.bi'
REM $INCLUDE: 'pmbase.bi'
REM $INCLUDE: 'gpiline.bi'
REM $INCLUDE: 'gpiarea.bi'
REM $INCLUDE: 'gpicolor.bi'

COMMON /Gdemo/ cxClient%, cyClient%

SUB DemoLine(hps&)
SHARED cxClient%, cyClient%
DIM ppnt AS POINTL, appnt(3) AS POINTL

'�
'� The following FOR NEXT loop, fills the Client window with
'� horizontal lines of varying Line types and colors.
'�
  colorcntr% = 1
  FOR I% = 0 TO cyClient% STEP 3
    bool% = GpiSetColor(hps&, colorcntr%)
    colorcntr% = colorcntr% + 1
    IF colorcntr% = 16 THEN colorcntr% = 1    'CHECK IF AT END OF COLOR TABLE
    bool% = GpiSetLineType(hps&, linetype%)
    linetype% = linetype% + 1                 'INCRIMENT LINETYPE COUTER AND
    If linetype% = 10 then linetype% = 0      'AND CHECK RESET IF AT LAST TYPE
    ppnt.x = 0
    ppnt.y = I%
    bool% = GpiMove(hps&, MakeLong(Varseg(ppnt), Varptr(ppnt)))
    ppnt.x = cxClient%
    along& = GpiLine(hps&, MakeLong(Varseg(ppnt), Varptr(ppnt)))
  NEXT
'�
'� Draws a Box and fills it using the GpiBox routine.  The box is filled
'� a halftone pattern and the color blue, which makes it appear transparent.
'�
  ppnt.x = cxClient% \ 8      'LOWER LEFT HAND CORNER OF BOX
  ppnt.y = cyClient% \ 8
  bool% = GpiMove(hps&, MakeLong(Varseg(ppnt), Varptr(ppnt)))
  ppnt.x = 7 * ppnt.x
  ppnt.y = 7 * ppnt.y         'UPPER RIGHT HAND CORNER OF BOX
'�
'� Sets fill pattern and draws box
'�
  bool% = GpiSetColor(hps&, CLRBLUE)
  bool% = GpiSetPattern(hps&, PATSYMHALFTONE)
  along& = GpiBox(hps&, DROOUTLINEFILL,_
                  MakeLong(Varseg(ppnt), Varptr(ppnt)), 0, 0)
'�
'� Sets patten and marks beginning of area to be filled when the
'� GpiEndArea is executed
'�
  bool% = GpiSetColor(hps&, CLRRED)
  bool% = GpiSetPattern(hps&, PATSYMSOLID)
  bool% = GpiBeginArea(hps&,(BAALTERNATE OR BABOUNDARY))
'�
'� Initializes array with points that define polygon to be draw
'� points are calculated using the current Client window coordinates
'� so that the polygon is always draw proportional to the Client window
'�
  appnt(0).x = (cxClient% \ 8) * 2 : appnt(0).y = cyClient% \ 2
  appnt(1).x = cxClient% \ 2       : appnt(1).y = (cyClient% \ 8) * 6
  appnt(2).x = (cxClient% \ 8) * 6 : appnt(2).y = cyClient% \ 2
  appnt(3).x = cxClient% \ 2       : appnt(3).y = (cyClient% \ 8) * 2
'�
'� Moves to first point of polygon then draws polygon
'�
  bool% = GpiMove(hps&, MakeLong(Varseg(appnt(0)), Varptr(appnt(0))))
  bool% = GpiPolyLine(hps&, 3&, MakeLong(Varseg(appnt(1)), Varptr(appnt(1))))
'�
'� Marks end of Area and fills polygon with current pattern and color
'�
  bool% = GpiEndArea(hps&)

END SUB

