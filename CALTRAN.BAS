'***********************************************************
'* 
'* Program Name: Cal.BAS
'*
'* Description : This is the transition version of CAL.BAS
'*               It uses essentially the same I/O and flow
'*               as the original CAL.BAS. All standard I/O
'*               has been replaced with the routines from
'*               WinStdIO.BAS (WinCLS, WinPrint, WinInput,
'*               WinLocate, WinPos).
'*
'* Changes:      SKELETON main program added
'*               I/O control moved to ClientWndProc (WMPAINT)
'*               PrintCalendar uses WinXXX routines for I/O
'*               GetInput uses WinXXX routines...
'***********************************************************

'* Initial section from original CAL.BAS
DEFINT A-Z               ' Default variable type is integer

' Define a data type for the names of the months and the
' number of days in each:
TYPE MonthType
   Number AS INTEGER     ' Number of days in the month
   MName AS STRING * 9   ' Name of the month
END TYPE

' Declare procedures used:
DECLARE FUNCTION IsLeapYear% (N%)
DECLARE FUNCTION GetInput% (hwnd&, hps&, Prompt$, Row%, LowVal%, HighVal%)

DECLARE SUB PrintCalendar (hwnd&, hps&, Year%, Month%)
DECLARE SUB ComputeMonth (Year%, Month%, StartDay%, TotalDays%)

'*********         Initialization section        ***********

'** From SKELETON.BAS

REM $INCLUDE: 'PMBase.BI'
REM $INCLUDE: 'WinStdIO.BI'
REM $INCLUDE: 'OS2Def.BI'           Needed for POINTL type
REM $INCLUDE: 'WinInput.BI'         Needed for WMCHAR constant

DIM aqmsg AS QMSG

flFrameFlags& = FCFTITLEBAR      OR FCFSYSMENU OR _
                FCFSIZEBORDER    OR FCFMINMAX  OR _
                FCFSHELLPOSITION OR FCFTASKLIST

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
          0,_
          MakeLong (VARSEG(hwndClient&), VARPTR(hwndClient&)))

'*** From original CAL.BAS
DIM MonthData(1 TO 12) AS MonthType

' Initialize month definitions from DATA statements below:
FOR I = 1 TO 12
   READ MonthData(I).MName, MonthData(I).Number
NEXT

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
'** ClientWndProc is mainly from SKELETON, but contains controls
'** from the original CAL.BAS. WMCHAR is necessary to buffer
'** characters for WinInput. InputIndex is used to tell what
'** the current stage of input is.
'**
'** NOTE: GOTO is used to display prompt again. Loops are not
'**       advised anywhere except in the message loop.
FUNCTION ClientWndProc& (hwnd&, msg%, mp1&, mp2&) STATIC
     DIM ClientRect AS RECTL
     ClientWndProc&=0
     SELECT CASE msg%
     CASE WMCHAR         'Buffer characters
        CALL KeyMsg(hwnd&, mp1&, mp2&)
     CASE WMPAINT
        hps&  = WinBeginPaint(hwnd&, 0,_
                MakeLong(VARSEG(ClientRect), VARPTR(ClientRect)))
        BeginInput:
           IF InputIndex% = 0 THEN    'Input Year
               ' Get year as input:
               CALL WinCLS(hwnd&, hps&)
               Year = GetInput(hwnd&, hps&, "Year (1899 to 2099): ", 1, 1899, 2099)
               IF Year <> 0 THEN
                  InputIndex% = InputIndex% + 1
               END IF
           END IF
           IF InputIndex% = 1 THEN    'Input Month
               ' Get month as input:
               Month = GetInput(hwnd&, hps&, "Month (1 to 12): ", 2, 1, 12)
               IF Month <> 0 THEN
                  InputIndex% = InputIndex% + 1
               END IF
           END IF
           IF InputIndex% = 2 THEN     'Print Calendar
               ' Print the calendar:
               PrintCalendar hwnd&, hps&, Year, Month
               InputIndex% = InputIndex% + 1
           END IF
           IF InputIndex% = 3 THEN     'Ask for another date
               ' Another Date?
               WinLocate hwnd&, hps&, 13, 1             ' Locate in 13th row, 1st column
               WinPrintS hps&, "New Date? "             ' Keep cursor on same line
               Resp$ = WinInkey$                        ' Wait for a key press
               IF Resp$ <> "" THEN WinPrint hps&, Resp$ ' Print the key pressed
               IF (UCASE$(Resp$)="Y") THEN
                  InputIndex% = 0
                  GOTO BeginInput        'If another date, display prompt
               ELSEIF Resp$ <> "" THEN
                  bool% = WinSendMsg(hwnd&, WMCLOSE, 0, 0)
               END IF
           END IF
        bool% = WinEndPaint(hps&)
     CASE ELSE        'Pass control to system for other messages
        ClientWndProc& = WinDefWindowProc(hwnd&, msg%, mp1&, mp2&)
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
' ======================== GETINPUT ==========================
'       Prompts for input, then tests for a valid range.
' ============================================================
'
'****
'** GetInput uses WinStdio routines to display and input text.
'** These routines are very similar to the BASIC I/O statements.
'** The main difference is that WinInput is a function which will
'** return zero until the input is completed.
FUNCTION GetInput (hwnd&, hps&, Prompt$, Row, LowVal, HighVal) STATIC

   ' Locate prompt at specified row, turn cursor on and
   ' make it one character high:
   WinLocate hwnd&, hps&, Row, 1
   WinPrintS hps&, Prompt$

   ' Save column position:
   Column = WinPos(hps&)

   ' Input value until it's within range:
   WinLocate hwnd&, hps&, Row, Column   ' Locate cursor at end of prompt
   WinPrint hps&, SPACE$(10)     ' Erase anything already there
   WinLocate hwnd&, hps&, Row, Column   ' Relocate cursor at end of prompt
   done% = WinInput(hps&, "", GetVal$)     ' Input value with no prompt
   IF done% THEN
     Value = VAL(GetVal$)
     GetVal$ = ""
   END IF
   IF (Value < LowVal) OR (Value > HighVal) THEN done% = 0

   ' Return valid input as value of function:
   IF done% THEN
     GetInput = Value
   ELSE
     GetInput = 0
   END IF

END FUNCTION
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
'****
'** PrintCalendar uses WinStdio routines. WinLocate's are used
'** instead of PRINT USING's to handle the proportional fonts.

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

      'WinLocate's used to compensate for proportional font
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

   'WinLocate's used to compensate for proportional font
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

END SUB
