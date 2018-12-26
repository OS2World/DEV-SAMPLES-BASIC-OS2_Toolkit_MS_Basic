'***********************************************************
'* 
'* Program Name: PMDev.BAS
'*
'* Include File: PMDev.BI
'*
'* Functions   :
'*               DevOpenDC
'*               DevCloseDC
'*               DevEscape
'*               DevQueryCaps
'*               DevQueryHardcopyCaps
'*               DevQueryDeviceNames
'*               DevPostDeviceModes
'*
'* Description : This program demonstrates the device functions.
'*               It opens a device context for the printer,
'*               queries the various values, prints text and
'*               graphics, and closes the device context.
'*
'*               NOTE: The output looks correct only with
'*                     printers compatible with the IBM 4201
'*                     Proprinter.
'*
'*               NOTE: This form of printing is VERY slow in
'*                     OS/2 Version 1.1.  For normal text
'*                     printing (no fonts), LPRINT or OPEN
'*                     "LPT1:"... will be much faster.
'***********************************************************

'*********         Initialization section        ***********

REM $INCLUDE: 'PMBase.BI'
REM $INCLUDE: 'PMDev.BI'
REM $INCLUDE: 'PMShl.BI'
REM $INCLUDE: 'OS2Def.BI'
REM $INCLUDE: 'WinErr.BI'
REM $INCLUDE: 'GpiCont.BI'
REM $INCLUDE: 'GpiChar.BI'
DECLARE FUNCTION  GpiLoadBitmap&(BYVAL hps&, BYVAL hmod%, BYVAL id%, BYVAL lw&, BYVAL lh&)
DECLARE FUNCTION  GpiBox&( BYVAL HPS AS LONG,_
			   BYVAL ALONG AS LONG,_
			   BYVAL PPOINTL AS LONG,_
			   BYVAL BLONG AS LONG,_
			   BYVAL CLONG AS LONG )
DECLARE FUNCTION WinDrawBitmap%(BYVAL hpsDst AS LONG,_
                                BYVAL hbm AS LONG,_
                                BYVAL pwrcSrc AS LONG,_
                                BYVAL pptlDst AS LONG,_
                                BYVAL clrFore AS LONG,_
                                BYVAL clrBack AS LONG,_
                                BYVAL fs AS INTEGER)


CONST MAXPRINTLEN = 1024
CONST MAXSTRINGLEN = 512

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
             WSVISIBLE,_
             MakeLong (VARSEG(flFrameFlags&),  VARPTR(flFrameFlags&)),_
             MakeLong (VARSEG(szClientClass$), SADD(szClientClass$)),_
             0,_
             0,_
             0,_
             0,_
             MakeLong (VARSEG(hwndClient&), VARPTR(hwndClient&)))

'*********         PMDev Functions       ***********

