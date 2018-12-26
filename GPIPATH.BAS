'**************************************************************************
'*
'* Program Name: GpiPath.BAS
'*
'* Include File: GpiPath.BI, GpiLine.BI
'*
'* Functions:    GpiSetGraphicsField
'*               GpiQueryGraphicsField
'*               GpiSetViewingLimits
'*               GpiQueryViewingLimits
'*               GpiBeginPath%
'*               GpiBeginPath%
'*               GpiCloseFigure
'*               GpiModifyPath
'*               GpiFillPath
'*               GpiSetClipPath
'*               GpiStrokePath
'*
'*            The following functions are from GpiLine.BI:
'*
'*               GpiSetLineWidthGeom
'*               GpiQueryLineWidthGeom
'*               GpiSetLineEnd
'*               GpiQueryLineEnd
'*               GpiSetLineJoin
'*               GpiQueryLineJoin
'*
'* Description:  All the routines contained in GpiPath.BI and some
'*               routines contained in GpiLine.BI are demonstrated
'*               in this program.  A predefined design is displayed
'*               using the current parameters set.  Path and line
'*               geometry parameters are set by selecting desired
'*               items from the various menus.  The "Clip Path"
'*               menu option takes quite a bit longer than the
'*               other menu selections to complete the display.
'*               so be aware of it.
'*
'*               The "LineEnd" option only visually affects the short
'*               line segments on either side of the screen.  The
'*               RED lines are drawn to show actual figured before
'*               modified with geometric line parameters.
'*
'*               The "LineJoin" option only visually affects the
'*               continuous line design in the middle of the screen.
'*
'*               The "LineWidth" option only allows for widths of
'*               10, 20, 30, and 40 pixels, however, the geometric
'*               line width can be set to any value from 1 to
'*               whatever the device will support.
'*
'*               Return values from routines that do no have a visual
'*               affect are written out to the file GpiPath.OUT.
'***************************************************************************

'*********         Initialization section        ***********

REM $INCLUDE: 'OS2Def.BI'
REM $INCLUDE: 'PMBase.BI'
REM $INCLUDE: 'WinMan1.BI'
REM $INCLUDE: 'WinMsgs.BI'
REM $INCLUDE: 'GpiCont.BI'
REM $INCLUDE: 'GpiChar.BI'
REM $INCLUDE: 'GpiColor.BI'
REM $INCLUDE: 'GpiLine.BI'
REM $INCLUDE: 'GpiPath.BI'
                  
DECLARE SUB ScreenPaint(hwnd&)
DECLARE SUB MarkActualPathWithRedLines(xdiv%, ydiv%)
DECLARE SUB DrawShortLineSegments(xdiv%, ydiv%)
DECLARE SUB FillClipPathWithText()  

CONST IDRESOURCE   = 1
CONST IDEXIT       = 10
CONST IDLINEEND    = 20
CONST IDLINEJOIN   = 30
CONST IDLINEWIDTH  = 40
CONST IDSTROKEPATH = 50
CONST IDFILLPATH   = 60
CONST IDCLIPPATH   = 70

DIM aqmsg AS QMSG
DIM SHARED aptl(7) AS POINTL

OPEN "GpiPath.OUT" FOR OUTPUT AS #1

flFrameFlags& =  FCFTITLEBAR      OR  FCFSYSMENU  OR_
                 FCFSIZEBORDER    OR  FCFMINMAX   OR_
                 FCFSHELLPOSITION OR  FCFTASKLIST OR_
                 FCFMENU

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
             WSINVISIBLE,_
             MakeLong (VARSEG(flFrameFlags&),  VARPTR(flFrameFlags&)),_
             MakeLong (VARSEG(szClientClass$), SADD(szClientClass$)),_
             0,_
             0,_
             0,_
             IDRESOURCE,_
             MakeLong (VARSEG(hwndClient&), VARPTR(hwndClient&)))

  bool% = WinSetWindowPos(hwndFrame&, 0, 0, 0, 0, 0, SWPSHOW OR SWPMAXIMIZE)

'**************         Message loop         ***************

WHILE WinGetMsg(hab&, MakeLong(VARSEG(aqmsg), VARPTR(aqmsg)), 0, 0, 0)
    bool% = WinDispatchMsg(hab&, MakeLong(VARSEG(aqmsg), VARPTR(aqmsg)))
WEND

'***********         Finalize section        ***************

bool% = WinDestroyWindow   (hwndFrame&)
bool% = WinDestroyMsgQueue (hmq&)
bool% = WinTerminate       (hab&)
CLOSE #1
END

'***********         Window procedure        ***************

