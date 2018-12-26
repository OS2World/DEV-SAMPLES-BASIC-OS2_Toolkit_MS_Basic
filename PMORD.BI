'**************************************************************
'*
'* Include File: PMOrd.H
'*
'* Requires:     OS2Def.BI (POINTL type)
'*               PMBase.BI (RECTL type)
'*
'* Description:  Types and constants for GOCA orders
'*
'*************************************************************
'*
'* The orders fall into 4 categories :-
'*
'* 1) 1-byte orders    - not possible as BASIC has no single byte numeric
'*
'* 2) 2-byte orders    - second byte contains the value
'*
'* 3) Long orders      - second byte gives the order length, subsequent bytes
'*                       contain the values (up to 256 bytes long)
'*
'* 4) Very long orders - third and fourth bytes gives the order length,
'*                       subsequent bytes contain the values (up to 64K long)
'*
'**************************************************************************
 
'*************************************************************************
'*
'* Miscellaneous structures used in this file
'*
'*************************************************************************
 
' form of RECTL with shorts instead of longs

TYPE RECT1S	  ' rcs
    xLeft AS INTEGER
    yBottom AS INTEGER
    xRight AS INTEGER
    yTop AS INTEGER
END TYPE
 
' form of POINTL with 1 byte offsets instead of longs
TYPE ODPOINT	    ' odpt
  dx AS STRING * 1
  dy AS STRING * 1
END TYPE
 
' form of SIZEL with shorts instead of longs
TYPE SIZES	    ' sizs
  cx AS INTEGER
  cy AS INTEGER
END TYPE
 
' unsigned two-byte swapped integer
TYPE SWPUSHORT	    ' swpus
  HiByte AS STRING * 1
  LoByte AS STRING * 1
END TYPE
 
'*************************************************************************
'*
'* 1-byte orders -- can't do in BASIC
'*
'*************************************************************************
 
' 1-byte order codes
'CONST OCODEGNOP1    = &H00            ' No-operation
'CONST OCODEGESD     = &HFF            ' End symbol definition
 
'*************************************************************************
'*
'* 2-byte orders
'*
'*************************************************************************
 
' definitions to help determine whether an order code is a 2-byte order
CONST OCODE21	    = &H80
CONST OCODE22	    = &H88
 
' General 2-byte order structure
TYPE ORDER	    ' ord
  idCode AS STRING * 1
  uchData AS STRING * 1
END TYPE
 
' 2-byte order codes
CONST OCODEGBAR     = &H68	      ' Begin area
CONST OCODEGCFIG    = &H7D	      ' Close figure
CONST OCODEGEEL     = &H49	      ' End element
CONST OCODEGEPTH    = &H7F	      ' End path
CONST OCODEGEPROL   = &H3E	      ' End prologue
CONST OCODEGPOP     = &H3F	      ' Pop
CONST OCODEGSBMX    = &H0D	      ' Set background mix
CONST OCODEGPSBMX   = &H4D	      ' Push & set b/g mix
CONST OCODEGSCD     = &H3A	      ' Set char direction
CONST OCODEGPSCD    = &H7A	      ' Push & set char direction
CONST OCODEGSCR     = &H39	      ' Set char precision
CONST OCODEGPSCR    = &H79	      ' Push & set char precision
CONST OCODEGSCS     = &H38	      ' Set char set
CONST OCODEGPSCS    = &H78	      ' Push & set char set
CONST OCODEGSCOL    = &H0A	      ' Set color
CONST OCODEGPSCOL   = &H4A	      ' Push & set color
CONST OCODEGSLE     = &H1A	      ' Set line end
CONST OCODEGPSLE    = &H5A	      ' Push & set line end
CONST OCODEGSLJ     = &H1B	      ' Set line join
CONST OCODEGPSLJ    = &H5B	      ' Push & set line join
CONST OCODEGSLT     = &H18	      ' Set line type
CONST OCODEGPSLT    = &H58	      ' Push & set line type
CONST OCODEGSLW     = &H19	      ' Set line width
CONST OCODEGPSLW    = &H59	      ' Push & set line width
CONST OCODEGSMP     = &H3B	      ' Set marker precision
CONST OCODEGPSMP    = &H7B	      ' Push & set marker precision
CONST OCODEGSMS     = &H3C	      ' Set marker set
CONST OCODEGPSMS    = &H7C	      ' Push & set marker set
CONST OCODEGSMT     = &H29	      ' Set marker symbol
CONST OCODEGPSMT    = &H69	      ' Push & set marker symbol
CONST OCODEGSMX     = &H0C	      ' Set mix
CONST OCODEGPSMX    = &H4C	      ' Push & set mix
CONST OCODEGSPS     = &H08	      ' Set pattern set
CONST OCODEGPSPS    = &H48	      ' Push & set pattern set
CONST OCODEGSPT     = &H28	      ' Set pattern symbol
CONST OCODEGPSPT    = &H09	      ' Push & set pattern symbol
 
