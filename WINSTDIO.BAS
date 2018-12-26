'***********************************************************
'* 
'* Program Name: WinStdio.BAS
'*
'* Functions   :
'*               WinPrint/WinPrintS
'*               WinCLS/WinResetStdIO
'*               WinInput/WinInkey$/KeyMsg
'*               WinLocate/WinPOS/WinCSRLIN
'*
'* Description : This file provides the routines that do a
'*               partial emulation of BASIC's standard input
'*               and output routines.  These are good for
'*               text output, but input is accomplished much
'*               easier with entryfields inside dialog boxes.
'***********************************************************


REM $INCLUDE: 'PMBase.BI'
REM $INCLUDE: 'OS2Def.BI'
REM $INCLUDE: 'GpiChar.BI'
REM $INCLUDE: 'GpiCont.BI'
REM $INCLUDE: 'GpiLine.BI'
REM $INCLUDE: 'WinMan1.BI'
REM $INCLUDE: 'WinInput.BI'

'*** WinResetStdIO resets the position to the upper left corner of the
'*   window without erasing. (Reset with erase is WinCLS.) This is
'*   particularly useful to eliminate flashing from WinInput.

SUB WinResetStdIO(hwnd AS LONG, hps AS LONG)
     DIM prcl AS RECTL
     DIM ppointl AS POINTL

     bool% = WinQueryWindowRect(hwnd, MakeLong(VARSEG(prcl), VARPTR(prcl)))
     ppointl.y = prcl.yTop
     ppointl.x = 0
     bool% = GpiMove(hps, MakeLong(VARSEG(ppointl), VARPTR(ppointl)))

END SUB

' *** WinCLS clears the screen and uses WinResetStdIO to reset the cursor
' *   position to the "home" position.

SUB WinCLS(hwnd AS LONG, hps AS LONG)

     bool% = GpiErase(hps)
     CALL WinResetStdIO(hwnd, hps)

END SUB

' *** Used like the BASIC LOCATE statement, WinLocate will go to a row
' *   and column based upon the current character size.  This is mainly
' *   used when converting old BASIC programs, for exact pixel positioning
' *   GpiMove should be used.

SUB WinLocate(hwnd AS LONG, hps AS LONG, row AS INTEGER, col AS INTEGER)
     DIM prcl AS RECTL
     DIM ppointl AS POINTL
     DIM psizfxBox AS SIZEF

     bool% = WinQueryWindowRect(hwnd, MakeLong(VARSEG(prcl), VARPTR(prcl)))
     bool% = GpiQueryCharBox(hps,_
			     MakeLong&(VARSEG(psizfxBox), VARPTR(psizfxBox)))
     ppointl.y = prcl.yTop - (row - 1) * (psizfxBox.cy / &H10000)
     ppointl.x = 0 + (col - 1) * (psizfxBox.cx / &H10000)
     bool% = GpiMove(hps, MakeLong(VARSEG(ppointl), VARPTR(ppointl)))
END SUB

' *** WinPos can replace BASIC's POS function.  It returns the current
' *   horizonal position of the cursor, based upon the current character
' *   size.

FUNCTION WinPos%(hps AS LONG)
      DIM ptl AS POINTL
      DIM psizfxBox AS SIZEF
      bool% = GpiQueryCurrentPosition(hps, MakeLong(VARSEG(ptl), VARPTR(ptl)))
      bool% = GpiQueryCharBox(hps,_
                              MakeLong&(VARSEG(psizfxBox), VARPTR(psizfxBox)))
      WinPos% = 1 + ptl.x \ (psizfxBox.cx / &H10000)
END FUNCTION

' *** Replaces CSRLIN function in BASIC.  Returns the current line (row)
' *   position of the cursor, based on the current character size.

FUNCTION WinCSRLIN%(hwnd AS LONG, hps AS LONG)
      DIM prcl AS RECTL
      DIM ptl AS POINTL
      DIM psizfxBox AS SIZEF

      bool% = WinQueryWindowRect(hwnd, MakeLong(VARSEG(prcl), VARPTR(prcl)))
      bool% = GpiQueryCurrentPosition(hps, MakeLong(VARSEG(ptl), VARPTR(ptl)))
      bool% = GpiQueryCharBox(hps,_
                              MakeLong&(VARSEG(psizfxBox), VARPTR(psizfxBox)))
      WinCSRLIN% = 1 + (prcl.yTop - ptl.y) \ (psizfxBox.cy / &H10000)
