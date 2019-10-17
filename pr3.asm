data segment para public 'data'

A   dw -170
B   db 45
C   dw 5000
D   db 2
RES dw ?

data ends

stk segment stack
    db 256 dup (?)   
stk ends

code segment para public 'code'
    assume cs:code, ds:data, ss:stk

start:
    mov ax, data
    mov ds, ax
    
    mov bx, A ; a
    mov al, D
    cbw
    add bx, ax ; a + d

    mov ax, C ; c
    idiv bx ; c / (a + d)

    xchg ax, bx

    mov al, B
    cbw
    sub ax, bx ; b - c / (a + d)

    xchg ax, bx

    mov ax, A
    cwd
    xchg ax, cx
    mov al, D
    cbw
    xchg ax, cx
    idiv cx ; a / d

    xchg ax, cx
    add ax, cx ; d + a / d

    cwd
    idiv bx ; (d + a / d) / (b - c / (a + d))

    add ax, 10 ; (d + a / d) / (b - c / (a + d)) + 10

    mov RES, ax
    
    mov ah, 4Ch
    int 21h

code ends
  end start