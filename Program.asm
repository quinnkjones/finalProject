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
winningCombo db ?
turncount db 0
activeP db 0

instruction db "The game of Tic Tac Toe: Take turns making moves on the board by pushing the row of the space and then the column.$"
turn db "It's your turn$"
Yellow db "Yellow player enter your username: $"
Green db "Green player enter your username: $"
GreenStorage db 30 dup(?)
YellowStorage db 30 dup(?)
catmessage db "T'was a Draw"
filledPrompt db "Space already taken$"

win db "win is you:$"


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
MOV DX, 143H        ; Place I/O chip into direction mode
MOV AL, 2        
OUT DX, AL 

MOV DX, 140H        ;Port A outputs to LED's b0 green 0 b1 is yellow 0 to b6 is green 3 and b7 is yellow 3
MOV AL, 0ffH
OUT DX, AL

MOV DX, 141H         ;Port B outputs to LED's b0 is green 4 to b7 is yellow 7
MOV AL, 0ffH
OUT DX, AL

mov dx,142h
mov al, 03h ; portC b0 and b1 output to box 8  b2-b7: input buttons b2,b3,b4= rows  b5,b6,b7=columns
out dx, al

MOV DX, 143H        ; Place I/O chip into operation mode
MOV AL, 3
out dx,al

beginPlay:
mov led0,0
mov led1,0
mov led2,0
mov led3,0
mov led4,0
mov led5,0
mov led6,0
mov led7,0
mov led8,0
call outputBoard
mov led0,3
mov led1,3
mov led2,3
mov led3,3
mov led4,3
mov led5,3
mov led6,3
mov led7,3
mov led8,3
mov turncount, 0

mov si, offset instruction
call print

mov si, offset Green
call print

mov si, offset GreenStorage		;Take in the screen name of the green player
call keyInput

mov si, offset Yellow
call print
	
mov si, offset YellowStorage	;Take in the screen name of the yellow player#A52A2A
call keyInput



mov activeP, 0  ;Makes green the first player
call outputBoard
mainloop:

mov si, offset turn ;announce change of turn
call print 

mov al,activeP ;"if statement" that prints out the appropriate screen name
cmp al,0
je pl1

mov si,offset YellowStorage
jmp pr

pl1:
mov si, offset GreenStorage

pr:
call print

call bInput ;take input from the push buttons

call SetPlayer ;use input from buttons to make the correct square on the board owned by the correct player

call outputBoard ;output the changes made in this turn

mov al,turncount ;increment the count of turns
inc al
mov turncount, al

call checkWin ;see if anyone won

mov al,turncount ;see if all the spaces have been taken
cmp al,9
je draw ;must have been a draw then

mov al,activeP	;change the active player and take a new turn
not al
mov activeP,al
jmp mainloop

draw:
mov si, offset catmessage ;print that there was a draw and then startover
call print
jmp beginPlay

end_prog: ;seperates the main loop from subroutines in case the program tries to run lose
mov ah,4ch
int 21h

print: ;prints out a message copied from old labs

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

keyInput: ;takes keyboard input and stores it in a buffer also taken from old lab work.

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

bInput: ;uses input from the buttons
push dx
push ax
mov dx,142h ;port number for port c
rowloop:
in al,dx  
and ax,0ffh ;solidify the input from c
mov ah,0 
shr ax,1 ;eliminates the values of b0 and b1 since they are outputs and we weren't sure how inputing from an output works
shr ax,1

mov ah,2 ;used to print al to the dos prompt for debugging

mov dl,al
;int 21h
mov dl," "
;int 21h
mov dx,142h
cmp al,3eh ; compare to the lowest row button
jne secondcmp

mov row,0 ;assign row variable for later use
jmp colloop

secondcmp:
cmp al,3dh ;compare to the middle row
jne thirdcmp

mov row,1
jmp colloop

thirdcmp:
cmp al,3bh ;compare to the highest row
jne rowloop

mov row,2
jmp colloop


colloop: ;same procedure as the row loop but with different comparisons

in al,dx
and al,0ffh
mov ah,0
shr ax,1
shr ax,1

mov ah,2



mov dl,al
;int 21h
mov dl," "
;int 21h
mov dx,142h

cmp al,37h ;lowest col button
jne secondcmpc

mov col,0
call checkValid ;we now have a row and column so call checkvalid to see if this space is usable
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

checkValid: ;checks whether a square is available
push ax


mov ah,row
mov al,col

cmp ah,0 ;given a row number and a column number decode that into an led index
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
        mov si, offset led0 ;mov led variable into si so it can be referenced later
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
mov al,[si] ;check if the square is empty
mov ah,3
cmp ah,al
je returnCheck
mov si, offset filledPrompt ;it wasn't empty so we'll print that out and force the player to input a different one
call print
call bInput
returnCheck: ;it was empty so skip calling binput again and return all the way back to mainloop
pop ax 
ret

setLEDG: ;sets the value of the led pointed to by SI with a value indicating green owns it
push ax
mov al,00000010b
mov [SI], al
pop ax
ret

setLEDY: sets the value of the led pointed to by SI witha value indicating yellow owns it
push ax
mov al,  00000001b
mov [SI],al
pop ax 
ret

outputBoard: ;uses the led variables to output the board configuration
push ax
push bx
push dx

mov ax, 0
mov al, led0 ;put the first square into the b0 and b1
mov bl, led1
shl bx,1
shl bx,1
or al,bl  ;puts the second square into b2 and b3 
mov bl, led2
shl bx,1
shl bx,1
shl bx,1
shl bx,1
or al,bl ;and so on
mov bl,led3
shl bx,1
shl bx,1
shl bx,1
shl bx,1
shl bx,1
shl bx,1
or al,bl
mov dx, 140h
out dx,al ;outputs the first four squares of the board

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

