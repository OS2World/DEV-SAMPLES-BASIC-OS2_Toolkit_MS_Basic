'�**********************************************************
'�
'� Program Name: GpiDemo.BAS
'�
'� Description:  This programs combineds most of the example
'�               programs for the Gpi include files into one.
'�               Each menu item essentially executes the Gpi
'�               example program for that area, however, in this
'�               program, each of the example programs included
'�               were converted to OBJect which contain no module
'�               level code.  The OBject are then LINKed together
'�               into one EXE file.
'�                 A description of what each module does is
'�               in the documentation contained in the source of
'�               each module.
'�
'� Source Files: GpiDemo.BAS  --  Main Module    
'�               ArcMod.BAS   --  Routines from GpiArc.BAS
'�               LineMod.BAS  --  Routines from GpiLine.BAS
'�               AreaMod.BAS  --  These three modules Demonstrate
'�               MarkMod.BAS      the same CALLs as the example     
'�               BitMod.BAS       programs for their include file,
'�                                but are completely different programs.
'�
'� Data files:   GpiDemo.RC   --  Resouce file containing all menu,
'�                                icon, bitmap, and dialogbox definitions.
'�               GpiDemo.ICO  --  Icon file created with ICONEDIT.EXE.
'�               GpiDemo1.BMP --  Bitmap file used in several routines
'�                                in the BitMod module.  File was
'�                                created with ICONEDIT.EXE
'�               GpiDemo2.BMP --  Bitmap file used in the "4 Plane Bitmap"
'�                                routine in the BitMod module.  Bitmap was
'�                                created with a program that uses the same
'�                                method as the "Capture Bitmap" routine
'�                                in the BitMod module, with the exception
'�                                of the Bitmap being written to a file.
'�               GpiDemo3.BMP --  Bitmap file used in the "Custom Fill..."
'�                                routine in the BitMod module.
'�
'� This program is Compiled and Linked as follows:
'�
'�   BC Gpidemo /o;
'�   BC ArcMod  /o;
'�   BC LineMod /o;
'�   BC AreaMod /o;
'�   BC MarkMod /o;
'�   BC BitMod  /o;
'�
'�   LINK Gpidemo ArcMod LineMod AreaMod MarkMod BitMod,,, Regbas.LIB OS2.LIB, Gpidemo.def;
'�
'�   RC GpiDemo     -- Compiles and adds resource file to EXE
'�   RC -r GpiDemo  -- Compile resouce file but does not add to EXE
'�   RC GpiDemo.RES -- Adds or replaces Compiled resouce to EXE
'�
'�**********************************************************

'�********         Initialization section        ***********

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
'�
'�*************         Message loop         ***************
'�
WHILE WinGetMsg(hab&,_
  MakeLong(VARSEG(aqmsg), VARPTR(aqmsg)), 0, 0, 0)
  bool% = WinDispatchMsg(hab&,_
                         MakeLong(VARSEG(aqmsg), VARPTR(aqmsg)))
WEND

'�**********         Finalize section        ***************

bool% = WinDestroyWindow(hwndFrame&)
bool% = WinDestroyMsgQueue(hmq&)
bool% = WinTerminate(hab&)
END