END FUNCTION

' *** WinPrintS functions like BASIC's PRINT statement, followed by a
' *   semicolon (but only string values may be printed):
' *       PRINT A$;  = WinPrintS(hps&, A$)
' *   Prints out a string without doing a CR/LF after it.
' *   To print out a numeric value, it must first be converted to a string

SUB WinPrintS(hps AS LONG, PString AS String)
     DIM pptl AS POINTL
     DIM psizfxBox AS SIZEF
     DIM PtlStart AS POINTL

     bool% = GpiQueryCurrentPosition(hps,_
				     MakeLong&(VARSEG(pptl), VARPTR(pptl)))
     savey% = pptl.y
     bool% = GpiQueryCharBox(hps,_
			     MakeLong&(VARSEG(psizfxBox), VARPTR(psizfxBox)))
     pptl.y = pptl.y - (psizfxBox.cy / 65536)
     bool% = GpiCharStringAt(hps, MakeLong&(VARSEG(pptl), VARPTR(pptl)),_
			     len(PString),_
			     MakeLong&(VARSEG(PString), SADD(PString)))
     bool% = GpiQueryCurrentPosition(hps,_
				     MakeLong&(VARSEG(pptl), VARPTR(pptl)))
     pptl.y = savey%
     bool% = GpiMove(hps, MakeLong&(VARSEG(pptl), VARPTR(pptl)))

END SUB

' *** WinPrint functions like a BASIC PRINT statement, but for string
' *   values only.  All numeric values must be converted to strings
' *   before being printed with this function.

SUB WinPrint(hps AS LONG, PString AS String)
     DIM pptl AS POINTL
     DIM psizfxBox AS SIZEF
     DIM PtlStart AS POINTL

     bool% = GpiQueryCurrentPosition(hps,_
				     MakeLong&(VARSEG(pptl), VARPTR(pptl)))
     pptl.x = 0
     bool% = GpiQueryCharBox(hps,_
			     MakeLong&(VARSEG(psizfxBox), VARPTR(psizfxBox)))
     pptl.y = pptl.y - (psizfxBox.cy / 65536)
     CALL WinPrintS(hps, PString)
     bool% = GpiMove(hps, MakeLong&(VARSEG(pptl), VARPTR(pptl)))

END SUB

'*** KeyMsg is a simple SUB program to be used in for a WMCHAR to
'*   place keystrokes in a keyboard buffer. The characters placed
'*   here are retrievable using WinInkey$ or WinInput% FUNCTIONs.
'*   This SUB sends a WMPAINT message to trigger any active WinInput's.
'*
'*   USAGE:    (in ClientWndProc)
'*             SELECT CASE msg%
'*               ...
'*               CASE WMCHAR
'*                 CALL KeyMsg(hwnd&, mp1&, mp2&)
'*               CASE ...

SUB KeyMsg(hwnd&, mp1&, mp2&)
  SHARED KbdBuffer$
  ascii% = mp2& AND 255

  'Ignore messages with Ctrl or Alt, or when key is released.
  IF ((mp1& AND (KCKEYUP OR KCCTRL OR KCALT)) = 0) AND (ascii% <> 0) THEN
    KbdBuffer$ = KbdBuffer$ + CHR$(ascii%)
    bool% = WinInvalidateRect(hwnd&, 0, 0)    'InvalidateRect and PAINT to
    bool% = WinSendMsg(hwnd&, WMPAINT, 0, 0)  'inform WinInput to check.
  END IF
END SUB

'*** WinInkey$ works essentially like the standard INKEY$ function.
'*   The characters must first be buffered with KeyMsg.

FUNCTION WinInkey$
  SHARED KbdBuffer$
  IF KbdBuffer$ <> "" THEN
    WinInkey$  = LEFT$ (KbdBuffer$, 1)	      'Return/remove first
    KbdBuffer$ = RIGHT$(KbdBuffer$, LEN(KbdBuffer$) - 1)
  ELSE
    WinInkey$  = ""    'Buffer empty, return empty string
  END IF
END FUNCTION

