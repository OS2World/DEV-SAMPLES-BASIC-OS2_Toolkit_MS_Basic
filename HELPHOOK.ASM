; Program Name: HelpHook.ASM
;
; Functions   :
;

DOSSEG
.286			      ; OS/2 only runs on 286 machines
.model medium, PASCAL	      ; Medium memory model when interfacing with BASIC
			      ; PASCAL and BASIC use same calling conventions

.data

bhab1    DW  ?		      ; set up local data for BasClientWndProc
bhab2    DW  ?
busmode  DW  ?
bidtopic DW  ?
bidsub   DW  ?
bprcpos1 DW  ?
bprcpos2 DW  ?

.code

EXTRN	HelpHook:PROC         ; BASIC function to call

PUBLIC BasHelpHook, RegHelpHook

BasHelpHook PROC hab1:word, hab2:word, usmode:word, idtopic:word, idsub:word, prcpos1:word, prcpos2:word

   push ds
   mov  ax, @data             ; get our data segment
   mov  ds, ax

   mov  ax, hab2              ; transfer the values passed
   mov  bhab1, ax             ; from PM to local variables
   mov  ax, hab1              ; for the call to BASIC
   mov  bhab2, ax
   mov  ax, usmode
   mov  busmode, ax
   mov  ax, idtopic
   mov  bidtopic, ax
   mov  ax, idsub
   mov  bidsub, ax
   mov  ax, prcpos2
   mov  bprcpos1, ax
   mov  ax, prcpos1
   mov  bprcpos2, ax

   mov  ax, OFFSET bhab1      ; set up for call to BASIC
   push ax                    ; BASIC expects values to
   mov  ax, OFFSET busmode    ; be passed by reference.
   push ax
   mov  ax, OFFSET bidtopic
   push ax
   mov  ax, OFFSET bidsub
   push ax
   mov  ax, OFFSET bprcpos1
   push ax

   call HelpHook              ; call BASIC routine - note
                              ; return values are already
   pop ds                     ; in dx, ax so we don't have
   ret                        ; to do anything.

BasHelpHook ENDP

RegHelpHook PROC
   mov dx, SEG BasHelpHook    ; return address of
   mov ax, OFFSET BasHelpHook ; BASIC routine.
   ret

RegHelpHook ENDP

   end
