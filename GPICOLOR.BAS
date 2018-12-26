'************************************************************************
'* 
'* Program Name: GpiColor.BAS
'*
'* Include File: GpiColor.BI
'*
'* Functions   :
'*               GpiSetBackColor
'*               GpiQueryBackColor
'*               GpiSetColor
'*               GpiQueryColor
'*               GpiCreateLogColorTable
'*               GpiRealizeColorTable     called, but no effect in OS2 1.10
'*               GpiUnrealizeColorTable   called, but no effect in OS2 1.10
'*               GpiQueryColorData
'*               GpiQueryLogColorTable
'*               GpiQueryRealColors
'*               GpiQueryNearestColor
'*               GpiQueryColorIndex
'*               GpiQueryRGBColor
'*
'* Description : This program demonstrates the functions from GpiColor.BI.
'*               By adjusting the size of the window, the image adjusts
'*               to be proportional to the window size.  The program also
'*               writes results of non-visual functions to "GpiColor.OUT".
'*
'*               The display is either a palette of color bars or a shading
'*               of 2 colors.  The user chooses between these options with
'*               the menu defined in GpiColor.RC
'*
'*               In the color bars, each bar also has a marker to show
'*               background color.  The palette can be changed by pressing
'*               a mouse button.  Button 1 will move the first color to
'*               the end and shift everything down.  Button 2 will choose
'*               random colors.
'*
'*               The shading option allows the user to display 81 shades
'*               of combinations of any two of the three primary colors.
'************************************************************************

'*********         Initialization section        ***********

REM $INCLUDE: 'PMBase.BI'
REM $INCLUDE: 'OS2Def.BI'
REM $INCLUDE: 'WinMan1.BI'
REM $INCLUDE: 'WinInput.BI'
REM $INCLUDE: 'GpiColor.BI'
REM $INCLUDE: 'GpiLine.BI'
REM $INCLUDE: 'GpiArea.BI'
REM $INCLUDE: 'GpiMark.BI'

DIM aqmsg AS QMSG

OPEN "GpiColor.Out" FOR OUTPUT AS #1

flFrameFlags&  = FCFTITLEBAR      OR FCFSYSMENU  OR _
                 FCFSIZEBORDER    OR FCFMINMAX   OR _
                 FCFSHELLPOSITION OR FCFTASKLIST OR _
                 FCFMENU

szClientClass$ = "ClassName" + CHR$(0)

hab&  = WinInitialize    (0)
hmq&  = WinCreateMsgQueue(hab&, 0)

bool% = WinRegisterClass(_
        hab&,_
        MakeLong(VARSEG(szClientClass$), SADD(szClientClass$)),_
        RegBas,_
        CSSIZEREDRAW,_
        0)

hwndFrame& = WinCreateStdWindow (_
             HWNDDESKTOP,_
             WSVISIBLE,_
             MakeLong (VARSEG(flFrameFlags&),  VARPTR(flFrameFlags&)),_
             MakeLong (VARSEG(szClientClass$), SADD  (szClientClass$)),_
             0,_
             0,_
             0,_
             1,_
             MakeLong (VARSEG(hwndClient&), VARPTR(hwndClient&)))

