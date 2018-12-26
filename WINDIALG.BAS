'***********************************************************
'*
'* Program Name: WinDialg.BAS
'*
'* Include File: WinDialg.BI
'*
'* Functions   :
'*               WinLoadDlg
'*               WinDlgBox
'*               WinDismissDlg
'*               WinQueryDlgItemShort
'*               WinSetDlgItemShort
'*               WinSetDlgItemText
'*               WinQueryDlgItemText
'*               WinQueryDlgItemTextLength
'*               WinDefDlgProc
'*               WinAlarm
'*               WinMessageBox
'*               WinProcessDlg
'*               WinSendDlgItemMsg
'*               WinMapDlgPoints
'*               WinEnumDlgItem
'*               WinSubstituteStrings
'*               WinCreateDlg
'*
'* Description : This program demonstrates the various dialog
'*               box functions.  Within the ClientWndProc
'*               function, the system receives messages about
'*               either a key press or a mouse button being
'*               pressed.  Depending on the message, various
'*               functions are executed to bring up a dialog.
'*               Those functions which do not produce notable
'*               results send their return value to a file
'*               called:  WinDialg.OUT.  Each function is
'*               documented to what it is going to do just prior
'*               to the call.
'***********************************************************

'********* Internal SUB and FUNCTION Declaration *********

DECLARE SUB MakeMessageBox (hwnd&)
DECLARE FUNCTION DosGetResource% (BYVAL p1 AS INTEGER,_
                                  BYVAL p2 AS INTEGER,_
                                  BYVAL p3 AS INTEGER,_
                                  SEG p4 AS INTEGER)
DECLARE FUNCTION RegBas1&
DECLARE FUNCTION RegBas2&

'*********         Initialization section        *********

REM $INCLUDE: 'PMBase.BI'
REM $INCLUDE: 'WinDialg.BI'
REM $INCLUDE: 'WinInput.BI'       Needed for messages
REM $INCLUDE: 'OS2Def.BI'         Needed for POINTL type
REM $INCLUDE: 'WinButtn.BI'       Needed for setting BMSETCHECK

OPEN "WinDialg.OUT" FOR OUTPUT AS #1

DIM aqmsg AS QMSG

flFrameFlags&  = FCFTITLEBAR      OR FCFSYSMENU OR_
                 FCFSIZEBORDER    OR FCFMINMAX  OR_
                 FCFSHELLPOSITION OR FCFTASKLIST

szClientClass$ = "ClassName" + CHR$(0)

hab&  = WinInitialize    (0)
hmq&  = WinCreateMsgQueue(hab&, 0)

bool% = WinRegisterClass(hab&,_
        MakeLong(VARSEG(szClientClass$), SADD(szClientClass$)),_
        RegBas,_
        0,_
        0)

hwndFrame& = WinCreateStdWindow(HWNDDESKTOP,  WSVISIBLE,_
             MakeLong(VARSEG(flFrameFlags&),  VARPTR(flFrameFlags&)),_
             MakeLong(VARSEG(szClientClass$), SADD(szClientClass$)),_
             0, 0, 0, 0,_
             MakeLong(VARSEG(hwndClient&),    VARPTR(hwndClient&)))

'**************         Message loop         ***************

WHILE WinGetMsg(hab&, MakeLong(VARSEG(aqmsg), VARPTR(aqmsg)), 0, 0, 0)
  bool% = WinDispatchMsg(hab&, MakeLong(VARSEG(aqmsg), VARPTR(aqmsg)))
WEND

'***********         Finalize section        ***************

bool% = WinDestroyWindow   (hwndFrame&)
bool% = WinDestroyMsgQueue (hmq&)
bool% = WinTerminate       (hab&)

CLOSE #1

END

'***********         Window procedure        ***************

