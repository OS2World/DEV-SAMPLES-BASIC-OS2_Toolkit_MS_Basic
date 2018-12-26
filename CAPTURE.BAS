'|***************************************************************************
'|
'| Program Name: Capture.BAS
'|
'| Description:    CAPTURE is a bitmap utility program.  It does not create
'|               bitmaps in the sense of being able to draw them.  It
'|               Creates bitmaps by capturing all or a portion of the entire
'|               visible screen.  It can stretch bitmaps upto the size of
'|               the visible screen, and can compress them to the minimum
'|               size allowed for a Client window, which is determined by
'|               the minimum size for a frame window.  This size will vary
'|               from machine to machine depending on the video hardware.
'|               bitmap format.  Existing bitmaps can be loaded from a disk
'|               file or from the system clipboard, and can be saved to
'|               disk file or to the system clipboard.  The clipborad can
'|               either be loaded to be used as the current bitmap or can
'|               be pasted over any portion of the existing bitmap and
'|               and combined.  With a little imagination, utilizing the
'|               system clipboard and running multiple copies of CAPTURE can
'|               produce interesting bitmaps.
'|                 The bitmap file can used by other PM programs utilizing
'|               bitmaps.  The bitmap can be place in a programs resource or
'|               loaded directly from the bitmap file and then displayed and
'|               edited using the various bitmap GPI routines available.
'|               Many of these routines are demonstrated in this program.
'|
'|                 This program also demonstrates the very useful
'|               library OPENDLG.DLL.  The dialog box displayed
'|               when the "Load" and "Save" menu items are selected is
'|               completely controlled by routines in this Dynamic Linked
'|               Library.  To use the routines in OPENDLG.DLL, the program
'|               must include the file "OPENDLG.BI" and the library
'|               OPENDLG.LIB must be linked into the program.
'|
'| Source files: Capture.BAS   main program
'|               Scrolmod.BAS  support module to control scroll bars
'|               Loadmod.BAS   support module to load a bitmap from disk
'|               Savemod.BAS   support module to save a bitmap to disk
'|               Dialgmod.BAS  support module to control dialog box used
'|                             by the "SetFrameWindowSize" SUBprocedure
'|               Capture.INC   include file cut & pasted from BI files
'|               Capture.DEF   definition file
'|               Capture.RC    resource file
'|               Capture.ICO   icon file
'|  
'| Compiling and
'| Linking:      BC capture/o;
'|               BC scrolmod/o;
'|               BC loadmod/o;
'|               BC savemod/o;
'|               BC dialgmod/o;
'|
'|               LINK /NOE capture+
'|                         scrolmod+
'|                         loadmod+
'|                         savemod+
'|                         dialgmod,,, OS2.LIB REGBAS.LIB OPENDLG.LIB, capture;
'|
'| Resourec:     RC capture  (compiles and adds resource to Capture.EXE)
'|
'|***************************************************************************
'|
'|********         Initialization section        ***********
'|
REM $INCLUDE: 'os2def.bi'
REM $INCLUDE: 'pmbase.bi'
REM $INCLUDE: 'opendlg.bi'
REM $INCLUDE: 'winmisc.bi'
REM $INCLUDE: 'wintrack.bi'
REM $INCLUDE: 'gpibit.bi'

REM $INCLUDE: 'CAPTURE.INC'

DIM aqmsg AS QMSG

flFrameFlags& = FCFTITLEBAR      OR FCFSYSMENU    OR_
                FCFSIZEBORDER    OR FCFMINMAX     OR_
                FCFSHELLPOSITION OR FCFTASKLIST   OR_
                FCFHORZSCROLL    OR FCFVERTSCROLL OR_
                FCFMENU          OR FCFICON       OR_
                FCFNOBYTEALIGN

szClientClass$ = "ClassName" + CHR$(0)
szTitle$ = ": PM-BASIC Bitmap utility" + CHR$(0)
hab& = WinInitialize(0)
hmq& = WinCreateMsgQueue(hab&, 0)

bool% = WinRegisterClass(_
   hab&,_
   MakeLong(VARSEG(szClientClass$), SADD(szClientClass$)),_
   RegBas,_
   CSSIZEREDRAW OR CSMOVENOTIFY,_
   0)

hwndFrame& = WinCreateStdWindow (_
   HWNDDESKTOP,_
   WSVISIBLE,_
   MakeLong (VARSEG(flFrameFlags&), VARPTR(flFrameFlags&)),_
   MakeLong (VARSEG(szClientClass$), SADD(szClientClass$)),_
   MakeLong (VARSEG(szTitle$), SADD(szTitle$)),_
   0,_
   0,_
   IDRESOURCE,_
   MakeLong (VARSEG(hwndClient&), VARPTR(hwndClient&)))

'|
'|*************         Message loop         ***************
'|
WHILE WinGetMsg(hab&,_
  MakeLong(VARSEG(aqmsg), VARPTR(aqmsg)), 0, 0, 0)
  bool% = WinDispatchMsg(hab&,_
                         MakeLong(VARSEG(aqmsg), VARPTR(aqmsg)))
WEND

'|**********         Finalize section        ***************

bool% = WinDestroyWindow(hqd2wndFrame&)
bool% = WinDestroyMsgQueue(hmq&)
bool% = WinTerminate(hab&)
END


