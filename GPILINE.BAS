'***********************************************************
'*
'* Program Name: GpiLine.BAS
'*
'* Include File: GpiLine.BI
'*
'* Functions   : GpiBox
'*               GpiMove
'*               Gpiline
'*               GpiPolyLine
'*               GpiSetLineType
'*               GpiQueryLineType
'*               GpiSetLineWidth    (Set/QueryLineWidth not shown
'*               GpiQueryLineWidth   because they are not implemented
'*                                   in OS/2 Version 1.10)
'*               GpiPtVisible
'*               GpiRectVisible
'*               GpiSetCurrentPosition
'*               GpiQueryCurrentPosition
'*
'*  << The remaining routines contained in the GpiLine.BI >>
'*  << are demonstrated in GpiPath.BAS                    >>
'*
'* Description : This programs demonstrates the Drawing
'*               routines contained in GpiLine.BI.  Some
'*               routines do not have a visual effect so
'*               return values from these CALLs are written
'*               out to the file "GpiLine.OUT".
'*
'*               rouines demonstrated are contained in the
'*               SUBprogram ScreenPaint which is called from
'*               ClientWinProc when a WMPAINT message is received.
'***********************************************************

'*********         Initialization section        ***********

REM $INCLUDE: 'OS2Def.BI'
REM $INCLUDE: 'PMBase.BI'
REM $INCLUDE: 'WinMan1.BI'
REM $INCLUDE: 'GpiCont.BI'
REM $INCLUDE: 'GpiArea.BI'
REM $INCLUDE: 'GpiLine.BI'

DECLARE SUB ScreenPaint(hwnd&)

DIM aqmsg AS QMSG
DIM SHARED ClientRect AS RECTL

OPEN "GpiLine.OUT" FOR OUTPUT AS #1

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

FUNCTION ClientWndProc& (hwnd&, msg%, mp1&, mp2&)
  ClientWndProc& = 0
  SELECT CASE msg%
    CASE WMPAINT
      '**** WinInvalidateRect ensures entire window is repainted ****
      bool% = WinInvalidateRect(hwnd&, 0, 0)
      CALL ScreenPaint(hwnd&)
    CASE ELSE
      ClientWndProc& = WinDefWindowProc(hwnd&, msg%, mp1&, mp2&)
  END SELECT
END FUNCTION

'*
'* SUBprogram ScreenPaint:  Called from ClientWndProc& when a WMPAINT
'*                          message is received.
'*
SUB ScreenPaint(hwnd&)
DIM ppnt AS POINTL, appnt(3) AS POINTL, rect AS RECTL
  hps&  = WinBeginPaint (hwnd&, 0,_
          MakeLong(VARSEG(ClientRect), VARPTR(ClientRect)))
  bool% = GpiErase      (hps&)
'*
'* Check if a POINT (100,100) and the RECTANGLE (0,0)-(100,100) are
'* visible (within the client area).
'*
    ppnt.x = 100
    ppnt.y = 100
    IF GpiPtVisible(hps&,_
                    MakeLong(VARSEG(ppnt), VARPTR(ppnt))) = PVISVISIBLE THEN
      PRINT #1,"Point 100,100 is VISIBLE"
    ELSE
      PRINT #1,"Point 100,100 is INVISIBLE"
    END IF

    rect.xLeft   = 0
    rect.yBottom = 0
    rect.xRight  = 100
    rect.yTop    = 100
    SELECT CASE GpiRectVisible(hps&,_
                               MakeLong(VARSEG(rect), VARPTR(rect)))
      CASE RVISINVISIBLE
	PRINT #1,"Rectangle is INVISIBLE"
      CASE RVISVISIBLE
	PRINT #1,"Rectangle is VISIBLE"
      CASE RVISPARTIAL
	PRINT #1,"Rectangle is PARTIALLY VISIBLE"
      CASE ELSE
	PRINT #1,"GpiRectVisible ERROR"
    END SELECT
'*
'* Set then Query the current pixel position
'*
   ppnt.x = 100
   ppnt.y = 100
   bool% = GpiSetCurrentPosition   (hps&,_
           MakeLong(VArSEG(ppnt), VARPTR(ppnt)))
   bool% = GpiQueryCurrentPosition (hps&,_
           MakeLong(VARSEG(ppnt), VARPTR(ppnt)))
   PRINT #1,"Current postion is (";ppnt.x;",";ppnt.y;")"
'*
'*
'* The following FOR NEXT loop, fills the Client window with
'* horizontal lines of varying Line types.  Query Line Type and
'* write Line type to file.
'*
  FOR I% = 0 TO ClientRect.yTop STEP 3
    bool% = GpiSetLineType(hps&, linetype%)
    PRINT #1,"GpiQueryLineType = "; GpiQueryLineType(hps&)

    linetype% = linetype% + 1
    IF linetype% = 10 THEN linetype% = 0
    ppnt.x = 0
    ppnt.y = I%
    bool%  = GpiMove(hps&, MakeLong(VARSEG(ppnt), VARPTR(ppnt)))
    ppnt.x = ClientRect.xRight
    along& = GpiLine(hps&, MakeLong(VARSEG(ppnt), VARPTR(ppnt)))
  NEXT
'*
'* Initializes ppnt TYPE with lower left and upper right corners
'* of box to be drawn.  Uses Client window coordinates so box is always
'* drawn proportional to Client window
'*
  ppnt.x = ClientRect.xRight \ 8
  ppnt.y = ClientRect.yTop \ 8
  bool%  = GpiMove(hps&, MakeLong(VARSEG(ppnt), VARPTR(ppnt)))
  ppnt.x = 7 * ppnt.x
  ppnt.y = 7 * ppnt.y
'*
'* Sets fill pattern and draws box
'*
  bool%  = GpiSetPattern(hps&, PATSYMHALFTONE)
  along& = GpiBox       (hps&, DROOUTLINEFILL,_
	   MakeLong(VARSEG(ppnt), VARPTR(ppnt)), 0, 0)
'*
'* Sets patten and marks beginning of area to be filled when the
'* GpiEndArea is executed
'*
  bool% = GpiSetPattern(hps&, PATSYMSOLID)
  bool% = GpiBeginArea (hps&,(BAALTERNATE OR BABOUNDARY))
'*
'* Initializes array with points that define polygon to be draw
'* points are calculated using the current Client window coordinates
'* so that the polygon is always draw proportional to the Client window
'*
  appnt(0).x = (ClientRect.xRight \ 8)*2 : appnt(0).y = ClientRect.yTop \ 2
  appnt(1).x = ClientRect.xRight \ 2     : appnt(1).y = (ClientRect.yTop \ 8)*6
  appnt(2).x = (ClientRect.xRight \ 8)*6 : appnt(2).y = ClientRect.yTop \ 2
  appnt(3).x = ClientRect.xRight \ 2     : appnt(3).y = (ClientRect.yTop \ 8)*2
'*
'* Moves to first point of polygon then draws polygon
'*
  retn% = GpiMove    (hps&,    MakeLong(VARSEG(appnt(0)), VARPTR(appnt(0))))
  retn% = GpiPolyLine(hps&, 3, MakeLong(VARSEG(appnt(1)), VARPTR(appnt(1))))
'*
'* Marks end of Area and fills polygon with current pattern and color
'*
  retn% = GpiEndArea (hps&)
  retn% = WinEndPaint(hps&)

END SUB
