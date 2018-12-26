'***********************************************************************
'* 
'* Program Name: GpiTrans.BAS
'*
'* Include File: GpiTrans.BI
'*
'* Functions   :
'*               GpiConvert
'*               GpiCallSegmentMatrix
'*               GpiQueryDefaultViewMatrix
'*               GpiQueryViewingTransformMatrix
'*               GpiQueryModelTransformMatrix
'*               GpiQuerySegmentTransformMatrix
'*               GpiQueryPageViewport
'*               GpiSetDefaultViewMatrix
'*               GpiSetViewingTransformMatrix
'*               GpiSetModelTransformMatrix
'*               GpiSetSegmentTransformMatrix
'*               GpiSetPageViewport
'*
'* Description : This program demonstrates the transformation matrix
'*               functions.  These functions allow a given coordinate
'*               space to display a drawing with a given rotation,
'*               scale, translation or shear.  This program illustrates
'*               rotation and scaling.  Virtually all calls are in the
'*               ClientWndProc and are triggered by keyboard or mouse
'*               input.
'*
'*               These calls are just example calls.  This program
'*               does not give a full discussion of coordinate spaces
'*               or transformation matrices.  For more information on
'*               these topics, see Chapter 31 of "OS/2 Programmer's
'*               Reference, Volume 1."
'***********************************************************************

'*********         Initialization section        ***********

REM $INCLUDE: 'PMBase.BI'
REM $INCLUDE: 'GpiTrans.BI'
REM $INCLUDE: 'GpiSeg.BI'         Needed to illustrate GpiSet/QuerySegmentTM
REM $INCLUDE: 'GpiCont.BI'        Needed for Create/DestroyPS
REM $INCLUDE: 'WinInput.BI'       Needed for messages
REM $INCLUDE: 'OS2Def.BI'         Needed for POINTL type
CONST  DROFILL	    =  1
DECLARE FUNCTION GpiMove%(BYVAL hps AS LONG, BYVAL pptl AS LONG)
DECLARE FUNCTION GpiFullArc%(BYVAL hps AS LONG,_
                             BYVAL flFlags AS LONG,_
                             BYVAL fxMult AS LONG)
DECLARE FUNCTION GpiSetColor%(BYVAL hps AS LONG, BYVAL clr AS LONG)
DECLARE FUNCTION WinOpenWindowDC&(BYVAL hwnd AS LONG)

CONST FirstSeg = 1
CONST LastSeg  = 10

'Global anchor block and presentation space
COMMON SHARED /Handles/ hab&, hps&

