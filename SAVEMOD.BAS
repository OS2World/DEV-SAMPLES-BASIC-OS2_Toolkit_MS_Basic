REM $INCLUDE: 'os2def.bi'
REM $INCLUDE: 'pmbase.bi'
REM $INCLUDE: 'opendlg.bi'
REM $INCLUDE: 'winmisc.bi'
REM $INCLUDE: 'wintrack.bi'
REM $INCLUDE: 'gpibit.bi'

REM $INCLUDE: 'CAPTURE.INC'

'|***************************************************************************
'|
'| SAVEMOD.BAS: Support module of CAPTURE.BAS to Save a bitmap to a disk file
'|
'|***************************************************************************
'| Saves captured bitmap to a disk file.  The filename to which the bitmap
'| is saved is obtained from the the routine "DlgFile" in OPENDLG.DLL.
'| If "Dlgfile" returns an appropriate value, the bitmap is converted to
'| file format and written out to disk.
'|***************************************************************************
SUB SaveBitmapToFile(hab&, hwndFrame&, hbm&) STATIC
DIM bfh AS BITMAPFILEHEADER, bi AS MyBITMAPINFO
DIM filename AS STRING * 80, vdlf AS DLF
'|
'| Initialize values to be used in in the Dialog box
'|
  szExtension$ = "\*.BMP" + CHR$(0)
  szHelp$ = "Any extension may be given, but the default is "+_
            ".BMP, and attached to the file name if an extension "+_
            "is not given." + CHR$(0)
  szSaveTitle$ = "SAVE BITMAP TO FILE" + CHR$(0)
'|
'| Initialize fields of "vdlf".  vdlf is of TYPE DLF, which is used
'| by the Dialog box routine.
'|
  CALL SetupDLF(MakeLong(VARSEG(vdlf), VARPTR(vdlf)),_
                DLGSAVEDLG OR DLGNOOPEN,_
                MakeLong(VARSEG(filehandle%), VARPTR(filehandle%)),_
                MakeLong(VARSEG(szExtension$), SADD(szExtension$)),_
                0,_
                MakeLong(VARSEG(szSaveTitle$), SADD(szSaveTitle$)),_
                MakeLong(VARSEG(szHelp$), SADD(szHelp$)))
                vdlf.szOpenFile = filename
'|
'| Obtain file name to save bitmap to.  The routine "DlgFile" is contained
'| within the DLL "OpenDlg.DLL".  It displays and manipulates the
'| dialog box for saving files.  It returns only when a valid filename
'| has been obtained, and the user selects "Save" or "Cancel.  It returns
'| one of three values:
'|
'|               TDFNEWSAVE  saving to a new file
'|               TDFOLDSAVE  write over an existing file
'|               TDFNOSAVE   user selected "Cancel"
'|
  retn% = DlgFile(hwndFrame&, MakeLong(VARSEG(vdlf), VARPTR(vdlf)))
  filename = vdlf.szFileName
  IF retn% = TDFNEWSAVE OR retn% = TDFOLDSAVE THEN
    CALL SetSystemPointerToWaitPointer
    bool% = GpiQueryBitmapParameters(hbm&,_
                                     MakeLong(VARSEG(bi), VARPTR(bi)))
  '|
  '| Initialize Bitmap file header information.
  '|
  '| PM requires each scanline to end on a 32 bit boundary, after
  '| the number of bits per scan line is determined, it is rounded up
  '| to the next 32 bit boundary.
  '|
    bits% = bi.cBitCount * bi.cx
    ScanLineSize% = ((bits% \ 32) + SGN(bits% MOD 32)) * 4
    BmpDataSize& = CLNG(ScanLineSize%) * bi.cy
    bfh.usType = BFTBMAP
    bfh.cbSize = LEN(bfh) + 48 + BmpDataSize&
    bfh.xHotspot = 0
    bfh.yHotspot = 0
    bfh.offBits =  LEN(bfh) + 48&
    bfh.bmp.cbFix = bi.cbFix
    bfh.bmp.cx = bi.cx
    bfh.bmp.cy = bi.cy
    bfh.bmp.cPlanes = bi.cPlanes
    bfh.bmp.cBitCount = bi.cBitCount
  '|
  '| Get file name and Delete file if it exists, then OPEN file for BINARY
  '|
    bmpfile$ = LEFT$(filename, INSTR(filename, CHR$(0)) - 1)
    IF retn% = TDFOLDSAVE THEN KILL bmpfile$
    OPEN bmpfile$ FOR BINARY AS #2
  '|
  '| Write Bitmap file header to file
  '|
    PUT #2,,bfh
  '|
  '| Set buffer to size that can hold one scanline
  '|
    outbuffer$ = SPACE$(ScanLineSize%)
  '|
  '| Convert one scanline of bitmap at a time to format which can be
  '| written to file, the copy to output buffer and write buffer to file.
  '| Write COLOR PALETTE to file returned by GpiQueryBitmapBits to file
  '| prior to writing first scanline to file.  This must be within the
  '| loop since the PALETTE information is obtained from the call to
  '| GpiQueryBitmapBits
  '|
    CALL CreateBitmapPSandDC(hpsBitmap&, hdc&)
    bool% = GpiSetBitmap(hpsBitmap&, hbm&)
    FOR scanline% = 0 TO bi.cy - 1
      bool% = GpiQueryBitmapBits(hpsBitmap&,_
                                 scanline%,_
                                 1,_
                                 MakeLong(VARSEG(outbuffer$), SADD(outbuffer$)),_
                                 MakeLong(VARSEG(bi), VARPTR(bi)))
      IF scanline% = 0 THEN PUT #2,,bi.argbColor
      PUT #2,,outbuffer$
    NEXT scanline%
    CLOSE #2
    bool% = GpiDestroyPS(hpsBitmap&)
    bool% = DevCloseDC(hdc&)
    CALL SetSystemPointerToStandardArrow
  END IF
END SUB

