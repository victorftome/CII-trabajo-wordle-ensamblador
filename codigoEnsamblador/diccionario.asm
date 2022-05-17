	.module diccionario

	.globl 	palabras
	.globl	num_palabras
	.globl	get_num_palabras

num_palabras:	.byte	0

palabras:
	.ascii	"MOSCA\n"
	.ascii	"PULPO\n"
	.ascii	"GANSO\n"
	.ascii	"LLAMA\n"
	.ascii	"HIENA\n"
	.ascii	"LEMUR\n"
	.ascii	"CERDO\n"
	.ascii	"CISNE\n"
	.ascii	"CARPA\n"
	.ascii	"CABRA\n"
	.ascii	"ERIZO\n"
	.ascii	"GALLO\n"
	.ascii	"TIGRE\n"
	.ascii	"CEBRA\n"
	.ascii	"OVEJA\n"
	.ascii	"PERRO\n"
	.ascii	"PANDA\n"
	.ascii	"KOALA\n"
	.byte	0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   get_num_palabras                                                             ;
;       Subrutina que devuelve el numero de palabras del diccionario.            ;
;                                                                                ;
;   Entrada: Ninguna                                                             ;
;   Salida: Ninguna                                                              ;
;   Registros afectados: CC                                                      ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
get_num_palabras:
	pshu	x,a
	ldx	#palabras

bucle_gnp:
	lda	,x+
	beq	fin_gnp

	cmpa	#'\n
	bne	bucle_gnp

	inc	num_palabras
	bra	bucle_gnp

fin_gnp:
	pulu	x,a
	rts
