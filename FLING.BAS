'|***************************************************************************
'|
'| Program Name: Fling.BAS
'|
'| Description:  Fling is a fun program that demonstrates many
'|               of the Presentation Manager GPI calls for
'|               manipulating and using bitmaps.  The following
'|               are the major areas demonstrated in this program:
'|      
'|               - Passing a bitmap from one program to another
'|                 using the System Clipboard.
'|               - Using mouse control to move and manipulate
'|                 bitmaps
'|               - Using bitmaps in menus
'|               - Executing menuselections before the menu item is
'|                 actually selected. (WMMENUSELECT)
'|               - Difference between 1 bit per pixel bitmaps
'|                 and 4 bits per pixel bitmaps. (The bitmap
'|                 titled "BITMAP" is the only 1 bit per pixel
'|                 bitmap used in this program, and is the only
'|                 bitmap the color can be changed using the color
'|                 menu selection).
'|
'|               Fling displays a bitmap moving and bouncing of
'|               the boundaries of the Client window.  The speed
'|               and direction are determined by the user through
'|               the use of the mouse.  Clicking and holding the
'|               Left mouse button down within the boundaries of
'|               the bitmap will "CATCH" the bitmap.  The bitmap
'|               can then be sent off in another direction and
'|               speed by "Flinging" it in the desired direction
'|               speed and releasing the mouse button.  Clicking
'|               the Left mouse button anywhere within the Client
'|               Window other than on the bitmap will pause the
'|               bitmap, allowing the user to click on the bitmap.
'|               Clicking it againg will restart the bitmap using
'|               the last direction and speed.  The right mouse
'|               button clears the Client window user.
'|      
'|               There are four predfined bitmaps which appear and
'|               are selected from the "Bitmaps" and "More bitmaps"
'|               menus.  If the System clipboard contains a bitmap
'|               the "Clipboard" menu selection will display that
'|               bitmap.  A bitmap can be place in the clipboard
'|               using the program CAPTURE.BAS.
'|
'| Source Files: FLING.BAS   Source
'|               FLING.DEF   definition file
'|               FLING.INC   Include file cut & pasted from BI files
'|               FLING.RC    Resouce file
'|               FLING.ICO   Icon
'|               FLING1.BMP  bitmap
'|               FLING2.BMP  OS/2 symbol
'|               FLING3.BMP  Jack of diamonds face
'|               FLING4.BMP  Bug face
'|
'| To Compile
'| and Link:     Use PMBC ->  PMBC fling
'|               or the following can be used
'|
'| Compiling:    BC fling /o;
'|
'| Linking:      Link /noe fling,,, os2.lib regbas.lib, fling.def
'|
'| Resource:     RC fling   (compiles and adds resource to FLING.EXE)
'|***************************************************************************
'|********         Initialization section        ***********

REM $INCLUDE: 'os2def.bi'
REM $INCLUDE: 'PMBase.bi'
REM $INCLUDE: 'winmisc.bi'
REM $INCLUDE: 'winman1.bi'
REM $INCLUDE: 'gpibit.bi'

REM $INCLUDE: 'FLING.INC'

DIM aqmsg AS QMSG

flFrameFlags& = FCFTITLEBAR      OR FCFSYSMENU  OR_
                FCFSIZEBORDER    OR FCFMINMAX   OR_
                FCFSHELLPOSITION OR FCFTASKLIST OR_
                FCFMENU          OR FCFICON     OR_
                FCFNOBYTEALIGN

szClientClass$ = "ClassName" + CHR$(0)

hab& = WinInitialize(0)
hmq& = WinCreateMsgQueue(hab&, 0)

bool% = WinRegisterClass(_
      hab&,_
      MakeLong(VARSEG(szClientClass$), SADD(szClientClass$)),_
      RegBas,_
      0,_
      0)

hwndFrame& = WinCreateStdWindow (_
      HWNDDESKTOP,_
      WSVISIBLE,_
      MakeLong (VARSEG(flFrameFlags&), VARPTR(flFrameFlags&)),_
      MakeLong (VARSEG(szClientClass$), SADD(szClientClass$)),_
      0,_
      0,_
      0,_
      1,_
      MakeLong (VARSEG(hwndClient&), VARPTR(hwndClient&)))

