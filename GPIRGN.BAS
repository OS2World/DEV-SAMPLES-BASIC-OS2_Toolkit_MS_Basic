'***********************************************************
'*
'* Program Name:  GpiRgn.BAS
'*
'* Include File:  GpiRgn.BI
'*
'* Functions   :  GpiCreateRegion
'*                GpiSetRegion
'*                GpiDestroyRegion
'*                GpiCombineRegion&
'*                GpiEqualRegion
'*                GpiOffsetRegion
'*                GpiPtInRegion&
'*                GpiRectInRegion
'*                GpiQueryRegionBox
'*                GpiQueryRegionRects
'*                GpiIntersectClipRectangle
'*                GpiPaintRegion
'*                GpiSetClipRegion
'*                GpiExcludeClipRectangle
'*                GpiOffsetClipRegion
'*                GpiQueryClipRegion&
'*                GpiQueryClipBox
'*
'* Description :  This program demonstrates the region functions
'*                contained in "GpiRgn.BI".  It stores the results
'*                of the functions in the data file "GpiRgn.OUT".
'***********************************************************

'*********         Initialization section        ***********

REM $INCLUDE: 'PMBase.BI'
REM $INCLUDE: 'GpiRgn.BI'
REM $INCLUDE: 'OS2Def.BI'         Needed for POINTL type
REM $INCLUDE: 'WinRect.BI'        Needed for rectangle functions
REM $INCLUDE: 'GpiColor.BI'       Needed for set colors to distinguish regions
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
        CSSIZEREDRAW,_
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

END

'***********         Window procedure        ***************

FUNCTION ClientWndProc& (hwnd&, msg%, mp1&, mp2&) STATIC
     DIM ClientRect AS RECTL
     ClientWndProc&=0
     SELECT CASE msg%
     CASE WMPAINT     'Paint the window and perform region functions
        hps&  = WinBeginPaint(hwnd&, 0,_
                MakeLong(VARSEG(ClientRect), VARPTR(ClientRect)))
        bool% = WinFillRect(hps&,_
		MakeLong(VARSEG(ClientRect), VARPTR(ClientRect)),0)
        CALL    GpiRegion (hps&)
	bool% = WinEndPaint(hps&)
     CASE ELSE        'Pass control to system for other messages
        ClientWndProc& = WinDefWindowProc(hwnd&, msg%, mp1&, mp2&)
     END SELECT
END FUNCTION

'Data for initialization of regions
DATA 137,115,177,165
DATA 337,115,377,165
DATA 232,220,272,270
DATA 232,20,272,70
DATA 157,40,357,240
DATA 20,270,60,290
DATA 430,0,475,20

