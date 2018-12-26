'***********************************************************
'* 
'* Program Name: WinPoint.BAS
'*
'* Include File: WinPoint.BI
'*
'* Functions   :
'*               WinSetPointer
'*               WinShowPointer
'*               WinQuerySysPointer
'*               WinLoadPointer
'*               WinDestroyPointer
'*               WinCreatePointer
'*               WinQueryPointer
'*               WinSetPointerPos
'*               WinQueryPointerPos
'*               WinQueryPointerInfo
'*               WinDrawPointer
'*               WinGetSysBitmap
'*
'* Description : This program demonstrates the various mouse
'*               pointer functions. All calls are done in the
'*               ClientWndProc. An array of handles for various
'*               mouse pointers is set up on the creation of the
'*               window. Each pointer is drawn in the window in
'*               each style (normal, half-toned, inverted).
'*
'*               The following is a list of actions and effects
'*               for this program:
'*
'*        Action              Effect
'*        ------              ------
'*        Create window       Set up array of handles
'*        Key Pressed         Change mouse position (swap x,y)
'*        Button 1 down       Get current handle and info then
'*                            set pointer to next in array
'*        Button 2 down       Make pointer invisible for 5 seconds
'*        Close window        Destroy non-system pointers
'***********************************************************

'*********         Initialization section        ***********

REM $INCLUDE: 'PMBase.BI'
REM $INCLUDE: 'WinPoint.BI'
REM $INCLUDE: 'OS2Def.BI'	Needed for POINTL
REM $INCLUDE: 'WinInput.BI'	Needed for mouse and key messages

'Number of pointers in array: all system ptrs, all system bmps, & 1 loaded ptr
CONST NumPointers = SPTRCPTR + SBMPSIZEBOX + 1

DIM aqmsg AS QMSG

flFrameFlags& =  FCFTITLEBAR      OR FCFSYSMENU OR _
                 FCFSIZEBORDER    OR FCFMINMAX  OR _
                 FCFSHELLPOSITION OR FCFTASKLIST

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
             WSVISIBLE,_
             MakeLong(VARSEG(flFrameFlags&),  VARPTR(flFrameFlags&)),_
             MakeLong(VARSEG(szClientClass$), SADD(szClientClass$)),_
             0,_
             0,_
             0,_
             0,_
             MakeLong(VARSEG(hwndClient&), VARPTR(hwndClient&)))

'Only data written to this file is PointerInfo on button 1 down
OPEN "WinPoint.OUT" FOR OUTPUT AS #1

'**************         Message loop         ***************

WHILE WinGetMsg(hab&, MakeLong(VARSEG(aqmsg), VARPTR(aqmsg)), 0, 0, 0)
  bool% = WinDispatchMsg(hab&, MakeLong(VARSEG(aqmsg), VARPTR(aqmsg)))
WEND

'***********         Finalize section        ***************

CLOSE #1

bool% = WinDestroyWindow   (hwndFrame&)
bool% = WinDestroyMsgQueue (hmq&)
bool% = WinTerminate       (hab&)

END

'***********         Window procedure        ***************

FUNCTION ClientWndProc& (hwnd&, msg%, mp1&, mp2&) STATIC
     DIM ClientRect AS RECTL
     ClientWndProc& = 0
     SELECT CASE msg%
     CASE WMCREATE

	'** Set up array for pointer handles
        DIM HPointers(NumPointers - 1) AS LONG
        FOR i% = 0 TO NumPointers - 1

	   IF i% < SPTRCPTR THEN      ' First part of array is sys pointers
	     HPointers(i%) = WinQuerySysPointer& (HWNDDESKTOP, i%+1, DPNORMAL)

	   ELSEIF i% < SPTRCPTR + SBMPSIZEBOX THEN    'Second is sys bitmaps
	     HPointers(i%) = WinCreatePointer (HWNDDESKTOP,_
                             WinGetSysBitmap&(HWNDDESKTOP, i% - SPTRCPTR),_
                             1, 1, 1)

	   ELSE 		       ' One pointer loaded from resource
             HPointers(i%) = WinLoadPointer(HWNDDESKTOP, 0, 1)
	   END IF
	NEXT i%

     CASE WMCHAR

	'** Change pointer position; swap x and y
	DIM ptl AS POINTL
	IF (mp1& AND KCKEYUP) = 0 THEN
	  Bool% = WinQueryPointerPos (HWNDDESKTOP,_
                  MakeLong(VARSEG(ptl), VARPTR(ptl)))
	  Bool% = WinSetPointerPos   (HWNDDESKTOP, ptl.y, ptl.x)
	END IF

     CASE WMBUTTON1DOWN

	'** Query current pointer and info. Then write info to file
	DIM PInfo AS POINTERINFO
        HPoint& = WinQueryPointer     (HWNDDESKTOP)
        Bool%   = WinQueryPointerInfo (HPoint&,_
                  MakeLong(VARSEG(PInfo), VARPTR(PInfo)))
	PRINT #1, "Pointer  #";HIndex%
	PRINT #1, "   Flags  ";HEX$(PInfo.fPointer)
	PRINT #1, "   XHot   ";PInfo.xHotspot
	PRINT #1, "   YHot   ";PInfo.yHotspot
	PRINT #1, "   Handle ";HEX$(PInfo.hbmPointer)

	'** Set pointer to next in array
	HIndex% = (HIndex% + 1) MOD NumPointers
        Bool%   = WinSetPointer(HWNDDESKTOP, HPointers(HIndex%))

     CASE WMBUTTON2DOWN

	'** Make pointer invisible for 5 seconds
	Bool% = WinShowPointer(HWNDDESKTOP, 0)
	SLEEP 5
	Bool% = WinShowPointer(HWNDDESKTOP, 1)

     CASE WMPAINT    'Paint the window with background color & display pointers

        hps&  = WinBeginPaint(hwnd&, 0,_
                MakeLong(VARSEG(ClientRect), VARPTR(ClientRect)))
        bool% = WinFillRect(hps&,_
		MakeLong(VARSEG(ClientRect), VARPTR(ClientRect)),0)

	'** Calculate proportional spacing for pointers
        yDelta% = ClientRect.yTop   \ 12
	xDelta% = ClientRect.xRight \ (1 + (NumPointers \ 4))

	'** Display all pointers in all styles
	FOR i% = 0 TO NumPointers - 1	 'Pointer index
	   FOR DrawStyle% = 0 TO 2	 'Style:  Normal, Half-toned, Inverted
	      bool% = WinDrawPointer (hps&,_
                      xDelta% * (i% \ 4),_
                      yDelta% * ((DrawStyle% * 4) + (i% MOD 4)),_
                      HPointers(i%), DrawStyle%)
	   NEXT DrawStyle%
	NEXT i%

	bool% = WinEndPaint(hps&)
     CASE WMCLOSE

	'** Destroy all non-system pointers
	FOR i% = SPTRCPTR TO NumPointers -1
	   Bool% = WinDestroyPointer(HPointers(i%))
	NEXT i%

	'** Pass control back to default for rest of WMCLOSE
        ClientWndProc& = WinDefWindowProc(hwnd&, msg%, mp1&, mp2&)
     CASE ELSE        'Pass control to system for other messages
        ClientWndProc& = WinDefWindowProc(hwnd&, msg%, mp1&, mp2&)
     END SELECT
END FUNCTION
