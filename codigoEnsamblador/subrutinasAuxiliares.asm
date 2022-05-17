;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   MODULO: subrutinasAuxiliares                                                 ;
;       En este modulo se van a crear todas las subrutinas auxiliares            ;
;       que se van a usar de forma general sin pertenecer a una seccion          ;
;       especifica                                                               ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.module	subrutinasAuxiliares

; Variables importadas
.globl	num_palabras

; Subrutinas importadas
.globl	print

; Subrutinas exportadas
.globl	pedir_confirmacion
.globl	get_next_word
.globl	palabras

posicion_palabra:	.byte	0

mensaje_continuar:
	.asciz "\n\nPulse una tecla para continuar..."

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   pedir_confirmacion                                                           ;
;       Espera a que se introduzca un caracter para seguir con la ejecucion      ;
;       del programa                                                             ;
;                                                                                ;
;   Entrada: Ninguna                                                             ;
;   Salida: Ninguna                                                              ;
;   Registros afectados: B, CC                                                   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pedir_confirmacion:
	ldx	#mensaje_continuar
	jsr	print

	pshu	a
	lda	0xFF02	; Esperamos a que nos introduzca una caracter
	pulu	a

	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   get_next_word                                                                ;
;       Subrutina que devuelve un entero que indica la palabra a tomar.          ;
;                                                                                ;
;   Entrada: Ninguna                                                             ;
;   Salida: B-El numero que indica la posicion de la palabra                     ;
;   Registros afectados: CC                                                      ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
get_next_word:
	pshu	b,a
	inc	posicion_palabra
	ldx	#palabras

	clra

	ldb	posicion_palabra

	cmpb	num_palabras
	bne	#bucle_palabra_gnw

	clr	posicion_palabra

bucle_palabra_gnw:
	cmpa	posicion_palabra
	beq	rts_gnw

	leax	6,x
	inca
	bra	bucle_palabra_gnw

rts_gnw:
	pulu	b,a
	rts
