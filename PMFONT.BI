'**************************************************************
'*
'* Include File: PMFonts.BI
'*
'* Requires:     none
'*
'* Description:  Font types and constants
'*
'*************************************************************

TYPE FOCAMETRICS	' foca
    ulIdentity AS LONG
    ulSize AS LONG
    szFamilyname AS STRING * 32
    szFacename AS STRING * 32
    usRegistryId AS INTEGER
    usCodePage AS INTEGER
    yEmHeight AS INTEGER
    yXHeight AS INTEGER
    yMaxAscender AS INTEGER
    yMaxDescender AS INTEGER
    yLowerCaseAscent AS INTEGER
    yLowerCaseDescent AS INTEGER
    yInternalLeading AS INTEGER
    yExternalLeading AS INTEGER
    xAveCharWidth AS INTEGER
    xMaxCharInc AS INTEGER
    xEmInc AS INTEGER
    yMaxBaselineExt AS INTEGER
    sCharSlope AS INTEGER
    sInlineDir AS INTEGER
    sCharRot AS INTEGER
    usWeightClass AS INTEGER
    usWidthClass AS INTEGER
    xDeviceRes AS INTEGER
    yDeviceRes AS INTEGER
    usFirstChar AS INTEGER
    usLastChar AS INTEGER
    usDefaultChar AS INTEGER
    usBreakChar AS INTEGER
    usNominalPointSize AS INTEGER
    usMinimumPointSize AS INTEGER
    usMaximumPointSize AS INTEGER
    fsTypeFlags AS INTEGER
    fsDefn AS INTEGER
    fsSelectionFlags AS INTEGER
    fsCapabilities AS INTEGER
    ySubscriptXSize AS INTEGER
    ySubscriptYSize AS INTEGER
    ySubscriptXOffset AS INTEGER
    ySubscriptYOffset AS INTEGER
    ySuperscriptXSize AS INTEGER
    ySuperscriptYSize AS INTEGER
    ySuperscriptXOffset AS INTEGER
    ySuperscriptYOffset AS INTEGER
    yUnderscoreSize AS INTEGER
    yUnderscorePosition AS INTEGER
    yStrikeoutSize AS INTEGER
    yStrikeoutPosition AS INTEGER
    usKerningPairs AS INTEGER
    usKerningTracks AS INTEGER
    pszDeviceNameOffset AS LONG
END TYPE

TYPE FONTDEFINITIONHEADER      ' fdh
    ulIdentity AS LONG
    ulSize AS LONG
    fsFontdef AS INTEGER
    fsChardef AS INTEGER
    usCellSize AS INTEGER
    xCellWidth AS INTEGER
    yCellHeight AS INTEGER
    xCellIncrement AS INTEGER
    xCellA AS INTEGER
    xCellB AS INTEGER
    xCellC AS INTEGER
    pCellBaseOffset AS INTEGER
END TYPE

CONST FONTDEFFONT1 =	&H0047	   ' set width, height, inc. & base offset
CONST FONTDEFFONT2 =	&H0042	   ' set height & base offset
CONST FONTDEFFONT3 =	&H0042	   ' set height & base offset
CONST FONTDEFCHAR1 =	&H0081	   ' set char offset and width
CONST FONTDEFCHAR2 =	&H0081	   ' set char offset and width
CONST FONTDEFCHAR3 =	&H00b8	   ' set char offset, A, B, and C space
CONST SPACEUNDEF   =	&H8000	   ' space undefined = take default

TYPE FONTSIGNATURE	' fs
    ulIdentity AS LONG
    ulSize AS LONG
    achSignature AS STRING * 12
END TYPE

TYPE FOCAFONT		' ff
    fssignature AS FONTSIGNATURE
    fmMetrics AS FOCAMETRICS
    fdDefinitions AS FONTDEFINITIONHEADER
END TYPE

CONST FONTSIGNATURE  =	&Hfffffffe ' Identity header start
CONST FONTMETRICS    =	&H00000001 ' Identity metrics
CONST FONTDEFINITION =	&H00000002 ' Identity definition
CONST FONTENDRECORD  =	&Hffffffff ' Identity record end

' Options for QueryFonts

CONST QUERYPUBLICFONTS	=    &H0001
CONST QUERYPRIVATEFONTS =    &H0002

CONST CDEFGENERIC	 =    &H0001
CONST CDEFBOLD		 =    &H0002
CONST CDEFITALIC	 =    &H0004
CONST CDEFUNDERSCORE	 =    &H0008
CONST CDEFSTRIKEOUT	 =    &H0010
