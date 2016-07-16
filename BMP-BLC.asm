mov ax,2000h
mov ss,ax

push cs
pop ds

NextImage:

        mov ah,42h
        mov dl,80h
        mov si,offset packet
        int 13h

	cmp [200],'BM'
	jnz ContinueRendering ; check for BMP signature - if not then exit
jmp Exit
	Continue Rendering:

	mov ax,13h
	int 10h ;Screen 13 - Clear Screen

        mov dx,3c8
        mov al,0
        out dx,al ;use output port to prepare for color palette load.
        inc dx
        mov bx,21ah              ;set bx to use palette from RAM

        PaletteLoop:
                mov al,[bx+2]
                shr al,2
                out dx,al           ;get load low Endian RGB(24 bit) as high endian RGB(18 bit)
                mov al,[bx+1]
                shr al,2
                out dx,al
                mov al,[bx]
                shr al,2
                out dx,al
                add bx,3
                cmp bx,51ah
        jnz PaletteLoop
        mov ah,0


        mov cx,[212h] ; load width to bx
        add cx,3
        shr cx,2
        shl cx,2        ;adjust for scan lines as mult. of 4
        mov ax,[214h] ; load height into ax
        dec ax
        mov dx,320 ;adjust for pixel start
        imul dx  ;pixel position of first pixel
        add cx,ax ;set cx as end of loop
        mov si,51ah ; set SI to address of first pixel

        mov dx,0a000h
        push dx

        startscanline:
                mov bx,ax ; move pixel start to register that can be used as address
                nextpixel:
                        push cs
                        pop ds
                        mov dx,[si]
                        pop ds
                        push ds
                        mov [bx],dx
                        add bx,2
                        add si,2
                        cmp bx,cx
                jnz nextpixel
        	sub cx,320
		sub ax,320
        jnc startscanline
        pop ds ;clear stack
        push cs
        pop ds ; restore ds to normal.

        mov ah,0
        int 16h

        shr si,9
        add word [Vector],si
jmp NextImage ; this a while loop that terminates after it loads

Exit:
push cs
pop es ; set ES to code sector
mov ax,3
int 10h
mov ax,1300h
mov bx,7
mov cx,offset msgend - offset msg
mov dx,101h
mov bp,offset msg
int 10h
HoldLoop:
jmp  HoldLoop
packet:
dw 10h
dw 127
dw 200h
dw 7b1h
Vector dw 1
dw 0
dw 0
dw 0
Msg:
db 'Reset and Boot from another medium'
msgend:
