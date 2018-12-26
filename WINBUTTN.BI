'**************************************************************
'*
'* Include File: WinButtn.BI
'*
'* Requires:     none
'*
'* Description:  Button control constants and types
'*
'*************************************************************

' Button control styles 

CONST BSPUSHBUTTON       =&H00000000&
CONST BSCHECKBOX         =&H00000001&
CONST BSAUTOCHECKBOX     =&H00000002&
CONST BSRADIOBUTTON      =&H00000003&
CONST BSAUTORADIOBUTTON  =&H00000004&
CONST BS3STATE           =&H00000005&
CONST BSAUTO3STATE       =&H00000006&

CONST BSUSERBUTTON       =&H00000007&

CONST BSHELP             = &H0100&
CONST BSSYSCOMMAND       = &H0200&
CONST BSDEFAULT          = &H0400&
CONST BSNOPOINTERFOCUS   = &H0800&
CONST BSNOBORDER         = &H1000&


' Button class name 

CONST WCBUTTON       = &Hffff0003&


TYPE BTNCDATA
    cb AS INTEGER
    fsCheckState AS INTEGER
    fsHiliteState AS INTEGER
END TYPE

' User button structure (passed in WMCONTROL msg) 

TYPE USERBUTTON
    hwnd AS LONG
    hps AS LONG
    fsState AS INTEGER
    fsStateOld AS INTEGER
END TYPE

' Button control messages 

CONST BMCLICK            = &H0120
CONST BMQUERYCHECKINDEX  = &H0121
CONST BMQUERYHILITE      = &H0122
CONST BMSETHILITE        = &H0123
CONST BMQUERYCHECK       = &H0124
CONST BMSETCHECK         = &H0125
CONST BMSETDEFAULT       = &H0126

' Button notification codes 

CONST BNCLICKED          =1
CONST BNDBLCLICKED       =2
CONST BNPAINT            =3

' BNPAINT button draw state codes (must be in high byte) 

CONST BDSHILITED         = &H0100
CONST BDSDISABLED        = &H0200
CONST BDSDEFAULT         = &H0400
