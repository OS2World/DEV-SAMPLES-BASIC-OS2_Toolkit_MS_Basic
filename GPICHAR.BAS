'***********************************************************
'* 
'* Program Name: GpiChar.BAS
'*
'* Include File: GpiChar.BI
'*
'* Functions   :
'*               GpiCharString
'*               GpiCharStringAt
'*               GpiQueryCharStringPos
'*               GpiQueryCharStringPosAt
'*               GpiQueryTextBox
'*               GpiQueryDefCharBox
'*               GpiSetCharBox
'*               GpiQueryCharBox
'*               GpiSetCharAngle
'*               GpiQueryCharAngle
'*               GpiSetCharShear
'*               GpiQueryCharShear
'*               GpiSetCharDirection
'*               GpiQueryCharDirection
'*               GpiSetCharMode
'*               GpiQueryCharMode
'*               GpiCharStringPos
'*               GpiCharStringPosAt
'*
'* Description : This program demonstrates the functions
'*               contained in GPICHAR.BI.  It prints
'*               several strings, altering the attributes
'*               to show the effects of the various
'*               functions.  Because all the calls are done
'*               in the WMPAINT message, this routine delays
'*               before processing messages during a redraw.
'***********************************************************

'*********         Initialization section        ***********

REM $INCLUDE: 'OS2Def.BI'
REM $INCLUDE: 'PMBase.BI'
REM $INCLUDE: 'GpiChar.BI'
REM $INCLUDE: 'GpiCont.BI'
REM $INCLUDE: 'GpiLine.BI'

DIM aqmsg AS QMSG

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

bool% = WinDestroyWindow(hwndFrame&)
bool% = WinDestroyMsgQueue(hmq&)
bool% = WinTerminate(hab&)

END


'***********         Window procedure        ***************

FUNCTION ClientWndProc& (hwnd&, msg%, mp1&, mp2&) STATIC
     DIM ClientRect AS RECTL
     ClientWndProc&=0
     SELECT CASE msg%
     CASE WMPAINT     'Paint the window with background color
        hps&  = WinBeginPaint(hwnd&, 0,_
                MakeLong(VARSEG(ClientRect), VARPTR(ClientRect)))
        bool% = WinFillRect(hps&,_
		MakeLong(VARSEG(ClientRect), VARPTR(ClientRect)),0)

        CALL GPICharTST(hps&)

        bool% = WinEndPaint(hps&)
     CASE ELSE        'Pass control to system for other messages
        ClientWndProc& = WinDefWindowProc(hwnd&, msg%, mp1&, mp2&)
     END SELECT
END FUNCTION


SUB GPICharTST(hps AS LONG)

' ** Print out strings with normal attributes to show contrast with
'    later strings printed with changed attributes.

   DIM ptlStart AS POINTL

   GPIString$ = "This is a GPI Test String"

   ptlStart.x = 100
   ptlStart.y = 100

   OPEN "GpiChar.OUT" FOR OUTPUT AS #1

   GPIReturn& = GpiCharStringAt(hps,_
                MakeLong(VARSEG(ptlStart),   VARPTR(ptlStart)),_
                LEN(GPIString$),_
                MakeLong(VARSEG(GPIString$), SADD(GPIString$)))
   PRINT #1, "GpiCharStringAt:", GPIReturn&

   GPIString$ = " - This text should follow"

   GPIReturn& = GpiCharString(hps,_
                LEN(GPIString$),_
                MakeLong(VARSEG(GPIString$), SADD(GPIString$)))
   PRINT #1, "GpiCharString:", GPIReturn&

' ** character primitive functions
'    These don't display any values, results are sent to GpiChar.OUT file

   GPIString$ = "AAA BBbb"

   DIM aptl(LEN(GPIString$)) AS POINTL

   bool% = GpiQueryCharStringPos(hps, 0, LEN(GPIString$),_
           MakeLong(VARSEG(GPIString$), SADD(GPIString$)), 0,_
           MakeLong(VARSEG(aptl(0)),    VARPTR(aptl(0))))
   PRINT #1, "GpiQueryCharStringPos:", bool%
   PRINT #1, ""
   PRINT #1, "VALUES FOR GPIQueryCharStringPos"
   PRINT #1, "--------------------------------"

   FOR i% = 0 to (LEN(GPIString$))
     PRINT #1, MID$(GPIString$,i% + 1,1),
     PRINT #1, "("; aptl(i%).x, ","; aptl(i%).y;")"
   NEXT

   ptlStart.x = 10
   ptlStart.y = 20

   bool% = GpiQueryCharStringPosAt(hps,_
           MakeLong(VARSEG(ptlStart),   VARPTR(ptlStart)), 0,_
           LEN(GPIString$),_
           MakeLong(VARSEG(GPIString$), SADD(GPIString$)), 0,_
           MakeLong(VARSEG(aptl(0)),    VARPTR(aptl(0))))

   PRINT #1, "GpiQueryCharStringPosAt:",bool%
   PRINT #1, ""
   PRINT #1, "VALUES FOR GPIQueryCharStringPosAt"
   PRINT #1, "----------------------------------"

   FOR i% = 0 to (LEN(GPIString$))
     PRINT #1, MID$(GPIString$,i% + 1,1),
     PRINT #1, "("; aptl(i%).x, ","; aptl(i%).y;")"
   NEXT

