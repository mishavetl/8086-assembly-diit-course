data segment para public 'data'

A       dw 435
B       db -29
C       db 7
D       db -6
RES     dw ?

data ends

stk segment stack
    db 256 dup (?)   
stk ends

code segment para public 'code'
    assume cs:code, ds:data, ss:stk

start:
    mov ax, data
    mov ds, ax
    
    ; d * d
    mov al, D 
    imul D
    
    push ax 
    
    ; a - d * d
    mov bx, A
    sub bx, ax
    mov cx, A
    mov al, C
    imul C
    sub cx, ax
    mov al, B
    cbw
    pop dx
    add ax, dx 
    imul cx 
    idiv bx
    mov RES, ax
    
    mov ah, 4Ch
    int 21h

code ends
  end start