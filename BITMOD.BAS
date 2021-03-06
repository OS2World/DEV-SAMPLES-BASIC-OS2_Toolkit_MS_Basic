'�*****************************************************************
'�
'� Module:       BitMod.bas
'�
'� Subprograms:  Demo1PlaneBitmap
'�               Demo4PlaneBitMap
'�               DemoSystemBitmaps
'�               DemoResizeBitmap
'�               DemoCaptureAndMagnify
'�               DemoFillWithBitmap
'�
'� Description:  BitMod demonstrates most of the Bitmap routines available
'�               with the Presentation Manager, and many others that do not
'�               deal directly with bitmaps.  Due to the need for many of
'�               the routines defined in a variaty of different Include
'�               files, compiler work space was getting low, so several
'�               FUNCTION and CONST declarations were cut and pasted into
'�               BITMOD.INC.  Each SUBprogram in this module has its own
'�               menuitem under the top level menuitem "Bitmaps".  Several
'�               of these routines essentially use the same calls, but all
'�               demonstrate several different ways of manipulating bitmaps.
'�
'�               Three different bitmaps are used throughout these routines
'�               all of which are stored in the programs resouce.
'�
'�***************************************************************************

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

'�
'� Demo1PlaneBitmap loads bitmap #1, which is a 99 x 99 bitmap created
'� with Iconedit.EXE.  This is a signle plane bitmap with 1 bitcount,
'� meaning each pixel displayed is represented by only one bit, which
'� means only two colors can be displayed, one forground and one background.
'� The Client window is divided into 20 equal boxes, the bitmap is loaded
'� and then displayed stretched and displayed to fill each area on the
'� screen in a different color.
'�

SUB Demo1PlaneBitmap(hps&)
SHARED cxClient%, cyClient%
DIM aptl(3) AS POINTL
  '�
  '� Divide Client window in to 20 equal areas
  '�
  xdiv4% = cxClient% / 5
  ydiv4% = cyClient% / 4
  '�
  '� Load bitmap1 from progams resource and store handle in hbm&
  '�
  hbm& = GpiLoadBitmap(hps&, 0, IDBBITMAP1, 0, 0)
  '�
  '� For the first and only the first bitmap drawn, set background color
  '� to black so a forground color of white can be used.  For every succeeding
  '� bitmap, a white background is used.
  '�
  bcolor% = CLRBLACK
  '�
  '� aptl(0) contains lower left hand corner of target area on screen
  '� aptl(1) contains upper right hand corner of target area on screen
  '�
  FOR X% = 0 to 4
    aptl(0).x = X% * xdiv4%
    aptl(1).x = aptl(0).x + xdiv4%
    FOR Y% = 0 to 3
      aptl(0).y = Y% * ydiv4%
      aptl(1).y = aptl(0).y + ydiv4%
      bool% = WinDrawBitmap(hps&, hbm&, 0,_
                            MakeLong(VARSEG(aptl(0)), VARPTR(aptl(0))),_
                            fcolor%, bcolor%, DBMSTRETCH)
      '�
      '� Incriment forground color.  Reset to 1 when at end of default
      '� color table.
      '�
      fcolor% = fcolor% + 1
      if fcolor% = 16 then fcolor% = 1
      bcolor% = CLRWHITE
    NEXT Y%
  NEXT X%
END SUB


