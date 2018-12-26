'**************************************************************
'*
'* Include File: WinRect.BI
'*
'* Requires:     PMBase.BI (RECTL type)
'*               OS2Def.BI (POINTL type)
'*
'* Description:  Rectangle routines
'*
'*************************************************************

DECLARE FUNCTION WinCopyRect%(BYVAL hab AS LONG,_
                              BYVAL prclDst AS LONG,_
                              BYVAL prclSrc AS LONG)

DECLARE FUNCTION WinSetRect%(BYVAL hab AS LONG,_
                             BYVAL prcl AS LONG,_
                             BYVAL xLeft AS INTEGER,_
                             BYVAL yBottom AS INTEGER,_
                             BYVAL xRight AS INTEGER,_
                             BYVAL yTop AS INTEGER)

DECLARE FUNCTION WinIsRectEmpty%(BYVAL hab AS LONG,_
                                 BYVAL prcl AS LONG)

DECLARE FUNCTION WinEqualRect%(BYVAL hab AS LONG,_
                               BYVAL prcl1 AS LONG,_
                               BYVAL prcl2 AS LONG)

DECLARE FUNCTION WinSetRectEmpty%(BYVAL hab AS LONG,_
                                  BYVAL prcl AS LONG)

DECLARE FUNCTION WinOffsetRect%(BYVAL hab AS LONG,_
                                BYVAL prcl AS LONG,_
                                BYVAL cx AS INTEGER,_
                                BYVAL cy AS INTEGER)

DECLARE FUNCTION WinInflateRect%(BYVAL hab AS LONG,_
                                 BYVAL prcl AS LONG,_
                                 BYVAL cx AS INTEGER,_
                                 BYVAL cy AS INTEGER)

DECLARE FUNCTION WinPtInRect%(BYVAL hab AS LONG,_
                              BYVAL prcl AS LONG,_
                              BYVAL pptl AS LONG)

DECLARE FUNCTION WinIntersectRect%(BYVAL hab AS LONG,_
                                   BYVAL prclDst AS LONG,_
                                   BYVAL prclSrc1 AS LONG,_
                                   BYVAL prclSrc2 AS LONG)

DECLARE FUNCTION WinUnionRect%(BYVAL hab AS LONG,_
                               BYVAL prclDst AS LONG,_
                               BYVAL prclSrc1 AS LONG,_
                               BYVAL prclSrc2 AS LONG)

DECLARE FUNCTION WinSubtractRect%(BYVAL hab AS LONG,_
                                  BYVAL prclDst AS LONG,_
                                  BYVAL prclSrc1 AS LONG,_
                                  BYVAL prclSrc2 AS LONG)

DECLARE FUNCTION WinMakeRect%(BYVAL hab AS LONG,_
                              BYVAL pwrc AS LONG)

DECLARE FUNCTION WinMakePoints%(BYVAL hab AS LONG,_
                                BYVAL pwpt AS LONG,_
                                BYVAL cwpt AS INTEGER)
