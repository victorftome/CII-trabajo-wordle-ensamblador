;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   MODULO: presentación                                                         ;
;       En este modulo se van a crear todas las subrutinas que                   ;
;       van a realizar operaciones con cadenas                                   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.module presentacion

.globl print_presentacion

; Subrutinas que vamos a usar
.globl print

; Variables con la presentación a imprimir
title:
	.ascii " ____ ____ ____ ____ ____ ____ \n"
	.ascii "||\33[32mW\33[37m |||\33[32mO\33[37m |||\33[32mR\33[37m |||\33[33mD\33[37m |||\33[31mL\33[37m |||\33[31mE\33[37m ||\n"
	.ascii "||__|||__|||__|||__|||__|||__||\n"
	.ascii "|/__\|/__\|/__\|/__\|/__\|/__\|\n"
	.asciz " ____ ____ ____ ____ ____ ____ \n\n"

authors:
	.ascii "Programa realizado por \n"
	.ascii "\t\33[32mVictor \33[33mFuncia \33[31mTome\33[37m   | victorfunciatome@usal.es\n"
	.asciz "\t\33[33mManuel \33[32mGarcia \33[31mCortes\33[37m | ManuGaCo@usal.es\n\n"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   print_presentacion                                                           ;
;       Imprime la presentacion. Título y autores                                ;
;                                                                                ;
;   Entrada: Ninguna                                                             ;
;   Salida: Ninguna                                                              ;
;   Registros afectados: CC                                                      ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print_presentacion:
	pshu	x		; Almacenamos el contenido de x en la pila para posterior recuperacion

	ldx		#title	; Cargamos en el registro x con la dir de inicio de la cadena
	jsr		print	; ejecutamos la subrutina print, que toma como parametro el contenido de x

	ldx		#authors	; Cargamos en el registro x con la dir de inicio de la cadena
	jsr		print		; ejecutamos la subrutina print, que toma como parametro el contenido de x

	pulu	x		; Recuperamos el valor del registro x
	rts