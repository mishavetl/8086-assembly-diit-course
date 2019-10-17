; файл PR2.asm

sseg	segment	stack	'stack'
	db	128 dup(?)
sseg	ends

dseg	segment	'data'

; input
text        db "Rome wasn't built in a day."
numbers     dw 30200
            dd -298475
            db 200

dseg	ends

cseg	segment	'code'
assume	cs:cseg, ds:dseg, ss:sseg


start:
    mov	ax, dseg
	mov	ds, ax

transform_first_word:
    mov al, text
    xchg al, text + 1
    xchg text, al

transform_second_word:
    mov al, text + 5
    xchg al, text + 6
    xchg text + 5, al

write_second_number_address:
    lea ax, numbers + 2

exchange_numbers_w_1:
    mov ax, numbers
    mov bl, ah
    mov bh, al
    mov numbers, bx

exchange_numbers_w_2:
    mov ax, numbers
    xchg ah, al
    mov numbers, ax

exchange_numbers_d:
    mov ax, numbers + 2
    xchg ax, numbers + 3
    mov numbers + 2, ax

	mov	ah, 4Ch
	int	21h

cseg	ends

end	start