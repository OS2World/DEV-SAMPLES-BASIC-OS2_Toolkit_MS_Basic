'***********************************************************
'* Program Name: Setup.BAS
'*
'* Description : Setup provides an easy way for the files
'*               from the BASIC PM Toolkit Supplement to be
'*               copied.  Besides copying the files into the
'*               specified directories, the program also
'*               modifies the PMBC command files and creates
'*               the file, NEW-VARS.SYS, which contains the
'*               values that need to be added to the
'*               environment variables in the user's
'*               CONFIG.SYS.
'*
'*               There are 2 sections of help and an about box.
'*
'*               The directory structure is limited.  All
'*               files must be copied to the same and under
'*               the same base directory.
'*
'*               Errors during copying are not checked
'*               because the SHELL function is used to start
'*               another process.  The user can, however,
'*               check that process.
'*----------------------------------------------------------
'* Program Flow: The program is based on the SKELETON.BAS
'*               program.  Setup gets the PM structure
'*               (module level code and ClientWndProc) from
'*               SKELETON.
'*
'*               Setup is driven from ClientWndProc in the
'*               WMTIMER message.  This section of CWP calls
'*               each of the CopyXxxxDisk routines and
'*               controls the flow using the global variable
'*               SetupStage.
'*
'* Procedures  : The routines in Setup can be divided into
'*               the following groups:
'*
'*    Window Procedures
'*             ClientWndProc     Main window procedure
'*             ClientWndProc1    Dialog procedure for SetDrives/Paths
'*
'*    Setup Routines
'*             CopyMainDisk      Copies main disk
'*             CopyExampleDisk   Copies all example disks
'*             ModifyCmdFiles    Modifies PMBC command files
'*             CreateNewVars     Creates NEW-VARS.SYS
'*
'*    File/Directory Routines
'*             CreateDirs        Create necessary directories
'*             MakeDir           Create specified directory
'*             ValidDrive        Check if drive is "<any letter>:"
'*             ValidDir          Minor check (start "\", no base)
'*             FileExists        Use DosFindFirst to check if file exists
'*             GetDiskName       Returns diskname (from DISKNAME.DAT)
'*
'*    String Routines
'*             Replace           Standard search/replace
'*             FarSADD           MakeLong(VARSEG,SADD) far string pointer
'*
'*    PM Readability Routines
'*             DisplayMessageBox Displays message box (Appl modal)
'*             StartTimer        Starts timer (2 seconds)
'*             StopTimer         Stops timer
'*             SetTitleBar       Sets title bar
'*             DisableMenu       Disables menu
'*             SetCheck          Sets checkbox
'*             ToggleCheck       Changes flag and sets checkbox
'*             QueryDlgText      Returns upper case string
'***********************************************************

'*********         Initialization section        ***********

REM $INCLUDE: 'Setup.INC'

DIM aqmsg AS QMSG

'****
'** Global variables:
'**
'** Handles      for Start/StopTimer
'** DrivesPaths  for everything
'** ErrorFlag    for checking directories (set in ON ERROR)
'** SetupStage   for distinguishing the stage of Setup for WMTIMER message
'** InstallFlags for installing optional files

COMMON SHARED /Handles/ hab&, hwndClient&
COMMON SHARED /DrivesPaths/ SourceDrive$, DestDrive$, BaseDir$, CmdDir$,_
              LibDir$, IncludeDir$, UtilityDir$, HelpDir$, ExampleDir$
COMMON SHARED /ErrorFlag/  DirError%
COMMON SHARED /SetupStage/ SetupStage%
COMMON SHARED /InstallFlags/ CmdFlag%, HelpFlag%, UtilityFlag%, ExampleFlag%

ON ERROR GOTO handle:
flFrameFlags& = FCFTITLEBAR      OR FCFSYSMENU OR _
                FCFSIZEBORDER    OR FCFMINMAX  OR _
                FCFSHELLPOSITION OR FCFTASKLIST OR_
                FCFMENU          OR FCFACCELTABLE OR_
                FCFICON

szClientClass$ = "Setup" + CHR$(0)

hab& = WinInitialize(0)
hmq& = WinCreateMsgQueue(hab&, 0)

warning$  = "WARNING:" + CHR$(0)
moreinfo$ = "Setup must be run from a hard disk." + STRING$(2,13) +_
            "Because Setup requires that disks be changed "+_
            "and OS/2 can swap segments to disk, it is "+_
            "necessary to run setup from a fixed disk." + STRING$(2,13) +_
            "If you are running Setup from a fixed disk, "+_
            "press OK and continue with Setup." + STRING$(2,13)+_
            "Otherwise, press Cancel, copy SETUP.EXE to "+_
            "a fixed disk, and run Setup again." + CHR$(0)