'*****************************************************************************
'*  WinInput displays the prompt$ & inputs characters until a carriage return
'*  and stores these in var$.
'*
'*  If there is no CR in the current buffer, the function will return 0. This
'*  means the input is still active. The next time this WinInput is called
'*  the input is concatenated onto the previous input. This should be used in
'*  a WMPAINT message.
'*
'*  USAGE:   (in ClientWndProc)
'*           SELECT CASE msg%
'*             ...
'*             CASE WMCHAR
'*               CALL KeyMsg(hwnd&, mp1&,mp2&)
'*               KeyPressed% = -1
'*             CASE WMPAINT
'*               hps&=WinBeginPaint(...)
'*               IF KeyPressed% THEN
'*                 CALL WinResetStdIO(hwnd&, hps&)
'*                 KeyPressed% = 0
'*               ELSE
'*                 CALL WinCLS(hwnd&, hps&)
'*               END IF
'*               bool% = WinInput(hps&, prompt$, var$)
'*               IF bool% THEN
'*                 ... (process input)
'*****************************************************************************

FUNCTION WinInput%(hps AS LONG, prompt AS STRING, var AS STRING)

'******************** DIMension variables for:
  DIM pptl AS POINTL			     'GpiQueryCurrentPosition, GpiMove
  DIM prectl AS RECTL			     'WinFillRect
  DIM psizfxBox AS SIZEF		     'GpiQueryCharBox

  WinInput% = -1			     'Default (MEANING: Input done)
  IF var = "" THEN var = CHR$(0)           'Initialize with continuation (nul)
  CALL WinPrintS(hps, prompt)              'Always display prompt

  IF INSTR(var, CHR$(0)) <> 0 THEN          'If Input is still active
					     '(no continuation character [nul])

    var = LEFT$(var, LEN(var) - 1)        'Strip continuation character

'***** Loop to clear keyboard buffer using WinInkey.
'NOTE: Can NOT just wait in this loop for CR!
'      MUST transfer control back to Message Loop
'      to receive WMCHAR messages.

    a$ = WinInkey$
    WHILE (a$ <> "") AND (a$ <> CHR$(13))    'Continue until buffer empty or CR
      IF a$ <> CHR$(8) THEN		     'Add key if not backspace
        var = var + a$

'***** Backspace is a tricky character. Stringwise,
'      the operation is simple (Strip last character).
'      For display, must fill rect with background color.
'      To get the rectangle to fill, several steps:
'           1. Get current position (Left, Top)
'           2. Get Final position   (Right,Top)
'           3. Get character size   (GpiQueryCharBox)
'           4. Shift top to allow for tails on previous line (1/4 height)
'           5. Calculate Bottom by subtracting height from Top
'           6. WinFillRect
'           7. Move to initial position
'           8. Strip last character

      ELSEIF var <> "" THEN

	'*** 1. Get initial position (after prompt)
        bool% = GpiQueryCurrentPosition(hps,_
					MakeLong(VARSEG(pptl), VARPTR(pptl)))
	prectl.xLeft = pptl.x
	prectl.yTop  = pptl.y

	'*** 2. Display string to move to and get final position
        CALL WinPrintS(hps, var)
        bool% = GpiQueryCurrentPosition(hps,_
					MakeLong(VARSEG(pptl), VARPTR(pptl)))
	prectl.xRight = pptl.x

	'*** 3. Get character size
        bool% = GpiQueryCharBox(hps,_
				MakeLong(VARSEG(psizfxBox), VARPTR(psizfxBox)))

	'*** 4. Shift top by height/4
	deltaY& = (psizfxBox.cy / 65536) * .25
	prectl.yTop = prectl.yTop - deltaY&

	'*** 5. Calculate bottom
	prectl.yBottom = prectl.yTop - deltaY& * 4

	'*** 6. WinFillRect
        bool% = WinFillRect(hps,_
			    MakeLong(VARSEG(prectl), VARPTR(prectl)),_
			    CLRBACKGROUND)

	'*** 7. Locate back at initial position (after position)
	pptl.x = prectl.xLeft
	pptl.y = prectl.yTop + deltaY&	   'Shift back
        bool% = GpiMove(hps, MakeLong(VARSEG(pptl), VARPTR(pptl)))

	'*** 8. Strip last character
        var = LEFT$(var, LEN(var) - 1)

      END IF
      a$ = WinInkey$
    WEND			  'End of FlushBuffer loop

    IF a$ = "" THEN		  'If end of buffer reached without CR [13]
      WinInput% = 0		  'WinInput fails (returns 0=FALSE)
      var = var + CHR$(0)       'concatenate continuation character
    END IF
  END IF
  CALL WinPrint(hps, var)       'Always print current variable string
END FUNCTION
