sseg	segment	stack 'stack'	
    db	128 dup(?)
sseg	ends

dseg    segment 'data'


CR      equ 13d
LF      equ 10d
QUOTE   equ 027h

; % Private data %
minus       dw -1
base        dw 10
str_msg     db 'Source string = $'
word_msg    db 'Word with the maximum length is ', QUOTE, '$'
length_msg  db QUOTE, ' with length of $'
index_msg   db ' at index $'
buffer_size db 255
buffer_read db 0
buffer      db 255 dup('$')

dseg    ends

cseg	segment	'code'
    assume	cs:cseg, ds:dseg, ss:sseg

; =========================================================
; Output text procedure
; =========================================================
output_text:
    mov	ah, 09h
	int	21h
    ret

; =========================================================
; Output character procedure
; =========================================================
output_character:
    mov ah, 02h
    int 21h
    ret

; =========================================================
; Output number procedure
; =========================================================
output_number:
    cmp ax, 0
    jge output_number_unsigned
    imul minus
    xchg ax, bx
    mov dl, '-'
    call output_character
    xchg ax, bx
output_number_unsigned:
    mov bx, 0
    mov cx, 0
output_number_loop:
    cmp ax, 0
    cwd
    idiv base
    add dl, '0'
    push dx
    inc bx
    cmp ax, 0
    loopne output_number_loop
    mov cx, bx
output_stack:
    pop dx
    call output_character
    loop output_stack
    ret

; =========================================================
; Buffered input procedure
; =========================================================
input_buffer:
    mov	ah, LF
	int	21h
    ret

; =========================================================
; Input data procedure
; =========================================================
input_data:
    lea dx, str_msg
    call output_text

    lea dx, buffer_size
    call input_buffer

    mov dl, 0Ah
    call output_character

    ret

; ---------------------------------------------------------
; Input point
; ---------------------------------------------------------
start:
    call init

    call input_data

    mov bx, 0 ; Maximum length
    mov ch, 0
    mov cl, buffer_read
    inc cx

    lea si, buffer - 1 ; Maximum word start index
    lea di, buffer - 1

process_string:
    mov ax, 0 ; Current length
    mov dx, di

process_word:
    inc di
    inc ax
    cmp byte ptr [di], ' '
    loopne process_word

    dec ax

    cmp ax, bx
    jbe end_update_max
    mov bx, ax
    mov si, dx
    inc si

end_update_max:
    inc cx
    loop process_string

    lea dx, word_msg
    call output_text

    lea cx, buffer
    mov dx, si
    sub dx, cx
    push dx
    
    mov dx, si
    add si, bx
    mov [si], '$'
    call output_text

    lea dx, length_msg
    call output_text
    
    mov ax, bx
    call output_number
    
    lea dx, index_msg
    call output_text

    pop ax
    call output_number

_exit:
    mov dl, LF
    call output_character
    call exit

; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
; Initialization and exit functions
; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
init:
    mov ax, dseg
    mov ds, ax
    ret

exit:
    mov ah, 4Ch
    int 21h
    ret

cseg ends
    end start