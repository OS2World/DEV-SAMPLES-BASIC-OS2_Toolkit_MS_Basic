'³*****************************************************************
'³
'³ Module:       AreaMod.bas
'³
'³ Subprograms:  DemoPatterns
'³               DemoBeginEndArea
'³               - ClientWndProc1 - DialogBox procedure used in
'³                                  DemoBeginEndArea
'³
'³ Description:  AreaMod contains many different Presentation Manager
'³               CALL, however, it essentially demonstrates only two
'³               areas: Fill patters & colors, and the Begin/End Area
'³               CALLS, i.e. "DemoPatterns" and "DemoBeginEndArea".
'³               "ClientWndProc1" is a SUBprogram CALLed externally
'³               by the Presentation Manager.  "ClientWndProc1" is
'³               registered from within "DemoBeginEndArea" with the
'³               CALL to WinDlgBox.  This SUBprogram is the controling
'³               procedure for the DialogBox used in the DemoBeginArea
'³               SUBprogram.
'³
'³*********************************************************************

REM $INCLUDE: 'os2def.bi'
REM $INCLUDE: 'pmbase.bi'
REM $INCLUDE: 'windialg.bi'
REM $INCLUDE: 'winmisc.bi'
REM $INCLUDE: 'gpiline.bi'
REM $INCLUDE: 'gpiarea.bi'
REM $INCLUDE: 'gpiarc.bi'
REM $INCLUDE: 'gpicolor.bi'

DECLARE FUNCTION DisplayMessageBox%(message$, caption$)

COMMON /Gdemo/ cxClient%, cyClient%
CONST       IDMAREA      = 30
CONST       IDDGETPOINTS = 1


'³**************************************************************
'³ DemoPattern divides the Client window into 15 rows and columns
'³ and then fill each row with a different color from the default color
'³ table.  Each column represents a different fill pattern from the
'³ default pattern set.  Each box in the window is actually draw and
'³ filled separately, starting at the lower left hand corner of the
'³ window, ending at the upper right hand corner.
'³
SUB DemoPatterns(hps&)
SHARED cxClient%, cyClient%
DIM ptl(1) AS POINTL
  '³
  '³ Divide Client window into 15 rows and columns
  '³
  xdiv15& = cxClient% / 15
  ydiv15& = cyClient% / 15
  '³
  '³ Step through colors
  '³
  FOR fcolor% = 1 to 15
    bool% = GpiSetColor(hps&, fcolor%)
    ptl(0).y = ptl(0).Y + ydiv15&
    ptl(0).x = 0
    '³
    '³ Step through patterns
    '³
    FOR pattern& = 0 to 14
      bool% = GpiSetPattern(hps&, pattern&)
      '³
      '³ ptl(0) is upper right hand corner of box
      '³ ptl(1) is lower left hand corner of box
      '³
      ptl(1).x = ptl(0).x : ptl(1).y = ptl(0).y - ydiv15&
      ptl(0).x = ptl(0).x + xdiv15&

      bool% = GpiMove(hps&, MakeLong(Varseg(ptl(0)), Varptr(ptl(0))))
      bool% = GpiBox(hps&, DROOUTLINEFILL,_
                     MakeLong(Varseg(ptl(1)), Varptr(ptl(1))),0,0)

    NEXT pattern&
  NEXT fcolor%

END SUB


'³**************************************************************
'³ DemoBeginEndArea demonstrates the ability of GpiBegin & End area
'³ to fill a very complex area.  A random design generated from one
'³ of three different Gpi CALLS:
'³
'³          GpiPolyLine - generates a design from straight lines
'³        GpiPolyFillet - generates a design from continuous randomly
'³                         curving line.
'³   GpiPolyFilletSharp - generates a design from many individual curved
'³                        lines.
'³
'³ A number of random points are generated and then stored in the array
'³ "aptl().  The number of points used is selected by the user, which
'³ is inputed through the use of a dialog box, which is control by the
'³ procudure ClientWndProc1.  The default number of points if 50.
'³ Once the points are generated, the pattern is drawn and filled, using
'³ one of the above Gpi routines, depending on which item was selected
'³ from the menu.  If this routine is called due to a WMPAINT message
'³ the dialog box is not displayed and the window is simply repainted
'³ using the previous set of points, this is flagged by a negative
'³ value in "hwnd&".  The dclicked% value determines if a set of new
'³ points should be generated.  If the routine is CALLed due to a
'³ WMCOMMAND message (selected from the menu), or if the user clicked
'³ on the Client window with a design already displayed, then a new set
'³ of points is generated, giving a new design.  Clicking on the Client
'³ window with a design already displayed will allow a new design to
'³ be generated without going through the menu selection.
'³
SUB DemoBeginEndArea(hwnd&, hps&, lastgpi%, dclicked%) STATIC
SHARED cxClient%, cyClient%, points&
DIM aptl(100) AS POINTL
  '³
  '³ If this is first CALL set default number of points
  '³
  IF points& = 0 THEN points& = 50
  '³
  '³ If hwnd& > 0 then allow user to select new number of points
  '³
  IF hwnd& > 0 THEN bool% = WinDlgBox(HWNDDESKTOP, hwnd&,_
                                      RegBas1, 0, IDDGETPOINTS, 0)
  '³
  '³ Set new seed for RND function then generate the select number
  '³ of points to be used for the design.
  '³
  RANDOMIZE TIMER
  IF dclicked% = 1 THEN
    FOR I% = 0 to points&
      aptl(I%).x = INT((cxClient% + 1) * RND)
      aptl(I%).y = INT((cyClient% + 1) * RND)
    NEXT I%
  END IF
  '³
  '³ Set last point equal to first point so that the pattern is
  '³ enclosed.  GpiEndArea will actually close a figure for you if
  '³ you don't explicitly do it yourself.
  '³
  aptl(points&).x = aptl(0).x
  aptl(points&).y = aptl(0).y
  '³
  '³ Move to starting point
  '³
  bool% = GpiMove(hps&, MakeLong(Varseg(aptl(0)), Varptr(aptl(0))))
  '³
  '³ Mark begining of area to be filled
  '³
  bool% = GpiBeginArea(hps&,BAALTERNATE OR BANOBOUNDARY)
  '³
  '³ "lastgpi%" contains ID of menuitem selected.  Use "lastgpi%"
  '³ to determine which Gpi routine to use to generated the design.
  '³
  SELECT CASE lastgpi%
    CASE IDMAREA+3
      bool% = GpiPolyLine(hps&, points&,_
                          MakeLong(Varseg(aptl(1)), Varptr(aptl(1))))
    CASE IDMAREA+4
      bool% = GpiPolyFillet(hps&, points&,_
                            MakeLong(Varseg(aptl(1)), Varptr(aptl(1))))
    CASE IDMAREA+5             
      sharp& =  2 ^ 16
      bool% = GpiPolyFilletSharp(hps&, points&,_
                                 MakeLong(VARSEG(aptl(1)), VARPTR(aptl(1))),_
                                 MakeLong(VARSEG(sharp&), VARPTR(sharp&)))
  END SELECT
  '³
  '³ Mark end of area, and fill it using current color and pattern
  '³
  bool% = GpiEndArea(hps&)

