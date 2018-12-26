'³*****************************************************************
'³
'³ Module:       BitMod.bas
'³
'³ Subprograms:  Demo1PlaneBitmap
'³               Demo4PlaneBitMap
'³               DemoSystemBitmaps
'³               DemoResizeBitmap
'³               DemoCaptureAndMagnify
'³               DemoFillWithBitmap
'³
'³ Description:  BitMod demonstrates most of the Bitmap routines available
'³               with the Presentation Manager, and many others that do not
'³               deal directly with bitmaps.  Due to the need for many of
'³               the routines defined in a variaty of different Include
'³               files, compiler work space was getting low, so several
'³               FUNCTION and CONST declarations were cut and pasted into
'³               BITMOD.INC.  Each SUBprogram in this module has its own
'³               menuitem under the top level menuitem "Bitmaps".  Several
'³               of these routines essentially use the same calls, but all
'³               demonstrate several different ways of manipulating bitmaps.
'³
'³               Three different bitmaps are used throughout these routines
'³               all of which are stored in the programs resouce.
'³
'³***************************************************************************

REM $INCLUDE: 'os2def.bi'
REM $INCLUDE: 'pmbase.bi'
REM $INCLUDE: 'winman1.bi'
REM $INCLUDE: 'winsys.bi'
REM $INCLUDE: 'winpoint.bi'
REM $INCLUDE: 'wintrack.bi'
REM $INCLUDE: 'gpibit.bi'
REM $INCLUDE: 'gpicolor.bi'
REM $INCLUDE: 'gpiarea.bi'
REM $INCLUDE: 'gpiline.bi'

REM $INCLUDE: 'BITMOD.INC'

COMMON /Gdemo/ cxClient%, cyClient%

'³
'³ Demo1PlaneBitmap loads bitmap #1, which is a 99 x 99 bitmap created
'³ with Iconedit.EXE.  This is a signle plane bitmap with 1 bitcount,
'³ meaning each pixel displayed is represented by only one bit, which
'³ means only two colors can be displayed, one forground and one background.
'³ The Client window is divided into 20 equal boxes, the bitmap is loaded
'³ and then displayed stretched and displayed to fill each area on the
'³ screen in a different color.
'³

SUB Demo1PlaneBitmap(hps&)
SHARED cxClient%, cyClient%
DIM aptl(3) AS POINTL
  '³
  '³ Divide Client window in to 20 equal areas
  '³
  xdiv4% = cxClient% / 5
  ydiv4% = cyClient% / 4
  '³
  '³ Load bitmap1 from progams resource and store handle in hbm&
  '³
  hbm& = GpiLoadBitmap(hps&, 0, IDBBITMAP1, 0, 0)
  '³
  '³ For the first and only the first bitmap drawn, set background color
  '³ to black so a forground color of white can be used.  For every succeeding
  '³ bitmap, a white background is used.
  '³
  bcolor% = CLRBLACK
  '³
  '³ aptl(0) contains lower left hand corner of target area on screen
  '³ aptl(1) contains upper right hand corner of target area on screen
  '³
  FOR X% = 0 to 4
    aptl(0).x = X% * xdiv4%
    aptl(1).x = aptl(0).x + xdiv4%
    FOR Y% = 0 to 3
      aptl(0).y = Y% * ydiv4%
      aptl(1).y = aptl(0).y + ydiv4%
      bool% = WinDrawBitmap(hps&, hbm&, 0,_
                            MakeLong(VARSEG(aptl(0)), VARPTR(aptl(0))),_
                            fcolor%, bcolor%, DBMSTRETCH)
      '³
      '³ Incriment forground color.  Reset to 1 when at end of default
      '³ color table.
      '³
      fcolor% = fcolor% + 1
      if fcolor% = 16 then fcolor% = 1
      bcolor% = CLRWHITE
    NEXT Y%
  NEXT X%
END SUB


