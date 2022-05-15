;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   MODULO: juego                                                                ;
;       Este modulo se va a encargar de realizar todas las operaciones           ;
;       relacionadas con el menu, desde su presentacion hasta saltos.            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.module juego

.globl	print
.globl	inicializar_juego
.globl	comprobar_palabra_existente
.globl	pedir_confirmacion

; Variables
intentos_totales	.equ	6 ; Varibale de referencia que va a almacenar el numero de intentos
num_intentos:	.byte	6
palabra_secreta:	.asciz	"CISNE"	; Variable en la que guardar la palabra a adivinar

; Informacion necesaria para el colocamiento del cursor
initial_up_offset:	.asciz	"\033[3A"
cursor_up_una_posicion:	.asciz	"\033[1A"
cursor_up:	.asciz	"\033[4A"
cursor_right_sin_caracter:	.asciz	"\033[6C"
cursor_right:	.asciz	"\033[5C"
cursor_left:	.asciz	"\033[6D"
save_cursor_position:	.asciz	"\033[s"
restore_cursor_position:	.asciz	"\033[u"

; Informacion para los colores
color_rojo:	.asciz	"\33[31m"
color_verde:	.asciz	"\33[32m"
color_amarillo:	.asciz	"\33[33m"
color_blanco:	.asciz	"\33[37m"


; Arreglo en el que vamos a almacenar las palabras introducidas
; por lo tanto son 6 palabras por 5 letras cada una nos da un total
; de 30 letras a almacenar
cadena_palabras: 	.asciz	"??????????????????????????????"
colores_palabras:	.asciz	"222222222222222222222222222222"


cabecera_juego:
	.asciz	"\33[2J\33[H            W O R D L E\n\n"

fila_juego:
	.ascii	"    ###   ###   ###   ###   ###\n"
	.ascii	"    #?#   #?#   #?#   #?#   #?#\n"
	.asciz	"    ###   ###   ###   ###   ###\n\n"

mensaje_ganar:
	.asciz	"HAS ACERTADO LA PALABRA!!!!"

mensaje_perder:
	.asciz	"Se acabaron los intentos.\nLa palabra era: "

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   inicializar_juego                                                            ;
;       Se encarga de realizar y llamar a todas las subrutinar                   ;
;       necesarias para ejecutar el juego                                        ;
;                                                                                ;
;   Entrada: Ninguna                                                             ;
;   Salida: Ninguna                                                              ;
;   Registros afectados: CC                                                      ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
inicializar_juego:
	lda	#intentos_totales
	sta	num_intentos

	jsr	reset_variables

	ldx	#cabecera_juego
	jsr	print
	lda	#1	; Inicializamos el registro A a 1
	ldx	#fila_juego 	; Preparamos la columna en x para imprimirla posteriormente

; En este bucle imprimimos todas las columnas, que son equivalente al numero de intentos
bucle_columnas:
	cmpa	#intentos_totales	; Comprobamos que el registro A sea menor o igual al numero de intentos
	bhi	jugar		; En caso de ser mayor o igual podemos iniciar el juego
	jsr	print		; Sacamos la columna por pantalla
	inca
	bra	bucle_columnas

jugar:
	ldx	#save_cursor_position
	jsr	print

bucle_pedir_palabras_j:
	ldb	num_intentos
	jsr	colorcar_cursor	; Llamamos a la subrutina para colocar el cursor verticalmente
	jsr	pedir_palabra	; Llamamos a la subrutina para pedir la palabra

	; Comprobamos la salida del programa
	cmpa	#1
	beq	fin_bucle_pedir_palabras_ij

	cmpa	#2
	beq	inicializar_juego

	; Decrementamos el numero de intentos
	dec	num_intentos

	ldx	#restore_cursor_position
	jsr	print

	jsr	imprimir_palabras_intentadas

	jsr	check_victoria

	tsta
	bne	ganador_ij	; Si ha no vale 0 esq hemos ganado

	ldx	#restore_cursor_position
	jsr	print

	ldb	num_intentos
	cmpb	#0
	bne	bucle_pedir_palabras_j

	bra	perdedor_ij:

ganador_ij:
	ldx	#mensaje_ganar
	jsr	print
	jsr	pedir_confirmacion

	bra	fin_bucle_pedir_palabras_ij