FUNCTION ClientWndProc& (hwnd&, msg%, mp1&, mp2&) STATIC
     DIM ClientRect AS RECTL
     ClientWndProc& = 0
     SELECT CASE msg%
     CASE WMCREATE     'Tasks to perform during creation.
        Text$  = "Press A Key Or Mouse Button To Bring Up"
        Text$  = Text$ + " The Dialog Boxes..." + CHR$(0)
        Title$ = "Dialog Sampler" + CHR$(0)

        '**** WinAlarm sounds a  beep.
        bool%   =  WinAlarm(HWNDDESKTOP, WAERROR)
        PRINT #1, "WinAlarm:", bool%

        '**** WinMessageBox creates the initial message box.
        bool% = WinMessageBox(HWNDDESKTOP, HWNDDESKTOP,_
                MakeLong(VARSEG(Text$),  SADD(Text$)),_
                MakeLong(VARSEG(Title$), SADD(Title$)), 1,_
                MBOK OR MBICONEXCLAMATION OR MBSYSTEMMODAL OR MBDEFBUTTON1)
        PRINT #1, "WinMessageBox:", bool%

     CASE WMPAINT     'Paint the window with background color
        hps&  = WinBeginPaint(hwnd&, 0,_
                MakeLong(VARSEG(ClientRect), VARPTR(ClientRect)))
        bool% = WinFillRect(hps&,_
                MakeLong(VARSEG(ClientRect), VARPTR(ClientRect)), 0)
        bool% = WinEndPaint(hps&)
     CASE WMBUTTON1DOWN     'Left Mouse Button Down, WinDlgBox

        '**** WinDlgBox loads and processes dialog box in ClientWndProc1
        bool%   =  WinDlgBox(HWNDDESKTOP, hwnd&, RegBas1, 0, 300, 0)
        PRINT #1, "WinDlgBox:", bool%

        ClientWndProc& = WinDefWindowProc(hwnd&, msg%, mp1&, mp2&)

     CASE WMBUTTON2DOWN     'Right Mouse Button Down, WinLoadDlg

        '**** WinLoadDlg loads and processes dialog box in ClientWndProc2
        hwndDlg& = WinLoadDlg(HWNDDESKTOP, hwnd&, RegBas2, 0, 600, 0)
        PRINT #1, "WinLoadDlg:", HEX$(hwndDlg&)

     CASE WMCHAR      ' Key Pressed, WinCreateDlg
        '* Load a dialog resource into memory and grab the selector
        bool% = DosGetResource(0, 4, 300, a%)

        '**** WinCreateDlg create the dialog from a dialog template defined
        '*    by the selector returned from DosGetResource and return a
        '*    handle to that dialog.  This also is processed in ClientWndProc1.
        MyDlgHwnd& = WinCreateDlg&(HWNDDESKTOP, 0, RegBas1,_
                     MakeLong(a%, 0), 0)
        PRINT #1, "WinCreateDlg:", HEX$(MyDlgHwnd&)

     CASE ELSE        'Pass control to system for other messages
        ClientWndProc& = WinDefWindowProc(hwnd&, msg%, mp1&, mp2&)
     END SELECT
END FUNCTION

'****
'** ClientWndProc1 is the dialog procedure for WinDlgBox and WinCreateDlg.
'** It allows the user to define and bring up a message box.