'**************         Message loop         ***************

WHILE WinGetMsg(hab&,_
              MakeLong(VARSEG(aqmsg), VARPTR(aqmsg)), 0, 0, 0)
    bool% = WinDispatchMsg(hab&,_
              MakeLong(VARSEG(aqmsg), VARPTR(aqmsg)))
WEND

'***********         Finalize section        ***************

bool% = WinDestroyWindow(hwndFrame&)
bool% = WinDestroyMsgQueue(hmq&)
bool% = WinTerminate(hab&)
END

'***********         Window procedure        ***************

FUNCTION ClientWndProc& (hwnd&, msg%, mp1&, mp2&) STATIC
SHARED hab&, hbm&, hpsClient&, hwndMenu&, colorflag%
SHARED cxClient%, cyClient%, fcolor%, randomc%, index%, xsize%, ysize%
SHARED maximizedClient%
SHARED ptl AS POINTL, bmpinfo AS BITMAPINFO
DIM bitmaps&(4,4), mirror AS POINTL

  SELECT CASE msg%

    CASE WMCREATE
    '|
    '| Set default values for color, speed, direction, and sound.
    '|
      fcolor% = 7
      tcolor% = 7
      colorflag% = 1
      sounds% = -1
      movex% = 3
      movey% = 3
      cxicon% = WinQuerySysValue(HWNDDESKTOP, SVCXICON)
    '|
    '| Load bitmaps from resource.  Query bitmap information for each
    '| bitmap and store bitmap handle, width, heigth, and bits per pixel
    '| in the array bitmaps&()
    '|
      hpsClient& = WinGetPS(hwnd&)
      FOR I% = 1 TO 4
        bitmaps&(I%,1) = GpiLoadBitmap(hpsClient&, 0, I%, 0, 0)
        bool% = GpiQueryBitmapParameters(bitmaps&(I%,1),_
                              MakeLong(VARSEG(bmpinfo), VARPTR(bmpinfo)))
        bitmaps&(I%,2) = bmpinfo.cx - 1
        bitmaps&(I%,3) = bmpinfo.cy - 1
        bitmaps&(I%,4) = bmpinfo.cBitCount
      NEXT I%
    '|
    '| Initialize values for initial bitmap displayed when FLING is
    '| loaded.
    '|
      hbm& = bitmaps&(1, 1)
      xsize% = bitmaps&(1, 2) - 1
      ysize% = bitmaps&(1, 3) - 1
    '|
    '| Obtain handle to programs menu.  To be used to enable, disable,
    '| check, and uncheck color selections.
    '|
      hwndMenu& = WinWindowFromID(WinQueryWindow(hwnd&, QWPARENT, FALSE),_
                                  FIDMENU)
    '|
    '| Start timer which will cause a bitmap to be displayed approximately
    '| every 1 millisecond.
    '|
      ClientWndProc& = 0
  '|
  '| Obtain new Client Window size
  '|
    CASE WMSIZE
      CALL BreakLong(mp2&, cyClient%, cxClient%)
      IF maximizedClient% = 1 THEN CALL MaximizeTheClientWindow(hwnd&)
      IF cxClient% = cxicon% THEN
        bool% = WinStopTimer(hab&, hwnd&, 1)
      ELSE
        bool% = WinStartTimer(hab&, hwnd&, 1, 1)
      END IF
      ClientWndProc&=0
  '|
  '| Clears Client Window, and redraws the current bitmap only
  '| if it is currently paused.
  '|
    CASE WMPAINT
      hps&  = WinBeginPaint(hwnd&, 0, 0)
      CALL ClearTheClientWindow(hps&)
      IF pause% = 1 THEN CALL MoveBitmap(hwnd&, 0, 0)
      bool% = WinEndPaint(hps&)
      ClientWndProc& = 0
  '|
  '| A WMTIMER message is sent every 1 millisecond, if the timer is started,
  '| which invokes this routine.  The timer is stopped before this routine
  '| is executed since once the WMTIMER message dispatched from the
  '| message loop, another WMTIMER can be posted in the message cue.  If
  '| a WMTIMER message is posted before this routine is complete, depending
  '| on the size of the current bitmap, the WMTIMER messages continuously
  '| being placed in the cue can make it difficult for other messages
  '| to get processed.  The timer is started upon exiting this routine.
    CASE WMTIMER
      bool% = WinStopTimer(hab&, hwnd&, 1)
    '|
    '| Obtain current direction (SIGN), both horizontal and vertical
      xsgn% = SGN(movex%)
      ysgn% = SGN(movey%)
    '|
    '| Change direction if at boundary of Client Window
    '|
      IF ptl.x = 0 THEN movex% = ABS(movex%)
      IF ptl.x = (cxClient% - xsize%) THEN movex% = -ABS(movex%)
      IF ptl.y = 0 THEN movey% = ABS(movey%)
      IF ptl.y = (cyClient% - ysize%) THEN movey% = -ABS(movey%)
    '|
    '| If out boundary and sound is turned on, BEEP
    '|
      IF sounds% = 1 THEN
        IF (xsgn% * movex%) < 0 OR (ysgn% * movey%) < 0 THEN
          bool% = DosBeep(250, 5)
        ENDIF
      END IF
    '|
    '| CALL MoveBitmap to draw bitmap in next location
    '|
      CALL MoveBitmap(hwnd&, movex%, movey%)
      bool% = WinStartTimer(hab&, hwnd&, 1, 1)
      ClientWndProc& = 0
  '|
  '| The WMMENUSELECT message is sent as each submenu item is selected
  '| from a menu, but prior to the WMCOMMAND message being sent for a
  '| selected menu item.  Both color and bitmap menu selections are
  '| processed before the menu is dismissed.
  '|
    CASE WMMENUSELECT
      CALL BreakLong(mp1&, dummy%, menuSelection%)
      SELECT CASE menuSelection%
      '|
      '| Get color selection.  Color 16 is random colors
      '|
        CASE IDMCOLOR+1 TO IDMCOLOR+16
          IF colorflag% = 1 THEN
            fcolor% = menuSelection% - IDMCOLOR
            IF fcolor% = 16 THEN randomc% = 1 ELSE randomc% = 0
          END IF
            
        CASE IDMBITMAPS+1 TO IDMBITMAPS+5
        '|
        '| If Clipboard was selected, get bitmap from System Clipboard
        '|
          IF menuSelection% = IDMCLIPBRD THEN
            CALL FlingBitmapFromClipBoard(hwnd&, hbmClip&)
            IF hbmClip& <> 0 THEN
              hbm& = hbmClip&
              bool% = GpiQueryBitmapParameters(hbm&,_
                                  MakeLong(VARSEG(bmpinfo), VARPTR(bmpinfo)))
              xsize% = bmpinfo.cx - 1
              ysize% = bmpinfo.cy - 1
              colorflag% = bmpinfo.cBitCount
            END IF
          ELSE
        '|
        '| Get a predefined bitmap was selected, get bitmap info from
        '| bitmaps&() array
        '|
            index% = menuSelection% - IDMBITMAPS
            hbm& = bitmaps&(index%, 1)
            xsize% = bitmaps&(index%, 2)
            ysize% = bitmaps&(index%, 3)
            colorflag% = bitmaps&(index%, 4)
          END IF
        '|
        '| Disable color selection if selected bitmap is a 4 bit per
        '| pixel bitmap
        '|
          IF colorflag% = 4 THEN
            attribute% = MIADISABLED
          ELSE
            attribute% = 0
          END IF
          bool% = WinSendMsg(hwndMenu&, MMSETITEMATTR,_
                             MakeLong(TRUE, IDMCOLOR),_
                             MakeLong(attribute%, MIADISABLED))
          IF pause% = 1 THEN CALL MoveBitmap(hwnd&, 0, 0)
        CASE ELSE
      END SELECT
      ClientWndProc& = 1
   
    CASE WMCOMMAND
      CALL BreakLong(mp1&, dummy%, menuSelection%)
      SELECT CASE menuSelection%

        CASE IDMEXIT
          bool% = WinReleasePS(hpsClient&)
          bool% = WinPostMsg(hwnd&, WMQUIT, 0, 0)

        CASE IDMSOUND
          sounds% = -sounds%

        CASE IDMMAXIMIZECLIENTWINDOW
          CALL MaximizeOrRestoreTheClientWindow(hwnd&)
      '|
      '| The color has already been selected during the WMMENUSELECT
      '| message.  The routine is used to recheck the new color
      '| selection.
      '|
        CASE IDMCOLOR+1 TO IDMCOLOR+16
        '|
        '| Calculate handle of last color selection menu item
        '|
          IF randomc% = 1 THEN
            lastcolor% = 16 + IDMCOLOR
          ELSE
            lastcolor% = tcolor% + IDMCOLOR
          ENDIF
          CALL ResetCheckedMenuItem(lastcolor%, menuSelection%)
          tcolor% = fcolor%
        CASE ELSE
      END SELECT
      ClientWndProc& = 0
  '|
  '| Clear the Client window
  '|
    CASE WMBUTTON2UP
      ClearTheClientWindow(hpsClient&)
      IF pause% = 1 THEN CALL MoveBitmap(hwnd&, 0, 0)
      ClientWndProc& = 1
  '|
  '| If mouse cursor is within the boundaryies of the bitmap,
  '| pause the bitmap and set the flag "mouse%" to one.  This
  '| will cause the WMMOUSEMOVE message to redraw the bitmap
  '| where ever the mouse is moved, as long as the left mouse
  '| button is held down.  Once released, the difference between
  '| the last two mouse locations are used to determine bitmap
  '| direction and speed.
  '|
    CASE WMBUTTON1DOWN
      CALL BreakLong(mp1&, my%, mx%)
      IF (mx% >= ptl.x) AND (mx% =< (ptl.x + xsize%)) THEN
        IF (my% >= ptl.y) AND (my% =< (ptl.y + ysize%)) THEN
          bool% = WinStopTimer(hab&, hwnd&, 1)
          mouse% = 1
          lastmx% = mx%
          lastmy% = my%
          fling% = 1
        END IF
      END IF
      ClientWndProc& = WinDefWindowProc(hwnd&, msg%, mp1&, mp2&)
  '|
  '| If the left mouse button has just been released and it was within
  '| the boundaries of the bitmap, the timer is started which will
  '| then cause the bitmap to continue in the direction and speed
  '| determined from the the mouse coordinates.  If the mouse
  '| was not within the bitmap boundaries, and the bitmap was moving,
  '| the bitmap is then paused.  If it was paused, it is restarting
  '|
    CASE WMBUTTON1UP
      mouse% = 0
      IF fling% THEN
        bool% = WinStartTimer(hab&, hwnd&, 1, 1)
        fling% = 0
        pause% = 0
      ELSEIF pause% = 0 THEN
        bool% = WinStopTimer(hab&, hwnd&, 1)
        pause% = 1
      ELSE
        bool% = WinStartTimer(hab&, hwnd&, 1, 1)
        pause% = 0
      END IF
      ClientWndProc& = WinDefWindowProc(hwnd&, msg%, mp1&, mp2&)
  '|
  '| If the left mouse button is currently down, redraw bitmap at
  '| the new location of the mouse.
  '|
    CASE WMMOUSEMOVE
      IF mouse% = 1 THEN
        CALL BreakLong(mp1&, my%, mx%)
        movex% = mx% - lastmx%
        movey% = my% - lastmy%
        lastmx% = mx%
        lastmy% = my%
        CALL MoveBitmap(hwnd&, movex%, movey%)
      END IF
      ClientWndProc& = 1

    CASE WMHELP
      CALL DisplayHelp

    CASE ELSE
      ClientWndProc& = WinDefWindowProc(hwnd&, msg%, mp1&, mp2&)

  END SELECT
