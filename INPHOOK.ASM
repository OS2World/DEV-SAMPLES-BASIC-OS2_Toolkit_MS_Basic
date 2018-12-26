; Program Name: InpHook.ASM
;
; Functions   :
;

DOSSEG
.286 ; OS/2 only runs on 286 machines
.model medium, PASCAL ; Medium memory model when interfacing with BASIC
; PASCAL and BASIC use same calling conventions

.data

bhab1   DW  ?                 ; set up local data for BasClientWndProc
bhab2   DW  ?
bqmsg1  DW  ?
bqmsg2  DW  ?
bfs     DW  ?

.code

EXTRN   InputHook:PROC        ; BASIC function to call

PUBLIC BasInputHook, RegInputHook

BasInputHook PROC hab1:word, hab2:word, qmsg1:word, qmsg2:word, fs:word

   push ds
   mov  ax, @data             ; get our data segment
   mov  ds, ax

   mov  ax, hab2              ; transfer the values passed
   mov  bhab1, ax             ; from PM to local variables
   mov  ax, hab1              ; for the call to BASIC
   mov  bhab2, ax
   mov  ax, qmsg2
   mov  bqmsg1, ax
   mov  ax, qmsg1
   mov  bqmsg2, ax
   mov  ax, fs
   mov  bfs, ax

   mov  ax, OFFSET bhab1      ; set up for call to BASIC
   push ax                    ; BASIC expects values to
   mov  ax, OFFSET bqmsg1     ; be passed by reference.
   push ax
   mov  ax, OFFSET bfs
   push ax

   call InputHook             ; call BASIC routine - note
                              ; return values are already
   pop  ds                    ; in dx, ax so we don't have
   ret                        ; to do anything.

BasInputHook ENDP

RegInputHook PROC
   mov dx, SEG BasInputHook    ; return address of
   mov ax, OFFSET BasInputHook ; BASIC routine.
   ret

RegInputHook ENDP

   end