FUNCTION ClientWndProc1& (hwnd&, msg%, mp1&, mp2&) STATIC
     ClientWndProc1& = 0
     UserCaption$ = "Default Caption" + CHR$(0)
     UserTitle$ = "Default Title" + CHR$(0)
     Substitute$ = "Dummy %1 String" + CHR$(0)
     SELECT CASE msg%
     CASE WMINITDLG
        '**** WinEnumDlgItem returns handle to the 1st group item in dialog
        DummyHwnd& = WinEnumDlgItem(HWNDDESKTOP, hwnd&, EDIFIRSTGROUPTITEM, 0)
        PRINT #1, "WinEnumDlgItem:", HEX$(DummyHwnd&)

        '**** WinSendDlgItemMsg to set the radio buttons in the dialog box.
        mresult& = WinSendDlgItemMsg(hwnd&, 258, BMSETCHECK, 1, 0)
        PRINT #1, "WinSendDlgItemMsg:", mresult&
        bool&    = WinSendDlgItemMsg(hwnd&, 267, BMSETCHECK, 1, 0)
        PRINT #1, "WinSendDlgItemMsg:", mresult&
        bool&    = WinSendDlgItemMsg(hwnd&, 276, BMSETCHECK, 1, 0)
        PRINT #1, "WinSendDlgItemMsg:", mresult&

        '**** WinSubstituteStrings will look for a %n and send the message
        '*    WMSUBSTITUTESTRING to replace that marker with some text.
        bool% = WinSubstituteStrings(hwnd&,_
                MakeLong(VARSEG(Substitute$), SADD(Substitute$)), 25,_
                MakeLong(VARSEG(Substitute$), SADD(Substitute$)))
        PRINT #1, "WinSubstituteStrings:", bool%

        '**** WinSetDlgItemText sets the text of a dialog item.
        bool%    = WinSetDlgItemText(hwnd&, 284,_
                   MakeLong(VARSEG(UserCaption$), SADD(UserCaption$)))
        PRINT #1, "WinSetDlgItemText:", bool%
        bool%    = WinSetDlgItemText(hwnd&, 285,_
                   MakeLong(VARSEG(UserTitle$), SADD(UserTitle$)))
        PRINT #1, "WinSetDlgItemText:", bool%

     CASE WMSUBSTITUTESTRING  'A %n character was received in the source string
        PRINT #1, "### In WMSUBSTITUTESTRING Message Handler ###"

     CASE WMCOMMAND
        CALL BreakLong(mp1&, HiWord%, LoWord%)
        SELECT CASE LoWord%
           CASE 257     'WinAlarm Pressed.
              Alarm& = 0
              FOR i = 258 TO 260
                 '**** WinSendDlgItemMsg to find which radio button is checked
                 Alarm&  =  WinSendDlgItemMsg(hwnd&, i, BMQUERYCHECK, 0, 0)
                 PRINT #1, "WinSendDlgItemMsg:", Alarm&
                 IF Alarm& THEN
                    SELECT CASE i
                       CASE 258
                          bool% = WinAlarm(HWNDDESKTOP, WANOTE)
                       CASE 259
                          bool% = WinAlarm(HWNDDESKTOP, WAWARNING)
                       CASE 260
                          bool% = WinAlarm(HWNDDESKTOP, WAERROR)
                    END SELECT
                 END IF
              NEXT i

           CASE 263     'WinMessageBox Pressed.
              CALL MakeMessageBox(hwnd&)

           CASE 262     'Cancel Pressed.
              '**** WinDismissDlg dismisses and hides current dialog
              bool%   =  WinDismissDlg%(hwnd&, 262)
              PRINT #1, "WinDismissDlg:", bool%

              '**** WinProcessDlg determines the result of dialog
              Result% =  WinProcessDlg(hwnd&)
              PRINT #1, "WinProcessDlg:", Result%

        END SELECT
     CASE ELSE        'Pass control to system for other messages
        ClientWndProc1& = WinDefDlgProc(hwnd&, msg%, mp1&, mp2&)
     END SELECT
END FUNCTION

'****
'** ClientWndProc2 is the dialog procedure for WinDlgBox.  It allows
'** the user to input points and map them to two coordinate spaces.
FUNCTION ClientWndProc2& (hwnd&, msg%, mp1&, mp2&) STATIC
     DIM DialogPts AS POINTL
     ClientWndProc2& = 0
     SELECT CASE msg%
     CASE WMINITDLG     'Initialize before showing dialog.
        x1% = 0
        y1% = 0

        '**** WinSetDlgItemShort to set x and y coordinates
        bool% = WinSetDlgItemShort(hwnd&, 263, x1%, 0)
        bool% = WinSetDlgItemShort(hwnd&, 260, y1%, 0)

        bool% = WinSetDlgItemShort(hwnd&, 264, x1%, 0)
        bool% = WinSetDlgItemShort(hwnd&, 265, y1%, 0)

        bool% = WinSetDlgItemShort(hwnd&, 267, x1%, 0)
        bool% = WinSetDlgItemShort(hwnd&, 268, y1%, 0)
        PRINT #1, "WinSetDlgItemShort:", bool%

     CASE WMCOMMAND
        CALL BreakLong(mp1&, HiWord%, LoWord%)
        SELECT CASE LoWord%
        CASE 269     'Cancel Pressed.
           '**** WinDismissDlg dismisses and hides the dialog
           bool%   =  WinDismissDlg%(hwnd&, 269)
           PRINT #1, "WinDismissDlg:", bool%

           '**** WinProcessDlg determines the result of dialog
           Result% =  WinProcessDlg(hwnd&)
           PRINT #1, "WinProcessDlg:", Result%

        CASE 270     'WinMapDlgPoints Pressed.
           '**** WinQueryDlgItemShort will return an integer representation
           '*    of a dialog field
           bool%    = WinQueryDlgItemShort(hwnd&, 263,_
                      MakeLong(VARSEG(x1%), VARPTR(x1%)), 0)
           bool%    = WinQueryDlgItemShort(hwnd&, 260,_
                      MakeLong(VARSEG(y1%), VARPTR(y1%)), 0)
           PRINT #1, "WinQueryDlgItemShort:", bool%

           DialogPts.x = x1%
           DialogPts.y = y1%

           '**** WinMapDlgPoints converts points to dialog coordinates
           bool%    = WinMapDlgPoints(hwnd&,_
                      MakeLong(VARSEG(DialogPts), VARPTR(DialogPts)), 1, 0)
           PRINT #1, "WinMapDlgPoints:", bool%

           x2% = DialogPts.x
           y2% = DialogPts.y

           '**** WinSetDlgItemShort will put the integer values into the
           '*    dialog item declared in the call
           bool%    = WinSetDlgItemShort(hwnd&, 264, x2%, 0)
           bool%    = WinSetDlgItemShort(hwnd&, 265, y2%, 0)
           PRINT #1, "WinSetDlgItemShort:", bool%

           DialogPts.x = x1%
           DialogPts.y = y1%

           '**** WinMapDlgPoints converts points to window coordinates
           bool%    = WinMapDlgPoints(hwnd&,_
                      MakeLong(VARSEG(DialogPts), VARPTR(DialogPts)), 1, 1)
           PRINT #1, "WinMapDlgPoints:", bool%

           x2% = DialogPts.x
           y2% = DialogPts.y

           '**** WinSetDlgItemShort will put the integer values into the
           '*    dialog item declared in the call
           bool%    = WinSetDlgItemShort(hwnd&, 267, x2%, 0)
           bool%    = WinSetDlgItemShort(hwnd&, 268, y2%, 0)
           PRINT #1, "WinSetDlgItemShort:", bool%
        END SELECT

     CASE ELSE        'Pass control to system for other messages
        ClientWndProc2& = WinDefDlgProc(hwnd&, msg%, mp1&, mp2&)
     END SELECT
