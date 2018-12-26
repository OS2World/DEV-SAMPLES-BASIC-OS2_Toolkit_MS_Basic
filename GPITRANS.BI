'**************************************************************
'*
'* Include File: GpiTrans.BI
'*
'* Requires:     PMBase.BI (RECTL type)
'*               OS2Def.BI (POINTL type)
'*
'* Description:  Transformation Matrices
'*
'**************************************************************

'  co-ordinates space for GpiConvert
CONST  CVTCWORLD	  =    1
CONST  CVTCMODEL	  =    2
CONST  CVTCDEFAULTPAGE	  =    3
CONST  CVTCPAGE 	  =    4
CONST  CVTCDEVICE	  =    5
 
'  type of transformation for GpiSetSegmentTransformMatrix
CONST  TRANSFORMREPLACE    =   0
CONST  TRANSFORMADD	   =   1
CONST  TRANSFORMPREEMPT    =   2
 
'  transform matrix
TYPE MATRIXLF	   '  matlf
    fxM11 AS LONG
    fxM12 AS LONG
    lM13 AS LONG
    fxM21 AS LONG
    fxM22 AS LONG
    lM23 AS LONG
    lM31 AS LONG
    lM32 AS LONG
    lM33 AS LONG
END TYPE
 
' ** transform and transform conversion functions
DECLARE FUNCTION GpiQuerySegmentTransformMatrix%( BYVAL HPS AS LONG,_
						  BYVAL ALONG AS LONG,_
						  BYVAL BLONG AS LONG,_
						  BYVAL PMATRIXLF AS LONG )

DECLARE FUNCTION GpiSetSegmentTransformMatrix%( BYVAL HPS AS LONG,_
						BYVAL ALONG AS LONG,_
						BYVAL BLONG AS LONG,_
						BYVAL PMATRIXLF AS LONG,_
						BYVAL CLONG AS LONG )

DECLARE FUNCTION GpiConvert%( BYVAL HPS AS LONG,_
			      BYVAL ALONG AS LONG,_
			      BYVAL BLONG AS LONG,_
			      BYVAL CLONG AS LONG,_
			      BYVAL PPOINTL AS LONG )

DECLARE FUNCTION GpiQueryModelTransformMatrix%( BYVAL HPS AS LONG,_
						BYVAL ALONG AS LONG,_
						BYVAL PMATRIXLF AS LONG )

DECLARE FUNCTION GpiSetModelTransformMatrix%( BYVAL HPS AS LONG,_
					      BYVAL ALONG AS LONG,_
					      BYVAL PMATRIXLF AS LONG,_
					      BYVAL BLONG AS LONG )

DECLARE FUNCTION GpiCallSegmentMatrix&( BYVAL HPS AS LONG,_
					BYVAL ALONG AS LONG,_
					BYVAL BLONG AS LONG,_
					BYVAL PMATRIXLF AS LONG,_
					BYVAL CLONG AS LONG )

DECLARE FUNCTION GpiQueryDefaultViewMatrix%( BYVAL HPS AS LONG,_
					     BYVAL ALONG AS LONG,_
					     BYVAL PMATRIXLF AS LONG )

DECLARE FUNCTION GpiSetDefaultViewMatrix%( BYVAL HPS AS LONG,_
					   BYVAL ALONG AS LONG,_
					   BYVAL PMATRIXLF AS LONG,_
					   BYVAL BLONG AS LONG )

DECLARE FUNCTION GpiQueryPageViewport%( BYVAL HPS AS LONG,_
					BYVAL PRECTL AS LONG )

DECLARE FUNCTION GpiSetPageViewport%( BYVAL HPS AS LONG,_
				      BYVAL PRECTL AS LONG )

DECLARE FUNCTION GpiQueryViewingTransformMatrix%( BYVAL HPS AS LONG,_
						  BYVAL ALONG AS LONG,_
						  BYVAL PMATRIXLF AS LONG )

DECLARE FUNCTION GpiSetViewingTransformMatrix%( BYVAL HPS AS LONG,_
						BYVAL ALONG AS LONG,_
						BYVAL PMATRIXLF AS LONG,_
						BYVAL BLONG AS LONG )
 