'|***************************************************************************
'|      *************         Window procedure        ***************
'|***************************************************************************
'|
FUNCTION ClientWndProc& (hwnd&, msg%, mp1&, mp2&) STATIC
SHARED hab&, hwndFrame&, hbm&, hpsClient&, hpntr&
SHARED hwndMenu&, hwndVertScroll&, hwndHorzScroll&
SHARED seconds%, hideORshow%, displaysize%, maximizedClient%
SHARED cxScreen%, cyScreen%, cxClient%, cyClient%, oldcxClient%, oldcyClient%

  SELECT CASE msg%
  '|
  '| Initialize variables to  default values, obtain handle to menu bar
  '| to be used in "checking" and "unchecking" menu items, and obtain
  '| resolution of the entire visible screen, and frame window border size.
  '|
    CASE WMCREATE
      hideORshow%   = HIDEWINDOW
      displaysize%  = ACTUALSIZE
      delay%        = 1 'second
      cxScreen% = WinQuerySysValue(HWNDDESKTOP, SVCXSCREEN)
      cyScreen% = WinQuerySysValue(HWNDDESKTOP, SVCYSCREEN)
      hpntr& = WinLoadPointer(HWNDDESKTOP, 0, IDPOINTER)
      hwndMenu& = WinWindowFromID(_
                                WinQueryWindow(hwnd&, QWPARENT, FALSE),_
                                FIDMENU)
      hwndHorzScroll& = WinWindowFromID(_
                                WinQueryWindow(hwnd&, QWPARENT, FALSE),_
                                FIDHORZSCROLL)
      hwndVertScroll& = WinWindowFromID(_
                                WinQueryWindow(hwnd&, QWPARENT, FALSE),_
                                FIDVERTSCROLL)
      ClientWndProc& = 0
  '|
  '| The SAVE, COPY, and PASTE Edit menu item must have a bitmap
  '| captured or loaded before they can be used, so they are
  '| enable or disabled depending on whether there is a bitmap
  '| currently in memory
  '|
    CASE WMINITMENU
      IF hbm& = 0 THEN attribute% = MIADISABLED ELSE attribute% = 0
      CALL SetStatusOfEditMenuItems(attribute%)
      ClientWndProc& = 0
  '|
  '| Obtain new Client window size
  '|
    CASE WMSIZE
      CALL BreakLong(mp1&, oldcyClient%, oldcxClient%)
      CALL BreakLong(mp2&, cyClient%, cxClient%)
      CALL SetScrollBarStatus
      IF maximizedClient% = 1 THEN CALL MaximizeTheClientWindow(hwnd&)
      hidecontrolsflag% = 0
    '|
    '| To prevent a bitmap being created that is larger than the visible
    '| screen, the SUBprogram CheckIfFrameIsGreaterThanMaximum is CALLed to
    '| check for this.  If it is to large it is resized to a valid size.
    '|
      CALL CheckIfFrameIsGreaterThanMaximum
      bool% = WinInvalidateRect(hwnd&, 0, 0)
      ClientWndProc&=0

    CASE WMMOVE
      IF useFrame% = 1 THEN bool% = WinPostMsg(hwnd&, WMPAINT, 0, 0)
      ClientWndProc&=0
  '|
  '| Erase then redraw the current bitmap, if one has been created or loaded.
  '| Since the Client window does not have physical size until the first
  '| WMPAINT message, the minimum frame window size cannot be calculated
  '| during the WMCREATE message, so it is calculated during the first
  '| WMPAINT message which is actually sent before entering the message loop.
  '|
    CASE WMPAINT, WMUSER
      IF firstpaint% = 0 THEN CALL CalculateMinimumFrameWindowSize(hwnd&)
      IF maximizedClient% = 1 THEN bool% = WinInvalidateRect(hwnd&, 0, 0)
      IF useFrame% = 1 THEN
        bool% = WinShowWindow(hwndFrame&, 0)
        FOR I = 1 TO 3500: NEXT
        bool% = WinShowWindow(hwndFrame&, 1)
      END IF
      hpsClient& = WinBeginPaint(hwnd&, 0, 0)
      IF useFrame% = 0 THEN bool% = GpiErase(hpsClient&)
      IF hbm& <> 0 THEN CALL DisplayCapturedBitmap
      bool% = WinEndPaint(hpsClient&)
      firstpaint% = 1
      ClientWndProc&=0
  '|
  '| Once the timer is started, the WMTIMER message is sent every 1000 ms,
  '| or 1 second.  When a number of seconds passes equal to the current
  '| delay setting, the timer is stopped.  If "Partial Screen" was selected,
  '| the user then selects the portion of the screen to capture.  The
  '| entire or portion of the screen is then captured to a bitmap.
  '| If SHOWWINDOW was selected, the Client window is invalidated to cause
  '| a WMPAINT message to be sent.  This is not neccessary when HIDEWINDOW
  '| is selected since when the Client window is made visible after the
  '| bitmap is captured, a WMPAINT message is automatically sent.
  '|
    CASE WMTIMER
      seconds% = seconds% + 1
      IF seconds% = delay% THEN
      '|
      '| If "delay" seconds has passed, capture or select portion of
      '| screen to capture.
      '|
        bool% = DosBeep(1500,50)
        StopCountDownToCapture(hwnd&)
        IF useFrame% = 1 THEN
          caption$ = CHR$(0)
          message$ = "Once the Frame window reappears, position "+_
                     "and/or resize viewing window until what "+_
                     "you wish to capture is within the Viewing window, "+_
                     "then select 'Capture Viewing Window contents' from "+_
                     "'Capture menu'" + CHR$(0)
          bool% = DisplayMessageBox(message$, caption$, 3)
          bool% = WinSetFocus(HWNDDESKTOP, hwndFrame&)
          bool% = WinPostMsg(hwnd&, WMUSER, 0, 0)
        ELSE
          IF screenpart% <> USINGTRACK THEN
            CALL CaptureScreenToBitmap(hwnd&)
          ELSEIF SelectPortionOfScreenToCapture = MBIDOK THEN
            CALL CaptureScreenToBitmap(hwnd&)
          END IF
          bool% = WinInvalidateRect(hwnd&, 0, 0)
        END IF
        CALL SetScrollBarStatus
      ELSE
      '|
      '| If time has not yet elapsed, BEEP, signaling a second has passed.
      '|
        bool% = DosBeep(1000,100)
      END IF
      ClientWndProc& = 0
  '|
  '| Reposition bitmap and scrollbar
  '|
    CASE WMHSCROLL, WMVSCROLL
      CALL ControlScrollBars(hwnd&, msg%, mp2&)
      ClientWndProc& = 0
  '|
  '| WMCOMMAND routine handles all menu selections.  The timer is stopped,
  '| the menuID is obtained from the lowword of mp1&, and then the
  '| appropriate routine is executed determined by the menuID stored in
  '| menuSelection%.  Selecting any menu item will stop the countdown if
  '| one is in progress
  '|
    CASE WMCOMMAND
      CALL StopCountDownToCapture(hwnd&)
      IF (hideORshow% = HIDEWINDOW) OR (useFrame% = 1)_
                                    THEN bool% = WinShowWindow(hwndFrame&, 1)
      useFrame% = 0
      CALL BreakLong(mp1&, dummy%, menuSelection%)
      lastcommand% = menuSelection%
      SELECT CASE menuSelection%
      '|
      '| User selected capture menu.  Hides window depending on value
      '| of "hideORshow%", and sets area to capture to entire screen
      '| depending on menu selected.  The timer is then started to countdown
      '| to bitmap capture, or time when user can select portion of screen
      '| to capture, after which the screen is captured.
      '|
        CASE ENTIRESCREEN, USINGTRACK, USINGFRAME, CLIENTWINDOW
          SELECT CASE menuSelection%
            CASE ENTIRESCREEN
              CALL SetCaptureRectToEntireScreen
            CASE CLIENTWINDOW
              CALL SetCaptureRectToClientWindow(hwnd&)
            CASE USINGFRAME
              IF maximizedClient% = 1 THEN
                caption$ = CHR$(0)
                message$ = "Cannot capture using Frame if Viewing Window "+_
                           "is maximized." + CHR$(0)
                bool% = DisplayMessageBox(message$, caption$, 2)
                bool% = WinInvalidateRect(hwnd&, 0, 0)
                nostart% = 1
              ELSE
                bool% = GpiDeleteBitmap(hbm&)
                hbm& = 0
                useFrame% = 1
              END IF
            CASE ELSE
          END SELECT
          IF (hideORshow% = HIDEWINDOW) AND (nostart% = 0) THEN_
                                      bool% = WinShowWindow(hwndFrame&, 0)
          screenpart% = menuselection%
          bool% = DosBeep(1000, 100)
          IF nostart% = 0 THEN bool% = WinStartTimer(hab&, hwnd&, IDTIMER, 1000)
          nostart% = 0
      '|
      '| Calls SetTheFrameWindowSize to allow user to select a specific
      '| window size, Maximize or Restore to original size
      '|
        CASE SETFRAMEWINDOWSIZE, MAXIMIZEFRAMEWINDOW, RESTOREWINDOW
          CALL SetTheFrameWindowSize(hwnd&, menuSelection%)
      '|
      '| Maximize or Restore The ClientWindow to hide or reveal the menus and
      '| controls.
      '|
        CASE MAXIMIZECLIENTWINDOW
          useFrame% = 0
          IF maximizedClient% = 0 THEN CALL MaximizeOrRestoreTheClientWindow(hwnd&)
        CASE RESTORECLIENTWINDOW
          IF maximizedClient% = 1 THEN CALL MaximizeOrRestoreTheClientWindow(hwnd&)
      '|
      '| Set flag to determine whether to hide of show window during
      '| the capturing of the screen, then "check" corresponding menuitem
      '|
        CASE HIDEWINDOW, SHOWWINDOW
          lastoption% = hideORshow%
          hideORshow% = menuselection%
          CALL ResetCheckedMenuItem(lastoption%, menuselection%)
      '|
      '| Set flag to determine whether to display captured bitmap actual size
      '| or to stretch or compress bitmap to exactly fill the Client window,
      '| then invalidate the Client window to cause a WMPAINT message to be
      '| sent.  This will cause the bitmap to be displayed using the selected
      '| display option.  The corresponding menuitem is also "checked"
      '|
        CASE ACTUALSIZE, STRETCH
          lastoption% = displaysize%
          displaysize% = menuselection%
          CALL ResetCheckedMenuItem(lastoption%, menuselection%)
          CALL SetScrollBarStatus
          IF lastoption% <> displaysize% THEN bool% = WinInvalidateRect(hwnd&, 0, 0)
      '|
      '| Set delay to selected value, and the "check" corresponding menuitem.
      '|
        CASE IDMDELAY+1 TO IDMDELAY+60
          lastdelay% = delay% + IDMDELAY
          delay% = menuselection% - IDMDELAY
          CALL ResetCheckedMenuItem(lastdelay%, menuselection%)
     
        CASE LOADBITMAPFILE
          CALL LoadBitmapFromFile(hwndFrame&, hwnd&, hbm&)
          
        CASE SAVEBITMAP
          CALL SaveBitmapToFile(hab&, hwndFrame&, hbm&)
  
        CASE COPYTOCLIPBOARD
          CALL CopyBitmapToClipBoard(hab&, hwnd&, hbm&)

        CASE LOADCLIPBOARD
          CALL LoadBitmapFromClipBoard(hab&, hbm&, hwnd&)
          
        CASE PASTECLIPBOARD
          IF displaysize% = ACTUALSIZE THEN
            CALL PasteClipboardOverCurrentBitmap(hwnd&)
          ELSE
            caption$ = CHR$(0)
            message$ = "Bitmap must be displayed actual size before "+_
                       "clipboard can be pasted over current bitmap" + CHR$(0)
            bool% = DisplayMessageBox(message$, caption$, 2)
          END IF

        CASE ERASEWINDOW
          useFrame% = 0
          bool% = GpiDeleteBitmap(hbm&)
          hbm& = 0
          CALL SetScrollBarStatus
          bool% = WinInvalidateRect(hwnd&, 0, 0)
                                           
        CASE EXITPROGRAM
        '|
        '| Delete bitmap and post WMQUIT message to terminate program
        '|
          bool% = GpiDeleteBitmap(hbm&)
          bool% = WinPostMsg(hwnd&, WMQUIT, 0, 0)

        CASE ELSE

      END SELECT
      ClientWndProc&=0

    CASE ELSE
      ClientWndProc& = WinDefWindowProc(hwnd&, msg%, mp1&, mp2&)

  END SELECT
