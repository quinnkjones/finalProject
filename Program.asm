;Tic Tac Toe Program for Cpe 311 Fall 2013
; Authors: Quinn Jones & Brandon McCauley


Assume cs:code, ds:data, ss:stack

data segment
instuctionPrompt db "This game is called tic tac toe. The goal is to get three of your lights lit in a row before your opponent does.$"
player1NamePrompt db "Player one please enter your name.$"
player2NamePrompt db "Player two please enter your name.$"
player1Name db 20 dup(?)
player2Name db 20 dup(?)
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
mov si, offset instuctionPrompt
call print		
mov si, offset player1NamePrompt
call print
mov si, offset player1Name
mov cx,20                             ;not sure if i need
mov ah,01h                            ;not sure if i need
call input                            ;will this work?
mov si, offset player2NamePrompt
call print
mov si, offset player2Name
mov cx,20                             ;not sure if i need
mov ah,01h                            ;not sure if i need
call input                            ;will this work?


print:			 ;pushes the letters into the stack
push si
push dx
push ax

mov ah,2
abc:
mov dl,[si]		 ;move the message to dl for printing
cmp dl,"$"		 ;stopping condition
je end_message
Int 21h
inc si		 	 ;increment along the message
jmp abc

end_message:  		 ;prints the message
pop ax
pop dx
pop si
ret			 ;returns back to the original call statement

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
ret

;code end