' constants for 2-byte orders
 
' Begin area
CONST GBARRESERVED   = &H80
CONST GBARBOUNDARY   = &HC0
CONST GBARNOBOUNDARY = &H80
CONST GBARWINDING    = &HA0
CONST GBARALTERNATE  = &H80
 
' Set Character Precision
CONST GSCRPRECISION  = &H0F
 
'*************************************************************************
'*
'* Long orders
'*
'*************************************************************************
 
' definitions to help determine whether an order code is a long order
 
CONST OCODEVLONG    = &HFE
 
' long order structure
CONST LORDERML = 253

TYPE LORDER	    ' lord
  idCode AS STRING * 1
  uchLength AS STRING * 1
  uchData AS STRING * LORDERML
END TYPE
 
' Long orders for which the length of data is normally zero
CONST OCODEGEAR     = &H60	      ' End Area
CONST OCODEGEIMG    = &H93	      ' End Image
 
' Long orders for which the data is contained in a type already defined
 
' Character String
CONST OCODEGCCHST   = &H83	      ' char string at curr posn
CONST GCCHSTMC	   = 255	     ' Max len of string in bytes
 
CONST OCODEGCHST    = &HC3	      ' char string at given pos
CONST GCHSTSMC	   = 251	     ' Max len of string (S)
CONST GCHSTLMC	   = 247	     ' Max len of string (L)
 
' Character String Move
CONST OCODEGCCHSTM  = &HB1	      ' char string move at c.p.
CONST GCCHSTMMC    = 255	     ' Max len of string in byte
 
CONST OCODEGCHSTM   = &HF1	      ' char string move at g.p.
CONST GCHSTMSMC    = 251	     ' Max len of string (S)
CONST GCHSTMLMC    = 247	     ' Max len of string (L)
 
' Comment
CONST OCODEGCOMT    = &H01	      ' Comment
CONST GCOMTML	   = 255	     ' Maximum len of comment data
 
' Image
CONST OCODEGIMD     = &H92	      ' Image data
CONST GIMDML	   = 255	     ' Maximum len of image data
 
' Full Arc
CONST OCODEGCFARC   = &H87	      ' full arc at current posn
CONST OCODEGFARC    = &HC7	      ' full arc at given posn
 
' Label
CONST OCODEGLABL    = &HD3	      ' Label
 
' Set Current Position
CONST OCODEGSCP     = &H21	      ' Set current position
CONST OCODEGPSCP    = &H61	      ' Push and set curr posn
 
' Bezier spline
CONST OCODEGCBEZ    = &HA5	      ' Bezier spline at curr pos
CONST GCBEZSMB	   = 21 	     ' Max number of splines (S)
CONST GCBEZLMB	   = 10 	     ' Max number of splines (L)
 
CONST OCODEGBEZ     = &HE5	      ' Bezier spline at given pos
CONST GBEZSMB	   = 20 	     ' Max number of splines (S)
CONST GBEZLMB	   = 10 	     ' Max number of splines (L)
 
' Fillet
CONST OCODEGCFLT    = &H85	      ' fillet at current posn
CONST GCFLTSMP	   = 63 	     ' Max number of points (S)
CONST GCFLTLMP	   = 31 	     ' Max number of points (L)
 
CONST OCODEGFLT     = &HC5	      ' fillet at given position
CONST GFLTSMP	   = 62 	     ' Max number of points (S)
CONST GFLTLMP	   = 30 	     ' Max number of points (L)
 