END FUNCTION


'|***************************************************************************
'| Since there is no system value for the minimum frame window size (not an
'| icon, the minimum Frame window size is determined by setting the window
'| to a size that is smaller than the minimum size, (i.e. width = 1, height = 1)
'| It you attempt to set the window to a size smaller than the smallest
'| size possible, the window will be set to the smallest window size.
'| The resulting window size is then obtained and the width value is saved
'| in the variable minFrame%.  Once the minimum value is obtained, the
'| frame window is restored to its shell postion and size.
'|
'| To make a symetrical minimum frame window size, and since the minimum
'| width is always greater than the minimum height, the minumum height is
'| set equal to the minimum width, so only one value need be saved.
'|***************************************************************************
SUB CalculateMinimumFrameWindowSize(hwnd&)
SHARED hwndFrame&, minFrame%, swpShell AS SWP
DIM rect AS RECTL
  bool% = WinQueryWindowPos(hwndFrame&,_
                            MakeLong(VARSEG(swpShell), VARPTR(swpShell)))
  bool% = WinSetWindowPos(hwndFrame&, 0, 0, 0, 1, 1,_
                          SWPSIZE )
  bool% = WinQueryWindowRect(hwndFrame&,_
                             MakeLong(VARSEG(rect), VARPTR(rect)))
  minFrame% = rect.xright
  bool% = WinSetWindowPos(hwndFrame&, 0,_
                          swpShell.x, swpShell.y,_
                          swpShell.cx, swpShell.cy,_
                          SWPSIZE OR SWPMOVE)
END SUB