perdedor_ij:
	ldx	#mensaje_perder
	jsr	print

	ldx	#palabra_secreta
	jsr	print

	jsr	pedir_confirmacion

	bra	fin_bucle_pedir_palabras_ij

fin_bucle_pedir_palabras_ij:
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   reset_variables                                                              ;
;       Se encarga de reinicar el valor de las variables cadena palabra          ;
;       y colores palabras                                                       ;
;                                                                                ;
;   Entrada: Ninguna                                                             ;
;   Salida: Las variables se resetearan al valor original                        ;
;   Registros afectados: CC                                                      ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
reset_variables:
	pshu	a,b,y,x

	ldy	#cadena_palabras
	ldx	#colores_palabras

	lda	#'?

bucle_palabras_rv:
	sta	,y+
	ldb	,y

	cmpb	#'\0
	bne	bucle_palabras_rv

	lda	#'2
bucle_colores_rv:
	sta	,x+
	ldb	,x

	cmpb	#'\0
	bne	bucle_colores_rv

fin_rv:
	pulu	a,b,y,x
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   colocar_cursor                                                               ;
;       Se encarga de color el cursor verticalmente dependiendo del intento      ;
;       en el que nos encontremos                                                ;
;                                                                                ;
;   Entrada: B-La fila a posicionarse                                            ;
;   Salida: Ninguna                                                              ;
;   Registros afectados: CC                                                      ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
colorcar_cursor:
	pshu	a,x,b

	tfr	b,a

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

	pulu	a,x,b
	rts


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   pedir_palabra                                                                ;
;       Se encarga de pedirle a un usuario la palabra a insertar, llamará        ;
;       a diferentes subrutinas para realizar las diferentes comprobaciones      ;
;                                                                                ;
;   Entrada: Ninguna                                                             ;
;   Salida: A-(1 Si se sale al menu, 2 Si se reiniciar el juego, 0 salida normal);
;   Registros afectados: CC                                                      ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pedir_palabra:
	pshu	b,x
	jsr	preparar_puntero_cadena
	ldb	#6	; Vamos a usar el registro B como contador para pedir un maximo de 6 caracteres
			; Pedimos 6 carecteres ya que necesitamos las 5 letras de la palabra
			; Y el ultimo caracter de control, confirmar, borrar, etc.

bucle_pp:
	tstb
	beq	rts_pp	; Comprobamos que el contador ha llegado a 0 para salir

	lda	0xFF02	; Pedimos el caracter
	jsr	comprobar_caracter_introducido

	tsta	; comprobamos que el caracter es incorrecto
	beq	bucle_pp

	cmpa	#1
	beq	reiniciar_juego_pp

	cmpa	#2
	beq	volver_menu_pp

	cmpa	#3
	beq	eliminar_caracter_puntero_pp

	cmpa	#4
	beq	iniciar_comprobaciones_pp

	decb	; Decrementamos el contador (registro B)
	bra	correcto_pp

iniciar_comprobaciones_pp:
	tfr	y,x
	leax	-5,x

	jsr	comprobar_palabra_existente

	tsta
	beq	palabra_no_valida_pp
	bra	palabra_valida_pp

palabra_no_valida_pp:
	jsr	colocar_cursor_en_fila
	bra	bucle_pp

palabra_valida_pp:
	jsr	comprobar_palabra_introducida
	clra
	bra	rts_pp

correcto_pp:
	sta	,y+	; Almacenamos a en la posicion de memoria que apunta Y, y aumentamos y.
	bra	bucle_pp

; Si se ha eliminado un caracter tenemos que eliminarlo tmb del puntero
eliminar_caracter_puntero_pp:
	lda	#'?
	sta	,-y

	incb	; Incrementamos el contador ya que hemos eliminado un caracter

	bra	bucle_pp


volver_menu_pp:
	lda	#1
	bra	rts_pp

reiniciar_juego_pp:
	lda	#2

