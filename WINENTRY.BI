'**************************************************************
'*
'* Include File: WinEntry.BI
'*
'* Requires:     none
'*
'* Description:  EntryField control constants and types
'*
'*************************************************************

'*** Entryfield controls Subsection 

' Entry field  styles 

CONST ESLEFT             = &H00000000&
CONST ESCENTER           = &H00000001&
CONST ESRIGHT            = &H00000002&

CONST ESAUTOSCROLL       = &H00000004&

CONST ESMARGIN           = &H00000008&

CONST WCENTRYFIELD     = &Hffff0006&

TYPE ENTRYFDATA
    cb AS INTEGER
    cchEditLimit AS INTEGER
    ichMinSel AS INTEGER
    ichMaxSel AS INTEGER
END TYPE


' Entry Field  messages 

CONST EMQUERYCHANGED     = &H0140
CONST EMQUERYSEL         = &H0141
CONST EMSETSEL           = &H0142
CONST EMSETTEXTLIMIT     = &H0143

CONST EMCUT              = &H0144
CONST EMCOPY             = &H0145
CONST EMCLEAR            = &H0146
CONST EMPASTE            = &H0147
CONST EMQUERYFIRSTCHAR   = &H0148
CONST EMSETFIRSTCHAR     = &H0149

' Entry Field  notification messages 

CONST ENSETFOCUS         = &H0001
CONST ENKILLFOCUS        = &H0002
CONST ENCHANGE           = &H0004
CONST ENSCROLL           = &H0008
CONST ENMEMERROR         = &H0010