'³*****************************************************************
'³ Demo4PlaneBitMap is a very simple routine.  It first sets the system
'³ pointer to an hourglass to signify the bitmap is being loaded, since it
'³ takes a few seconds to load and display.  It the loads the bitmap from
'³ the programs resource, and displays it to fill the Client window.
'³
SUB Demo4PlaneBitMap(hps&)
SHARED cxClient%, cyClient%
DIM ptl AS POINTL, aptl(3) AS POINTL, rect AS RECTL
DIM bmpinfo AS BITMAPINFOHEADER 
  '³
  '³ Set system ponter to hourglass
  '³
  bool% = WinSetPointer(HWNDDESKTOP,_
                        WinQuerySysPointer(HWNDDESKTOP, SPTRWAIT, 0))
  '³
  '³ Load bitmap2 from programs resource and store handle in hbm&
  '³
  hbm& = GpiLoadBitmap(hps&, 0, IDBBITMAP2, 0, 0)
  bool% = GpiQueryBitmapParameters(hbm&,_
                                   MakeLong(VARSEG(bmpinfo), VARPTR(bmpinfo)))

  '³
  '³ aptl(0) contains lower left hand corner of target area
  '³ aptl(1) contains upper right hand corne of target area
  '³ aptl(2) contains lower right hand corner of source area
  '³ aptl(3) contains upper right hand corner of source area
  '³
  '³ aptl(2) and aptl(3) are set so as to use the entire bitmap
  '³ aptl(0) and aptl(1) are set so as to fill the entire Client window
  '³
  aptl(0).x = 0
  aptl(0).y = 0
  aptl(1).x = cxClient%
  aptl(1).y = cyClient%
  aptl(2).x = 0
  aptl(2).y = 0
  aptl(3).x = bmpinfo.cx
  aptl(3).y = bmpinfo.cy
  '³
  '³ Display bitmap
  '³
  bool% = GpiWCBitBlt(hps&, hbm&, 4&,_
                    MakeLong(VARSEG(aptl(0)), VARPTR(aptl(0))),_
                    ROPSRCCOPY, BBOAND)
  '³
  '³ Release bitmap handle
  '³
  bool% = GpiDeleteBitmap(hbm&)

END SUB


'³*****************************************************************
'³ DemoSystemBitmaps, depending on the menuitem selected, will display all
'³ the available system bitmaps at the same time, magnifying them to fill
'³ the client window, or will display one at a time in its actual size, but
'³ fills the client window with multiple copies of the bitmap
'³
SUB DemoSystemBitmaps(hps&, lastgpi%)
SHARED cxClient%, cyClient%
DIM aptl(1) AS POINTL, ptl AS POINTL, rect AS RECTL
DIM bmpinfo AS BITMAPINFOHEADER

IF lastgpi% = ShowAllSysBitmaps THEN
'³
'³ Display all system bitmaps at once if lastgpi% = ShowAllSysBitmaps
'³
'³ Divide the Client window into 20 equal areas
'³
  xdiv5% = cxClient% / 5
  ydiv4% = cyClient% / 4
  '³
  '³ Begin at first system bitmap
  '³
  bitmapnum% = 1
  FOR X% = 0 TO 4
  '³
  '³ aptl(0) contains lower left hand corner of target area
  '³ aptl(1) contains upper right hand corner of target area
  '³
    aptl(0).x = X% * xdiv5%
    aptl(1).x = aptl(1).x + xdiv5%
    FOR Y% = 0 TO 3
      aptl(0).y = Y% * ydiv4%
      aptl(1).y = aptl(0).y + ydiv4%
      '³
      '³ The ID numbers for the system bitmaps is not continuous.
      '³ There is no corresponding bitmap for numbers 13,14,20, or 21
      '³ so they are skipped.
      '³
      While (bitmapnum% = 13 OR bitmapnum% = 14 OR_
             bitmapnum% = 20 OR bitmapnum% = 21)
        bitmapnum% = bitmapnum% + 1
      WEND
      '³
      '³ Retrieve bitmap corresponding to bitmapnum%
      '³
      hbm& = WinGetSysBitmap(HWNDDESKTOP, bitmapnum%)
      bitmapnum% = bitmapnum% + 1
      '³
      '³ Display bitmap filling area defined by aplt(0) and aplt(1)
      '³
      bool% = WinDrawBitmap(hps&, hbm&, 0,_
                            MakeLong(VARSEG(aptl(0)), VARPTR(aptl(0))),_
                            CLRNEUTRAL, CLRBACKGROUND, DBMSTRETCH)
    NEXT Y%
  NEXT X%