'�*****************************************************************
'� Demo4PlaneBitMap is a very simple routine.  It first sets the system
'� pointer to an hourglass to signify the bitmap is being loaded, since it
'� takes a few seconds to load and display.  It the loads the bitmap from
'� the programs resource, and displays it to fill the Client window.
'�
SUB Demo4PlaneBitMap(hps&)
SHARED cxClient%, cyClient%
DIM ptl AS POINTL, aptl(3) AS POINTL, rect AS RECTL
DIM bmpinfo AS BITMAPINFOHEADER 
  '�
  '� Set system ponter to hourglass
  '�
  bool% = WinSetPointer(HWNDDESKTOP,_
                        WinQuerySysPointer(HWNDDESKTOP, SPTRWAIT, 0))
  '�
  '� Load bitmap2 from programs resource and store handle in hbm&
  '�
  hbm& = GpiLoadBitmap(hps&, 0, IDBBITMAP2, 0, 0)
  bool% = GpiQueryBitmapParameters(hbm&,_
                                   MakeLong(VARSEG(bmpinfo), VARPTR(bmpinfo)))

  '�
  '� aptl(0) contains lower left hand corner of target area
  '� aptl(1) contains upper right hand corne of target area
  '� aptl(2) contains lower right hand corner of source area
  '� aptl(3) contains upper right hand corner of source area
  '�
  '� aptl(2) and aptl(3) are set so as to use the entire bitmap
  '� aptl(0) and aptl(1) are set so as to fill the entire Client window
  '�
  aptl(0).x = 0
  aptl(0).y = 0
  aptl(1).x = cxClient%
  aptl(1).y = cyClient%
  aptl(2).x = 0
  aptl(2).y = 0
  aptl(3).x = bmpinfo.cx
  aptl(3).y = bmpinfo.cy
  '�
  '� Display bitmap
  '�
  bool% = GpiWCBitBlt(hps&, hbm&, 4&,_
                    MakeLong(VARSEG(aptl(0)), VARPTR(aptl(0))),_
                    ROPSRCCOPY, BBOAND)
  '�
  '� Release bitmap handle
  '�
  bool% = GpiDeleteBitmap(hbm&)

END SUB


'�*****************************************************************
'� DemoSystemBitmaps, depending on the menuitem selected, will display all
'� the available system bitmaps at the same time, magnifying them to fill
'� the client window, or will display one at a time in its actual size, but
'� fills the client window with multiple copies of the bitmap
'�
SUB DemoSystemBitmaps(hps&, lastgpi%)
SHARED cxClient%, cyClient%
DIM aptl(1) AS POINTL, ptl AS POINTL, rect AS RECTL
DIM bmpinfo AS BITMAPINFOHEADER

IF lastgpi% = ShowAllSysBitmaps THEN
'�
'� Display all system bitmaps at once if lastgpi% = ShowAllSysBitmaps
'�
'� Divide the Client window into 20 equal areas
'�
  xdiv5% = cxClient% / 5
  ydiv4% = cyClient% / 4
  '�
  '� Begin at first system bitmap
  '�
  bitmapnum% = 1
  FOR X% = 0 TO 4
  '�
  '� aptl(0) contains lower left hand corner of target area
  '� aptl(1) contains upper right hand corner of target area
  '�
    aptl(0).x = X% * xdiv5%
    aptl(1).x = aptl(1).x + xdiv5%
    FOR Y% = 0 TO 3
      aptl(0).y = Y% * ydiv4%
      aptl(1).y = aptl(0).y + ydiv4%
      '�
      '� The ID numbers for the system bitmaps is not continuous.
      '� There is no corresponding bitmap for numbers 13,14,20, or 21
      '� so they are skipped.
      '�
      While (bitmapnum% = 13 OR bitmapnum% = 14 OR_
             bitmapnum% = 20 OR bitmapnum% = 21)
        bitmapnum% = bitmapnum% + 1
      WEND
      '�
      '� Retrieve bitmap corresponding to bitmapnum%
      '�
      hbm& = WinGetSysBitmap(HWNDDESKTOP, bitmapnum%)
      bitmapnum% = bitmapnum% + 1
      '�
      '� Display bitmap filling area defined by aplt(0) and aplt(1)
      '�
      bool% = WinDrawBitmap(hps&, hbm&, 0,_
                            MakeLong(VARSEG(aptl(0)), VARPTR(aptl(0))),_
                            CLRNEUTRAL, CLRBACKGROUND, DBMSTRETCH)
    NEXT Y%
  NEXT X%
