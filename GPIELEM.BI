'**************************************************************
'*
'* Include File: GpiElem.BI
'*
'* Requires:     (many functions must be in segments GpiSeg.BI)
'*
'* Description:  Element manager
'*
'**************************************************************

'  edit modes used by GpiSet/QueryEditMode
CONST  SEGEMERROR   =  0
CONST  SEGEMINSERT  =  1
CONST  SEGEMREPLACE =  2

' ** segment editing by element functions
DECLARE FUNCTION GpiBeginElement%( BYVAL HPS AS LONG,_
				   BYVAL ALONG AS LONG,_
				   BYVAL PSZ AS LONG )

DECLARE FUNCTION GpiEndElement%( BYVAL HPS AS LONG )

DECLARE FUNCTION GpiLabel%( BYVAL HPS AS LONG,_
			    BYVAL ALONG AS LONG )

DECLARE FUNCTION GpiElement&( BYVAL HPS AS LONG,_
			      BYVAL ALONG AS LONG,_
			      BYVAL PSZ AS LONG,_
			      BYVAL BLONG AS LONG,_
			      BYVAL PBYTE AS LONG )

DECLARE FUNCTION GpiQueryElement&( BYVAL HPS AS LONG,_
				   BYVAL ALONG AS LONG,_
				   BYVAL BLONG AS LONG,_
				   BYVAL PBYTE AS LONG )

DECLARE FUNCTION GpiDeleteElement%( BYVAL HPS AS LONG )

DECLARE FUNCTION GpiDeleteElementRange%( BYVAL HPS AS LONG,_
					 BYVAL ALONG AS LONG,_
					 BYVAL BLONG AS LONG )

DECLARE FUNCTION GpiDeleteElementsBetweenLabels%( BYVAL HPS AS LONG,_
						  BYVAL ALONG AS LONG,_
						  BYVAL BLONG AS LONG )

DECLARE FUNCTION GpiQueryEditMode&( BYVAL HPS AS LONG )

DECLARE FUNCTION GpiSetEditMode%( BYVAL HPS AS LONG,_
				  BYVAL ALONG AS LONG )

DECLARE FUNCTION GpiQueryElementPointer&( BYVAL HPS AS LONG )

DECLARE FUNCTION GpiSetElementPointer%( BYVAL HPS AS LONG,_
					BYVAL ALONG AS LONG )

DECLARE FUNCTION GpiOffsetElementPointer%( BYVAL HPS AS LONG,_
					   BYVAL ALONG AS LONG )

DECLARE FUNCTION GpiQueryElementType&( BYVAL HPS AS LONG,_
				       BYVAL PLONG AS LONG,_
				       BYVAL ALONG AS LONG,_
				       BYVAL PSZ AS LONG )

DECLARE FUNCTION GpiSetElementPointerAtLabel%( BYVAL HPS AS LONG,_
					       BYVAL ALONG AS LONG )