'|***************************************************************************
'| If The scroll bars are needed, this routine sets the range and initial
'| position of both the horizontal and vertical scroll bars
'|***************************************************************************
'|
SUB SetScrollBarStatus
SHARED hbm&, hwndVertScroll&, hwndHorzScroll&
SHARED cxClient%, cyClient%, oldcxClient%, oldcyClient%, displaysize%
DIM bih AS BITMAPINFOHEADER
  IF displaysize% = STRETCH THEN
  '|
  '| Scroll bars cannot be used if bitmap is STRETCHED
  '|
    bool% = WinEnableWindow(hwndHorzScroll&, FALSE)
    bool% = WinEnableWindow(hwndVertScroll&, FALSE)
  ELSE
  '|
  '| Get bitmap dimensions to be used in determining scroll bar ranges
  '|
    bool% = GpiQueryBitmapParameters(hbm&,_
                                     MakeLong(VARSEG(bih), VARPTR(bih)))
    IF bih.cx <= cxClient% THEN
    '|
    '| If bitmap is not as wide as Client window, horizontal scroll bar
    '| is not needed, so disable it
    '|
      bool% = WinEnableWindow(hwndHorzScroll&, FALSE)
    ELSEIF cxClient% <> oldcxClient% THEN
    '|
    '| Enable horizontal scroll bar and set range and initial position
    '|
      bool% = WinEnableWindow(hwndHorzScroll&, TRUE)
      bool% = WinSendMsg(hwndHorzScroll&,_
                         SBMSETSCROLLBAR,_
                         MakeLong(0, 0),_
                         MakeLong((bih.cx - cxClient%), 0))
    END IF
    IF bih.cy <= cyClient% THEN
    '|
    '| If bitmap is not as high as Client window, vertical scroll bar
    '| is not needed, so disable it
    '|

      bool% = WinEnableWindow(hwndVertScroll&, FALSE)
    ELSEIF cyClient% <> oldcyClient% THEN
    '|
    '| Enable vertical scroll bar and set range and initial position
    '|
      bool% = WinEnableWindow(hwndVertScroll&, TRUE)
      bool% = WinSendMsg(hwndVertScroll&,_
                         SBMSETSCROLLBAR,_
                         MakeLong(0, (bih.cy - cyClient%)),_
                         MakeLong((bih.cy - cyClient%), 0))
    END IF
  END IF
END SUB


'|***************************************************************************
'| Stops the timer and resets "seconds" to zero
'|***************************************************************************
'|
SUB StopCountDownToCapture(hwnd&)
SHARED hab&, seconds%
  bool% = WinStopTimer(hab&, hwnd&, IDTIMER)
  seconds% = 0
END SUB


'|***************************************************************************
'| This routine removes the check from the menuitem with the ID corresponding
'| to the menuID passed in "oldChecked%", and places a check on the menuitem
'| corresponding the the menuID passed in "newChecked%".
'|***************************************************************************
'|
SUB ResetCheckedMenuItem(oldChecked%, newChecked%)
SHARED hwndMenu&
'|
'| Remove check from menu item
'|
  bool% = WinSendMsg(hwndMenu&, MMSETITEMATTR,_
                     MakeLong(TRUE, oldChecked%),_
                     MakeLong(0, MIACHECKED))
'|
'| Place a check on the menu item
'|
  bool% = WinSendMsg(hwndMenu&, MMSETITEMATTR,_
                     MakeLong(TRUE, newChecked%),_
                     MakeLong(MIACHECKED, MIACHECKED))
END SUB


'|***************************************************************************
'| If either the width or height of the frame window is greater than the
'| maximum size, the window is resized and postioned to the maximum size.
'|***************************************************************************
SUB CheckIfFrameIsGreaterThanMaximum
SHARED hwndFrame&, cxScreen%, cyScreen%
DIM swpFrame AS SWP
'|
'| Obtain current window size
'|
  bool% = WinQueryWindowPos(hwndFrame&,_
                            MakeLong(VARSEG(swpFrame), VARPTR(swpFrame)))
'|
'| determine if either width or height is greater than maximum
'|
  IF swpFrame.cx > cxScreen% OR swpFrame.cy > cyScreen% THEN
  '|
  '| If width is greater than maximum reset size and postion
  '|
    IF swpFrame.cx > cxScreen% THEN
      swpFrame.x = 0
      swpFrame.cx = cxScreen%
    END IF
  '|
  '| If height is greater than maximum reset size and postion
  '|
    IF swpFrame.cy > cyScreen% THEN
      swpFrame.y = 0
      swpFrame.cy = cyScreen%
    END IF
  '|
  '| Set window to new size and postion
  '|
    bool% = WinSetWindowPos(hwndFrame&, 0,_
                            swpFrame.x, swpFrame.y,_
                            swpFrame.cx, swpFrame.cy,_
                            SWPSIZE OR SWPMOVE)
  END IF
END SUB


'|***************************************************************************
'| Set area to capture to entire screen using the system values stored in
'| cxScreen% and cyScreen%, which were obtained during program start up
'| during the WMCREATE message.
'|***************************************************************************
'|
SUB SetCaptureRectToEntireScreen
SHARED cxScreen%, cyScreen%
SHARED captureRect AS RECTL
  captureRect.xLeft   = 0
  captureRect.xRight  = cxScreen%
  captureRect.yTop    = cyScreen%
  captureRect.yBottom = 0
END SUB


'|***************************************************************************
'| Set area to capture to contents of the Client Window.  The rectangle is
'| calculated differently depending on whether the option "Maximize viewing
'| window" has been selected or not.
'|***************************************************************************
SUB SetCaptureRectToClientWindow(hwnd&)
SHARED hwndFrame&, maximizedClient%, captureRect AS RECTL
DIM swpFrame AS SWP, swpClient AS SWP
'|
'| Obtain current Frame and Cleint window sizes and positions
'|
  bool% = WinQueryWindowPos(hwndFrame&,_
                            MakeLong(VARSEG(swpFrame), VARPTR(swpFrame)))
  bool% = WinQueryWindowPos(hwnd&,_
                            MakeLong(VARSEG(swpClient), VARPTR(swpClient)))
