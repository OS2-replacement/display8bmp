display_bmp:
  mov [LoadAdress], 0 ; Top-left edge
  mov ax, 0013h
  int 10h
  mov ax, image
  mov [ImageBase], ax
  call DisplayBmp
  jnc .halt
  mov ax, 0003h
  int 10h
  mov si, error
  call print
.halt:
  hlt
  jmp .halt

DisplayBmp:
  pusha
  push ds
  push es
  mov si, [ImageBase]
  cmp word [si+00h], 4D42h
  jnz BmpError
  mov bx, [si+12h]
  mov bp, [si+16h]
  cmp bx, 320
  ja BmpError
  cmp bp, 200
  ja BmpError
  cmp word [si+1Ch], 8
  jnz BmpError
  mov si, 0036h
  add si, [ImageBase]
  mov cx, 256
  mov dx, 03C8h
  mov al, 0
  out dx, al
  inc dx
SetPalette:
  mov al, [si+2]
  shr al, 2
  out dx, al
  mov al, [si+1]
  shr al, 2
  out dx, al
  mov al, [si]
  shr al, 2
  out dx,al
  add si, 4
  loop SetPalette
  
  push 0A000h
  pop es
  lea dx, [bx+3]
  and dx, -4
  imul di,bp,320
  add di, [LoadAdress]
new_line:
  sub di, 320
  pusha
  mov cx, bx
  rep movsb
  popa
  add si, dx
  dec bp
  jnz new_line
ExitOK:
  stc
  pop es
  pop ds
  ret

BmpError:
  stc
  pop es
  pop ds
  ret
  
LoadAdress dw 0
ImageBase dw 0
; with NASM use incbin
image:
  file 'stuff.bmp'
