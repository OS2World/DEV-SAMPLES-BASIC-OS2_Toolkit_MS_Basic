'**************************************************************
'*
'* Include File: OS2Def.H
'*
'* Requires:     none
'*
'* Description:  OS/2 Common Definitions file
'*
'*************************************************************

CONST  NULL    =0

CONST FALSE    =0
CONST TRUE     =1

' Severity codes 
CONST SEVERITYNOERROR                    = &H0000
CONST SEVERITYWARNING                    = &H0004
CONST SEVERITYERROR                      = &H0008
CONST SEVERITYSEVERE                     = &H000C
CONST SEVERITYUNRECOVERABLE              = &H0010

' Base component error values 

CONST WINERRBASE     = &H1000  ' Window Manager                  
CONST GPIERRBASE     = &H2000  ' Graphics Presentation Interface 
CONST DEVERRBASE     = &H3000  ' Device Manager                  
CONST SPLERRBASE     = &H4000  ' Spooler                         

'** Common types used across components 

TYPE POINTL      ' ptl  
    x AS LONG  
    y AS LONG  
END TYPE ' POINTL

TYPE POINTS  ' pts 
   x AS INTEGER
   y AS INTEGER
END TYPE ' POINTS

'defined in PMBase.BI
'
'TYPE RECTL       ' rcl 
'    xLeft AS LONG
'    yBottom AS LONG
'    xRight AS LONG
'    yTop AS LONG
'END TYPE ' RECTL

TYPE FTIME          ' ftime 
    twosecs AS INTEGER
    minutes AS INTEGER
    hours AS INTEGER
END TYPE ' FTIME

TYPE FDATE          ' fdate 
    day AS INTEGER  
    month AS INTEGER
    year AS INTEGER 
END TYPE ' FDATE

'** common DEV/SPL types 

' structure for Device Driver data 

TYPE DRIVDATA       ' driv 
    cb AS LONG    
    lVersion AS LONG    
    szDeviceName AS STRING*32
    abGeneralData AS STRING*1
END TYPE ' DRIVDATA

' array indices for array parameter for DevOpenDC, SplQmOpen or SplQpOpen 

CONST ADDRESS         =0
CONST DRIVERNAME      =1
CONST DRIVERDATA      =2
CONST DATATYPE        =3
CONST COMMENT         =4
CONST PROCNAME        =5
CONST PROCPARAMS      =6
CONST SPLPARAMS       =7
CONST NETWORKPARAMS   =8

' structure definition as an alternative of the array parameter 

TYPE DEVOPENSTRUC     ' dop 
    pszLogAddress AS LONG        
    pszDriverName AS LONG        
    pdriv AS LONG        
    pszDataType AS LONG        
    pszComment AS LONG        
    pszQueueProcName AS LONG        
    pszQueueProcParams AS LONG        
    pszSpoolerParams AS LONG        
    pszNetworkParams AS LONG        
END TYPE ' DEVOPENSTRUC

'** common AVIO/GPI types 

' values of fsSelection field of FATTRS structure 
CONST FATTRSELITALIC        = &H0001
CONST FATTRSELUNDERSCORE    = &H0002
CONST FATTRSELSTRIKEOUT     = &H0010
CONST FATTRSELBOLD          = &H0020
 
' values of fsType field of FATTRS structure 
CONST FATTRTYPEFIXED        = &H0002
CONST FATTRTYPEKERNING      = &H0004
 
' values of fsFontUse field of FATTRS structure 
CONST FATTRFONTUSENOMIX         = &H0002
CONST FATTRFONTUSEOUTLINE       = &H0004
CONST FATTRFONTUSETRANSFORMABLE = &H0008
' size for fields in the font structures 

CONST FACESIZE = 32

' font struct for Vio/GpiCreateLogFont 

TYPE FATTRS	      ' fat 
    usRecordLength AS INTEGER
    fsSelection AS INTEGER
    lMatch AS LONG
    szFacename AS STRING * FACESIZE
    idRegistry AS INTEGER
    usCodePage AS INTEGER
    lMaxBaselineExt AS LONG
    lAveCharWidth AS LONG
    fsType AS INTEGER
    fsFontUse AS INTEGER
END TYPE ' FATTRS

' font metrics returned by GpiQueryFonts and others 

TYPE FONTMETRICS    ' fm 
    szFamilyname AS STRING * FACESIZE
    szFacename AS STRING * FACESIZE
    idRegistry AS INTEGER  
    usCodePage AS INTEGER
    lEmHeight AS LONG    
    lXHeight AS LONG    
    lMaxAscender AS LONG    
    lMaxDescender AS LONG    
    lLowerCaseAscent AS LONG    
    lLowerCaseDescent AS LONG    
    lInternalLeading AS LONG    
    lExternalLeading AS LONG    
    lAveCharWidth AS LONG    
    lMaxCharInc AS LONG    
    lEmInc AS LONG    
    lMaxBaselineExt AS LONG    
    sCharSlope AS INTEGER   
    sInlineDir AS INTEGER   
    sCharRot AS INTEGER   
    usWeightClass AS INTEGER  
    usWidthClass AS INTEGER  
    sXDeviceRes AS INTEGER   
    sYDeviceRes AS INTEGER   
    sFirstChar AS INTEGER   
    sLastChar AS INTEGER   
    sDefaultChar AS INTEGER   
    sBreakChar AS INTEGER   
    sNominalPointSize AS INTEGER   
    sMinimumPointSize AS INTEGER   
    sMaximumPointSize AS INTEGER   
    fsType AS INTEGER  
    fsDefn AS INTEGER  
    fsSelection AS INTEGER  
    fsCapabilities AS INTEGER  
    lSubscriptXSize AS LONG    
    lSubscriptYSize AS LONG    
    lSubscriptXOffset AS LONG    
    lSubscriptYOffset AS LONG    
    lSuperscriptXSize AS LONG    
    lSuperscriptYSize AS LONG    
    lSuperscriptXOffset AS LONG    
    lSuperscriptYOffset AS LONG    
    lUnderscoreSize AS LONG    
    lUnderscorePosition AS LONG    
    lStrikeoutSize AS LONG    
    lStrikeoutPosition AS LONG    
    sKerningPairs AS INTEGER   
    sReserved AS INTEGER   
    lMatch AS LONG    
END TYPE 'FONTMETRICS

TYPE WRECT     ' wrc 
    xLeft AS INTEGER 
    dummy1 AS INTEGER 
    yBottom AS INTEGER 
    dummy2 AS INTEGER 
    xRight AS INTEGER 
    dummy3 AS INTEGER 
    yTop AS INTEGER 
    dummy4 AS INTEGER 
END TYPE ' WRECT

TYPE WPOINT    ' wpt 
    x AS INTEGER 
    dummy1 AS INTEGER 
    y AS INTEGER 
    dummy2 AS INTEGER 
END TYPE ' WPOINT
