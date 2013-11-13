;Tic Tac Toe Program for Cpe 311 Fall 2013
; Authors: Quinn Jones & Brandon McCauley
Assume cs:code, ds:data, ss:stack

data segment
; All variables defined within the data segment 
led0 db 3
led1 db 3
led2 db 3
led3 db 3
led4 db 3
led5 db 3
led6 db 3
led7 db 3
led8 db 3
col db ?
row db ?
winningLEDS dw 3 dup(?)

activeP db 0

instruction db "The game of Tic Tac Toe: Take turns making moves on the board by pushing the row of the space and then the column.$"
turn db "It's your turn$"
Yellow db "Yellow player enter your username: $"
Green db "Green player enter your username: $"
GreenStorage db 30 dup(?)
YellowStorage db 30 dup(?)

debugP db "rows over$"
debugp2 db "column over$"


var db "w"
data ends

stack segment
;Stack size and the top of the stack defined in the stack segment
dw 100 dup(?)
stacktop:
stack ends

code segment
begin:
mov ax, data
mov ds,ax
mov ax, stack
mov ss,ax
mov sp,offset stacktop
;code begins

;begin code 

;setup ports
MOV DX, 143H	; Place I/O chip into direction mode
MOV AL, 2	
OUT DX, AL 

MOV DX, 140H	;Port A outputs to LED's b0 green 0 b1 is yellow 0 to b6 is green 3 and b7 is yellow 3
MOV AL, 0ffH
OUT DX, AL

MOV DX, 141H 	;Port B outputs to LED's b0 is green 4 to b7 is yellow 7
MOV AL, 0ffH
OUT DX, AL

mov dx,142h
mov al, 03h ; portC b0 and b1 output to box 8  b2-b7: input buttons b2,b3,b4= rows  b5,b6,b7=columns
out dx, al

MOV DX, 143H	; Place I/O chip into operation mode
MOV AL, 3
out dx,al

mov si, offset instruction
call print

mov si, offset Green
call print

mov si, offset GreenStorage
call keyInput

mov si, offset Yellow
call print

mov si, offset YellowStorage
call keyInput



mov activeP, 0
call outputBoard
mainloop:

mov si, offset turn
call print

mov al,activeP
cmp al,0
je pl1

mov si,offset YellowStorage
jmp pr

pl1:
mov si, offset GreenStorage

pr:
call print

call bInput

cmp al,0
je slg

slg:
call setLEDG
jmp outputB

call setLEDY

outputB:
call outputBoard

call checkWins

not al
mov activeP,al
jmp mainloop



end_prog:
mov ah,4ch
int 21h

print:

push si
push dx
push ax

mov ah,2
abc:
mov dl,[si] ;move the message to dl for printing
cmp dl,"$" ;stopping condition
je end_message
Int 21h
inc si ;increment along the message
jmp abc

end_message:
mov ah,2
mov dl,0dh
int 21h
mov dl,0ah
int 21h
pop ax
pop dx
pop si
ret

keyInput:

push cx
push ax


mov cx,20
mov ah,01h
input:
int 21h
cmp al,0dh
je end_input
mov [si],al

inc si
loop  input

end_input:
mov al,"$"
mov [si],al
pop ax
pop cx
ret

bInput:
push dx
push ax
mov dx,142h
rowloop:
in al,dx
and ax,0ffh
mov ah,0
shr ax,1
shr ax,1

mov ah,2

mov dl,al
int 21h
mov dl," "
int 21h
mov dx,142h
cmp al,3eh ;lowest row button
jne secondcmp

mov row,0
jmp colloop

secondcmp:
cmp al,3dh
jne thirdcmp

mov row,1
jmp colloop

thirdcmp:
cmp al,3bh
jne rowloop

mov row,2
jmp colloop


colloop:

in al,dx
and al,0ffh
mov ah,0
shr ax,1
shr ax,1

mov ah,2



mov dl,al
int 21h
mov dl," "
int 21h
mov dx,142h

cmp al,37h ;lowest row button
jne secondcmpc

mov col,0
call checkValid
jmp return


secondcmpc:
cmp al,2fh
jne thirdcmpc

mov col,1
call checkValid
jmp return

thirdcmpc:
cmp al,1fh
jne colloop

mov col,2
call checkValid


return:
pop ax
pop dx
ret
;SI holds offset of LED that should change

checkValid:
push ax
mov si, offset debugp2
call print
mov ah,row
mov al,col

cmp ah,0
je row0

cmp ah,1
je row1

