'**************************************************************
'*
'* Include File: GpiFont.BI
'*
'* Requires:     none
'*
'* Description:  Font Manager
'*
'**************************************************************

'  return codes from GpiCreateLogFont
CONST  FONTDEFAULT   =	1
CONST  FONTMATCH     =	2
 
'  lcid type for GpiQuerySetIds
CONST  LCIDTFONT     =	6
 
CONST  LCIDTBITMAP   =	7
 
'  constant used to delete all lcids by GpiDeleteSetId
CONST  LCIDALL	     =	-1
 
'  kerning data returned by GpiQueryKerningPairs
TYPE KERNINGPAIRS   '  krnpr
    sFirstChar AS INTEGER
    sSecondChar AS INTEGER
    sKerningAmount AS INTEGER
END TYPE
 
'  options for GpiQueryFonts
CONST  QFPUBLIC       =        &H0001
CONST  QFPRIVATE      =        &H0002
 
' ** physical and logical font functions
DECLARE FUNCTION GpiDeleteSetId%( BYVAL HPS AS LONG,_
				  BYVAL ALONG AS LONG )

DECLARE FUNCTION GpiQueryNumberSetIds&( BYVAL HPS AS LONG )

DECLARE FUNCTION GpiQuerySetIds%( BYVAL HPS AS LONG,_
				  BYVAL ALONG AS LONG,_
				  BYVAL APLONG AS LONG,_
				  BYVAL PSTR8 AS LONG,_
				  BYVAL BPLONG AS LONG )

DECLARE FUNCTION GpiLoadFonts%( BYVAL HAB AS LONG,_
				BYVAL PSZ AS LONG )

DECLARE FUNCTION GpiUnloadFonts%( BYVAL HAB AS LONG,_
				  BYVAL PSZ AS LONG )

DECLARE FUNCTION GpiCreateLogFont&( BYVAL HPS AS LONG,_
				    BYVAL PSTR8 AS LONG,_
				    BYVAL ALONG AS LONG,_
				    BYVAL PFATTRS AS LONG)

DECLARE FUNCTION GpiQueryFonts&( BYVAL HPS AS LONG,_
				 BYVAL ULONG AS LONG,_
				 BYVAL PSZ AS LONG,_
				 BYVAL PLONG AS LONG,_
				 BYVAL ALONG AS LONG,_
				 BYVAL PFONTMETRICS AS LONG)

DECLARE FUNCTION GpiQueryFontMetrics%( BYVAL HPS AS LONG,_
				       BYVAL ALONG AS LONG,_
				       BYVAL PFONTMETRICS AS LONG)

DECLARE FUNCTION GpiQueryKerningPairs&( BYVAL HPS AS LONG,_
					BYVAL ALONG AS LONG,_
					BYVAL PKERNINGPAIRS AS LONG)

DECLARE FUNCTION GpiQueryWidthTable%( BYVAL HPS AS LONG,_
				      BYVAL ALONG AS LONG,_
				      BYVAL BLONG AS LONG,_
				      BYVAL PLONG AS LONG )

DECLARE FUNCTION GpiSetCp%( BYVAL HPS AS LONG,_
			    BYVAL USHORT AS INTEGER)

DECLARE FUNCTION GpiQueryCp%( BYVAL HPS AS LONG )

DECLARE FUNCTION GpiQueryFontFileDescriptions&( BYVAL HAB AS LONG,_
						BYVAL PSZ AS LONG,_
						BYVAL PLONG AS LONG,_
						BYVAL PFFDESCS AS LONG)

DECLARE FUNCTION  GpiSetCharSet%( BYVAL HPS AS LONG,_
				  BYVAL ALONG AS LONG )

DECLARE FUNCTION  GpiQueryCharSet&( BYVAL HPS AS LONG )
