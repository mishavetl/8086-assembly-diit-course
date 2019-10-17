sseg	segment	stack 'stack'	
    db	128 dup(?)
sseg	ends

dseg    segment 'data'


; Input data
x           dw ?
y           dw ?

; % Private data %
yes_msg     db 'The given point is located in the first or third quarter', 0Dh, 0Ah, '$'
no_msg      db 'The given point isn', 27h ,'t located in the first or third quarter', 0Dh, 0Ah, '$'
x_msg       db 'x = $'
y_msg       db 'y = $'
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
    lea dx, x_msg
    call output_text

    lea dx, buffer_size
    call input_number

    mov x, ax

    mov dl, 0Ah
    call output_character

    lea dx, y_msg
    call output_text

    lea dx, buffer_size
    call input_number

    mov y, ax

    mov dl, 0Ah
    call output_character

    mov ax, x
    mov bx, y
    ret

; ---------------------------------------------------------
; Input point
; ---------------------------------------------------------
start:
    call init

    call input_data
    
    mov cx, 0

    cmp ax, 0
    je no
    jg right
    or cx, 01b
right:
    nop

    cmp bx, 0
    je no
    jg up
    or cx, 10b
up:
    nop

    cmp cx, 00b
    je yes
    cmp cx, 11b
    je yes

    jmp no
    
yes:
    cmp cx, 0
    lea dx, yes_msg
    call output_text
    jmp _exit

no:
    lea dx, no_msg
    call output_text

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