'|
'| Calculate Screen coordinates of Client window
'|
  IF maximizedClient% = 1 THEN
    captureRect.xLeft   = swpFrame.x
    captureRect.xRight  = captureRect.xLeft + swpFrame.cx
    captureRect.yBottom = swpFrame.y
    captureRect.yTop    = captureRect.ybottom + swpFrame.cy
  ELSE
    captureRect.xLeft   = swpFrame.x + swpClient.x
    captureRect.xRight  = captureRect.xLeft + swpClient.cx
    captureRect.yBottom = swpFrame.y + swpClient.y
    captureRect.yTop    = captureRect.ybottom + swpClient.cy
  END IF
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
    CALL ResetCheckedMenuItem(MAXIMIZECLIENTWINDOW, RESTORECLIENTWINDOW)
  ELSE
  '|
  '| Maximize the Client Window
  '|
    CALL MaximizeTheClientWindow(hwnd&)
    CALL ResetCheckedMenuItem(RESTORECLIENTWINDOW, MAXIMIZECLIENTWINDOW)
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
'| Set Client window size using width and height values of the frame window
'|
  bool% = WinSetWindowPos(hwnd&, 0, 0, 0,_
                          swpFrame.cx, swpFrame.cy,_
                          SWPSIZE OR SWPMOVE)
  maximizedClient% = 1
END SUB

'|***************************************************************************
'| Sets the frame window size to a specific size, maximizes the window, or
'| restores it to the orginal size and postion.  The Maximize and Restore
'| options can be selected directly from the menu or from the dialog box
'| displayed if SetFrameWindowSize was selected.
'|***************************************************************************
SUB SetTheFrameWindowSize(hwnd&, menuSelection%)
SHARED hwndFrame&, newXFrame%, newYFrame%, cxScreen%, cyScreen%
SHARED swpFrame AS SWP, swpShell AS SWP
  IF menuSelection% = SETFRAMEWINDOWSIZE THEN
  '|
  '| Display dialog box and obtain new size for the frame window
  '|
    control% = WinDlgBox(HWNDDESKTOP, hwnd&, RegBas1, 0, IDRESOURCE, 0)
  ELSE
    control% = menuSelection%
  END IF
  SELECT CASE control%
    CASE OKBUTTON
    '|
    '| Set frame window to new size selected by user; but first determine
    '| if any portion of the window will extend off the visible screen.
    '| If so, adjust position of window so that entire window is visible.
    '|
      bool% = WinQueryWindowPos(hwndFrame&,_
                                MakeLong(VARSEG(swpFrame), VARPTR(swpFrame)))
      IF (swpFrame.x + newXFrame%) > cxScreen% THEN
        swpFrame.x = cxScreen% - newXFrame%
      END IF
      IF (swpFrame.y + newYFrame%) > cyScreen% THEN
        swpFrame.y = cyScreen% - newYFrame%
      END IF
      bool% = WinSetWindowPos(hwndFrame&, 0,_
                              swpFrame.x, swpFrame.y,_
                              newXFrame%, newYFrame%,_
                              SWPSIZE OR SWPMOVE)
    CASE MAXIMIZEBUTTON, MAXIMIZEFRAMEWINDOW
    '|
    '| If Maximize menu or Maximize button from dialog box is selected,
    '| maximize the frame window.
    '|
      bool% = WinSetWindowPos(hwndFrame&, 0, 0, 0,_
                              cxScreen%, cyScreen%,_
                              SWPSIZE OR SWPMOVE)
    CASE RESTOREBUTTON, RESTOREWINDOW
    '|
    '| If Restore menu or Restore button from dialog box is selected,
    '| Restore the frame window to origianl size and position.
    '|
      bool% = WinSetWindowPos(hwndFrame&, 0,_
                              swpShell.x,  swpShell.y,_
                              swpShell.cx, swpShell.cy,_
                              SWPSIZE OR SWPMOVE)
    CASE ELSE
  END SELECT
END SUB


'|***************************************************************************
FUNCTION SelectPortionOfScreenToCapture%
SHARED hbm&, hwndFrame&, hpntr&
SHARED cxScreen%, cyScreen%, hideORshow%, captureRect AS RECTL
DIM ti AS TRACKINFO
'|
'| Initialize "message$" to STRING containing instructions for selecting
'| portion of screen, and then display message box.  If user selects "OK"
'| continue and select portion of screen to capture.
'|
  message$="Position pointer to upper-left corner of area "+_
           "to be captured, then click left mouse button.  "+_
           "Stretch box around area to be captured, then "+_
           "click left mouse button again." + CHR$(0)
  caption$ = "PARTIAL SCREEN"+CHR$(0)

  IF DisplayMessageBox(message$, caption$, 1) = MBIDOK THEN
  '|
  '| Obtain handle to a screen presentation space
  '|
    hpsScreen& = WinGetScreenPS(HWNDDESKTOP)
  '|
  '| Set pointer to four point pointer
  '|
    bool% = WinSetPointer(HWNDDESKTOP, hpntr&)
  '|
  '| Initialize Tracking information. Pointer is initially displayed at
  '| the center of the screen, and no rectangle is visible since the
  '| rectangle size is initially set to 1x1, and all sides of the
  '| tracking rectangle move.
  '|
    ti.cxBorder = 1
    ti.cyBorder = 1
    ti.cxGrid = 0
    ti.cyGrid = 0
    ti.cxKeyboard = 4
    ti.cyKeyboard = 4
    ti.rclBoundary.xleft = 0
    ti.rclBoundary.ybottom = 0
    ti.rclBoundary.xright = cxScreen%
    ti.rclBoundary.ytop = cyScreen%
    ti.ptlMinTrackSize.x = 1
    ti.ptlMinTrackSize.y = 1
    ti.ptlMaxTrackSize.x = ti.rclBoundary.xright
    ti.ptlMaxTrackSize.y = ti.rclBoundary.ytop
    ti.rclTrack.xleft = ti.rclBoundary.xright / 2
    ti.rclTrack.yBottom = ti.rclBoundary.ytop / 2
    ti.rclTrack.xRight = ti.rclBoundary.xright / 2
    ti.rclTrack.ytop = ti.rclBoundary.ytop / 2
    ti.fs = TFMOVE OR TFSTANDARD OR TFSETPOINTERPOS
  '|
  '| Obtain upper left hand corner of area to be captured.  The tracking
  '| rectangle is simply a single pixel during this call to WinTrackRect
  '| so only the pointer is visible.  When the left mouse button is
  '| clicked, WinTractRect returns, new parameters are set which allow
  '| the rectangle to be resized down and to the right of the selected
  '| upper left hand corner of the the area to be captured.
  '|
    bool% = WinTrackRect(HWNDDESKTOP, 0,_
                         MakeLong(VARSEG(ti), VARPTR(ti)))
  '|
  '| Set new parameters for tracking rectangle.  Can only expand
  '| rectangle down or to the right.
  '|
    ti.fs = TFBOTTOM OR TFRIGHT OR TFSTANDARD OR TFSETPOINTERPOS
  '|
  '| Obtain area to be captured
  '|
    bool% = WinTrackRect(HWNDDESKTOP, 0,_
                         MakeLong(VARSEG(ti), VARPTR(ti)))
  '|
  '| Set capture rectangle to rectangle returned from WinTrackRect
  '|
    captureRect.xLeft   = ti.rclTrack.xLeft
    captureRect.xRight  = ti.rclTrack.xRight
    captureRect.yTop    = ti.rclTrack.yTop
    captureRect.yBottom = ti.rclTrack.yBottom
    IF captureRect.yTop = cyScreen% THEN captureRect.yTop = captureRect.yTop - 1
    bool% = WinReleasePS(hpsScreen&)
    SelectPortionOfScreenToCapture% = MBIDOK
  ELSE
  '|
  '| User selected CANCEL from message box, so no area is selected
  '|
    SelectPortionOfScreenToCapture% = MBIDCANCEL
    IF hideORshow% = HIDEWINDOW THEN
      bool% = WinShowWindow(hwndFrame&, 1)
    '|
    '| Must set focus back to CAPTURE since if CANCEL is selected, the
    '| is not returned to CAPTURE from the message box
    '|
      bool% = WinSetFocus(HWNDDESKTOP, hwndFrame&)
    END IF
  END IF
