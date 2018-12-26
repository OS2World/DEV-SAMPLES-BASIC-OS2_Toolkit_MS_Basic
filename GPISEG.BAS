'***********************************************************
'* 
'* Program Name: GpiSeg.BAS
'*
'* Include File: GpiSeg.BI
'*
'* Functions   :
'*               GpiOpenSegment
'*               GpiCloseSegment
'*               GpiDrawSegment
'*               GpiDeleteSegment
'*               GpiDeleteSegments
'*               GpiQuerySegmentNames
'*               GpiSetInitialSegmentAttrs
'*               GpiQueryInitialSegmentAttrs
'*               GpiSetSegmentAttrs
'*               GpiQuerySegmentAttrs
'*               GpiSetSegmentPriority
'*               GpiQuerySegmentPriority
'*               GpiDrawChain
'*               GpiDrawDynamics
'*               GpiRemoveDynamics
'*               GpiGetData
'*               GpiPutData
'*               GpiComment         GpiComment is not demonstrated
'*                                  because it has no purpose.
'*
'* Description : This program demonstrates the segment functions.
'*               These functions allow graphics statements to be
'*               stored in RAM to then be displayed. These can be
'*               displayed alone (GpiDrawSegment), dynamically
'*               (GpiDrawDynamics), in groups (GpiDrawFrom),
'*               or in entire chains (GpiDrawChain).
'*
'*               Using segments requires creating a presentation
'*               space (WinCreatePS) and associating it with the
'*               appropriate device context (WinOpenWindowDC).
'*
'*               GpiComment is not demonstrated because it seems
'*               to have no purpose. It allows you to place a
'*               comment on a segment, but there is no way to
'*               retrieve that comment.
'***********************************************************

'*********         Initialization section        ***********

REM $INCLUDE: 'PMBase.BI'
REM $INCLUDE: 'GpiSeg.BI'
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
             MakeLong (VARSEG(flFrameFlags&),  VARPTR(flFrameFlags&)),_
             MakeLong (VARSEG(szClientClass$), SADD(szClientClass$)),_
             0,_
             0,_
             0,_
             0,_
             MakeLong (VARSEG(hwndClient&), VARPTR(hwndClient&)))

'**************         Message loop         ***************

WHILE WinGetMsg(hab&, MakeLong(VARSEG(aqmsg), VARPTR(aqmsg)), 0, 0, 0)
  bool% = WinDispatchMsg(hab&, MakeLong(VARSEG(aqmsg), VARPTR(aqmsg)))
WEND

'***********         Finalize section        ***************

bool% = WinDestroyWindow   (hwndFrame&)
bool% = WinDestroyMsgQueue (hmq&)
bool% = WinTerminate       (hab&)

END

'***********         Window procedure        ***************

