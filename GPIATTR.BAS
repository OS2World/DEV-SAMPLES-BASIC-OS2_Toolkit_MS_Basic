'***********************************************************
'*
'* Program Name: GpiAttr.BAS
'*
'* Include File: GpiAttr.BI
'*
'* Functions   : GpiSetAttrMode
'*               GpiQueryAttrMode
'*               GpiSetAttrs
'*               GpiQueryAttrs
'*               GpiPop
'*
'* Description : This program demonstrates how to set and query
'*               attributes and attribute modes. This can be done
'*               for a variety of elements, but this uses the
'*               image element.
'*
'* NOTE:         To use an attribute mode of AMPRESERVE (necessary
'*               for GpiPop), you must first create a presentation
'*               space (with GpiCreatePS instead of the microPS
'*               aquired with WinGetPS and WinBeginPaint).
'***********************************************************

'*********         Initialization section        ***********

REM $INCLUDE: 'PMBase.BI'
REM $INCLUDE: 'GpiCont.BI'      Needed for GpiCreatePS
REM $INCLUDE: 'GpiLine.BI'      Needed for SIZEF type
REM $INCLUDE: 'GpiAttr.BI'

COMMON SHARED /Handle/ hab&         'Global anchor block for GpiCreatePS

OPEN "GpiAttr.OUT" FOR OUTPUT AS #1

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

'**************         Message loop         ***************

WHILE WinGetMsg(hab&, MakeLong(VARSEG(aqmsg), VARPTR(aqmsg)), 0, 0, 0)
  bool% = WinDispatchMsg(hab&, MakeLong(VARSEG(aqmsg), VARPTR(aqmsg)))
WEND

'***********         Finalize section        ***************

bool% = WinDestroyWindow  (hwndFrame&)
bool% = WinDestroyMsgQueue(hmq&)
bool% = WinTerminate      (hab&)

CLOSE #1

END

'***********         Window procedure        ***************

FUNCTION ClientWndProc& (hwnd&, msg%, mp1&, mp2&) STATIC
     DIM ClientRect AS RECTL
     ClientWndProc& = 0
     SELECT CASE msg%
       CASE WMCREATE
         CALL DemonstrateGPIATTRroutines
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

SUB DemonstrateGPIATTRroutines
DIM ibmd AS IMAGEBUNDLE
   'Define size of presentation space for GpiCreatePS
   DIM szl AS SIZEL
   szl.cx = 640 : szl.cy = 480

   'Create a presentation space because AMPRESERVE mode can not be
   'used with micro presentation spaces.
   hps& = GpiCreatePS(hab&, 0,_
          MakeLong(VARSEG(szl), VARPTR(szl)), PUPELS)

'*
'* Set Attribute mode. AMPRESERVE cause current attributes to
'* be pushed onto stack before changing the attribute values
'*
  bool% = GpiSetAttrMode  (hps&, AMPRESERVE)
  PRINT #1, "GpiSetAttrMode:",  bool%
  attr& = GpiQueryAttrMode(hps&)
  PRINT #1,"GpiQueryAttrMode:", attr&

'*
'* Get current IMAGE attributes for Foreground and Background colors
'*
  attrm& = GpiQueryAttrs(hps&,_
           PRIMIMAGE, IBBCOLOR OR IBBBACKCOLOR,_
           MakeLong(VARSEG(ibmd), VARPTR(ibmd)))
  PRINT #1,"Initial values"
  PRINT #1,"Image Attributes: IBBCOLOR =     ";ibmd.LColor
  PRINT #1,"                  IBBBACKCOLOR = ";ibmd.LBackColor

'*
'* Set Attributes for IMAGE primitive.  The same routine, GpiSetAttrs
'* is used for all 5 Gpi primitives, the only difference is the
'* second parameter which specifies the Gpi primitive, and the values
'* allowed in the 3rd and 4th parameters which specify the values to
'* be set.
'*
  ibmd.LColor     = 10
  ibmd.LBackColor = 11
  bool%  = GpiSetAttrs  (hps&, PRIMIMAGE,_
           IBBCOLOR OR IBBBACKCOLOR, IBBMIXMODE OR IBBBACKMIXMODE,_
           MakeLong(VARSEG(ibmd), VARPTR(ibmd)))
  attrm& = GpiQueryAttrs(hps&, PRIMIMAGE,_
           IBBCOLOR OR IBBBACKCOLOR,_
           MakeLong(VARSEG(ibmd), VARPTR(ibmd)))
  PRINT #1,"After GpiSetAttrs"
  PRINT #1,"Image Attributes: IBBCOLOR =     ";ibmd.LColor
  PRINT #1,"                  IBBBACKCOLOR = ";ibmd.LBackColor

'*
'* Restore original IMAGE attributes
'*
  bool%  = GpiPop       (hps&, 2)
  attrm& = GpiQueryAttrs(hps&, PRIMIMAGE,_
           IBBCOLOR OR IBBBACKCOLOR,_
           MakeLong(VARSEG(ibmd), VARPTR(ibmd)))
  PRINT #1,"After GpiPop"
  PRINT #1,"Image Attributes: IBBCOLOR =     ";ibmd.LColor
  PRINT #1,"                  IBBBACKCOLOR = ";ibmd.LBackColor

END SUB
