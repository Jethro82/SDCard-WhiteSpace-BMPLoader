mov ax,cs
mov [MSector],ax ; set fie swap space to current sector
add ax,1000h
mov ss,ax ; move stack pointer to prevent 64794b files from clobbering the stack
mov dx,80h
mov cx,1h
mov bx,200h
DriveLoop:
	mov ax,201h
	int 13h

	cmp [3C6h],8192
jz EndDriveLoop
	inc dx
	cmp DX,90h ; failsafe if 16 drives fails to find proper partition table - exit
jnz DriveLoop
int 20h

EndDriveLoop:
mov byte [Drv],dl
pusha ;save sector 1 information for int13

mov ax,3d00h
mov dx,offset FileNameBlc
int 21h ;open BLC file

mov bx,ax
mov ah,3fh
mov cx,239
mov dx,200h
int 21h ; load blc to front of MBR

popa ;restore sector 1 information for int13
mov ax,301h
int 13h 

mov ax,3d00h
mov dx,offset FileNameFls
int 21h ; open list of file names

mov [FlsFileHandle],ax ; save file handle

FileDump:
	mov bx,[FlsFileHandle]
	mov dx,82h
	mov cx,126
	mov ah,3fh
	int 21h ; load next file name
	
	cmp byte [82h],':'
	jnz ContinueFileDump
		int 20h ; exit if ':' place holder found - even if this is the first iteration through the loop
	ContinueFileDump:
	mov ax,3d00h
	mov dx,82h
	int 21h ; open next file
	
	mov bx,ax ; set file handle for dealing with next file
	mov ah,3fh
	mov dx,200h
	mov cx,64794
	int 21h ; load BMP file into memory

	mov ah,3Eh
	int 21h ; close BMP file

	mov bx,[202h]
	add bx,511
	shr bx,9 ;get size of file from header - divide by 512 while rounding up
	mov [Size],bx
	
	mov ah,43h
	mov dl,[drv]
	mov si,offset PAcket
	int 13h ; Write BMP to unused disk space

	add [Vector],bx ; advance write sector for next file
jmp FileDump ; no condition is neccesary - this a 'while' loop that terminates at the top.
	






Drv db 0h
packet:
dw 10h
Size dw 127
dw 200h
MSector dw 0h
Vector dw 1
dw 0
dw 0
dw 0
FlsFileHandle dw 0
FileNameFls db 'list2',0
FileNameBLC db 'bl-bmp',0
