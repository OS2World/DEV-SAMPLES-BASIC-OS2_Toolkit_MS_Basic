'**************************************************************
'*
'* Include File: WinHook.BI
'*
'* Requires:     none
'*
'* Description:  Hook manager
'*
'*************************************************************

DECLARE FUNCTION WinSetHook%(BYVAL hab AS LONG,_
                             BYVAL hmq AS LONG,_
                             BYVAL iHook AS INTEGER,_
                             BYVAL pfnHook AS LONG,_
                             BYVAL hmod AS INTEGER)

DECLARE FUNCTION WinReleaseHook%(BYVAL hab AS LONG,_
                                 BYVAL hmq AS LONG,_
                                 BYVAL iHook AS INTEGER,_
                                 BYVAL pfnHook AS LONG,_
                                 BYVAL hmod AS INTEGER)

DECLARE FUNCTION WinCallMsgFilter%(BYVAL hab AS LONG,_
                                   BYVAL pqmsg AS LONG,_
                                   BYVAL msgf AS INTEGER)


' Hook codes 

CONST HKSENDMSG          =0
CONST HKINPUT            =1
CONST HKMSGFILTER        =2
CONST HKJOURNALRECORD    =3
CONST HKJOURNALPLAYBACK  =4
CONST HKHELP             =5


CONST HMQCURRENT         =1&

' WHMSGFILTER context codes 

CONST MSGFDIALOGBOX      =1
CONST MSGFMESSAGEBOX     =2
CONST MSGFTRACK          =8

' HKHELP Help modes 

CONST HLPMFRAME          =-1
CONST HLPMWINDOW         =-2
CONST HLPMMENU           =-3

' HKSENDMSG structure 

TYPE SMHSTRUCT
    mp2 AS LONG
    mp1 AS LONG
    msg AS INTEGER
    hwnd AS LONG
END TYPE
