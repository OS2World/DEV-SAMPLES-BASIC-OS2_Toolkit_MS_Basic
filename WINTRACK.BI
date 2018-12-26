'**************************************************************
'*
'* Include File: WinTrack.BI
'*
'* Requires:     PMBase.BI (RECTL type)
'*               OS2Def.BI (POINTL type)
'*
'* Description:  Tracking rectangle manager
'*
'*************************************************************

' WinTrackRect() tracking information structure 

TYPE TRACKINFO 
    cxBorder AS INTEGER
    cyBorder AS INTEGER
    cxGrid AS INTEGER
    cyGrid AS INTEGER
    cxKeyboard AS INTEGER
    cyKeyboard AS INTEGER
    rclTrack AS RECTL
    rclBoundary AS RECTL
    ptlMinTrackSize AS POINTL
    ptlMaxTrackSize AS POINTL
    fs AS INTEGER
    cxLeft AS INTEGER
    cyBottom AS INTEGER
    cxRight AS INTEGER
    cyTop AS INTEGER
END TYPE

DECLARE FUNCTION WinTrackRect%(BYVAL hwnd AS LONG,_
                               BYVAL hps AS LONG,_
                               BYVAL pti AS LONG)

DECLARE FUNCTION WinShowTrackRect%(BYVAL hwnd AS LONG,_
                                   BYVAL fShow AS INTEGER)

' WinTrackRect() flags 

CONST TFLEFT              = &H0001
CONST TFTOP               = &H0002
CONST TFRIGHT             = &H0004
CONST TFBOTTOM            = &H0008
' TFMOVE = TFLEFT | TFTOP | TFRIGHT | TFBOTTOM 
CONST TFMOVE              = &H000F

CONST TFSETPOINTERPOS     = &H0010
CONST TFGRID              = &H0020
CONST TFSTANDARD          = &H0040
CONST TFALLINBOUNDARY     = &H0080
CONST TFVALIDATETRACKRECT = &H0100
CONST TFPARTINBOUNDARY    = &H0200

' Special rectangle relative flags 
CONST TFFIXLEFT	     = &H0400
CONST TFFIXTOP	     = &H0800
CONST TFFIXRIGHT	     = &H1000
CONST TFFIXBOTTOM	     = &H2000
