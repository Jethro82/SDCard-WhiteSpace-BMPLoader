mov ax,2000h
mov ss,ax ; set stack so it won't be clobbered by incoming files

push cs
pop ds ; set DS to Code Sector

NextImage:

        mov ah,42h
        mov dl,80h
        mov si,offset packet
        int 13h ; Read first 63 1/2 KB

	cmp word [200],'BM'
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
                out dx,al           ;get load little Endian RGB(24 bit) as big endian RGB(18 bit)
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


        mov cx,[212h] ; load width to cx
        add cx,3
        shr cx,2
        shl cx,2        ;adjust for scan lines as mult. of 4
        mov ax,[214h] ; load height into ax
        dec ax ; adjust for zero start
        mov dx,320 
        imul dx  ;set ax as pixel position of first pixel
        add cx,ax ;set cx as end of loop - last pixel in first iteration
        mov si,51ah ; set SI to address of first pixel in BMP File

        mov dx,0a000h
        mov ds,dx ; set ds to MCGA screen sector

        startscanline:
                mov bx,ax ; move pixel start to register that can be used as address
                nextpixel:
                        mov dx,[cs:si]
                        mov [bx],dx ; move two pixels at a time from BMP to MCGA video mem.
                        add bx,2
                        add si,2 ; advance both BMP and MCGA counters
                        cmp bx,cx 
                jnz nextpixel ;check for last pixel in scanline - if not continue loop
        	sub cx,320
		sub ax,320 ; adjust scanlines for MCGA up one row
        jnc startscanline ; checked for carry error(A becomes less than 0) - if not continue with next scanline of BMP
        push cs
        pop ds ; restore ds to normal.

        mov ah,0
        int 16h ; press any key to continue

        shr si,9
        add word [Vector],si ; use adress of last pixel in BMP to determine next sector to load - divide by 512 and add to sector counter
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
