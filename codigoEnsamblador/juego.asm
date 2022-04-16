;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   MODULO: juego                                                                ;
;       Este modulo se va a encargar de realizar todas las operaciones           ;
;       relacionadas con el menu, desde su presentacion hasta saltos.            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.module juego

.globl	print
.globl	inicializar_juego

; Variables
num_intentos	.equ	6 ; Varibale de referencia que va a almacenar el numero de intentos

; Informacion necesaria para el colocamiento del cursor
initial_up_offset:	.asciz	"\033[3A"
cursor_up:	.asciz	"\033[4A"
cursor_right:	.asciz	"\033[5C"

cabecera_juego:
	.asciz	"\n\n            W O R D L E\n\n"

columna_juego:
	.ascii	"    ###   ###   ###   ###   ###\n"
	.ascii	"    #?#   #?#   #?#   #?#   #?#\n"
	.asciz	"    ###   ###   ###   ###   ###\n\n"

inicializar_juego:
	ldx	#cabecera_juego
	jsr	print
	lda	#1

bucle_columnas:
	cmpa	#num_intentos
	bhi	cont
	ldx	#columna_juego
	jsr	print
	inca
	bra	bucle_columnas

cont:
	ldx	#initial_up_offset
	jsr	print

	ldx	#cursor_right
	jsr	print

	lda	0xFF02
	lda	0xFF02
	rts