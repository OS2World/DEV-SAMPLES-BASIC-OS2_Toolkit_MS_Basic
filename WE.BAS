'---------------------------------------------------------
' WE.BAS -- A Program that Obtains an Anchor Block Handle
'---------------------------------------------------------
REM $INCLUDE: 'PMBase.BI'

hab& = WinInitialize(0)

bool% = WinTerminate(hab&)

END

'*** ClientWndProc needed to eliminate unresolved externals from REGBAS.LIB
FUNCTION ClientWndProc&(hwnd&, msg%, mp1&, mp2&)
END FUNCTION