bool% = DisplayMessageBox(moreinfo$, warning$, MBOKCANCEL OR MBICONEXCLAMATION)

IF bool% = MBIDOK THEN

   bool% = WinRegisterClass(hab&, FarSADD(szClientClass$), RegBas, 0, 0)

   hwndFrame& = WinCreateStdWindow (HWNDDESKTOP, WSVISIBLE,_
                MakeLong (VARSEG(flFrameFlags&), VARPTR(flFrameFlags&)),_
                FarSADD(szClientClass$), 0, 0, 0, IDSETUP,_
                MakeLong (VARSEG(hwndClient&), VARPTR(hwndClient&)))

   '**************         Message loop         ***************

   WHILE WinGetMsg(hab&, MakeLong(VARSEG(aqmsg), VARPTR(aqmsg)), 0, 0, 0)
     bool% = WinDispatchMsg(hab&, MakeLong(VARSEG(aqmsg), VARPTR(aqmsg)))
   WEND

   '***********         Finalize section        ***************

   bool% = WinDestroyWindow(hwndFrame&)
END IF

bool% = WinDestroyMsgQueue(hmq&)
bool% = WinTerminate(hab&)

END

handle:
   SELECT CASE ERR
      CASE 76
         DirError% = -1
         Title$    = "Path/File Access Error" + CHR$(0)
         Caption$  = "Invalid path. Reenter drives/paths." + CHR$(0)
         bool% = DisplayMessageBox(caption$, title$, MBOK OR MBICONEXCLAMATION)
      CASE ELSE
   END SELECT
   RESUME NEXT

'***********         Window Procedures        ***************