END FUNCTION


'|***************************************************************************
'| MoveBitmap redraws the current bitmap at its new location which is
'| determined by adding the horizontal "movex%" and vertical "movey%"
'| values to the current location.  If the new location would place part
'| of the bitmap outside the Client window, then the bitmap is drawn
'| at the boundary, recalculating "movex%" and "movey%" as neccessary.
'|***************************************************************************
SUB MoveBitmap(hwnd&, movemx%, movemy%) STATIC
SHARED hbm&, hpsClient&, fcolor%, randomc%, cxClient%, cyClient%, colorflag%
SHARED xsize%, ysize%, ptl AS POINTL

'|
'| Add movement values to current location. (lower left hand corner)
'|
  ptl.x = ptl.x + movemx%
  ptl.y = ptl.y + movemy%
'|
'| Determine if new location would place part of the bitmap outside
'| the Client window.  Recalculate if neccessary.
'|
  IF ptl.x > (cxClient% - xsize%) THEN ptl.x = cxClient% - xsize%
  IF ptl.x < 0 THEN ptl.x = 0
  IF ptl.y > (cyClient% - ysize%) THEN ptl.y = cyClient% - ysize%
  IF ptl.y < 0 THEN ptl.y = 0
'|
'| If random color is selected, and current bitmap is a 1 bit per pixel
'| bitmap, select a random color
'|
  IF randomc% = 1 AND colorflag% = 1 THEN
    RANDOMIZE TIMER
    fcolor% = INT (15 * RND + 1)
  END IF
