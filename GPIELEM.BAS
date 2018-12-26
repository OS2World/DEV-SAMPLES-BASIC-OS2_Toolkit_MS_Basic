'*******************************************************************
'* 
'* Program Name: GpiElem.BAS
'*
'* Include File: GpiElem.BI
'*
'* Functions   :
'*               GpiBeginElement
'*               GpiEndElement
'*               GpiLabel
'*               GpiElement
'*               GpiQueryElement
'*               GpiDeleteElement
'*               GpiDeleteElementRange
'*               GpiDeleteElementsBetweenLabels
'*               GpiQueryEditMode
'*               GpiSetEditMode
'*               GpiQueryElementPointer
'*               GpiSetElementPointer
'*               GpiOffsetElementPointer
'*               GpiQueryElementType
'*               GpiSetElementPointerAtLabel
'*
'* Description : This program demonstrates the element functions.
'*               These functions allow graphics statements to be
'*               stored in RAM to then be displayed. Most element
'*               functions must be used in segments. Segments also
'*               retain graphics; the difference is that elements
'*               are subsets of segments.
'*
'*               All calls are demonstrated in SUBs after
'*               the ClientWndProc. These SUBs are called when
'*               a mouse or keyboard message is received.
'*               QueryElements writes element info to GpiElem.OUT.
'******************************************************************

'*********         Initialization section        ***********

REM $INCLUDE: 'PMBase.BI'
REM $INCLUDE: 'OS2Def.BI'
REM $INCLUDE: 'GpiElem.BI'
REM $INCLUDE: 'GpiSeg.BI'
REM $INCLUDE: 'GpiCont.BI'        Needed for Create/DestroyPS
REM $INCLUDE: 'WinInput.BI'       Needed for messages
CONST OCODEGCLINE   = &H81      ' polyline at current posn (from PMOrd.BI)
CONST  DROFILL	    =  1
DECLARE FUNCTION GpiMove%(BYVAL hps AS LONG, BYVAL pptl AS LONG)
DECLARE FUNCTION GpiFullArc%(BYVAL hps AS LONG,_
                             BYVAL flFlags AS LONG,_
                             BYVAL fxMult AS LONG)
DECLARE FUNCTION GpiLine%(BYVAL hps AS LONG, BYVAL pptl AS LONG)
DECLARE FUNCTION GpiSetColor%(BYVAL hps AS LONG, BYVAL clr AS LONG)
DECLARE FUNCTION WinOpenWindowDC&(BYVAL hwnd AS LONG)

'Global anchor block and presentation space
COMMON SHARED /Handles/ hab&, hps&
COMMON SHARED /Values/ CurrElem%, LastElem%

DIM aqmsg AS QMSG

OPEN "GpiElem.OUT" FOR OUTPUT AS #1
RANDOMIZE TIMER

flFrameFlags& =  FCFTITLEBAR      OR FCFSYSMENU OR _
                 FCFSIZEBORDER    OR FCFMINMAX  OR _
                 FCFSHELLPOSITION OR FCFTASKLIST

szClientClass$ = "ClassName" + CHR$(0)

hab&  = WinInitialize(0)
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

bool% = WinDestroyWindow  (hwndFrame&)
bool% = WinDestroyMsgQueue(hmq&)
bool% = WinTerminate      (hab&)

CLOSE #1
END

'***********         Window procedure        ***************

FUNCTION ClientWndProc& (hwnd&, msg%, mp1&, mp2&) STATIC
     DIM ClientRect AS RECTL
     ClientWndProc& = 0
     SELECT CASE msg%
     CASE WMCREATE
        CALL ElementSetup(hwnd&)
     CASE WMCHAR             'Key press Deletes CurrElem%
        IF (mp1& AND KCKEYUP)=0 THEN
           CALL DeleteOne

           'Send WMPAINT to draw segment
           bool% = WinSendMsg(hwnd&, WMPAINT, 0, 0)
	END IF
     CASE WMBUTTON1DOWN            '1st Button adds a random line at CurrElem%
        CALL AddElement
        ClientWndProc& = WinDefWindowProc(hwnd&, msg%, mp1&, mp2&)

        'Send WMPAINT to draw segment
        bool% = WinSendMsg(hwnd&, WMPAINT, 0, 0)
     CASE WMBUTTON2DOWN        '2nd Button deletes between CurrElem and CE+1
        CALL DeleteCurrentElements

        'Send WMPAINT to draw segment
        bool% = WinSendMsg(hwnd&, WMPAINT, 0, 0)
     CASE WMPAINT     'Draw the segment

        'Draw the segment
        bool% = GpiErase      (hps&)
        bool% = GpiDrawSegment(hps&, 1)

        hps2& = WinBeginPaint (hwnd&,0,0)    ' WinBegin/EndPaint to
        bool% = WinEndPaint   (hps2&)        ' terminate WMPAINT message.

     CASE WMCLOSE        'Delete all remaining elements, segment and PS
        CALL DeleteAll
        bool% = GpiDeleteSegment(hps&, 1)
        bool% = GpiDestroyPS    (hps&)
        ClientWndProc& = WinDefWindowProc(hwnd&, msg%, mp1&, mp2&)
     CASE ELSE        'Pass control to system for other messages
        ClientWndProc& = WinDefWindowProc(hwnd&, msg%, mp1&, mp2&)
     END SELECT