ELSE
'³
'³ The following fills the Client window the select bitmap, using its actual
'³ size
'³
'³ The menu ID number is used to determine which bitmap to be displayed, and
'³ the menu ID numbers were defined as 70 greater than the actual bitmap
'³ ID, so 70 must be subtracted to obtain the actual ID.  See the GpiDemo.RC.
'³
  bitmap% = lastgpi% - 70
  hbm& = WinGetSysBitmap(HWNDDESKTOP, bitmap%)
  '³
  '³ Determine actual size of bitmap
  '³
  bool% = GpiQueryBitmapParameters(hbm&,_
                                   MakeLong(VARSEG(bmpinfo), VARPTR(bmpinfo)))
  '³
  '³ Fill the Client window with RED.  This will display a narrow RED line
  '³ between each bitmap, since the bitmaps are draw a few pixels apart.
  '³ This helps distinguish the actual size of the bitmap.
  '³
  rect.xleft = 0
  rect.xright = cxClient%
  rect.ytop = cyClient%
  rect.ybottom = 0
  bool% = WinFillRect(hps&, MakeLong(VARSEG(rect), VARPTR(rect)), CLRRED)
  '³
  '³ Fill the screen with the selected bitmap
  '³
  FOR X% = 0 TO cxClient% STEP bmpinfo.cx + 2
    FOR Y% = 0 TO cyClient% STEP bmpinfo.cy + 2
      ptl.x = X%
      ptl.y = Y%
      bool% = WinDrawBitmap(hps&, hbm&, 0,_
                            MakeLong(VARSEG(ptl), VARPTR(ptl)),_
                            CLRNEUTRAL, CLRBACKGROUND, DBMNORMAL)
    NEXT Y%
  NEXT X%
END IF
END SUB


'³*****************************************************************
'³ DemoResizeBitmap essentially does the same thing as the above routines,
'³ stretches or compresses a bitmap, but with the aid of the WinTrackRect
'³ routine, it does it in a way that is much more visible.  You see the
'³ original bitmap, and the user then, using the mouse, selects the new
'³ size of the bitmap.  The mouse is moved resize the window tracking
'³ rectangle, and then clicks the left mouse button to display the bitmap
'³ as it new size.
'³
SUB DemoResizeBitmap(hwnd&, hps&) STATIC
SHARED cxClient%, cyClient%
DIM ti AS TRACKINFO, aptl(1) AS POINTL
  '³
  '³ Load bitmap from programs resource and store handle in hbm&
  '³
  hbm& = GpiLoadBitmap(hps&, 0, IDBBITMAP1, 0, 0)
  '³
  '³ If this is the first call to this routine, set default values for
  '³ bitmap size and tracking rectangle size, otherwize, use current values.
  '³ Values are retained due to the STATIC following the SUB statment.
  If Demoed% = 0 THEN
    '³
    '³ Tracking rectangle default values.  Slightly larger than the bitmap.
    '³
    ti.rclTrack.xleft = 0
    ti.rclTrack.yBottom = 0
    ti.rclTrack.xRight = 110
    ti.rclTrack.ytop = 110
    '³
    '³ Default values for the bitmap.  Draws bitmap actual size.
    '³
    aptl(0).x = 0
    aptl(0).y = 0
    aptl(1).x = 98
    aptl(1).y = 98
    demoed% = 1
  END IF
  '³
  '³ Display bitmap using current size
  '³
  bool% = WinDrawBitmap(hps&, hbm&, 0,_
                        MakeLong(VARSEG(aptl(0)), VARPTR(aptl(0))),_
                        CLRNEUTRAL, CLRBACKGROUND, DBMSTRETCH)
  '³
  '³ Initialize tracking rectangle information.  See QuickHELP or
  '³ OS/2 Programmers reference VOL 2 for a detailed description of the
  '³ fields of "ti" defined as TRACKINFO.
  '³
  ti.cxBorder = 1
  ti.cyBorder = 1
  ti.cxKeyboard = 4
  ti.cyKeyboard = 4
  ti.rclBoundary.xleft = 0
  ti.rclBoundary.ybottom = 0
  ti.rclBoundary.xright = cxClient%
  ti.rclBoundary.ytop = cyClient%
  ti.ptlMinTrackSize.x = 1
  ti.ptlMinTrackSize.y = 1
  ti.ptlMaxTrackSize.x = cxClient%
  ti.ptlMaxTrackSize.y = cyClient%
  ti.fs = TFTOP OR TFRIGHT OR TFSTANDARD OR TFSETPOINTERPOS
  '³
  '³ Set system pointer to a four point pointer to signify movement in
  '³ all directions.
  '³
  bool% = WinSetPointer(HWNDDESKTOP,_
                        WinQuerySysPointer(HWNDDESKTOP, SPTRMOVE, 0))
  '³
  '³ Resize tracking rectangle.  WinTrackRect does not return until
  '³ the left mouse button is clicked.
  '³
  bool% = WinTrackRect(hwnd&, 0,_
                       MakeLong(VARSEG(ti), VARPTR(ti)))
  '³
  '³ Obtain resulting rectangle size to be used as new bitmap size.
  '³
  aptl(1).x = ti.rclTrack.xRight
  aptl(1).y = ti.rclTrack.ytop
  '³
  '³ Fill new rectangle with RED.  This is done only to let the user know
  '³ that something is going on, since if the new rectangle is quite large,
  '³ it can take a few seconds to display the bitmap.
  '³
  bool% = WinFillRect(hps&,_
                      MakeLong(VARSEG(ti.rclTrack), VARPTR(ti.rclTrack)),_
                      CLRRED)
  '³
  '³ Draw the bitmap using its new size
  '³
  bool% = WinDrawBitmap(hps&, hbm&, 0,_
                        MakeLong(VARSEG(aptl(0)), VARPTR(aptl(0))),_
                        CLRNEUTRAL, CLRBACKGROUND, DBMSTRETCH)
  '³
  '³ Release bitmap handle
  '³
  bool% = GpiDeleteBitmap(hbm&)

