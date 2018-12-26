'**************************************************************
'*
'* Include File: GpiCont.BI
'*
'* Requires:     OS2Def.BI (POINTL type)
'*
'* Description:  Gpi Control Manager
'*
'**************************************************************

DECLARE FUNCTION GpiCreatePS&( BYVAL HAB AS LONG,_
			       BYVAL HDC AS LONG,_
			       BYVAL PSIZEL AS LONG,_
			       BYVAL ULONG AS LONG )

DECLARE FUNCTION GpiDestroyPS%( BYVAL HPS AS LONG )

DECLARE FUNCTION GpiAssociate%( BYVAL HPS AS LONG,_
				BYVAL HDC AS LONG )

DECLARE FUNCTION GpiRestorePS%( BYVAL HPS AS LONG,_
				BYVAL ALONG AS LONG )

DECLARE FUNCTION GpiSavePS&( BYVAL HPS AS LONG )

DECLARE FUNCTION GpiErase%( BYVAL HPS AS LONG )

DECLARE FUNCTION GpiQueryDevice&( BYVAL HPS AS LONG )

'  General GPI return values
CONST  GPIERROR    = 0
CONST  GPIOK	   = 1
CONST  GPIALTERROR = -1

'  structure for size parameters e.g. for GpiCreatePS
TYPE SIZEL	    '  sizl
    cx AS LONG
    cy AS LONG
END TYPE

'  units for GpiCreatePS and others
CONST  PUARBITRARY =   &H0004&
CONST  PUPELS	   =   &H0008&
CONST  PULOMETRIC  =   &H000C&
CONST  PUHIMETRIC  =   &H0010&
CONST  PULOENGLISH =   &H0014&
CONST  PUHIENGLISH =   &H0018&
CONST  PUTWIPS	   =   &H001C&

'  format for GpiCreatePS
CONST  GPIFDEFAULT =   0&
CONST  GPIFSHORT   =   &H0100&
CONST  GPIFLONG    =   &H0200&

'  PS type for GpiCreatePS
CONST  GPITNORMAL  =   0&
CONST  GPITMICRO   =   &H1000&

'  implicit associate flag for GpiCreatePS
CONST  GPIANOASSOC =   0&
CONST  GPIAASSOC   =   &H4000&

'  return error for GpiQueryDevice
CONST  HDCERROR    =	-1&
'  options for GpiResetPS
CONST  GRESATTRS    =  &H0001&
CONST  GRESSEGMENTS =  &H0002&
CONST  GRESALL	    =  &H0004&

'  option masks for PS options used by GpiQueryPs
CONST  PSUNITS	    =  &H00FC&
CONST  PSFORMAT     =  &H0F00&
CONST  PSTYPE	    =  &H1000&
CONST  PSMODE	    =  &H2000&
CONST  PSASSOCIATE  =  &H4000&

'  error context returned by GpiErrorSegmentData
CONST  GPIESEGMENT  =  0&
CONST  GPIEELEMENT  =  1&
CONST  GPIEDATA     =  2&

'  control parameter for GpiSetDrawControl
CONST  DCTLERASE     =	     1&
CONST  DCTLDISPLAY   =	     2&
CONST  DCTLBOUNDARY  =	     3&
CONST  DCTLDYNAMIC   =	     4&
CONST  DCTLCORRELATE =	     5&

'  constants for GpiSet/QueryDrawControl
CONST  DCTLERROR = -1&
CONST  DCTLOFF	 = 0&
CONST  DCTLON	 = 1&

'  constants for GpiSet/QueryStopDraw
CONST  SDWERROR = -1&
CONST  SDWOFF	= 0&
CONST  SDWON	= 1&

'  drawing for GpiSet/QueryDrawingMode
CONST  DMERROR	     =	0&
CONST  DMDRAW	     =	1&
CONST  DMRETAIN      =	2&
CONST  DMDRAWANDRETAIN = 3&

' ** other GPICONTROL functions
DECLARE FUNCTION GpiResetPS%( BYVAL HPS AS LONG,_
			      BYVAL ULONG AS LONG )

