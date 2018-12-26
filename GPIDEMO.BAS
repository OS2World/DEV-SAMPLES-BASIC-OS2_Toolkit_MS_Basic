'³**********************************************************
'³
'³ Program Name: GpiDemo.BAS
'³
'³ Description:  This programs combineds most of the example
'³               programs for the Gpi include files into one.
'³               Each menu item essentially executes the Gpi
'³               example program for that area, however, in this
'³               program, each of the example programs included
'³               were converted to OBJect which contain no module
'³               level code.  The OBject are then LINKed together
'³               into one EXE file.
'³                 A description of what each module does is
'³               in the documentation contained in the source of
'³               each module.
'³
'³ Source Files: GpiDemo.BAS  --  Main Module    
'³               ArcMod.BAS   --  Routines from GpiArc.BAS
'³               LineMod.BAS  --  Routines from GpiLine.BAS
'³               AreaMod.BAS  --  These three modules Demonstrate
'³               MarkMod.BAS      the same CALLs as the example     
'³               BitMod.BAS       programs for their include file,
'³                                but are completely different programs.
'³
'³ Data files:   GpiDemo.RC   --  Resouce file containing all menu,
'³                                icon, bitmap, and dialogbox definitions.
'³               GpiDemo.ICO  --  Icon file created with ICONEDIT.EXE.
'³               GpiDemo1.BMP --  Bitmap file used in several routines
'³                                in the BitMod module.  File was
'³                                created with ICONEDIT.EXE
'³               GpiDemo2.BMP --  Bitmap file used in the "4 Plane Bitmap"
'³                                routine in the BitMod module.  Bitmap was
'³                                created with a program that uses the same
'³                                method as the "Capture Bitmap" routine
'³                                in the BitMod module, with the exception
'³                                of the Bitmap being written to a file.
'³               GpiDemo3.BMP --  Bitmap file used in the "Custom Fill..."
'³                                routine in the BitMod module.
'³
'³ This program is Compiled and Linked as follows:
'³
'³   BC Gpidemo /o;
'³   BC ArcMod  /o;
'³   BC LineMod /o;
'³   BC AreaMod /o;
'³   BC MarkMod /o;
'³   BC BitMod  /o;
'³
'³   LINK Gpidemo ArcMod LineMod AreaMod MarkMod BitMod,,, Regbas.LIB OS2.LIB, Gpidemo.def;
'³
'³   RC GpiDemo     -- Compiles and adds resource file to EXE
'³   RC -r GpiDemo  -- Compile resouce file but does not add to EXE
'³   RC GpiDemo.RES -- Adds or replaces Compiled resouce to EXE
'³
'³**********************************************************

'³********         Initialization section        ***********

REM $INCLUDE: 'os2def.bi'
REM $INCLUDE: 'pmbase.bi'
REM $INCLUDE: 'winman1.bi'
REM $INCLUDE: 'wininput.bi'
REM $INCLUDE: 'windialg.bi'
REM $INCLUDE: 'winmsgs.bi'
REM $INCLUDE: 'winmenu.bi'
REM $INCLUDE: 'winframe.bi'
REM $INCLUDE: 'winpoint.bi'

REM $INCLUDE: 'GpiDemo.INC'

DIM aqmsg AS QMSG
DIM mi AS MENUITEM

flFrameFlags& = FCFTITLEBAR      OR FCFSYSMENU OR _
                FCFSIZEBORDER    OR FCFMINMAX  OR _
                FCFSHELLPOSITION OR FCFTASKLIST OR_
                FCFMENU          OR FCFICON

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
   WSINVISIBLE,_
   MakeLong (VARSEG(flFrameFlags&), VARPTR(flFrameFlags&)),_
   MakeLong (VARSEG(szClientClass$), SADD(szClientClass$)),_
   0,_
   0,_
   0,_
   IDRESOURCE,_
   MakeLong (VARSEG(hwndClient&), VARPTR(hwndClient&)))

bool% = WinSetWindowPos(hwndFrame&, 0,0,0,0,0, SWPSHOW OR SWPMAXIMIZE)
'³
'³*************         Message loop         ***************
'³
WHILE WinGetMsg(hab&,_
  MakeLong(VARSEG(aqmsg), VARPTR(aqmsg)), 0, 0, 0)
  bool% = WinDispatchMsg(hab&,_
                         MakeLong(VARSEG(aqmsg), VARPTR(aqmsg)))