' ** Text Box - No screen output, output sent to GpiChar.OUT

   DIM sizl AS SIZEL

   bool% = GpiQueryDefCharBox(hps, MakeLong(VARSEG(sizl), VARPTR(sizl)))
   PRINT #1, "GpiQueryDefCharBox:", bool%
   PRINT #1, "("; sizl.cx, ","; sizl.cy; ")"

   REDIM aptl(TXTBOXCOUNT) AS POINTL

   bool% = GpiQueryTextBox(hps,         LEN(GPIString$),_
           MakeLong(VARSEG(GPIString$), SADD(GPIString$)), TXTBOXCOUNT,_
           MakeLong(VARSEG(aptl(0)),    VARPTR(aptl(0))))

   PRINT #1, "GpiQueryTextBox:", bool%
   PRINT #1, ""
   PRINT #1, "VALUES FOR GPIQueryTextBox"
   PRINT #1, "----------------------------------"

   PRINT #1, "Top Left    : ("; aptl(TXTBOXTOPLEFT).x;",";_
                                aptl(TXTBOXTOPLEFT).y;")"
   PRINT #1, "Bottom Left : ("; aptl(TXTBOXBOTTOMLEFT).x;",";_
                                aptl(TXTBOXBOTTOMLEFT).y;")"
   PRINT #1, "Top Right   : ("; aptl(TXTBOXTOPRIGHT).x;",";_
                                aptl(TXTBOXTOPRIGHT).y;")"
   PRINT #1, "Bottom Right: ("; aptl(TXTBOXBOTTOMRIGHT).x;",";_
                                aptl(TXTBOXBOTTOMRIGHT).y;")"

' ** Character Mode - No screen output, output sent to GpiChar.OUT

   GPIReturn& = GpiQueryCharMode(hps)
   PRINT #1, "Character Mode:", GPIReturn&

   ' Set to CMMODE3 - Vector Font, otherwise the other GPICHAR calls will
   '                  show no effects.

   bool% = GpiSetCharMode       (hps, CMMODE3)
   PRINT #1, "GpiSetCharMode:", bool%

   GPIReturn& = GpiQueryCharMode(hps)
   PRINT #1, "Character Mode:", GPIReturn&

' ** Character Box

   DIM sizfxBox AS SIZEF
   DIM newsizfxBox AS SIZEF

   GPIString$ = "1) Character Box"

   ptlStart.x = 0
   ptlStart.y = 200

   GPIReturn& = GpiCharStringAt(hps,_
                MakeLong(VARSEG(ptlStart),   VARPTR(ptlStart)),_
                LEN(GPIString$),_
                MakeLong(VARSEG(GPIString$), SADD(GPIString$)))

   ' Get current character box size

   bool% = GpiQueryCharBox(hps, MakeLong(VARSEG(sizfxBox), VARPTR(sizfxBox)))
   PRINT #1, "GpiQueryCharBox:", bool%
   PRINT #1, "Character Box: ("; sizfxBox.cx; ",";sizfxBox.cy;")"

   ' double the character box size

   newsizfxBox.cy = sizfxBox.cy * 2
   newsizfxBox.cx = sizfxBox.cx * 2

   bool% = GpiSetCharBox(hps,_
           MakeLong(VARSEG(newsizfxBox), VARPTR(newsizfxBox)))
   PRINT #1, "GpiSetCharBox:", bool%

   GPIString$ = "2) Character Box"

   ptlStart.x = 0
   ptlStart.y = 180

   GPIReturn& = GpiCharStringAt(hps,_
                MakeLong(VARSEG(ptlStart),   VARPTR(ptlStart)),_
                LEN(GPIString$),_
                MakeLong(VARSEG(GPIString$), SADD(GPIString$)))

   bool%      = GpiQueryCharBox(hps,_
                MakeLong(VARSEG(newsizfxBox), VARPTR(newsizfxBox)))

   ' restore old character box size

   PRINT #1, "GpiQueryCharBox:", bool%
   PRINT #1, "Character Box: ("; sizfxBox.cx; ",";sizfxBox.cy;")"

   ' Set character box back to default

   bool% = GpiSetCharBox(hps, MakeLong(VARSEG(sizfxBox), VARPTR(sizfxBox)))

