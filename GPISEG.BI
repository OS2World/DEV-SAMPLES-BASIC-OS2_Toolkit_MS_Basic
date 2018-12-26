'**************************************************************
'*
'* Include File: GpiSeg.BI
'*
'* Requires:     none
'*
'* Description:  Segment manager (for retained graphics)
'*
'**************************************************************

'  segment attributes used by GpiSet/QuerySegmentAttrs and others
CONST  ATTRERROR       =    -1
CONST  ATTRDETECTABLE  =    1
CONST  ATTRVISIBLE     =    2
CONST  ATTRCHAINED     =    6

CONST  ATTRDYNAMIC	=   8

CONST  ATTRFASTCHAIN   =    9
CONST  ATTRPROPDETECTABLE = 10
CONST  ATTRPROPVISIBLE	  = 11

'  attribute on/off values
CONST  ATTROFF =  0
CONST  ATTRON =  1

'  segment priority used by GpiSetSegmentPriority and others
CONST  LOWERPRI    =   -1
CONST  HIGHERPRI   =   1

'  data formats for GpiPutData and GpiGetData
CONST  DFORMNOCONV  =  0
CONST  DFORMS370SHORT = 1
CONST  DFORMPCSHORT  = 2
CONST  DFORMPCLONG   = 4

' ** draw functions for segments
DECLARE FUNCTION GpiGetData&( BYVAL HPS AS LONG,_
			      BYVAL ALONG AS LONG,_
			      BYVAL PLONG AS LONG,_
			      BYVAL BLONG AS LONG,_
			      BYVAL CLONG AS LONG,_
			      BYVAL PBYTE AS LONG)

DECLARE FUNCTION GpiPutData&( BYVAL HPS AS LONG,_
			      BYVAL ALONG AS LONG,_
			      BYVAL PLONG AS LONG,_
			      BYVAL PBYTE AS LONG)

DECLARE FUNCTION GpiDrawChain%( BYVAL HPS AS LONG )

DECLARE FUNCTION GpiDrawFrom%( BYVAL HPS AS LONG,_
			       BYVAL ALONG AS LONG,_
			       BYVAL BLONG AS LONG )

DECLARE FUNCTION GpiDrawSegment%( BYVAL HPS AS LONG,_
				  BYVAL ALONG AS LONG )

DECLARE FUNCTION GpiDrawDynamics%( BYVAL HPS AS LONG )

DECLARE FUNCTION GpiRemoveDynamics%( BYVAL HPS AS LONG,_
				     BYVAL ALONG AS LONG,_
				     BYVAL BLONG AS LONG )

' ** segment control functions
DECLARE FUNCTION GpiOpenSegment%( BYVAL HPS AS LONG,_
				  BYVAL ALONG AS LONG )

DECLARE FUNCTION GpiCloseSegment%( BYVAL HPS AS LONG )

DECLARE FUNCTION GpiDeleteSegment%( BYVAL HPS AS LONG,_
				    BYVAL ALONG AS LONG )

DECLARE FUNCTION GpiQueryInitialSegmentAttrs&( BYVAL HPS AS LONG,_
					       BYVAL ALONG AS LONG )

DECLARE FUNCTION GpiSetInitialSegmentAttrs%( BYVAL HPS AS LONG,_
					     BYVAL ALONG AS LONG,_
					     BYVAL BLONG AS LONG )

DECLARE FUNCTION GpiQuerySegmentAttrs&( BYVAL HPS AS LONG,_
					BYVAL ALONG AS LONG,_
					BYVAL BLONG AS LONG )

DECLARE FUNCTION GpiSetSegmentAttrs%( BYVAL HPS AS LONG,_
				      BYVAL ALONG AS LONG,_
				      BYVAL BLONG AS LONG,_
				      BYVAL CLONG AS LONG )

DECLARE FUNCTION GpiQuerySegmentPriority&( BYVAL HPS AS LONG,_
					   BYVAL ALONG AS LONG,_
					   BYVAL BLONG AS LONG )

DECLARE FUNCTION GpiSetSegmentPriority%( BYVAL HPS AS LONG,_
					 BYVAL ALONG AS LONG,_
					 BYVAL BLONG AS LONG,_
					 BYVAL CLONG AS LONG )

DECLARE FUNCTION GpiDeleteSegments%( BYVAL HPS AS LONG,_
				     BYVAL ALONG AS LONG,_
				     BYVAL BLONG AS LONG )

DECLARE FUNCTION GpiQuerySegmentNames&( BYVAL HPS AS LONG,_
					BYVAL ALONG AS LONG,_
					BYVAL BLONG AS LONG,_
					BYVAL CLONG AS LONG,_
					BYVAL PLONG AS LONG )

DECLARE FUNCTION GpiComment%( BYVAL HPS AS LONG,_
			      BYVAL ALONG AS LONG,_
			      BYVAL PBYTE AS LONG )
