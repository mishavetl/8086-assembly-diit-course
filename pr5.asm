sseg	segment	stack 'stack'	
    db	128 dup(?)
sseg	ends

dseg    segment 'data'


; Input data
n           dw ?

; % Private data %
n_msg       db 'n = $'
sum_msg     db 'sum = $'
base        dw 10
minus       dw -1
buffer_size db 16
buffer_read db 0
buffer      db 16 dup('$')

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
; Input character procedure
; =========================================================
input_character:
    mov	ah, 08h
	int	21h
    ret

; =========================================================
; Buffered input procedure
; =========================================================
input_buffer:
    mov	ah, 0Ah
	int	21h
    ret

; =========================================================
; Input number function
; =========================================================
input_number:
    lea dx, buffer_size
    call input_buffer
    lea di, buffer
    mov ax, 0
    mov bx, 0
    mov cx, 0
    mov cl, buffer_read
    cmp byte ptr [di], '-'
    jne input_number_positive
    push minus
    inc di
    dec cl
    jmp input_number_loop
input_number_positive:
    push 1
input_number_loop:
    mul base
    mov bl, byte ptr [di]
    sub bl, '0'
    add ax, bx
    inc di
    loop input_number_loop
    cwd
    pop bx
    imul bx
    ret

; =========================================================
; Input data procedure
; =========================================================
input_data:
    lea dx, n_msg
    call output_text

    lea dx, buffer_size
    call input_number

    mov n, ax

    mov dl, 0Ah
    call output_character

    mov ax, n
    ret

; ---------------------------------------------------------
; Input point
; ---------------------------------------------------------
start:
    call init

    call input_data
    
    mov bx, 0
separate_next_digit:
    mov dx, 0
    div base

    test dx, 1
    jz next_iteration
    add bx, dx
    
next_iteration:
    cmp ax, 0
    jne separate_next_digit

    push bx

    lea dx, sum_msg
    call output_text

    pop ax
    call output_number

_exit:
    mov dl, 0Ah
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