FUNCTION ClientWndProc& (hwnd&, msg%, mp1&, mp2&) STATIC
SHARED cxClient%, cyClient%, lineend&, linewidth&, linejoin&, path%

  ClientWndProc&=0
  SELECT CASE msg%
    '*
    '* Set default values for Line Width, End, and Join
    '*
    CASE WMCREATE
      lineend&   = LINEENDROUND
      linewidth& = 10
      linejoin&  = LINEJOINROUND
    '*
    '* Obtain new size of Client Window
    '*
    CASE WMSIZE
      CALL BreakLong(mp2&, cyClient%, cxClient%)
      bool% = WinInvalidateRect(hwnd&, 0, 0)

    CASE WMPAINT
      CALL ScreenPaint(hwnd&)
    '*
    '* Determine which menu item was selected, set corresponding
    '* flag or parameter, then invalidate the Client Window, so
    '* a WMPAINT message will be posted, which will cause the
    '* window to be redrawn with the new parameters
    '*
    CASE WMCOMMAND
      CALL BreakLong(mp1&, dummy%, menuselection%)
      SELECT CASE menuselection%

        CASE IDEXIT
          bool% = WinPostMsg(hwnd&, WMQUIT, 0&, 0&)
      '*
      '* Obtain LineEnd type
      '*
        CASE IDLINEEND+1 TO IDLINEEND+4
          lineend&   = menuselection% - IDLINEEND - 1
      '*
      '* Obtain LineJoin type
      '*
        CASE IDLINEJOIN+1 TO IDLINEJOIN+4
          linejoin&  = menuselection% - IDLINEJOIN - 1
      '*
      '* Obtain LineWidth
      '*
        CASE IDLINEWIDTH+1 TO IDLINEWIDTH+4
          linewidth& = (menuselection% - IDLINEWIDTH) * 10
      '*
      '* StrokePath simply draws the path with the current
      '* line geometry parameters
      '*
        CASE IDSTROKEPATH
          path% = 0
      '*
      '* FillPath either fills the interior of the path, or the
      '* path itself.
      '*
        CASE IDFILLPATH+1 TO IDFILLPATH+2
          path% = menuselection% - IDFILLPATH
      '*
      '* ClipPath either clips all output to within the path itself
      '* or to within the interior of the path
      '*
        CASE IDCLIPPATH+1, IDCLIPPATH+2
          path% = menuselection% - IDCLIPPATH + 2

      END SELECT
      bool% = WinInvalidateRect(hwnd&, 0, 0)

    CASE ELSE  
      ClientWndProc& = WinDefWindowProc(hwnd&, msg%, mp1&, mp2&)

  END SELECT

END FUNCTION


'************************************************************************
'*
'* SUBprogram ScreenPaint:  Called from ClientWndProc& when a WMPAINT
'*                          message is received.
'*
SUB ScreenPaint(hwnd&)
SHARED hps&, cxClient%, cyClient%, lineend&, linewidth&, linejoin&, path%
DIM rect AS RECTL

  hps&  = WinBeginPaint(hwnd&, 0, 0)
  bool% = GpiErase     (hps&)
'*
'* The following four CALLs set viewing limits and graphics field limits.
'* For simplicity, both are set to the entire Client Window, so there will
'* be no visible affect.  To see the affect of setting a clipping region,
'* select the "ClipPath" menu item.
'*
  rect.xRight  = cxClient% + 1
  rect.xLeft   = 0
  rect.yTop    = cyClient% + 1
  rect.yBottom = 0
'*
'* Set Viewing Limits and Graphics Field equal to entire Client Window.
'* Adding one to the right and top limits is needed since the fields
'* set by the following to CALLs include the left and bottom edges specified
'* in the RECTL structure, but the top and right limits are not, so to
'* set fields to entire Client Window, 1 must be added to the top and
'* bottom values.
'*
  bool% = GpiSetViewingLimits(hps&, MakeLong(VARSEG(rect), VARPTR(rect)))
  bool% = GpiSetGraphicsField(hps&, MakeLong(VARSEG(rect), VARPTR(rect)))
'*
'* Query Values just set above, and then write the return values out
'* the the file GpiPath.OUT
'*
  bool% = GpiQueryViewingLimits(hps&, MakeLong(VARSEG(rect), VARPTR(rect)))
  PRINT #1,"GpiQueryViewingLimits:", bool%
  PRINT #1,"("; rect.xLeft;  ","; rect.yBottom;")-(";_
                rect.xRight; ","; rect.yTop;   ")"
  bool% = GpiQueryGraphicsField(hps&, MakeLong(VARSEG(rect), VARPTR(rect)))
  PRINT #1,"GpiQueryGraphicsField:", bool%
  PRINT #1,"("; rect.xLeft;  ","; rect.yBottom;")-(";_
                rect.xRight; ","; rect.yTop;   ")"
'*
'* Divide Client Window into divisions of 10, to be used to set values
'* for design
'*
  xdiv% = cxClient% \ 10
  ydiv% = cyClient% \ 10
'*
'* Calculate points for design to be proportional to Client window
'*
  aptl(0).x = xdiv%     :  aptl(0).y = ydiv%
  aptl(1).x = xdiv% * 9 :  aptl(1).y = ydiv% * 9
  aptl(2).x = xdiv% * 6 :  aptl(2).y = ydiv% * 9
  aptl(3).x = xdiv% * 6 :  aptl(3).y = ydiv%
  aptl(4).x = xdiv% * 9 :  aptl(4).y = ydiv%
  aptl(5).x = xdiv%     :  aptl(5).y = ydiv% * 9
  aptl(6).x = xdiv% * 4 :  aptl(6).y = ydiv% * 9
  aptl(7).x = xdiv% * 4 :  aptl(7).y = ydiv%