END SUB

'³**************************************************************
'³ ClientWndProc1 controls the use of the dialog box registered and displayed
'³ with the CALL to WinDlgBox in DemoBeginEndArea.  It consists simply of
'³ a title, a static display field which displays current number of points
'³ selected, a horizontal scrollbar which is used to select points by sliding
'³ left to decrease number and sliding right to increase number ( minimum
'³ number is 3, maximum number is 100), and an "OK" pushbutton used to
'³ enter your selection.
'³
FUNCTION ClientWndProc1& (hwnd&, msg%, mp1&, mp2&)
SHARED points&

  SELECT CASE msg%
  '³
  '³ Initialize dialogbox before it is displayed
  '³
    CASE WMINITDLG
      c$ = ltrim$(str$(points&))+chr$(0)
    '³
    '³ Set display field to current number of points selected
    '³
      bool% = WinSetDlgItemText(hwnd&,IDDGETPOINTS+2,_
                                MakeLong(VARSEG(c$), SADD(c$)))
    '³
    '³ Set scrollbar to relative position for current number of points
    '³ and set the low and upper bounds for the scrollbar, 3 to 100
    '³
      bool& = WinSendDlgItemMsg(hwnd&, IDDGETPOINTS+1,_
                                SBMSETSCROLLBAR,_
                                points&,_
                                MakeLong(100,3))
      ClientWndProc1& = 0
    '³
    '³ Exit and erase dialogbox.  This occurs when the "OK" pushbutton
    '³ is selected
    '³
    CASE WMCOMMAND
      bool% = WinDismissDlg(hwnd&, TRUE)
      ClientWndProc1& = 0
    '³
    '³ When any part of the scrollbar is clicked, this section of code
    '³ is executed, due to the WMHSCROLL message.  The ID of the actual
    '³ part of the scrollbar that was clicked is contained in the highword
    '³ mp2& and extracted to hcommand%.  The point value (3 to 100) for
    '³ the current location of the scrollbar slider is contained in the
    '³ lowword of mp2& and extracted to lowword%.
    '³
    CASE WMHSCROLL
      CALL BreakLong(mp2&, hcommand%, lowword%)
      SELECT CASE hcommand%
        CASE SBLINELEFT
          points& = points& - 1
          if points& = 2 then points& = 3
        CASE SBPAGELEFT
          points& = points& - 10
          if points& < 3 then points& = 3
        CASE SBLINERIGHT
          points& = points& + 1
          IF points& = 101 THEN points& = 100
        CASE SBPAGERIGHT
          points& = points& + 10
          IF points& > 100 THEN points& = 100
        CASE SBSLIDERTRACK
          points& = lowword%
        CASE ELSE
      END SELECT
      '³
      '³ Do not update scrollbar slider if user has clicked on the slider
      '³ itself and is sliding it from left to right.  Once the mouse
      '³ button is released, then update the scrollbar slider to its
      '³ position.  If this is not done, random garbage lines are left
      '³ on the scrollbar as it is move from left to right.
      '³
      IF hcommand% <> SBSLIDERTRACK THEN
        bool& = WinSendDlgItemMsg(hwnd&, IDDGETPOINTS+1,_
                                  SBMSETPOS,_
                                  points&,_
                                  0)
      END IF
      '³
      '³ Set display field to new number of points
      '³
      C$ = LTRIM$(STR$(points&))+CHR$(0)
      bool% = WinSetDlgItemText(hwnd&,IDDGETPOINTS+2,_
                                MakeLong(VARSEG(c$), SADD(c$)))
      ClientWndProc1& = 0

    CASE ELSE
      ClientWndProc1& = WinDefDlgProc(hwnd&, msg%, mp1&, mp2&)

  END SELECT
END FUNCTION

