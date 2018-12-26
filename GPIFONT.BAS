'***********************************************************
'* 
'* Program Name: GpiFont.BAS
'*
'* Include File: GpiFont.BI
'*
'* Functions   :
'*               GpiDeleteSetId
'*               GpiQueryNumberSetIds
'*               GpiQuerySetIds
'*               GpiLoadFonts
'*               GpiUnloadFonts
'*               GpiCreateLogFont
'*               GpiQueryFonts
'*               GpiQueryFontMetrics
'*               GpiQueryKerningPairs
'*               GpiQueryWidthTable
'*               GpiSetCp
'*               GpiQueryCp
'*               GpiQueryFontFileDescriptions
'*               GpiSetCharSet
'*               GpiQueryCharSet
'*
'* Description : This program demonstrates the Font functions.
'*               These functions allow the programmer to change
'*               font types and sizes, as well as to query the
'*               font metrics other font related information.
'***********************************************************

'*********         Initialization section        ***********

REM $INCLUDE: 'OS2Def.BI'
REM $INCLUDE: 'PMBase.BI'
REM $INCLUDE: 'WinMan1.BI'
REM $INCLUDE: 'GpiFont.BI'
REM $INCLUDE: 'GpiCont.BI'
REM $INCLUDE: 'GpiLine.BI'
REM $INCLUDE: 'GpiChar.BI'

DIM aqmsg AS QMSG

flFrameFlags& = FCFTITLEBAR      OR FCFSYSMENU OR _
                FCFSIZEBORDER    OR FCFMINMAX  OR _
                FCFSHELLPOSITION OR FCFTASKLIST

szClientClass$ = "ClassName" + CHR$(0)

hab& = WinInitialize    (0)
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
     ClientWndProc& = 0
     SELECT CASE msg%
     CASE WMPAINT     'Paint the window with background color
        bool% = WinInvalidateRect(hwnd&, 0, 0)
        hps&  = WinBeginPaint(hwnd&, 0,_
                MakeLong(VARSEG(ClientRect), VARPTR(ClientRect)))
        bool% = WinFillRect(hps&,_
		MakeLong(VARSEG(ClientRect), VARPTR(ClientRect)),0)

        CALL GPIFontTST(hps&)

        bool% = WinEndPaint(hps&)
     CASE ELSE         'Pass control to system for other messages
        ClientWndProc& = WinDefWindowProc(hwnd&, msg%, mp1&, mp2&)
     END SELECT
END FUNCTION


