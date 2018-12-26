'**************************************************************
'*
'* Include File: GpiBit.BI
'*
'* Requires:     OS2Def.BI (POINTL type)
'*               GpiCont.BI (SIZEL type)
'*
'* Description:  Bitmap constants and functions
'*
'*************************************************************

'  rastor operations defined for GpiBitBlt
CONST  ROPSRCCOPY	=      &H00CC
CONST  ROPSRCPAINT	=      &H00EE
CONST  ROPSRCAND	=      &H0088
CONST  ROPSRCINVERT	=      &H0066
CONST  ROPSRCERASE	=      &H0044
CONST  ROPNOTSRCCOPY	=      &H0033
CONST  ROPNOTSRCERASE	=      &H0011
CONST  ROPMERGECOPY	=      &H00C0
CONST  ROPMERGEPAINT	=      &H00BB
CONST  ROPPATCOPY	=      &H00F0
CONST  ROPPATPAINT	=      &H00FB
CONST  ROPPATINVERT	=      &H005A
CONST  ROPDSTINVERT	=      &H0055
CONST  ROPZERO		=      &H0000
CONST  ROPONE		=      &H00FF

'  Blt options for GpiBitBlt
CONST  BBOOR	       =   0
CONST  BBOAND	       =   1
CONST  BBOIGNORE       =   2

'  error return for GpiSetBitmap
CONST  HBMERROR        =   -1

' ** bitmap and pel functions
DECLARE FUNCTION GpiLoadBitmap&( BYVAL HPS AS LONG,_
					 BYVAL HMODULE AS INTEGER,_
					 BYVAL USHORT AS INTEGER,_
					 BYVAL ALONG AS LONG,_
					 BYVAL BLONG AS LONG )

DECLARE FUNCTION     GpiDeleteBitmap%( BYVAL HBITMAP AS LONG)

DECLARE FUNCTION   GpiSetBitmap&( BYVAL HPS AS LONG,_
					BYVAL HBITMAP AS LONG)

DECLARE FUNCTION     GpiBitBlt&( BYVAL AHPS AS LONG,_
				 BYVAL BHPS AS LONG,_
				 BYVAL ALONG AS LONG,_
				 BYVAL PPOINTL AS LONG,_
				 BYVAL BLONG AS LONG,_
				 BYVAL ULONG AS LONG )

DECLARE FUNCTION     GpiWCBitBlt&( BYVAL HPS AS LONG,_
				   BYVAL HBITMAP AS LONG,_
				   BYVAL ALONG AS LONG,_
				   BYVAL PPOINTL AS LONG,_
				   BYVAL BLONG AS LONG,_
				   BYVAL ULONG AS LONG )

'  usage flags for GpiCreateBitmap
CONST CBMINIT	  =   &H0004

'  bitmap parameterization used by GpiCreateBitmap and others
TYPE BITMAPINFOHEADER	   '  bmp
    cbFix AS LONG
    cx AS INTEGER
    cy AS INTEGER
    cPlanes AS INTEGER
    cBitCount AS INTEGER
END TYPE

'*
'* This is the file format structure for Bitmaps, Pointers and Icons
'* as stored in the resource file of a PM application.
'
TYPE BITMAPFILEHEADER
    usType AS INTEGER
    cbSize AS LONG
    xHotspot AS INTEGER
    yHotspot AS INTEGER
    offBits AS LONG
    bmp AS BITMAPINFOHEADER
END TYPE


' * These are the identifying values that go in the wType field of the 
' * BITMAPFILEHEADER.  (BFT_ => Bitmap File Type)
' 
CONST BFTICON        =&H4349    'IC' 
CONST BFTBMAP        =&H4d42    'BM' 
CONST BFTPOINTER     =&H5450    'PT' 

'  RGB data for BITMAPINFO struct
TYPE RGB	   '  rgb
    bBlue AS STRING * 1
    bGreen AS STRING * 1
    bRed AS STRING * 1
END TYPE

'  bitmap data used by GpiSetBitmapBits and others
TYPE BITMAPINFO    '  bmi
    cbFix AS LONG
    cx AS INTEGER
    cy AS INTEGER
    cPlanes AS INTEGER
    cBitCount AS INTEGER
    argbColor AS RGB
END TYPE


'  error return code for GpiSet/QueryBitmapBits
CONST BMBERROR	  =   -1

' ** bitmap and pel functions
DECLARE FUNCTION  GpiCreateBitmap&( BYVAL HPS AS LONG,_
					   BYVAL PBITMAPINFOHEADER AS LONG,_
					   BYVAL ULONG AS LONG,_
					   BYVAL PBYTE AS LONG,_
					   BYVAL PBITMAPINFO AS LONG)

DECLARE FUNCTION     GpiSetBitmapDimension%( BYVAL HBITMAP AS LONG,_
					     BYVAL PSIZEL AS LONG )

DECLARE FUNCTION     GpiQueryBitmapDimension%( BYVAL HBITMAP AS LONG,_
					       BYVAL PSIZEL AS LONG )

DECLARE FUNCTION     GpiQueryDeviceBitmapFormats%( BYVAL HPS AS LONG,_
						   BYVAL ALONG AS LONG,_
						   BYVAL PLONG AS LONG )

DECLARE FUNCTION     GpiQueryBitmapParameters%( BYVAL HBITMAP AS LONG,_
						BYVAL PBITMAPINFOHEADER AS LONG)

DECLARE FUNCTION     GpiQueryBitmapBits&( BYVAL HPS AS LONG,_
					  BYVAL ALONG AS LONG,_
					  BYVAL BLONG AS LONG,_
					  BYVAL PBYTE AS LONG,_
					  BYVAL PBITMAPINFO AS LONG)

DECLARE FUNCTION     GpiSetBitmapBits&( BYVAL HPS AS LONG,_
					BYVAL ALONG AS LONG,_
					BYVAL BLONG AS LONG,_
					BYVAL PBYTE AS LONG,_
					BYVAL PBITMAPINFO AS LONG)

DECLARE FUNCTION     GpiSetPel&( BYVAL HPS AS LONG,_
				 BYVAL PPOINTL AS LONG )

DECLARE FUNCTION     GpiQueryPel&( BYVAL HPS AS LONG,_
				   BYVAL PPOINTL AS LONG )

DECLARE FUNCTION     GpiSetBitmapId%( BYVAL HPS AS LONG,_
				      BYVAL HBITMAP AS LONG,_
				      BYVAL ALONG AS LONG )

DECLARE FUNCTION   GpiQueryBitmapHandle&( BYVAL HPS AS LONG,_
						BYVAL ALONG AS LONG )

' ** image primitive functions
DECLARE FUNCTION GpiImage&( BYVAL HPS AS LONG,_
			    BYVAL ALONG AS LONG,_
			    BYVAL PSIZEL AS LONG,_
			    BYVAL BLONG AS LONG,_
			    BYVAL PBYTE AS LONG )
