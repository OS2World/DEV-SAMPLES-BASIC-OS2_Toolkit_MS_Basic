'**************************************************************
'*
'* Include File: GpiArc.BI
'*
'* Requires:     OS2Def.BI (POINTL type)
'*
'* Description:  Arc functions
'*
'**************************************************************

'  structure for GpiSetArcParams and GpiQueryArcParams
TYPE ARCPARAMS	  '  arcp
    LP AS LONG
    LQ AS LONG
    LR AS LONG
    LS AS LONG
END TYPE

' ** arc primitive functions
DECLARE FUNCTION  GpiSetArcParams%( BYVAL HPS AS LONG,_
				    BYVAL PARCPARAMS AS LONG)

DECLARE FUNCTION  GpiQueryArcParams%( BYVAL HPS AS LONG,_
				      BYVAL PARCPARAMS AS LONG)

DECLARE FUNCTION  GpiPointArc&( BYVAL HPS AS LONG,_
				BYVAL PPOINTL AS LONG )

DECLARE FUNCTION  GpiFullArc&( BYVAL HPS AS LONG,_
			       BYVAL ALONG AS LONG,_
			       BYVAL FIXED AS LONG)

DECLARE FUNCTION  GpiPartialArc&( BYVAL HPS AS LONG,_
				  BYVAL PPOINTL AS LONG,_
				  BYVAL AFIXED AS LONG,_
				  BYVAL BFIXED AS LONG,_
				  BYVAL CFIXED AS LONG )

DECLARE FUNCTION  GpiPolyFilletSharp&( BYVAL HPS AS LONG,_
				       BYVAL ALONG AS LONG,_
				       BYVAL PPOINTL AS LONG,_
				       BYVAL PFIXED AS LONG )

DECLARE FUNCTION  GpiPolySpline&( BYVAL HPS AS LONG,_
				  BYVAL ALONG AS LONG,_
				  BYVAL PPOINTL AS LONG )

DECLARE FUNCTION  GpiPolyFillet&( BYVAL HPS AS LONG,_
				  BYVAL ALONG AS LONG,_
				  BYVAL PPOINTL AS LONG )