END FUNCTION


'|***************************************************************************
'| Captures the selected portion of the screen to a bitmap.
'|***************************************************************************
'|
SUB CaptureScreenToBitmap(hwnd&)
SHARED hbm&, hwndFrame&, hwndMenu&, hpsClient&, hideORshow%, captureRect AS RECTL
DIM bih AS BITMAPINFOHEADER, aptl(2) AS POINTL
'|
'| Set system pointer to wait pointer since this can take a few seconds
'|
  CALL SetSystemPointerToWaitPointer
'|
'| Initialize bitmap information
'|
  bih.cbFix = LEN(bih)
  bih.cx = captureRect.xright - captureRect.xleft
  bih.cy = captureRect.ytop - captureRect.ybottom
  bih.cPlanes = 1
  bih.cBitCount = 4
'|
'| Create micro presentation space and device context.
'| Delete current bitmap.
'| Create a new bitmap using info in "bih" (bitmap info header)
'| Set bitmap to presentation space.
'| Get a screen presentation space to allow copying from entire screen
'|
  CALL CreateBitmapPSandDC(hpsBitmap&, hdc&)
  bool% = GpiDeleteBitmap(hbm&)
  hbm& = GpiCreateBitmap(hpsBitmap&,_
                         MakeLong(VARSEG(bih), VARPTR(bih)),_
                         0, 0, 0)
  bool% = GpiSetBitmap(hpsBitmap&, hbm&)
  hpsScreen& = WinGetScreenPS(HWNDDESKTOP)
'|
'| Set aptl() to source and target rectangles
'|
  aptl(0).x = 0
  aptl(0).y = 0
  aptl(1).x = bih.cx
  aptl(1).y = bih.cy
  aptl(2).x = captureRect.xleft
  aptl(2).y = captureRect.ybottom
'|
'| Copy area defind by the rectangle returned by WinTractRect to the
'| micro presentation space created above.
'|
  bool% = GpiBitBlt(hpsBitmap&, hpsScreen&, 3&,_
                    MakeLong(VARSEG(aptl(0)), VARPTR(aptl(0))),_
                    ROPSRCCOPY, BBOAND)
'|
'| Release screen presentation space, micro presentation space, and destroy
'| device context used to create bitmap.
'|
  bool% = WinReleasePS(hpsScreen&)
  bool% = GpiDestroyPS(hpsBitmap&)
  bool% = DevCloseDC(hdc&)
'|
'| If window was hidden, show window, and set focus to Client window,
'| since the Client window lost the focus during the creation of the bitmap
'|
  IF hideORshow% = HIDEWINDOW THEN
    bool% = WinShowWindow(hwndFrame&, 1)
    bool% = WinSetFocus(HWNDDESKTOP, hwndFrame&)
  END IF
  CALL SetSystemPointerToStandardArrow
END SUB


'|***************************************************************************
'| Displays captured bitmap in Client window.  It is either displayed actual
'| size, in which case some of the bitmap may not be visible depending on the
'| current size of the Client window; or it is stretched or compressed to
'| to the same size as the Client window, in which case the entire bitmap
'| will always be visible.
'|***************************************************************************
'|
SUB DisplayCapturedBitmap
SHARED hbm&, hwndHorzScroll&, hwndVertScroll&, hpsClient&
SHARED cxClient%, cyClient%, displaysize%
DIM rect AS RECTL
  CALL SetSystemPointerToWaitPointer
'|
'| Set drawing flag to STRETCH or NORMAL
'|
  IF displaysize% = STRETCH THEN
    drawflag% = DBMSTRETCH
  ELSE
    drawflag% = DMBNORMAL
  END IF
'|
'| Get scroll bar positions to determine portion of bitmap to display
'|
  Hpos% = WinSendMsg(hwndHorzScroll&, SBMQUERYPOS, 0, 0)
  Vpos% = WinSendMsg(hwndVertScroll&, SBMQUERYPOS, 0, 0)
  Vmax% = WinSendMsg(hwndVertScroll&, SBMQUERYRANGE, 0, 0) \ 2 ^ 16
'|
'| If scroll bars are enabled, calculate offset from scroll positions
'|
  IF WinIsWindowEnabled(hwndHorzScroll&) THEN rect.xleft = -Hpos%
  IF WinIsWindowEnabled(hwndVertScroll&) THEN rect.ybottom = Vpos% - Vmax%
'|
'| Initialize rectangle to which bitmap will be drawn.
'|
  rect.xright  = cxClient%
  rect.ytop    = cyClient%
  bool% = WinDrawBitmap(hpsClient&, hbm&, 0,_
                        MakeLong(VARSEG(rect), VARPTR(rect)),_
                        CLRNEUTRAL, CLRBACKGROUND, drawflag%)
  CALL SetSystemPointerToStandardArrow
END SUB