ELSE
'�
'� The following fills the Client window the select bitmap, using its actual
'� size
'�
'� The menu ID number is used to determine which bitmap to be displayed, and
'� the menu ID numbers were defined as 70 greater than the actual bitmap
'� ID, so 70 must be subtracted to obtain the actual ID.  See the GpiDemo.RC.
'�
  bitmap% = lastgpi% - 70
  hbm& = WinGetSysBitmap(HWNDDESKTOP, bitmap%)
  '�
  '� Determine actual size of bitmap
  '�
  bool% = GpiQueryBitmapParameters(hbm&,_
                                   MakeLong(VARSEG(bmpinfo), VARPTR(bmpinfo)))
  '�
  '� Fill the Client window with RED.  This will display a narrow RED line
  '� between each bitmap, since the bitmaps are draw a few pixels apart.
  '� This helps distinguish the actual size of the bitmap.
  '�
  rect.xleft = 0
  rect.xright = cxClient%
  rect.ytop = cyClient%
  rect.ybottom = 0
  bool% = WinFillRect(hps&, MakeLong(VARSEG(rect), VARPTR(rect)), CLRRED)
  '�
  '� Fill the screen with the selected bitmap
  '�
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


'�*****************************************************************
'� DemoResizeBitmap essentially does the same thing as the above routines,
'� stretches or compresses a bitmap, but with the aid of the WinTrackRect
'� routine, it does it in a way that is much more visible.  You see the
'� original bitmap, and the user then, using the mouse, selects the new
'� size of the bitmap.  The mouse is moved resize the window tracking
'� rectangle, and then clicks the left mouse button to display the bitmap
'� as it new size.
'�
SUB DemoResizeBitmap(hwnd&, hps&) STATIC
SHARED cxClient%, cyClient%
DIM ti AS TRACKINFO, aptl(1) AS POINTL
  '�
  '� Load bitmap from programs resource and store handle in hbm&
  '�
  hbm& = GpiLoadBitmap(hps&, 0, IDBBITMAP1, 0, 0)
  '�
  '� If this is the first call to this routine, set default values for
  '� bitmap size and tracking rectangle size, otherwize, use current values.
  '� Values are retained due to the STATIC following the SUB statment.
  If Demoed% = 0 THEN
    '�
    '� Tracking rectangle default values.  Slightly larger than the bitmap.
    '�
    ti.rclTrack.xleft = 0
    ti.rclTrack.yBottom = 0
    ti.rclTrack.xRight = 110
    ti.rclTrack.ytop = 110
    '�
    '� Default values for the bitmap.  Draws bitmap actual size.
    '�
    aptl(0).x = 0
    aptl(0).y = 0
    aptl(1).x = 98
    aptl(1).y = 98
    demoed% = 1
  END IF
  '�
  '� Display bitmap using current size
  '�
  bool% = WinDrawBitmap(hps&, hbm&, 0,_
                        MakeLong(VARSEG(aptl(0)), VARPTR(aptl(0))),_
                        CLRNEUTRAL, CLRBACKGROUND, DBMSTRETCH)
  '�
  '� Initialize tracking rectangle information.  See QuickHELP or
  '� OS/2 Programmers reference VOL 2 for a detailed description of the
  '� fields of "ti" defined as TRACKINFO.
  '�
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
  '�
  '� Set system pointer to a four point pointer to signify movement in
  '� all directions.
  '�
  bool% = WinSetPointer(HWNDDESKTOP,_
                        WinQuerySysPointer(HWNDDESKTOP, SPTRMOVE, 0))
  '�
  '� Resize tracking rectangle.  WinTrackRect does not return until
  '� the left mouse button is clicked.
  '�
  bool% = WinTrackRect(hwnd&, 0,_
                       MakeLong(VARSEG(ti), VARPTR(ti)))
  '�
  '� Obtain resulting rectangle size to be used as new bitmap size.
  '�
  aptl(1).x = ti.rclTrack.xRight
  aptl(1).y = ti.rclTrack.ytop
  '�
  '� Fill new rectangle with RED.  This is done only to let the user know
  '� that something is going on, since if the new rectangle is quite large,
  '� it can take a few seconds to display the bitmap.
  '�
  bool% = WinFillRect(hps&,_
                      MakeLong(VARSEG(ti.rclTrack), VARPTR(ti.rclTrack)),_
                      CLRRED)
  '�
  '� Draw the bitmap using its new size
  '�
  bool% = WinDrawBitmap(hps&, hbm&, 0,_
                        MakeLong(VARSEG(aptl(0)), VARPTR(aptl(0))),_
                        CLRNEUTRAL, CLRBACKGROUND, DBMSTRETCH)
  '�
  '� Release bitmap handle
  '�
  bool% = GpiDeleteBitmap(hbm&)

