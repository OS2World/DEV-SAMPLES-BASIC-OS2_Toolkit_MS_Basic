'**************************************************************
'*
'* Include File: GpiRgn.BI
'*
'* Requires:     OS2Def.BI (POINTL type)
'*               PMBase.BI (RECTL type)
'*
'* Description:  Region Manager
'*
'**************************************************************

'  options for GpiCombineRegion
CONST CRGNOR	   =	      1
CONST CRGNCOPY	   =	      2
CONST CRGNXOR	   =	      4
CONST CRGNAND	   =	      6
CONST CRGNDIFF	   =	      7
 
'  usDirection of returned region data for GpiQueryRegionRects
CONST  RECTDIRLFRTTOPBOT =    1
CONST  RECTDIRRTLFTOPBOT =    2
CONST  RECTDIRLFRTBOTTOP =    3
CONST  RECTDIRRTLFBOTTOP =    4
 
'  control data for GpiQueryRegionRects
TYPE RGNRECT	   '  rgnrc
    ircStart AS INTEGER
    crc AS INTEGER
    crcReturned AS INTEGER
    usDirection AS INTEGER
END TYPE
 
'  return code to indicate type of region for GpiCombineRegion and others
CONST  RGNERROR    =   0
CONST  RGNNULL	   =   1
CONST  RGNRECT	   =   2
CONST  RGNCOMPLEX  =   3
 
'  return codes for GpiPtInRegion
CONST  PRGNERROR    =  0
CONST  PRGNOUTSIDE  =  1
CONST  PRGNINSIDE   =  2
 
'  return codes for GpiRectInRegion
CONST  RRGNERROR    =  0
CONST  RRGNOUTSIDE  =  1
CONST  RRGNPARTIAL  =  2
CONST  RRGNINSIDE   =  3
 
'  return codes for GpiEqualRegion
CONST  EQRGNERROR   =  0
CONST  EQRGNNOTEQUAL =	1
CONST  EQRGNEQUAL   =  2
 
'  error return code for GpiSetRegion
CONST  HRGNERROR   =   -1&
 
' ** main region functions
DECLARE FUNCTION GpiCreateRegion&( BYVAL HPS AS LONG,_
					BYVAL ALONG AS LONG,_
					BYVAL PRECTL AS LONG )

DECLARE FUNCTION  GpiSetRegion%( BYVAL HPS AS LONG,_
				 BYVAL HRGN AS LONG,_
				 BYVAL ALONG AS LONG,_
				 BYVAL PRECTL AS LONG )

DECLARE FUNCTION  GpiDestroyRegion%( BYVAL HPS AS LONG,_
				     BYVAL HRGN AS LONG )

DECLARE FUNCTION  GpiCombineRegion&( BYVAL HPS AS LONG,_
				     BYVAL AHRGN AS LONG,_
				     BYVAL BHRGN AS LONG,_
				     BYVAL CHRGN AS LONG,_
				     BYVAL ALONG AS LONG )

DECLARE FUNCTION  GpiEqualRegion&( BYVAL HPS AS LONG,_
				   BYVAL AHRGN AS LONG,_
				   BYVAL BHRGN AS LONG )

DECLARE FUNCTION  GpiOffsetRegion%( BYVAL HPS AS LONG,_
				    BYVAL HRGN AS LONG,_
				    BYVAL PPOINTL AS LONG )

DECLARE FUNCTION  GpiPtInRegion&( BYVAL HPS AS LONG,_
				  BYVAL HRGN AS LONG,_
				  BYVAL PPOINTL AS LONG )

DECLARE FUNCTION  GpiRectInRegion&( BYVAL HPS AS LONG,_
				    BYVAL HRGN AS LONG,_
				    BYVAL PRECTL AS LONG )

DECLARE FUNCTION  GpiQueryRegionBox&( BYVAL HPS AS LONG,_
				      BYVAL HRGN AS LONG,_
				      BYVAL PRECTL AS LONG )

DECLARE FUNCTION  GpiQueryRegionRects%( BYVAL HPS AS LONG,_
					BYVAL HRGN AS LONG,_
					BYVAL APRECTL AS LONG,_
					BYVAL PRGNRECT AS LONG,_
					BYVAL BPRECTL AS LONG )

DECLARE FUNCTION  GpiPaintRegion&( BYVAL HPS AS LONG,_
				   BYVAL HRGN AS LONG )
 
' ** clip region functions
DECLARE FUNCTION  GpiSetClipRegion&( BYVAL HPS AS LONG,_
				     BYVAL HRGN AS LONG,_
				     BYVAL PHRGN AS LONG )
 
DECLARE FUNCTION  GpiQueryClipRegion&( BYVAL HPS AS LONG )

DECLARE FUNCTION  GpiQueryClipBox&( BYVAL HPS AS LONG,_
				    BYVAL PRECTL AS LONG )
 
DECLARE FUNCTION  GpiIntersectClipRectangle&( BYVAL HPS AS LONG,_
				  BYVAL PRECTL AS LONG )

DECLARE FUNCTION GpiExcludeClipRectangle&( BYVAL HPS AS LONG,_
				BYVAL PRECTL AS LONG )
 
DECLARE FUNCTION  GpiOffsetClipRegion&( BYVAL HPS AS LONG,_
			   BYVAL PPOINTL AS LONG )
 
