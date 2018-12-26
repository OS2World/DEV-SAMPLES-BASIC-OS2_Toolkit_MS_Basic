'**************************************************************
'*
'* Include File: GpiArea.BI
'*
'* Requires:     OS2Def.BI (POINTL type)
'*
'* Description:  Area manager
'*
'**************************************************************

'  control flags used by GpiBeginArea
CONST  BANOBOUNDARY =  0
CONST  BABOUNDARY   =  &H0001

CONST  BAALTERNATE  =  0
CONST  BAWINDING    =  &H0002

'  fill options for GpiBox/GpiFullArc
CONST  DROFILL	    =  1
CONST  DROOUTLINE   =  2
CONST  DROOUTLINEFILL = 3

'  basic pattern symbols
CONST  PATSYMERROR    =       -1
CONST  PATSYMDEFAULT  =       0
CONST  PATSYMDENSE1    =      1
CONST  PATSYMDENSE2    =      2
CONST  PATSYMDENSE3    =      3
CONST  PATSYMDENSE4    =      4
CONST  PATSYMDENSE5    =      5
CONST  PATSYMDENSE6    =      6
CONST  PATSYMDENSE7    =      7
CONST  PATSYMDENSE8    =      8
CONST  PATSYMVERT      =      9
CONST  PATSYMHORIZ     =      10
CONST  PATSYMDIAG1     =      11
CONST  PATSYMDIAG2     =      12
CONST  PATSYMDIAG3     =      13
CONST  PATSYMDIAG4     =      14
CONST  PATSYMNOSHADE   =      15
CONST  PATSYMSOLID     =      16
CONST  PATSYMBLANK     =      64
CONST  PATSYMHALFTONE  =      17

'  lcid values for GpiSet/QueryPattern and others
CONST  LCIDERROR       =      -1
CONST  LCIDDEFAULT     =      0

'  foreground mixes
CONST  FMERROR	      =       -1
CONST  FMDEFAULT      =       0
CONST  FMOR	      =       1
CONST  FMOVERPAINT    =       2
CONST  FMLEAVEALONE   =       5

CONST  FMXOR	       =      4
CONST  FMAND	       =      6
CONST  FMSUBTRACT      =      7
CONST  FMMASKSRCNOT    =      8
CONST  FMZERO	       =      9
CONST  FMNOTMERGESRC   =      10
CONST  FMNOTXORSRC     =      11
CONST  FMINVERT        =      12
CONST  FMMERGESRCNOT   =      13
CONST  FMNOTCOPYSRC    =      14
CONST  FMMERGENOTSRC   =      15
CONST  FMNOTMASKSRC    =      16
CONST  FMONE	       =      17

'  background mixes
CONST  BMERROR	      =       -1
CONST  BMDEFAULT      =       0
CONST  BMOVERPAINT    =       2
CONST  BMLEAVEALONE   =       5

CONST  BMOR	       =      1
CONST  BMXOR	       =      4

' ** area primitive functions
DECLARE FUNCTION  GpiSetPattern%( BYVAL HPS AS LONG,_
				  BYVAL ALONG AS LONG )

DECLARE FUNCTION  GpiQueryPattern&( BYVAL HPS AS LONG )

DECLARE FUNCTION  GpiBeginArea%( BYVAL HPS AS LONG,_
				 BYVAL ULONG AS LONG )

DECLARE FUNCTION  GpiEndArea&( BYVAL HPS AS LONG )

' ** area primitive functions
DECLARE FUNCTION  GpiSetPatternSet%( BYVAL HPS AS LONG,_
				     BYVAL ALONG AS LONG )

DECLARE FUNCTION  GpiQueryPatternSet&( BYVAL HPS AS LONG )

DECLARE FUNCTION  GpiSetPatternRefPoint%( BYVAL HPS AS LONG,_
					  BYVAL PPOINTL AS LONG )

DECLARE FUNCTION  GpiQueryPatternRefPoint%( BYVAL HPS AS LONG,_
					    BYVAL PPOINTL AS LONG )

DECLARE FUNCTION  GpiSetMix%( BYVAL HPS AS LONG,_
			      BYVAL ALONG AS LONG )

DECLARE FUNCTION  GpiQueryMix&( BYVAL HPS AS LONG )

DECLARE FUNCTION  GpiSetBackMix%( BYVAL HPS AS LONG,_
				  BYVAL ALONG AS LONG )

DECLARE FUNCTION  GpiQueryBackMix&( BYVAL HPS AS LONG )
