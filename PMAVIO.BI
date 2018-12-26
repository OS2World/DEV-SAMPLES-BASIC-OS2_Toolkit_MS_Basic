'**************************************************************
'*
'* Include File: PMAvio.BI
'*
'* Requires:     none
'*
'* Description:  AVIO constants types and function declarations
'*
'**************************************************************

'VioCreatePS format constants

CONST FORMATCGA   = &H0001
CONST FORMAT4BYTE = &H0003

'options for VioQueryFonts

CONST VQFPUBLIC   = &H0001&
CONST VQFPRIVATE  = &H0002&
 
DECLARE FUNCTION VioAssociate%( BYVAL HDC AS LONG,_
				BYVAL HVPS AS LONG)

DECLARE FUNCTION VioCreateLogFont%( BYVAL PFATTRS AS LONG,_
				    BYVAL ALONG AS LONG,_
				    BYVAL PSTR8 AS LONG,_
				    BYVAL HVPS AS LONG)

DECLARE FUNCTION VioCreatePS%( BYVAL PHVPS AS LONG,_
			       BYVAL ASHORT AS INTEGER,_
			       BYVAL BSHORT AS INTEGER,_
			       BYVAL CSHORT AS INTEGER,_
			       BYVAL DSHORT AS INTEGER,_
			       BYVAL HVPS AS LONG)

DECLARE FUNCTION VioDestroyPS%( BYVAL HVPS AS LONG)

DECLARE FUNCTION VioDeleteSetId%( BYVAL ALONG AS LONG,_
				  BYVAL HVPS AS LONG)

DECLARE FUNCTION VioGetDeviceCellSize%( BYVAL APSHORT AS LONG,_
					BYVAL BPSHORT AS LONG,_
					BYVAL HVPS AS LONG)

DECLARE FUNCTION VioGetOrg%( BYVAL APSHORT AS LONG,_
			     BYVAL BPSHORT AS LONG,_
			     BYVAL HVPS AS LONG)

DECLARE FUNCTION VioQueryFonts%( BYVAL APLONG AS LONG,_
				 BYVAL PFONTMETRICS AS LONG,_
				 BYVAL ALONG AS LONG,_
				 BYVAL BPLONG AS LONG,_
				 BYVAL PSZ AS LONG,_
				 BYVAL ULONG AS LONG,_
				 BYVAL HVPS AS LONG)

DECLARE FUNCTION VioQuerySetIds%( BYVAL APLONG AS LONG,_
				  BYVAL PSTR8 AS LONG,_
				  BYVAL BPLONG AS LONG,_
				  BYVAL ALONG AS LONG,_
				  BYVAL HVPS AS LONG)

DECLARE FUNCTION VioSetDeviceCellSize%( BYVAL ASHORT AS INTEGER,_
					BYVAL BSHORT AS INTEGER,_
					BYVAL HVPS AS LONG)

DECLARE FUNCTION VioSetOrg%( BYVAL ASHORT AS INTEGER,_
			     BYVAL BSHORT AS INTEGER,_
			     BYVAL HVPS AS LONG)

DECLARE FUNCTION VioShowPS%( BYVAL ASHORT AS INTEGER,_
			     BYVAL BSHORT AS INTEGER,_
			     BYVAL CSHORT AS INTEGER,_
			     BYVAL HVPS AS LONG)
 
'*********************** Public Function ******************************
'*
'* WinDefAVioWindowProc -- Default message processing for AVio PS's
'*
'**********************************************************************

DECLARE FUNCTION WinDefAVioWindowProc&(BYVAL HWND AS LONG,_
				      BYVAL USHORT AS INTEGER,_
				      BYVAL AMPARAM AS LONG,_
				      BYVAL BMPARAM AS LONG)
 
