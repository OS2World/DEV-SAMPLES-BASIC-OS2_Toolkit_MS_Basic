'***********************************************************
'* 
'* Program Name: Cal.BAS
'*
'* Description : This is the fully-converted version of
'*               CAL.BAS. It takes advantage of more PM
'*               features. Specifically, it uses a menu
'*               and dialog box instead of using WinInput
'*               for input. WinPrint is still used, since
'*               text output is still appropriate, but lines
'*               were added to make the output look more
'*               like a calendar.
'*
'* Changes:      Menu and dialog instead of WinInput.
'*               ClientWndProc modified for menu and dialog
'*               flFrameFlags& added OR FCFMENU
'*               WinCreateStdWindow added IDMENU
'*               ClientWndProc1 added (dialog procedure)
'*               GetInput removed
'*               DrawBoxes added
'***********************************************************

'*********         Initialization section        ***********

DEFINT A-Z               ' Default variable type is integer

' Define a data type for the names of the months and the
' number of days in each:
TYPE MonthType
   Number AS INTEGER     ' Number of days in the month
   MName AS STRING * 9   ' Name of the month
END TYPE

' Declare procedures used:
DECLARE FUNCTION IsLeapYear% (N%)

DECLARE SUB PrintCalendar (hwnd&, hps&, Year%, Month%)
DECLARE SUB ComputeMonth (Year%, Month%, StartDay%, TotalDays%)
REM $INCLUDE: 'PMBase.BI'
REM $INCLUDE: 'OS2Def.BI'
REM $INCLUDE: 'WinStdIO.BI'
REM $INCLUDE: 'WinDialg.BI'        Needed for WinDlgBox, etc.
REM $INCLUDE: 'WinMan1.BI'         Needed for DrawBoxes (WinQueryWindowRect)
REM $INCLUDE: 'GpiLine.BI'         Needed for DrawBoxes (GpiLine,GpiBox)
REM $INCLUDE: 'GpiArea.BI'         Needed for DrawBoxes (DROOUTLINE)
REM $INCLUDE: 'GpiChar.BI'         Needed for DrawBoxes (GpiQueryCharBox)
DECLARE FUNCTION RegBas1&         'Needed for registering Dialog procedure
CONST IDDLG = 1                   'Constants for menu and dialog
CONST IDYEAR = 1
CONST IDMONTH = 2
CONST IDMENU = 2

DIM MonthData(1 TO 12) AS MonthType

' Initialize month definitions from DATA statements below:
FOR I = 1 TO 12
   READ MonthData(I).MName, MonthData(I).Number
NEXT

DIM aqmsg AS QMSG

flFrameFlags& = FCFTITLEBAR      OR FCFSYSMENU OR _
                FCFSIZEBORDER    OR FCFMINMAX  OR _
                FCFSHELLPOSITION OR FCFTASKLIST OR_
                FCFMENU          '*** FCFMENU added

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
          IDMENU,_                       '**** IDMENU added
          MakeLong (VARSEG(hwndClient&), VARPTR(hwndClient&)))

'**************         Message loop         ***************

WHILE WinGetMsg(hab&, MakeLong(VARSEG(aqmsg), VARPTR(aqmsg)), 0, 0, 0)
  bool% = WinDispatchMsg(hab&, MakeLong(VARSEG(aqmsg), VARPTR(aqmsg)))
WEND

'***********         Finalize section        ***************

bool% = WinDestroyWindow(hwndFrame&)
bool% = WinDestroyMsgQueue(hmq&)
bool% = WinTerminate(hab&)

END

'***********         Window procedure        ***************

'****
'** ClientWndProc was modified by removing WinInput:
'**
'**          WMCHAR is removed
'**          WMPAINT only does one operation (PrintCalendar)
'**          WMCOMMAND added
FUNCTION ClientWndProc& (hwnd&, msg%, mp1&, mp2&) STATIC
     SHARED Year%, Month%
     DIM ClientRect AS RECTL
     ClientWndProc&=0
     SELECT CASE msg%
     CASE WMCREATE      'Get current date for initial calendar
        Month% = VAL(LEFT$(DATE$,2))
        Year% = VAL(RIGHT$(DATE$,4))
     CASE WMPAINT
        bool% = WinInvalidateRect(hwnd&, 0, 0)
        hps&  = WinBeginPaint(hwnd&, 0,_
                MakeLong(VARSEG(ClientRect), VARPTR(ClientRect)))
            ' Print the calendar:
            PrintCalendar hwnd&, hps&, Year%, Month%
        bool% = WinEndPaint(hps&)
     CASE WMCOMMAND      'Triggered by Menu

        'Accept input from dialog box (NOTE: RegBas1 --> ClientWndProc1)
        bool% = WinDlgBox(HWNDDESKTOP, hwnd&, RegBas1&, 0, IDDLG, 0)

        'Invalidate window to cause WMPAINT
        bool% = WinInvalidateRect(hwnd&, 0, 0)
     CASE ELSE        'Pass control to system for other messages
        ClientWndProc& = WinDefWindowProc(hwnd&, msg%, mp1&, mp2&)
     END SELECT