'|
'| Draw bitmap at new location
'|
  bool% = WinDrawBitmap(hpsClient&, hbm&, 0,_
                        MakeLong(VARSEG(ptl), VARPTR(ptl)),_
                        fcolor%, CLRWHITE, DBMNORMAL)
END SUB


'|***************************************************************************
'| Retrieves bitmap from the System Clipboard, if the Clipboard contains one.
'| If there is not a bitmap in the Clipboard, a message is displayed to
'| prompt the user.
'|***************************************************************************
SUB FlingBitmapFromClipBoard(hwnd&, hbm&)
SHARED hab&
  bool% = GpiDeleteBitmap(hbm&)
'|
'| Open Clipboard and determine if it contains a bitmap
'|
  bool% = WinOpenClipBrd(hab&)
  hbmClip& = WinQueryClipBrdData(hab&, CFBITMAP)
'|
'| If the Clipboard contains a bitmap, make a copy of the bitmap
'|
  IF hbmClip& <> 0 THEN
    hbm& = MakeCopyOfBitmap(hbmClip&)
  ELSE
  '|
  '| If the Clipboard does not contain a bitmap, let the user know
  '|
    caption$ = CHR$(0)
    message$ = "The Clipboard does not contain a bitmap" + CHR$(0)
    bool% = WinMessageBox(HWNDDESKTOP, HWNDDESKTOP,_
                          MakeLong(VARSEG(message$), SADD(message$)),_
                          MakeLong(VARSEG(caption$), SADD(caption$)),_
                          0,_
                          MBICONHAND OR MBAPPLMODAL)
    hbm& = 0
  END IF
  bool% = WinCloseClipbrd(hab&)
