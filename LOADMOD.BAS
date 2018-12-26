REM $INCLUDE: 'os2def.bi'
REM $INCLUDE: 'pmbase.bi'
REM $INCLUDE: 'opendlg.bi'
REM $INCLUDE: 'winmisc.bi'
REM $INCLUDE: 'wintrack.bi'
REM $INCLUDE: 'gpibit.bi'

REM $INCLUDE: 'CAPTURE.INC'


'|***************************************************************************
'|
'| LOADMOD.BAS:  Support module of CAPTURE.BAS
'|
'|***************************************************************************
'| Loads a bitmap from a disk file.  The filename of the bitmap to be loaded
'| is obtained from the the routine "DlgFile" in OPENDLG.DLL.  If "Dlgfile"
'| returns an appropriate value, the bitmap is loaded into memory.  If the
'| is not a valid OS/2 bitmap format, it will not be loaded.
'|
'| Due to a limitation of the OPENDLG routines, if a file that does not exist
'| is opened, the OPENDLG routine asks the user if it should be created.
'| Since this program cannot load a bitmap that does ont exist, the file is
'| not created if "yes" is selected.
'|***************************************************************************
SUB LoadBitmapFromFile(hwndFrame&, hwnd&, hbm&)
DIM bfh AS BITMAPFILEHEADER, bi AS MyBITMAPINFO, vdlf AS DLF
DIM filename AS STRING * 80, ptl AS POINTL
'|
'| Initialize values to be used in in the Dialog box
'|
  szExtension$ = "\*.BMP" + CHR$(0)
  szHelp$ = "The default extension is .BMP, and is attached to the file "+_
            "name if an extension is not given." + CHR$(13) + CHR$(10) +_
            "If the file does not exist, you'll be asked if you wish to "+_
            "create it.  Since the Bitmap must exist to be loaded, "+_
            "selecting YES will not create the file.  The OPEN BITMAP "+_
            "dialog box will disappear, and message box will appear "+_
            "explaining that the file must exist to be loaded.  This is "+_
            "due to a limit with OPENDLG.DLL" + CHR$(0)
  szSaveTitle$ = "LOAD BITMAP FROM FILE" + CHR$(0)
'|
'| Initialize fields of "vdlf".  vdlf is of TYPE DLF, which is used
'| by the Dialog box routine.
'|
  CALL SetupDLF(MakeLong(VARSEG(vdlf), VARPTR(vdlf)),_
                DLGOPENDLG,_
                MakeLong(VARSEG(filehandle%), VARPTR(filehandle%)),_
                MakeLong(VARSEG(szExtension$), SADD(szExtension$)),_
                0,_
                MakeLong(VARSEG(szSaveTitle$), SADD(szSaveTitle$)),_
                MakeLong(VARSEG(szHelp$), SADD(szHelp$)))
                vdlf.szOpenFile = filename