END SUB


'�*****************************************************************
'� DemoCaptureAndMagnify use the WinTractRect to select an area of the screen
'� to capture and store as a bitmap.  Once the bitmap is stored, it is stretched
'� or compressed to fill the client window.  Three presentation spaces are needed
'� for this operation:
'�
'�   1. The Client window, where the bitmap will finally be displayed.
'�   2. A Screen presentation space where the bitmap is captured from.  The
'�      entire screen is available to be captured.  For a visual explanation
'�      of this, click the restore icon prior to selecting capture bitmap from
'�      the menu so this applications window does not take up the entire screen.
'�   3. A memory presentation space where the bitmap is stored after being
'�      captured, so it can be quickly redrawn when a WMPAINT message is
'�      executed.
'�
SUB DemoCaptureAndMagnify(hab&, hwndFrame&, shwnd&, hps&) STATIC
SHARED cxClient%, cyClient%
DIM ti AS TRACKINFO, aptl(3) AS POINTL
DIM sizl AS POINTL, bi AS BITMAPINFOHEADER

  hwnd& = ABS(shwnd&)
  '�
  '� If shwnd& is negative, this routine was called due to a WMPAINT
  '� message, therefore a new bitmap is not to be captured. Everything
  '� in the SUBprogram is skipped except the previous bitmap captured is
  '� redrawn.
  '�
  IF shwnd& > 0 THEN
  '�
  '� Instructions for using "Capture Bitmap"
  '�
    message$="Position pointer to upper-left corner of area "+_
             "to be captured, then click left mouse button.  "+_
             "Stretch box around area to be captured, then "+_
             "click left mouse button again." + CHR$(0)
    caption$ = ""+CHR$(0)
  '�
  '� Display instructions and determine if user really wants to capture
  '� a bitmap.  If value returned from WinMessageBox is MBIDOK then
  '� capture a new bitmap, otherwise, display previous bitmap.
  '�
    IF  WinMessageBox(HWNDDESKTOP, HWNDDESKTOP,_
                      MakeLong(VARSEG(message$), SADD(message$)),_
                      MakeLong(VARSEG(caption$), SADD(caption$)),_
                      0,_
                      MBOKCANCEL OR_
                      MBICONASTERISK) = MBIDOK THEN
    '�
    '� Release previous bitmap handle, and the presentation space where the
    '� bitmap is stored, and the Device Context associated with the
    '� presentation space.
    '�
      bool% = GpiDeleteBitmap(hbm&)
      bool% = GpiDestroyPS(hps3&)
      bool% = DevCloseDC(hdc&)
    '�
    '� Initialize tracking rectangle information.  See QuickHELP or
    '� OS/2 Programmers reference VOL 2 for a detailed description of the
    '� fields of "ti" defined as TRACKINFO.
    '�
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
    '�
    '� Obtain a Screen Presentation Space
    '�
      hps2& = WinGetScreenPS(HWNDDESKTOP)
    '�
    '� Set pointer to four point system pointer as in "Resize Bitmap"
    '�
      bool% = WinSetPointer(HWNDDESKTOP,_
                            WinQuerySysPointer(HWNDDESKTOP, SPTRMOVE, 0))
    '�
    '� Obtain upper left hand corner of area to be captured.  The tracking
    '� rectangle is simply a single pixel during this call to WinTrackRect
    '� so only the pointer is visible.  When the left mouse button is
    '� clicked, WinTractRect returns, new parameters are set which allow
    '� the rectangle to be resized down and to the right of the selected
    '� upper left hand corner of the the area to be captured.
    '�
      bool% = WinTrackRect(HWNDDESKTOP, 0,_
                           MakeLong(VARSEG(ti), VARPTR(ti)))
    '�
    '� Set new parameters for tracking rectangle.  Can only expand
    '� rectangle down or to the right.
    '�
      ti.fs = TFBOTTOM OR TFRIGHT OR TFSTANDARD OR TFSETPOINTERPOS
    '�
    '� Obtain area to be captured
    '�
      bool% = WinTrackRect(HWNDDESKTOP, 0,_
                           MakeLong(VARSEG(ti), VARPTR(ti)))
    '�
    '� Initialize bitmap information
    '�
      bi.cbFix = LEN(bi)
      bi.cx = ti.rclTrack.xright - ti.rclTrack.xleft
      bi.cy = ti.rclTrack.ytop - ti.rclTrack.ybottom
      bi.cPlanes = 1
      bi.cBitCount = 4
    '�
    '� Initialize information for Memory Device Context, then open
    '� a memory device context.
    '�
      token$ = "*" + CHR$(0)
      sizl.x = bi.cx
      sizl.y = bi.cy
      hdc& = DevOpenDC(hab&, ODMEMORY,_
                       MakeLong(VARSEG(token$), SADD(token$)), 0, 0, 0)
    '�
    '� Create a micro presentation space and associate it with the memory
    '� device context opened above.
    '�
      hps3& = GpiCreatePS(hab&, hdc&,_
                          MakeLong(VARSEG(sizl), VARPTR(sizl)),_
                          PUPELS OR GPIFDEFAULT OR GPITMICRO OR GPIAASSOC)
    '�
    '� Create bitmap using information set previously and associate bitmap
    '� with presentation space created above.
    '�
      hbm& = GpiCreateBitmap(hps3&,_
                             MakeLong(VARSEG(bi), VARPTR(bi)),_
                             0, 0, 0)
      bool% = GpiSetBitmap(hps3&, hbm&)
    '�
    '� Set aptl() to source and target rectangles
    '�
      aptl(0).x = 0
      aptl(0).y = 0
      aptl(1).x = bi.cx
      aptl(1).y = bi.cy
      aptl(2).x = ti.rclTrack.xleft
      aptl(2).y = ti.rclTrack.ybottom
      aptl(3).x = ti.rclTrack.xright
      aptl(3).y = ti.rclTrack.ytop
    '�
    '� Copy area defind by the rectangle returned by WinTractRect to the
    '� micro presentation space created above.
    '�
      bool% = GpiBitBlt(hps3&, hps2&, 4&,_
                        MakeLong(VARSEG(aptl(0)), VARPTR(aptl(0))),_
                        ROPSRCCOPY, BBOAND)
    '�
    '� Release the Screen presentation space
    '�
      bool% = WinReleasePS(hps2&)
    END IF
  END IF