WEND

'³**********         Finalize section        ***************

bool% = WinDestroyWindow(hwndFrame&)
bool% = WinDestroyMsgQueue(hmq&)
bool% = WinTerminate(hab&)
END

'³**********         Window procedure        ***************
'
FUNCTION ClientWndProc& (hwnd&, msg%, mp1&, mp2&) STATIC
SHARED cxClient%, cyClient%, lastgpi%, dclicked%, hwndFrame&

  SELECT CASE msg%
    '³
    '³ Obtain new size of Client window
    '³
    CASE WMSIZE
      CALL BreakLong(mp2&, cyClient%, cxClient%)
      ClientWndProc&=0
    '³
    '³ Ivalidate entire Client window so entire window is repainted.
    '³ Do not erase Client window if last item selected was "Capture Bitmap"
    '³ CALL DisplayChoice to execute currently selected item.
    '³
    CASE WMPAINT
      bool% = WinInvalidateRect(hwnd&, 0, 0)
      hps& = WinBeginPaint(hwnd&, 0, 0)
      IF lastgpi% <> IDMBIT+4 THEN bool% = GpiErase(hps&)
      CALL DisplayChoice(-hwnd&, hps&)
      bool% = WinEndPaint(hps&)
      ClientWndProc&=0
    '³
    '³ Obtain ID of menuitem selected and place in "lastgpi%"
    '³ Do not erase Client window if last item selected was "Capture Bitmap"
    '³ "dclicked%" is a flag used in the "Begin/End Area" routine in the
    '³ Area/Colors module to determine if the routine is being called due
    '³ to a WMPAINT (dclicked% = 0) or a WMCOMMAND (dclicked% = 0) message.
    '³
    CASE WMCOMMAND
      hps& = WinGetPS(hwnd&)
      CALL BreakLong(mp1&, dummy%, lastgpi%)
      IF lastgpi% <> IDMBIT+4 THEN bool% = GpiErase(hps&)
      dclicked% = 1
      CALL DisplayChoice(hwnd&, hps&)
      dclicked% = 0
      bool% = WinReleasePS(hps&)
      ClientWndProc&=0
    '³
    '³ The message is processed only if the currently selected menuitem
    '³ is "Begin/End Area" in the "Area/Colors" module.  Clicking the
    '³ If "Begin/End Area" is the currently selected menuitem, clicking
    '³ the left mouse button will display a new picture without having
    '³ to go through the menu again.
    '³
    CASE WMBUTTON1UP
      IF lastgpi% = IDMAREA+3 OR_
         lastgpi% = IDMAREA+4 OR_
         lastgpi% = IDMAREA+5 THEN
        hps& = WinGetPS(hwnd&)
        bool% = GpiErase(hps&)
        dclicked% = 1
        CALL DisplayChoice(hwnd&, hps&)
        dclicked% = 0
        bool% = WinReleasePS(hps&)
        ClientWndProc& = 0
      ELSE
        ClientWndProc& = WinDefWindowProc(hwnd&, msg%, mp1&, mp2&)
      ENDIF

    CASE WMCLOSE
      DoYouReallyWantToQuit(hwnd&)
      ClientWndProc&=0

    CASE ELSE        'Pass control to system for other messages
      ClientWndProc& = WinDefWindowProc(hwnd&, msg%, mp1&, mp2&)
  END SELECT

END FUNCTION