END FUNCTION

'****
'** ElementSetup creates a device context and a presentation space,
'** then defines a segment containing 5 sets of 5 elements each.
'** Each set of elements contains the following:
'**      1. Label
'**      2. Color
'**      3. Move
'**      4. Circle
'**      5. Line
SUB ElementSetup(hwnd&) STATIC

   'Get device context for window to use with GpiCreatePS
   hdcWin& = WinOpenWindowDC(hwnd&)

   'Define size of presentation space for GpiCreatePS
   DIM szl AS SIZEL
   szl.cx = 640
   szl.cy = 480

   'Create a presentation space because segments can not be
   'used with micro presentation spaces.
   hps& = GpiCreatePS(hab&, hdcWin&,_
          MakeLong(VARSEG(szl), VARPTR(szl)),_
          PUPELS OR GPIAASSOC)

   'Set drawing mode
   bool% = GpiSetDrawingMode (hps&, DMRETAIN)

   'Setup up string for GpiElement. Uses order from PMOrd.BI.
   DIM GraphicString AS STRING * 10
   GraphicString = CHR$(OCODEGCLINE) + CHR$(8) + CHR$(0) + CHR$(0) + _
                   CHR$(0) + CHR$(0) + CHR$(200) + CHR$(0) + CHR$(0) + CHR$(0)

   'radius for GpiFullArc (fixed type in C)
   radius& = 25 * &H10000

   'Set initial position for elements
   DIM ptl AS POINTL
   ptl.x = 30
   ptl.y = 30

   bool% = GpiOpenSegment(hps&, 1)

'** Each set of elements contains the following:
'**      1. Label
'**      2. Color
'**      3. Move
'**      4. Circle
'**      5. Line
     FOR e% = 1 TO 5

'**      1. Label
       bool% = GpiLabel(hps&, e%)

'**      2. Color
       type1$ = "First" + STR$(e%) + CHR$(0)
       bool%    = GpiBeginElement(hps&, e% * 4 - 3,_
                  MakeLong(VARSEG(type1$), SADD(type1$)))
          bool% = GpiSetColor    (hps&, e%)  'Set color to distinguish elements
       bool%    = GpiEndElement  (hps&)

'**      3. Move
       type2$   = "Second" + STR$(e%) + CHR$(0)
       bool%    = GpiBeginElement (hps&, e% * 4 - 2,_
                  MakeLong(VARSEG(type2$), SADD(type2$)))
          bool% = GpiMove       (hps&, MakeLong(VARSEG(ptl), VARPTR(ptl)))
       bool%    = GpiEndElement   (hps&)

'**      4. Circle
       type3$   = "Third" + STR$(e%) + CHR$(0)
       bool%    = GpiBeginElement (hps&, e% * 4 - 1,_
                  MakeLong(VARSEG(type3$), SADD(type3$)))
          bool% = GpiFullArc    (hps&, DROFILL, radius&)
       bool%    = GpiEndElement   (hps&)

'**      5. Line
       type4$   = "Fourth" + STR$(e%) + CHR$(0)
       pmerr&   = GpiElement(hps&, e% * 4,_
                  MakeLong(VARSEG(type4$),        SADD(type4$)), 10,_
                  MakeLong(VARSEG(GraphicString), VARPTR(GraphicString)))

       ptl.x = ptl.x + 20 : ptl.y = ptl.y + 20   'Increment point position
     NEXT e%
   bool% = GpiCloseSegment(hps&)

   'Set globals for adding/deleting elements
   CurrElem% = 1
   LastElem% = 20

   bool% = GpiSetDrawingMode (hps&, DMDRAW)  'Reset drawing mode
END SUB

'****
'** AddElement adds a random line at the CurrElem label.  This is
'** called when a WMBUTTON1DOWN message occurs.
SUB AddElement
   DIM ptl AS POINTL
   bool% = GpiSetDrawingMode (hps&, DMRETAIN)  'Reset drawing mode
   bool% = GpiOpenSegment    (hps&, 1)

     'Set mode to Insert if not already
     IF GpiQueryEditMode (hps&) <> SEGEMINSERT THEN
       bool% = GpiSetEditMode (hps&, SEGEMINSERT)
     END IF

     'Set pointer
     bool% = GpiSetElementPointer        (hps&, 0)
     bool% = GpiSetElementPointerAtLabel (hps&, CurrElem%)
     bool% = GpiOffsetElementPointer     (hps&, 1)

     'Define Element
     LastElem% = LastElem% + 1
     typeNew$  = "New " + STR$(LastElem%) + CHR$(0)
     ptl.x = 300 * RND
     ptl.y = 300 * RND
     bool%   = GpiBeginElement (hps&, LastElem%,_
               MakeLong(VARSEG(typeNew$), SADD(typeNew$)))
       bool% = GpiLine         (hps&, MakeLong(VARSEG(ptl), VARPTR(ptl)))
     bool%   = GpiEndElement   (hps&)

   bool% = GpiCloseSegment   (hps&)
   bool% = GpiSetDrawingMode (hps&, DMDRAW)  'Reset drawing mode
   PRINT #1, "After AddElement"
   CALL QueryElements              'Query and print elements