SUB GPIFontTST(hps AS LONG)

   SHARED hab&

   DIM ptl AS POINTL

   OPEN "GpiFont.OUT" FOR OUTPUT AS #1

   dim fat AS FATTRS
   CodePage% = GpiQueryCp(hps)
   PRINT #1, "GpiQueryCp: ", CodePage%

   bool% = GpiSetCp(hps, CodePage%)
   PRINT #1, "GpiSetCp: ", CodePage%

   ptl.x = 0 : ptl.y = 100           ' Show default font for reference
   DisplayString$ = "Programs start in System Font" + CHR$(0)
   GpiReturn& = GpiCharStringAt(hps,_
                MakeLong(VARSEG(ptl), VARPTR(ptl)),_
                LEN(DisplayString$),_
                MakeLong(VARSEG(DisplayString$), SADD(DisplayString$)))

   fat.usRecordLength  = LEN(fat)
   fat.usCodePage      = CodePage%
   fat.lMaxBaseLineExt = 12
   fat.lAveCharWidth   = 12
   fat.fsType          = FATTRTYPEFIXED
   fat.fsFontUse       = FATTRFONTUSENOMIX
   fat.szFacename      = "Courier" + CHR$(0)
   FontReturn& = GpiCreateLogFont(hps, 0, 1&,_
                 MakeLong(VARSEG(fat), VARPTR(fat)))
   PRINT #1, "GpiCreateLogFont: ",FontReturn&

   bool% = GpiSetCharSet(hps, 1&)
   PRINT #1, "GpiSetCharSet: ", bool%

   ptl.x = 0 : ptl.y = 90            ' Show that we have changed the font
   DisplayString$ = "Now in Courier..." + CHR$(0)
   GpiReturn& = GpiCharStringAt(hps,_
                MakeLong(VARSEG(ptl), VARPTR(ptl)),_
                LEN(DisplayString$),_
                MakeLong(VARSEG(DisplayString$), SADD(DisplayString$)))

   DIM fm AS FONTMETRICS

   bool% = GpiQueryFontMetrics(hps, LEN(fm), MakeLong(VARSEG(fm), VARPTR(fm)))

   PRINT #1, "GpiQueryFontMetrics: ", bool%
   PRINT #1, ""
   PRINT #1, "Font Metrics"
   PRINT #1, "--------------------------------------"

   PRINT #1, "szFamilyName:        "; fm.szFamilyName
   PRINT #1, "szFacename:          "; fm.szFacename
   PRINT #1, "idRegistry:          "; fm.idRegistry
   PRINT #1, "usCodePage:          "; fm.usCodePage
   PRINT #1, "lEmHeight:           "; fm.lEmHeight
   PRINT #1, "lXHeight:            "; fm.lXHeight
   PRINT #1, "lMaxAscender:        "; fm.lMaxAscender
   PRINT #1, "lMaxDescender:       "; fm.lMaxDescender
   PRINT #1, "lLowerCaseAscent:    "; fm.lLowerCaseAscent
   PRINT #1, "lLowerCaseDescent:   "; fm.lLowerCaseDescent
   PRINT #1, "lInternalLeading:    "; fm.lInternalLeading
   PRINT #1, "lExternalLeading:    "; fm.lExternalLeading
   PRINT #1, "lAveCharWidth:       "; fm.lAveCharWidth
   PRINT #1, "lMaxCharInc:         "; fm.lMaxCharInc
   PRINT #1, "lEmInc:              "; fm.lEmInc
   PRINT #1, "lMaxBaselineExt:     "; fm.lMaxBaselineExt
   PRINT #1, "sCharSlope:          "; fm.sCharSlope
   PRINT #1, "sInlineDir:          "; fm.sInlineDir
   PRINT #1, "sCharRot:            "; fm.sCharRot
   PRINT #1, "usWeightClass:       "; fm.usWeightClass
   PRINT #1, "usWidthClass:        "; fm.usWidthClass
   PRINT #1, "sXDeviceRes:         "; fm.sXDeviceRes
   PRINT #1, "sYDeviceRes:         "; fm.sYDeviceRes
   PRINT #1, "sFirstChar:          "; fm.sFirstChar
   PRINT #1, "sLastChar:           "; fm.sLastChar
   PRINT #1, "sDefaultChar:        "; fm.sDefaultChar
   PRINT #1, "sBreakChar:          "; fm.sBreakChar
   PRINT #1, "sNominalPointSize:   "; fm.sNominalPointSize
   PRINT #1, "sMinimumPointSize:   "; fm.sMinimumPointSize
   PRINT #1, "sMaximumPointSize:   "; fm.sMaximumPointSize
   PRINT #1, "fsType:              "; fm.fsType
   PRINT #1, "fsDefn:              "; fm.fsDefn
   PRINT #1, "fsSelection:         "; fm.fsSelection
   PRINT #1, "fsCapabilities:      "; fm.fsCapabilities
   PRINT #1, "lSubscriptXSize:     "; fm.lSubscriptXSize
   PRINT #1, "lSubscriptYSize:     "; fm.lSubscriptYSize
   PRINT #1, "lSubscriptXOffset:   "; fm.lSubscriptXOffset
   PRINT #1, "lSubscriptYOffset:   "; fm.lSubscriptYOffset
   PRINT #1, "lSuperscriptXSize:   "; fm.lSuperscriptXSize
   PRINT #1, "lSuperscriptYSize:   "; fm.lSuperscriptYSize
   PRINT #1, "lSuperscriptXOffset: "; fm.lSuperscriptXOffset
   PRINT #1, "lSuperscriptYOffset: "; fm.lSuperscriptYOffset
   PRINT #1, "lUnderscoreSize:     "; fm.lUnderscoreSize
   PRINT #1, "lUnderscorePosition: "; fm.lUnderscorePosition
   PRINT #1, "lStrikeoutSize:      "; fm.lStrikeoutSize
   PRINT #1, "lStrikeoutPosition:  "; fm.lStrikeoutPosition
   PRINT #1, "sKerningPairs:       "; fm.sKerningPairs
   PRINT #1, "sReserved:           "; fm.sReserved
   PRINT #1, "lMatch:              "; fm.lMatch
   PRINT #1, ""

   NumberIds& = GpiQueryNumberSetIds(hps)
   PRINT #1, "GpiQueryNumberSetIds: ", NumberIds&

   REDIM alTypes(NumberIds&) AS LONG
   REDIM str8(NumberIds&) AS STRING * 9

   REDIM alcid(NumberIds&) AS LONG

   bool% = GpiQuerySetIds(hps, NumberIds&,_
           MakeLong(VARSEG(alTypes(0)), VARPTR(alTypes(0))),_
           MakeLong(VARSEG(str8(0)),    VARPTR(str8(0))),_
           MakeLong(VARSEG(alcid(0)),   VARPTR(alcid(0))))
   PRINT #1, "GpiQuerySetIds: ", bool%

   PRINT #1, ""
   PRINT #1, "Type","Name","Local Identifier"
   PRINT #1, "--------------------------------------------"

   FOR i% = 0 TO NumberIds& - 1
      PRINT #1, alTypes(i%), str8(i%), alcid(i%)
   NEXT

   PRINT #1, ""

   REDIM akrnpr(fm.SkerningPairs) AS KERNINGPAIRS
   bool% = GpiQueryKerningPairs(hps, fm.sKerningPairs,_
           MakeLong(VARSEG(akrnpr(0)), VARPTR(akrnpr(0))))
   PRINT #1, "GpiQueryKerningPairs: ", bool%

   PRINT #1, ""
   PRINT #1, "Kerning Pairs"
   PRINT #1, "-------------"

   FOR i% = 0 TO fm.SkerningPairs - 1
      PRINT #1, akrnpr(i%).sFirstChar, akrnpr(i%).sSecondChar,_
                akrnpr(i%).sKerningAmount
   NEXT

   PRINT #1, ""

   REDIM alWidths(5) AS LONG
   bool% = GpiQueryWidthTable(hps, 65, 5,_
           MakeLong(VARSEG(alWidths(0)), VARPTR(alWidths(0))))
   PRINT #1, "GpiQueryWidthTable: ", bool%

   PRINT #1, ""
   PRINT #1, "Widths"
   PRINT #1, "------"

   FOR i% = 0 TO 4
      PRINT #1, alWidths(i%)   ' In Courier all widths are the same
   NEXT

   PRINT #1, ""

   bool% = GpiSetCharSet(hps, 0&)          ' release the font before deleting
   PRINT #1, "GpiSetCharSet: ", bool%

   bool% = GpiDeleteSetId(hps, 1&)         ' delete the logical font
   PRINT #1, "GpiDeleteSetId: ", bool%

   FontReturn& = GpiQueryNumberSetIds(hps)
   PRINT #1, "GpiQueryNumberSetIds: ", FontReturn&

