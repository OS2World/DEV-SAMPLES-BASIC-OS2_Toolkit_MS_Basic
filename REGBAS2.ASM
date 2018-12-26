; Program Name: RegBas2.ASM
;
; Functions   :
;		BasClientWndProc2
;		RegBas2
;
; Description : This supplies the interface routines for BASIC programs.
;		used to register window classes from BASIC.
;

DOSSEG
.286			  ; OS/2 only runs on 286 machines
.model medium, PASCAL	  ; Medium memory model when interfacing with BASIC
			  ; PASCAL and BASIC use same calling conventions

.data

hwndb1	DW  ?		  ; set up local data for BasClientWndProc
hwndb2	DW  ?
msgb	DW  ?
mp1b1	DW  ?
mp1b2	DW  ?
mp2b1	DW  ?
mp2b2	DW  ?

.code

EXTRN  ClientWndProc2:PROC		     ; BASIC function to call

PUBLIC BasClientWndProc2, RegBas2


BasClientWndProc2  PROC hwnd1:word, hwnd2:word, msg:word, mp11:word, mp12:word, mp21:word, mp22:word

		       push ds
		       mov  ax, @data	    ; get our data segment
		       mov  ds, ax

		       mov  ax, hwnd2	    ; transfer the values passed
		       mov  hwndb1, ax	    ; from PM to local variables
		       mov  ax, hwnd1	    ; for the call to BASIC
		       mov  hwndb2, ax
		       mov  ax, msg
		       mov  msgb, ax
		       mov  ax, mp12
		       mov  mp1b1, ax
		       mov  ax, mp11
		       mov  mp1b2, ax
		       mov  ax, mp22
		       mov  mp2b1, ax
		       mov  ax, mp21
		       mov  mp2b2, ax

		       mov  ax, OFFSET hwndb1  ; set up for call to BASIC
		       push ax		       ; BASIC expects values to
		       mov  ax, OFFSET msgb    ; be passed by reference.
		       push ax
		       mov  ax, OFFSET mp1b1
		       push ax
		       mov  ax, OFFSET mp2b1
		       push ax

		       call ClientWndProc2     ; call BASIC routine - note
					       ; return values are already
		       pop  ds		       ; in dx, ax so we don't have
		       ret		       ; to do anything.

BasClientWndProc2  ENDP

RegBas2 	    PROC
		      mov dx, SEG BasClientWndProc2    ; return address of
		      mov ax, OFFSET BasClientWndProc2 ; BASIC routine.
		      ret

RegBas2 	    ENDP

		    end
