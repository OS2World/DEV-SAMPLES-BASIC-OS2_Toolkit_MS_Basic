'**************************************************************
'*
'* Include File: GpiMark.BI
'*
'* Requires:     OS2Def.BI (POINTL type)
'*               GpiLine.BI (SIZEF type)
'*
'* Description:  Marker controls
'*
'**************************************************************

'  basic marker symbols
CONST  MARKSYMERROR	  =    -1
CONST  MARKSYMDEFAULT	  =    0
CONST  MARKSYMCROSS	  =    1
CONST  MARKSYMPLUS	  =    2
CONST  MARKSYMDIAMOND	  =    3
CONST  MARKSYMSQUARE	  =    4
CONST  MARKSYMSIXPOINTSTAR  =  5
CONST  MARKSYMEIGHTPOINTSTAR = 6
CONST  MARKSYMSOLIDDIAMOND  =  7
CONST  MARKSYMSOLIDSQUARE   =  8
CONST  MARKSYMDOT	    =  9
CONST  MARKSYMSMALLCIRCLE   =  10
CONST  MARKSYMBLANK	    =  64

' ** marker primitive functions
DECLARE FUNCTION  GpiSetMarkerSet%( BYVAL HPS AS LONG,_
				    BYVAL ALONG AS LONG )

DECLARE FUNCTION  GpiQueryMarkerSet&( BYVAL HPS AS LONG )

DECLARE FUNCTION  GpiSetMarker%( BYVAL HPS AS LONG,_
				 BYVAL ALONG AS LONG )

DECLARE FUNCTION  GpiQueryMarker&( BYVAL HPS AS LONG )

DECLARE FUNCTION GpiSetMarkerBox%( BYVAL HPS AS LONG,_
				   BYVAL PSIZEF AS LONG)

DECLARE FUNCTION GpiQueryMarkerBox%( BYVAL HPS AS LONG,_
				     BYVAL PSIZEF AS LONG)

DECLARE FUNCTION GpiMarker&( BYVAL HPS AS LONG,_
			     BYVAL PPOINTL AS LONG )

DECLARE FUNCTION GpiPolyMarker&( BYVAL HPS AS LONG,_
				 BYVAL ALONG AS LONG,_
				 BYVAL PPOINTL AS LONG )