DECLARE FUNCTION GpiSetPS%( BYVAL HPS AS LONG,_
			    BYVAL PSIZEL AS LONG,_
			    BYVAL ULONG AS LONG )

DECLARE FUNCTION GpiQueryPS&( BYVAL HPS AS LONG,_
			      BYVAL PSIZEL AS LONG )

DECLARE FUNCTION GpiErrorSegmentData&( BYVAL HPS AS LONG,_
				       BYVAL APLONG AS LONG,_
				       BYVAL BPLONG AS LONG )

DECLARE FUNCTION GpiQueryDrawControl&( BYVAL HPS AS LONG,_
				       BYVAL ALONG AS LONG )

DECLARE FUNCTION GpiSetDrawControl%( BYVAL HPS AS LONG,_
				     BYVAL ALONG AS LONG,_
				     BYVAL BLONG AS LONG )

DECLARE FUNCTION GpiQueryDrawingMode&( BYVAL HPS AS LONG )

DECLARE FUNCTION GpiSetDrawingMode%( BYVAL HPS AS LONG,_
				     BYVAL ALONG AS LONG )

DECLARE FUNCTION GpiQueryStopDraw&( BYVAL HPS AS LONG )

DECLARE FUNCTION GpiSetStopDraw%( BYVAL HPS AS LONG,_
				  BYVAL ALONG AS LONG )

'  options for GpiSetPickApertureSize
CONST  PICKAPDEFAULT  =        0&
CONST  PICKAPREC      =        2&

'  type of correlation for GpiCorrelateChain
CONST  PICKSELVISIBLE  =       0&
CONST  PICKSELALL      =       1&

'  return code to indicate correlate hit(s)
CONST  GPIHITS =   2&

' ** picking,  correlation and boundary functions
DECLARE FUNCTION GpiCorrelateChain&(  BYVAL HPS AS LONG,_
				      BYVAL ALONG AS LONG,_
				      BYVAL PPOINTL AS LONG,_
				      BYVAL BLONG AS LONG,_
				      BYVAL CLONG AS LONG,_
				      BYVAL PLONG AS LONG )

DECLARE FUNCTION GpiQueryTag%( BYVAL HPS AS LONG,_
			       BYVAL PLONG AS LONG )

DECLARE FUNCTION GpiSetTag%( BYVAL HPS AS LONG,_
			     BYVAL ALONG AS LONG )

DECLARE FUNCTION GpiQueryPickApertureSize%( BYVAL HPS AS LONG,_
					    BYVAL PSIZEL AS LONG )

DECLARE FUNCTION GpiSetPickApertureSize%( BYVAL HPS AS LONG,_
					  BYVAL ALONG AS LONG,_
					  BYVAL PSIZEL AS LONG )

DECLARE FUNCTION GpiQueryPickAperturePosition%( BYVAL HPS AS LONG,_
						BYVAL PPOINTL AS LONG )

DECLARE FUNCTION GpiSetPickAperturePosition%( BYVAL HPS AS LONG,_
					      BYVAL PPOINTL AS LONG )

DECLARE FUNCTION GpiQueryBoundaryData%( BYVAL HPS AS LONG,_
					BYVAL PRECTL AS LONG)

DECLARE FUNCTION GpiResetBoundaryData%( BYVAL HPS AS LONG )

DECLARE FUNCTION GpiCorrelateFrom&(  BYVAL HPS AS LONG,_
				     BYVAL ALONG AS LONG,_
				     BYVAL BLONG AS LONG,_
				     BYVAL CLONG AS LONG,_
				     BYVAL PPOINTL AS LONG,_
				     BYVAL DLONG AS LONG,_
				     BYVAL ELONG AS LONG,_
				     BYVAL PLONG AS LONG )

DECLARE FUNCTION GpiCorrelateSegment&( BYVAL HPS AS LONG,_
				       BYVAL ALONG AS LONG,_
				       BYVAL BLONG AS LONG,_
				       BYVAL PPOINTL AS LONG,_
				       BYVAL CLONG AS LONG,_
				       BYVAL DLONG AS LONG,_
				       BYVAL PLONG AS LONG )
