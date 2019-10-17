; файл PR1.asm

; сегмент стека
sseg	segment	stack	'stack'
db		128 dup(?)
sseg	ends

; сегмент данных 
dseg	segment	'data'
; текст
db	"Strike while the iron is hot."
; байт
dbA	db	-103
; слово 
dwA	dw	234
dwB	dw	-30211
; подвійне слово
ddA	dd	35325
ddB	dd	407541
ddC	dd	-193567
dwC	dd	-367.278
dseg	ends

; сегмент команд
cseg	segment	'code'
assume	cs:cseg, ds:dseg, ss:sseg
; мітка початку програми з ім’ям start 
start:	mov	ax, dseg
mov	ds, ax
; повернення керування ОС 
mov	ah, 4Ch
int	21h
cseg	ends
end	start	; закінчення програми