checkWin: ;checks if the playing board is in a won state by checking every possible winning combination
push ax


mov al,led0 ;check if any square in the combo are empty and skip the rest
cmp al,3
je combo2

mov ah, led1 ;check if this square is not zero and equal to the "first" in the series
cmp ah,3
je combo2

cmp ah,al
jne combo2

mov ah,led2 ;check if this square is not zero and equal to the "first" and by extension the "second" in the series
cmp ah,3
je combo2

cmp ah,al
jne combo2

;the only way we get here is if all three in this winning combination are held by the same player
mov winningCombo, 0 ;index to denote with combination was triggered for later use
jmp celeb

; and so on for every possible combination
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

mov winningCombo, 1
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

mov winningCombo, 2
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

mov winningCombo, 3
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

mov ah,led7
cmp ah,3
je combo6

cmp ah,al
jne combo6

mov winningCombo, 4
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

mov winningCombo, 5
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

mov winningCombo, 6
jmp celeb


combo8:
mov al,led2
cmp al,3
je checkwinR ;jumps to the return statement as this is the last combo and no one has one yet apparently

mov ah, led4
cmp ah,3
je checkwinR                        

cmp ah,al
jne checkwinR                        

mov ah,led6
cmp ah,3
je checkwinR 

cmp ah,al
jne checkwinR                                

mov winningCombo, 7
jmp celeb


celeb:
call celebrate ;someone has won so we need to celebrate that
checkwinR: ;no one has won so we need to keep going
pop ax
ret

celebrate: ;celebrates a win
mov si,offset win ;print out a message indicating winning
call print

mov al,activeP ;print out the screen name of the winner based on the value of the active player from the last turn
cmp al,0
jne YellowWin

mov si,offset GreenStorage
jmp printing

YellowWin:
mov si,offset YellowStorage

printing:
call print

mov cx,25


mov al,winningCombo  ;decode to a different celebration loop for every possible winning combination
cmp al,0
jne wincombo1

loop1: ;loop for winning combination #0
mov si, offset led0 ;turn the led's in this combo to the color of the player who won
call SetPlayer
mov si, offset led1
call SetPlayer
mov si,offset led2
call SetPlayer

call outputBoard ;output that

call delay ; delay for about .25s

mov led0,3 ;turn them all off
mov led1,3
mov led2,3

call outputBoard ;output that and delay then do it again for 25x
call delay
loop loop1
jmp beginPlay ;start the game over

;All other cases reflect this setup

wincombo1:
cmp al,1
jne wincombo2
loop2:
mov si, offset led3
call SetPlayer
mov si, offset led4
call SetPlayer
mov si,offset led5
call SetPlayer

call outputBoard 

call delay

mov led3,3
mov led4,3
mov led5,3

call outputBoard
call delay
loop loop2
jmp beginPlay

wincombo2:
cmp al,2
jne wincombo3

loop3:
mov si, offset led6
call SetPlayer
mov si, offset led7
call SetPlayer
mov si, offset led8
call SetPlayer

call outputBoard 

call delay

mov led6,3
mov led7,3
mov led8,3

call outputBoard
call delay
loop loop3
jmp beginPlay

wincombo3:
cmp al,3
jne wincombo4

loop4:
mov si, offset led0
call SetPlayer
mov si, offset led3
call SetPlayer
mov si, offset led6
call SetPlayer

call outputBoard 

call delay

mov led0,3
mov led3,3
mov led6,3

call outputBoard
call delay
loop loop4
jmp beginPlay

wincombo4:
cmp al,4
jne wincombo5
loop5:
mov si, offset led1
call SetPlayer
mov si, offset led4
call SetPlayer
mov si, offset led7
call SetPlayer

call outputBoard 

call delay

mov led1,3
mov led4,3
mov led7,3

call outputBoard
call delay
loop loop5
jmp beginPlay

wincombo5:
cmp al,5
jne wincombo6
loop6:
mov si, offset led2
call SetPlayer
mov si, offset led5
call SetPlayer
mov si, offset led8
call SetPlayer

call outputBoard 

call delay

mov led2,3
mov led5,3
mov led8,3

call outputBoard
call delay
loop loop6
jmp beginPlay

wincombo6:
cmp al,6
jne wincombo7
loop7:
mov si, offset led0
call SetPlayer
mov si, offset led4
call SetPlayer
mov si, offset led8
call SetPlayer

call outputBoard 

call delay

mov led0,3
mov led4,3
mov led8,3

call outputBoard
call delay
loop loop7
jmp beginPlay

wincombo7:
loop8:
mov si, offset led2
call SetPlayer
mov si, offset led4
call SetPlayer
mov si, offset led6
call SetPlayer

call outputBoard 

call delay

mov led2,3
mov led4,3
mov led6,3

call outputBoard
call delay
loop loop8
jmp beginPlay



SetPlayer: ;changes the led variable to reflect that a change has been made by calling setLEDG or setLEDY based on the activeP
push ax
mov al,activeP
cmp al,0
jne yellowPlayer

call setLEDG
jmp endPlayer

yellowPlayer:
call setLEDY

endPlayer:
pop ax
ret


delay: ;delay subroutine copied from prior labs
push bx
push cx
mov bx,5
loop2d:
mov cx, 0ffffh
loop1d:
nop
loop loop1d
dec bx
jnz loop2d

pop bx
pop cx

ret

;code end
code ends
end begin