OPEN "GpiTrans.OUT" FOR OUTPUT AS #1

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
     DIM ClientRect AS RECTL
     DIM mtrx AS MATRIXLF
     ClientWndProc&=0
     SELECT CASE msg%
     CASE WMCREATE
	CALL SegmentSetup(hwnd&)
     CASE WMSIZE             'Size causes change in page viewport
        CALL BreakLong(mp2&, Yheight%, Xwidth%)
        bool% = GpiQueryPageViewport(hps&,_
                MakeLong(VARSEG(ClientRect), VARPTR(ClientRect)))

        PRINT #1, "PageViewport: ";
        PRINT #1, "(";ClientRect.xLeft;",";ClientRect.yBottom;")";" - ";
        PRINT #1, "(";ClientRect.xRight;",";ClientRect.yTop;")"

        'Set up new ViewPort (origin at center of window)
        deltaY% = Yheight% / 2
        deltaX% = Xwidth% / 2
        ClientRect.yBottom = deltaY%
        ClientRect.yTop    = Yheight%
        ClientRect.xLeft   = deltaX%
        ClientRect.xRight  = Xwidth%

        bool% = GpiSetPageViewport(hps&,_
                MakeLong(VARSEG(ClientRect), VARPTR(ClientRect)))

     CASE WMCHAR             'Key press causes scaling to be reset
        IF (mp1& AND KCKEYUP)=0 THEN
          bool% = GpiQueryDefaultViewMatrix(hps&, 9,_
                  MakeLong(VARSEG(mtrx), VARPTR(mtrx)))

          'Reset scaling
          mtrx.fxM11 = &H10000
          mtrx.fxM22 = &H10000

          bool% = GpiSetDefaultViewMatrix(hps&, 9,_
                  MakeLong(VARSEG(mtrx), VARPTR(mtrx)),_
                  TRANSFORMREPLACE)

          'Send WMPAINT to draw chain
          bool% = WinSendMsg(hwnd&, WMPAINT, 0, 0)
        END IF

     CASE WMBUTTON1DOWN            '1st Button rotates model transform matrix
        bool% = GpiQueryModelTransformMatrix(hps&, 9,_
                MakeLong(VARSEG(mtrx), VARPTR(mtrx)))

        'Set matrix for 10 degree rotation
        mtrx.fxM11 = &H10000 * COS(3.14/18)
        mtrx.fxM12 = &H10000 * -SIN(3.14/18)
        mtrx.fxM21 = &H10000 * SIN(3.14/18)
        mtrx.fxM22 = &H10000 * COS(3.14/18)

        bool% = GpiSetModelTransformMatrix(hps&, 9,_
                MakeLong(VARSEG(mtrx), VARPTR(mtrx)), TRANSFORMADD)

        'Call segment with large radius
        bool% = GpiErase (hps&)
        mtrx.fxM11 = &H10000 * 5
        mtrx.fxM12 = 0
        mtrx.fxM21 = 0
        mtrx.fxM22 = &H10000 * 5
        mtrx.lM33 = 1
        bool% = GpiCallSegmentMatrix(hps&,_
                LastSeg + 1, 9,_
                MakeLong(VARSEG(mtrx), VARPTR(mtrx)), TRANSFORMADD)

        'Convert points between coordinate spaces
        CALL ConvertPoints

        SLEEP 1

        'Send WMPAINT to draw chain
	bool% = WinSendMsg(hwnd&, WMPAINT, 0, 0)
        ClientWndProc& = WinDefWindowProc(hwnd&, msg%, mp1&, mp2&)

     CASE WMBUTTON2DOWN   '2nd Button changes scaling for default view matrix
        bool% = GpiQueryDefaultViewMatrix(hps&, 9,_
                MakeLong(VARSEG(mtrx), VARPTR(mtrx)))

        'Choose random scaling
        mtrx.fxM11 = &H10000 * 5 * RND
        mtrx.fxM22 = &H10000 * 5 * RND

        'Replace DVM
        bool% = GpiSetDefaultViewMatrix(hps&, 9,_
                MakeLong(VARSEG(mtrx), VARPTR(mtrx)), TRANSFORMREPLACE)

        'Send WMPAINT to draw chain
        bool% = WinSendMsg(hwnd&, WMPAINT, 0, 0)

     CASE WMPAINT     'Draw chain reflected twice with ViewingTM
        'Reflect ViewingTM through origin
        bool% = GpiQueryViewingTransformMatrix(hps&, 9,_
                MakeLong(VARSEG(mtrx), VARPTR(mtrx)))
        mtrx.fxM11 = -mtrx.fxM11
        mtrx.fxM22 = -mtrx.fxM22
        bool% = GpiSetViewingTransformMatrix(hps&, 9,_
                MakeLong(VARSEG(mtrx), VARPTR(mtrx)), TRANSFORMREPLACE)
        bool% = GpiErase    (hps&)
        bool% = GpiDrawChain(hps&)

        SLEEP 1

        'Reflect ViewingTM again through origin
        bool% = GpiQueryViewingTransformMatrix(hps&, 9,_
                MakeLong(VARSEG(mtrx), VARPTR(mtrx)))
        mtrx.fxM11 = -mtrx.fxM11
        mtrx.fxM22 = -mtrx.fxM22
        bool% = GpiSetViewingTransformMatrix(hps&, 9,_
                MakeLong(VARSEG(mtrx), VARPTR(mtrx)), TRANSFORMREPLACE)
        bool% = GpiErase    (hps&)
        bool% = GpiDrawChain(hps&)

        hps2& = WinBeginPaint(hwnd&,0,0)    ' WinBegin/EndPaint to
        bool% = WinEndPaint  (hps2&)        ' terminate WMPAINT message.

     CASE WMCLOSE
        bool% = GpiDeleteSegments        (hps&, FirstSeg, LastSeg)
        bool% = GpiDestroyPS             (hps&)
        ClientWndProc& = WinDefWindowProc(hwnd&, msg%, mp1&, mp2&)

     CASE ELSE        'Pass control to system for other messages
        ClientWndProc& = WinDefWindowProc(hwnd&, msg%, mp1&, mp2&)
     END SELECT
END FUNCTION

