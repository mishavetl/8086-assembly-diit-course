; файл pr_ifs.asm

sseg	segment	stack	'stack'
	db	128 dup(?)
sseg	ends

dseg	segment	'data'

N       dw 32768
textYes db 'Even', 13, 10, '$'
textNo  db 'Odd', 13, 10, '$'

dseg	ends

cseg	segment	'code'
assume	cs:cseg, ds:dseg, ss:sseg

start:
    mov	ax, dseg
	mov	ds, ax

    mov bx, 2
    mov ax, N
    ; cwd
    xor dx, dx
    div bx
    cmp dx, 0
    jne m_else
    lea dx, textYes
    jmp m_endif
m_else:
    lea dx, textNo
m_endif:
    mov ah, 9
    int 21h

	mov	ah, 4Ch
	int	21h

cseg	ends

end	start