'****
'** ClientWndProc is the main window procedure.
'**
'**  WMCREATE  sets the initial values for global vars and initial title
'**  WMCLOSE   asks user if the want to Quit then does so
'**  WMCOMMAND handles menu options: dialog boxes or start setup with timer
'**  WMHELP    displays the help string in a message box
'**  WMPAINT   loads and draws bitmap to window dimensions
'**  WMTIMER   copies files, etc.
FUNCTION ClientWndProc& (hwnd&, msg%, mp1&, mp2&) STATIC

     SHARED szClientClass$
     DIM ClientRect AS RECTL

     ClientWndProc& = 0
     SELECT CASE msg%

     CASE WMCREATE   'WMCREATE sets initial global vars, local handles and title

        SourceDrive$  = "A:"               'Global variables
        DestDrive$    = "C:"
        BaseDir$      = "\PMBASIC"
        CmdDir$       = "\CMD"
        LibDir$       = "\LIB"
        IncludeDir$   = "\INCLUDE"
        HelpDir$      = "\HELP"
        UtilityDir$   = "\UTILITY"
        ExampleDir$   = "\EXAMPLES"
        CmdFlag%      = -1
        HelpFlag%     = -1
        UtilityFlag%  = -1
        ExampleFlag%  = -1

        InitTitleBar$ = "BASIC PM Setup" + CHR$(0)              'Set title bar
        CALL SetTitleBar(hwnd&, InitTitleBar$)

     CASE WMCLOSE      'WMCLOSE asks if user wants to quit and does so

        message$ = "Are you sure you want to QUIT?" + CHR$(0)
        caption$ = " " + CHR$(0)
        IF DisplayMessageBox(message$, caption$,_
           MBYESNO OR MBICONQUESTION) = MBIDYES THEN
           bool% = WinPostMsg(hwnd&, WMQUIT, 0, 0)
        END IF

     CASE WMCOMMAND                           'WMCOMMAND processes the menus

        CALL BreakLong(mp1&, hiword%, loword%)
        SELECT CASE loword%

           CASE IDDRPATH      'IDDRPATH displays dialog processed in CWP1
              bool% = WinDlgBox(HWNDDESKTOP, hwnd&, RegBas1, 0, IDDRPATH, 0)

           CASE IDSTART       'IDSTART starts setup with timer (disables menus)
              SetupStage% = 1
              CALL DisableMenu(hwnd&, IDDRPATH, MIADISABLED)
              CALL DisableMenu(hwnd&, IDSTART,  MIADISABLED)
              CALL StartTimer

           CASE IDABOUT       'IDABOUT brings up simple dialog (no procedure)
              bool% = WinDlgBox(HWNDDESKTOP, hwnd&, 0, 0, IDABOUT, 0)

           CASE ELSE          'Pass control to default (should not get here)
              ClientWndProc& = WinDefWindowProc(hwnd&, msg%, mp1&, mp2&)
        END SELECT

     CASE WMHELP              'WMHELP displays help dialog

        bool% = WinDlgBox(HWNDDESKTOP, hwnd&, 0, 0, WMHELP, 0)

     CASE WMPAINT     'WMPAINT loads and displays bitmap

        bool% = WinInvalidateRect(hwnd&, 0, 0)     'inval to redraw full window
        hps&  = WinBeginPaint(hwnd&, 0,_
                MakeLong(VARSEG(ClientRect), VARPTR(ClientRect)))
        hbmp& = GpiLoadBitmap(hps&, 0, IDBITMAP, 0, 0)
        bool% = WinDrawBitmap(hps&, hbmp&, 0,_
                MakeLong(VARSEG(ClientRect), VARPTR(ClientRect)),_
                1, 0, DBMSTRETCH)
        bool% = WinEndPaint(hps&)

     CASE WMTIMER     'WMTIMER drives setup. SetupStage shows current state

        IF SetupStage% = 1 THEN      'SetupStage=1 copy main disk
           CALL StopTimer
           SetupStage% = -1
           MainTitleBar$ = "BASIC PM Setup:Copying Main Disk" + CHR$(0)
           CALL SetTitleBar(hwnd&, MainTitleBar$)
           CALL CopyMainDisk
           CALL StartTimer
        END IF

        IF SetupStage% = -1 THEN     'SetupStage=-1 waiting for main to finish
           fileSpec$ = DestDrive$ + BaseDir$ + "\DISKNAME.DAT"
           IF FileExists(fileSpec$) THEN  'Wait until DISKNAME.DAT is copied

              IF ExampleFlag% THEN
                 SetupStage% = 2          'SetupStage=2 for example
              ELSE
                 SetupStage% = 4          'SetupStage=4 for done
              END IF

              cmdFile$ = DestDrive$ + BaseDir$ + "\MAINDISK.CMD"
              KILL fileSpec$              'Delete DISKNAME.DAT and MAINDISK.CMD
              KILL cmdFile$
           END IF
        END IF

        IF (SetupStage% = 2) OR_           'SetupStage=2 copy 1st Example disk
           (SetupStage% = 3) THEN          'SetupStage=3 copy extra Exam disks
           CALL StopTimer
           IF SetupStage% = 2 THEN         'SetupStage=2 prompt for Disk #2
              Title$ = "Insert Disk" + CHR$(0)
              Caption$ = "Insert (First) EXAMPLE Disk (Disk #2), "+_
                         "then press Enter." + STRING$(2,13) + _
                         "NOTE:Another process will be started in the "+_
                         "foreground to copy the disk.  This process requires " +_
                         "XCOPY.EXE to be in your PATH." + CHR$(0)

              flStyle% = MBENTERCANCEL OR MBNOICON
           ELSE                            'SetupStage=3 ask if more disks
              Title$ = "More Disks?" + CHR$(0)
              Caption$ = "This package is designed to be dynamic.  That is, " + _
                         "as more examples become available, additional disks " +_
                         "can easily be added." + STRING$(2,13) +_
                         "If this edition contains additional EXAMPLES disks, " +_
                         "wait for the drive access to stop, insert next disk, " +_
                         "then press Enter." + STRING$(2,13) + _
                         "NOTE:Another process will be started in the "+_
                         "foreground to copy the disk.  This process requires " +_
                         "XCOPY.EXE to be in your PATH." + CHR$(0)

              'Default CANCEL for this one
              flStyle% = MBENTERCANCEL OR MBICONQUESTION OR MBDEFBUTTON2
           END IF
        wrong:                            'loop until correct disk
           bool% = DisplayMessageBox(caption$, title$, flStyle%)
           IF bool% = MBIDENTER THEN      'Copy current Example disk

              'Check the diskname is correct ("EXAM" 1st example, "MORE" extra)
              IF ((GetDiskName$ <> "EXAM") AND (SetupStage% = 2)) OR_
                 ((GetDiskName$ <> "MORE") AND (SetupStage% = 3)) THEN
                   title$ = "Wrong Disk" + CHR$(0)
                   caption$ = "Please insert correct disk and press Enter." + CHR$(0)
                   flStyle% = MBENTERCANCEL OR MBICONHAND
                   GOTO wrong
              END IF

              ExamTitleBar$ = "BASIC PM Setup:Copying Example Disk" + CHR$(0)
              SetupStage% = -2
              CALL SetTitleBar(hwnd&, ExamTitleBar$)
              CALL CopyExampleDisk
              CALL StartTimer

           ELSE               'If Disk CANCELed, Setup done (SetupStage=4)
              SetupStage% = 4
           END IF
        END IF

        IF SetupStage% = -2 THEN          'SetupStage=-2 wait for disk to copy

           fileSpec$ = DestDrive$ + BaseDir$   + "\DISKNAME.DAT"
           IF FileExists(fileSpec$) THEN     'Wait until DISKNAME.DAT is copied

              SetupStage% = 3
              cmdFile$ = DestDrive$ + BaseDir$ + ExampleDir$ + "\TREECOPY.CMD"
              diskname$= DestDrive$ + BaseDir$ + ExampleDir$ + "\DISKNAME.DAT"
              KILL fileSpec$              'Delete DISKNAME.DAT and MAINDISK.CMD
              KILL cmdFile$
              KILL diskname$              'extra DISKNAME.DAT from TREECOPY

           END IF

        END IF

        IF SetupStage% = 4 THEN          'SetupStage=4 setup done.
                                         'Stop timer, enable menus, ask to exit

           CALL StopTimer
           CALL SetTitleBar(hwnd&, InitTitleBar$)
           CALL DisableMenu(hwnd&, IDDRPATH, 0)
           CALL DisableMenu(hwnd&, IDSTART,  0)

           Title$   = "Done" + CHR$(0)
           Caption$ = "SETUP completed.  Exit SETUP?"+ CHR$(0)
           IF DisplayMessageBox%(Caption$, Title$,_
              MBYESNO OR MBICONQUESTION) = MBIDYES THEN
              bool% = WinPostMsg(hwnd&, WMQUIT, 0, 0)
           ELSE
              SetupStage% = 0             'SetupStage=0 idle state
           END IF
        END IF
        bool% = WinReleasePS(hps&)
     CASE ELSE        'Pass control to system for other messages
        ClientWndProc& = WinDefWindowProc(hwnd&, msg%, mp1&, mp2&)
     END SELECT

