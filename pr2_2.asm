; файл PR2.asm

sseg	segment	stack	'stack'
	db	128 dup(?)
sseg	ends

dseg	segment	'data'

text    db 'Strike while the iron is hot.'
numbers db -103
        dd 407541
        dw 35325

dseg	ends

cseg	segment	'code'
assume	cs:cseg, ds:dseg, ss:sseg

start:
    mov	ax, dseg
	mov	ds, ax

transform_text:
    mov al, text + 11
    push dword ptr [text + 7]
    pop dword ptr [text + 8]
    mov [text + 7], al

write_address_of_the_second_number:
    lea di, numbers + 1
    mov cx, 1

switch_numbers_word_first:
    mov ah, numbers + 5
    mov al, numbers + 6
    mov numbers + 5, al
    mov numbers + 6, ah

switch_numbers_word_second:
    mov ah, numbers + 5
    mov al, numbers + 6
    xchg ah, al
    mov numbers + 5, ah
    mov numbers + 6, al

switch_numbers_double_word:
    push dword ptr [numbers + 1]
    pop word ptr [numbers + 3]
    pop word ptr [numbers + 1]

	mov	ah, 4Ch
	int	21h

cseg	ends

end	start