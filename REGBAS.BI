'**************************************************************
'*
'* Include File: RegBas.BI
'*
'* Requires:     none
'*
'* Description:  Support routines for BASIC PM programs
'*
'*************************************************************

' MakeLong& is a function which takes two integers and returns long with each
' integer as the high and low word. This function is used to pass long
' addresses of data items to the PM routines. For example:
'
' LongAddr& = MakeLong&(VARSEG(avar), VARPTR(avar))

DECLARE FUNCTION MakeLong&(BYVAL highword AS INTEGER, BYVAL lowword AS INTEGER)

' BreakLong is a subroutine which takes a long and two integers.  The long
' will be broken into its high and lo bytes which are returned in the
' integers.  For example:
'
' BreakLong(&H010002&, HiWord, LoWord)
' PRINT HiWord, LoWord

DECLARE SUB BreakLong(BYVAL along AS LONG, hiword AS INTEGER, loword AS INTEGER)

' RegBas is a function which is necessary for the WinRegisterClass call.
' It returns the address of the function which calls ClientWndProc& in YOUR
' code.  You must use this address when registering the class. For example:
'
' bool%=WinRegisterClass%(hab&,_
'                         MakeLong(varseg(szClientClass$), sadd(szClientClass$)),_
'                         RegBas&,_
'                         CSSIZEREDRAW,_
'                         0)
'
' Your BASIC function must be defined as follows:
'
' FUNCTION ClientWndProc&(hwnd&, msg%, mp1&, mp2&)


DECLARE FUNCTION RegBas&

' The RegBasN& functions are for registering multiple classes. You need to use
' a different function for each new class of window. Your BASIC function which
' will be called must be named ClientWndProcN&. For example,
'
'   RegBas1&  registers ClientWndProc1&
'   RegBas2&  registers ClientWndProc2&
'   RegBas3&  registers ClientWndProc3&
'
' To use one of these functions, just take the comment off the DECLARE line.

'DECLARE FUNCTION RegBas1&
'DECLARE FUNCTION RegBas2&
'DECLARE FUNCTION RegBas3&
'DECLARE FUNCTION RegBas4&
'DECLARE FUNCTION RegBas5&
'DECLARE FUNCTION RegBas6&
'DECLARE FUNCTION RegBas7&
'DECLARE FUNCTION RegBas8&
'DECLARE FUNCTION RegBas9&
'DECLARE FUNCTION RegBas10&
'DECLARE FUNCTION RegBas11&
'DECLARE FUNCTION RegBas12&
'DECLARE FUNCTION RegBas13&
'DECLARE FUNCTION RegBas14&
'DECLARE FUNCTION RegBas15&
'DECLARE FUNCTION RegBas16&
'DECLARE FUNCTION RegBas17&
'DECLARE FUNCTION RegBas18&
'DECLARE FUNCTION RegBas19&
'DECLARE FUNCTION RegBas20&

' The RegxxxHook& functions are for registering various types of hooks. You
' need to use a different function for each new type of hook. Your BASIC
' function which will be called must be named xxxHook&.  For more information
' on using these functions, see Section III. Support Modules in the
' documentation.
'
' To use one of these functions, just take the comment off the DECLARE line.

'DECLARE FUNCTION RegInputHook&
'DECLARE FUNCTION RegSendMsgHook&
'DECLARE FUNCTION RegMsgFilterHook&
'DECLARE FUNCTION RegHelpHook&
