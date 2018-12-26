'**************************************************************
'*
'* Include File: GpiMeta.BI
'*
'* Requires:     none
'*
'* Description:  Metafile Manager
'*
'**************************************************************

'  constants for index values of options array for GpiPlayMetafile
CONST  PMFSEGBASE	 =    0
CONST  PMFLOADTYPE	 =    1
CONST  PMFRESOLVE	 =    2
CONST  PMFLCIDS 	 =    3
CONST  PMFRESET 	 =    4
CONST  PMFSUPPRESS	 =    5
CONST  PMFCOLORTABLES	 =    6
CONST  PMFCOLORREALIZABLE  =  7
 
'  options for GpiPlayMetafile
CONST  RSDEFAULT    =  0
CONST  RSNODISCARD  =  1
CONST  LCDEFAULT    =  0
CONST  LCNOLOAD     =  1
CONST  LCLOADDISC   =  3
CONST  LTDEFAULT    =  0
CONST  LTNOMODIFY   =  1
 
CONST  LTORIGINALVIEW = 4
CONST  RESDEFAULT   =  0
CONST  RESNORESET   =  1
CONST  RESRESET     =  2
CONST  SUPDEFAULT   =  0
CONST  SUPNOSUPPRESS =	1
CONST  SUPSUPPRESS   = 2
CONST  CTABDEFAULT   = 0
CONST  CTABNOMODIFY  = 1
CONST  CTABREPLACE   = 3
CONST  CREADEFAULT   = 0
CONST  CREAREALIZE   = 1
CONST  CREANOREALIZE = 2
CONST  RSPDEFAULT    = 0
CONST  RSPNODISCARD  = 1
 
' ** metafile functions
DECLARE FUNCTION   GpiLoadMetaFile&( BYVAL HAB AS LONG,_
					 BYVAL PSZ AS LONG )

DECLARE FUNCTION   GpiPlayMetaFile&( BYVAL HPS AS LONG,_
				     BYVAL HMF AS LONG,_
				     BYVAL ALONG AS LONG,_
				     BYVAL APLONG AS LONG,_
				     BYVAL BPLONG AS LONG,_
				     BYVAL BLONG AS LONG,_
				     BYVAL PSZ AS LONG )

DECLARE FUNCTION   GpiSaveMetaFile%( BYVAL HMF AS LONG,_
				     BYVAL PSZ AS LONG )

DECLARE FUNCTION   GpiDeleteMetaFile%( BYVAL HMF AS LONG )
 
DECLARE FUNCTION   GpiCopyMetaFile&( BYVAL HMF AS LONG )

DECLARE FUNCTION   GpiQueryMetaFileLength&( BYVAL HMF AS LONG )

DECLARE FUNCTION   GpiQueryMetaFileBits%( BYVAL HMF AS LONG,_
					  BYVAL ALONG AS LONG,_
					  BYVAL BLONG AS LONG,_
					  BYVAL PBYTE AS LONG )
 
DECLARE FUNCTION   GpiSetMetaFileBits%( BYVAL HMF AS LONG,_
					BYVAL ALONG AS LONG,_
					BYVAL BLONG AS LONG,_
					BYVAL PBYTE AS LONG )
 