'|***************************************************************************
'| Make a copy of the current bitmap and set clipboard contents to copy of
'| the bitmap.
'|***************************************************************************
SUB CopyBitmapToClipBoard(hab&, hwnd&, hbm&)
  IF WinOpenClipBrd(hab&) THEN
  '|
  '| If Clipboard is avaiable, copy bitmap to clipboard
  '|
    hbmClip& = MakeCopyOfBitmap(hbm&)
    bool% = WinEmptyClipBrd(hab&)
    bool% = WinSetClipbrdData(hab&, hbmClip&, CFBITMAP, CFIHANDLE)
    bool% = WinCloseClipbrd(hab&)
  ELSE
  '|
  '| If clipboard is not avaiable, display message to prompt user
  '|
    caption$ = CHR$(0)
    message$ = "ERROR opening Clipboard.  Another process might "+_
               "be using system clipboard" + CHR$(0)
    bool% = DisplayMessageBox(message$, caption$, 2)
  END IF
END SUB


'|***************************************************************************
'| Loads bitmap from system clibboard if clibboard contains a bitmap.
'|***************************************************************************
SUB LoadBitmapFromClipBoard(hab&, hbm&, hwnd&)
  IF WinOpenClipBrd(hab&) THEN
  '|
  '| If clibboard contains a bitmap, make copy of bitmap
  '|
    hbmclip& = WinQueryClipBrdData(hab&, CFBITMAP)
    IF hbmclip& <> 0 THEN
      bool% = GpiDeleteBitmap(hbm&)
      CALL SetSystemPointerToWaitPointer
      hbm& = MakeCopyOfBitmap(hbmclip&)
    '|
    '| Invalidate Window to force the new bitmap to be displayed
    '|
      CALL SetScrollBarStatus
      bool% = WinInvalidateRect(hwnd&, 0, 0)
      CALL SetSystemPointerToStandardArrow
    ELSE
    '|
    '| Display message to prompt user that clipboard does not contain a bitmap
    '|
      caption$ = CHR$(0)
      message$ = "The Clipboard does not contain a bitmap" + CHR$(0)
      bool% = DisplayMessageBox(message$, caption$, 2)
    END IF
    bool% = WinCloseClipbrd(hab&)
  ELSE
  '|
  '| If clipboard is not avaiable, display message to prompt user
  '|
    caption$ = CHR$(0)
    message$ = "ERROR opening Clipboard.  Another process might "+_
               "be using system clipboard" + CHR$(0)
    bool% = DisplayMessageBox(message$, caption$, 2)
  END IF
END SUB


'|***************************************************************************
SUB PasteClipboardOverCurrentBitmap(hwnd&)
SHARED hab&, hpsClient&, hbm&, hwndFrame&, hwndHorzScroll&, hwndVertScroll&
DIM ti AS TRACKINFO, aptl(2) AS POINTL
DIM bihCurrent AS BITMAPINFOHEADER, bihClip AS BITMAPINFOHEADER
'|
'| Check If clibboard is available
'|
  IF WinOpenClipBrd(hab&) THEN
  '|
  '| Check if clibboard contains a bitmap
  '|
    hbmClip& = WinQueryClipBrdData(hab&, CFBITMAP)
    IF hbmClip& <> 0 THEN
    '|
    '| Initialize "message$" to STRING containing instructions for positioning
    '| bitmap from Clipboard
    '|
      message$="Move rectangle to desired position and "+_
                "Click the left Mouse Button" + CHR$(0)
      caption$ = "PASTE CLIPBOARD BITMAP" + CHR$(0)
    '|
    '| Display instructions for pasting clibboard bitmap, and give user
    '| options to cancel command.
    '|
      IF DisplayMessageBox(message$, caption$, 1) = MBIDOK THEN
        bool% = WinSetPointer(HWNDDESKTOP,_
                              WinQuerySysPointer(HWNDDESKTOP, SPTRMOVE, 0))
      '|
      '| Get Clipboard bitmap information
      '|
        bool% = GpiQueryBitmapParameters(_
                                hbmClip&,_
                                MakeLong(VARSEG(bihClip), VARPTR(bihClip)))
      '|
      '| Get current bitmap information
      '|
        bool% = GpiQueryBitmapParameters(_
                            hbm&,_
                            MakeLong(VARSEG(bihCurrent), VARPTR(bihCurrent)))
      '|
      '| Initialize Tracking information. Pointer is placed in center of
      '| rectangle.  Rectangle is set to size of Bitmap in Clipboard.
      '| Boundary for pasting bitmap is boundary of current bitmap.
      '|
        ti.cxBorder = 1
        ti.cyBorder = 1
        ti.cxKeyboard = 4
        ti.cyKeyboard = 4
        ti.rclBoundary.xleft = bihClip.cx - 1
        ti.rclBoundary.ybottom = bihClip.cy - 1
        ti.rclBoundary.xright = bihCurrent.cx - bihClip.cx + 1
        ti.rclBoundary.ytop = bihCurrent.cy - bihClip.cy + 1
        ti.ptlMinTrackSize.x = bihClip.cx
        ti.ptlMinTrackSize.y = bihClip.cy
        ti.ptlMaxTrackSize.x = bihClip.cx
        ti.ptlMaxTrackSize.y = bihClip.cy
        ti.rclTrack.xleft = 0
        ti.rclTrack.yBottom = 0
        ti.rclTrack.xRight = bihClip.cx
        ti.rclTrack.ytop = bihClip.cy
        ti.fs = TFMOVE OR TFSTANDARD OR TFSETPOINTERPOS
      '|
      '| Obtain postion within current bitmap to paste Clipboard bitmap
      '|
        bool% = WinTrackRect(hwnd&, 0,_
                             MakeLong(VARSEG(ti), VARPTR(ti)))
      '|
      '| Create presentation space, device context for Clibboard and
      '| current bitmap
      '|
        CALL CreateBitmapPSandDC(hpsCurrent&, hdcCurrent&)
        CALL CreateBitmapPSandDC(hpsClip&, hdcClip&)
        bool% = GpiSetBitmap(hpsCurrent&, hbm&)
        bool% = GpiSetBitmap(hpsClip&, hbmClip&)
      '|
      '| Get scroll bar positions and determine offset from scrollbar
      '| positions if scroll bar is enabled.
      '|
        Hpos% = WinSendMsg(hwndHorzScroll&, SBMQUERYPOS, 0, 0)
        Vpos% = WinSendMsg(hwndVertScroll&, SBMQUERYPOS, 0, 0)
        Vmax% = WinSendMsg(hwndVertScroll&, SBMQUERYRANGE, 0, 0) \ 2 ^ 16
        IF WinIsWindowEnabled(hwndHorzScroll&) THEN Hoffset% = Hpos%
        IF WinIsWindowEnabled(hwndVertScroll&) THEN Voffset% = Vmax% - Vpos%
      '|
      '| Set target rectangle to to size of clibboard bitmap and set position
      '| to location tracking rectangle
      '|
        aptl(0).x = ti.rclTrack.xleft + Hoffset%
        aptl(0).y = ti.rclTrack.yBottom + Voffset%
        aptl(1).x = ti.rclTrack.xright + Hoffset%
        aptl(1).y = ti.rclTrack.ytop + Voffset%
        aptl(2).x = 0
        aptl(2).y = 0
      '|
      '| Paste the clipboard bitmap onto the current bitmap
      '|
        bool% = GpiBitBlt(hpsCurrent&, hpsClip&, 3,_
                          MakeLong(VARSEG(aptl(0)), VARPTR(aptl(0))),_
                          ROPSRCCOPY, BBOAND)
      '|
      '| Release and destroy presentation spaces and device contexts of
      '| current and clibboard bitmap.
      '|
        bool% = GpiDestroyPS(hpsCurrent&)
        bool% = GpiDestroyPS(hpsClip&)
        bool% = DevCloseDC(hdcCurrent&)
        bool% = DevCloseDC(hdcClip&)
        CALL SetSystemPointerToStandardArrow
      '|
      '| Invalidate window to force new bitmap to be displayed.
      '|
        bool% = WinInvalidateRect(hwnd&, 0, 0)
      END IF
    ELSE
    '|
    '| Display message to prompt user that clipboard does not contain a bitmap
    '|
      caption$ = CHR$(0)
      message$ = "The Clipboard does not contain a bitmap" + CHR$(0)
      bool% = DisplayMessageBox(message$, caption$, 2)
    END IF
    bool% = WinCloseClipbrd(hab&)
  ELSE
  '|
  '| If clipboard is not avaiable, display message to prompt user
  '|
    caption$ = CHR$(0)
    message$ = "ERROR opening Clipboard.  Another process might "+_
               "be using system clipboard" + CHR$(0)
    bool% = DisplayMessageBox(message$, caption$, 2)
  END IF