FUNCTION ClientWndProc& (hwnd&, msg%, mp1&, mp2&) STATIC
     DIM ClientRect AS RECTL
     ClientWndProc&=0
     SELECT CASE msg%
     CASE WMCREATE
	CALL SegmentSetup(hwnd&)
        NumSegs% = LastSeg       'Initial number of segments is max seg value
     CASE WMCHAR             'Key press causes second segment to be dynamic
        IF (mp1& AND KCKEYUP)=0 THEN

          'Set attribute if not already
          IF ATTROFF=GpiQuerySegmentAttrs(hps&, FirstSeg+1, ATTRDYNAMIC) THEN
            bool%   =GpiSetSegmentAttrs  (hps&, FirstSeg+1, ATTRDYNAMIC, ATTRON)
          END IF

          'draw dynamic segment
	  bool% = GpiDrawDynamics(hps&)
          SLEEP 1

          'Remove and reset dynamic segment
          bool% = GpiRemoveDynamics (hps&, FirstSeg,   LastSeg)
          bool% = GpiSetSegmentAttrs(hps&, FirstSeg+1, ATTRDYNAMIC, ATTROFF)

	END IF
     CASE WMBUTTON1DOWN            '1st Button deletes middle segment
        DIM SegNames&(NumSegs% - 1)     'Array for valid segment names

        'Fill array with valid segments
        retNum&  = GpiQuerySegmentNames (hps&,_
                   FirstSeg, LastSeg, NumSegs%,_
                   MakeLong(VARSEG(SegNames&(0)), VARPTR(SegNames&(0))))
        Deleted% = NumSegs% \ 2       'Select segment to delete

        'Draw segment to be deleted
        bool% = GpiErase      (hps&)
	bool% = GpiDrawSegment(hps&, SegNames&(Deleted%))
	SLEEP 1

        'Draw lower part of chain
        bool% = GpiErase   (hps&)
	bool% = GpiDrawFrom(hps&, FirstSeg, SegNames&(Deleted%-1))
	SLEEP 1

        'Draw upper part of chain
        bool% = GpiErase   (hps&)
	bool% = GpiDrawFrom(hps&, SegNames&(Deleted%+1), LastSeg)
	SLEEP 1

        'Delete segment and decrement number of segments
        bool%    = GpiDeleteSegment(hps&, SegNames&(Deleted%))
	NumSegs% = NumSegs% - 1
        ERASE SegNames&         'Erase array so it can be reallocated

        'Send WMPAINT to draw full chain
        bool% = WinSendMsg(hwnd&, WMPAINT, 0, 0)

     CASE WMBUTTON2DOWN        '2nd Button changes priority of first segment

        'Get next higher and lower priority segments (only 1 call will succeed)
	Higher& = GpiQuerySegmentPriority(hps&, FirstSeg, HIGHERPRI)
        Lower&  = GpiQuerySegmentPriority(hps&, FirstSeg, LOWERPRI)

        'Trade priorities with successful segment
	IF Higher& = FirstSeg+1 THEN
          bool%    = GpiSetSegmentPriority(hps&, FirstSeg, Higher&, HIGHERPRI)
	ELSE
          bool%    = GpiSetSegmentPriority(hps&, FirstSeg, Lower&, LOWERPRI)
        END IF

        'Send WMPAINT to draw chain
	bool% = WinSendMsg(hwnd&, WMPAINT, 0, 0)
     CASE WMPAINT     'Erase the window and draw chain

        'Draw current chain
        bool% = GpiErase     (hps&)
        bool% = GpiDrawChain (hps&)

        hps2& = WinBeginPaint(hwnd&,0,0)    ' WinBegin/EndPaint to
        bool% = WinEndPaint  (hps2&)        ' terminate WMPAINT message.

     CASE WMCLOSE
	bool% = GpiDeleteSegments(hps&, FirstSeg, LastSeg)
        bool% = GpiDestroyPS     (hps&)
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

   'Set drawing mode and initial segment attributes
   bool%       = GpiSetDrawingMode (hps&, DMRETAIN)
   IF (ATTROFF = GpiQueryInitialSegmentAttrs(hps&, ATTRCHAINED)) THEN
     bool%     = GpiSetInitialSegmentAttrs  (hps&, ATTRCHAINED, ATTRON)
   END IF

   'Make a segment to be copied into each new segment
   radius& = 25 * &H10000          'radius for GpiFullArc (fixed type in C)
   bool%   = GpiOpenSegment (hps&, LastSeg+1)
     bool% = GpiFullArc     (hps&, DROFILL, radius&)
   bool%   = GpiCloseSegment(hps&)

   'Copy commands from above segment into a buffer to be used with GpiPutData
   DIM Buffer AS STRING * 512
   NumBytes& = GpiGetData(hps&, LastSeg + 1,_
               MakeLong(VARSEG(Offset&), VARPTR(Offset&)),_
               DFORMNOCONV, 512,_
               MakeLong(VARSEG(Buffer),  VARPTR(Buffer)))

   'Set initial position for segments
   DIM ptl AS POINTL
   ptl.x = 30 : ptl.y = 30

   'Set up 10 segments (drawn diagonally)
   FOR s% = FirstSeg TO LastSeg
     bool% = GpiOpenSegment(hps&, s%)
     bool% = GpiSetColor   (hps&, s%)   'Change color to distinguish segments
     bool% = GpiMove       (hps&, MakeLong(VARSEG(ptl), VARPTR(ptl)))

     'Copy data from buffer (from original segment) to current segment
     PutBytes& = GpiPutData(hps&, DFORMNOCONV,_
                 MakeLong(VARSEG(NumBytes&), VARPTR(NumBytes&)),_
                 MakeLong(VARSEG(Buffer),    VARPTR(Buffer)))

     bool% = GpiCloseSegment(hps&)
     ptl.x = ptl.x + 20 : ptl.y = ptl.y + 20   'Increment point position
   NEXT s%

   bool% = GpiDeleteSegment  (hps&, LastSeg+1) 'Remove initial segment
   bool% = GpiSetDrawingMode (hps&, DMDRAW)    'Reset drawing mode
END SUB
