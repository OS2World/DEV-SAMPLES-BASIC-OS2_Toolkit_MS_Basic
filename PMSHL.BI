'**************************************************************
'*
'* Include File: PMShl.BI
'*
'* Requires:     none
'*
'* Description:  OS/2 Presentation Manager Shell constants,
'*               types, messages and function declarations
'*
'*************************************************************
 
' common types, constants and function declarations             
 
' maximum file name length 
CONST MAXNAMEL =60
 
' window size structure 
TYPE XYWINSIZE 
    x AS INTEGER
    y AS INTEGER
    cx AS INTEGER
    cy AS INTEGER
    fsWindow AS INTEGER
END TYPE
 
' Definitions for fsWindow                            
CONST XYFNOAUTOCLOSE  =&H0008
CONST XYFMINIMIZED    =&H0004                           
CONST XYFMAXIMIZED    =&H0002                           
CONST XYFINVISIBLE    =&H0001
CONST XYFNORMAL       =&H0000
 
 
 
' maximum path length 
CONST MAXPATHL =128
 
' root group handle 
CONST SGHROOT      =-1&
 
' values acceptable for PROGCATEGORY for PM groups cannot be defined
' as CONSTants in BASIC, since they are singel character constants.
' They have the following values:
'
' C Constant name      CHR$(n)
' ---------------      -------
' PROG_DEFAULT             0
' PROG_FULLSCREEN          1
' PROG_WINDOWABLEVIO       2
' PROG_PM                  3
' PROG_GROUP               5
' PROG_REAL                7
'
' visibility flag for PROGTYPE structure are also character constants:
' SHE_VISIBLE              0
' SHE_INVISIBLE            1
 
TYPE PROGTYPE 
    progc AS STRING * 1
    fbVisible AS STRING * 1
END TYPE
 
TYPE PROGRAMENTRY
    hprog AS LONG
    progt AS PROGTYPE
    szTitle AS STRING * 61     ' array in C: CHAR szTitle[MAXNAMEL+1]
END TYPE
 
TYPE PIBSTRUCT
    progt AS PROGTYPE
    szTitle AS STRING * 61	   ' array in C:CHAR szTitle[MAXNAMEL+1]
    szIconFileName AS STRING * 129 ' array in C:CHAR szIconFileName[MAXPATHL+1]
    szExecutable AS STRING * 129   ' array in C:CHAR szExecutable[MAXPATHL+1]
    szStartupDir AS STRING * 129   ' array in C:CHAR szStartupDir[MAXPATHL+1]
    xywinInitial AS XYWINSIZE
    res1 AS INTEGER
    res2 AS LONG
    cchEnvironmentVars AS INTEGER
    pchEnvironmentVars AS LONG
    cchProgramParameter AS INTEGER
    pchProgramParameter AS LONG
END TYPE
 
'**  Program Use 
DECLARE FUNCTION WinQueryProgramTitles%( BYVAL hab AS LONG,_
                                         BYVAL hprogram AS LONG,_
                                         BYVAL pprogramentry AS LONG,_
                                         BYVAL ushort AS INTEGER,_
                                         BYVAL pushort AS LONG )
 
'**  Single Program Manipulation 
DECLARE FUNCTION WinAddProgram&( BYVAL hab AS LONG,_
                                 BYVAL ppibstruct AS LONG,_
                                 BYVAL hprogram AS LONG )

DECLARE FUNCTION WinQueryDefinition%( BYVAL hab AS LONG,_
                                      BYVAL hprogram AS LONG,_
                                      BYVAL ppibstruct AS LONG,_
                                      BYVAL ushort AS INTEGER )
 
'**  Group Manipulation 
'DECLARE FUNCTION WinCreateGroup&( BYVAL hab AS LONG,_
'                                  BYVAL psz AS LONG ,_
'                                  *****UCHAR,*********_
'                                  BYVAL Aulong AS LONG,_
'                                   BYVAL Bulong AS LONG )
 