' Character Angle

   DIM gradlAngle AS GRADIENTL

   GPIString$ = "Character Angle"

   bool% = GpiQueryCharAngle(hps,_
           MakeLong(VARSEG(gradlAngle), VARPTR(gradlAngle)))
   PRINT #1, "GpiQueryCharAngle:", bool%
   PRINT #1, "Character Angle: ("; gradlAngle.x, ","; gradlAngle.y; ")"

   gradlAngle.x = 1
   gradlAngle.y = 1

   bool% = GpiSetCharAngle(hps,_
           MakeLong(VARSEG(gradlAngle), VARPTR(gradlAngle)))
   PRINT #1, "GpiSetCharAngle:", bool%

   ptlStart.x = 200
   ptlStart.y = 250

   ' rotate the characters around in a circle at 45 degree increments

   FOR angle% = 1 TO 360 STEP 45
      ang = angle% * 3.1416 / 180!

      gradlAngle.x = sin(ang)
      gradlAngle.y = cos(ang)

      bool%      = GpiSetCharAngle(hps,_
                   MakeLong(VARSEG(gradlAngle), VARPTR(gradlAngle)))

      GPIReturn& = GpiCharStringAt(hps,_
                   MakeLong(VARSEG(ptlStart),   VARPTR(ptlStart)),_
                   LEN(GPIString$),_
                   MakeLong(VARSEG(GPIString$), SADD(GPIString$)))
   NEXT

   bool% = GpiQueryCharAngle(hps,_
           MakeLong(VARSEG(gradlAngle), VARPTR(gradlAngle)))
   PRINT #1, "GpiQueryCharAngle:", bool%
   PRINT #1, "Character Angle: ("; gradlAngle.x, ","; gradlAngle.y; ")"

   gradlAngle.x = 1
   gradlAngle.y = 0

   bool% = GpiSetCharAngle(hps,_
           MakeLong(VARSEG(gradlAngle), VARPTR(gradlAngle)))

' Character Shear

   DIM ptlshear AS POINTL

   GPIString$ = "Character Shear"

   bool% = GpiQueryCharShear(hps,_
           MakeLong(VARSEG(ptlshear), VARPTR(ptlshear)))
   PRINT #1, "GpiQueryCharShear:", bool%
   PRINT #1, "Character Shear: ("; ptlshear.x, ","; ptlshear.y; ")"

   ptlshear.x = 1
   ptlshear.y = 1

   bool% = GpiSetCharShear(hps, MakeLong(VARSEG(ptlshear), VARPTR(ptlshear)))
   PRINT #1, "GpiSetCharShear:", bool%

   ptlStart.x = 0
   ptlStart.y = 170

   GPIReturn& = GpiCharStringAt  (hps,_
                MakeLong(VARSEG(ptlStart),   VARPTR(ptlStart)),_
                LEN(GPIString$),_
                MakeLong(VARSEG(GPIString$), SADD(GPIString$)))

   bool%      = GpiQueryCharShear(hps,_
                MakeLong(VARSEG(ptlshear), VARPTR(ptlshear)))
   PRINT #1, "GpiQueryCharShear:", bool%
   PRINT #1, "Character Shear: ("; ptlshear.x, ","; ptlshear.y; ")"

' Character Direction
' NOTE: This doesn't show any effect, as only current values that can be
'       passed to GpiSetCharDirection are LEFT TO RIGHT.

   GPIString$ = "Character Direction"

   GPIReturn& = GpiQueryCharDirection(hps)
   PRINT #1, "GpiQueryCharDirection:", GPIReturn&

   chardir& = CHDIRNDEFAULT
   bool% = GpiSetCharDirection(hps,_
           MakeLong(VARSEG(chardir&), VARPTR(chardir&)))
   PRINT #1, "GpiSetCharDirection:", bool%

   ptlStart.x = 0
   ptlStart.y = 160

   GPIReturn& = GpiCharStringAt(hps,_
                MakeLong(VARSEG(ptlStart),   VARPTR(ptlStart)),_
                LEN(GPIString$),_
                MakeLong(VARSEG(GPIString$), SADD(GPIString$)))

   GPIReturn& = GpiQueryCharDirection(hps)
   PRINT #1, "GpiQueryCharDirection:", GPIReturn&

' Character String

   DIM rect AS RECTL

   GPIString$ = " Char String Pos1"

   GPIReturn& = GpiCharStringPos(hps,_
                MakeLong(VARSEG(rect), VARPTR(rect)),_
                CHSLEAVEPOS, LEN(GPIString$),_
                MakeLong(VARSEG(GPIString$), SADD(GPIString$)),_
                MakeLong(VARSEG(aptl(0)), VARPTR(aptl(0))))

   ptlStart.x = 0
   ptlStart.y = 150
   GPIString$ = "Char String Pos2"

   GPIReturn& = GpiCharStringPosAt(hps,_
                MakeLong(VARSEG(ptlStart),   VARPTR(ptlStart)),_
                MakeLong(VARSEG(rect),       VARPTR(rect)),_
                CHSLEAVEPOS, LEN(GPIString$),_
                MakeLong(VARSEG(GPIString$), SADD(GPIString$)),_
                MakeLong(VARSEG(aptl(0)),    VARPTR(aptl(0))))
   CLOSE #1

END SUB
