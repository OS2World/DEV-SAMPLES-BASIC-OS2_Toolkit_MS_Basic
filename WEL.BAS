'---------------------------------------------------
' WEL.BAS -- A Program that Creates a Message Queue
'---------------------------------------------------
REM $INCLUDE: 'PMBase.BI'

hab& = WinInitialize(0)
hmq& = WinCreateMsgQueue(hab&, 0)

bool% = WinDestroyMsgQueue(hmq&)
bool% = WinTerminate(hab&)

END


'*** ClientWndProc needed to eliminate unresolved externals from REGBAS.LIB
FUNCTION ClientWndProc&(hwnd&, msg%, mp1&, mp2&)
END FUNCTION