rts_pp:
	pulu	b,x
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   comprobar_caracter_introducido                                               ;
;       Se encarga de comprobar el carcter escrito y llamar a la subrutina       ;
;       correspondiente dependiendo del caracter introducido                     ;
;                                                                                ;
;   Entrada: A-El caracter introducido, B-El numero del caracter introducido     ;
;   Salida: A-El caracter en mayuscula si el caracter es valido, 0 si no lo es,  ;
;           1 si se ha pulsado la 'v' para volver al menu, '2' si se ha pulsado  ;
;           la 'r' para reiniciar la partida, '3' si se ha eliminado un caracter ;
;           o 4 si se ha pulsado enter y era la ultima posicion, para comprobar  ;
;           la palabra                                                           ;
;                                                                                ;
;   Registros afectados: A, CC                                                   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
comprobar_caracter_introducido:
	pshu	b,x

	cmpa	#65	; Comprobamos que es un caracter no valido (por debajo de A)
	lblo	caracter_no_valido_cci

	cmpa	#90
	lbls	caracter_valido_mayuscula_cci

	cmpa	#97
	lblo	caracter_no_valido_cci

	cmpa	#122
	lbls	caracter_valido_minuscula_cci

	lbra	caracter_no_valido_cci

caracter_valido_mayuscula_cci:
	cmpb	#1
	beq	caracter_no_valido_cci

	ldx	#cursor_right
	jsr	print

	lbra	fin_cci

caracter_valido_minuscula_cci:
	cmpa	#'r
	beq	prep_salir_menu_cci

	cmpa	#'v
	beq	prep_reiniciar_cci

	cmpb	#1
	beq	caracter_no_valido_cci

	suba	#32	; Le restamos a A 32 para pasarlo a mayuscula

	ldb	#8	; Retrocedemos una posicion
	stb	0xFF00

	sta	0xFF00	; Lo escribimos en mayusculas

	; Avanzamos el cursor
	; Se podria llamar a caracter valido mayuscula para que haga lo mismo sin necesidad de copiar codigo
	ldx	#cursor_right
	jsr	print

	lbra	fin_cci

prep_salir_menu_cci:
	lda	#1
	bra	fin_cci

prep_reiniciar_cci:
	lda	#2
	bra	fin_cci

caracter_no_valido_cci:
	cmpa	#10
	beq	tecla_enter_pulsada

	pshu	b

	ldb	#8	; Volvemos a la posicion anterior
	stb	0xFF00

	ldb	#'?	; Sustituimos el caracter introducido por el usuario por la interrogacion
	stb	0xFF00

	ldb	#8	; Volvemos a la posicion anterior para el proximo caracter a introducir del usuario
	stb	0xFF00

	pulu	b

	cmpa	#32
	beq	borrar_caracter_cci

	clra

	bra	fin_cci

borrar_caracter_cci:
	cmpb	#6
	bne	cursor_izquierda_cci	; Si no es el primer caracter movemos el cursor a la izquierda

	ldb	#'?
	stb	0xFF00

	ldb	#8
	stb	0xFF00

	clra

	bra	fin_cci

cursor_izquierda_cci:
	ldx	#cursor_left
	jsr	print

	ldb	#'?
	stb	0xFF00

	ldb	#8
	stb	0xFF00

	lda	#3

	bra	fin_cci

tecla_enter_pulsada:
	cmpb	#1
	beq	guardar_palabra

	jsr	colocar_cursor_en_fila

	clra

	bra	fin_cci
guardar_palabra:
	lda	#4
	bra	fin_cci

fin_cci:
	pulu	b,x
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   colocar_cursor_en_pila                                                       ;
;       Subrutina que nos coloca el puntero en fila dependiendo de los caracteres;
;       ya introduccidos                                                         ;
;                                                                                ;
;   Entrada: B-El numero del caracter que estamos introduciendo                  ;
;   Salida: Ninguna                                                              ;
;   Registros afectados: CC                                                      ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
colocar_cursor_en_fila:
	pshu	a,b,x

	tfr	b,a	; A tiene la posicion actual del caracter introducido

	ldx	#cursor_up_una_posicion	; Movemos el cursor la posicion superior que ha bajado el enter
	jsr	print

	ldb	#8	; Retrocedemos una posicion para eliminar el caracter escrito
	stb	0xFF00

	ldx	#cursor_right	; Movemos el cursor 5 caracteres a la derecha
	jsr	print

	ldx	#cursor_right_sin_caracter	; Cargamos x para mover el caracter 6 caracteres a la derecha
