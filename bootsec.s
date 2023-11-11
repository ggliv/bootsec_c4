; register cheatsheet
; ax: accumulator
; bx: base/offset
; cx: counter
; dx: data
; sp: stack pointer
; bp: base pointer
; si: source index
; di: destination index

[org 0x7c00]           ; bios program offset
[bits 16]              ; use 16 bit real mode

mov ax, 0x0003         ; set video mode to 80x25 16-color text
int 0x10               ; raise video interrupt

mov dx, [board_origin]
call draw_board        ; draw at 5,19

handle_input:
  mov ah, 0x00
  int 0x16             ; wait for keyboard input

  cmp ah, 0x39         ; space pressed?
  jnz left             ; no, check for directions
  call drop_token      ; yes, drop token
  jmp handle_input     ; done, wait for more input

  left: cmp ah, 0x4b   ; left arrow pressed?
  jnz right            ; no, check for right
  call move_left       ; yes, move the cursor
  jmp handle_input     ; done, wait for more input

  right: cmp ah, 0x4d  ; right arrow pressed?
  jnz handle_input     ; no, wait for more input
  call move_right      ; yes, move the cursor
  jmp handle_input     ; done, wait for more input

echo:
  mov ah, 0x00
  int 0x16
  mov ah, 0x0e
  int 0x10
  jmp echo


jmp $                  ; infinite loop


;
; Variables/data
;

board_origin dw 0x0513
col_sel  db 0x00 ; currently selected column
col0_top db 0x00 ; next row for column 0
col1_top db 0x00 ; next row for column 1
col2_top db 0x00 ; next row for column 2
col3_top db 0x00 ; next row for column 3
col4_top db 0x00 ; next row for column 4
col5_top db 0x00 ; next row for column 5
col6_top db 0x00 ; next row for column 6

top_line:
  db 0xc9,0xcd,0xcd,0xcd,0xcd,0xcd,0xcb,0xcd,0xcd,0xcd,0xcd,0xcd,0xcb,0xcd,0xcd,0xcd,0xcd,0xcd,0xcb,0xcd,0xcd,0xcd,0xcd,0xcd,0xcb,0xcd,0xcd,0xcd,0xcd,0xcd,0xcb,0xcd,0xcd,0xcd,0xcd,0xcd,0xcb,0xcd,0xcd,0xcd,0xcd,0xcd,0xbb,0
int_blank:
  db 0xba,0x20,0x20,0x20,0x20,0x20,0xba,0x20,0x20,0x20,0x20,0x20,0xba,0x20,0x20,0x20,0x20,0x20,0xba,0x20,0x20,0x20,0x20,0x20,0xba,0x20,0x20,0x20,0x20,0x20,0xba,0x20,0x20,0x20,0x20,0x20,0xba,0x20,0x20,0x20,0x20,0x20,0xba,0
int_border:
  db 0xcc,0xcd,0xcd,0xcd,0xcd,0xcd,0xce,0xcd,0xcd,0xcd,0xcd,0xcd,0xce,0xcd,0xcd,0xcd,0xcd,0xcd,0xce,0xcd,0xcd,0xcd,0xcd,0xcd,0xce,0xcd,0xcd,0xcd,0xcd,0xcd,0xce,0xcd,0xcd,0xcd,0xcd,0xcd,0xce,0xcd,0xcd,0xcd,0xcd,0xcd,0xb9,0
btm_line:
  db 0xc8,0xcd,0xcd,0xcd,0xcd,0xcd,0xca,0xcd,0xcd,0xcd,0xcd,0xcd,0xca,0xcd,0xcd,0xcd,0xcd,0xcd,0xca,0xcd,0xcd,0xcd,0xcd,0xcd,0xca,0xcd,0xcd,0xcd,0xcd,0xcd,0xca,0xcd,0xcd,0xcd,0xcd,0xcd,0xca,0xcd,0xcd,0xcd,0xcd,0xcd,0xbc,0


;
; Processes
;

; Drop a token in the currently selected column
drop_token:
  ret

; Move the drop cursor left
move_left:
  ret

; Move the drop cursor right
move_right:
  ret

; Print the null-terminated string at [si]
print_str:
  push si
  .while:
    lodsb
    or al, al    ; are we at a null char?
    jz .done     ; yes, break

    mov ah, 0x0e ; set routine to tty
    int 0x10     ; raise print interrupt
    jmp .while   ; continue w next char

  .done:
    pop si
    ret


; Put the cursor to the position specified by DX
; DH = row, DL = col
mov_cur:
  pusha        ; preserve state
  mov ah, 0x02 ; "get cursor data" process
  int 0x10     ; screen function int
  popa         ; restore state
  ret


; dh = row
; dl = col
draw_board:
  pusha
  call mov_cur        ; move cursor to correct spot
  mov si, top_line    ; print top bar
  call print_str
  add dx, 0x0100      ; go to next line
  call mov_cur
  mov si, int_blank
  call print_str      ; print internal blank line

  mov cx, 5           ; loop 5 times
  .loop:
    add dx, 0x0100    ; go to next line
    call mov_cur

    mov si, int_blank
    call print_str    ; print internal blank line

    add dx, 0x0100    ; go to next line
    call mov_cur

    mov si, int_border ; print internal border line
    call print_str

    add dx, 0x0100     ; go to next line
    call mov_cur

    mov si, int_blank
    call print_str     ; print internal blank line

    loop .loop

  add dx, 0x0100       ; go to next line
  call mov_cur

  mov si, int_blank
  call print_str       ; print internal blank line

  add dx, 0x0100       ; go to next line
  call mov_cur

  mov si, btm_line     ; print top bar
  call print_str

  popa
  ret


times 510-($-$$) db 0 ; pad with zeros
dw 0xaa55             ; boot sector magic number