END FUNCTION

'****
'** ClientWndProc1 is the dialog procedure for setting drives and paths.
'**       WMINITDLG creates temp variables and sets items accordingly
'**       WMCOMMAND dismisses dialog or gets help
'**         BNOK checks for valid values, assigns if valid and dismisses
'**         BNCANCEL dismisses without changing global variables
'**         BNHELP displays help for the dialog box
'**       WMCONTROL toggles the checkboxes
FUNCTION ClientWndProc1& (hwnd&, msg%, mp1&, mp2&) STATIC

   ClientWndProc1& = 0
   SELECT CASE msg%

      CASE WMINITDLG          'WMINITDLG creates temp variables and sets items
         TempSourceDrive$ = SourceDrive$ + CHR$(0)
         TempDestDrive$   = DestDrive$   + CHR$(0)
         TempBaseDir$     = BaseDir$     + CHR$(0)
         TempIncludeDir$  = IncludeDir$  + CHR$(0)
         TempLibDir$      = LibDir$      + CHR$(0)
         TempCmdDir$      = CmdDir$      + CHR$(0)
         TempHelpDir$     = HelpDir$     + CHR$(0)
         TempUtilityDir$  = UtilityDir$  + CHR$(0)
         TempExampleDir$  = ExampleDir$  + CHR$(0)
         TempCmdFlag%     = CmdFlag%
         TempHelpFlag%    = HelpFlag%
         TempUtilityFlag% = UtilityFlag%
         TempExampleFlag% = ExampleFlag%
         bool% = WinSetDlgItemText(hwnd&, IDSOURCE,  FarSADD(TempSourceDrive$))
         bool% = WinSetDlgItemText(hwnd&, IDDEST,    FarSADD(TempDestDrive$))
         bool% = WinSetDlgItemText(hwnd&, IDBASE,    FarSADD(TempBaseDir$))
         bool% = WinSetDlgItemText(hwnd&, IDINCLUDE, FarSADD(TempIncludeDir$))
         bool% = WinSetDlgItemText(hwnd&, IDLIB,     FarSADD(TempLibDir$))
         bool% = WinSetDlgItemText(hwnd&, IDCMD,     FarSADD(TempCmdDir$))
         bool% = WinSetDlgItemText(hwnd&, IDHELP,    FarSADD(TempHelpDir$))
         bool% = WinSetDlgItemText(hwnd&, IDUTILITY, FarSADD(TempUtilityDir$))
         bool% = WinSetDlgItemText(hwnd&, IDEXAMPLE, FarSADD(TempExampleDir$))
         CALL SetCheck(hwnd&, IDCMD,     TempCmdFlag%)
         CALL SetCheck(hwnd&, IDHELP,    TempHelpFlag%)
         CALL SetCheck(hwnd&, IDUTILITY, TempUtilityFlag%)
         CALL SetCheck(hwnd&, IDEXAMPLE, TempExampleFlag%)
      CASE WMCOMMAND                'WMCOMMAND dismisses dialog or displays help

         CALL BreakLong(mp1&, hiword%, loword%)
         SELECT CASE loword%
            CASE BNOK               'BNOK checks values and assigns if Ok

               TempSourceDrive$ = STRING$(256,0)      'Allocate space for query
               TempDestDrive$   = STRING$(256,0)
               TempBaseDir$     = STRING$(256,0)
               TempCmdDir$      = STRING$(256,0)
               TempLibDir$      = STRING$(256,0)
               TempIncludeDir$  = STRING$(256,0)
               TempHelpDir$     = STRING$(256,0)
               TempUtilityDir$  = STRING$(256,0)
               TempExampleDir$  = STRING$(256,0)

               'Query dlg text
               CALL QueryDlgText(hwnd&, IDSOURCE,  TempSourceDrive$)
               CALL QueryDlgText(hwnd&, IDDEST,    TempDestDrive$)
               CALL QueryDlgText(hwnd&, IDBASE,    TempBaseDir$)
               CALL QueryDlgText(hwnd&, IDINCLUDE, TempIncludeDir$)
               CALL QueryDlgText(hwnd&, IDLIB,     TempLibDir$)
               CALL QueryDlgText(hwnd&, IDCMD,     TempCmdDir$)
               CALL QueryDlgText(hwnd&, IDHELP,    TempHelpDir$)
               CALL QueryDlgText(hwnd&, IDUTILITY, TempUtilityDir$)
               CALL QueryDlgText(hwnd&, IDEXAMPLE, TempExampleDir$)

               'Check drives amd directories
               source%  = ValidDrive(hwnd&, TempSourceDrive$, IDSOURCE)
               dest%    = ValidDrive(hwnd&, TempDestDrive$,   IDDEST)
               basedir% = ValidDir(hwnd&, TempBaseDir$,    BaseDir$,    IDBASE)
               cmd%     = ValidDir(hwnd&, TempCmdDir$,     CmdDir$,     IDINCLUDE)
               lib%     = ValidDir(hwnd&, TempLibDir$,     LibDir$,     IDLIB)
               include% = ValidDir(hwnd&, TempIncludeDir$, IncludeDir$, IDCMD)
               utility% = ValidDir(hwnd&, TempHelpDir$,    HelpDir$,    IDHELP)
               helpdir% = ValidDir(hwnd&, TempUtilityDir$, UtilityDir$, IDUTILITY)
               example% = ValidDir(hwnd&, TempExampleDir$, ExampleDir$, IDEXAMPLE)
               IF source%  AND dest%    AND basedir% AND cmd%     AND_
                  lib%     AND include% AND helpdir% AND example% THEN
                  SourceDrive$ = TempSourceDrive$
                  DestDrive$   = TempDestDrive$
                  BaseDir$     = TempBaseDir$
                  CmdDir$      = TempCmdDir$
                  LibDir$      = TempLibDir$
                  IncludeDir$  = TempIncludeDir$
                  HelpDir$     = TempHelpDir$
                  UtilityDir$  = TempUtilityDir$
                  ExampleDir$  = TempExampleDir$
                  CmdFlag%     = TempCmdFlag%
                  HelpFlag%    = TempHelpFlag%
                  UtilityFlag% = TempUtilityFlag%
                  ExampleFlag% = TempExampleFlag%
                  bool%        = WinDismissDlg(hwnd&, -1)
               END IF
            CASE BNCANCEL            'BNCANCEL dismisses without changing
               bool%    = WinDismissDlg(hwnd&, -1)
            CASE BNHELP              'BNHELP brings up help for the dialog

               bool% = WinDlgBox(HWNDDESKTOP, hwnd&, 0, 0, BNHELP, 0)

            CASE ELSE
         END SELECT
      CASE WMCONTROL                   'WMCONTROL toggles the checkboxes
         CALL BreakLong(mp1&, hiword%, loword%)
         SELECT CASE loword%
            CASE 26
               CALL ToggleFlag(hwnd&, IDCMD,     TempCmdFlag%)
            CASE 27
               CALL ToggleFlag(hwnd&, IDHELP,    TempHelpFlag%)
            CASE 28
               CALL ToggleFlag(hwnd&, IDUTILITY, TempUtilityFlag%)
            CASE 29
               CALL ToggleFlag(hwnd&, IDEXAMPLE, TempExampleFlag%)
            CASE ELSE
         END SELECT
      CASE ELSE        'Pass control to system for other messages
         ClientWndProc1& = WinDefDlgProc(hwnd&, msg%, mp1&, mp2&)

   END SELECT

