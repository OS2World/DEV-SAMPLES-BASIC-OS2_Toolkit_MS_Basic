'**************************************************************************
'*
'* Program Name: GpiBit.BAS
'*
'* Include File: GpiBit.BI
'*
'* Functions   : GpiLoadBitmap
'*               GpiDeleteBitmap
'*               GpiSetBitmap
'*               GpiBitBlt
'*               GpiWCBitBlt
'*               GpiCreateBitmap
'*               GpiQueryDeviceBitmapFormats
'*               GpiQueryBitmapParameters
'*               GpiQueryBitmapBits
'*               GpiSetBitmapBits
'*               GpiSetPel
'*               GpiQueryPel
'*               GpiSetBitmapID
'*               GpiQueryBitmapHandle
'*               GpiImage
'*
'*  Description: This program demonstrates all functions in GpiBit.BI
'*               except for GpiSetBitmapBits and GpiQueryBitmapBits.
'*               These routines are demonstrated in the demo program
'*               Capture.BAS.  Return values from functions that do not
'*               have a visual affect, are written out to the file
'*               GpiBit.OUT.
'*
'*               The program sequence is as follows:
'*
'*               - An 8x8 bitmap is loaded from the programs resource
'*                 and used as a fill pattern to fill the entire window.
'*               - A 99x99 bitmap is then loaded from the programs resource
'*                 and displayed in the lower left hand corner of the
'*                 Client window, actual size.
'*               - It is then copied and magnified to the upper left hand
'*                 quarter of the Client Window.
'*               - The image data at the end of the module level code is
'*                 then read in to an array which is used to display
'*                 10 copies of the image (a cat) at random locations
'*                 in the upper right hand quarter of the Client window.
'*               - 1000 random pixels in the lower right hand quarter of
'*                 the Client window are then set to the color Blue.
'*               - A bitmap is then created in a presentation space
'*                 associated with a memory device context, consisting
'*                 of the entire contents of the Client window.
'*               - This bitmap is then copied to the lower right hand
'*                 quarter of the Client window.
'*
'***************************************************************************

'*********         Initialization section        ***********

REM $INCLUDE: 'OS2Def.BI'
REM $INCLUDE: 'PMBase.BI'
REM $INCLUDE: 'WinMsgs.BI'
REM $INCLUDE: 'GpiCont.BI'
REM $INCLUDE: 'GpiArea.BI'
REM $INCLUDE: 'GpiColor.BI'
REM $INCLUDE: 'GpiBit.BI'
DECLARE FUNCTION GpiMove% (BYVAL HPS AS LONG, BYVAL PPOINTL AS LONG)
DECLARE FUNCTION GpiBox& (BYVAL HPS AS LONG, BYVAL along AS LONG, BYVAL PPOINTL AS LONG, BYVAL blong AS LONG, BYVAL CLONG AS LONG)
DECLARE FUNCTION DevOpenDC& (BYVAL HAB AS LONG, BYVAL along AS LONG, BYVAL PSZ AS LONG, BYVAL blong AS LONG, BYVAL PDEVOPENDATA AS LONG, BYVAL HDC AS LONG)
DECLARE FUNCTION DevCloseDC& (BYVAL HDC AS LONG)

DECLARE SUB ScreenPaint (hwnd&)
DECLARE FUNCTION DosAllocSeg%( _
        BYVAL P1 AS INTEGER,_
        BYVAL P2 AS LONG,_
        BYVAL P3 AS INTEGER)

CONST IDBITMAP1 = 1
CONST IDBITMAP2 = 2
CONST ODMEMORY = 8&

TYPE BitMapFormats
  Planes AS LONG
  BitCount AS LONG
END TYPE

TYPE MyBITMAPINFO
    cbFix AS LONG
    cx AS INTEGER
    cy AS INTEGER
    cPlanes AS INTEGER
    cBitCount AS INTEGER
    argbColor AS STRING * 48
END TYPE


DIM aqmsg AS QMSG

OPEN "GpiBit.OUT" FOR OUTPUT AS #1

flFrameFlags& =  FCFTITLEBAR      OR FCFSYSMENU  OR_
                 FCFSIZEBORDER    OR FCFMINMAX   OR_
                 FCFSHELLPOSITION OR FCFTASKLIST

szClientClass$ = "ClassName" + CHR$(0)

hab&  = WinInitialize(0)
hmq&  = WinCreateMsgQueue(hab&, 0)

