; Program Name: MsgfHook.ASM
;
; Functions   :
;

DOSSEG
.286                      ; OS/2 only runs on 286 machines
.model medium, PASCAL     ; Medium memory model when interfacing with BASIC
                          ; PASCAL and BASIC use same calling conventions

.data

bhab1   DW  ?             ; set up local data for BasClientWndProc
bhab2   DW  ?
bmsgf   DW  ?
bqmsg1  DW  ?
bqmsg2  DW  ?

.code

EXTRN  MsgFilterHook:PROC        ; BASIC function to call

PUBLIC BasMsgFilterHook, RegMsgFilterHook

BasMsgFilterHook PROC hab1:word, hab2:word, msgf:word, qmsg1:word, qmsg2:word

   push ds
   mov  ax, @data         ; get our data segment
   mov  ds, ax

   mov  ax, hab2          ; transfer the values passed
   mov  bhab1, ax         ; from PM to local variables
   mov  ax, hab1          ; for the call to BASIC
   mov  bhab2, ax
   mov  ax, msgf
   mov  bmsgf, ax
   mov  ax, qmsg2
   mov  bqmsg1, ax
   mov  ax, qmsg1
   mov  bqmsg2, ax

   mov  ax, OFFSET bhab1  ; set up for call to BASIC
   push ax                ; BASIC expects values to
   mov  ax, OFFSET bmsgf  ; be passed by reference.
   push ax
   mov  ax, OFFSET bqmsg1
   push ax

   call MsgFilterHook     ; call BASIC routine - note
                          ; return values are already
   pop  ds                ; in dx, ax so we don't have
   ret                    ; to do anything.

BasMsgFilterHook ENDP

RegMsgFilterHook PROC
   mov dx, SEG BasMsgFilterHook    ; return address of
   mov ax, OFFSET BasMsgFilterHook ; BASIC routine.
   ret

RegMsgFilterHook ENDP

   end