END FUNCTION

FUNCTION ClientWndProc1& (hwnd&, msg%, mp1&, mp2&) STATIC
    SHARED Year%, Month%
    DIM YearString AS STRING * 5
    DIM MonthString AS STRING * 3
    ClientWndProc1& = 0
    SELECT CASE msg%
       CASE WMCOMMAND     'Triggered by button
          bool% = WinQueryDlgItemText(hwnd&,_
                             IDYEAR,_
                             5,_
                             MakeLong(VARSEG(YearString),VARPTR(YearString)))
          bool% = WinQueryDlgItemText(hwnd&,_
                             IDMONTH,_
                             3,_
                             MakeLong(VARSEG(MonthString),VARPTR(MonthString)))

          'Check bounds
          TempYear% = VAL(YearString)
          TempMonth% = VAL(MonthString)
          IF (TempYear%>0) AND (TempMonth%>0) AND (TempMonth%<13) THEN
             Year% = TempYear%
             Month% = TempMonth%
          END IF

          bool% = WinDisMissDlg(hwnd&, 1)
       CASE ELSE
          ClientWndProc1& = WinDefDlgProc(hwnd&, msg%, mp1&, mp2&)
    END SELECT
END FUNCTION

' Data for the months of a year:
DATA January, 31, February, 28, March, 31
DATA April, 30, May, 31, June, 30, July, 31, August, 31
DATA September, 30, October, 31, November, 30, December, 31
'
' ====================== COMPUTEMONTH ========================
'     Computes the first day and the total days in a month.
' ============================================================
'
SUB ComputeMonth (Year, Month, StartDay, TotalDays) STATIC
   SHARED MonthData() AS MonthType
   CONST LEAP = 366 MOD 7
   CONST NORMAL = 365 MOD 7

   ' Calculate total number of days (NumDays) since 1/1/1899.

   ' Start with whole years:
   NumDays = 0
   FOR I = 1899 TO Year - 1
      IF IsLeapYear(I) THEN         ' If year is leap, add
         NumDays = NumDays + LEAP   ' 366 MOD 7.
      ELSE                          ' If normal year, add
         NumDays = NumDays + NORMAL ' 365 MOD 7.
      END IF
   NEXT

   ' Next, add in days from whole months:
   FOR I = 1 TO Month - 1
      NumDays = NumDays + MonthData(I).Number
   NEXT

   ' Set the number of days in the requested month:
   TotalDays = MonthData(Month).Number

   ' Compensate if requested year is a leap year:
   IF IsLeapYear(Year) THEN

      ' If after February, add one to total days:
      IF Month > 2 THEN
         NumDays = NumDays + 1

      ' If February, add one to the month's days:
      ELSEIF Month = 2 THEN
         TotalDays = TotalDays + 1

      END IF
   END IF

   ' 1/1/1899 was a Sunday, so calculating "NumDays MOD 7"
   ' gives the day of week (Sunday = 0, Monday = 1, Tuesday = 2,
   ' and so on) for the first day of the input month:
   StartDay = NumDays MOD 7
END SUB
'
' ====================== ISLEAPYEAR ==========================
'         Determines if a year is a leap year or not.
' ============================================================
'
FUNCTION IsLeapYear (N) STATIC

   ' If the year is evenly divisible by 4 and not divisible
   ' by 100, or if the year is evenly divisible by 400, then
   ' it's a leap year:
   IsLeapYear = (N MOD 4 = 0 AND N MOD 100 <> 0) OR (N MOD 400 = 0)
