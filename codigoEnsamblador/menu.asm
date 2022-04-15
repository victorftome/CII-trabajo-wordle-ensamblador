;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   MODULO: menu                                                                 ;
;       Este modulo se va a encargar de realizar todas las operaciones           ;
;       relacionadas con el menu, desde su presentacion hasta saltos.            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.module menu

.globl	print_menu

; Subrutinas a usar
.globl	print

; Variables globales
.globl	palabras
.globl	lineas_leidas

cadena_menu:
	.ascii "\n\n####################################\n"
	.ascii "#        1) Ver diccionario        #\n"
	.ascii "#        2) Jugar                  #\n"
	.ascii "#        3) Salir                  #\n"
	.asciz "####################################\n"

cadena_solicitud_opcion:
	.asciz "Introduzca la opcion deseada: "

cadena_opcion_incorrecta:
	.asciz "\nLa opcion introducida no es valida.\n"

cadena_diccionario:
	.asciz "\n\nDICCIONARIO:\n"

cadena_num_palabras:
	.asciz "Num de palabras: "

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   print_menu                                                                   ;
;       Imprime el menu y se queda esperando la opción                           ;
;                                                                                ;
;   Entrada: Ninguna                                                             ;
;   Salida: Ninguna                                                              ;
;   Registros afectados: CC                                                      ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print_menu:
	pshu	x,a

	ldx		#cadena_menu
	jsr		print

solicitud_opcion:
	ldx		#cadena_solicitud_opcion
	jsr		print

	lda		0xFF02
	bra		comprobar_opcion

salir:
	pulu	x,a
	rts

comprobar_opcion:
	cmpa	#'1					; Comprobamos la primera opcion
	beq		mostrar_diccionario	; Saltamos a la subrutina de mostrar diccionario

	cmpa	#'2
	beq		jugar

	cmpa	#'3
	beq		salir

	ldx		#cadena_opcion_incorrecta
	jsr		print

	bra		solicitud_opcion

mostrar_diccionario:
	pshu	x,a

	ldx		#cadena_diccionario
	jsr		print

	ldx		#palabras
	jsr		print

	lda		lineas_leidas

	ldx		#cadena_num_palabras
	jsr		print

	sta		0xFF00

	pulu	x,a
	bra		print_menu

jugar:
	rts