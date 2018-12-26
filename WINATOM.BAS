'************************************************************************
'* 
'* Program Name: WinAtom.BAS
'*
'* Include File: WinMisc.BI
'*
'* Functions   :
'*               WinCreateAtomTable
'*               WinDestroyAtomTable
'*               WinAddAtom
'*               WinFindAtom
'*               WinDeleteAtom
'*               WinQueryAtomLenght
'*               WinQueryAtomName
'*               WinQuerySystemAtomTable
'*
'* Description : This program demonstrates how to use an atom table
'*               Since these functions have no visible effect, the
'*               information is written to a data file ("WinAtom.OUT").
'*               Atom tables can be useful in reducing your string space
'*               usage by storing strings as two-byte atoms.
'************************************************************************

'*********         Initialization section        ***********

REM $INCLUDE: 'PMBase.BI'
REM $INCLUDE: 'WinMisc.BI'

CONST KByte = 1024

DIM aqmsg AS QMSG

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
             0,_            'Optional: Specify Resource ID here
             MakeLong (VARSEG(hwndClient&), VARPTR(hwndClient&)))

'**************       WinAtom        **************

OPEN "WinAtom.OUT" FOR OUTPUT AS #1

FirstAtom$  = "This is a very long first atom which will be stored as 2 bytes" + CHR$(0)
SecondAtom$ = "This is a second atom which will also be stored as 2 bytes" + CHR$(0)

' Creating 32K Atom table:
      HAtom&  =  WinCreateAtomTable (32 * KByte, 0)
      PRINT #1, "WinCreateAtomTable:", HEX$(HAtom&)

' Adding Atoms to Atom table:
      Atom1% = WinAddAtom (HAtom&,_
	       MakeLong(VARSEG(FirstAtom$), SADD(FirstAtom$)))
      PRINT #1, "WinAddAtom:", HEX$(Atom1%)
      PRINT #1, FirstAtom$

      Atom2% = WinAddAtom (HAtom&,_
	       MakeLong(VARSEG(SecondAtom$), SADD(SecondAtom$)))
      PRINT #1, "WinAddAtom is ", HEX$(Atom2%)
      PRINT #1, SecondAtom$

' Checking Find values
      ShouldBe1st% = WinFindAtom (HAtom&,_
                     MakeLong(VARSEG(FirstAtom$),  SADD(FirstAtom$)))
      ShouldBe2nd% = WinFindAtom (HAtom&,_
		     MakeLong(VARSEG(SecondAtom$), SADD(SecondAtom$)))
      PRINT #1, "WinFindAtom:"
      PRINT #1, "First atom:  "; HEX$(Atom1%); " ?= ";HEX$(ShouldBe1st%)
      PRINT #1, "Second atom: "; HEX$(Atom2%); " ?= ";HEX$(ShouldBe2nd%)

' Add first Atom to the Atom table to increase usage count:
      Atom%  = WinAddAtom (HAtom&,_
	       MakeLong(VARSEG(FirstAtom$), SADD(FirstAtom$)))
      Usage% = WinQueryAtomUsage (HAtom&, Atom%)
      PRINT #1, "WinQueryAtomUsage:", Usage%

' Delete Atom from Atom table:
      Deleted% = WinDeleteAtom (HAtom&, Atom1%)
      Usage%   = WinQueryAtomUsage (HAtom&, Atom1%)
      PRINT #1, "WinDeleteAtom:",     deleted%
      PRINT #1, "WinQueryAtomUsage:", Usage%

' Query Atom length:
      Length1% = WinQueryAtomLength (HAtom&, Atom1%)
      PRINT #1,"1st WinQueryAtomLength:", Length1%
      Buffer1$ = SPACE$(Length1%) + chr$(0)

      Length2% = WinQueryAtomLength (HAtom&, Atom2%)
      PRINT #1,"2nd WinQueryAtomLength:", Length2%
      Buffer2$ = SPACE$(Length2%) + chr$(0)

' Query Atom Name:
      NL% = WinQueryAtomName (HAtom&,_
	    Atom1%,_
	    MakeLong(VARSEG(Buffer1$), SADD(Buffer1$)),_
	    Length1% + 1)
      PRINT #1, "1st WinQueryAtomName:", NL%
      PRINT #1, Buffer1$

      NL% = WinQueryAtomName(HAtom&,_
	    Atom2%,_
	    MakeLong(VARSEG(Buffer2$), SADD(Buffer2$)),_
	    Length2% + 1)
      PRINT #1, "2nd WinQueryAtomName:", NL%
      PRINT #1, Buffer2$

' Query System Atom table:
      SysHAtom& = WinQuerySystemAtomTable&
      PRINT #1,  "WinQuerySystemAtomTable:", HEX$(SysHAtom&)

' Destroy Atom table (works):
      HAtom&  =  WinDestroyAtomTable (HAtom&)
      PRINT #1, "WinDestroyAtomTable:", HEX$(HAtom&)

' Show string space difference
      PRINT #1, "String space with strings allocated:    ";HEX$(FRE(""))
      FirstAtom$  = ""
      SecondAtom$ = ""
      PRINT #1, "String space without strings allocated: ";HEX$(FRE(""))

CLOSE #1

'**************         Message loop         ***************

WHILE WinGetMsg(hab&, MakeLong(VARSEG(aqmsg), VARPTR(aqmsg)), 0, 0, 0)
  bool% = WinDispatchMsg(hab&, MakeLong(VARSEG(aqmsg), VARPTR(aqmsg)))
WEND

'***********         Finalize section        ***************

bool% = WinDestroyWindow   (hwndFrame&)
bool% = WinDestroyMsgQueue (hmq&)
bool% = WinTerminate       (hab&)

END

'***********         Window procedure        ***************

FUNCTION ClientWndProc& (hwnd&, msg%, mp1&, mp2&) STATIC
     DIM ClientRect AS RECTL
     ClientWndProc& = 0
     SELECT CASE msg%
     CASE WMPAINT     'Paint the window with background color
        hps&  = WinBeginPaint(hwnd&, 0,_
                MakeLong(VARSEG(ClientRect), VARPTR(ClientRect)))
        bool% = WinFillRect(hps&,_
                MakeLong(VARSEG(ClientRect), VARPTR(ClientRect)),0)
        bool% = WinEndPaint(hps&)
     CASE ELSE	      'Pass control to system for other messages
        ClientWndProc& = WinDefWindowProc(hwnd&, msg%, mp1&, mp2&)
     END SELECT
END FUNCTION