' Polyline
CONST OCODEGCLINE   = &H81	      ' polyline at current posn
CONST GCLINESMP    = 63 	     ' Max number of points (S)
CONST GCLINELMP    = 31 	     ' Max number of points (L)
 
CONST OCODEGLINE    = &HC1	      ' polyline at given posn
CONST GLINESMP	   = 62 	     ' Max number of points (S)
CONST GLINELMP	   = 30 	     ' Max number of points (L)
 
' Polymarker
CONST OCODEGCMRK    = &H82	      ' marker at current posn
CONST GCMRKSMP	   = 63 	     ' Max number of points (S)
CONST GCMRKLMP	   = 31 	     ' Max number of points (L)
 
CONST OCODEGMRK     = &HC2	      ' marker at given posn
CONST GMRKSMP	   = 62 	     ' Max number of points (S)
CONST GMRKLMP	   = 30 	     ' Max number of points (L)
 
' Relative Line
CONST OCODEGCRLINE  = &HA1	      ' Relative line at curr pos
CONST GCRLINEMP    = 127	     ' Max number of points
 
CONST OCODEGRLINE   = &HE1	      ' Relative line at givn pos
CONST GRLINESMP    = 125	     ' Max number of points (S)
CONST GRLINELMP    = 123	     ' Max number of points (L)
 
' Set Background Color
CONST OCODEGSBCOL   = &H25	      ' Set background color
CONST OCODEGPSBCOL  = &H65	      ' Push and set b/g color
 
' Set Extended Color
CONST OCODEGSECOL   = &H26	      ' Set extended color
CONST OCODEGPSECOL  = &H66	      ' Push and set ext color
 
' Extended Color values
CONST SECOLDEFAULT0  = &H0000
CONST SECOLDEFAULT1  = &HFF00
CONST SECOLNEUTRAL   = &HFF07
CONST SECOLRESET     = &HFF08
 
' Set Character Angle
CONST OCODEGSCA     = &H34	      ' Set character angle
CONST OCODEGPSCA    = &H74	      ' Push and set char angle
 
' Set Character Shear
CONST OCODEGSCH     = &H35	      ' Set character shear
CONST OCODEGPSCH    = &H75	      ' Push and set char shear
 
' Set Fractional Line Width
CONST OCODEGSFLW    = &H11	      ' Set fractional line width
CONST OCODEGPSFLW   = &H51	      ' Push and set frac l width
 
' Set Pick Identifier
CONST OCODEGSPIK    = &H43	      ' Set pick identifier
CONST OCODEGPSPIK   = &H23	      ' Push and set pick id
 
 
' Long Orders for which a structure can be defined for the data
 
' Arc
CONST OCODEGCARC    = &H86	      ' Arc at Current Position
CONST OCODEGARC     = &HC6	      ' Arc at Given Position
 
TYPE ORDERSGCARC   ' osgcarc
  ptInter AS POINTS
  ptEnd AS POINTS
END TYPE
 
TYPE ORDERLGCARC   ' olgcarc
  ptInter AS POINTL
  ptEnd AS POINTL
END TYPE
 
' Begin Element
CONST OCODEGBEL     = &HD2	      ' Begin Element
 
CONST GBELDL	    = 251
TYPE ORDERGBEL	   ' ogbel
  lElementType AS LONG
  segogg AS LONG   ' address of array in C: CHAR achDesc[GBEL_DL]
END TYPE
 
' Begin Image
CONST OCODEGCBIMG   = &H91	      ' Begin Image at curr posn
CONST OCODEGBIMG    = &HD1	      ' Begin Image at given posn
 
TYPE ORDERGCBIMG   ' ogbimg
  uchFormat AS STRING * 1
  uchReserved AS STRING * 1
  cx AS SWPUSHORT
  cy AS SWPUSHORT
END TYPE
 
' Begin Path
CONST OCODEGBPTH    = &HD0	      ' Begin Path
 
TYPE ORDERGBPTH    ' ogbpth
  usReserved AS INTEGER
  idPath AS LONG
END TYPE
 
' Box
CONST OCODEGCBOX    = &H80	      ' Box at current position
CONST OCODEGBOX     = &HC0	      ' Box at given position
 
TYPE ORDERSGCBOX   ' osgcbox
  fbFlags AS STRING * 1
  uchReserved AS STRING * 1
  ptCorner AS POINTS
  hAxis AS INTEGER
  vAxis AS INTEGER