END SUB


'|***************************************************************************
'| This FUNCTION takes a bitmap handle as a paramater, and makes a copy of
'| the bitmap referenced by "hbmSource&".  The handle of the bitmap copy
'| is returned by the FUNCTION.
'|***************************************************************************
FUNCTION MakeCopyOfBitmap&(hbmSource&)
DIM bih AS BITMAPINFOHEADER, aptl(2) AS POINTL
'|
'| Create a presentation space and device context for both the source bitmap
'| and the target bitmap.
'|
  CALL CreateBitmapPSandDC(hpsSource&, hdcSource&)
  CALL CreateBitmapPSandDC(hpsTarget&, hdcTarget&)
'|
'| Get source bitmap information.
'|
  bool% = GpiQueryBitmapParameters(hbmSource&,_
                                   MakeLong(VARSEG(bih), VARPTR(bih)))
'|
'| Create a new bitmap using info from source bitmap
'|
  hbmTarget& = GpiCreateBitmap(hpsTarget&,_
                               MakeLong(VARSEG(bih), VARPTR(bih)),_
                               0, 0, 0)
'|
'| Associate source and target bitmaps with their respective presentation
'| space so a copy can be made using GpiBitBlt
'|
  bool% = GpiSetBitmap(hpsSource&, hbmSource&)
  bool% = GpiSetBitmap(hpsTarget&, hbmTarget&)
