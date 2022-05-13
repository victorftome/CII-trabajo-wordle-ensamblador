;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   MODULO: instrucciones                                                        ;
;       Este modulo contiene las rutinas necesarias para mostrar las             ;
;       instrucciones                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.module instrucciones

; Subrutinas importadas
.globl	print
.globl	pedir_confirmacion

; Subrutinas exportadas
.globl	print_instrucciones

instrucciones:
	.ascii	"\33[2J\33[H\33[1m========== INSTRUCCIONES (Wordle) ==========\n"
	.ascii	"Funcionamiento del juego: \33[0m\n"
	.ascii	"\tAl iniciar el juego apareceran 6 columnas de 5 casillas\n"
	.ascii	"\ten estas casillas se introduciran las palabras a comprobar.\n"

	.ascii	"\tSe tiene en total una cantidad de 6 intentos para adivinar la palabra oculta.\n"
	.ascii	"\tA modo de ayuda se le indicaran por colores diferentes pistas:\n"

	.ascii	"\t\t\33[32m\33[1mVerde:\33[0m La letra introducida esta en la posicion correcta\n"
	.ascii 	"\t\trespecto a la palabra secreta.\n"

	.ascii	"\t\t\33[33m\33[1mAmarillo:\33[0m La letra introducida se encuentra en la palabra secreta\n"
	.ascii 	"\t\tpero en otra posicion a la introducida.\n"

	.asciz	"\t\t\33[31m\33[1mRojo:\33[0m La letra introducida no se encuentra en la palabra secreta.\n\n"

controles:
	.ascii	"\33[1mCaracteres especiales: \33[0m\n"
	.ascii	"Mientras el juego se encuentre en ejecucion, se tendran unos caracteres\n"
	.ascii	"'especiales' que permitiran controlar el juego. Siendo estos los siguientes: \n"
	.ascii	"\t\33[1mEspacio:\33[0m Al pulsar el espacio se borrara una letra introducida.\n"
	.ascii	"\t\33[1mLetra 'r':\33[0m Al pulsar la letra r se reiniciara la partida.\n"
	.ascii	"\t\33[1mLetra 'v':\33[0m Al pulsar la letra v se saldra del juego y se volvera al menu.\n"
	.asciz	"\t\33[1mEnter:\33[0m Se comprobara la palabra indicada."

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   print_instrucciones                                                          ;
;       Imprime las instrucciones.                                               ;
;                                                                                ;
;   Entrada: Ninguna                                                             ;
;   Salida: Ninguna                                                              ;
;   Registros afectados: CC                                                      ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print_instrucciones:
	ldx	#instrucciones
	jsr	print

	ldx	#controles
	jsr	print

	jsr	pedir_confirmacion

	rts