'�
'� Initialize source and target rectanges.  Target is now the Client Window
'�
  aptl(0).x = 0
  aptl(0).y = 0
  aptl(1).x = cxClient%
  aptl(1).y = cyClient%
  aptl(2).x = 0
  aptl(2).y = 0
  aptl(3).x = bi.cx
  aptl(3).y = bi.cy
'�
'� Copy captured bitmap to the Client Window
'�
  bool% = GpiBitBlt(hps&, hps3&, 4&,_
                    MakeLong(VARSEG(aptl(0)), VARPTR(aptl(0))),_
                    ROPSRCCOPY, BBOAND)
END SUB


'�*****************************************************************
'� DemoFillWithBitmap demonstrates how to use an 8 x 8 bitmap created
'� with Iconedit.EXE as a fill pattern.  A crude picture is drawn, which
'� sort of resembles a castle, and then is filled with the bitmap.
'� the bitmap resembles bricks when used as a fill pattern.
'�
SUB DemoFillWithBitmap(hps&)
SHARED cxClient%, cyClient%
DIM pic(14) AS POINTL

  xdiv5% = cxClient% / 5
  ydiv4% = cyClient% / 4
'�
'� Initialize pic() with points used to draw the picture.  The points
'� are calculated to be proportional to the Client Window
'�
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
'�
'� Load Bitmap from programs resource.  Assigne the Bitmap an ID of 254.
'� Set the current pattern set to 254 which has been defined as the bitmap.
'� Select pattern set 254, the bitmap.  Set color to RED, to resemble bricks.
'� Mark the beginning of of the picture.  Move to first point of picture,
'� lower left corner of Client window.  Use GpiPolyLine to draw picture
'� in one call, using points stored in pic().  Mark end of area and fill
'� picture with current pattern and color, which is RED and the loaded
'� bitmap.  Finally release the bitmap handle.
'�
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