TYPE PIBBUFFER 
    progt AS PROGTYPE
    szTitle AS STRING * 61	   ' array in C:CHAR szTitle[MAXNAMEL+1]
    szIconFileName AS STRING * 129 ' array in C:CHAR szIconFileName[MAXPATHL+1]
    szExecutable AS STRING * 129   ' array in C:CHAR szExecutable[MAXPATHL+1]
    szStartupDir AS STRING * 129   ' array in C:CHAR szStartupDir[MAXPATHL+1]
    xywinInitial AS XYWINSIZE
    res1 AS INTEGER
    res2 AS LONG
    cchEnvironmentVars AS INTEGER
    pchEnvironmentVars AS LONG
    cchProgramParameter AS INTEGER
    pchProgramParameter AS LONG
    HEPstrings AS STRING * 1024    ' array in C:CHAR HEPstrings[1024]
END TYPE
 
 
 
 
' visibility flag for SWCNTRL structure use character constants
'
' C Constant name      CHR$(n)
' ---------------      -------
' SWL_VISIBLE             4
' SWL_INVISIBLE           1
' SWL_GRAYED              2
' 
' visibility flag for SWCNTRL structure also use character constants
' SWL_JUMPABLE            2
' SWL_NOTJUMPABLE         1

TYPE SWCNTRL
    hwnd AS LONG                                            
    hwndIcon AS LONG
    hprog AS LONG
    idProcess AS INTEGER
    idSession AS INTEGER
    uchVisibility AS STRING * 1
    fbJump AS STRING * 1
    szSwtitle AS STRING * 129 ' array in C:CHAR     szSwtitle[MAXNAMEL+1]
    fReserved AS STRING * 1   ' To align on word boundary  
END TYPE
 
'** Switching Program functions 
DECLARE FUNCTION WinAddSwitchEntry&( BYVAL pswcntrl AS LONG )

DECLARE FUNCTION WinRemoveSwitchEntry%( BYVAL hswitch AS LONG )
 
 
 
DECLARE FUNCTION WinChangeSwitchEntry%( BYVAL hswitch AS LONG,_
                                        BYVAL pswcntrl AS LONG )

DECLARE FUNCTION WinQueryTaskTitle%( BYVAL Aushort AS INTEGER,_
                                     BYVAL psz AS LONG ,_
                                     BYVAL Bushort AS INTEGER )
 
 
 
 
'** OS2.INI Access functions 
DECLARE FUNCTION WinQueryProfileInt%( BYVAL hab AS LONG,_
                                      BYVAL Apsz AS LONG,_
                                      BYVAL Bpsz AS LONG,_
                                      BYVAL short AS INTEGER )

DECLARE FUNCTION WinQueryProfileString%( BYVAL hab AS LONG,_
                                         BYVAL Apsz AS LONG,_
                                         BYVAL Bpsz AS LONG,_
                                         BYVAL Cpsz AS LONG ,_
                                         BYVAL pvoid AS LONG,_
                                         BYVAL ushort AS INTEGER )

DECLARE FUNCTION WinWriteProfileString% ( BYVAL hab AS LONG,_
                                          BYVAL Apsz AS LONG,_
                                          BYVAL Bpsz AS LONG,_
                                          BYVAL Cpsz AS LONG )

DECLARE FUNCTION WinQueryProfileSize% ( BYVAL hab AS LONG,_
                                        BYVAL Apsz AS LONG,_
                                        BYVAL Bpsz AS LONG,_
                                        BYVAL pushort AS LONG )

DECLARE FUNCTION WinQueryProfileData% ( BYVAL hab AS LONG,_
                                        BYVAL Apsz AS LONG,_
                                        BYVAL Bpsz AS LONG,_
                                        BYVAL pvoid AS LONG,_
                                        BYVAL pushort AS LONG )    

DECLARE FUNCTION WinWriteProfileData% ( BYVAL hab AS LONG,_
                                        BYVAL Apsz AS LONG,_
                                        BYVAL Bpsz AS LONG,_
                                        BYVAL pvoid AS LONG,_
                                        BYVAL ushort AS INTEGER )
 
 
 
CONST PMERRINVALIDPIB                =&H1101
CONST PMERRINSUFFSPACETOADD          =&H1102
CONST PMERRINVALIDGROUPHANDLE        =&H1103
CONST PMERRDUPLICATETITLE            =&H1104
CONST PMERRINVALIDTITLE              =&H1105
CONST PMERRHANDLENOTINGROUP          =&H1107
CONST PMERRINVALIDTARGETHANDLE       =&H1106
CONST PMERRINVALIDPATHSTATEMENT      =&H1108
CONST PMERRNOPROGRAMFOUND            =&H1109
CONST PMERRINVALIDBUFFERSIZE         =&H110A
CONST PMERRBUFFERTOOSMALL            =&H110B
CONST PMERRPLINITIALISATIONFAIL      =&H110C
CONST PMERRCANTDESTROYSYSGROUP       =&H110D
CONST PMERRINVALIDTYPECHANGE         =&H110E
CONST PMERRINVALIDPROGRAMHANDLE      =&H110F
 
