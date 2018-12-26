'***********************************************************
'* 
'* Program Name: WinMenu.BAS
'*
'* Include File: WinMenu.BI
'*
'* Functions   :
'*               WinCreateMenu   Not Demonstrated,see below
'*               WinLoadMenu
'*
'* Description : This program demonstrates loading a menu
'*               (using WinLoadMenu) from a resource file
'*               (WinMenu.RC).  WinCreateMenu is not 
'*               demonstrated because the menu template type
'*               uses a variant record, which is not possible
'*               in BASIC.  It is advised to use WinLoadMenu,
'*               with a resouce compiled with the RC resource
'*               compiler that comes with the PM Toolkit or
'*               specify the resource ID in WinCreateStdWindow.
'***********************************************************

'*********         Initialization section        ***********

REM $INCLUDE: 'PMBase.BI'
REM $INCLUDE: 'WinMenu.BI'
REM $INCLUDE: 'BseDosPC.BI'	 Needed for DOSBeep
REM $INCLUDE: 'WinMan1.BI'	 Needed for WinShowWindow

CONST IDRESOURCE = 1		'Constants for Resource File
CONST IDMBEEP	 = 2
CONST IDMBEEP1   = 3
CONST IDMBEEP2   = 4
CONST IDMBEEP3   = 5
CONST IDMEXIT    = 6
CONST IDMBYE     = 7 

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
             WSINVISIBLE,_
             MakeLong(VARSEG(flFrameFlags&),  VARPTR(flFrameFlags&)),_
             MakeLong(VARSEG(szClientClass$), SADD(szClientClass$)),_
             0,_
             0,_
             0,_
             0,_           'Optional: Specify Resource ID here
             MakeLong(VARSEG(hwndClient&), VARPTR(hwndClient&)))

'***********          WinLoadMenu          ***************

HwndMenu& = WinLoadMenu   (hwndFrame&,0,IDRESOURCE)
Bool%     = WinShowWindow (hwndFrame&,1)

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
     ClientWndProc& = 0
     SELECT CASE msg%
     CASE WMPAINT     'Paint the window with background color
        hps&  = WinBeginPaint(hwnd&, 0,_
                MakeLong(VARSEG(ClientRect), VARPTR(ClientRect)))
        bool% = WinFillRect(hps&,_
                MakeLong(VARSEG(ClientRect), VARPTR(ClientRect)),0)
        bool% = WinEndPaint(hps&)
     CASE WMCOMMAND	'WMCOMMAND sent for any menu msg
	  CALL BreakLong(mp1&, HiWord%, LoWord%)
	  SELECT CASE LoWord%	   'MenuItem ID is in low word of mp1
               CASE IDMBEEP1
		     X% = DosBeep(110,100)
               CASE IDMBEEP2
		     X% = DosBeep(110,100)
		     X% = DosBeep(220,100)
               CASE IDMBEEP3
		     X% = DosBeep(110,100)
		     X% = DosBeep(220,100)
		     X% = DosBeep(440,100)
               CASE IDMBYE
                     Quit& = WinSendMsg(HWND&,WMClose,0,0)     
	       CASE ELSE	   'Should never be any other case
	  END SELECT
     CASE ELSE        'Pass control to system for other messages
        ClientWndProc& = WinDefWindowProc(hwnd&, msg%, mp1&, mp2&)
     END SELECT
END FUNCTION