'³**************************************************************
'³ This routine simply passes control to the routine coresponding to the
'³ selected menuitem, passing appropriate parameters.  The statement
'³ "hwnd& = ABS(shwnd&)" takes the absolute value of shwnd& since some
'³ of the routines use a negative "hwnd&" (shwnd&) as a flag to determine
'³ exactly what is to be done.  Routines using this flag are passed shwnd&
'³ instead of hwnd&.  The routines using "shwnd&" always convert it to
'³ a positive value before passing the local variable "hwnd" to any
'³ of the Presentation Manager routines.  A additional paramater could be
'³ passed to these routines to be used as the flag.  The decision to use
'³ a negative "hwnd&" is purely arbitrary.
'³
SUB DisplayChoice(shwnd&, hps&)
SHARED lastgpi%, dclicked%, hwndFrame&, hab&

  hwnd& = ABS(shwnd&)
  SELECT CASE lastgpi%
    CASE IDMEXIT
      DoYouReallyWantToQuit(hwnd&)
    '³
    '³ Submenu items under the "Arcs" top level menuitem
    '³
    CASE IDMARC+1                      
      CALL DemoGpiPointArc(hps&,1)
    CASE IDMARC+2
      CALL DemoGpiFullArc(hps&,1)
    CASE IDMARC+3
      CALL DemoGpiPartialArc(hps&,1)
    CASE IDMARC+4
      CALL DemoGpiPolyFilletSharp(hps&,1)
    CASE IDMARC+5
      CALL DemoGpiPolySpline(hps&,1)
    CASE IDMARC+6
      CALL DemoGpiPolyFillet(hps&,1)
    CASE IDMARC+7
      CALL DemoGpiPointArc(hps&,0)
      CALL DemoGpiFullArc(hps&,0)
      CALL DemoGpiPartialArc(hps&,0)
      CALL DemoGpiPolySpline(hps&,0)
      CALL DemoGpiPolyFillet(hps&,0)
      CALL DemoGpiPolyFilletSharp(hps&,0)
    '³
    '³ Top level menuitem "Lines"
    '³
    CASE IDMLINE
      CALL DemoLine(hps&)
    '³
    '³ Submenu items under the "Area/Colors" top level menuitem
    '³
    CASE IDMAREA+1
      CALL DemoPatterns(hps&)
    CASE IDMAREA+3, IDMAREA+4, IDMAREA+5
      CALL DemoBeginEndArea(shwnd&, hps&, lastgpi%, dclicked%)
    '³
    '³ Top level Menuitem "GraphMarkers"
    '³
    CASE IDMMARK+1 TO IDMMARK+10
      CALL DemoMark(hps&, lastgpi%)
    '³
    '³ Submenu items under the "Bitmaps" top level menuitem
    '³
    CASE IDMBIT+1
      CALL Demo1PlaneBitmap(hps&)
    CASE IDMBIT+2
      CALL Demo4PlaneBitmap(hps&)
    CASE IDMBIT+3
      CALL DemoResizeBitmap(hwnd&, hps&)
    CASE IDMBIT+4
      CALL DemoCaptureAndMagnify(hab&, hwndFrame&, shwnd&, hps&)
    CASE IDMBIT+5
      CALL DemoFillWithBitmap(hps&)
    CASE IDMBIT+10 TO IDMBIT+34
      CALL DemoSystemBitmaps(hps&, lastgpi%)
    CASE ELSE
  END SELECT
END SUB


'³**************************************************************
'³ Displays message boxes to determine if the user really wants to quit
'³ The box is displayed a maximum of three times with a slightly different
'³ message every time "YES" is selected from the message box.  If "YES"
'³ is selected on the third message box, the program is terminated.
'³
SUB DoYouReallyWantToQuit(hwnd&)
message$ = "Are you sure you want to QUIT?" + chr$(0)
caption$ = " " + chr$(0)
IF DisplayMessageBox%(message$, caption$) = MBIDYES THEN
  message$ = "Are you positive?" + chr$(0)
  caption$ = " " + chr$(0)
  IF DisplayMessageBox%(message$, caption$) = MBIDYES THEN
    message$ = "Are you absolutely positively sure you really want to QUIT?" + chr$(0)
    caption$ = " " + chr$(0)
    IF DisplayMessageBox%(message$, caption$) = MBIDYES THEN
      bool% = WinPostMsg(hwnd&, WMQUIT, 0&, 0&)
    END IF
  END IF
END IF
END SUB


'³**************************************************************
'³ Using WinMessageBox, this routine displays a message box using the
'³ message and caption contained in "message$" and "caption$"
'³ The message box contains a question mark icon, and a "YES" and "NO"
'³ pushbutton.
'³
FUNCTION DisplayMessageBox%(message$, caption$)
DisplayMessageBox% = WinMessageBox(_
       HWNDDESKTOP, HWNDDESKTOP,_
       MakeLong(VARSEG(message$), SADD(message$)),_
       MakeLong(VARSEG(caption$), SADD(caption$)),_
       0,_
       MBYESNO OR_
       MBICONQUESTION OR_
       MBAPPLMODAL)
END FUNCTION


'³**************************************************************
'³ Simply converts a double precision value to a fixed point 32 bit value,
'³ used by several routines in the various modules.
'³
FUNCTION MakeFixed&(realnum#)
  MakeFixed& = realnum# * 2 ^ 16
END FUNCTION