bucle_ccef:
	cmpa	#6	; mientras a sea diferente de 6 ejecutamos
	beq	fin_ccef

	jsr	print	; movemos el cursor

	inca

	bra	bucle_ccef

fin_ccef:
	pulu	a,b,x
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

	cmpa	#'\0
	beq	fin_ppc

	bra	bucle_ppc

fin_ppc:
	leay	-1,y

	pulu	a
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   comprobar_palabra_introducida                                                ;
;       En esta subrutina se comprobara la palabra introducida con la palabra    ;
;       secreta, sacar los colores y comprobar que se ha acertado o no.          ;
;                                                                                ;
;   Entrada: Ninguna                                                             ;
;   Salida: Ninguna                                                              ;
;   Registros afectados: CC                                                      ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
comprobar_palabra_introducida:
	pshs	x,y,a,b

	clrb	; Hacemos q b sea 0 ya que lo usaremos de contador
	ldx	#palabra_secreta
	jsr	apuntar_ultima_palabra

bucle_comprobar_letras_dif_pos:
	lda	,x+
	cmpa	,y	; Vamos comparando el caracter de nuestra palabra con el de la palabra secreta
	beq	poner_amarillo_cpi	; En el caso de ser iguales los ponemos a amarillo

	cmpa	#'\0	; Comprobamos que haya llegado al final de la palabra
	bne	bucle_comprobar_letras_dif_pos

	; Incrementamos B
	incb
	leay	1,y

	ldx	#palabra_secreta

	cmpb	#5	; Comprobamos que B es menor o igual q 0
	blo	bucle_comprobar_letras_dif_pos

	; En caso contrario preparamos para siguiente bucle (comprobar misma posicion)
	ldx	#palabra_secreta
	jsr	apuntar_ultima_palabra

	ldb	#-1

bucle_comprobar_letras_misma_pos:
	incb
	lda	,x+

	; Comprobamos que A no vale ni ? ni \0
	; ya que en ese caso ya habriamos leido todos los caracteres
	cmpa	#'?
	beq	rts_cpi

	cmpa	#'\0
	beq	rts_cpi

	cmpa	,y+
	beq	poner_verde_cpi	; comprobamos que son iguales, si lo son ponemos el color a verde

	bra	bucle_comprobar_letras_misma_pos

poner_amarillo_cpi:
	lda	#'1
	jsr	poner_color
	bra	bucle_comprobar_letras_dif_pos

poner_verde_cpi:
	lda	#'0
	jsr	poner_color
	bra	bucle_comprobar_letras_misma_pos

rts_cpi:
	puls	x,y,a,b
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   poner_color                                                                  ;
;       En esta subrutina pondra el color indicado en A en la posicion del       ;
;       arreglo                                                                  ;
;                                                                                ;
;   Entrada: A-color codificado, B-Posicion a insertarlo                         ;
;   Salida: Ninguna.                                                             ;
;   Registros afectados: CC                                                      ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
poner_color:
	pshu	y,a	; Usaremos Y para recorrer el vector donde almacenar los colores

	ldy	#colores_palabras

	pshu	a

	lda	#intentos_totales
	suba	num_intentos	; Cargamos A con 6 y le restamos el intento actual (asi sabremos los caracteres que tenemos q avanzar)

	pshu	b

	ldb	#intentos_totales	; Cargamos B con el numero de intentos totales
	mul			; Multiplicamos A por B asi tendremos las posicion a avanzar en D

	leay	b,y		; Avanzamos el puntero Y las posiciones calculadas

	; Las palabras al ser de tamaño 5 e ir de 0-5 | 5 - 10 etc necesitamos decrementar el numero de intentos que llevamos al puntero
	; ya que la multiplicacion ira tal que 0-6 | 0-12 | etc.
	ldb	num_intentos
	subb	#intentos_totales

	leay	b,y

	pulu	b

	leay	b,y

	pulu	a

	sta	,y	; Almacenamos en la posicion de la letra el color verde, ya que b lleva la posicion de la letra

	pulu	y,a

	rts


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   apuntar_ultima_palabra                                                       ;
;       En esta subrutina se almacenara en Y la direccion de inicio a la ultima  ;
;       palabra introducida                                                      ;
;                                                                                ;
;   Entrada: Ninguna                                                             ;
;   Salida: Y apuntara a la ultima palabra introducida                           ;
;   Registros afectados: CC                                                      ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
apuntar_ultima_palabra:
	jsr	preparar_puntero_cadena	; Preparamos el puntero para que apunte a caracter a continuacion de la palabra a tomar
	leay	-5,y			; Apuntamos al inicio de la nueva palabra

	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   imprimir_palabras_intentadas                                                 ;