'|
'| Initialize rectangle of source bitmap to be copied to entire bitmap
'|
  aptl(0).x = 0
  aptl(0).y = 0
  aptl(1).x = bih.cx
  aptl(1).y = bih.cy
  aptl(2).x = 0
  aptl(2).y = 0
'|
'| Copy bitmap
'|
  bool% = GpiBitBlt(hpsTarget&, hpsSource&, 3,_
                    MakeLong(VARSEG(aptl(0)), VARPTR(aptl(0))),_
                    ROPSRCCOPY, BBOAND)
'|
'| Destroy presentation spaces and device contexts used to create bitmap
'|
  bool% = GpiDestroyPS(hpsSource&)
  bool% = GpiDestroyPS(hpsTarget&)
  bool% = DevCloseDC(hdcSource&)
  bool% = DevCloseDC(hdcTarget&)
'|
'| Return handle to copy of bitmap
'|
  MakeCopyOfBitmap& = hbmTarget&
END FUNCTION


'|***************************************************************************
'| Creates a Micro presentation space and device context to be used to store
'| bitmap in memory, which can be referenced by a handle.
'|***************************************************************************
SUB CreateBitmapPSandDC(hps&, hdc&)
SHARED hab&
DIM sizl AS POINTL
'|
'| Initialize information for Memory Device Context, then open
'| a memory device context.  Create same size as bitmap.
'|
  token$ = "*" + CHR$(0)
  sizl.x = 0
  sizl.y = 0
  hdc& = DevOpenDC(hab&, ODMEMORY,_
                   MakeLong(VARSEG(token$), SADD(token$)), 0, 0, 0)
'|
'| Create a micro presentation space and associate it with the memory
'| device context opened above.
'|
  hps& = GpiCreatePS(hab&, hdc&,_
                     MakeLong(VARSEG(sizl), VARPTR(sizl)),_
                     PUPELS OR GPIFDEFAULT OR GPITMICRO OR GPIAASSOC)
END SUB


'|***************************************************************************
'| Maximizes or restores the Client window, depending on the current value
'| of "maximizedClient".
'|***************************************************************************
SUB MaximizeOrRestoreTheClientWindow(hwnd&)
SHARED hwndFrame&, hwndMenu&, maximizedClient%
DIM swpFrame AS SWP
  IF maximizedClient% = 1 THEN
  '|
  '| Restore the Client Window
    maximizedClient% = 0
  '|
  '| Obtain current frame window size
  '|
    bool% = WinQueryWindowPos(hwndFrame&,_
                              MakeLong(VARSEG(swpFrame), VARPTR(swpFrame)))
  '|
  '| Restore the Client window to within the frame windows frame and menus
  '| by changing the frame window size by 1 pixel, then changing it back to
  '| its original size.  A WinSetWindowPos will not cause a WMSIZE message
  '| if the size of the window is not changed.  This is a sleezy way to
  '| restore the Client window without having to save its orginal size and
  '| position.
  '|
    bool% = WinSetWindowPos(hwndFrame&, 0, 0, 0,_
                            swpFrame.cx + 1, swpFrame.cy,_
                            SWPSIZE)
    bool% = WinSetWindowPos(hwndFrame&, 0, 0, 0,_
                            swpFrame.cx, swpFrame.cy,_
                            SWPSIZE)
    CALL ResetCheckedMenuItem(IDMMAXIMIZECLIENTWINDOW, 0)
  ELSE
  '|
  '| Maximize the Client Window
  '|
    CALL MaximizeTheClientWindow(hwnd&)
    CALL ResetCheckedMenuItem(0, IDMMAXIMIZECLIENTWINDOW)
  END IF
END SUB