cmp ah,2 
je row2

row0:
	cmp al,0
	je l0
	
	cmp al,1
	je l1
	
	cmp al,2
	je l2
	
row1:
	cmp al,0
	je l3
	
	cmp al,1
	je l4
	
	cmp al,2
	je l5

row2:
	cmp al,0
	je l6
	
	cmp al,1
	je l7
	
	cmp al,2
	je l8
	
l0:
	mov si, offset led0
	jmp end_check

l1:
	mov si, offset led1
	jmp end_check
	
l2:
	mov si, offset led2
	jmp end_check
	
l3:
	mov si, offset led3
	jmp end_check
	
l4:
	mov si, offset led4
	jmp end_check

l5:
	mov si, offset led5
	jmp end_check
	
l6:
	mov si, offset led6
	jmp end_check
l7:
	mov si, offset led7
	jmp end_check
l8:
	mov si, offset led8
	jmp end_check
	
end_check:
mov al,[si]
mov ah,3
cmp ah,al
je returnCheck
;this is where we would put a reentry prompt
call bInput
returnCheck:
pop ax
ret

setLEDG:
push ax
mov al,00000010b
mov [SI], al
pop ax
ret

setLEDY:
push ax
mov al,  00000001b
mov [SI],al
pop ax 
ret

outputBoard:
push ax
push bx
push dx

mov ax, 0
mov al, led0
mov bl, led1
shl bx,1
shl bx,1
or al,bl
mov bl, led2
shl bx,1
shl bx,1
shl bx,1
shl bx,1
or al,bl
mov bl,led3
shl bx,1
shl bx,1
shl bx,1
shl bx,1
shl bx,1
shl bx,1
or al,bl
mov dx, 140h
out dx,al

mov ax, 0
mov al, led4
mov bl,led5
shl bx,1
shl bx,1
or al,bl
mov bl, led6
shl bx,1
shl bx,1
shl bx,1
shl bx,1
or al,bl
mov bl,led7
shl bx,1
shl bx,1
shl bx,1
shl bx,1
shl bx,1
shl bx,1
or al,bl
mov dx, 141h
out dx,al

mov ax,0
mov al,led8
mov dx,142h
out dx,al

pop dx
pop bx
pop ax
ret

checkWin:
push ax

mov al,led0
cmp al,3
je combo2

mov ah, led1
cmp ah,3
je combo2

cmp ah,al
jne combo2

mov ah,led2
cmp ah,3
je combo2

cmp ah,al
jne combo2

jmp celeb


combo2:
mov al,led3
cmp al,3
je combo3

mov ah, led4
cmp ah,3
je combo3

cmp ah,al
jne combo3

mov ah,led5
cmp ah,3
je combo3

cmp ah,al
jne combo3

jmp celeb


combo3:
mov al,led6
cmp al,3
je combo4

mov ah, led7
cmp ah,3
je combo4

cmp ah,al
jne combo4

mov ah,led8
cmp ah,3
je combo4

cmp ah,al
jne combo4

jmp celeb


combo4:
mov al,led0
cmp al,3
je combo5

mov ah, led3
cmp ah,3
je combo5

cmp ah,al
jne combo5

mov ah,led6
cmp ah,3
je combo5

cmp ah,al
jne combo5

jmp celeb


combo5:
mov al,led1
cmp al,3
je combo6

mov ah, led4
cmp ah,3
je combo6

cmp ah,al
jne combo6

mov ah,led6
cmp ah,3
je combo6

cmp ah,al
jne combo6

jmp celeb


combo6:
mov al,led2
cmp al,3
je combo7

mov ah, led5
cmp ah,3
je combo7

cmp ah,al
jne combo7

mov ah,led8
cmp ah,3
je combo7

cmp ah,al
jne combo7

jmp celeb


combo7:
mov al,led0
cmp al,3
je combo8

mov ah, led4
cmp ah,3
je combo8

cmp ah,al
jne combo8

mov ah,led8
cmp ah,3
je combo8

cmp ah,al
jne combo8

jmp celeb


combo8:
mov al,led2
cmp al,3
je checkwinR				;binput?

mov ah, led4
cmp ah,3
je checkwinR			;?

cmp ah,al
jne checkwinR			;?

mov ah,led6
cmp ah,3
je checkwinR ;?

cmp ah,al
jne checkwinR				;?

jmp celeb


celeb:
call celebrate
checkwinR:
ret

celebrate:

jmp end_prog
ret

;code end
code ends
end begin
