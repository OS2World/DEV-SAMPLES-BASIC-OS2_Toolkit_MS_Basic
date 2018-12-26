'**************************************************************
'*
'* Include File: PMDev.BI
'*
'* Requires:     none
'*
'* Description:  Device Context Manager
'*
'*************************************************************
 
' General DEV return values 
CONST DEVERROR     =0&
CONST DEVOK        =1&
 
' DC type for DevOpenDC 
CONST ODQUEUED              = 2&
CONST ODDIRECT              = 5&
CONST ODINFO                = 6&
CONST ODMETAFILE            = 7&
CONST ODMEMORY              = 8&
 
' codes for DevQueryCaps 
CONST CAPSFAMILY                   =  0&
CONST CAPSIOCAPS                   =  1&
CONST CAPSTECHNOLOGY               =  2&
CONST CAPSDRIVERVERSION            =  3&
CONST CAPSWIDTH                    =  4&      ' pels            
CONST CAPSHEIGHT                   =  5&      ' pels            
CONST CAPSWIDTHINCHARS             =  6&
CONST CAPSHEIGHTINCHARS            =  7&
CONST CAPSHORIZONTALRESOLUTION     =  8&      ' pels per meter  
CONST CAPSVERTICALRESOLUTION       =  9&      ' pels per meter  
CONST CAPSCHARWIDTH                = 10&      ' pels            
CONST CAPSCHARHEIGHT               = 11&      ' pels            
CONST CAPSSMALLCHARWIDTH           = 12&      ' pels            
CONST CAPSSMALLCHARHEIGHT          = 13&      ' pels            
CONST CAPSCOLORS                   = 14&
CONST CAPSCOLORPLANES              = 15&
CONST CAPSCOLORBITCOUNT            = 16&
CONST CAPSCOLORTABLESUPPORT        = 17&
CONST CAPSMOUSEBUTTONS             = 18&
CONST CAPSFOREGROUNDMIXSUPPORT     = 19&
CONST CAPSBACKGROUNDMIXSUPPORT     = 20&
CONST CAPSDEVICEWINDOWING          = 31&
CONST CAPSADDITIONALGRAPHICS       = 32&
CONST CAPSVIOLOADABLEFONTS         = 21&
CONST CAPSWINDOWBYTEALIGNMENT      = 22&
CONST CAPSBITMAPFORMATS            = 23&
CONST CAPSRASTERCAPS               = 24&
CONST CAPSMARKERHEIGHT             = 25&      ' pels            
CONST CAPSMARKERWIDTH              = 26&      ' pels            
CONST CAPSDEVICEFONTS              = 27&
CONST CAPSGRAPHICSSUBSET           = 28&
CONST CAPSGRAPHICSVERSION          = 29&
CONST CAPSGRAPHICSVECTORSUBSET     = 30&
CONST CAPSPHYSCOLORS               = 33&
CONST CAPSCOLORINDEX               = 34&
CONST CAPSGRAPHICSCHARWIDTH        = 35&
CONST CAPSGRAPHICSCHARHEIGHT       = 36&
CONST CAPSHORIZONTALFONTRES        = 37&
CONST CAPSVERTICALFONTRES          = 38&
 
' Constants for CAPSIOCAPS 
CONST CAPSIODUMMY                  = 1&
CONST CAPSIOSUPPORTSOP             = 2&
CONST CAPSIOSUPPORTSIP             = 3&
CONST CAPSIOSUPPORTSIO             = 4&
 
' Constants for CAPSTECHNOLOGY 
CONST CAPSTECHUNKNOWN              = 0&
CONST CAPSTECHVECTORPLOTTER        = 1&
CONST CAPSTECHRASTERDISPLAY        = 2&
CONST CAPSTECHRASTERPRINTER        = 3&
CONST CAPSTECHRASTERCAMERA         = 4&
CONST CAPSTECHPOSTSCRIPT           = 5&
 
' Constants for CAPSCOLORTABLESUPPORT 
CONST CAPSCOLTABLRGB8             = 1&
CONST CAPSCOLTABLRGB8PLUS         = 2&
CONST CAPSCOLTABLTRUEMIX          = 4&
CONST CAPSCOLTABLREALIZE          = 8&
 
' Constants for CAPSFOREGROUNDMIXSUPPORT 
CONST CAPSFMOR                    =  1&
CONST CAPSFMOVERPAINT             =  2&
CONST CAPSFMXOR                   =  8&
CONST CAPSFMLEAVEALONE            = 16&
CONST CAPSFMAND                   = 32&
CONST CAPSFMGENERALBOOLEAN        = 64&
 
' Constants for CAPSBACKGROUNDMIXSUPPORT 
CONST CAPSBMOR                    =  1&
CONST CAPSBMOVERPAINT             =  2&
CONST CAPSBMXOR                   =  8&
CONST CAPSBMLEAVEALONE            = 16&
 