SUB SegmentSetup(hwnd&) STATIC

   'Get device context for window to use with GpiCreatePS
   hdcWin& = WinOpenWindowDC(hwnd&)

   'Define size of presentation space for GpiCreatePS
   DIM szl AS SIZEL
   szl.cx = 640 : szl.cy = 480

   'Create a presentation space because segments can not be
   'used with micro presentation spaces.
   hps& = GpiCreatePS(hab&, hdcWin&,_
          MakeLong(VARSEG(szl), VARPTR(szl)),_
          PUPELS OR GPIAASSOC)

   'Set drawing mode and initial attributes
   bool% = GpiSetDrawingMode (hps&, DMRETAIN)
   IF (ATTROFF  = GpiQueryInitialSegmentAttrs(hps&, ATTRCHAINED)) THEN
     bool%      = GpiSetInitialSegmentAttrs  (hps&, ATTRCHAINED, ATTRON)
   END IF

   'Make a segment to be copied into each new segment
   radius& = 25 * &H10000          'radius for GpiFullArc (fixed type in C)
   bool%   = GpiOpenSegment(hps&, LastSeg+1)
     bool% = GpiFullArc(hps&, DROFILL, radius&)
   bool%   = GpiCloseSegment(hps&)

   'Make this segment callable for GpiCallSegmentMatrix
   bool% = GpiSetSegmentAttrs(hps&, LastSeg+1, ATTRCHAINED, ATTROFF)

   'Copy commands from above segment into a buffer to be used with GpiPutData
   DIM Buffer AS STRING * 512
   NumBytes& = GpiGetData(hps&, LastSeg + 1,_
               MakeLong(VARSEG(Offset&), VARPTR(Offset&)),_
               DFORMNOCONV, 512,_
               MakeLong(VARSEG(Buffer),  VARPTR(Buffer)))

   'Set initial position for segments
   DIM ptl AS POINTL
   ptl.x = 10 : ptl.y = 10

   'Set up 10 segments (drawn diagonally)
   FOR s% = FirstSeg TO LastSeg
     bool% = GpiOpenSegment(hps&, s%)
     bool% = GpiSetColor   (hps&, s%)  'Change color to distinguish segments
     bool% = GpiMove       (hps&, MakeLong(VARSEG(ptl), VARPTR(ptl)))

     'Copy data from buffer (from original segment) to current segment
     PutBytes& = GpiPutData(hps&, DFORMNOCONV,_
                 MakeLong(VARSEG(NumBytes&), VARPTR(NumBytes&)),_
                 MakeLong(VARSEG(Buffer),    VARPTR(Buffer)))

     bool% = GpiCloseSegment(hps&)

     '***Rotate each segment 5*s% degrees
     DIM mtrx AS MATRIXLF
     bool% = GpiQuerySegmentTransformMatrix(hps&, s%, 9,_
             MakeLong(VARSEG(mtrx), VARPTR(mtrx)))
     Angle! = s% * 5 * 3.14/180
     mtrx.fxM11 = &H10000 * COS(Angle!)
     mtrx.fxM12 = &H10000 * -SIN(Angle!)
     mtrx.fxM21 = &H10000 * SIN(Angle!)
     mtrx.fxM22 = &H10000 * COS(Angle!)
     bool% = GpiSetSegmentTransformMatrix(hps&, s%, 9,_
             MakeLong(VARSEG(mtrx), VARPTR(mtrx)), TRANSFORMADD)

     ptl.x = ptl.x + 15 : ptl.y = ptl.y + 15   'Increment point position
   NEXT s%

   bool% = GpiSetDrawingMode (hps&, DMDRAW)  'Reset drawing mode
END SUB

'****
'** Convert points computes equivalent points in 4 coordinate spaces using
'** GpiConvert.  Points are written to GpiTrans.OUT in PrintPoints.

SUB ConvertPoints
  DIM ptls(3) AS POINTL
  ptls(0).x = 10
  ptls(0).y = 10
  ptls(1).x = 20
  ptls(1).y = 10
  ptls(2).x = 10
  ptls(2).y = 20
  ptls(3).x = 20
  ptls(3).y = 20
  CALL PrintPoints("Default:",ptls())

  'Default -> Model
  bool% = GpiConvert(hps&, CVTCDEFAULTPAGE, CVTCMODEL, 4,_
          MakeLong(VARSEG(ptls(0)), VARPTR(ptls(0))))
  CALL    PrintPoints("Model:",ptls())

  'Model -> Page
  bool% = GpiConvert(hps&, CVTCMODEL, CVTCPAGE, 4,_
          MakeLong(VARSEG(ptls(0)), VARPTR(ptls(0))))
  CALL PrintPoints("Page:",ptls())

  'Page -> World
  bool% = GpiConvert(hps&, CVTCPAGE, CVTCWORLD, 4,_
          MakeLong(VARSEG(ptls(0)), VARPTR(ptls(0))))
  CALL PrintPoints("World:",ptls())

  PRINT #1,
END SUB

SUB PrintPoints(coord$, ptls() AS POINTL)
  PRINT #1, coord$,
  FOR i% = 0 TO 3
    PRINT #1, "(";
    PRINT #1, ptls(i%).x;
    PRINT #1, ",";
    PRINT #1, ptls(i%).y;
    PRINT #1, ")",
  NEXT
  PRINT #1,
END SUB
