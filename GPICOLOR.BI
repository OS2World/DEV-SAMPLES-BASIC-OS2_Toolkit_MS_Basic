'**************************************************************
'*
'* Include File: GpiColor.BI
'*
'* Requires:     none
'*
'* Description:  Color Manager
'*
'**************************************************************

'  options for GpiCreateLogColorTable and others
CONST  LCOLRESET      =        &H0001
CONST  LCOLREALIZABLE =        &H0002
CONST  LCOLPURECOLOR  =        &H0004

'  format of logical lColor table for GpiCreateLogColorTable and others
CONST  LCOLFDEFAULT   =        0
CONST  LCOLFINDRGB    =        1
CONST  LCOLFCONSECRGB =        2
CONST  LCOLFRGB       =        3

'  options for GpiQueryRealColors and others
CONST  LCOLOPTREALIZED =      &H0001
CONST  LCOLOPTINDEX    =      &H0002

'  return codes from GpiQueryLogColorTable to indicate it is in RGB mode
CONST  QLCTERROR =  -1
CONST  QLCTRGB	 =  -2

'  GpiQueryLogColorTable index returned for colors not explicitly loaded
CONST  QLCTNOTLOADED = -1

'  return code on GpiQueryLogColorTable,GpiQueryRealColors and GpiQueryPel
CONST  CLRNOINDEX = -254

'  return codes for GpiQueryColorData
CONST  QCDLCTFORMAT  =	0
CONST  QCDLCTLOINDEX =	1
CONST  QCDLCTHIINDEX =	2

' ** global primitive functions
DECLARE FUNCTION  GpiSetBackColor%( BYVAL HPS AS LONG,_
				    BYVAL ALONG AS LONG )

DECLARE FUNCTION  GpiQueryBackColor&( BYVAL HPS AS LONG )

' ** global primitive functions
DECLARE FUNCTION  GpiSetColor%( BYVAL HPS AS LONG,_
				BYVAL ALONG AS LONG )

DECLARE FUNCTION  GpiQueryColor&( BYVAL HPS AS LONG )

' ** logical lColor table functions
DECLARE FUNCTION  GpiCreateLogColorTable%( BYVAL HPS AS LONG,_
					   BYVAL ULONG AS LONG,_
					   BYVAL ALONG AS LONG,_
					   BYVAL BLONG AS LONG,_
					   BYVAL CLONG AS LONG,_
					   BYVAL PLONG AS LONG )

DECLARE FUNCTION  GpiRealizeColorTable%( BYVAL HPS AS LONG )

DECLARE FUNCTION  GpiUnrealizeColorTable%( BYVAL HPS AS LONG )

DECLARE FUNCTION  GpiQueryColorData%( BYVAL HPS AS LONG,_
				      BYVAL ALONG AS LONG,_
				      BYVAL PLONG AS LONG )

DECLARE FUNCTION  GpiQueryLogColorTable&( BYVAL HPS AS LONG,_
					  BYVAL ULONG AS LONG,_
					  BYVAL ALONG AS LONG,_
					  BYVAL BLONG AS LONG,_
					  BYVAL PLONG AS LONG )

DECLARE FUNCTION  GpiQueryRealColors&( BYVAL HPS AS LONG,_
				       BYVAL ULONG AS LONG,_
				       BYVAL ALONG AS LONG,_
				       BYVAL BLONG AS LONG,_
				       BYVAL PLONG AS LONG )

DECLARE FUNCTION  GpiQueryNearestColor&( BYVAL HPS AS LONG,_
					 BYVAL ULONG AS LONG,_
					 BYVAL ALONG AS LONG )

DECLARE FUNCTION  GpiQueryColorIndex&( BYVAL HPS AS LONG,_
				       BYVAL ULONG AS LONG,_
				       BYVAL ALONG AS LONG )

DECLARE FUNCTION  GpiQueryRGBColor&( BYVAL HPS AS LONG,_
				     BYVAL ULONG AS LONG,_
				     BYVAL ALONG AS LONG )

'  default color table indices

CONST  CLRFALSE        =       -5
CONST  CLRTRUE         =       -4

CONST  CLRERROR        =       -255
CONST  CLRDEFAULT      =       -3
CONST  CLRWHITE        =       -2
CONST  CLRBLACK        =       -1
CONST  CLRBACKGROUND   =       0
CONST  CLRBLUE         =       1
CONST  CLRRED          =       2
CONST  CLRPINK	       =       3
CONST  CLRGREEN        =       4
CONST  CLRCYAN	       =       5
CONST  CLRYELLOW       =       6
CONST  CLRNEUTRAL      =       7

CONST  CLRDARKGRAY     =       8
CONST  CLRDARKBLUE     =       9
CONST  CLRDARKRED      =      10
CONST  CLRDARKPINK     =      11
CONST  CLRDARKGREEN    =      12
CONST  CLRDARKCYAN	=     13
CONST  CLRBROWN 	=     14
CONST  CLRPALEGRAY	=     15

'  rgb colors
CONST  RGBERROR        =       -255&
CONST  RGBBLACK        =       &H00000000
CONST  RGBBLUE	       =       &H000000FF
CONST  RGBGREEN        =       &H0000FF00
CONST  RGBCYAN	       =       &H0000FFFF
CONST  RGBRED	       =       &H00FF0000
CONST  RGBPINK	       =       &H00FF00FF
CONST  RGBYELLOW       =       &H00FFFF00
CONST  RGBWHITE        =       &H00FFFFFF