END FUNCTION

'****************************************************************
'*
'*                      Setup Routines
'*
'****************************************************************

'****
'** CopyMainDisk copies the first disk (labeled "MAIN").
'**
'** The flow is as follows:
'**
'**     1) Prompt user for disk
'**     2) Check for correct disk
'**     3) Create directories
'**     4) Modify PMBC.CMD files
'**     5) Create NewVars.SYS
'**     6) Create MAINDISK.CMD
'**     7) Shell function to start MAINDISK.CMD
SUB CopyMainDisk

   '* Prompt user for disk
   Title$   = "Insert Disk" + CHR$(0)
   Caption$ = "Insert MAIN Disk (Disk #1), " +_
              "then press Enter." + STRING$(2,13) + _
              "NOTE: Another process will be started in the "+_
              "background to copy the disk." + CHR$(0)
main:
   bool% = DisplayMessageBox(caption$, title$, MBENTERCANCEL OR MBNOICON)
   IF bool% = MBIDCANCEL THEN
      SetupStage% = 4
      EXIT SUB
   END IF

   '* Check for correct disk
   IF GetDiskName$ <> "MAIN" THEN
      title$ = "Wrong Disk" + CHR$(0)
      caption$ = "Please insert correct disk and press Enter." + CHR$(0)
      GOTO main
   END IF

   '* Create directories
   CALL CreateDirs
   IF DirError% THEN     'If error, stop setup and exit
      SetupStage% = 4
      EXIT SUB
   END IF

   IF CmdFlag% THEN           '* If CmdFlag is chosen, Modify PMBC.CMD files
      CALL ModifyCmdFiles
   END IF

   CALL CreateNewVars         '* Create NEW-VARS.SYS

   '* Create MAINDISK.CMD
   src$ = SourceDrive$
   dst$ = DestDrive$ + BaseDir$
   cmdFile$ = dst$ + "\MAINDISK.CMD"

   OPEN cmdFile$ FOR OUTPUT AS #1
      PRINT #1, "COPY "+src$+"\LIB " + dst$ + LibDir$
      PRINT #1, "COPY "+src$+"\INCLUDE " + dst$ + IncludeDir$

      IF HelpFlag% THEN
         PRINT #1, "COPY "+src$+"\HELP " + dst$ + HelpDir$
      END IF

      IF UtilityFlag% THEN
         PRINT #1, "COPY "+src$+"\UTILITY " + dst$ + UtilityDir$
      END IF
      PRINT #1, "COPY "+src$+"\SKELETON.* " + dst$ + "\CODE"
      PRINT #1, "COPY "+src$+"\DISKNAME.DAT " + dst$
      PRINT #1, "EXIT"
   CLOSE #1

   '* Shell function to start MAINDISK.CMD
   pid% = SHELL("START " + cmdFile$)