OPEN "PMDev.OUT" FOR OUTPUT AS #1

   'Set up strings for WinQueryProfileString for port
   PmSpooler$  = "PM_SPOOLER"        + CHR$(0)
   Printer$    = "PRINTER"           + CHR$(0)
   szPrinter$  = SPACE$(MAXPRINTLEN) + CHR$(0)
   NullString$ = CHR$(0)

   'Get printer port
   cch% = WinQueryProfileString(hab&,_
          MakeLong(VARSEG(PmSpooler$),  SADD(PmSpooler$)),_
          MakeLong(VARSEG(Printer$),    SADD(Printer$)),_
          MakeLong(VARSEG(NullString$), SADD(NullString$)),_
          MakeLong(VARSEG(szPrinter$),  SADD(szPrinter$)),_
          MAXPRINTLEN)

   'Set up strings for WinQueryProfileString for details
   szPrinter$ = LEFT$(szPrinter$,cch% - 2)+ CHR$(0)   'Remove last semicolon
   PmSpooler$ = "PM_SPOOLER_PRINTER"      + CHR$(0)
   szDetails$ = SPACE$(MAXPRINTLEN)       + CHR$(0)

   'Get printer details
   cch% = WinQueryProfileString(hab&,_
          MakeLong(VARSEG(PmSpooler$),  SADD(PmSpooler$)),_
          MakeLong(VARSEG(szPrinter$),  SADD(szPrinter$)),_
          MakeLong(VARSEG(NullString$), SADD(NullString$)),_
          MakeLong(VARSEG(szDetails$),  SADD(szDetails$)),_
          MAXPRINTLEN)

   'search for semicolon delimeters
   first%  = INSTR(szDetails$, ";")
   second% = INSTR(first%  + 1, szDetails$, ";")
   third%  = INSTR(second% + 1, szDetails$, ";")

   'Driver is between 1st & 2nd semicolons. Logical address between 2nd & 3rd
   Driver$     = MID$(szDetails$, first%  + 1, second% - first%  - 1) + CHR$(0)
   LogAddress$ = MID$(szDetails$, second% + 1, third%  - second% - 1) + CHR$(0)
   PRINT #1, "WinQueryProfileString:"
   PRINT #1, "","Driver:",  Driver$
   PRINT #1, "","Address:", LogAddress$

   '**** DevPostDeviceModes brings up dialog box; print info to file
   DIM dd AS DRIVDATA
   size& = DevPostDeviceModes(hab&,_
           MakeLong(VARSEG(dd),          VARPTR(dd)),_
           MakeLong(VARSEG(Driver$),     SADD(Driver$)), 0,_
           MakeLong(VARSEG(LogAddress$), SADD(LogAddress$)), 0)
   PRINT #1, "DevPostDeviceModes:", size&
   PRINT #1, "", "cb:",             HEX$(dd.cb)
   PRINT #1, "", "lVersion:",       HEX$(dd.lVersion)
   PRINT #1, "", "szDeviceName:",   dd.szDeviceName
   PRINT #1, "", "abGeneralData:",  dd.abGeneralData

   '**** DevQueryDeviceNames should return number of names and types,
   '**   according to the function specifications, but there seems to
   '**   be a problem with this function due to limited device names
   '**   with the initial release.

   DIM achDeviceName AS STRING * 32
   DIM achDeviceDesc AS STRING * 64
   DIM achDataType   AS STRING * 16
   pcMaxNames&       =  0
   pcMaxDataTypes&   =  0
   bool% = DevQueryDeviceNames(hab&,_
           MakeLong(VARSEG(Driver$),         SADD(Driver$)),_
           MakeLong(VARSEG(pcMaxNames&),     VARPTR(pcMaxNames&)),_
           MakeLong(VARSEG(achDeviceName),   VARPTR(achDeviceName)),_
           MakeLong(VARSEG(achDeviceDesc),   VARPTR(achDeviceDesc)),_
           MakeLong(VARSEG(pcMaxDataTypes&), VARPTR(pcMaxDataTypes&)),_
           MakeLong(VARSEG(achDataType),     VARPTR(achDataType)))
   PRINT #1, "DevQueryDeviceNames:", bool%
   PRINT #1, "", "MaxNames:",        pcMaxNames&
   PRINT #1, "", "MaxTypes:",        pcMaxDataTypes&

   '**** DevOpenDC opens device context for printer
   DIM dop AS DEVOPENSTRUC
   dop.pszLogAddress = MakeLong(VARSEG(LogAddress$), SADD(LogAddress$))
   dop.pszDriverName = MakeLong(VARSEG(Driver$),     SADD(Driver$))
   dop.pdriv         = 0
   dop.pszDataType   = 0
   devInfo$          = "*" + CHR$(0)
   hdcPrinter& = DevOpenDC(hab&, ODQUEUED,_
                 MakeLong(VARSEG(devInfo$), SADD(devInfo$)), 4,_
                 MakeLong(VARSEG(dop),      VARPTR(dop)),    0)
      PRINT #1, "DevOpenDC:", HEX$(hdcPrinter&)

      '**** DevQueryCaps get height and width of printer page
      bool% = DevQueryCaps(hdcPrinter&, CAPSHEIGHT, 1,_
              MakeLong(VARSEG(h&), VARPTR(h&)))
      bool% = DevQueryCaps(hdcPrinter&, CAPSWIDTH, 1,_
              MakeLong(VARSEG(w&), VARPTR(w&)))
      PRINT #1, "DevQueryCaps:", "("; w&; ","; h&; ")"

      '**** DevEscape starts the printer document
      szBuf$ = SPACE$(MAXSTRINGLEN) + CHR$(0)
      bool% = DevEscape(hdcPrinter&,   DEVESCSTARTDOC, MAXSTRINGLEN,_
              MakeLong(VARSEG(szBuf&), SADD(szBuf$)),  0, 0)
      PRINT #1, "DevEscape:",bool%

      '**** DevQueryHardcopyCaps returns the number of forms for device
      DIM hci AS HCINFO
      numForms& = DevQueryHardcopyCaps&(hdcPrinter&, 0, 0,_
                  MakeLong(VARSEG(hci), VARPTR(hci)))
      PRINT #1, "DevQueryHardcopyCaps:", numForms&

      'Create presentation space and put graphics and text to printer
      DIM szl AS SIZEL
      szl.cx = 0
      szl.cy = 0
      hpsPrinter& = GpiCreatePS(hab&, hdcPrinter&,_
                    MakeLong(VARSEG(szl), VARPTR(szl)),_
                    PUPELS OR GPIFDEFAULT OR GPITNORMAL OR GPIAASSOC)
         PRINT #1, "GpiCreatePS: ",HEX$(hpsPrinter&)

         'Text
         DIM ptl AS POINTL
         ptl.x  = 10
         ptl.y  = h& - 20
         hello$ = "Hello from Presentation Manager!!!" + CHR$(0)
         bool%  = GpiCharStringAt(hpsPrinter&,_
                  MakeLong(VARSEG(ptl),    VARPTR(ptl)), LEN(hello$) - 1,_
                  MakeLong(VARSEG(hello$), SADD(hello$)))

         'Box
         ptl.y = ptl.y - 20
         bool% = GpiBox(hpsPrinter&, 2,_
                 MakeLong(VARSEG(ptl), VARPTR(ptl)), 0, 0)

         'Bitmap
         hbmp& = GpiLoadBitmap(hpsPrinter&, 0, 1, 0, 0)
         bool% = WinDrawBitmap(hpsPrinter&, hbmp&, 0,_
                 MakeLong(VARSEG(ptl), VARPTR(ptl)), 1, 2, 0)

         'Disassociate and destroy the presentation space
         bool% = GpiAssociate(hpsPrinter&, 0)
      bool% = GpiDestroyPS(hpsPrinter&)

      '**** DevEscape ends document
      szBuf$ = SPACE$(MAXSTRINGLEN) + CHR$(0)
      bool% = DevEscape(hdcPrinter&, DEVESCENDDOC, 0, 0, MAXSTRINGLEN,_
              MakeLong(VARSEG(szBuf&), SADD(szBuf$)))
      PRINT #1, "DevEscape:",bool%

   '**** DevCloseDC closes printer device context
   hmf& = DevCloseDC(hdcPrinter&)
   PRINT #1, "DevCloseDC:",hmf&

'**************         Message loop         ***************

WHILE WinGetMsg(hab&, MakeLong(VARSEG(aqmsg), VARPTR(aqmsg)), 0, 0, 0)
  bool% = WinDispatchMsg(hab&, MakeLong(VARSEG(aqmsg), VARPTR(aqmsg)))
WEND

'***********         Finalize section        ***************

CLOSE #1

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
        hps&  = WinBeginPaint(hwnd&, 0,_
                MakeLong(VARSEG(ClientRect), VARPTR(ClientRect)))
        bool% = WinFillRect  (hps&,_
                MakeLong(VARSEG(ClientRect), VARPTR(ClientRect)),0)
        bool% = WinEndPaint  (hps&)
     CASE ELSE        'Pass control to system for other messages
        ClientWndProc& = WinDefWindowProc(hwnd&, msg%, mp1&, mp2&)
     END SELECT
END FUNCTION
