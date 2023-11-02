; register cheatsheet
; ax: accumulator
; bx: base/offset
; cx: counter
; dx: data
; sp: stack pointer
; bp: base pointer
; si: source index
; di: destination index

[org 0x7c00] ; bios program offset

call .cls
mov bx, .str

.loop:
  mov ah, 0       ; set routine indicator
  int 0x16        ; wait for keyboard input
  call .print_str ; print the string
  jmp .loop       ; loop

jmp $ ; infinite loop

;
; Data/functions
;

; Print the char stored in al
.print_char:
  pusha
  mov ah, 0x0e ; set routine to tty
  int 0x10     ; call print interrupt
  popa
  ret


; Print the null-terminated string at memory location [bx]
.print_str:
  pusha
  push bx
  ; while [bx] != \0: print_char [bx]
  .while:
    mov al, [bx]
    cmp al, 0
    je .done
    call .print_char
    inc bx
    jmp .while

  .done:
    pop bx
    popa
    ret


; Put the cursor to the position specified by DX
; DH = row, DL = col
.mov_cur:
  ; preserve state
  pusha
  push bx
  mov ah, 0x02 ; "get cursor data" process
  int 0x10     ; screen function int
  ; restore state
  pop bx
  popa
  ret


.cls:
  pusha

  ; go through each cell on screen and blank it out
  mov cx, 0x07d0
  .clear:
    mov al, 0
    call .print_char
    loop .clear

  ; move cursor to start
  push dx
  mov dx, 0x0000
  call .mov_cur
  pop dx

  popa
  ret


.str:
 ; backtick for escape sequences
 db `Hello world!\n`,0


times 510-($-$$) db 0 ; pad with zeros

dw 0xaa55 ; boot sector magic number