END SUB

'****
'** CopyExampleDisk is used to copy all example disks. It creates TREECOPY.CMD
'** which uses XCOPY (user is warned of this) and uses the Shell function to
'** start the command file in the foreground.
'**
'** The XCOPY command will copy all subdirectories and is thus optimal for
'** copying the example disks, where directory structure can vary.
SUB CopyExampleDisk
      src$ = SourceDrive$
      dst$ = DestDrive$ + BaseDir$ + ExampleDir$
      TreeCopy$ = dst$ + "\TREECOPY.CMD"
      OPEN TreeCopy$ FOR OUTPUT AS #1
         cmdline$ = "XCOPY " + src$ + "\ "+ dst$ + " /s"
         PRINT #1, cmdline$
         cmdline$ = "COPY "+ src$ + "\DISKNAME.DAT "+_
                    DestDrive$ + BaseDir$
         PRINT #1, cmdline$
         PRINT #1, "EXIT"
      CLOSE #1
      cmdline$ = "Start /f " + TreeCopy$
      pid% = SHELL(cmdline$)
END SUB

'****
'** ModifyCmdFiles reads the 4 PMBC.CMD files from the Main Disk and
'** modifies (with Replace$) the INCLUDE and CODE directories to the
'** paths set in the dialog box.  The modified files are written to
'** the Cmd directory.
SUB ModifyCmdFiles
   DIM Cmd$(3)
   Cmd$(0) = "\PMBC.CMD"
   Cmd$(1) = "\PMBCD.CMD"
   Cmd$(2) = "\PMBCR.CMD"
   Cmd$(3) = "\PMBCRD.CMD"

   src$ = SourceDrive$
   dst$ = DestDrive$ + BaseDir$ + CmdDir$
   inc$ = DestDrive$ + BaseDir$ + IncludeDir$
   cod$ = DestDrive$ + BaseDir$ + "\CODE"

   FOR f% = 0 TO 3
      OPEN src$+Cmd$(f%) FOR INPUT AS #1
      OPEN dst$+Cmd$(f%) FOR OUTPUT AS #2
         WHILE NOT(EOF(1))
            LINE INPUT #1, CmdLine$
            CmdLine$ = Replace$(CmdLine$, "C:\PMBASIC\INCLUDE", inc$)
            CmdLine$ = Replace$(CmdLine$, "C:\PMBASIC\CODE",    cod$)
            PRINT #2, CmdLine$
         WEND
      CLOSE #2
      CLOSE #1
   NEXT f%
END SUB

