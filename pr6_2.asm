sseg	segment	stack 'stack'	
    db	128 dup(?)
sseg	ends

dseg    segment 'data'


CR      equ 13d
LF      equ 10d
QUOTE   equ 027h

; - Input data -
m                   dw ?
n                   dw ?
matrix              dw 255 dup(?)

; % Private data %
number_length       dw ?
minus               dw -1
two                 dw 2
base                dw 10
m_msg               db 'Matrix height (m) = $'
n_msg               db 'Matrix width (n) = $'
matrix_msg          db 'Matrix (', CR, LF, 'a11 a12', CR, LF, 'a21 a22', CR, LF, ') =', CR, LF, '$'
output_start_msg    db 'Output matrix = (', CR, LF, '$'
output_end_msg      db ')', CR, LF, '$'
buffer_size         db 255
buffer_read         db 0
buffer              db 255 dup('$')

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
output_number proc near
    push bx
    push dx
    push cx
    
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
    
    pop cx
    pop dx
    pop bx
    ret
output_number endp

; =========================================================
; Buffered input procedure
; =========================================================
input_buffer:
    mov	ah, LF
	int	21h
    ret

; =========================================================
; Input number function
; @ret ax: number from stdin
; =========================================================
input_number proc near
    push bx
    push dx
    push cx

    lea dx, buffer_size
    call input_buffer

    lea di, buffer

    mov cx, 0
    mov cl, buffer_read
    mov number_length, cx
    call parse_number

    pop cx
    pop dx
    pop bx
    ret
input_number endp

; =========================================================
; Parse number function
; @param di: buffer pointer
; @param cx: max number length to parse
; @ret ax: parsed number
; =========================================================
parse_number proc near
    push bx
    push dx

    mov ax, 0
    mov bx, 0
    mov cx, number_length
    cmp byte ptr [di], '-'
    jne input_number_positive
    push minus
    inc di
    dec cl
    jmp .input_number_loop
input_number_positive:
    push 1
.input_number_loop:
    mov bl, byte ptr [di]
    cmp bl, ' '
    je break_input_number_loop
    mul base
    sub bl, '0'
    add ax, bx
    inc di
    loop .input_number_loop

break_input_number_loop:
    cwd
    pop bx
    imul bx
    mov number_length, cx

    pop dx
    pop bx
    ret
parse_number endp

; =========================================================
; Matrix input/output procedures
; =========================================================
input_matrix proc near
    push dx
    push di
    push bx
    push cx

    lea dx, matrix
    mov cx, m

input_matrix_loop:
    xchg bx, cx
    
    push dx
    mov dl, ' '
    call output_character

    lea dx, buffer_size
    call input_buffer
    pop dx

    lea di, buffer
    mov ch, 0
    mov cl, buffer_read

    push dx
    mov dl, CR
    call output_character
    mov dl, LF
    call output_character
    pop dx

    .input_matrix_line_loop:
        mov number_length, cx
        call parse_number
        mov cx, number_length
        xchg di, dx
        mov [di], ax
        xchg di, dx
        inc di
        add dx, 2
        dec cx
        cmp cx, 0
        jg .input_matrix_line_loop

    xchg bx, cx
    loop input_matrix_loop

    pop cx
    pop bx
    pop di
    pop dx
    ret
input_matrix endp

output_matrix proc near
    push cx
    push bx
    push di

    mov cx, m
    lea di, matrix

output_matrix_loop:
    xchg cx, bx
    mov cx, n
    .output_matrix_line_loop:
        mov ax, [di]
        call output_number
        mov dl, ' '
        call output_character
        add di, 2
        loop .output_matrix_line_loop

    mov dl, CR
    call output_character
    mov dl, LF
    call output_character
    
    xchg cx, bx
    loop output_matrix_loop

    pop di
    pop bx
    pop cx
    ret
output_matrix endp

; =========================================================
; Find maximum element of a row
; @param di: matrix row pointer
; @param cx: number of elements
; @ret ax: maximum element
; =========================================================
max_element proc near
    mov ax, 0
    
max_element_loop:
    cmp [di], ax
    jle endif_update_max
    mov ax, [di]
endif_update_max:
    add di, 2    
    loop max_element_loop
    ret
max_element endp

xchg_rows proc near
    push cx
    push di

    mov cx, 0
    mov di, ax

xchg_loop:
    mov ax, word ptr [di]
    xchg ax, word ptr [bx]
    mov word ptr [di], ax
    add di, 2
    add bx, 2
    inc cx
    cmp cx, n
    jl xchg_loop

    pop di
    pop cx
    ret
xchg_rows endp

; =========================================================
; Sort matrix by maximum elements of row
; @param matrix: matrix
; @param m: number of rows
; @param n: number of columns
; =========================================================
sort_by_max_element proc near
    push ax
    push bx
    push cx
    push dx

    mov cx, m
    dec cx

sort_loop1:
    mov bx, cx
    mov cx, m
    sub cx, bx
    push bx

sort_loop2:
    push dx
    mov dx, 0
    mov ax, cx
    dec ax
    mul n
    mul two
    pop dx

    push ax
    push dx
    mov dx, 0
    mov ax, cx
    mul n
    mul two
    mov bx, ax
    pop dx
    pop ax

    add ax, offset matrix

    push ax
    push cx
    mov di, ax
    mov cx, n
    call max_element
    mov dx, ax
    pop cx
    pop ax
    
    add bx, offset matrix

    push ax
    push cx
    mov di, bx
    mov cx, n
    call max_element
    pop cx
    cmp dx, ax
    pop ax
    jle endif_xchg
    call xchg_rows
endif_xchg:
    loop sort_loop2

    pop bx
    mov cx, bx
    loop sort_loop1

    pop dx
    pop cx
    pop bx
    pop ax
    ret
sort_by_max_element endp

; =========================================================
; Input data procedure
; =========================================================
input_data:
    lea dx, m_msg
    call output_text

    call input_number
    mov m, ax

    mov dl, CR
    call output_character
    mov dl, LF
    call output_character

    lea dx, n_msg
    call output_text

    call input_number
    mov n, ax

    mov dl, CR
    call output_character
    mov dl, LF
    call output_character

    lea dx, matrix_msg
    call output_text

    call input_matrix

    mov dl, 0Ah
    call output_character

    ret

; ---------------------------------------------------------
; Input point
; ---------------------------------------------------------
start:
    call init

    call input_data

    call sort_by_max_element
    
    lea dx, output_start_msg
    call output_text

    call output_matrix

    lea dx, output_end_msg
    call output_text

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