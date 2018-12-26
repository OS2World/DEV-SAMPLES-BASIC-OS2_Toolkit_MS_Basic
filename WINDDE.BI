'**************************************************************
'*
'* Include File: WinDDE.BI
'*
'* Requires:     none
'*
'* Description:  Dynamic Data Exchange manager
'*
'*************************************************************

' Dynamic Data Exchange (DDE) Structure Declaration

TYPE DDEINIT
    cb AS INTEGER
    pszAppName AS LONG
    pszTopic AS LONG
END TYPE
    
TYPE DDESTRUCT
    cbData AS LONG
    fsStatus AS INTEGER
    usFormat AS INTEGER
    offszItemName AS INTEGER
    offabData AS INTEGER
END TYPE

' DDE constants for wStatus field 
CONST DDEFACK            = &H0001
CONST DDEFBUSY           = &H0002
CONST DDEFNODATA         = &H0004
CONST DDEFACKREQ         = &H0008
CONST DDEFRESPONSE       = &H0010
CONST DDENOTPROCESSED    = &H0020
CONST DDEFRESERVED       = &H00C0
CONST DDEFAPPSTATUS      = &HFF00

' DDE public formats 

CONST DDEFMTTEXT         = &H0001

' Dynamic Data Exchange (DDE) Routines 

DECLARE FUNCTION WinDdeInitiate%(BYVAL hwndClient AS LONG,_
                                 BYVAL pszAppName AS LONG,_
                                 BYVAL pszTopicName AS LONG)

DECLARE FUNCTION WinDdeRespond&(BYVAL hwndClient AS LONG,_
                                BYVAL hwndServer AS LONG,_
                                BYVAL pszAppName AS LONG,_
                                BYVAL pszTopicName AS LONG)

DECLARE FUNCTION WinDdePostMsg%(BYVAL hwndTo AS LONG,_
                                BYVAL hwndFrom AS LONG,_
                                BYVAL wm AS INTEGER,_
                                BYVAL pDdest AS LONG,_
                                BYVAL fRetry AS INTEGER)


 ' Dynamic Data Exchange (DDE) Messages 

CONST WMDDEFIRST        = &H00A0
CONST WMDDEINITIATE     = &H00A0
CONST WMDDEREQUEST      = &H00A1
CONST WMDDEACK          = &H00A2
CONST WMDDEDATA         = &H00A3
CONST WMDDEADVISE       = &H00A4
CONST WMDDEUNADVISE     = &H00A5
CONST WMDDEPOKE         = &H00A6
CONST WMDDEEXECUTE      = &H00A7
CONST WMDDETERMINATE    = &H00A8
CONST WMDDEINITIATEACK  = &H00A9
CONST WMDDELAST         = &H00AF

CONST WMQUERYCONVERTPOS  = &H00b0

' Return values for WMQUERYCONVERTPOS 
CONST QCPCONVERT         = &H0001
CONST QCPNOCONVERT       = &H0000
