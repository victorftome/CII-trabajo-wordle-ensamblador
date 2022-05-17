;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   MODULO: menu                                                                 ;
;       Este modulo se va a encargar de realizar todas las operaciones           ;
;       relacionadas con el menu, desde su presentacion hasta saltos.            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.module menu

.globl	cargar_menu

; Subrutinas a usar
.globl	print
.globl inicializar_juego
.globl	int_to_char
.globl	print_instrucciones
.globl	pedir_confirmacion

; Variables globales
.globl	palabras
.globl	num_palabras

cadena_menu:
	.ascii "\33[2J\33[H####################################\n"
	.ascii "#        1) Ver diccionario        #\n"
	.ascii "#        2) jugar                  #\n"
	.ascii "#        3) Instrucciones          #\n"
	.ascii "#        S) Salir                  #\n"
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
;   cargar_menu                                                                  ;
;       Imprime el menu y se queda esperando la opción                           ;
;                                                                                ;
;   Entrada: Ninguna                                                             ;
;   Salida: Ninguna                                                              ;
;   Registros afectados: Y, B, CC                                                ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
cargar_menu:
	pshu	x,a

print_menu:
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
	cmpa	#'1				; Comprobamos la primera opcion
	beq		mostrar_diccionario	; Saltamos a la subrutina de mostrar diccionario

	cmpa	#'2
	beq		jugar_menu

	cmpa	#'3
	beq		instrucciones

	cmpa	#'S
	beq		salir

	cmpa	#'s
	beq		salir

	ldx		#cadena_opcion_incorrecta
	jsr		print

	bra		solicitud_opcion

mostrar_diccionario:
	pshu	x,d

	ldx	#cadena_diccionario
	jsr	print

	ldx	#palabras
	jsr	print

	ldx	#cadena_num_palabras
	jsr	print

	ldb	num_palabras

	; Pasamos el numero en B a caracter
	jsr	int_to_char

	sta	0xFF00
	stb	0xFF00

	pulu	x,d

	jsr	pedir_confirmacion

	bra	print_menu

instrucciones:
	jsr	print_instrucciones
	bra	print_menu

jugar_menu:
	jsr	inicializar_juego
	bra	print_menu