'*
'* Set Line End, Join, and Width to selected values
'*
  bool% = GpiSetLineEnd      (hps&, lineend&)
  bool% = GpiSetLineJoin     (hps&, linejoin&)
  bool% = GpiSetLineWidthGeom(hps&, linewidth&)     
'*
'* Query Line End, Join, and Width values and write out to GpiPath.OUT
'*
  PRINT #1,"GpiSetLineEnd:       "; GpiQueryLineEnd      (hps&)
  PRINT #1,"GpiSetLineJoin:      "; GpiQueryLineJoin     (hps&)
  PRINT #1,"GpiSetLineWidthGeom: "; GpiQueryLineWidthGeom(hps&) 
'*
'* Mark beginning of Path, move to first point of design.  Display
'* design using points store in aptl(), then close figure conecting
'* the last and first points drawn.  If this is not done, GpiStrokePath
'* or GpiFillPath will do this for you
'*
  bool% = GpiBeginPath  (hps&, 1)
  bool% = GpiMove       (hps&,    MakeLong(VARSEG(aptl(0)), VARPTR(aptl(0))))
  bool% = GpiPolyLine   (hps&, 7, MakeLong(VARSEG(aptl(1)), VARPTR(aptl(1))))
  bool% = GpiCloseFigure(hps&)
'*
'* Draw three short line segments on either side of main design.  These
'* lines are used to show the "LineEnd" type selected.
'*
  CALL DrawShortLineSegments(xdiv%, ydiv%)
'*
'* Mark end of path
'*
  bool% = GpiEndPath(hps&)
'*
'* Draw path, using one of the following methods, depending on which
'* menu item was selected.  "ModifyPath" causes the path itself to
'* be filled or used as the clipping region, instead of the interior
'* of the path.
'*
  SELECT CASE path%
    CASE 0
      bool% = GpiStrokePath(hps&, 1, 0)
    CASE 1, 2
      IF path% = 1 THEN bool% = GpiModifyPath(hps&, 1, MPATHSTROKE)
      bool% = GpiFillPath(hps&, 1, FPATHALTERNATE)
    CASE 3, 4
      IF path% = 3 THEN bool% = GpiModifyPath(hps&, 1, MPATHSTROKE)  
      bool% = GpiSetClipPath(hps&, 1, SCPAND)
    '*
    '* Display text to show clipping
    '*
      CALL FillClipPathWithText

  END SELECT

  CALL MarkActualPathWithRedLines(xdiv%, ydiv%)

  bool% = WinEndPaint(hps&)

END SUB


'**************************************************************************
'* This routine simply draws the the path defined above, in RED and only
'* one pixel wide, using the standard line drawing routine of GpiPolyline
'* and GpiLine.
'*
SUB MarkActualPathWithRedLines(xdiv%, ydiv%)
SHARED hps&

  bool% = GpiSetColor(hps&, CLRRED)
  bool% = GpiMove    (hps&,    MakeLong(VARSEG(aptl(7)), VARPTR(aptl(7))))
  bool% = GpiPolyLine(hps&, 8, MakeLong(VARSEG(aptl(0)), VARPTR(aptl(0))))
  CALL DrawShortLineSegments(xdiv%, ydiv%)

END SUB


'**************************************************************************
'* This routine draws the three short line segments on either side of the
'* main design.  This routine is CALLed twice, once from within the PATH
'* and once from outside the path.  The SUB "MarkActualPathWithRedLines"
'* CALLs this routine from outside the PATH to show actual PATH, on one
'* pixel wide.
'*
SUB DrawShortLineSegments(xdiv%, ydiv%)
SHARED hps&
DIM ptl(1) AS POINTL

  ptl(0).x = xdiv%
  ptl(1).x = xdiv% * 2
  FOR N%   = 1 TO 2
    ptl(0).y = ydiv% * 3
    FOR I%   = 1 TO 3
      ptl(0).y = ptl(0).y + ydiv%
      ptl(1).y = ptl(0).y
      bool%    = GpiMove(hps&, MakeLong(VARSEG(ptl(0)), VARPTR(ptl(0))))
      bool%    = Gpiline(hps&, MakeLong(VARSEG(ptl(1)), VARPTR(ptl(1))))
    NEXT I%
    ptl(0).x = xdiv% * 8
    ptl(1).x = xdiv% * 9
  NEXT N%

END SUB


'**************************************************************************
'* This routine displays text as to fill the entire Client Window, however
'* only the text that falls within the clipped region is visible.
'*
SUB FillClipPathWithText
SHARED hps&, cyClient%
DIM ptl AS POINTL

  text$   = "This is the text that is only diplayed within the clipped path"
  text$   = text$ + text$ + CHR$(0)
  ptl.x   = 0
  FOR Y%  = 0 TO cyClient% STEP 16
    ptl.y = Y%
    bool% = GpiCharStringAt(hps&,_
            MakeLong(VARSEG(ptl),   VARPTR(ptl)), 124,_
            MakeLong(VARSEG(text$), SADD(text$)))
  NEXT Y%
END SUB
  