;       En esta subrutina se encargara de mostrar las palabras intentadas con sus;
;       respectivos colores                                                      ;
;                                                                                ;
;   Entrada: Ninguna                                                             ;
;   Salida: Ninguna                                                              ;
;   Registros afectados: CC                                                      ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
imprimir_palabras_intentadas:
	ldb	#intentos_totales
	ldx	#cadena_palabras
	ldy	#colores_palabras

bucle_colocar_cursor_fila_ipi:
	cmpb	num_intentos
	beq	rts_ipi

	jsr	colorcar_cursor
	clra

	pshu	b
bucle_imprimir_palabra_ipi:
	ldb	,y+

	; Dependiendo del valor imprimimos uno u otro valor
	cmpb	#'0
	beq	imprimir_verde_ipi

	cmpb	#'1
	beq	imprimir_amarillo_ipi

	cmpb	#'2
	beq	imprimir_rojo_ipi

continuar_flujo_bucle_imprimir_ipi:
	ldb	,x+
	stb	0xFF00

comprobaciones_salir_bucle_ipi:
	cmpa	#4
	beq	salir_bucle_imprimir_letra_ipi	; comprobamos que no hayamos recorrido ya las 5 letras

	pshu	x
	ldx	#cursor_right	; movemos el cursor a la derecha
	jsr	print
	pulu	x

	inca	; Incrementamos A

	bra	bucle_imprimir_palabra_ipi

salir_bucle_imprimir_letra_ipi:
	pshu	x
	ldx	#restore_cursor_position
	jsr	print
	pulu	x

	pulu	b

	decb	; Decremenamos B
	bra	bucle_colocar_cursor_fila_ipi	; Volvemos al bucle

imprimir_verde_ipi:
	pshu	x
	ldx	#color_verde
	jsr	print
	pulu	x
	bra	continuar_flujo_bucle_imprimir_ipi

imprimir_amarillo_ipi:
	pshu	x
	ldx	#color_amarillo
	jsr	print
	pulu	x
	bra	continuar_flujo_bucle_imprimir_ipi

imprimir_rojo_ipi:
	pshu	x
	ldx	#color_rojo
	jsr	print
	pulu	x
	bra	continuar_flujo_bucle_imprimir_ipi

imprimir_blanco_ipi:
	pshu	x
	ldx	#color_blanco
	jsr	print
	pulu	x
	bra	comprobaciones_salir_bucle_ipi

rts_ipi:
	rts


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   check_victoria                                                               ;
;       En esta subrutina comprobaremos que se ha adivinado la palabra           ;
;                                                                                ;
;   Entrada: Ninguna                                                             ;
;   Salida: A(0-Si no se ha ganado, 1-si se ha ganado)                           ;
;   Registros afectados: CC                                                      ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
check_victoria:
	pshu	b,y

	ldy	#colores_palabras	; Cargamos en Y el puntero a los colores
	ldb	num_intentos		; Cargamos el intento actual

	incb

preparar_puntero_cv:
	cmpb	#intentos_totales
	beq	cont_cv

	leay	5,y
	incb
	bra	preparar_puntero_cv

cont_cv:
	clrb

; Recorremos la cadena hasta que la terminemos o lleguemos a un numero diferente de 0
; Si se sale porque ha encontrado un numero distinto de 0 no hemos ganado.
; En caso contrario hemos ganado.
bucle_comprobar_victoria_cv:
	cmpb	#4
	beq	fin_si_gana_cv

	lda	,y+
	incb
	cmpa	#'0
	beq	bucle_comprobar_victoria_cv

	bra	fin_no_gana_cv

fin_si_gana_cv:
	lda	#1
	bra	fin_cv

fin_no_gana_cv:
	clra

fin_cv:
	pulu	b,y
	rts