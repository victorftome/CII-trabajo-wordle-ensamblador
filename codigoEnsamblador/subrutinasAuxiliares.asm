;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   MODULO: subrutinasAuxiliares                                                 ;
;       En este modulo se van a crear todas las subrutinas auxiliares            ;
;       que se van a usar de forma general sin pertenecer a una seccion          ;
;       especifica                                                               ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.module	subrutinasAuxiliares

; Subrutinas importadas
.globl	print

; Subrutinas exportadas
.globl	pedir_confirmacion

mensaje_continuar:
	.asciz "\n\nPulse una tecla para continuar..."

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   pedir_confirmacion                                                           ;
;       Espera a que se introduzca un caracter para seguir con la ejecucion      ;
;       del programa                                                             ;
;                                                                                ;
;   Entrada: Ninguna                                                             ;
;   Salida: Ninguna                                                              ;
;   Registros afectados: CC                                                      ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pedir_confirmacion:
	ldx	#mensaje_continuar
	jsr	print

	pshu	a
	lda	0xFF02	; Esperamos a que nos introduzca una caracter
	pulu	a

	rts
	