'�**********         Window procedure        ***************
'
FUNCTION ClientWndProc& (hwnd&, msg%, mp1&, mp2&) STATIC
SHARED cxClient%, cyClient%, lastgpi%, dclicked%, hwndFrame&

  SELECT CASE msg%
    '�
    '� Obtain new size of Client window
    '�
    CASE WMSIZE
      CALL BreakLong(mp2&, cyClient%, cxClient%)
      ClientWndProc&=0
    '�
    '� Ivalidate entire Client window so entire window is repainted.
    '� Do not erase Client window if last item selected was "Capture Bitmap"
    '� CALL DisplayChoice to execute currently selected item.
    '�
    CASE WMPAINT
      bool% = WinInvalidateRect(hwnd&, 0, 0)
      hps& = WinBeginPaint(hwnd&, 0, 0)
      IF lastgpi% <> IDMBIT+4 THEN bool% = GpiErase(hps&)
      CALL DisplayChoice(-hwnd&, hps&)
      bool% = WinEndPaint(hps&)
      ClientWndProc&=0
    '�
    '� Obtain ID of menuitem selected and place in "lastgpi%"
    '� Do not erase Client window if last item selected was "Capture Bitmap"
    '� "dclicked%" is a flag used in the "Begin/End Area" routine in the
    '� Area/Colors module to determine if the routine is being called due
    '� to a WMPAINT (dclicked% = 0) or a WMCOMMAND (dclicked% = 0) message.
    '�
    CASE WMCOMMAND
      hps& = WinGetPS(hwnd&)
      CALL BreakLong(mp1&, dummy%, lastgpi%)
      IF lastgpi% <> IDMBIT+4 THEN bool% = GpiErase(hps&)
      dclicked% = 1
      CALL DisplayChoice(hwnd&, hps&)
      dclicked% = 0
      bool% = WinReleasePS(hps&)
      ClientWndProc&=0
    '�
    '� The message is processed only if the currently selected menuitem
    '� is "Begin/End Area" in the "Area/Colors" module.  Clicking the
    '� If "Begin/End Area" is the currently selected menuitem, clicking
    '� the left mouse button will display a new picture without having
    '� to go through the menu again.
    '�
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


'�**************************************************************
'� This routine simply passes control to the routine coresponding to the
'� selected menuitem, passing appropriate parameters.  The statement
'� "hwnd& = ABS(shwnd&)" takes the absolute value of shwnd& since some
'� of the routines use a negative "hwnd&" (shwnd&) as a flag to determine
'� exactly what is to be done.  Routines using this flag are passed shwnd&
'� instead of hwnd&.  The routines using "shwnd&" always convert it to
'� a positive value before passing the local variable "hwnd" to any
'� of the Presentation Manager routines.  A additional paramater could be
'� passed to these routines to be used as the flag.  The decision to use
'� a negative "hwnd&" is purely arbitrary.
'�
SUB DisplayChoice(shwnd&, hps&)
SHARED lastgpi%, dclicked%, hwndFrame&, hab&

  hwnd& = ABS(shwnd&)
  SELECT CASE lastgpi%
    CASE IDMEXIT
      DoYouReallyWantToQuit(hwnd&)
    '�
    '� Submenu items under the "Arcs" top level menuitem
    '�
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
    '�
    '� Top level menuitem "Lines"
    '�
    CASE IDMLINE
      CALL DemoLine(hps&)
    '�
    '� Submenu items under the "Area/Colors" top level menuitem
    '�
    CASE IDMAREA+1
      CALL DemoPatterns(hps&)
    CASE IDMAREA+3, IDMAREA+4, IDMAREA+5
      CALL DemoBeginEndArea(shwnd&, hps&, lastgpi%, dclicked%)
    '�
    '� Top level Menuitem "GraphMarkers"
    '�
    CASE IDMMARK+1 TO IDMMARK+10
      CALL DemoMark(hps&, lastgpi%)
    '�
    '� Submenu items under the "Bitmaps" top level menuitem
    '�
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


'�**************************************************************
'� Displays message boxes to determine if the user really wants to quit
'� The box is displayed a maximum of three times with a slightly different
'� message every time "YES" is selected from the message box.  If "YES"
'� is selected on the third message box, the program is terminated.
'�
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


'�**************************************************************
'� Using WinMessageBox, this routine displays a message box using the
'� message and caption contained in "message$" and "caption$"
'� The message box contains a question mark icon, and a "YES" and "NO"
'� pushbutton.
'�
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


'�**************************************************************
'� Simply converts a double precision value to a fixed point 32 bit value,
'� used by several routines in the various modules.
'�
FUNCTION MakeFixed&(realnum#)
  MakeFixed& = realnum# * 2 ^ 16
END FUNCTION