'***************************************************************
'** GpiRegion demonstrates each of the Region calls.  The first
'** section creates several regions and paints them.  The rest
'** of the section writes out info from the other miscellaneous
'** region functions to "GpiRgn.OUT".
'***************************************************************
SUB GpiRegion (hps&)
	DIM RectsForRgn(3) AS RECTL
        DIM RectsRgn1(2)   AS RECTL
        DIM RectsBound     AS RECTL
        DIM RectsInRgn     AS RECTL
        DIM RgnOffset      AS POINTL
        DIM RGNPoint       AS POINTL
        DIM RGNRectangle   AS RGNRECT
	RESTORE
	FOR i% = 0 TO 3
	   READ RectsForRgn(i%).xLeft
	   READ RectsForRgn(i%).yBottom
	   READ RectsForRgn(i%).xRight
	   READ RectsForRgn(i%).yTop
	NEXT i%
	FOR I% = 0 TO 2
           READ RectsRgn1(i%).xLeft
           READ RectsRgn1(i%).yBottom
           READ RectsRgn1(i%).xRight
           READ RectsRgn1(i%).yTop
        NEXT I%

        hrgnsc& = GpiCreateRegion (hps&, 4,_
                  MakeLong(VARSEG(RectsForRgn(0)), VARPTR(RectsForRgn(0))))
        bool%   = GpiSetColor     (hps&, CLRDARKGREEN)
        bool%   = GpiPaintRegion  (hps&, hrgnsc&)
        SLEEP 1

        bool%   = GpiSetRegion   (hps&, hrgnsc&, 2,_
                  MakeLong(VARSEG(RectsForRgn(0)), VARPTR(RectsForRgn(0))))
        bool%   = GpiSetColor    (hps&, CLRDARKBLUE)
        bool%   = GpiPaintRegion (hps&, hrgnsc&)
        SLEEP 1

        hrgnds& = GpiCreateRegion (hps&, 3,_
                  MakeLong(VARSEG(RectsRgn1(0)), VARPTR(RectsRgn1(0))))
        bool%   = GpiSetColor     (hps&, CLRCYAN)
        bool%   = GpiPaintRegion  (hps&, hrgnds&)
        SLEEP 1

        Comb&   = GpiCombineRegion (hps&, hrgnds&, hrgnsc&, hrgnds&, CRGNAND)
        bool%   = GpiSetColor      (hps&, CLRRED)
        bool%   = GpiPaintRegion   (hps&, hrgnds&)
        SLEEP 1

        RgnOffset.x = 50
        RgnOffset.y = 50
        bool%   = GpiOffsetRegion (hps&, hrgnsc&,_
                  MakeLong(VARSEG(RgnOffset),VARPTR(RgnOffset)))
        bool%   = GpiSetColor     (hps&, CLRYELLOW)
        bool%   = GpiPaintRegion  (hps&, hrgnsc&)

        OPEN "GpiRgn.OUT" FOR OUTPUT AS #1

	     PRINT #1,"******  GpiPtInRegion ******"
	     RGNPoint.x = 137
	     RGNPoint.y = 125
             Result& = GpiPtInRegion (hps&, hrgnsc&,_
                       MakeLong(VARSEG(RGNPoint), VARPTR(RGNPoint)))
	     SELECT CASE Result&
		  CASE PRGNOUTSIDE
                       PRINT #1,"(";RGNPoint.x;",";RGNPoint.y;") outside region"
		  CASE PRGNINSIDE
                       PRINT #1,"(";RGNPoint.x;",";RGNPoint.y;") inside region"
		  CASE PRGNERROR
		       PRINT #1,"Error!"
		  CASE ELSE
             END SELECT

	     PRINT #1,"****** GpiRectInRegion ******"
             RectsInRgn.xLeft = 337
             RectsInRgn.yBottom = 125
             RectsInRgn.xRight = 377
             RectsInRgn.yTop = 175
             Result& = GpiRectInRegion (hps&, hrgnsc&,_
                       MakeLong(VARSEG(RectsInRgn),VARPTR(RectsInRgn)))
	     SELECT CASE Result&
		  CASE RRGNOUTSIDE
		       PRINT #1,"The region specified is outside the region."
		  CASE RRGNINSIDE
		       PRINT #1,"The region specified is inside the region."
		  CASE RRGNERROR
		       PRINT #1,"Error!"
		  CASE ELSE
             END SELECT

	     PRINT #1,"****** GpiQueryRegionBox ******"
             Result& = GpiQueryRegionBox (hps&, hrgnds&,_
                       MakeLong(VARSEG(RectsInRgn),VARPTR(RectsInRgn)))
             PRINT #1,"(";RectsInRgn.xLeft;",";RectsInRgn.yBottom;") - ";
             PRINT #1,"(";RectsInRgn.xRight;",";RectsInRgn.yTop;")"

	     PRINT #1,"****** GpiQueryRegionRects ******"
             RectsBound.xLeft = 0
             RectsBound.yBottom = 380
             RectsBound.xRight = 640
             RectsBound.yTop = 0
             Result& = GpiQueryRegionRects (hps&,_
                          hrgnds&,_
			  MakeLong(VARSEG(RectsBound),VARPTR(RectsBound)),_
                          MakeLong(VARSEG(RGNRectangle),VARPTR(RGNRectangle)),_
			  MakeLong(VARSEG(RectsRgn1(0)),VARPTR(RectsRgn1(0))))
             PRINT #1, "Result: ";Result&

             PRINT #1, "****** GpiSetClipRegion ******"
             ClipRGN& = GpiSetClipRegion (hps&, hrgnsc&,_
                        MakeLong(VARSEG(hrgnds&), VARPTR(hrgnds&)))
             PRINT #1, "Result: ";ClipRGN&

	     PRINT #1,"****** GpiQueryClipRegion ******"
	     Result& = GpiQueryClipRegion (hps&)
             PRINT #1, "Result: ";Result&

	     PRINT #1,"****** GpiQueryClipBox ******"
             Result& = GpiQueryClipBox (hps&,_
                       MakeLong(VARSEG(RectsInRgn), VARPTR(RectsInRgn)))
             CALL OutcomeOfFunction (Result&)

	     PRINT #1,"****** GpiIntersectClipRectangle ******"
             Result& = GpiIntersectClipRectangle(hps&,_
                       MakeLong(VARSEG(RectsInRgn), VARPTR(RectsInRgn)))
             CALL OutcomeOfFunction (Result&)

	     PRINT #1,"****** GpiExcludeClipRectangle ******"
             Result& = GpiExcludeClipRectangle(hps&,_
                       MakeLong(VARSEG(RectsInRgn), VARPTR(RectsInRgn)))
             CALL OutcomeOfFunction (Result&)

	     PRINT #1,"****** GpiOffsetClipRegion ******"
	     Result& = GpiOffsetClipRegion(hps&,_
                       MakeLong(VARSEG(RGNPoint), VARPTR(RGNPoint)))
             CALL OutcomeOfFunction (Result&)

	     PRINT #1,"****** GpiQueryClipBox ******"
             Result& = GpiQueryClipBox (hps&,_
                       MakeLong(VARSEG(RectsInRgn), VARPTR(RectsInRgn)))
             CALL OutcomeOfFunction (Result&)

	CLOSE #1
	bool%	= GpiDestroyRegion(hps&, hrgrnsc&)
	bool%	= GpiDestroyRegion(hps&, hrgrnds&)
END SUB

'***** Sub procedure to check general results of RGN function calls *****

SUB OutcomeOfFunction (ResultOfFunction&)
     SELECT CASE ResultOfFunction&
	 CASE RGNNULL
             PRINT #1,"RGNNULL    -- Function Successful"
	 CASE RGNRECT
             PRINT #1,"RGNRECT    -- Function Successful"
	 CASE RGNCOMPLEX
             PRINT #1,"RGNCOMPLEX -- Function Successful"
	 CASE ELSE
             PRINT #1,"RGNERROR   -- Function UnSuccessful"
     END SELECT
END SUB
