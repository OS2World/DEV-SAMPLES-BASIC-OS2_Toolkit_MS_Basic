'
'    OPENDLG.BI -- File Dialog include file
'    Created by Microsoft Corporation, 1989


CONST IDMSYSCLOSE =   &H8004   ' "Close" item id in System Menu

CONST IDSMERGE1   =	0      ' merge string (%%)
CONST IDSIFN	  =	1      ' %% is not a valid filename.
CONST IDSFNF	  =	2      ' %% not found - Create new file?
CONST IDSREF	  =	3      ' Replace existing %%?
CONST IDSSCC	  =	4      ' %% has changed. Save current changes?
CONST IDSEOF	  =	5      ' Error opening %%
CONST IDSECF	  =	6      ' Error creating %%

' Dialog box IDs Open/Save IDs
CONST IDDFILEOPEN  =   -1
CONST IDDFILESAVE  =   -2

CONST ATTRDIRLIST  =  &H4010  ' include directories and drives in listbox

CONST MAXFNAMELEN      =  80
CONST CBEXTMAX	       =   6
CONST CBROOTNAMEMAX    =  73
CONST MAXMESSAGELENGTH = 128  ' maximum cb of a msg (instruction or warning).

' Action value for DlgFile, the values may be ORed, except DLGOPENDLG
' and DLGSAVEDLG.
CONST DLGOPENDLG = &H00      ' Use the Open dialog box.
CONST DLGSAVEDLG = &H01	     ' Use the Save (As) dialog box
CONST DLGNOOPEN  = &H02	     ' Don't Open the file we selected
CONST DLGHELP	 = &H04	     ' The dialog box supports Help

' Return values from DlgFile :
CONST TDFERRMEM  =  0
CONST TDFINVALID =  1
CONST TDFNOOPEN  =  2
CONST TDFNEWOPEN =  3
CONST TDFOLDOPEN =  4
CONST TDFNOSAVE  =  5
CONST TDFNEWSAVE =  6
CONST TDFOLDSAVE =  7

' Flags for OpenFile
CONST OFREOPEN = &H8000
CONST OFEXIST  = &H4000
CONST OFPROMPT = &H2000
CONST OFCREATE = &H1000
CONST OFCANCEL = &H0800
CONST OFVERIFY = &H0400
CONST OFDELETE = &H0200
CONST OFPARSE  = &H0100

CONST OFREAD	  =   &H0080
CONST OFWRITE	  =   &H0040
CONST OFREADWRITE =   &H0020

' flAttributes used to filter entries provided by DlgFillListBox
CONST BITATTRDRIVE = &H4000
CONST BITATTRDIR   = &H0010

' Data structure used to pass information to DlgFile().
TYPE DLF	 ' dlf
   rgbAction AS INTEGER               ' action usType:  eg. DLGOPEN
   rgbFlags AS INTEGER                ' open file flAttributes
   phFile AS LONG                     ' file handle
   pszExt AS LONG                     ' default file extension "\\.ext"
   pszAppName AS LONG                 ' application name
   pszTitle AS LONG                   ' panel title or NULL
   pszInstructions AS LONG            ' panel instructions or NULL
   szFileName AS STRING * MAXFNAMELEN ' relative file name
   szOpenFile AS STRING * MAXFNAMELEN ' full path name of current file
   szLastWild AS STRING * MAXFNAMELEN ' last relative wild card name
   szLastFile AS STRING * MAXFNAMELEN ' last relative file name
END TYPE

'  Exported functions
DECLARE SUB LCopyStruct (BYVAL PCHA AS LONG,_
                         BYVAL PCHB AS LONG,_
                         BYVAL aint AS INTEGER)

' Single byte parameter - cannot pass
'
'DECLARE SUB LFillStruct (BYVAL PCH AS LONG,_
'                         BYVAL aint AS INTEGER,_
'                         BYVAL BYTE AS STRING * 1)

DECLARE FUNCTION lstrlen% (BYVAL PSZ AS LONG)

DECLARE SUB lstrcpy (BYVAL PSZA AS LONG,_
                     BYVAL PSZB AS LONG)

DECLARE SUB lstrcat (BYVAL PSZA AS LONG,_
                     BYVAL PSZB AS LONG)

DECLARE FUNCTION lstrcmp% (BYVAL PSZA AS LONG,_
                           BYVAL PSZB AS LONG)

DECLARE SUB AddExt(BYVAL PSZA AS LONG,_
                   BYVAL PSZB AS LONG)

DECLARE FUNCTION FileInPath&(BYVAL PSZA AS LONG)

DECLARE FUNCTION GetTextExtent& (HPS AS LONG,_
                                 PCH AS LONG,_
                                 aint AS INTEGER)

DECLARE FUNCTION MergeStrings%(BYVAL PSZA AS LONG,_
                               BYVAL PSZB AS LONG,_
                               BYVAL PSZC AS LONG)

DECLARE FUNCTION OpenFile%(BYVAL PSZA AS LONG,_
                           BYVAL PHANDLE AS LONG,_
                           BYVAL PSZB AS LONG,_
                           BYVAL USHORT AS INTEGER)

DECLARE SUB SetupDLF(BYVAL PDLF AS LONG,_
                     BYVAL aint AS INTEGER,_
                     BYVAL PHFILE AS LONG,_
                     BYVAL APSZ AS LONG,_
                     BYVAL BPSZ AS LONG,_
                     BYVAL CPSZ AS LONG,_
                     BYVAL DPSZ AS LONG)

DECLARE FUNCTION DlgFile%(BYVAL HWND AS LONG,_
                          BYVAL PDLF AS LONG)

DECLARE FUNCTION AlertBox%(BYVAL HWND AS LONG,_
                           BYVAL aint AS INTEGER,_
                           BYVAL APSZ AS LONG,_
                           BYVAL BPSZ AS LONG,_
                           BYVAL AUSHORT AS INTEGER,_
                           BYVAL BUSHORT AS INTEGER)
