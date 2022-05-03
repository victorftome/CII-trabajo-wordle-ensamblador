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
save_cursor_position:	.asciz	"\033[s"
restore_cursor_position:	.asciz	"\033[u"

; Arreglo en el que vamos a almacenar las letras con los colores.
; Como los colores son una secuancia ANSI que ocupan 1 byte,
; por lo tanto son 6 palabras por 5 letras cada una nos da un total
; de 30 letras a almacenar, como cada letra tiene que ir a compañada de su color
; esto hara que tengamos que almacenar 30 * 2 = 60 caracteres + el caracter nulo 61 carateres
cadena_palabras: .asciz "????????????????????????????????????????????????????????????"


cabecera_juego:
	.asciz	"\n\n            W O R D L E\n\n"

columna_juego:
	.ascii	"    ###   ###   ###   ###   ###\n"
	.ascii	"    #?#   #?#   #?#   #?#   #?#\n"
	.asciz	"    ###   ###   ###   ###   ###\n\n"

inicializar_juego:
	ldx	#cabecera_juego
	jsr	print
	lda	#1	; Inicializamos el registro A a 1
	ldx	#columna_juego 	; Preparamos la columna en x para imprimirla posteriormente

; En este bucle imprimimos todas las columnas, que son equivalente al numero de intentos
bucle_columnas:
	cmpa	#num_intentos	; Comprobamos que el registro A sea menor o igual al numero de intentos
	bhi	jugar		; En caso de ser mayor o igual podemos iniciar el juego
	jsr	print		; Sacamos la columna por pantalla
	inca
	bra	bucle_columnas

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   Jugar                                                                        ;
;       Se encarga de realizar y llamar a todas las subrutinar                   ;
;       necesarias para ejecutar el juego                                        ;
;                                                                                ;
;   Entrada: Ninguna                                                             ;
;   Salida: Ninguna                                                              ;
;   Registros afectados: CC                                                      ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
jugar:
	jsr	colorcar_cursor	; Llamamos a la subrutina para colocar el cursor verticalmente
	jsr	pedir_palabra	; Llamamos a la subrutina para pedir la palabra

	ldx	#restore_cursor_position
	jsr	print

	; DEBUG ELIMINAR INICIO
	ldx	#cadena_palabras
	jsr	print
	; DEBUG ELIMINAR FIN

	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   colocar_cursor                                                               ;
;       Se encarga de color el cursor verticalmente dependiendo del intento      ;
;       en el que nos encontremos                                                ;
;                                                                                ;
;   Entrada: Ninguna                                                             ;
;   Salida: Ninguna                                                              ;
;   Registros afectados: CC                                                      ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
colorcar_cursor:
	pshu	a

	ldx	#save_cursor_position	; Guardamos la posicion inicial de cursor para recuperarla mas tarde.
	jsr	print

	lda	#num_intentos		; Cargamos en a el numero de intentos que tenemos

	ldx	#initial_up_offset	; Movemos el cursor el offset inicial, ya que no es del mismo numero de posiciones que para
					; avanzar de columna en columna
	jsr	print

bucle_cc:
	cmpa	#1
	bhi	mover_cursor_cc		; Si el registro A vale mas o lo mismo que 1 avanzamos el cursor
	bra	rts_cc

mover_cursor_cc:
	ldx	#cursor_up		; Aumentamos el cursor
	jsr	print
	deca				; Decrementamos el registro A para continuar con el bucle
	bra	bucle_cc

rts_cc:
	ldx	#cursor_right ; Por ultimo movemos el cursor una posicion a la derecha para iniciar la solicitud de la palabra
	jsr	print

	pulu	a
	rts


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   pedir_palabra                                                                ;
;       Se encarga de pedirle a un usuario la palabra a insertar, llamará        ;
;       a diferentes subrutinas para realizar las diferentes comprobaciones      ;
;                                                                                ;
;   Entrada: Ninguna                                                             ;
;   Salida: Ninguna                                                              ;
;   Registros afectados: CC                                                      ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pedir_palabra:
	pshu	d,x
	jsr	preparar_puntero_cadena
	ldb	#5	; Vamos a usar el registro B como contador para pedir un maximo de 5 letras

bucle_pp:
	tstb
	beq	rts_pp	; Comprobamos que el contador ha llegado a 0 para salir

	lda	0xFF02	; Pedimos el caracter
	jsr	comprobar_caracter_introducido

	tsta	; comprobamos que el caracter es incorrecto
	beq	bucle_pp

	decb	; Decrementamos el contaddor (registro B)
	bra	correcto_pp

correcto_pp:
	sta	,y+	; Almacenamos a en la posicion de memoria que apunta Y, y aumentamos y.
	bra	bucle_pp

rts_pp:
	pulu	d,x
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   comprobar_caracter_introducido                                               ;
;       Se encarga de comprobar el carcter escrito y llamar a la subrutina       ;
;       correspondiente dependiendo del caracter introducido                     ;
;                                                                                ;
;   Entrada: A-El caracter introducido                                           ;
;   Salida: A-El caracter en mayuscula si el caracter es valido, 0 si no lo es   ;
;   Registros afectados: A, CC                                                   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
comprobar_caracter_introducido:
	pshu	b,x

	cmpa	#65	; Comprobamos que es un caracter no valido (por debajo de A)
	blo	caracter_no_valido_cci

	cmpa	#90
	bls	caracter_valido_mayuscula_cci

	cmpa	#97
	blo	caracter_no_valido_cci

	cmpa	#122
	bls	caracter_valido_minuscula_cci

	bra	caracter_no_valido_cci

caracter_valido_mayuscula_cci:
	ldx	#cursor_right
	jsr	print

	bra	fin_cci

caracter_valido_minuscula_cci:
	suba	#32	; Le restamos a A 32 para pasarlo a mayuscula

	ldb	#8	; Retrocedemos una posicion
	stb	0xFF00

	sta	0xFF00	; Lo escribimos en mayusculas

	; Avanzamos el cursor
	; Se podria llamar a caracter valido mayuscula para que haga lo mismo sin necesidad de copiar codigo
	ldx	#cursor_right
	jsr	print

	bra	fin_cci

caracter_no_valido_cci:
	lda	#8	; Volvemos a la posicion anterior
	sta	0xFF00

	lda	#'?	; Sustituimos el caracter introducido por el usuario por la interrogacion
	sta	0xFF00

	lda	#8	; Volvemos a la posicion anterior para el proximo caracter a introducir del usuario
	sta	0xFF00

	clra
fin_cci:
	pulu	b,x
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   preparar_puntero_cadena                                                      ;
;       Preparamos el puntero de pila Y para que apunte a la direccion           ;
;       dentro de arreglo en la que queremos empezar a insertar la palabra       ;
;                                                                                ;
;   Entrada: Ninguna                                                             ;
;   Salida: Y-La direccion a partir de la cual empezar a insertar la palabra     ;
;   Registros afectados: Y, CC                                                   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
preparar_puntero_cadena:
	pshu	a
	ldy	#cadena_palabras

bucle_ppc:
	lda	,y+

	cmpa	#'?
	beq	fin_ppc

fin_ppc:
	lda	,-y

	pulu	a
	rts