END SUB

'****
'** DeleteOne deletes the current element and decrements LastElem.
'** This is caused by a WMCHAR message.
SUB DeleteOne
   bool% = GpiSetDrawingMode (hps&, DMRETAIN)  'Reset drawing mode
   bool% = GpiOpenSegment    (hps&, 1)

     'Set pointer
     bool% = GpiSetElementPointer        (hps&,0)
     bool% = GpiSetElementPointerAtLabel (hps&, CurrElem%)
     bool% = GpiOffsetElementPointer     (hps&, 2)

     'Delete and decrement
     bool% = GpiDeleteElement(hps&)
     LastElem% = LastElem% - 1

   bool% = GpiCloseSegment   (hps&)
   bool% = GpiSetDrawingMode (hps&, DMDRAW)  'Reset drawing mode
   PRINT #1, "After DeleteOne"
END SUB

'****
'** DeleteCurrentElements deletes between the current label and the
'** next label and increments the CurrElem.  This is caused by a
'** WMBUTTON2DOWN message.
SUB DeleteCurrentElements
   bool% = GpiSetDrawingMode (hps&, DMRETAIN)  'Reset drawing mode
   bool% = GpiOpenSegment    (hps&, 1)
     bool% = GpiDeleteElementsBetweenLabels(hps&, CurrElem%, CurrElem% + 1)
     CurrElem% = CurrElem% + 1
   bool% = GpiCloseSegment   (hps&)
   bool% = GpiSetDrawingMode (hps&, DMDRAW)  'Reset drawing mode
   PRINT #1, "After DeleteCurrentElements"
   CALL QueryElements              'Query and print elements
END SUB

'****
'** DeleteAll deletes all remaining segments (assuming there are fewer
'** than 1000 elements.  This is called on a WMCLOSE.
SUB DeleteAll
   bool% = GpiSetDrawingMode      (hps&, DMRETAIN)  'Set drawing mode
   bool% = GpiOpenSegment         (hps&, 1)
     bool% = GpiDeleteElementRange(hps&, 0, 1000)
   bool% = GpiCloseSegment        (hps&)
   bool% = GpiSetDrawingMode      (hps&, DMDRAW)    'Reset drawing mode
   PRINT #1, "After DeleteAll"
   CALL QueryElements              'Query and print elements
END SUB

'****
'** QueryElements queries the element info and prints it out to
'** GpiElem.OUT.  This is called by AddElement, DeleteCurrentSegments,
'** and DeleteAll.
SUB QueryElements
   DIM Buffer AS STRING * 512, EName AS STRING * 32
   bool% = GpiSetDrawingMode (hps&, DMRETAIN)  'Set drawing mode
   bool% = GpiOpenSegment    (hps&, 1)

     'Set pointer at the beginning of segment
     bool% = GpiSetElementPointer (hps&, 0)

     'Initialize element pointer (-1)
     ep& = -1

     'Query elements until same element comes up twice.
     'NOTE: Querying after the last element does not return an error.
     DO UNTIL oldep& = ep&

       'Set old and query new element
       oldep& = ep&
       ep& = GpiQueryElementPointer (hps&)

       'Query name and type
       bytes& = GpiQueryElementType (hps&,_
                MakeLong(VARSEG(lType&), VARPTR(lType&)), 32,_
                MakeLong(VARSEG(EName), VARPTR(EName)))

       'Query element data
       bytes& = GpiQueryElement (hps&, 0, 512,_
                MakeLong(VARSEG(Buffer), VARPTR(Buffer)))

       'Write element info
       PRINT #1, "Element #";ep&
       PRINT #1, "   Type:",lType&
       PRINT #1, "   Name:",RTRIM$(EName)
       PRINT #1, "   Data:";

       'Loop through element data
       FOR i% = 1 TO bytes&
         b$ = HEX$(ASC(MID$(Buffer,i%,1)))
         IF LEN(b$)=1 THEN PRINT #1, " ";
         PRINT #1, b$; "  ";
         IF i% MOD 12 = 0 THEN PRINT #1,
       NEXT i%
       PRINT #1,

       'Increment element pointer
       bool% = GpiOffsetElementPointer(hps&, 1)
     LOOP
   bool% = GpiCloseSegment   (hps&)
   bool% = GpiSetDrawingMode (hps&, DMDRAW)  'Reset drawing mode
END SUB
