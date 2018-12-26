; Program Name: SndMHook.ASM
;
; Functions   :
;

DOSSEG
.286                      ; OS/2 only runs on 286 machines
.model medium, PASCAL     ; Medium memory model when interfacing with BASIC
                          ; PASCAL and BASIC use same calling conventions

.data

bhab1         DW  ?       ; set up local data for BasClientWndProc
bhab2         DW  ?
bsmh1         DW  ?
bsmh2         DW  ?
bfintertask   DW  ?

.code

EXTRN  SendMsgHook:PROC   ; BASIC function to call

PUBLIC BasSendMsgHook, RegSendMsgHook

BasSendMsgHook PROC hab1:word, hab2:word, smh1:word, smh2:word, fintertask:word

   push ds
   mov  ax, @data           ; get our data segment
   mov  ds, ax

   mov  ax, hab2            ; transfer the values passed
   mov  bhab1, ax           ; from PM to local variables
   mov  ax, hab1            ; for the call to BASIC
   mov  bhab2, ax
   mov  ax, smh2
   mov  bsmh1, ax
   mov  ax, smh1
   mov  bsmh2, ax
   mov  ax, fintertask
   mov  bfintertask, ax

   mov  ax, OFFSET bhab1    ; set up for call to BASIC
   push ax                  ; BASIC expects values to
   mov  ax, OFFSET bsmh1    ; be passed by reference.
   push ax
   mov  ax, OFFSET bfintertask
   push ax

   call SendMsgHook         ; call BASIC routine - note
                            ; return values are already
   pop  ds                  ; in dx, ax so we don't have
   ret                      ; to do anything.

BasSendMsgHook ENDP

RegSendMsgHook PROC
   mov dx, SEG BasSendMsgHook     ; return address of
   mov ax, OFFSET BasSendMsgHook  ; BASIC routine.
   ret

RegSendMsgHook ENDP

   end