CONST PMERRNOTCURRENTPLVERSION       =&H1110
CONST PMERRINVALIDCIRCULARREF        =&H1111
CONST PMERRMEMORYALLOCATIONERR       =&H1112
CONST PMERRMEMORYDEALLOCATIONERR     =&H1113
CONST PMERRTASKHEADERTOOBIG          =&H1114
 
CONST PMERRDOSERROR                  =&H1200
 
CONST PMERRNOSPACE                   =&H1201
CONST PMERRINVALIDSWITCHHANDLE       =&H1202
CONST PMERRNOHANDLE                  =&H1203
CONST PMERRINVALIDPROCESSID          =&H1204
CONST PMERRNOTSHELL                  =&H1205
CONST PMERRINVALIDWINDOW             =&H1206
CONST PMERRINVALIDPOSTMSG            =&H1207
CONST PMERRINVALIDPARAMETERS         =&H1208
CONST PMERRINVALIDPROGRAMTYPE        =&H1209
CONST PMERRNOTEXTENDEDFOCUS          =&H120A
CONST PMERRINVALIDSESSIONID          =&H120B
CONST PMERRSMGINVALIDICONFILE        =&H120C
CONST PMERRSMGICONNOTCREATED         =&H120D
CONST PMERRSHLDEBUG                  =&H120E
 
CONST PMERROPENINGINIFILE            =&H1301
CONST PMERRINIFILECORRUPT            =&H1302
CONST PMERRINVALIDPARM               =&H1303
CONST PMERRNOTINIDX                  =&H1304
 
CONST PMERRINIWRITEFAIL              =&H1306
CONST PMERRIDXFULL                   =&H1307
CONST PMERRINIPROTECTED              =&H1308
CONST PMERRMEMORYALLOC               =&H1309
CONST PMERRINIINITALREADYDONE        =&H130A
CONST PMERRINVALIDINTEGER            =&H130B
CONST PMERRINVALIDASCIIZ             =&H130C
CONST PMERRCANNOTCALLSPOOLER         =&H130D
CONST PMERRVALIDATIONREJECTED        =&H130D
 
CONST PMERRWARNINGWINDOWNOTKILLED    =&H1401
CONST PMERRERRORINVALIDWINDOW        =&H1402
CONST PMERRALREADYINITIALIZED        =&H1403
CONST PMERRMSGPROGNOMOU              =&H1405
CONST PMERRMSGPROGNONRECOV           =&H1406
CONST PMERRWINCONVINVALIDPATH        =&H1407
CONST PMERRPINOTINITIALISED          =&H1408
CONST PMERRPLNOTINITIALISED          =&H1409
CONST PMERRNOTASKMANAGER             =&H140A
CONST PMERRSAVENOTINPROGRESS         =&H140B
CONST PMERRNOSTACKSPACE              =&H140C
CONST PMERRINVALIDCOLRFIELD          =&H140d
CONST PMERRINVALIDCOLRVALUE          =&H140e
CONST PMERRCOLRWRITE                 =&H140f
 
CONST PMERRTARGETFILEEXISTS          =&H1501
CONST PMERRSOURCESAMEASTARGET        =&H1502
CONST PMERRSOURCEFILENOTFOUND        =&H1503
CONST PMERRINVALIDNEWPATH            =&H1504
CONST PMERRTARGETFILENOTFOUND        =&H1505
CONST PMERRINVALIDDRIVENUMBER        =&H1506
CONST PMERRNAMETOOLONG               =&H1507
CONST PMERRNOTENOUGHROOMONDISK       =&H1508
CONST PMERRNOTENOUGHMEM              =&H1509
 
CONST PMERRLOGDRVDOESNOTEXIST        =&H150B
CONST PMERRINVALIDDRIVE              =&H150C
CONST PMERRACCESSDENIED              =&H150D
CONST PMERRNOFIRSTSLASH              =&H150E
CONST PMERRREADONLYFILE              =&H150F
 