' Note:  The following are commented out because the file Helv.fon
'        needs to be in the directory that this program is run from.
'        To demonstate these routines copy Helv.fon over to the directory
'        the program is to be run from, then un-comment the following lines
'        and re-compile.
'        The .FON file must be in the current path - even if it is in the
'        current directory it will only look for it on the path.

'   ModuleName$ = "helv.fon" + CHR$(0)
'   bool% = GpiLoadFonts(hab&,_
'           MakeLong(VARSEG(ModuleName$), SADD(ModuleName$)))
'   PRINT #1, "GpiLoadFonts: ", bool%
'
'   QueryFontNULL& = 0
'   FontReturn& = GpiQueryFonts(hps, QFPRIVATE, 0,_
'                 MakeLong(VARSEG(QueryFontNULL&), VARPTR(QueryFontNULL&)),_
'                 0, 0)
'   PRINT #1, "Number Fonts Loaded: ", FontReturn&
'
'   FontReturn& = GpiQueryFontFileDescriptions(hab&,_
'                 MakeLong(VARSEG(ModuleName$), SADD(ModuleName$)),_
'                 MakeLong(VARSEG(cFonts&), VARPTR(cFonts&)), 0)
'   PRINT #1, "Number Fonts In File: ", FontReturn&
'
'   bool% = GpiUnloadFonts(hab&,_
'           MakeLong(VARSEG(ModuleName$), SADD(ModuleName$)))
'   PRINT #1, "GpiUnloadFonts: ", bool%

   CLOSE #1

END SUB
