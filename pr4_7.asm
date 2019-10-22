sseg	segment	stack 'stack'	
    db	128 dup(?)
sseg	ends

dseg    segment 'data'

a       dw  -1
b       dw  -32
c       dw  55

msg_a   db 'Number A is the least one.', 0Dh, 0Ah, '$'
msg_b   db 'Number B is the least one.', 0Dh, 0Ah, '$'
msg_c   db 'Number C is the least one.', 0Dh, 0Ah, '$'

dseg    ends

cseg	segment	'code'
    assume	cs:cseg, ds:dseg, ss:sseg

start:
    mov ax, dseg
    mov ds, ax

    mov ax, a
    mov bx, b
    mov cx, c
    mov dl, 0

    cmp ax, bx
    jl a_less_b
    jmp endif_a_less_b
a_less_b:
    or dl, 10b
    xchg ax, bx
endif_a_less_b:
    
    cmp bx, cx
    jl b_less_c
    jmp endif_b_less_c
b_less_c:
    or dl, 01b
    xchg bx, cx
endif_b_less_c:

    test dl, 01b
    jz output_c
    test dx, 10b
    jz output_b
    lea dx, msg_a
    jmp endif_output_b
output_b:
    lea dx, msg_b
end_if_output_b:
    jmp endif_output_c
output_c:
    lea dx, msg_c
endif_output_c:

output:
    mov	ah, 09h
	int	21h

    mov ah, 4Ch
    int 21h

cseg ends
    end start