END TYPE
 
TYPE ORDERLGCBOX   ' olgcbox
  fbFlags AS STRING * 1
  uchReserved AS STRING * 1
  ptCorner AS POINTL
  hAxis AS LONG
  vAxis AS LONG
END TYPE
 
CONST GCBOXFILL     = &H40
CONST GCBOXBOUNDARY = &H20
 
' Call Segment
CONST OCODEGCALLS   = &H07	      ' call segment
 
TYPE ORDERGCALLS   ' ogcalls
  sReserved AS INTEGER
  idSegment AS LONG
END TYPE
 
' Fill Path
CONST OCODEGFPTH    = &HD7	      ' Fill path
TYPE ORDERGFPTH   ' ogfpth
  fbFlags AS STRING * 1
  uchReserved AS STRING * 1
  idPath AS LONG
END TYPE
 
CONST GFPTHALTERNATE = &H00
CONST GFPTHWINDING   = &H40
CONST GFPTHMODIFY    = &H20
 
' Modify Path
CONST OCODEGMPTH = &HD8 	      ' modify path
 
TYPE ORDERGMPTH    ' ogmpth
  uchMode AS STRING * 1
  uchReserved AS STRING * 1
  idPath AS LONG
END TYPE
 
CONST GMPTHSTROKE    = &H06
 
' Partial Arc
CONST OCODEGCPARC   = &HA3	      ' Partial arc at curr posn
CONST OCODEGPARC    = &HE3	      ' Partial arc at given posn
 
TYPE ORDERSGCPARC  ' osgcparc
  ptCenter AS POINTS
  ufx88Multiplier AS INTEGER
  usStartAngle AS LONG
  usSweepAngle AS LONG
END TYPE
 
TYPE ORDERLGCPARC  ' olgcparc
  ptCenter AS POINTL
  ufxMultiplier AS INTEGER
  usStartAngle AS LONG
  usSweepAngle AS LONG
END TYPE
 
' Set Clip Path
CONST OCODEGSCPTH   = &HB4	      ' Set clip path
 
TYPE ORDERGSCPTH   ' ogscpth
  fbFlags AS STRING * 1
  uchReserved AS STRING * 1
  idPath AS LONG
END TYPE
 
CONST GSCPTHALTERNATE = &H00
CONST GSCPTHWINDING   = &H40
CONST GSCPTHRESET     = &H00
CONST GSCPTHINTERSECT = &H20
 
' Set Arc Parameters
CONST OCODEGSAP     = &H22	      ' Set arc parameters
CONST OCODEGPSAP    = &H62	      ' Push and set arc params
 
TYPE ORDERSGSAP    ' osgsap
  p AS INTEGER
  q AS INTEGER
  r AS INTEGER
  s AS INTEGER
END TYPE
 
TYPE ORDERLGSAP    ' olgsap
  p AS LONG
  q AS LONG
  r AS LONG
  s AS LONG
END TYPE
 
' Set Background Indexed Color
CONST OCODEGSBICOL  = &HA7	      ' Set b/g indexed color
CONST OCODEGPSBICOL = &HE7	      ' Push and set b/g ind color
CONST OCODEGSICOL   = &HA6	      ' Set indexed color
CONST OCODEGPSICOL  = &HE6	      ' Push and set indexd color
 
TYPE ORDERGSBICOL  ' ogbicol
  fbFlags AS STRING * 1
  auchColor AS STRING * 3
END TYPE
 
CONST SICOLSPECIFY  = &H00
CONST SICOLSPECIAL  = &H40
CONST SICOLDEFAULT  = &H80
CONST SICOLBLACK   = 1
CONST SICOLWHITE   = 2
CONST SICOLONES    = 4
CONST SICOLZEROES  = 5
 
' Set Character Cell
CONST OCODEGSCC     = &H33	      ' Set character cell
CONST OCODEGPSCC    = &H03	      ' Push and set char cell
 
TYPE ORDERSGSCC    ' osgscc
  cxInt AS INTEGER
  cyInt AS INTEGER
  cxFract AS INTEGER
  cyFract AS INTEGER
  fbFlags AS STRING * 1
  uchReserved AS STRING * 1
END TYPE
 