'|
'| Obtain file name of bitmap to loaded.  The routine "DlgFile" is contained
'| within the DLL "OpenDlg.DLL".  It displays and manipulates the
'| dialog box for saving files.  It returns only when a valid filename
'| has been obtained, and the user selects "Open".  It returns one of
'| three values:
'|               TDFNEWOPEN  the file does not exist
'|                           (since this program creates a file only
'|                            during a SAVE operation, to OPEN a file,
'|                            the file must exist.  Any messages from
'|                            DLGFILE stating "File does not exist,
'|                            do wish to create it?", you can ignore
'|                            since the file will not be created.  If you
'|                            select "YES", the DLGFILE will return
'|                            TDFNEWOPEN and this routine will prompt
'|                            the user that the file must exist to be loaded.
'|               TDFOLDOPEN  file exists, open it
'|               TDFNOOPEN   user selected "Cancel"
'|
'| Loop until DlgFile returns either TDFNOOPEN or TDFOLDOPEN
'|
  DO
  '|
  '| Get file name
  '|
    retn% = DlgFile(hwndFrame&, MakeLong(VARSEG(vdlf), VARPTR(vdlf)))
  '|
  '| Close file since DlgFile opens the file selected regardless if
  '| DLGNOOPEN was included in the paramaters passed to DlgFile.  The
  '| file handle returned from DlgFile cannot be used by standard BASIC
  '| file functions, i.e. GET, PUT, INPUT,..., since it is a DOS file
  '| handle.
  '|
    bool% = DosClose(filehandle%)
    filename = vdlf.szFileName
  '|
  '| Stripe off unused portion of 80 byte fixed string containing file name
  '|
    bmpfile$ = LEFT$(filename, INSTR(filename, CHR$(0)) - 1)
    IF retn% = TDFOLDOPEN THEN
    '|
    '| If file exists, OPEN file and load bitmap
    '|
      CALL SetSystemPointerToWaitPointer
      OPEN bmpfile$ FOR BINARY AS #2
    '|
    '| Get bitmap file header information and copy information to
    '| "bi" (bitmap info type), and read palette information
    '|
      GET #2,,bfh
      GET #2,,bi.argbColor
      bi.cbFix     = bfh.bmp.cbFix
      bi.cx        = bfh.bmp.cx
      bi.cy        = bfh.bmp.cy
      bi.cPlanes   = bfh.bmp.cPlanes
      bi.cBitCount = bfh.bmp.cBitCount
    '|
    '| Create a presentation space and device context for bitmap.
    '| Delete current bitmap.
    '| Create a new bitmap using above bitmap information
    '| Set new bitmap to presentation space
    '|
      CALL CreateBitmapPSandDC(hpsBitmap&, hdc&)
      bool% = GpiDeleteBitmap(hbm&)
      hbm& = GpiCreateBitmap(hpsBitmap&,_
                             MakeLong(VARSEG(bi), VARPTR(bi)),_
                             0, 0, 0)
      IF (hbm& <> 0) AND (bfh.usType = BFTBMAP) THEN
      '|
      '| If file is a valid bitmap file, load bitmap
      '|
        bool% = GpiSetBitmap(hpsBitmap&, hbm&)
      '|
      '| Determine buffer size needed for one scan line, rounded to next
      '| 32 byte boundary. (required by OS/2)
      '|
        bits% = bi.cBitCount * bi.cx
        ScanLineSize% = ((bits% \ 32) + SGN(bits% MOD 32)) * 4
        inbuffer$ = SPACE$(ScanLineSize%)
      '|
      '| GET one scan at a time, convert to displable format and store in
      '| in micro presentation space created above
      '|
        FOR scanline& = 0 TO bi.cy - 1
          GET #2,,inbuffer$
          bool% = GpiSetBitmapBits(hpsBitmap&,_
                                   scanline&,_
                                   1,_
                                   MakeLong(VARSEG(inbuffer$), SADD(inbuffer$)),_
                                   MakeLong(VARSEG(bi), VARPTR(bi)))
        NEXT scanline&
        CALL SetScrollBarStatus
      ELSE
      '|
      '| If file is not a valid OS/2 bitmap file, prompt user
      '|
        caption$ = "INVALID FORMAT" + CHR$(0)
        message$ = bmpfile$ + " is not a valid OS/2 Bitmap file" + CHR$(0)
        bool% = DisplayMessageBox(message$, caption$, 2)
        bool% = GpiDeleteBitmap(hbm&)
        hbm& = 0
      END IF
    '|
    '| CLOSE file, and release presentation space, device context used to
    '| create bitmap.  Post a WMPAINT message to cause bitmap to be displayed.
    '|
      CLOSE #2
      bool% = GpiDestroyPS(hpsBitmap&)
      bool% = DevCloseDC(hdc&)
      bool% = WinInvalidateRect(hwnd&, 0, 0)
      CALL SetSystemPointerToStandardArrow
    ELSEIF retn% = TDFNEWOPEN THEN
    '|
    '| If file is a new file delete the file, since it is create by DlgFile
    '| if "Yes" is selected when asked if it is to be created.  Display
    '| message to prompt user that the file must exist to be loaded.
    '|
      KILL bmpfile$
      caption$ = bmpfile$ + "does not exist!" + CHR$(0)
      message$ = "A Bitmap must exist to be loaded" + CHR$(0)
      bool% = DisplayMessageBox(message$, caption$, 2)
    END IF
  LOOP UNTIL (retn% = TDFNOOPEN) OR (retn% = TDFOLDOPEN)
END SUB

