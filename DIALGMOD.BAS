REM $INCLUDE: 'os2def.bi'
REM $INCLUDE: 'pmbase.bi'
REM $INCLUDE: 'opendlg.bi'
REM $INCLUDE: 'winmisc.bi'
REM $INCLUDE: 'wintrack.bi'
REM $INCLUDE: 'gpibit.bi'

REM $INCLUDE: 'CAPTURE.INC'

'|***************************************************************************
'|
'| DIALGMOD.BAS:  Support module of CAPTURE.BAS
'|
'|***************************************************************************
'| This FUNCTION controls the dialog box used by "SetFrameWindowSize"
'|***************************************************************************
FUNCTION ClientWndProc1& (hwnd&, msg%, mp1&, mp2&)
SHARED hwndFrame&, cxScreen%, cyScreen%, newXFrame%, newYFrame%, minFrame%
DIM rect AS RECTL
  SELECT CASE msg%
    CASE WMINITDLG
    '|
    '| Initialize dialogbox items
    '|
    '| Get current frame window size
    '|
      bool% = WinQueryWindowRect(hwndFrame&,_
                                 MakeLong(VARSEG(rect), VARPTR(rect)))
      newXFrame% = rect.xright
      newYFrame% = rect.ytop
    '|
    '| Initialize entryfields for Frame width and height
    '|
      bool% = WinSetDlgItemShort(hwnd&,_
                                 XENTRYFIELD,_
                                 newXFrame%,_
                                 1)
      bool% = WinSetDlgItemShort(hwnd&,_
                                 YENTRYFIELD,_
                                 newYFrame%,_
                                 1)
    '|
    '| Initialize horizontal and vertical scroll bars to range and initial
    '| position
    '|                           
      bool& = WinSendDlgItemMsg(hwnd&, XSCROLLBAR,_
                                SBMSETSCROLLBAR,_
                                MakeLong(0, newXFrame%),_
                                MakeLong(cxScreen%, minFrame%))
      bool& = WinSendDlgItemMsg(hwnd&, YSCROLLBAR,_
                                SBMSETSCROLLBAR,_
                                MakeLong(0, newYFrame%),_
                                MakeLong(cyScreen%, minFrame%))
    CASE WMCOMMAND
    '|
    '| A dialog box pushbutton was selected
    '|
      CALL BreakLong(mp1&, dummy%, controlSelection%)
      IF controlSelection% <> OKBUTTON THEN
      '|
      '| If button selected was not the OK button, dismiss the dialog box
      '| and return the ID of the button selected to CALLing routine
      '|
        bool% = WinDismissDlg(hwnd&, controlSelection%)
      ELSE
      '|
      '| Obtain entryfield values for frame window width and height
      '|
        xbool% = WinQueryDlgItemShort(_
                          hwnd&,_
                          XENTRYFIELD,_
                          MakeLong(VARSEG(newXFrame%), VARPTR(newXFrame%)),_
                          1)
        ybool% = WinQueryDlgItemShort(_
                          hwnd&,_
                          YENTRYFIELD,_
                          MakeLong(VARSEG(newYFrame%), VARPTR(newYFrame%)),_
                          1)
      '|
      '| Determine if width and height values are valid.  If not display
      '| message to prompt user, and give valid range for both width and height
      '|                  
        IF (xbool% = 0 OR ybool% = 0) OR_
           (newXFrame% < minFrame% OR newXFrame% > cxScreen%) OR_
           (newYFrame% < minFrame% OR newYFrame% > cyScreen%) THEN
             message$ = "Ivalid value or, Width or Heigth is out of "+_
                        "range.  Values must be within the following ranges:"+_
                        CHR$(13)+CHR$(10)+"Width:" + STR$(minFrame%)+_
                        " to"+STR$(cxScreen%)+_
                        CHR$(13)+CHR$(10)+"Height:" + STR$(minFrame%)+_
                        " to"+STR$(cyScreen%)+CHR$(0)
             caption$ = CHR$(0)
             bool% = DisplayMessageBox%(message$, caption$, 2)
        ELSE
        '|
        '| If values for frame window width and height are valid, dismiss
        '| dialog box and return ID of button selected to CALLing routine
        '|
          bool% = WinDismissDlg(hwnd&, controlSelection%)
        END IF
      END IF
      ClientWndProc1& = 0
  '|
  '| Control horizontal (Width) scroll bar
  '|
    CASE WMHSCROLL
      CALL BreakLong(mp2&, hcommand%, lowword%)
      SELECT CASE hcommand%
        CASE SBLINELEFT
         newXFrame% = newXFrame% - 1
        CASE SBPAGELEFT
         newXFrame% = newXFrame% - 10
        CASE SBLINERIGHT
         newXFrame% = newXFrame% + 1
        CASE SBPAGERIGHT
         newXFrame% = newXFrame% + 10
        CASE SBSLIDERTRACK
         newXFrame% = lowword%
        CASE ELSE
      END SELECT
    '|
    '| If width or height value is outside range due to a PAGELEFT or PAGERIGHT
    '| set to minimum or maximum value.
    '|
      IF newXFrame% > cxScreen% THEN newXFrame% = cxScreen%
      IF newXFrame% < minFrame% THEN newXFrame% = minFrame%
    '|
    '| Reset Scroll bar position indicator only if user is not sliding the
    '| position indicator.
    '|
      IF hcommand% <> SBSLIDERTRACK THEN
        bool& = WinSendDlgItemMsg(hwnd&, XSCROLLBAR,_
                                  SBMSETPOS,_
                                  newXFrame%,_
                                  0)
      END IF
    '|
    '| Set entry field to new value
    '|
      bool% = WinSetDlgItemShort(hwnd&,_
                                 XENTRYFIELD,_
                                 newXFrame%,_
                                 1)
      ClientWndProc1& = 0
  '|
  '| Control vertical (Height) scroll bar
  '|
    CASE WMVSCROLL
      CALL BreakLong(mp2&, hcommand%, lowword%)
      SELECT CASE hcommand%
        CASE SBLINEUP
          newYFrame% = newYFrame% - 1
        CASE SBPAGEUP
          newYFrame% = newYFrame% - 10
        CASE SBLINEDOWN
          newYFrame% = newYFrame% + 1
        CASE SBPAGEDOWN
          newYFrame% = newYFrame% + 10
        CASE SBSLIDERTRACK
          newYFrame% = lowword%
        CASE ELSE
      END SELECT
    '|
    '| If width or height value is outside range due to a PAGEDOWN or PAGEUP
    '| set to minimum or maximum value.
    '|      
      IF newYFrame% > cyScreen% THEN newYFrame% = cyScreen%
      IF newYFrame% < minFrame% THEN newYFrame% = minFrame%
    '|
    '| Reset Scroll bar position indicator only if user is not sliding the
    '| position indicator.
    '|      
      IF hcommand% <> SBSLIDERTRACK THEN
        bool& = WinSendDlgItemMsg(hwnd&, YSCROLLBAR,_
                                  SBMSETPOS,_
                                  newYFrame%,_
                                  0)
      END IF
    '|
    '| Set entry field to new value
    '|
      bool% = WinSetDlgItemShort(hwnd&,_
                                 YENTRYFIELD,_
                                 newYFrame%,_
                                 1)
      ClientWndProc1& = 0

    CASE ELSE
      ClientWndProc1& = WinDefDlgProc(hwnd&, msg%, mp1&, mp2&)
  END SELECT
END FUNCTION

