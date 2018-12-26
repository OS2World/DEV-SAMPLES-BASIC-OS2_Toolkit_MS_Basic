'***********************************************************
'* 
'* Program Name: Fixed.BAS
'*
'* Functions   :
'*               IEEEtoFixed
'*               FixedtoIEEE
'*
'* Description : This file provides routines to convert
'*               between BASIC's IEEE floating point numbers
'*               and PM's 32-bit FIXED decimal point numbers.
'*               This is accomplished by multiplying and
'*               dividing by 2^16 (&H10000).
'*
'*               These routines are not equivalent to the C
'*               macro, MAKEFIXED.  These are actually more
'*               intuitive.  For example, to use the C macro
'*               to make a fixed type with the value 1.5,
'*               you would use MAKEFIXED(1,32768) because
'*               32768 is .5 of 2^16.  With these routines,
'*               the fixed value equivalent to 1.5 is
'*               returned by the simple call IEEEtoFixed(1.5)
'***********************************************************

'**** IEEEtoFixed takes an IEEE floating point number (BASIC's standard) and
'**   returns a FIXED type used by several of the PM functions

FUNCTION IEEEtoFixed&(float AS DOUBLE)
  IEEEtoFixed& = float * &H10000
END FUNCTION

'**** FixedtoIEEE takes a FIXED type used by several of the PM functions
'**   and returns an IEEE floating point number (BASIC's standard)

FUNCTION FixedtoIEEE#(Fixed AS LONG)
  FixedtoIEEE# = 1# * Fixed / &H10000
END FUNCTION
