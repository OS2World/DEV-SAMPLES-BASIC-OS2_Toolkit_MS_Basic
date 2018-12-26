'**************************************************************
'*
'* Include File: GpiAttr.BI
'*
'* Requires:     GpiLine.BI (SIZEF type)
'*
'* Description:  Attribute controls
'*
'**************************************************************

'  mode for GpiSetAttrMode
CONST  AMERROR	     =	 -1
CONST  AMPRESERVE    =	 0
CONST  AMNOPRESERVE  =	 1

'  bundle codes for GpiSetAttributes and GpiQueryAttributes
CONST  PRIMLINE 	   =   1
CONST  PRIMCHAR 	   =   2
CONST  PRIMMARKER	   =   3
CONST  PRIMAREA 	   =   4
CONST  PRIMIMAGE           =   5

'  line bundle mask bits
CONST  LBBCOLOR 	    =  &H0001
CONST  LBBMIXMODE	   =   &H0004
CONST  LBBWIDTH 	   =   &H0010
CONST  LBBGEOMWIDTH	   =   &H0020
CONST  LBBTYPE		    =  &H0040
CONST  LBBEND		    =  &H0080
CONST  LBBJOIN		    =  &H0100

'  character bundle mask bits
CONST  CBBCOLOR 	    =  &H0001
CONST  CBBBACKCOLOR	    =  &H0002
CONST  CBBMIXMODE	    =  &H0004
CONST  CBBBACKMIXMODE	    =  &H0008
CONST  CBBSET		    =  &H0010
CONST  CBBMODE		    =  &H0020
CONST  CBBBOX		    =  &H0040
CONST  CBBANGLE 	    =  &H0080
CONST  CBBSHEAR 	    =  &H0100
CONST  CBBDIRECTION	    =  &H0200

'  marker bundle mask bits
CONST  MBBCOLOR 	    =  &H0001
CONST  MBBBACKCOLOR	    =  &H0002
CONST  MBBMIXMODE	    =  &H0004
CONST  MBBBACKMIXMODE	    =  &H0008
CONST  MBBSET		    =  &H0010
CONST  MBBSYMBOL	    =  &H0020
CONST  MBBBOX		    =  &H0040

'  pattern bundle mask bits
CONST  ABBCOLOR 	    =  &H0001
CONST  ABBBACKCOLOR	    =  &H0002
CONST  ABBMIXMODE	    =  &H0004
CONST  ABBBACKMIXMODE	    =  &H0008
CONST  ABBSET		    =  &H0010
CONST  ABBSYMBOL	    =  &H0020
CONST  ABBREFPOINT	    =  &H0040

'  image bundle mask bits
CONST  IBBCOLOR 	    =  &H0001
CONST  IBBBACKCOLOR	    =  &H0002
CONST  IBBMIXMODE	    =  &H0004
CONST  IBBBACKMIXMODE       =  &H0008

'  line bundle for GpiSetAttributes and GpiQueryAttributes
TYPE LINEBUNDLE     '  lbnd
    lColor AS LONG
    lReserved AS LONG
    usMixMode AS INTEGER
    usReserved AS INTEGER
    fxWidth AS LONG
    lGeomWidth AS LONG
    usType AS INTEGER
    usEnd AS INTEGER
    usJoin AS INTEGER
END TYPE

'  character bundle for GpiSetAttributes and GpiQueryAttributes
TYPE CHARBUNDLE    '  cbnd
    lColor AS LONG
    lBackColor AS LONG
    usMixMode AS INTEGER
    usBackMixMode AS INTEGER
    usSet AS INTEGER
    usPrecision AS INTEGER
    sizfxCell AS SIZEF
    ptlAngle AS LONG
    ptlShear AS LONG
    usDirection AS INTEGER
END TYPE

'  marker bundle for GpiSetAttributes and GpiQueryAttributes
TYPE MARKERBUNDLE  '  mbnd
    lColor AS LONG
    lBackColor AS LONG
    usMixMode AS INTEGER
    usBackMixMode AS INTEGER
    usSet AS INTEGER
    usSymbol AS INTEGER
    sizfxCell AS SIZEF
END TYPE

'  pattern bundle for GpiSetAttributes and GpiQueryAttributes
TYPE AREABUNDLE  '  pbnd
    lColor AS LONG
    lBackColor AS LONG
    usMixMode AS INTEGER
    usBackMixMode AS INTEGER
    usSet AS INTEGER
    usSymbol AS INTEGER
    ptlRefPoint AS LONG
END TYPE

'  image bundle for GpiSetAttributes and GpiQueryAttributes
TYPE IMAGEBUNDLE   '  ibmd
    lColor AS LONG
    lBackColor AS LONG
    usMixMode AS INTEGER
    usBackMixMode AS INTEGER
END TYPE

' ** attribute mode functions
DECLARE FUNCTION  GpiSetAttrMode%( BYVAL HPS AS LONG,_
				   BYVAL ALONG AS LONG )

DECLARE FUNCTION  GpiQueryAttrMode&( BYVAL HPS AS LONG )

' ** bundle primitive functions
DECLARE FUNCTION  GpiSetAttrs%( BYVAL HPS AS LONG,_
				BYVAL ALONG AS LONG,_
				BYVAL ULONG AS LONG,_
				BYVAL AULONG AS LONG,_
				BYVAL PBUNDLE AS LONG)

DECLARE FUNCTION  GpiQueryAttrs&( BYVAL HPS AS LONG,_
				  BYVAL ALONG AS LONG,_
				  BYVAL ULONG AS LONG,_
				  BYVAL PBUNDLE AS LONG)

' ** miscellaneous primitive functions
DECLARE FUNCTION GpiPop%( BYVAL HPS AS LONG,_
			  BYVAL ALONG AS LONG )