retn% = WinRegisterClass(_
        hab&,_
        MakeLong(VARSEG(szClientClass$), SADD(szClientClass$)),_
        RegBas,_
        CSSIZEREDRAW,_
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

retn% = WinDestroyWindow(hwndFrame&)
retn% = WinDestroyMsgQueue(hmq&)
retn% = WinTerminate(hab&)
CLOSE #1

END

'***********         Window procedure        ***************

FUNCTION ClientWndProc& (hwnd&, msg%, mp1&, mp2&) STATIC
SHARED cxClient%, cyClient%

  ClientWndProc& = 0
  SELECT CASE msg%
  '*
  '* Get current size of Client Window
  '*
    CASE WMSIZE
      CALL BreakLong(mp2&, cyClient%, cxClient%)

    CASE WMPAINT
      CALL ScreenPaint(hwnd&)

    CASE ELSE
      ClientWndProc& = WinDefWindowProc(hwnd&, msg%, mp1&, mp2&)

  END SELECT

END FUNCTION

'*
'* Data to be used by GpiImage.  Below data will display a small cat.
'*
'* Taken from "Programming the OS/2 Presentation Manager" by Charles Petzold
'*
DATA &H01, &HF8, &H1F, &H80, &H01, &H04, &H20, &H80
DATA &H00, &H8F, &HF1, &H00, &H00, &H48, &H12, &H00
DATA &H00, &H28, &H14, &H00, &H00, &H1A, &H58, &H00
DATA &H00, &H08, &H10, &H00, &H00, &HFC, &H3F, &H00
DATA &H00, &H09, &H90, &H00, &H00, &HFC, &H3F, &H00
DATA &H00, &H08, &H10, &H00, &H00, &H07, &HE0, &H00
DATA &H00, &H08, &H10, &H00, &H00, &H08, &H10, &HC0
DATA &H00, &H08, &H10, &H20, &H00, &H10, &H08, &H10
DATA &H00, &H10, &H08, &H08, &H00, &H10, &H08, &H04
DATA &H00, &H20, &H04, &H04, &H00, &H20, &H04, &H04
DATA &H00, &H20, &H04, &H04, &H00, &H40, &H02, &H04
DATA &H00, &H40, &H02, &H04, &H00, &H40, &H02, &H04
DATA &H00, &HC0, &H03, &H04, &H00, &H9C, &H39, &H08
DATA &H00, &HA2, &H45, &H08, &H00, &HA2, &H45, &H10
DATA &H00, &HA2, &H45, &HE0, &H00, &HA2, &H45, &H00
DATA &H00, &HA2, &H45, &H00, &H00, &HFF, &HFF, &H00

'************************************************************************
'*
'* SUBprogram ScreenPaint:  Called from ClientWndProc& when a WMPAINT
'*                          message is received.
'*
SUB ScreenPaint(hwnd&)
SHARED cxClient%, cyClient%, hab&
DIM aptl(3)       AS POINTL
DIM rect          AS RECTL
DIM sizl          AS SIZEL
DIM bi            AS BITMAPINFOHEADER
DIM bihdr         AS BITMAPINFOHEADER
DIM fmts(1)       AS BitMapFormats
DIM catimage(128) AS STRING * 1

  hps&  = WinBeginPaint(hwnd&, 0, 0)
  bool% = GpiErase     (hps&)
'*
'* Load an 8x8 bitmap to used to be used as a fill pattern.  GpiBox
'* is used to fill the Client window with the fill pattern.  The
'* bitmap is loaded, the bitmap is set to ID 254, the pattern set
'* is set to ID 254 which is the bitmap, then the current fill pattern
'* is set using GpiSetPattern, using ID 254, the bitmap.  After the
'* screen is filled, the bitmap handle is released.
'*
  aptl(0).x = 0
  aptl(0).y = 0
  aptl(1).x = cxClient%
  aptl(1).y = cyClient%
  bool% = GpiSetColor     (hps&, CLRRED)
  hbm&  = GpiLoadBitmap   (hps&, 0, IDBITMAP2, 0, 0)
  bool% = GpiSetBitmapId  (hps&, hbm&, 254)
  bool% = GpiSetPatternSet(hps&, 254)
  bool% = GpiSetPattern   (hps&, 254)
  bool% = GpiMove         (hps&, MakeLong(VARSEG(aptl(0)), VARPTR(aptl(0))))
  bool% = GpiBox          (hps&, DROOUTLINEFILL,_
          MakeLong(VARSEG(aptl(1)), VARPTR(aptl(1))), 0, 0)
  bool% = GpiDeleteBitmap (hbm&)
  bool% = GpiSetColor     (hps&, CLRBLACK)
'*
'* Get handle of bitmap set to ID of 254 in above GpiSetBitmapID
'*
  Bhandle& = GpiQueryBitmapHandle(hps&, 254)
  PRINT #1, "GpiQueryBitmapHandle:", HEX$(Bhandle&)
'*
'* Load bitmap from resource
'*
  hbm& = GpiLoadBitmap(hps&, 0, IDBITMAP1, 0, 0)

  aptl(0).x = 0              'lower left corner of target
  aptl(0).y = 0
  aptl(1).x = 98             'upper right corner of target
  aptl(1).y = 98
  aptl(2).x = 1              'lower left corner of source
  aptl(2).y = 1
  aptl(3).x = 99             'upper right corner of source
  aptl(3).y = 99
'*
'* Draws bitmap in lower left of Client window, actual size
'*
  bool% = GpiWCBitBlt(hps&, hbm&, 3,_
          MakeLong(VARSEG(aptl(0)), VARPTR(aptl(0))),_
          ROPSRCCOPY, BBOAND)
'*
'* Copy bitmap from current location, and stretch bitmap to fill
'* top half of Client window
'*
  aptl(0).x = 0              'lower left corner of target
  aptl(0).y = cyClient% / 2
  aptl(1).x = cxClient% / 2  'upper right corner of target
  aptl(1).y = cyClient%
  aptl(2).x = 0              'lower left corner of source
  aptl(2).y = 0
  aptl(3).x = 98             'upper right corner of source
  aptl(3).y = 98
  bool% = GpiBitBlt(hps&, hps&, 4,_
          MakeLong(VARSEG(aptl(0)), VARPTR(aptl(0))),_
          ROPSRCCOPY, BBOAND)
  bool% = GpiDeleteBitmap(hbm&)
'*
'* The Image DATA at the module level is read into the array CATIMAGE
'* and then GpiImage is used to display the image defined by the DATA.
'* 10 cat images are displayed at random positions in the upper right
'* hand corner of the Client Window
'*
  FOR I% = 1 TO 128
    READ byte%
    catimage(I%) = CHR$(byte%)
  NEXT
  RESTORE
  aptl(0).x = 32
  aptl(0).y = 32
  FOR I% = 1 TO 10
    xlowerbound% = cxClient% / 2
    xupperbound% = cxClient% - 32
    ylowerbound% = cyClient% / 2 + 32
    yupperbound% = cyClient%

    aptl(1).x = INT ((xupperbound% - xlowerbound% + 1) * RND + xlowerbound%)
    aptl(1).y = INT ((yupperbound% - ylowerbound% + 1) * RND + ylowerbound%)

    bool% = GpiMove (hps&, MakeLong(VARSEG(aptl(1)), VARPTR(aptl(1))))
    bool% = GpiImage(hps&, 0,_
            MakeLong(VARSEG(aptl(0)),     VARPTR(aptl(0))), 128,_
            MakeLong(VARSEG(catimage(1)), VARPTR(catimage(1))))
  NEXT I%
'*
'* Set 1000 random pixels in the lower right corner of the Client window
'* to the color Blue.  The pixels set will appear blue and purple since
'* blue pixels next to red pixels appear purple.
'*
  rect.xLeft   = cxClient% \ 2
  rect.xRight  = cxClient%
  rect.yTop    = cyClient% \ 2
  rect.yBottom = 0
  bool% = WinFillRect(hps&, MakeLong(VARSEG(rect), VARPTR(rect)), 0)
  bool% = GpiSetColor(hps&, CLRBLUE)

  FOR I% = 1 TO 1000
    xlowerbound% = rect.xLeft
    xupperbound% = rect.xRight
    ylowerbound% = rect.yBottom
    yupperbound% = rect.yTop

    aptl(0).x = INT ((xupperbound% - xlowerbound% + 1) * RND + xlowerbound%)
    aptl(0).y = INT ((yupperbound% - ylowerbound% + 1) * RND + ylowerbound%)

    bool% = GpiSetPel(hps&, MakeLong(VARSEG(aptl(0)), VARPTR(aptl(0))))
  NEXT I%
'*
'* Obtain color of last pixel set by GpiSetPel above, which should be Blue (1)
'*
  pixelcolor& = GpiQueryPel(hps&, MakeLong(VARSEG(aptl(0)), VARPTR(aptl(0))))
  PRINT #1,"GpiQueryPel: (";aptl(0).x;",";aptl(0).y;") is color";pixelcolor&
'*
'* Initialize bitmap info to be used in GpiCreateBitmap
'*
  bi.cbFix     = LEN(bi)
  bi.cx        = cxClient%
  bi.cy        = cyClient%
  bi.cPlanes   = 1
  bi.cBitCount = 4
'*
'* Initialize info to be used in DevOpenDC
'*
  token$  = "*" + CHR$(0)
  sizl.cx = bi.cx
  sizl.cy = bi.cy
'*
'* Create a Device Context and and a Micro Presentation space,
'* associate the presentation space with the Device Context,
'* Create a bitmap using the bitmap info initialized above,
'* associate the bitmap with the memory presentation space.
'*
  hdc&  = DevOpenDC      (hab&, ODMEMORY,_
          MakeLong(VARSEG(token$), SADD(token$)), 0, 0, 0)
  hps2& = GpiCreatePS    (hab&, hdc&,_
          MakeLong(VARSEG(sizl), VARPTR(sizl)),_
          PUPELS OR GPIFDEFAULT OR GPITMICRO OR GPIAASSOC)
  hbm&  = GpiCreateBitmap(hps2&,_
          MakeLong(VARSEG(bi), VARPTR(bi)), 0, 0, 0)
  bool% = GpiSetBitmap   (hps2&, hbm&)
'*
'* Copy Entire contents of Client window to bitmap created above
'*
  aptl(0).x = 0
  aptl(0).y = 0
  aptl(1).x = cxClient%
  aptl(1).y = cyClient%
  aptl(2).x = 0
  aptl(2).y = 0
  aptl(3).x = cxClient%
  aptl(3).y = cyClient%
  bool% = GpiBitBlt(hps2&, hps&, 4,_
          MakeLong(VARSEG(aptl(0)), VARPTR(aptl(0))),_
          ROPSRCCOPY, BBOAND)
'*
'* Copy bitmap created above, which is the current Client Window
'* display, to the lower right hand quarter of the Client Window.
'* Change the last parameter in GpiBitBlt for varying results when
'* the bitmap is compressed: BBOIGNORE, BBOAND, and BBOOR.
'*
  aptl(0).x = cxClient% / 2
  aptl(0).y = 0
  aptl(1).x = cxClient%
  aptl(1).y = cyClient% / 2
  aptl(2).x = 0
  aptl(2).y = 0
  aptl(3).x = bi.cx
  aptl(3).y = bi.cy
  bool% = GpiBitBlt(hps&, hps2&, 4,_
          MakeLong(VARSEG(aptl(0)), VARPTR(aptl(0))),_
          ROPSRCCOPY, BBOIGNORE)

'*
'* The following routines have now visual effect so their return
'* values are written out to GpiBit.OUT
'*
  bool% = GpiQueryBitmapParameters(hbm&, MakeLong(VARSEG(bihdr), VARPTR(bihdr)))
  PRINT #1,"GpiQueryBitmapParameters:  cbFix = ";bihdr.cbFix
  PRINT #1,"                              cx = ";bihdr.cx
  PRINT #1,"                              cy = ";bihdr.cy
  PRINT #1,"                         cPlanes = ";bihdr.cPlanes
  PRINT #1,"                       cBitCount = ";bihdr.cBitCount

  bool% = GpiQueryDeviceBitmapFormats(hps&, 2,_
          MakeLong(VARSEG(fmts(0)), VARPTR(fmts(0))))
  PRINT #1,"GpiQueryDeviceBitmapFormats: Format #1-> Planes = ";fmts(0).Planes
  PRINT #1,"                                       BitCount = ";fmts(0).BItcount
  PRINT #1,"                             Format #2-> Planes = ";fmts(1).Planes
  PRINT #1,"                                       BitCount = ";fmts(1).BItcount

  aptl(0).x = 100
  aptl(0).y = 100
  bool% = GpiSetBitmapDimension  (hbm&,_
          MakeLong(VARSEG(aptl(0)), VARPTR(aptl(0))))
  bool% = GpiQueryBitmapDimension(hbm&,_
          MakeLong(VARSEG(aptl(1)), VARPTR(aptl(1))))
  PRINT #1,"GpiQueryBitmapDimension: (";aptl(1).x;",";aptl(1).y;")"

'*
'* Release all handles
'*
    bool% = GpiDeleteBitmap(hbm&)
    bool% = GpiDestroyPS   (hps2&)
    bool% = DevCloseDC     (hdc&)

    bool% = WinEndPaint    (hps&)

END SUB
