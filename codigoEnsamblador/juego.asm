;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   MODULO: juego                                                                ;
;       Este modulo se va a encargar de realizar todas las operaciones           ;
;       relacionadas con el menu, desde su presentacion hasta saltos.            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.module juego

.globl	print
.globl	inicializar_juego
.globl	comprobar_palabra_existente

; Variables
num_intentos	.equ	6 ; Varibale de referencia que va a almacenar el numero de intentos
palabra_secreta:	.asciz	"MOSCA"	; Variable en la que guardar la palabra a adivinar

; Informacion necesaria para el colocamiento del cursor
initial_up_offset:	.asciz	"\033[3A"
cursor_up_una_posicion:	.asciz	"\033[1A"
cursor_up:	.asciz	"\033[4A"
cursor_right_sin_caracter:	.asciz	"\033[6C"
cursor_right:	.asciz	"\033[5C"
cursor_left:	.asciz	"\033[6D"
save_cursor_position:	.asciz	"\033[s"
restore_cursor_position:	.asciz	"\033[u"

; Arreglo en el que vamos a almacenar las palabras introducidas
; por lo tanto son 6 palabras por 5 letras cada una nos da un total
; de 30 letras a almacenar
cadena_palabras: 	.asciz	"??????????????????????????????"
colores_palabras:	.asciz	"??????????????????????????????"


cabecera_juego:
	.asciz	"\33[2J\33[H            W O R D L E\n\n"

fila_juego:
	.ascii	"    ###   ###   ###   ###   ###\n"
	.ascii	"    #?#   #?#   #?#   #?#   #?#\n"
	.asciz	"    ###   ###   ###   ###   ###\n\n"

inicializar_juego:
	ldx	#cabecera_juego
	jsr	print
	lda	#1	; Inicializamos el registro A a 1
	ldx	#fila_juego 	; Preparamos la columna en x para imprimirla posteriormente

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

	; TODO DEBUG ELIMINAR INICIO
	ldx	#cadena_palabras
	jsr	print

	ldb	#'\n
	stb	0xFF00

	ldx	#colores_palabras
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

rts_pp:
	pulu	d,x
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

	cmpb	#5	; Comprobamos que B es menor o igual q 0
	ble	bucle_comprobar_letras_dif_pos

	; En caso contrario preparamos para siguiente bucle (comprobar misma posicion)
	ldx	#palabra_secreta
	jsr	apuntar_ultima_palabra

	clrb

bucle_comprobar_letras_misma_pos:
	cmpb	#5
	beq	rts_cpi

	lda	,x+
	cmpa	,y+
	beq	poner_verde_cpi	; comprobamos que son iguales, si lo son ponemos el color a verde

	incb	; Aumentamos el contador del b (para saber la posicion en la que tenemos que establecer el color)

	; Comprobamos que A no vale ni ? ni \0
	; ya que en ese caso ya habriamos leido todos los caracteres
	cmpa	#'?
	bne	bucle_comprobar_letras_misma_pos

	cmpa	#'\0
	bne	bucle_comprobar_letras_misma_pos

	bra	rts_cpi

poner_rojo_cpi:
	lda	#2
	jsr	poner_color
	bra	bucle_comprobar_letras_dif_pos

poner_amarillo_cpi:
	lda	#1
	jsr	poner_color
	bra	bucle_comprobar_letras_dif_pos

poner_verde_cpi:
	lda	#0
	jsr	poner_color
	bra	bucle_comprobar_letras_misma_pos

rts_cpi:
	puls	x,y,a,b
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   apuntar_ultima_palabra                                                       ;
;       En esta subrutina se almacenara en Y la direccion de inicio a la ultima  ;
;       palabra introducida                                                      ;
;                                                                                ;
;   Entrada: B-Posicion a insertarlo                                             ;
;   Salida: Ninguna.                                                             ;
;   Registros afectados: CC                                                      ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
poner_color:
	pshu	y,a	; Usaremos Y para recorrer el vector donde almacenar los colores

	ldy	#colores_palabras

	lda	#6
	suba	#num_intentos	; Cargamos A con 6 y le restamos el intento actual (asi sabremos los caracteres que tenemos q avanzar)

	pshu	b

	ldb	#6		; Cargamos B con el numero de intentos totales
	mul			; Multiplicamos A por B asi tendremos las posicion a avanzar en D
	leay	b,y		; Avanzamos el puntero Y las posiciones calculadas

	pulu	b

	leay	b,y

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