END SUB


'³*****************************************************************
'³ DemoCaptureAndMagnify use the WinTractRect to select an area of the screen
'³ to capture and store as a bitmap.  Once the bitmap is stored, it is stretched
'³ or compressed to fill the client window.  Three presentation spaces are needed
'³ for this operation:
'³
'³   1. The Client window, where the bitmap will finally be displayed.
'³   2. A Screen presentation space where the bitmap is captured from.  The
'³      entire screen is available to be captured.  For a visual explanation
'³      of this, click the restore icon prior to selecting capture bitmap from
'³      the menu so this applications window does not take up the entire screen.
'³   3. A memory presentation space where the bitmap is stored after being
'³      captured, so it can be quickly redrawn when a WMPAINT message is
'³      executed.
'³
SUB DemoCaptureAndMagnify(hab&, hwndFrame&, shwnd&, hps&) STATIC
SHARED cxClient%, cyClient%
DIM ti AS TRACKINFO, aptl(3) AS POINTL
DIM sizl AS POINTL, bi AS BITMAPINFOHEADER

  hwnd& = ABS(shwnd&)
  '³
  '³ If shwnd& is negative, this routine was called due to a WMPAINT
  '³ message, therefore a new bitmap is not to be captured. Everything
  '³ in the SUBprogram is skipped except the previous bitmap captured is
  '³ redrawn.
  '³
  IF shwnd& > 0 THEN
  '³
  '³ Instructions for using "Capture Bitmap"
  '³
    message$="Position pointer to upper-left corner of area "+_
             "to be captured, then click left mouse button.  "+_
             "Stretch box around area to be captured, then "+_
             "click left mouse button again." + CHR$(0)
    caption$ = ""+CHR$(0)
  '³
  '³ Display instructions and determine if user really wants to capture
  '³ a bitmap.  If value returned from WinMessageBox is MBIDOK then
  '³ capture a new bitmap, otherwise, display previous bitmap.
  '³
    IF  WinMessageBox(HWNDDESKTOP, HWNDDESKTOP,_
                      MakeLong(VARSEG(message$), SADD(message$)),_
                      MakeLong(VARSEG(caption$), SADD(caption$)),_
                      0,_
                      MBOKCANCEL OR_
                      MBICONASTERISK) = MBIDOK THEN
    '³
    '³ Release previous bitmap handle, and the presentation space where the
    '³ bitmap is stored, and the Device Context associated with the
    '³ presentation space.
    '³
      bool% = GpiDeleteBitmap(hbm&)
      bool% = GpiDestroyPS(hps3&)
      bool% = DevCloseDC(hdc&)
    '³
    '³ Initialize tracking rectangle information.  See QuickHELP or
    '³ OS/2 Programmers reference VOL 2 for a detailed description of the
    '³ fields of "ti" defined as TRACKINFO.
    '³
      ti.cxBorder = 1
      ti.cyBorder = 1
      ti.cxGrid = 0
      ti.cyGrid = 0
      ti.cxKeyboard = 4
      ti.cyKeyboard = 4
      ti.rclBoundary.xleft = 0
      ti.rclBoundary.ybottom = 0
      ti.rclBoundary.xright = WinQuerySysValue(HWNDDESKTOP, SVCXSCREEN)
      ti.rclBoundary.ytop = WinQuerySysValue(HWNDDESKTOP, SVCYSCREEN)
      ti.ptlMinTrackSize.x = 1
      ti.ptlMinTrackSize.y = 1
      ti.ptlMaxTrackSize.x = ti.rclBoundary.xright
      ti.ptlMaxTrackSize.y = ti.rclBoundary.ytop
      ti.rclTrack.xleft = ti.rclBoundary.xright / 2
      ti.rclTrack.yBottom = ti.rclBoundary.ytop / 2
      ti.rclTrack.xRight = ti.rclBoundary.xright / 2
      ti.rclTrack.ytop = ti.rclBoundary.ytop / 2
      ti.fs = TFMOVE OR TFSTANDARD OR TFSETPOINTERPOS
    '³
    '³ Obtain a Screen Presentation Space
    '³
      hps2& = WinGetScreenPS(HWNDDESKTOP)
    '³
    '³ Set pointer to four point system pointer as in "Resize Bitmap"
    '³
      bool% = WinSetPointer(HWNDDESKTOP,_
                            WinQuerySysPointer(HWNDDESKTOP, SPTRMOVE, 0))
    '³
    '³ Obtain upper left hand corner of area to be captured.  The tracking
    '³ rectangle is simply a single pixel during this call to WinTrackRect
    '³ so only the pointer is visible.  When the left mouse button is
    '³ clicked, WinTractRect returns, new parameters are set which allow
    '³ the rectangle to be resized down and to the right of the selected
    '³ upper left hand corner of the the area to be captured.
    '³
      bool% = WinTrackRect(HWNDDESKTOP, 0,_
                           MakeLong(VARSEG(ti), VARPTR(ti)))
    '³
    '³ Set new parameters for tracking rectangle.  Can only expand
    '³ rectangle down or to the right.
    '³
      ti.fs = TFBOTTOM OR TFRIGHT OR TFSTANDARD OR TFSETPOINTERPOS
    '³
    '³ Obtain area to be captured
    '³
      bool% = WinTrackRect(HWNDDESKTOP, 0,_
                           MakeLong(VARSEG(ti), VARPTR(ti)))
    '³
    '³ Initialize bitmap information
    '³
      bi.cbFix = LEN(bi)
      bi.cx = ti.rclTrack.xright - ti.rclTrack.xleft
      bi.cy = ti.rclTrack.ytop - ti.rclTrack.ybottom
      bi.cPlanes = 1
      bi.cBitCount = 4
    '³
    '³ Initialize information for Memory Device Context, then open
    '³ a memory device context.
    '³
      token$ = "*" + CHR$(0)
      sizl.x = bi.cx
      sizl.y = bi.cy
      hdc& = DevOpenDC(hab&, ODMEMORY,_
                       MakeLong(VARSEG(token$), SADD(token$)), 0, 0, 0)
    '³
    '³ Create a micro presentation space and associate it with the memory
    '³ device context opened above.
    '³
      hps3& = GpiCreatePS(hab&, hdc&,_
                          MakeLong(VARSEG(sizl), VARPTR(sizl)),_
                          PUPELS OR GPIFDEFAULT OR GPITMICRO OR GPIAASSOC)
    '³
    '³ Create bitmap using information set previously and associate bitmap
    '³ with presentation space created above.
    '³
      hbm& = GpiCreateBitmap(hps3&,_
                             MakeLong(VARSEG(bi), VARPTR(bi)),_
                             0, 0, 0)
      bool% = GpiSetBitmap(hps3&, hbm&)
    '³
    '³ Set aptl() to source and target rectangles
    '³
      aptl(0).x = 0
      aptl(0).y = 0
      aptl(1).x = bi.cx
      aptl(1).y = bi.cy
      aptl(2).x = ti.rclTrack.xleft
      aptl(2).y = ti.rclTrack.ybottom
      aptl(3).x = ti.rclTrack.xright
      aptl(3).y = ti.rclTrack.ytop
    '³
    '³ Copy area defind by the rectangle returned by WinTractRect to the
    '³ micro presentation space created above.
    '³
      bool% = GpiBitBlt(hps3&, hps2&, 4&,_
                        MakeLong(VARSEG(aptl(0)), VARPTR(aptl(0))),_
                        ROPSRCCOPY, BBOAND)
    '³
    '³ Release the Screen presentation space
    '³
      bool% = WinReleasePS(hps2&)
    END IF
  END IF
