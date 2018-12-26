'*******************************************************************
'* 
'* Program Name: WinClip.BAS
'*
'* Include File: WinClip.BI
'*
'* Functions   :
'*               WinOpenClipbrd
'*               WinSetClipbrdOwner
'*               WinQueryClipbrdOwner
'*               WinSetClipbrdViewer
'*               WinQueryClipbrdViewer
'*               WinSetClipbrdData
'*               WinQueryClipbrdData
'*               WinQueryClipbrdFmtInfo
'*               WinEmptyClipbrd
'*               WinEnumClipbrdFmts
'*               WinCloseClipbrd
'*
'* Description : This program demonstrates the clipboard functions.
'*               Each function is used in the section before the
'*               message loop and the resulting info is written
'*               to WinClip.OUT. In ClientWndProc, the clipboard
'*               is monitored. Using this with a PM text or graphics
'*               editor (such as NotePad or PMDraw), you can see
'*               the clipboard change.
'******************************************************************

'*********         Initialization section        ***********

REM $INCLUDE: 'PMBase.BI'
REM $INCLUDE: 'WinClip.BI'
REM $INCLUDE: 'OS2Def.BI'      Needed for POINTL type
REM $INCLUDE: 'WinMan1.BI'     Needed for WinGet/ReleasePS, WinDrawText
REM $INCLUDE: 'WinMan2.BI'     Needed for WinValidateRect
REM $INCLUDE: 'WinPoint.BI'    Needed for WinGetSysBitmap
REM $INCLUDE: 'GpiColor.BI'    Needed for color constants

COMMON SHARED /handles/ hab&
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

'**************   Clipboard Calls   ***************

OPEN "WinClip.OUT" FOR OUTPUT AS #1

bool% = WinOpenClipbrd (hab&)

  'Query before and after SetOwner

  before& = WinQueryClipbrdOwner (hab&, 0)
  bool%   = WinSetClipbrdOwner   (hab&, hwndClient&)
  after&  = WinQueryClipbrdOwner (hab&, 0)
  PRINT #1, "Owner before: ";HEX$(before&),"...after: ";HEX$(after&)

  'Query before and after SetViewer

  before& = WinQueryClipbrdViewer (hab&, 0)
  bool%   = WinSetClipbrdViewer   (hab&, hwndClient&)
  after&  = WinQueryClipbrdViewer (hab&, 0)
  PRINT #1, "Viewer before: ";HEX$(before&),"...after: ";HEX$(after&)

  'Put bitmap in clipboard

  hbmp& = WinGetSysBitmap   (HWNDDESKTOP, SBMPCHECKBOXES)
  bool% = WinSetClipbrdData (hab&, 0, CFBITMAP, CFIHANDLE)
  bool% = WinSetClipbrdData (hab&, hbmp&, CFBITMAP, CFIHANDLE)

  'Check format of bitmap in clipboard

  bool%   = WinQueryClipbrdFmtInfo (hab&, CFBITMAP,_
            MakeLong(VARSEG(format&), VARPTR(format&)))
  hcheck& = WinQueryClipbrdData    (hab&, CFBITMAP)
  PRINT #1, "Clipboard data:"
  PRINT #1, "Format: ",HEX$(format&)
  PRINT #1, "Handle:",HEX$(hcheck&)

  'Add another item to the clipboard (for enumeration)

  theString$ = "This is the clipboard data." + CHR$(0)
  bool% = WinSetClipbrdData (hab&, 0, CFTEXT, CFISELECTOR)
  bool% = WinSetClipbrdData (hab&,_
          MakeLong(VARSEG(theString$), SADD(theString$)),_
          CFTEXT, CFISELECTOR)

  'loop through formats in clipboard (should be 2)

  PRINT #1, "Two items added to be enumerated."
  enum% = 0
  DO
    enum% = WinEnumClipbrdFmts (hab&, enum%)
    PRINT #1, "Enumerate: ",enum%
  LOOP UNTIL enum% = 0

  'Empty clipboard and check to see if data is there

  bool%  = WinEmptyClipbrd     (hab&)
  nullh& = WinQueryClipbrdData (hab&, CFBITMAP)
  PRINT #1, "Handle of data after Empty (should be NULL)",HEX$(nullh&)

bool% = WinCloseClipbrd (hab&)
CLOSE #1

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

'****
'** The WMDRAWCLIPBOARD case monitors text and bitmap clipboard changes.
'** The contents are centered in the window. This code is taken from
'** OS/2 Programmer's Reference Volume 1, page 338.

FUNCTION ClientWndProc& (hwnd&, msg%, mp1&, mp2&) STATIC
     DIM ClientRect AS RECTL
     DIM ptlDest AS POINTL
     ClientWndProc& = 0
     SELECT CASE msg%
     CASE WMDRAWCLIPBOARD          'Monitor clipboard changes
        bool%    = WinOpenClipbrd      (hab&)
        hText&   = WinQueryClipbrdData (hab&, CFTEXT)
        hBitmap& = WinQueryClipbrdData (hab&, CFBITMAP)
        IF hText& THEN       ' If handle is valid, center it in window

          'Change text handle to pointer
          CALL BreakLong (hText&, nothing%, selector%)
          pszText& = MakeLong(selector%, 0)

          'Center string
          hps&  = WinGetPS           (hwnd&)
          bool% = WinQueryWindowRect (hwnd&,_
                  MakeLong(VARSEG(ClientRect), VARPTR(ClientRect)))
          bool% = WinDrawText        (hps&, &HFFFF, pszText&,_
                  MakeLong(VARSEG(ClientRect), VARPTR(ClientRect)),_
                  CLRBLACK, CLRWHITE,_
                  DTCENTER OR DTVCENTER OR DTERASERECT)
          bool% = WinValidateRect    (hwnd&, 0, 0)
          bool% = WinReleasePS       (hps&)

        ELSEIF hBitmap& THEN
          ptlDest.x = 0 : ptlDest.y = 0
          hps&  = WinGetPS           (hwnd&)
          bool% = WinQueryWindowRect (hwnd&,_
                  MakeLong(VARSEG(ClientRect), VARPTR(ClientRect)))
          bool% = WinFillRect        (hps&,_
                  MakeLong(VARSEG(ClientRect), VARPTR(ClientRect)),CLRWHITE)
          bool% = WinDrawBitmap(hps&, hBitmap&, 0,_
                  MakeLong(VARSEG(ptlDest), VARPTR(ptlDest)),_
                  CLRBLACK, CLRWHITE, DBMNORMAL)
          bool% = WinValidateRect    (hwnd&, 0, 0)
          bool% = WinReleasePS       (hps&)
        END IF
        bool% = WinCloseClipbrd (hab&)

     CASE WMPAINT     'Paint the window with background color
        hps&  = WinBeginPaint(hwnd&, 0,_
                MakeLong(VARSEG(ClientRect), VARPTR(ClientRect)))
        bool% = WinFillRect(hps&,_
                MakeLong(VARSEG(ClientRect), VARPTR(ClientRect)),0)
        bool% = WinEndPaint(hps&)
     CASE ELSE        'Pass control to system for other messages
        ClientWndProc& = WinDefWindowProc(hwnd&, msg%, mp1&, mp2&)
     END SELECT
END FUNCTION