TYPE ORDERLGSCC    ' olgscc
  cxInt AS LONG
  cyInt AS LONG
  cxFract AS INTEGER
  cyFract AS INTEGER
  fbFlags AS STRING * 1
  uchReserved AS STRING * 1
END TYPE
 
CONST GSCCZERODEF   = &H00
CONST GSCCZEROZERO  = &H80
 
' Set Marker Cell
CONST OCODEGSMC     = &H37	      ' Set marker cell
CONST OCODEGPSMC    = &H77	      ' Push and set marker cell
 
TYPE ORDERSGSMC    ' osgsmc
  cx AS INTEGER
  cy AS INTEGER
  fbFlags AS STRING * 1
  uchReserved AS STRING * 1
END TYPE
 
TYPE ORDERLGSMC    ' olgsmc
  cx AS LONG
  cy AS LONG
  fbFlags AS STRING * 1
  uchReserved AS STRING * 1
END TYPE
 
CONST GSMCZERODEF   = &H00
CONST GSMCZEROZERO  = &H80
 
' Set Pattern Reference Point
CONST OCODEGSPRP    = &HA0	      ' Set pattern ref point
CONST OCODEGPSPRP   = &HE0	      ' Push and set patt ref pt
 
TYPE ORDERSGSPRP   ' osgsprp
  fbFlags AS STRING * 1
  uchReserved AS STRING * 1
  ptPos AS POINTS
END TYPE
 
TYPE ORDERLGSPRP   ' olgsprp
  fbFlags AS STRING * 1
  uchReserved AS STRING * 1
  ptPos AS POINTL
END TYPE
 
CONST GSPRPDEFAULT  = &H80
CONST GSPRPSPECIFY  = &H00
 
 
' Set Individual Attribute
CONST OCODEGSIA     = &H14	      ' Set individual attribute
CONST OCODEGPSIA    = &H54	      ' Push and set ind attr
 
CONST GSIAVL = 3
TYPE ORDERGSIA	   ' ogsia
  uchAttrType AS STRING * 1
  uchPrimType AS STRING * 1
  fbFlags AS STRING * 1
  auchValue AS STRING * GSIAVL
END TYPE
 
CONST GSIACOLOR     = &H01
CONST GSIABCOLOR    = &H02
CONST GSIAMIX	    = &H03
CONST GSIABMIX	    = &H04
CONST GSIALINE	    = &H01
CONST GSIACHAR	    = &H02
CONST GSIAMARKER    = &H03
CONST GSIAPATTERN   = &H04
CONST GSIAIMAGE     = &H05
CONST GSIASPECIFY   = &H00
CONST GSIASPECIAL   = &H40
CONST GSIADEFAULT   = &H80
CONST GSIABLACK   =  1
CONST GSIAWHITE   =  2
CONST GSIAONES	  =  4
CONST GSIAZEROES  =  5
 
 
' Set Model /Viewing Transform
CONST OCODEGSTM     = &H24	      ' Set model transform
CONST OCODEGPSTM    = &H64	      ' Push and set model tfm
 
CONST OCODEGSTV     = &H31	      ' Set Viewing Transform
 
CONST GSTMML	  =  16
TYPE ORDERSGSTM     ' osgstm
  uchReserved AS STRING * 1
  fbFlags AS STRING * 1
  fsMask AS INTEGER
  asMatrix0  AS INTEGER             ' Array in C
  asMatrix1  AS INTEGER
  asMatrix2  AS INTEGER
  asMatrix3  AS INTEGER
  asMatrix4  AS INTEGER
  asMatrix5  AS INTEGER
  asMatrix6  AS INTEGER
  asMatrix7  AS INTEGER
  asMatrix8  AS INTEGER
  asMatrix9  AS INTEGER
  asMatrix10 AS INTEGER
  asMatrix11 AS INTEGER
  asMatrix12 AS INTEGER
  asMatrix13 AS INTEGER
  asMatrix14 AS INTEGER
  asMatrix15 AS INTEGER
END TYPE
 