'|***************************************************************************
'| Maximizes the Client window, hiding all of the frame window controls and
'| menus.  The controls are still accessable by keyboard or mouse, but they
'| simply cannot be seen.
'|***************************************************************************
SUB MaximizeTheClientWindow(hwnd&)
SHARED hwndFrame&, hwndMenu&, maximizedClient%
DIM swpFrame AS SWP
'|
'| Obtain current frame window size
'|
  bool% = WinQueryWindowPos(hwndFrame&,_
                            MakeLong(VARSEG(swpFrame), VARPTR(swpFrame)))
'|
'| Hide Menus
'|
  bool% = WinShowWindow(hwndMenu&, 0)
'|
'| Set Client window size using width and height values of the frame window
'|
  bool% = WinSetWindowPos(hwnd&, 0, 0, 0,_
                          swpFrame.cx, swpFrame.cy,_
                          SWPSIZE OR SWPMOVE)
  maximizedClient% = 1
END SUB


'|***************************************************************************
'| Removes CHECK from menu item pointed to by "oldChecked%" and places a
'| check on the menu item pointed to by "newChecked%".
'|***************************************************************************
SUB ResetCheckedMenuItem(oldChecked%, newChecked%)
SHARED hwndMenu&
'|
'| Remove check from menu item
'|
  bool% = WinSendMsg(hwndMenu&, MMSETITEMATTR,_
                     MakeLong(TRUE, oldChecked%),_
                     MakeLong(0, MIACHECKED))
'|
'| Place a check on menu item
'|
  bool% = WinSendMsg(hwndMenu&, MMSETITEMATTR,_
                     MakeLong(TRUE, newChecked%),_
                     MakeLong(MIACHECKED, MIACHECKED))
END SUB


'|***************************************************************************
'| The Client Window is Cleared to the current background color or the Client
'| window is filled with the color blue, depending on the predefined bitmap
'| selected.  Bitmaps 2 and 4, the OS/2 symbol and the Bug face, have blue
'| backgrounds therefore the Client window is cleared to blue.
'|***************************************************************************
SUB ClearTheClientWindow(hps&)
SHARED hab&, index%, cxClient%, cyClient%
DIM rect AS RECTL
 IF index% = 2 OR index% = 4 THEN
 '|
 '| Fill Client window with blue
 '|
   rect.xright = cxClient%
   rect.ytop   = cyClient%
   bool% = WinFillRect(hps&,_
                       MakeLong(VARSEG(rect), VARPTR(rect)),_
                       1) '*** 1 is CLRBLUE
 ELSE
 '|
 '| Clear Client window to current background color.
 '|
   bool% = GpiErase(hps&)
 END IF
END SUB


'|***************************************************************************
'| Using the MessageBox routine, a short help screen is displayed, using
'| the text contianed in the variable length STRING message$.  The CHR$(13)
'| and CHR$(10) characters force carriage returns and line feeds in the
'| displayed help text.
'|***************************************************************************
SUB DisplayHelp
  caption$ = CHR$(0)
  message$ = "1.) To change speed and direction of bitmap, click and hold "+_
             "Left mouse button on bitmap, then push bitmap in new direction "+_
             "and speed and release button." + CHR$(13) +_
             "2.) To pause bitmap, Click and release Left mouse button "+_
             "anywhere within viewing window, execpt on bitmap." + CHR$(13) +_
             "3.) To clear viewing window, click right mouse button "+_
             "anywhere within the viewing window." + CHR$(13) + CHR$(10)+_
             "CLIPBOARD:" + CHR$(13) +_
             "- Selecting the Clipboard menu will Fling the contents of "+_
             "the Clipboard if it is a bitmap.  A bitmap can be placed "+_
             "in the clipboard using the program CAPTURE.BAS" + CHR$(0)
  bool% = WinMessageBox(HWNDDESKTOP, HWNDDESKTOP,_
                        MakeLong(VARSEG(message$), SADD(message$)),_
                        MakeLong(VARSEG(caption$), SADD(caption$)),_
                        0,_
                        MBICONASTERISK OR MBAPPLMODAL)
END SUB

