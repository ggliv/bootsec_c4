; register cheatsheet
; ax: accumulator
; bx: base/offset
; cx: counter
; dx: data
; sp: stack pointer
; bp: base pointer
; si: source index
; di: destination index

%define board_origin 0x0513
%define cols 7

[org 0x7c00]           ; bios program offset
[bits 16]              ; use 16 bit real mode

mov ax, 0x0003         ; set video mode to 80x25 16-color text
int 0x10               ; raise video interrupt

mov dx, board_origin
call draw_board        ; draw board
call move_dropsel

handle_input:
  mov ah, 0x00
  int 0x16             ; wait for keyboard input

  cmp ah, 0x39         ; space pressed?
  jne left             ; no, check for directions
  call drop_token      ; yes, drop token
  jmp handle_input     ; done, wait for more input

  left: cmp ah, 0x4b   ; left arrow pressed?
  jne right            ; no, check for right
  call move_left       ; yes, move the cursor
  jmp handle_input     ; done, wait for more input

  right: cmp ah, 0x4d  ; right arrow pressed?
  jne handle_input     ; no, wait for more input
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

col_sel  db 0x00 ; currently selected column
col0_top db 0x00 ; next row for column 0
col1_top db 0x00 ; next row for column 1
col2_top db 0x00 ; next row for column 2
col3_top db 0x00 ; next row for column 3
col4_top db 0x00 ; next row for column 4
col5_top db 0x00 ; next row for column 5
col6_top db 0x00 ; next row for column 6

blank:
  db " ",0
cursor_char:
  db 0x1F,0
; left side, internal space, internal border, right side
top_line:
  db 0xc9,0xcd,0xcb,0xbb
int_blank:
  db 0xba,0x20,0xba,0xba
int_border:
  db 0xcc,0xcd,0xce,0xb9
btm_line:
  db 0xc8,0xcd,0xca,0xbc


;
; Processes
;

; Drop a token in the currently selected column
drop_token:
  ret

; Move the drop cursor left
move_left:
  cmp byte [col_sel], 0
  je .done
  dec byte [col_sel]
  call move_dropsel
.done:
  ret

; Move the drop cursor right
move_right:
  cmp byte [col_sel], cols - 1
  je .done
  inc byte [col_sel]
  call move_dropsel
.done:
  ret

; Move the drop select cursor to the value of [col_sel]
move_dropsel:
  mov dx, board_origin + 0x0003 - 0x0100
  mov cx, 0
.loop:
  call mov_cur
  cmp cl, [col_sel]
  jne .blank
  mov si, cursor_char
  call print_str
  jmp .continue
.blank:
  mov si, blank
  call print_str
.continue:
  add dx, 6
  inc cx
  cmp cx, cols
  jne .loop

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

draw_line:
  push cx
  mov ah, 0x0e ; tty routine
  mov al, [si] ; top border char
  int 0x10 ; print
  mov cx, cols
.internal:
  mov al, [si + 1]

  push cx
  mov cx, 5
  .p int 0x10 ; print
  loop .p
  pop cx

  cmp cl, 1 ; are we on last internal loop?
  je .l ; yes, skip the internal border char
  mov al, [si + 2]
  int 0x10 ; print
  .l loop .internal
  mov al, [si + 3] ; btm border char
  int 0x10 ; print

  add dh, 0x01      ; go to next line
  call mov_cur
  pop cx
  ret

; dh = row
; dl = col
draw_board:
  call mov_cur        ; move cursor to correct spot

  mov si, top_line
  call draw_line

  mov si, int_blank
  call draw_line    ; print internal blank line

  mov cx, 5           ; loop 5 times
.loop:
  mov si, int_blank
  call draw_line    ; print internal blank line

  mov si, int_border ; print internal border line
  call draw_line

  mov si, int_blank
  call draw_line     ; print internal blank line

  loop .loop

  mov si, int_blank
  call draw_line       ; print internal blank line

  mov si, btm_line     ; print top bar
  call draw_line

  ret


times 510-($-$$) db 0 ; pad with zeros
dw 0xaa55             ; boot sector magic number