'****
'** CreateNewVars writes out a file containing the values which need to
'** be added to the user's CONFIG.SYS
SUB CreateNewVars
   NewVars$ = DestDrive$ + BaseDir$ + "\NEW-VARS.SYS"
   dest$    = DestDrive$
   base$    = BaseDir$
   cmd$     = dest$ + base$ + CmdDir$
   lib$     = dest$ + base$ + LibDir$
   include$ = dest$ + base$ + IncludeDir$
   help$    = dest$ + base$ + HelpDir$
   OPEN NewVars$ FOR OUTPUT AS #1
      PRINT #1, "REM This file contains the values to be added to environment"
      PRINT #1, "REM variables in your CONFIG.SYS"
      PRINT #1,
      PRINT #1, "REM %xx% is the current value for environment variable xx"
      PRINT #1,
      IF CmdFlag% THEN
         PRINT #1, "SET PATH=%PATH%;";cmd$
      END IF
      PRINT #1, "SET LIB=%LIB%;";lib$
      IF HelpFlag% THEN
         PRINT #1, "SET QH=%QH%;";help$
      END IF
      PRINT #1,
      PRINT #1, "REM INCLUDE path not used with BASIC Compiler 6.00"
      PRINT #1, "SET INCLUDE=%INCLUDE%;";include$
   CLOSE #1
END SUB

'**********************************************************
'*
'*                 File/Directory Routines
'*
'**********************************************************

'****
'** CreateDirs creates each of the directories needed for Setup
SUB CreateDirs
   sBaseDir$ = BaseDir$
   CALL MakeDir(BaseDir$)
   IF DirError% THEN EXIT SUB
   IF CmdFlag% THEN
      CALL MakeDir(sBaseDir$  +  CmdDir$    )
      IF DirError% THEN EXIT SUB
   END IF
   CALL MakeDir(sBaseDir$  +  LibDir$    )
   IF DirError% THEN EXIT SUB
   CALL MakeDir(sBaseDir$  +  IncludeDir$)
   IF DirError% THEN EXIT SUB
   IF HelpFlag% THEN
      CALL MakeDir(sBaseDir$  +  HelpDir$   )
      IF DirError% THEN EXIT SUB
   END IF
   IF UtilityFlag% THEN
      CALL MakeDir(sBaseDir$  +  UtilityDir$)
      IF DirError% THEN EXIT SUB
   END IF
   IF ExampleFlag% THEN
      CALL MakeDir(sBaseDir$  +  ExampleDir$)
      IF DirError% THEN EXIT SUB
   END IF
   CALL MakeDir(sBaseDir$ + "\CODE")
END SUB

'****
'** MakeDir resets the error flag and creates the directory.
SUB MakeDir (dir$)
   DirError% = 0
   MKDIR DestDrive$ + dir$
END SUB

'****
'** ValidDrive checks to see that the drive could be valid.  It does not
'** check to see if the drive exists, only if it is valid.  This is done
'** by checking the Length = 2, first char is letter, and last char is ":".
FUNCTION ValidDrive%(hwnd&, drive$, id%)
   ValidDrive% = -1
   IF (LEN  (drive$)     = 2)   AND (LEFT$ (drive$, 1) >= "A") AND_
      (LEFT$(drive$, 1) <= "Z") AND (RIGHT$(drive$, 1)  = ":") THEN
      ValidDrive% = -1
   ELSE
      Title$    = "Set Drives/Paths" + CHR$(0)
      Caption$  = "Invalid source drive:  " + drive$ + CHR$(13)+_
                  "Reenter."   + CHR$(0)
      bool%     = DisplayMessageBox(Caption$, Title$, MBOK OR MBICONHAND)
      drive$    = SourceDrive$ + CHR$(0)
      bool%     = WinSetDlgItemText(hwnd&, id%, FarSADD(TempSourcedrive$))
      ValidDrive% = 0
   END IF
END FUNCTION

'****
'** ValidDir does some simple checks of the directory name.
'** Directories must begin with a backslash and need not
'** contain the base directory.  Other errors in directory
'** names are caught with ON ERROR.
FUNCTION ValidDir%(hwnd&, new$, old$, id%)
   ValidDir% = -1
   IF LEN  (new$)   =   0  THEN EXIT FUNCTION
   IF LEFT$(new$,1) <> "\" THEN
      Title$    = "Set Drives/Paths" + CHR$(0)
      Caption$  = "Invalid directory:  " +_
                  new$ + STRING$(2,13)+_
                  "Directories must begin with a backslash (\). "+_
                  "Reenter." + CHR$(0)
      bool%     = DisplayMessageBox(Caption$, Title$, MBOK OR MBICONHAND)
      new$      = old$ + CHR$(0)
      bool%     = WinSetDlgItemText(hwnd&, id%, FarSADD(new$))
      ValidDir% = 0
      EXIT FUNCTION
   END IF
   IF (id%<>3) AND INSTR(new$,BaseDir$) THEN
      Title$    = "Set Drives/Paths" + CHR$(0)
      Caption$  = "Invalid directory:  " +_
                  new$ + CHR$(13)+_
                  "Subdirectories do not require repetition of base directory." + CHR$(13)+_
                  "Reenter." + CHR$(0)
      bool%     = DisplayMessageBox(Caption$, Title$, MBOK OR MBICONHAND)
      new$      = old$ + CHR$(0)
      bool%     = WinSetDlgItemText(hwnd&, id%, FarSADD(new$))
      ValidDir% = 0
   END IF