END SUB


'|***************************************************************************
'| Makes a copy of bitmap reference by the bitmap handle passed in hbmSource&
'|***************************************************************************
FUNCTION MakeCopyOfBitmap&(hbmSource&)
DIM bih AS BITMAPINFOHEADER, aptl(2) AS POINTL
'|
'| Create presentation spaces and device contextes for source and target
'| bitmap
'|
  CALL CreateBitmapPSandDC(hpsSource&, hdcSource&)
  CALL CreateBitmapPSandDC(hpsTarget&, hdcTarget&)
'|
'| Get Bitmap info of Source bitmap
'|
  bool% = GpiQueryBitmapParameters(hbmSource&,_
                                   MakeLong(VARSEG(bih), VARPTR(bih)))
'|
'| Create a new bitmap using info from Source bitmap
'|                          
  hbmTarget& = GpiCreateBitmap(hpsTarget&,_
                               MakeLong(VARSEG(bih), VARPTR(bih)),_
                               0, 0, 0)
'|
'| Set source and target bitmaps to corresponing presentation spaces
'|                      
  bool% = GpiSetBitmap(hpsSource&, hbmSource&)
  bool% = GpiSetBitmap(hpsTarget&, hbmTarget&)
'|
'| Set rectangle of Source bitmap to be copied to entire bitmap
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
'| Release presentation spaces and device contextes used to create new bitmap
'|           
  bool% = GpiDestroyPS(hpsSource&)
  bool% = GpiDestroyPS(hpsTarget&)
  bool% = DevCloseDC(hdcSource&)
  bool% = DevCloseDC(hdcTarget&)
  MakeCopyOfBitmap& = hbmTarget&
END FUNCTION


'|***************************************************************************
'| Creates a micro presentation space and a memory device context and returns
'| the handles to the CALLing routine.
'|***************************************************************************
SUB CreateBitmapPSandDC(hps&, hdc&)
SHARED hab&
DIM sizl AS SIZEL
'|
'| Initialize information for Memory Device Context, then open
'| a memory device context.  Create same size as bitmap.
'|
  token$ = "*" + CHR$(0)
  sizl.cx = 0
  sizl.cy = 0
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
'| Enables or disables the Paste Menu item depending on the value of
'| "attribute%"
'|***************************************************************************
SUB SetStatusOfEditMenuItems(attribute%)
SHARED hwndMenu&
  bool% = WinSendMsg(hwndMenu&, MMSETITEMATTR,_
                     MakeLong(TRUE, SAVEBITMAP),_
                     MakeLong(attribute%, MIADISABLED))
  bool% = WinSendMsg(hwndMenu&, MMSETITEMATTR,_
                     MakeLong(TRUE, COPYTOCLIPBOARD),_
                     MakeLong(attribute%, MIADISABLED))
  bool% = WinSendMsg(hwndMenu&, MMSETITEMATTR,_
                     MakeLong(TRUE, PASTECLIPBOARD),_
                     MakeLong(attribute%, MIADISABLED))
END SUB

'|***************************************************************************
'| Sets system pointer to the WAIT pointer for a routines that might take
'| a few seconds or more.
'|***************************************************************************
SUB SetSystemPointerToWaitPointer
  bool% = WinSetPointer(HWNDDESKTOP,_
                        WinQuerySysPointer(HWNDDESKTOP, SPTRWAIT, 0))
END SUB


'|***************************************************************************
'| Sets system pointer back to the standard system pointer
'|***************************************************************************
SUB SetSystemPointerToStandardArrow
  bool% = WinSetPointer(HWNDDESKTOP,_
                        WinQuerySysPointer(HWNDDESKTOP, SPTRARROW, 0))
END SUB


'|***************************************************************************
'| Displays message box using values passed in message$ and caption$.  Makes
'| displaying message boxes easier if used in various places in a program.
'|***************************************************************************
FUNCTION DisplayMessageBox%(message$, caption$, style%)
IF style% = 1 THEN styleflag% = MBOKCANCEL OR MBICONQUESTION OR MBAPPLMODAL
IF style% = 2 THEN styleflag% = MBICONHAND OR MBAPPLMODAL
IF style% = 3 THEN styleflag% = MBICONASTERISK OR MBAPPLMODAL
DisplayMessageBox% = WinMessageBox(_
       HWNDDESKTOP, HWNDDESKTOP,_
       MakeLong(VARSEG(message$), SADD(message$)),_
       MakeLong(VARSEG(caption$), SADD(caption$)),_
       0,_
       styleflag%)
END FUNCTION