TYPE ORDERLGSTM     ' olgstm
  uchReserved AS STRING * 1
  fbFlags AS STRING * 1
  fsMask AS INTEGER
  alMatrix0  AS LONG             ' Array in C
  alMatrix1  AS LONG
  alMatrix2  AS LONG
  alMatrix3  AS LONG
  alMatrix4  AS LONG
  alMatrix5  AS LONG
  alMatrix6  AS LONG
  alMatrix7  AS LONG
  alMatrix8  AS LONG
  alMatrix9  AS LONG
  alMatrix10 AS LONG
  alMatrix11 AS LONG
  alMatrix12 AS LONG
  alMatrix13 AS LONG
  alMatrix14 AS LONG
  alMatrix15 AS LONG
END TYPE
 
CONST GSTMM11	  = &H8000
CONST GSTMM12	  = &H4000
CONST GSTMM13	  = &H2000
CONST GSTMM14	  = &H1000
CONST GSTMM21	  = &H0800
CONST GSTMM22	  = &H0400
CONST GSTMM23	  = &H0200
CONST GSTMM24	  = &H0100
CONST GSTMM31	  = &H0080
CONST GSTMM32	  = &H0040
CONST GSTMM33	  = &H0020
CONST GSTMM34	  = &H0010
CONST GSTMM41	  = &H0008
CONST GSTMM42	  = &H0004
CONST GSTMM43	  = &H0002
CONST GSTMM44	  = &H0001
 
CONST GSTMUNITY     = &H00
CONST GSTMAFTER     = &H01
CONST GSTMBEFORE    = &H02
CONST GSTMOVERWRITE = &H03
 
CONST GSTVOVERWRITE = &H00
CONST GSTVAFTER     = &H04
 
' Set Segment Boundary, Viewing Window
 
CONST OCODEGSSB     = &H32	      ' Set segment boundary
CONST OCODEGSVW     = &H27	      ' Set viewing window
CONST OCODEGPSVW    = &H67	      ' Push and set view window
 
CONST GSSBML	  =  4
TYPE ORDERSGSSB    ' osgssb
  fbFlags AS STRING * 1
  fbMask AS STRING * 1
  alMatrix0 AS INTEGER
  alMatrix1 AS INTEGER
  alMatrix2 AS INTEGER
  alMatrix3 AS INTEGER
END TYPE
 
TYPE ORDERLGSSB    ' olgssb
  fbFLags AS STRING * 1
  fbMask AS STRING * 1
  alMatrix0 AS LONG
  alMatrix1 AS LONG
  alMatrix2 AS LONG
  alMatrix3 AS LONG
END TYPE
 
CONST GSSBXLEFT     = &H20
CONST GSSBXRIGHT    = &H10
CONST GSSBYBOTTOM   = &H08
CONST GSSBYTOP	    = &H04
 
CONST GSVWINTERSECT = &H00
CONST GSVWREPLACE   = &H80
 
' Set Segment Characteristics
CONST OCODEGSGCH    = &H04	      ' Set segment characterstc   s
 
CONST GSGCHML  =     254
TYPE ORDERGSGCH    ' ogsgch
  uchIdent AS STRING * 1
  auchData AS STRING * GSGCHML
END TYPE
 
' Set Stroke Line Width
CONST OCODEGSSLW    = &H15	      ' Set stroke line width
CONST OCODEGPSSLW   = &H55	      ' Push and set strk l width
 
TYPE ORDERSGSSLW   ' osgsslw
  fbFlags AS STRING * 1
  uchReserved AS STRING * 1
  LineWidth AS INTEGER
END TYPE
 
TYPE ORDERLGSSLW   ' olgsslw
  fbFlags AS STRING * 1
  uchReserved AS STRING * 1
  LineWidth AS LONG
END TYPE
 
CONST GSSLWDEFAULT  = &H80
CONST GSSLWSPECIFY  = &H00
 
' Sharp Fillet at Current Position
CONST OCODEGCSFLT   = &HA4	      ' Sharp fillet at curr pos
CONST OCODEGSFLT    = &HE4	      ' Sharp fillet at given pos
 
CONST GCSFLTSMF =    21
CONST GSFLTSMF	=    20
 