END FUNCTION

'****
'** FileExists uses DosFindFirst to see if a file exists.  This is used
'** to check when a process is finished; in which case, Setup will go on
'** to the next disk.
FUNCTION FileExists%(filespec$)
        DIM ffb AS FILEFINDBUF
        temp$ = filespec$ + CHR$(0)
        phdir%= 1
        usBL% = 36
        usSC% = 1
        ulR&  = 0
        att%  = 0 + 2 + 4 + 16    'Normal, hidden, directory and system
        FileExists% = (DosFindFirst(VARSEG(temp$), SADD(temp$),_
                       phdir%, att%, ffb, usBL%, usSC%, ulR&) = 0)
END FUNCTION

'****
'** GetDiskName gets the name of the source disk from a file. This is used
'** to check to make sure the correct disk is in the drive.
'**
'** Correct values are:
'**
'**       MAIN
'**       EXAM
'**       MORE
FUNCTION GetDiskName$
   fileName$ = SourceDrive$ + "\DISKNAME.DAT"
   OPEN fileName$ FOR INPUT AS #1
      LINE INPUT #1, temp$
   CLOSE #1
   GetDiskName$ = UCASE$(temp$)
END FUNCTION

'**********************************************************
'*
'*                     String Routines
'*
'**********************************************************

'****
'** Replace does a standard search and replace. It is used
'** in ModifyCmdFiles.
FUNCTION Replace$ (full$, oldPart$, newPart$)
  Return$ = ""
  temp$ = full$
  DO
    f% = INSTR(Temp$, oldPart$)
    IF f% = 0 THEN
      Return$ = Return$ + temp$
      EXIT DO
    END IF
    Return$ = Return$ + LEFT$(temp$, f% - 1) + newPart$
    temp$ = MID$(temp$, f% + LEN(oldPart$))
  LOOP
  Replace$ = Return$
END FUNCTION

'****
'** FarSADD returns the far string address (selector and offset).
'** It is used to make code more readable and smaller.
FUNCTION FarSADD&(s$)
   FarSADD& = MakeLong(VARSEG(s$), SADD(s$))
END FUNCTION

'***********************************************************
'*
'*              PM Readability Routines
'*
'*  Each of the following routines performs one simple task
'*  to make main Setup code more readable.  The name of each
'*  function describes what it does.
'***********************************************************

FUNCTION DisplayMessageBox%(message$, caption$, flStyle%)
  DisplayMessageBox% = WinMessageBox(HWNDDESKTOP, HWNDDESKTOP,_
                       FarSADD(message$), FarSADD(caption$), 0,_
                       flStyle% OR MBAPPLMODAL)
END FUNCTION

SUB StartTimer
   bool% = WinStartTimer(hab&, hwndClient&, 1, 2000)
END SUB

SUB StopTimer
   bool% = WinStopTimer(hab&, hwndClient&, 1)
END SUB

SUB SetTitleBar(hwnd&, text$)
   hwndParent& = WinQueryWindow  (hwnd&, QWPARENT, 0)
   hwndTitle&  = WinWindowFromID (hwndParent&, FIDTITLEBAR)
   bool%       = WinSetWindowText(hwndTitle&, FarSADD(text$))
END SUB

SUB DisableMenu(hwnd&, id%, flag%)
   hwndParent& = WinQueryWindow (hwnd&, QWPARENT, 0)
   hwndMenu&   = WinWindowFromID(hwndParent&, FIDMENU)
   bool%       = WinSendMsg     (hwndMenu&, MMSETITEMATTR,_
                 MakeLong(1, id%), MakeLong(flag%, MIADISABLED))
END SUB

SUB SetCheck(hwnd&, id%, flag%)
   bool% = WinSendDlgItemMsg(hwnd&, IDCHECK + id%, BMSETCHECK, flag%, 0)
END SUB

SUB ToggleFlag(hwnd&, id%, flag%)
   flag% = NOT(flag%)
   CALL SetCheck(hwnd&, id%, flag%)
END SUB

SUB QueryDlgText(hwnd&, id%, text$)
   length% = WinQueryDlgItemText(hwnd&, id%, 256, FarSADD(text$))
   text$ = UCASE$(LEFT$(text$ , length%))
END SUB
