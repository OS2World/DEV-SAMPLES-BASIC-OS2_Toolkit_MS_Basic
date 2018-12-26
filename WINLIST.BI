'**************************************************************
'*
'* Include File: WinList.BI
'*
'* Requires:     none
'*
'* Description:  List box constants
'*
'*************************************************************

' List box styles 

CONST LSMULTIPLESEL      = &H00000001&

CONST LSOWNERDRAW        = &H00000002&

CONST LSNOADJUSTPOS      = &H00000004&


' Listbox class name 

CONST WCLISTBOX      = &HFFFF0007&

' List box notification messages 

CONST LNSELECT           =1
CONST LNSETFOCUS         =2
CONST LNKILLFOCUS        =3
CONST LNSCROLL           =4
CONST LNENTER            =5

' List box messages 

CONST LMQUERYITEMCOUNT   = &H0160
CONST LMINSERTITEM       = &H0161
CONST LMSETTOPINDEX      = &H0162
CONST LMDELETEITEM       = &H0163
CONST LMSELECTITEM       = &H0164
CONST LMQUERYSELECTION   = &H0165
CONST LMSETITEMTEXT      = &H0166
CONST LMQUERYITEMTEXTLENGTH = &H0167
CONST LMQUERYITEMTEXT    = &H0168

CONST LMSETITEMHANDLE    = &H0169
CONST LMQUERYITEMHANDLE  = &H016a
CONST LMSEARCHSTRING     = &H016b
CONST LMSETITEMHEIGHT    = &H016c
CONST LMQUERYTOPINDEX    = &H016d
CONST LMDELETEALL        = &H016e

' List box constants 

CONST LITERROR            =-3
CONST LITMEMERROR         =-2
CONST LITNONE             =-1
CONST LITFIRST            =-1

' For LMINSERTITEM msg     

CONST LITEND              =-1
CONST LITSORTASCENDING    =-2
CONST LITSORTDESCENDING   =-3

' For LMSEARCHSTRING msg     

CONST LSSSUBSTRING       = &H0001
CONST LSSPREFIX          = &H0002
CONST LSSCASESENSITIVE   = &H0004