' Constants for CAPSDEVICEWINDOWING 
CONST CAPSDEVWINDOWINGSUPPORT     = 1&
 
' Constants for CAPSADDITIONALGRAPHICS 
CONST CAPSGRAPHICSKERNINGSUPPORT  = 2&
CONST CAPSFONTOUTLINEDEFAULT      = 4&
CONST CAPSFONTIMAGEDEFAULT        = 8&
CONST CAPSSCALEDDEFAULTMARKERS    =16&
 
' Constants for CAPSWINDOWBYTEALIGNMENT 
CONST CAPSBYTEALIGNREQUIRED      = 0&
CONST CAPSBYTEALIGNRECOMMENDED   = 1&
CONST CAPSBYTEALIGNNOTREQUIRED   = 2&
 
' Constants for CAPSRASTERCAPS 
CONST CAPSRASTERBITBLT             = 1&
CONST CAPSRASTERBANDING            = 2&
CONST CAPSRASTERBITBLTSCALING      = 4&
CONST CAPSRASTERSETPEL             =16&
CONST CAPSRASTERFONTS              =32&
 
DECLARE FUNCTION DevOpenDC&(BYVAL HAB AS LONG,_
                            BYVAL along AS LONG,_
                            BYVAL PSZ AS LONG,_
                            BYVAL blong AS LONG,_
                            BYVAL PDEVOPENDATA AS LONG,_
                            BYVAL HDC AS LONG)

DECLARE FUNCTION DevCloseDC&(BYVAL HDC AS LONG)

DECLARE FUNCTION DevQueryCaps%(BYVAL HDC AS LONG,_
                               BYVAL along AS LONG,_
                               BYVAL blong AS LONG,_
                               BYVAL PLONG AS LONG)
 
' return codes for DevEscape 
CONST DEVESCERROR           = -1&
CONST DEVESCNOTIMPLEMENTED  = 0&
' codes for DevEscape 
CONST DEVESCQUERYESCSUPPORT = 0&
CONST DEVESCGETSCALINGFACTOR= 1&
CONST DEVESCSTARTDOC        = 8150&
CONST DEVESCENDDOC          = 8151&
CONST DEVESCNEXTBAND        = 8152&
CONST DEVESCABORTDOC        = 8153&
CONST DEVESCNEWFRAME        = 16300&
CONST DEVESCDRAFTMODE       = 16301&
CONST DEVESCFLUSHOUTPUT     = 16302&
CONST DEVESCRAWDATA         = 16303&
 
' codes for DevEscape PMQESC spool files 
CONST DEVESCSTDJOURNAL      =32600&
 
' return codes for DevPostDeviceModes 
CONST DPDMERROR   =-1&
CONST DPDMNONE    = 0&
 
' return code for DevQueryHardcopyCaps 
CONST DQHCERROR    =-1&
' codes for DevQueryHardcopyCaps 
CONST HCAPSCURRENT =1&
 
' structure for DevQueryHardcopyCaps 
TYPE HCINFO 
    szFormname AS STRING * 32
    cx AS LONG
    cy AS LONG
    xLeftClip AS LONG
    yBottomClip AS LONG
    xRightClip AS LONG
    yTopClip AS LONG
    xPels AS LONG
    yPels AS LONG
    flAttributes AS LONG
END TYPE

'** Device Context Functions 
 
DECLARE FUNCTION DevEscape&(BYVAL hdc AS LONG,_
                            BYVAL ALONG AS LONG,_
                            BYVAL BLONG AS LONG,_
                            BYVAL Apbyte AS LONG,_
                            BYVAL plong AS LONG,_
                            BYVAL Bpbyte AS LONG)

DECLARE FUNCTION DevQueryDeviceNames%( BYVAL hab AS LONG,_
                                       BYVAL psz AS LONG,_
                                       BYVAL Aplong AS LONG,_
                                       BYVAL pstr32 AS LONG,_
                                       BYVAL pstr64 AS LONG,_
                                       BYVAL Bplong AS LONG,_
                                       BYVAL pstr16 AS LONG)

DECLARE FUNCTION DevQueryHardcopyCaps&(BYVAL hdc AS LONG,_
                                       BYVAL ALONG AS LONG,_
                                       BYVAL BLONG AS LONG,_
                                       BYVAL phcinfo AS LONG)

DECLARE FUNCTION DevPostDeviceModes&(BYVAL hab AS LONG,_
                                     BYVAL pdrivdata AS LONG,_
                                     BYVAL Apsz AS LONG,_
                                     BYVAL Bpsz AS LONG,_
                                     BYVAL Cpsz AS LONG,_
                                     BYVAL ulong AS LONG)
