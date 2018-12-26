'**************************************************************
'*
'* Include File: GpiChar.BI
'*
'* Requires:     PMBase.BI (RECTL type)
'*               OS2Def.BI (POINTL type)
'*               GpiCont.BI (SIZEL type)
'*               GpiLine.BI (SIZEF type)
'*
'* Description:  Character output controls
'*
'**************************************************************

'  array indices for GpiQueryTextBox
CONST  TXTBOXTOPLEFT	=  0
CONST  TXTBOXBOTTOMLEFT =  1
CONST  TXTBOXTOPRIGHT	=  2
CONST  TXTBOXBOTTOMRIGHT =  3
CONST  TXTBOXCONCAT	=  4

'  array count for GpiQueryTextBox
CONST  TXTBOXCOUNT	=  5

'  formatting options for GpiCharStringPosAt
CONST  CHSOPAQUE	    =  &H0001
CONST  CHSVECTOR	    =  &H0002
CONST  CHSLEAVEPOS	    =  &H0008
CONST  CHSCLIP		    =  &H0010

'  character directions
CONST  CHDIRNERROR	  =    -1
CONST  CHDIRNDEFAULT	  =    0
CONST  CHDIRNLEFTRIGHT	  =    1
CONST  CHDIRNTOPBOTTOM	  =    2
CONST  CHDIRNRIGHTLEFT	  =    3
CONST  CHDIRNBOTTOMTOP	  =    4

'  character modes
CONST  CMERROR		  =    -1
CONST  CMDEFAULT	  =    0
CONST  CMMODE1		  =    1
CONST  CMMODE2		  =    2
CONST  CMMODE3		  =    3

'  structure for gradient parameters e.g. for GpiSetCharAngle
TYPE GRADIENTL	   '  gradl
    x AS LONG
    y AS LONG
END TYPE

' ** character primitive functions
DECLARE FUNCTION  GpiCharString&( BYVAL HPS AS LONG,_
				  BYVAL ALONG AS LONG,_
				  BYVAL PCH AS LONG )

DECLARE FUNCTION  GpiCharStringAt&( BYVAL HPS AS LONG,_
				    BYVAL PPOINTL AS LONG,_
				    BYVAL ALONG AS LONG,_
				    BYVAL PCH AS LONG )

' ** character primitive functions
DECLARE FUNCTION  GpiQueryCharStringPos%( BYVAL HPS AS LONG,_
					  BYVAL ULONG AS LONG,_
					  BYVAL ALONG AS LONG,_
					  BYVAL PCH AS LONG,_
					  BYVAL PLONG AS LONG,_
					  BYVAL PPOINTL AS LONG )

DECLARE FUNCTION  GpiQueryCharStringPosAt%( BYVAL HPS AS LONG,_
					    BYVAL APPOINTL AS LONG,_
					    BYVAL ULONG AS LONG,_
					    BYVAL ALONG AS LONG,_
					    BYVAL PCH AS LONG,_
					    BYVAL PLONG AS LONG,_
					    BYVAL BPPOINTL AS LONG )

DECLARE FUNCTION  GpiQueryTextBox%( BYVAL HPS AS LONG,_
				    BYVAL ALONG AS LONG,_
				    BYVAL PCH AS LONG,_
				    BYVAL BLONG AS LONG,_
				    BYVAL PPOINTL AS LONG )

DECLARE FUNCTION  GpiQueryDefCharBox%( BYVAL HPS AS LONG,_
				       BYVAL PSIZEL AS LONG )

DECLARE FUNCTION  GpiSetCharBox%( BYVAL HPS AS LONG,_
				  BYVAL PSIZEF AS LONG)

DECLARE FUNCTION  GpiQueryCharBox%( BYVAL HPS AS LONG,_
				    BYVAL PSIZEF AS LONG)

DECLARE FUNCTION  GpiSetCharAngle%( BYVAL HPS AS LONG,_
				    BYVAL PGRADIENTL AS LONG)

DECLARE FUNCTION  GpiQueryCharAngle%( BYVAL HPS AS LONG,_
				      BYVAL PGRADIENTL AS LONG)

DECLARE FUNCTION  GpiSetCharShear%( BYVAL HPS AS LONG,_
				    BYVAL PPOINTL AS LONG )

DECLARE FUNCTION  GpiQueryCharShear%( BYVAL HPS AS LONG,_
				      BYVAL PPOINTL AS LONG )

DECLARE FUNCTION  GpiSetCharDirection%( BYVAL HPS AS LONG,_
					BYVAL ALONG AS LONG )

DECLARE FUNCTION  GpiQueryCharDirection&( BYVAL HPS AS LONG )

DECLARE FUNCTION  GpiSetCharMode%( BYVAL HPS AS LONG,_
				   BYVAL ALONG AS LONG )

DECLARE FUNCTION  GpiQueryCharMode&( BYVAL HPS AS LONG )

DECLARE FUNCTION  GpiCharStringPos&( BYVAL HPS AS LONG,_
				     BYVAL PRECTL AS LONG,_
				     BYVAL ULONG AS LONG,_
				     BYVAL ALONG AS LONG,_
				     BYVAL PCH AS LONG,_
				     BYVAL PLONG AS LONG )

DECLARE FUNCTION  GpiCharStringPosAt&( BYVAL HPS AS LONG,_
				       BYVAL PPOINTL AS LONG,_
				       BYVAL PRECTL AS LONG,_
				       BYVAL ULONG AS LONG,_
				       BYVAL ALONG AS LONG,_
				       BYVAL PCH AS LONG,_
				       BYVAL PLONG AS LONG )