'³
'³ Initialize source and target rectanges.  Target is now the Client Window
'³
  aptl(0).x = 0
  aptl(0).y = 0
  aptl(1).x = cxClient%
  aptl(1).y = cyClient%
  aptl(2).x = 0
  aptl(2).y = 0
  aptl(3).x = bi.cx
  aptl(3).y = bi.cy
'³
'³ Copy captured bitmap to the Client Window
'³
  bool% = GpiBitBlt(hps&, hps3&, 4&,_
                    MakeLong(VARSEG(aptl(0)), VARPTR(aptl(0))),_
                    ROPSRCCOPY, BBOAND)
END SUB


'³*****************************************************************
'³ DemoFillWithBitmap demonstrates how to use an 8 x 8 bitmap created
'³ with Iconedit.EXE as a fill pattern.  A crude picture is drawn, which
'³ sort of resembles a castle, and then is filled with the bitmap.
'³ the bitmap resembles bricks when used as a fill pattern.
'³
SUB DemoFillWithBitmap(hps&)
SHARED cxClient%, cyClient%
DIM pic(14) AS POINTL

  xdiv5% = cxClient% / 5
  ydiv4% = cyClient% / 4
'³
'³ Initialize pic() with points used to draw the picture.  The points
'³ are calculated to be proportional to the Client Window
'³
  pic(0).x = 0             : pic(0).y = 0
  pic(1).x = 0             : pic(1).y = 2 * ydiv4%
  pic(2).x = xdiv5%        : pic(2).y = 2 * ydiv4%
  pic(3).x = xdiv5%        : pic(3).y = ydiv4%
  pic(4).x = 2 * xdiv5%    : pic(4).y = ydiv4%
  pic(5).x = 2 * xdiv5%    : pic(5).y = 3 * ydiv4%
  pic(6).x = xdiv5%        : pic(6).y = 3 * ydiv4%
  pic(7).x = cxClient% / 2 : pic(7).y = cyClient%
  pic(8).x = 4 * xdiv5%    : pic(8).y = 3 * ydiv4%
  pic(9).x = 3 * xdiv5%    : pic(9).y = 3 * ydiv4%
  pic(10).x = 3 * xdiv5%   : pic(10).y = ydiv4%
  pic(11).x = 4 * xdiv5%   : pic(11).y = ydiv4%
  pic(12).x = 4 * xdiv5%   : pic(12).y = 2 * ydiv4%
  pic(13).x = cxClient%    : pic(13).y = 2 * ydiv4%
  pic(14).x = cxClient%    : pic(14).y = 0
