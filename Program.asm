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
activeP db 0

instruction db "The game of Tic Tac Toe: Take turns making moves on the board by pushing the row of the space and then the column.$"
turn db "It's your turn$"
Yellow db "Yellow player enter your username: $"
Green db "Green player enter your username: $"

GreenStorage db 30 dup(?)
YellowStorage db 30 dup(?)

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

MOV DX, 140H	
MOV AL, 0ffH
OUT DX, AL

MOV DX, 141H
MOV AL, 0feH
OUT DX, AL

mov dx,142h
mov al, 00
out dx, al

MOV DX, 143H	; Place I/O chip into operation mode
MOV AL, 3
out dx,al

mov si, offset instruction
call print
mov si, offset Yellow
call print

mov si, offset YellowStorage
call keyInput

mov si, offset Green
call print

mov si, offset GreenStorage
call keyInput

mov activeP, 0
mainloop:

mov si, offset turn
call print

mov al,activeP
cmp al,0
je pl1

mov si, offset GreenStorage
jmp pr

pl1:
mov si,offset YellowStorage

pr:
call print








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

;code end
code ends
end begin
