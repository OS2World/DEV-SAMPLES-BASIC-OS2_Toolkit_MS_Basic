'***********************************************************
'* 
'* Program Name: Demo3.BAS
'*
'* Description : This is the fully-converted version of
'*               Demo3.BAS. It takes advantage of more PM
'*               features. Specifically, it uses a menu
'*               and message box instead of using WinPrint
'*               and WinInkey$ for I/O.
'*
'* Changes:      Menu and message instead of WinPrint/Inkey
'*               ClientWndProc modified for menu and msg box
'*               Main control shifted from WMPAINT to WMCOMMAND
'*               flFrameFlags& added OR FCFMENU
'*               WinCreateStdWindow added IDMENU
'*               Menu routine changed
'*               FOR loops removed in sound routines
'***********************************************************

'*********         Initialization section        ***********

REM $INCLUDE: 'PMBase.BI'
REM $INCLUDE: 'WinMisc.BI'
REM $INCLUDE: 'WinDialg.BI'      Needed for WinMessageBox
REM $INCLUDE: 'BseDosPC.BI'      Needed for DosBeep
CONST MsPerTick = 1000 / 18     'Needed to convert SOUND units to DosBeep
CONST IDMENU       = 1            'Constants for Resource File
CONST IDMSOUND     = 2
CONST IDMBOUNCING  = 3
CONST IDMFALLING   = 4
CONST IDMKLAXON    = 5
CONST IDMSIREN     = 6
CONST IDMQUIT      = 7

DIM aqmsg AS QMSG
COMMON SHARED /HANDLE/ Hab&,hwndClient&

flFrameFlags& = FCFTITLEBAR      OR FCFSYSMENU OR _
                FCFSIZEBORDER    OR FCFMINMAX  OR _
                FCFSHELLPOSITION OR FCFTASKLIST OR_
                FCFMENU

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
          IDMENU,_
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
'** ClientWndProc has been rearranged to accomodate the menu.
'** Thus, main control is from WMCOMMAND (caused by menu) instead
'** of WMPAINT. WMTIMER still handles the sound, but is terminated
'** immediately with message box.

FUNCTION ClientWndProc& (hwnd&, msg%, mp1&, mp2&) STATIC
     DIM ClientRect AS RECTL

     ClientWndProc&=0
     SELECT CASE msg%
	CASE WMPAINT	 'Paint the window with background color
	      hps&  = WinBeginPaint(hwnd&, 0,_
                      MakeLong(VARSEG(ClientRect), VARPTR(ClientRect)))
              bool% = WinFillRect(hps&,_
                      MakeLong(VARSEG(ClientRect), VARPTR(ClientRect)),0)
	      bool% = WinEndPaint(hps&)
        CASE WMCOMMAND             'Menu has main control
              CALL BreakLong(mp1&, hiword%, loword%)
              SELECT CASE loword%
                   CASE IDMBOUNCING
                        '** CurrSound and Timer must be before Message Box!
                        CurrSound = 1
                        Bool% = WinStartTimer (hab&,hwndClient&,1,10)

                        caption$ = "Bouncing" + CHR$(0)
                        message$ = "Click OK for Silence" + CHR$(0)
                        MsgBox% = WinMessageBox(HWNDDESKTOP,_
                                  hwnd&,_
                                  MakeLong(VARSEG(message$), SADD(message$)),_
                                  MakeLong(VARSEG(caption$), SADD(caption$)),_
                                  1,_
                                  MBOK)
		   CASE IDMFALLING
                        CurrSound = 2
                        Bool% = WinStartTimer (hab&,hwndClient&,1,10)

                        caption$ = "Falling" + CHR$(0)
                        message$ = "Click OK for Silence" + CHR$(0)
                        MsgBox% = WinMessageBox(HWNDDESKTOP,_
                                  hwnd&,_
                                  MakeLong(VARSEG(message$), SADD(message$)),_
                                  MakeLong(VARSEG(caption$), SADD(caption$)),_
                                  1,_
                                  MBOK)

                   CASE IDMSIREN
                        CurrSound = 3
                        Bool% = WinStartTimer (hab&,hwndClient&,1,10)

                        caption$ = "Wailing" + CHR$(0)
                        message$ = "Click OK for Silence" + CHR$(0)
                        MsgBox% = WinMessageBox(HWNDDESKTOP,_
                                  hwnd&,_
                                  MakeLong(VARSEG(message$), SADD(message$)),_
                                  MakeLong(VARSEG(caption$), SADD(caption$)),_
                                  1,_
                                  MBOK)

                   CASE IDMKLAXON
                        CurrSound = 4
                        Bool% = WinStartTimer (hab&,hwndClient&,1,10)

                        caption$ = "Oscillating" + CHR$(0)
                        message$ = "Click OK for Silence" + CHR$(0)
                        MsgBox% = WinMessageBox(HWNDDESKTOP,_
                                  hwnd&,_
                                  MakeLong(VARSEG(message$), SADD(message$)),_
                                  MakeLong(VARSEG(caption$), SADD(caption$)),_
                                  1,_
                                  MBOK)

               CASE IDMQUIT
                     Quit& = WinSendMsg(HWND&,WMClose,0,0)
               
               CASE ELSE
	  END SELECT
          IF MsgBox% = MBIDOK THEN                     'Stop timer when OK
             bool% = WinStopTimer(hab&, hwndClient&, 1)
          END IF
     CASE WMTIMER                         'WMTIMER still has sound control
	  SELECT CASE CurrSound
	      CASE 1
                        CALL Bounce (32767, 246)
              CASE 2
                        CALL Fall (2000, 550, 500)
              CASE 3
                        CALL Siren (780, 650)
              CASE 4
                        CALL Klaxon (987, 329, 50)
	      CASE ELSE
	  END SELECT
     CASE ELSE       
          ClientWndProc& = WinDefWindowProc(hwnd&, msg%, mp1&, mp2&)
     END SELECT
END FUNCTION


'**** Original Demo3 SUBs. Changed to DosBeep and removed loops.
DEFINT A-Z

' Loop two sounds down at decreasing time intervals
SUB Bounce (Hi, Low) STATIC
   IF Count < 1 THEN Count = 60
      X% = DosBeep ( Low - Count / 2, MsPerTick * Count / 20 )
      X% = DosBeep ( Hi, MsPerTick * Count / 15 )
   Count = Count - 2
END SUB

' Loop down from a high sound to a low sound
SUB Fall (Hi, Low, Del) STATIC
   IF Count < Low THEN Count = Hi
      X% = DosBeep( Count, MsPerTick * Del / Count )
   Count = Count - 10
END SUB

' Alternate two sounds until a key is pressed
SUB Klaxon (Hi, Low, Dur) STATIC
      X% = DosBeep ( Hi, MsPerTick * 5 )
      X% = DosBeep ( Low, MsPerTick * 5 )
END SUB

' Loop a sound from low to high to low
SUB Siren (Hi, Range) STATIC
         IF Count < -Range THEN Count = Range
            X% = DosBeep ( Hi - ABS(Count), MsPerTick * .3 )
            Count = Count - 2 / Range
         Count = Count - 4
END SUB