'³
'³ Load Bitmap from programs resource.  Assigne the Bitmap an ID of 254.
'³ Set the current pattern set to 254 which has been defined as the bitmap.
'³ Select pattern set 254, the bitmap.  Set color to RED, to resemble bricks.
'³ Mark the beginning of of the picture.  Move to first point of picture,
'³ lower left corner of Client window.  Use GpiPolyLine to draw picture
'³ in one call, using points stored in pic().  Mark end of area and fill
'³ picture with current pattern and color, which is RED and the loaded
'³ bitmap.  Finally release the bitmap handle.
'³
  hbm&  = GpiLoadBitmap(hps&, 0, IDBBITMAP3, 0, 0)
  bool% = GpiSetBitmapId(hps&, hbm&, 254)
  bool% = GpiSetPatternSet(hps&, 254)
  bool% = GpiSetPattern(hps&, 254)
  bool% = GpiSetColor(hps&, CLRRED)
  bool% = GpiBeginArea(hps&, (BAALTERNATE OR BABOUNDARY))
  bool% = GpiMove(hps&, MakeLong(VARSEG(pic(0)), VARPTR(pic(0))))
  bool% = GpiPolyLine(hps&, 14&, MakeLong(VARSEG(pic(1)), VARPTR(pic(1))))
  bool% = GpiEndArea(hps&)
  bool% = GpiDeleteBitmap(hbm&)

END SUB