TYPE ORDERSGCSFLT  ' osgcsflt
  apt0  AS POINTS             ' Array in C
  apt1  AS POINTS
  apt2  AS POINTS
  apt3  AS POINTS
  apt4  AS POINTS
  apt5  AS POINTS
  apt6  AS POINTS
  apt7  AS POINTS
  apt8  AS POINTS
  apt9  AS POINTS
  apt10 AS POINTS
  apt11 AS POINTS
  apt12 AS POINTS
  apt13 AS POINTS
  apt14 AS POINTS
  apt15 AS POINTS
  apt16 AS POINTS
  apt17 AS POINTS
  apt18 AS POINTS
  apt19 AS POINTS
  apt20 AS POINTS
  apt21 AS POINTS
  apt22 AS POINTS
  apt23 AS POINTS
  apt24 AS POINTS
  apt25 AS POINTS
  apt26 AS POINTS
  apt27 AS POINTS
  apt28 AS POINTS
  apt29 AS POINTS
  apt30 AS POINTS
  apt31 AS POINTS
  apt32 AS POINTS
  apt33 AS POINTS
  apt34 AS POINTS
  apt35 AS POINTS
  apt36 AS POINTS
  apt37 AS POINTS
  apt38 AS POINTS
  apt39 AS POINTS
  afxSharpness0  AS LONG             ' Array in C
  afxSharpness1  AS LONG
  afxSharpness2  AS LONG
  afxSharpness3  AS LONG
  afxSharpness4  AS LONG
  afxSharpness5  AS LONG
  afxSharpness6  AS LONG
  afxSharpness7  AS LONG
  afxSharpness8  AS LONG
  afxSharpness9  AS LONG
  afxSharpness10 AS LONG
  afxSharpness11 AS LONG
  afxSharpness12 AS LONG
  afxSharpness13 AS LONG
  afxSharpness14 AS LONG
  afxSharpness15 AS LONG
  afxSharpness16 AS LONG
  afxSharpness17 AS LONG
  afxSharpness18 AS LONG
  afxSharpness19 AS LONG
END TYPE
 
CONST GCSFLTLMF  =   12
CONST GSFLTLMF	 =   12
 
TYPE ORDERLGCSFLT  ' olgcsflt
  apt0  AS POINTL             ' Array in C
  apt1  AS POINTL
  apt2  AS POINTL
  apt3  AS POINTL
  apt4  AS POINTL
  apt5  AS POINTL
  apt6  AS POINTL
  apt7  AS POINTL
  apt8  AS POINTL
  apt9  AS POINTL
  apt10 AS POINTL
  apt11 AS POINTL
  apt12 AS POINTL
  apt13 AS POINTL
  apt14 AS POINTL
  apt15 AS POINTL
  apt16 AS POINTL
  apt17 AS POINTL
  apt18 AS POINTL
  apt19 AS POINTL
  apt20 AS POINTL
  apt21 AS POINTL
  apt22 AS POINTL
  apt23 AS POINTL
  afxSharpness0  AS LONG             ' Array in C
  afxSharpness1  AS LONG
  afxSharpness2  AS LONG
  afxSharpness3  AS LONG
  afxSharpness4  AS LONG
  afxSharpness5  AS LONG
  afxSharpness6  AS LONG
  afxSharpness7  AS LONG
  afxSharpness8  AS LONG
  afxSharpness9  AS LONG
  afxSharpness10 AS LONG
  afxSharpness11 AS LONG
END TYPE
 
' Bitblt
CONST OCODEGBBLT    = &HD6	      ' Bitblt
 
TYPE ORDERSGBBLT    ' osgbblt
  fsFlags AS INTEGER
  usMix AS INTEGER
  hbmSrc AS LONG
  lOptions AS LONG
  rcsTargetRect AS RECT1S
  rclSourceRect AS RECTL
END TYPE
 
TYPE ORDERLGBBLT    ' olgbblt
  fsFlags AS INTEGER
  usMix AS INTEGER
  hbmSrc AS LONG
  lOptions AS LONG
  rclTargetRect AS RECTL
  rclSourceRect AS RECTL
END TYPE
 
' Escape
CONST OCODEGESCP    = &HD5	      ' Escape
 
'
' * type describes type of escape order, identifier gives the escape
' * order if the type is registered

CONST GESCPML  =     253
TYPE ORDERGESCP    ' ogescp
  uchType AS STRING * 1
  uchIdent AS STRING * 1
  auchData AS STRING * GESCPML ' Escape data
END TYPE
 
CONST GESCPREG	    = &H80	      ' identifier is registered
 