END FUNCTION
'
' ===================== PRINTCALENDAR ========================
'     Prints a formatted calendar given the year and month.
' ============================================================
'
SUB PrintCalendar (hwnd&, hps&, Year, Month) STATIC
SHARED MonthData() AS MonthType

   ' Compute starting day (Su M Tu ...) and total days
   ' for the month:
   ComputeMonth Year, Month, StartDay, TotalDays
   WinCLS hwnd&, hps&
   Header$ = RTRIM$(MonthData(Month).MName) + "," + STR$(Year)

   ' Calculates location for centering month and year:
   LeftMargin = (35 - LEN(Header$)) \ 2

   ' Print header:
   WinPrintS hps&, SPACE$(LeftMargin)
   WinPrint hps&, Header$
   WinPrint hps&, ""
   Row = WinCSRLIN(hwnd&, hps&)
      WinLocate hwnd&, hps&, Row, 1 + 0 * 5
      WinPrint hps&, "Su"
      WinLocate hwnd&, hps&, Row, 1 + 1 * 5
      WinPrint hps&, " M"
      WinLocate hwnd&, hps&, Row, 1 + 2 * 5
      WinPrint hps&, "Tu"
      WinLocate hwnd&, hps&, Row, 1 + 3 * 5
      WinPrint hps&, " W"
      WinLocate hwnd&, hps&, Row, 1 + 4 * 5
      WinPrint hps&, "Th"
      WinLocate hwnd&, hps&, Row, 1 + 5 * 5
      WinPrint hps&, " F"
      WinLocate hwnd&, hps&, Row, 1 + 6 * 5
      WinPrint hps&, "Sa"
      WinPrint hps&, ""

   ' Recalculate and print tab to the first day
   ' of the month (Su M Tu ...):
   Row = WinCSRLIN (hwnd&, hps&)
   Column = 1 + StartDay * 5

   ' Print out the days of the month:
   FOR I = 1 TO TotalDays
      II$ = LTRIM$(RTRIM$(STR$(I)))
      IF LEN(II$) = 1 THEN II$ = " " + II$
      WinLocate hwnd&, hps&, Row, Column
      WinPrintS hps&, II$
      Column = Column + 5

      ' Advance to the next line when the cursor
      ' is past column 32:
      IF Column > 32 THEN
        Row = Row + 1
        Column = 1
      END IF
   NEXT
   IF Column = 1 THEN Row = Row - 1
   CALL DrawBoxes(hwnd&, hps&, Row - 3)     '**** DrawBoxes added
END SUB

'**** DrawBoxes added to draw lines around calendar.
SUB DrawBoxes(hwnd&, hps&, NumRows%)
    DIM prcl AS RECTL
    DIM psizfxBox AS SIZEF
    DIM ptl AS POINTL

    'Check size of window and character
    bool% = WinQueryWindowRect(hwnd&, MakeLong(VARSEG(prcl), VARPTR(prcl)))
    bool% = GpiQueryCharBox(hps&,_
                            MakeLong&(VARSEG(psizfxBox), VARPTR(psizfxBox)))

    'DeltaX/Y and BottomOfCalendar used to ease drawing boxes
    DeltaX! = psizfxBox.cx / &H10000
    DeltaY! = psizfxBox.cy / &H10000
    BottomOfCalendar& = prcl.yTop - (DeltaY! * (NumRows% + 3.25))

    'Draw full box:
    CALL WinLocate(hwnd&, hps&, 3, 1)
    ptl.x = DeltaX! * 7 * 5
    ptl.y = BottomOfCalendar&
    bool% = GpiBox (hps&,_
                    DROOUTLINE,_
                    MakeLong(VARSEG(ptl), VARPTR(ptl)), 0, 0)

    'Draw vertical lines
    FOR I% = 1 TO 6
       ptl.x = ((5 * I%) - 1) * DeltaX!
       ptl.y = BottomOfCalendar& + (NumRows% + 1.25) * DeltaY!
       bool% = GpiMove(hps&, MakeLong(VARSEG(ptl), VARPTR(ptl)))
       ptl.y = BottomOfCalendar&
       bool% = GpiLine(hps&, MakeLong(VARSEG(ptl), VARPTR(ptl)))
    NEXT I%

    'Draw horizontal lines
    FOR I% = 1 TO NumRows% - 1
       ptl.x = 0
       ptl.y = BottomOfCalendar& + I% * DeltaY!
       bool% = GpiMove(hps&, MakeLong(VARSEG(ptl), VARPTR(ptl)))
       ptl.x = 7 * 5 * DeltaX!
       bool% = GpiLine(hps&, MakeLong(VARSEG(ptl), VARPTR(ptl)))
    NEXT I%
END SUB
