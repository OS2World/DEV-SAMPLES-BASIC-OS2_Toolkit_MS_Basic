'***********************************************************
'* 
'* Program Name: Demo3.BAS
'*
'* Description : This is the transition version of Demo3.BAS
'*               It uses essentially the same I/O and flow
'*               as the original Demo3.BAS. All standard I/O
'*               has been replaced with the routines from
'*               WinStdIO.BAS (WinCLS, WinPrint, WinInput,
'*               WinLocate, WinPos).
'*
'* Changes:      SKELETON main program added
'*               I/O control moved to ClientWndProc (WMPAINT)
'*               Sound loops changed to WMTIMER
'*               SOUND statements changed to DosBeep
'***********************************************************

'*********         Initialization section        ***********

REM $INCLUDE: 'PMBase.BI'
REM $INCLUDE: 'WinMisc.BI'
REM $INCLUDE: 'WinInput.BI'      Needed for WMCHAR
REM $INCLUDE: 'BSEDosPC.BI'      Needed for DosBeep
REM $INCLUDE: 'WinStdIO.BI'      Needed for Standard Input & Output
CONST MsPerTick = 1000 / 18     'Needed to convert SOUND units to DosBeep
COMMON SHARED /HANDLE/ hab&     'Needed for WinStart/StopTimer

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


'**************         Message loop         ***************

WHILE WinGetMsg(hab&,_
       MakeLong(VARSEG(aqmsg), VARPTR(aqmsg)), 0, 0, 0)
  bool% = WinDispatchMsg(hab&,_
              MakeLong(VARSEG(aqmsg), VARPTR(aqmsg)))
WEND
     
'***********         Finalize section        ***************

bool% = WinDestroyWindow(hwndFrame&)
bool% = WinDestroyMsgQueue(hmq&)
bool% = WinTerminate(hab&)

END

'***********         Window procedure        ***************

'****
'** ClientWndProc handles most control from WMPAINT and WMTIMER
'** messages. WMPAINT is used for I/O because KeyMsg causes
'** a WMPAINT for WinInkey$. WMTIMER is used for sound loops
'** so other messages can get through for terminating sound.
'**
'** Key pressed controls flow in WMPAINT
'** CurrSound static variable (set in WMPAINT) control which sound in WMTIMER

FUNCTION ClientWndProc& (hwnd&, msg%, mp1&, mp2&) STATIC
     DIM ClientRect AS RECTL

     ClientWndProc&=0
     SELECT CASE msg%
	CASE WMPAINT	 'Paint the window with background color
	      hps&  = WinBeginPaint(hwnd&, 0,_
                     MakeLong(VARSEG(ClientRect), VARPTR(ClientRect)))
              Q$ = UCASE$(WinInkey$)          'Check current key
              SELECT CASE Q$                  'NOTE: Loop is message loop

                        CASE "B"              'Bouncing
			     CurrSound = 1
			     CALL WinCLS ( hwnd&, hps& )
			     CALL WinPrint ( hps&, "Bouncing .  .  ." )
			     CALL WinPrint ( hps&, ".  .  . Press any key to end.")
                             Bool% = WinStartTimer (hab&, hwnd&, 1, 10)

                        CASE "F"              'Falling
			     CurrSound =  2
			     CALL WinCLS ( hwnd&, hps& )
			     CALL WinPrint ( hps&, "Falling .  .  ." )
			     CALL WinPrint ( hps&, ".  .  . Press any key to end.")
			     Bool% = WinStartTimer (hab&,hwnd&,1,10)

                        CASE "S"              'Siren
			     CurrSound = 3
			     CALL WinCLS ( hwnd&, hps& )
			     CALL WinPrint ( hps&, "Wailing .  .  ." )
			     CALL WinPrint ( hps&, ".  .  . Press any key to end.")
			     Bool% = WinStartTimer (hab&,hwnd&,1,10)

                        CASE "K"              'Klaxon
			     CurrSound = 4
			     CALL WinCLS ( hwnd&, hps& )
			     CALL WinPrint ( hps&, "Oscillating .  .  ." )
			     CALL WinPrint ( hps&, ".  .  . Press any key to end.")
			     Bool% = WinStartTimer (hab&,hwnd&,1,10)

                        CASE "Q"              'Quit
			     Quit& = WinSendMsg(HWND&,WMClose,0,0)

                        'If a non-active key, stop timer (and thus stop sound)
                        CASE ELSE           ' and display menu
                             Bool% =  WinStopTimer (hab&,hwnd&,1)
                             CALL Menu(hwnd&, hps&)
	      END SELECT

	      bool% = WinEndPaint(hps&)
        CASE WMCHAR
              CALL KeyMsg (hwnd&,mp1&,mp2&)    'Buffer keys for WinInkey$
	CASE WMTIMER
          SELECT CASE CurrSound                'Which sound?
	      CASE 1
			CALL Bounce (32767, 246)
	      CASE 2
			CALL Fall (2000, 550, 500)
	      CASE 3
			CALL Siren (780, 650)
	      CASE 4
			CALL Klaxon (987, 329)
	      CASE ELSE
	  END SELECT
	CASE ELSE
          ClientWndProc& = WinDefWindowProc(hwnd&, msg%, mp1&, mp2&)
     END SELECT
END FUNCTION


'**** Menu uses the WinStdIO routines to display menu.

SUB Menu (hwnd&, hps&) STATIC
	      CALL WinCLS ( hwnd&, hps& )
	      CALL WinPrint ( hps&, "Sound Effects" )
              CALL WinPrint ( hps&, "             " )
              CALL WinPrint ( hps&, "Bouncing" )
              CALL WinPrint ( hps&, "Falling" )
              CALL WinPrint ( hps&, "Klaxon" )
              CALL WinPrint ( hps&, "Siren" )
              CALL WinPrint ( hps&, "Quit" )
	      CALL WinPrint ( hps&, "             " )
	      CALL WinPrint ( hps&, "Select:" )
END SUB

'**** Original Demo3.BAS source with SOUND statements replaced with DosBeep

' Loop two sounds down at decreasing time intervals
SUB Bounce (Hi%, Low%) STATIC
   FOR Count% = 60 TO 1 STEP -2
      X% = DosBeep ( Low% - Count% / 2,  MsPerTick * Count% / 20 )
      X% = DosBeep ( Hi%, MsPerTick * Count% / 15 )
   NEXT Count%
END SUB

' Loop down from a high sound to a low sound
SUB Fall (Hi%, Low%, Del%) STATIC
   FOR Count% = Hi% TO Low% STEP -10
      X% = DosBeep( Count%, MsPerTick * Del% / Count% )
   NEXT Count%
END SUB

' Alternate two sounds until a key is pressed
SUB Klaxon (Hi%, Low%) STATIC
      X% = DosBeep ( Hi%, MsPerTick * 5 )
      X% = DosBeep ( Low%, MsPerTick * 5 )
END SUB

' Loop a sound from low to high to low
SUB Siren (Hi%, Range%) STATIC
         FOR Count% = Range% TO -Range% STEP -4
            X% = DosBeep ( Hi% - ABS(Count%), MsPerTick * .3 )
            Count% = Count% - 2 / Range%
         NEXT Count%
END SUB