' Escape (Bitblt)
CONST GEBBREGID     = &H02	      ' uchIdent - Bitblt
 
CONST ETYPEGEBB 	 = &H000200D5&
 
CONST GEBBLMP  =     29
TYPE ORDERLGEBB    ' olgebb
  fbFlags AS STRING * 1
  usMix AS INTEGER
  cPoints AS STRING * 1
  hbmSrc AS LONG
  lReserved AS LONG
  lOptions AS LONG
  aptPoints0  AS POINTL             ' Array in C
  aptPoints1  AS POINTL
  aptPoints2  AS POINTL
  aptPoints3  AS POINTL
  aptPoints4  AS POINTL
  aptPoints5  AS POINTL
  aptPoints6  AS POINTL
  aptPoints7  AS POINTL
  aptPoints8  AS POINTL
  aptPoints9  AS POINTL
  aptPoints10 AS POINTL
  aptPoints11 AS POINTL
  aptPoints12 AS POINTL
  aptPoints13 AS POINTL
  aptPoints14 AS POINTL
  aptPoints15 AS POINTL
  aptPoints16 AS POINTL
  aptPoints17 AS POINTL
  aptPoints18 AS POINTL
  aptPoints19 AS POINTL
  aptPoints20 AS POINTL
  aptPoints21 AS POINTL
  aptPoints22 AS POINTL
  aptPoints23 AS POINTL
  aptPoints24 AS POINTL
  aptPoints25 AS POINTL
  aptPoints26 AS POINTL
  aptPoints27 AS POINTL
  aptPoints28 AS POINTL
END TYPE
 
' Escape (Set Pel)
CONST GEPELREGID    = &H01	      ' uchIdent - Set Pel
 
CONST ETYPEGEPEL	 = &H000100D5&
 
' Element Types for attribute bundles
CONST ETYPELINEBUNDLE	 = &H0000FD01&
CONST ETYPECHARBUNDLE	 = &H0000FD02&
CONST ETYPEMARKERBUNDLE  = &H0000FD03&
CONST ETYPEAREABUNDLE	 = &H0000FD04&
CONST ETYPEIMAGEBUNDLE	 = &H0000FD05&
 
'*************************************************************************
'*
'* Very long orders
'*
'*************************************************************************
 
' Very long order structure
CONST VORDERML = 65531
TYPE VORDER	    ' vord
  idCode AS STRING * 1
  uchQualifier AS STRING * 1
  uchLength AS SWPUSHORT
  uchData AS STRING * VORDERML
END TYPE
 
' Character String Extended
CONST OCODEQGCCHSTE  = &HB0	      ' Qualifier - current posn
CONST OCODEQGCHSTE   = &HF0	      ' Qualifier - given position
 
CONST ETYPEGCCHSTE	 = &H0000FEB0&
CONST ETYPEGCHSTE	 = &H0000FEF0&
 
TYPE ORDERSGCCHSTE  ' osgcchste
  fbFlags AS STRING * 1
  uchReserved AS STRING * 1
  ptRect0 AS POINTS
  ptRect1 AS POINTS
  cchString AS SWPUSHORT
  achString AS STRING * 1
  adx AS INTEGER
END TYPE
 
TYPE ORDERLGCCHSTE  ' olgcchste
  fbFlags AS STRING * 1
  uchReserved AS STRING * 1
  ptRect0 AS POINTL
  ptRect1 AS POINTL
  cchString AS SWPUSHORT
  achString AS STRING * 1
  adx AS LONG
END TYPE
 
CONST GCCHSTEDRAWRECT	   = &H80
CONST GCCHSTENORECT	   = &H00
CONST GCCHSTECLIP	   = &H40
CONST GCCHSTENOCLIP	   = &H00
CONST GCCHSTEDEEMPHASIZE   = &H20
CONST GCCHSTENODEEMPHASIZE = &H00
CONST GCCHSTELEAVEPOS	   = &H10
CONST GCCHSTEMOVEPOS	   = &H00
 
' Extended Escape
CONST OCODEQGEESCP   = &HD5	      ' Qualifier - extended escape
 
CONST GEESCPML	 =   65533
TYPE ORDERGEESCP   ' ogeescp
  uchType AS STRING * 1
  uchIdent AS STRING * 1
  auchData AS STRING * GEESCPML
END TYPE