RANDOMIZE TIMER

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
     DIM ptl AS POINTL
     DIM alTable&(16)
     DIM alData&(2)
     ClientWndProc& = 0
     SELECT CASE msg%
     CASE WMCREATE
        hps&   = WinGetPS       (hwnd&)

        DisplayFlag% = 1           'Default display is color bars
        bool%  = GpiSetBackMix  (hps&, BMOVERPAINT) 'SetBackMix to show Background
        bool%  = GpiSetMarkerSet(hps&, LCIDDEFAULT) 'SetMarker  to show Background
        bool%  = GpiSetMarker   (hps&, MARKSYMDOT)

        '**** Test non-displaying GpiColor functions

        Result&  = GpiQueryBackColor(hps&)
        PRINT #1, "GpiQueryBackColor:", HEX$(Result&)

        Result&  = GpiQueryColor(hps&)
        PRINT #1, "GpiQueryColor:", HEX$(Result&)

        Result&  = GpiQueryLogColorTable(hps&, 0, 0, 16,_
                   MakeLong(VARSEG(alTable&(0)), VARPTR(alTable&(0))))
        PRINT #1, "GpiQueryLogColorTable:", Result&
        CALL PrintTable(alTable&())

        bool%    = GpiQueryColorData(hps&, 3,_
                   MakeLong(VARSEG(alData&(0)),VARPTR(alData&(0))))
        PRINT #1, "GpiQueryColorData:", bool%
        PRINT #1, "Color Data:"
        PRINT #1, "Format:",  HEX$(alData&(0))
        PRINT #1, "LoIndex:", HEX$(alData&(1))
        PRINT #1, "HiIndex:", HEX$(alData&(2))

        Result&  = GpiQueryRealColors(hps&, LCOLOPTREALIZED, 0, 16,_
                   MakeLong(VARSEG(alTable&(0)), VARPTR(alTable&(0))))
        PRINT #1, "GpiQueryRealColors:", Result&
        CALL PrintTable(alTable&())

        Result&  = GpiQueryNearestColor(hps&, LCOLOPTREALIZED, &HFFFF)
        PRINT #1, "GpiQueryNearestColor:", HEX$(Result&)

        Result&  = GpiQueryColorIndex(hps&, LCOLOPTREALIZED, 1)
        PRINT #1, "GpiQueryColorIndex:", Result&

        Result&  = GpiQueryRGBColor(hps&, LCOLOPTREALIZED, 4)
        PRINT #1, "GpiQueryRGBColor:", HEX$(Result&)

     CASE WMBUTTON1DOWN         'Button 1 causes palette cycle

        Result& = GpiQueryLogColorTable(hps&, 0, 0, 16,_
                  MakeLong(VARSEG(alTable&(0)), VARPTR(alTable&(0))))
        alTable&(16) = alTable&(0)
        bool% = GpiCreateLogColorTable(hps&, LCOLREALIZABLE,_
                LCOLFCONSECRGB, 0, 16,_
                MakeLong(VARSEG(alTable&(1)), VARPTR(alTable&(1))))

        '*** RealizeColorTable should physically change palette, but it has
        bool%    = GpiRealizeColorTable(hps&)        'no effect in OS/2 1.1
        PRINT #1, "GpiRealizeColorTable:", bool%

        ClientWndProc& = WinDefWindowProc(hwnd&, msg%, mp1&, mp2&)
        bool% = WinSendMsg(hwnd&, WMPAINT, 0, 0)

     CASE WMBUTTON2DOWN         'Button 2 sets a random palette

        FOR i% = 0 TO 15
           alTable&(i%) =  RND * &HFFFFFF
        NEXT i%
        bool% = GpiCreateLogColorTable(hps&,LCOLREALIZABLE,_
                LCOLFCONSECRGB, 0, 16,_
                MakeLong(VARSEG(alTable&(0)), VARPTR(alTable&(0))))
        ClientWndProc& = WinDefWindowProc(hwnd&, msg%, mp1&, mp2&)
        bool% = WinSendMsg(hwnd&, WMPAINT, 0, 0)

     CASE WMCOMMAND          'Menu items to choose color bars or shading
        CALL BreakLong(mp1&, hiword%, DisplayFlag%)
        bool% = WinSendMsg(hwnd&, WMPAINT, 0, 0)
     CASE WMPAINT            'Paint draws color bars and markers or shading
        bool% = WinInvalidateRect(hwnd&, 0, 0)

        hps2& = WinBeginPaint(hwnd&, 0,_
                MakeLong(VARSEG(ClientRect), VARPTR(ClientRect)))
        bool% = WinFillRect(hps&,_
                MakeLong(VARSEG(ClientRect), VARPTR(ClientRect)),0)

        IF DisplayFlag% = 1 THEN
           'draw color bars
           ptl.x  = 0
           delta& = ClientRect.xRight / 16
           FOR c% = 0 TO 15
              ptl.y = 0
              bool% = GpiMove(hps&, MakeLong(VARSEG(ptl), VARPTR(ptl)))
              bool% = GpiSetColor (hps&, c%)
              ptl.y = ClientRect.yTop
              ptl.x = ptl.x + delta&
              bool% = GpiBox(hps&, DROFILL,_
                      MakeLong(VARSEG(ptl), VARPTR(ptl)), 0, 0)
           NEXT c%

           'draw markers
           ptl.x  = ClientRect.xRight / 32
           ptl.y  = ClientRect.yTop / 2
           FOR c% = 0 TO 15
              bool% = GpiSetColor (hps&, c%)
              bool% = GpiSetBackColor (hps&, 15 - c%)
              bool% = GpiMarker(hps&, MakeLong(VARSEG(ptl), VARPTR(ptl)))
              ptl.x = ptl.x + delta&
           NEXT c%
        ELSE
           SELECT CASE DisplayFlag%
              CASE 2
                 xFactor& = &H10
                 yFactor& = &H1000
              CASE 3
                 xFactor& = &H1000
                 yFactor& = &H100000
              CASE 4
                 xFactor& = &H100000
                 yFactor& = &H10
              CASE ELSE
           END SELECT

           deltaY& = ClientRect.yTop / 16
           deltaX& = ClientRect.xRight / 16
           ptl.x  = 0

           FOR dx% = 0 TO 15
              FOR dy% = 0 TO 15
              Clr& = dx% * xFactor& + dy% * yFactor&
              bool% = GpiCreateLogColorTable(hps&,LCOLREALIZABLE,_
                      LCOLFCONSECRGB,1,1,_
                      MakeLong(VARSEG(Clr&), VARPTR(Clr&)))
              ptl.x = dx% * deltaX&
              ptl.y = dy% * deltaY&
              bool% = GpiMove(hps&, MakeLong(VARSEG(ptl), VARPTR(ptl)))
              bool% = GpiSetColor (hps&, 1)
              ptl.y = ptl.y + deltaY&
              ptl.x = ptl.x + deltaX&
              bool% = GpiBox(hps&, DROFILL,_
                      MakeLong(VARSEG(ptl), VARPTR(ptl)), 0, 0)
              NEXT dy%
           NEXT dx%
        END IF

        bool% = WinEndPaint(hps2&)

     CASE WMCLOSE

        '*** UnrealizeColorTable should set palette back to default, but has
        bool%    = GpiUnrealizeColorTable(hps&)       'no effect in OS/2 1.1
        PRINT #1, "GpiUnrealizeColorTable:", bool%
        ClientWndProc& = WinDefWindowProc(hwnd&, msg%, mp1&, mp2&)

     CASE ELSE        'Pass control to system for other messages
        ClientWndProc& = WinDefWindowProc(hwnd&, msg%, mp1&, mp2&)
     END SELECT
END FUNCTION


SUB PrintTable(alTable&())
   PRINT #1, "Color Table:"
   FOR i% = 0 TO 15
      PRINT #1, "", i%, HEX$(alTable&(i%))
   NEXT i%
END SUB