END FUNCTION



SUB MakeMessageBox (hwnd&)
   Result&  = 0
   Options& = 0
   FOR i%   = 264 TO 283
      '**** WinSendDlgItemMsg checks if the item is checked
      Result& = WinSendDlgItemMsg(hwnd&, i%, BMQUERYCHECK, 0, 0)

      IF Result& THEN
         SELECT CASE i%     'Get Dialog options
             CASE 264
                Options& = MBABORTRETRYIGNORE
             CASE 265
                Options& = MBENTER
             CASE 266
                Options& = MBENTERCANCEL
             CASE 267
                Options& = MBOK
             CASE 268
                Options& = MBOKCANCEL
             CASE 269
                Options& = MBRETRYCANCEL
             CASE 270
                Options& = MBYESNO
             CASE 271
                Options& = MBYESNOCANCEL
             CASE 272
                Options& = Options& OR MBICONASTERISK
             CASE 273
                Options& = Options& OR MBICONEXCLAMATION
             CASE 274
                Options& = Options& OR MBICONHAND
             CASE 275
                Options& = Options& OR MBICONQUESTION
             CASE 276
                Options& = Options& OR MBNOICON
             CASE 277
                Options& = Options& OR MBDEFBUTTON1
             CASE 278
                Options& = Options& OR MBDEFBUTTON2
             CASE 279
                Options& = Options& OR MBDEFBUTTON3
             CASE 280
                Options& = Options& OR MBAPPLMODAL
             CASE 281
                Options& = Options& OR MBSYSTEMMODAL
             CASE 282
                Options& = Options& OR MBHELP
             CASE 283
                Options& = Options& OR MBMOVEABLE
         END SELECT
      END IF
   NEXT i%

   '**** WinQueryDlgItemTextLength determines dialog string length.
   Length%  = WinQueryDlgItemTextLength(hwnd&, 284)
   PRINT #1, "WinQueryDlgItemTextLength:", Length%

   UserTitle$ = SPACE$(Length% + 1)
   '**** WinQueryDlgItemText returns the string from a specific dialog entry
   bool% = WinQueryDlgItemText(hwnd&, 284, Length% + 1,_
           MakeLong(VARSEG(UserTitle$), SADD(UserTitle$)))

   '**** WinQueryDlgItemTextLength determines dialog string length.
   Length%  = WinQueryDlgItemTextLength(hwnd&, 285)
   PRINT #1, "WinQueryDlgItemTextLength:", Length%

   UserCaption$ = SPACE$(Length% + 1)
   '**** WinQueryDlgItemText returns the string from a specific dialog entry
   bool% = WinQueryDlgItemText(hwnd&, 285, Length% + 1,_
           MakeLong(VARSEG(UserCaption$), SADD(UserCaption$)))

   '**** WinMessageBox will create the user's dialog box.
   bool% = WinMessageBox%(HWNDDESKTOP,    hwnd&,_
           MakeLong(VARSEG(UserTitle$),   SADD(UserTitle$)),_
           MakeLong(VARSEG(UserCaption$), SADD(UserCaption$)),_
           1, Options&)
   PRINT #1, "WinMessageBox:", bool%
END SUB
