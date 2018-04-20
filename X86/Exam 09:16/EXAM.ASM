;Exercise 6/9/16
;ITEM A

;ANALISYS OF THE PROBLEM DONE ON PAPER
;THIS KIND OF EXAM IT'S SOLVABLE BY THINKING AND WRITING A FEW LINE OF CODE

;Let us assume that in input we receive xc and yc from the user and we store ax-> al=xc ah=yc AB=30
; 3| 4yc-3xc| is the equation to be implemented in order to solve the item A

.model small
.586  ; enable pusha popa,shr shl
.stack
.data
MENU DD item_a
     DD item_b
     ;DB item_c
     DD exit
N EQU 3
BUFFER DB N+1, N+2 DUP (?)
xc DB ?
yc DB ?
base dw ?
height dw ?
area dw ?
question db "Choose one option: $"
ASK DB "Please, choose one option:$"
opt1 DB "1.Given the points and a line y=3x/4, find the area of the triangle$"
opt2 DB "2.Given one point, see if it belongs to the line y=3x/4$"
opt3 DB "3.Exit$"
Q1 DB "Give the value of xc $"
Q2 DB "Give the value of yc $"
P1 DB "The area is: $"
TRACE DB "TRACE$"
.code
;this procedure print the new line
printNL PROC
pusha
mov dl,0Ah
mov ah,2
int 21h
popa
ret
printNL ENDP

;this procedure is used to print number (also the conversion is done)
print PROC
push ax   ;push all register onto the stack
push bx
push cx
push dx
xor dx,dx   ;set to zero register and set bx=10 in order to compute division by ten
xor cx,cx
mov bx,10
division:
  div bx
  add dl,'0'
  push dx
  cmp ax,0
  je print_1
  inc cx
  xor dx,dx
  jmp division

print_1:
  mov ah,2
  inc cx
print_2:
  pop dx
  int 21h
  dec cx
  jnz print_2

  pop dx
  pop cx
  pop bx
  pop ax

ret
print ENDP

.startup


mov ax,3    ;clear the screen befor start
int 10h
xor ax,ax

startmenu:
call printNL
push dx
push ax
push di
lea dx, ASK   ;print the string
mov ah, 9
int 21h
call printNL
lea dx,opt1
mov ah, 9
int 21h
call printNL
lea dx,opt2
mov ah, 9
int 21h
call printNL
lea dx,opt3
mov ah, 9
int 21h
call printNL


mov ah,1    ;read choice from  user
int 21h
sub al, '0'   ;store into al the inputted number subtratting zero in order to get the real one
xor ah,ah     ;set to zero ah
mov di, ax
dec di  ;because first number is 0
shl di,1
shl di,1
jmp MENU[di]
pop di
pop ax
pop dx

;here we're assuming that the value of xc and yc are only one digit
item_a:
mov xc,0
mov yc,0
call printNL
lea dx, Q1      ;ask to the user for the value of xc
mov ah,9
int 21h
lea dx, BUFFER    ;load buffer address and read the value
mov ah,0Ah
int 21h
mov di,2
mov al, BUFFER[di]  ;get in al the value inserted
sub al,'0' ;make conversion in number
add xc,al   ;now xc store the value of inseted by the user

call printNL
lea dx, Q2      ;ask to the user for the value of yc
mov ah,9
int 21h
lea dx, BUFFER    ;load buffer address and read the value
mov ah,0Ah
int 21h
mov di,2
mov al, BUFFER[di]  ;get in al the value inserted
sub al,'0' ;make conversion in number
add yc,al   ;now yc store the value of inseted by the user

algorithm:
mov base,0
mov area,0
mov al, yc
xor ah,ah
shl ax,1    ; 2 *yc
shl ax,1    ;2*2*yc
mov dl, xc
xor dh,dh
mov bx,dx
shl dx,1  ;2*xc
add dx,bx   ;dx now store the value of xc*3
cmp ax,dx   ;here is necessary to check which one is the greatest
jb x_greater_y
sub ax,dx   ; 4yc-3xc
mov base,ax
jmp continue
x_greater_y:
sub dx,ax
mov base,dx
jmp continue
;compute the area
continue:
mov ax,base
mov bl,3 ; store into bl 3 in order to multyply by the value obtained
xor bh,bh
mul bx   ;result is on 32 bit
mov area,ax     ;ax store the result of area
call printNL
lea dx,P1
mov ah,9
int 21H
mov ax,area
call print
jmp startmenu


item_b:
mov xc,0
mov yc,0
call printNL
lea dx, Q1      ;ask to the user for the value of xc
mov ah,9
int 21h
lea dx, BUFFER    ;load buffer address and read the value
mov ah,0Ah
int 21h
mov di,2
mov al, BUFFER[di]  ;get in al the value inserted
sub al,'0' ;make conversion in number
add xc,al   ;now xc store the value of inseted by the user

call printNL
lea dx, Q2      ;ask to the user for the value of yc
mov ah,9
int 21h
lea dx, BUFFER    ;load buffer address and read the value
mov ah,0Ah
int 21h
mov di,2
mov al, BUFFER[di]  ;get in al the value inserted
sub al,'0' ;make conversion in number
add yc,al   ;now yc store the value of inseted by the user

algorithm_b:
mov base,0
mov area,0
mov al, yc
xor ah,ah
shl ax,1    ; 2 *yc
shl ax,1    ;2*2*yc
shl ax,1    ;4*2
mov dx,ax
shl ax,1    ;8*2
add ax,dx   ;now ax store 24
mov dl, xc
xor dh,dh
shl dx,1
mov bx,dx
shl dx,1
shl dx,1
shl dx,1  ;16
add dx,bx   ;dx now store the value of xc*18
cmp ax,dx   ;here is necessary to check which one is the greatest
jb x_greater_y_b
sub ax,dx   ; 4yc-3xc
mov base,ax
jmp continue_b
x_greater_y_b:
sub dx,ax
mov base,dx
jmp continue_b
;compute the area
continue_b:
xor dx,dx     ;division 32 bit / 16 bit
shl ax,1    
shl ax,1
shl ax,1
shl ax,1
rcl dx,1
shl ax,1
rcl dx,1 ;ready for division
mov ax,base
mov bx,5
div bx
mov area,ax     ;ax store the result of area
call printNL
lea dx,P1
mov ah,9
int 21H
mov ax,area
call print
jmp startmenu



exit:
.exit

debug PROC
push ax
push dx
lea dx,TRACE
mov ah,9
int 21H
pop dx
pop ax
debug ENDP



end
