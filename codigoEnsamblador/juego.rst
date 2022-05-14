ASxxxx Assembler V05.00  (Motorola 6809), page 1.
Hexidecimal [16-Bits]



                              1 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                              2 ;   MODULO: juego                                                                ;
                              3 ;       Este modulo se va a encargar de realizar todas las operaciones           ;
                              4 ;       relacionadas con el menu, desde su presentacion hasta saltos.            ;
                              5 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                              6 
                              7 .module juego
                              8 
                              9 .globl	print
                             10 .globl	inicializar_juego
                             11 .globl	comprobar_palabra_existente
                             12 
                             13 ; Variables
                     0006    14 num_intentos	.equ	6 ; Varibale de referencia que va a almacenar el numero de intentos
   04D8 4D 4F 53 43 41 00    15 palabra_secreta:	.asciz "MOSCA"	; Variable en la que guardar la palabra a adivinar
                             16 
                             17 ; Informacion necesaria para el colocamiento del cursor
   04DE 1B 5B 33 41 00       18 initial_up_offset:	.asciz	"\033[3A"
   04E3 1B 5B 31 41 00       19 cursor_up_una_posicion:	.asciz	"\033[1A"
   04E8 1B 5B 34 41 00       20 cursor_up:	.asciz	"\033[4A"
   04ED 1B 5B 36 43 00       21 cursor_right_sin_caracter:	.asciz	"\033[6C"
   04F2 1B 5B 35 43 00       22 cursor_right:	.asciz	"\033[5C"
   04F7 1B 5B 36 44 00       23 cursor_left:	.asciz	"\033[6D"
   04FC 1B 5B 73 00          24 save_cursor_position:	.asciz	"\033[s"
   0500 1B 5B 75 00          25 restore_cursor_position:	.asciz	"\033[u"
                             26 
                             27 ; Arreglo en el que vamos a almacenar las palabras introducidas
                             28 ; por lo tanto son 6 palabras por 5 letras cada una nos da un total
                             29 ; de 30 letras a almacenar
   0504 3F 3F 3F 3F 3F 3F    30 cadena_palabras: 	.asciz	"??????????????????????????????"
        3F 3F 3F 3F 3F 3F
        3F 3F 3F 3F 3F 3F
        3F 3F 3F 3F 3F 3F
        3F 3F 3F 3F 3F 3F
        00
   0523 3F 3F 3F 3F 3F 3F    31 colores_palabras:	.asciz	"??????????????????????????????"
        3F 3F 3F 3F 3F 3F
        3F 3F 3F 3F 3F 3F
        3F 3F 3F 3F 3F 3F
        3F 3F 3F 3F 3F 3F
        00
                             32 
                             33 
   0542                      34 cabecera_juego:
   0542 1B 5B 32 4A 1B 5B    35 	.asciz	"\33[2J\33[H            W O R D L E\n\n"
        48 20 20 20 20 20
        20 20 20 20 20 20
        20 57 20 4F 20 52
        20 44 20 4C 20 45
        0A 0A 00
                             36 
   0563                      37 fila_juego:
   0563 20 20 20 20 23 23    38 	.ascii	"    ###   ###   ###   ###   ###\n"
        23 20 20 20 23 23
        23 20 20 20 23 23
ASxxxx Assembler V05.00  (Motorola 6809), page 2.
Hexidecimal [16-Bits]



        23 20 20 20 23 23
        23 20 20 20 23 23
        23 0A
   0583 20 20 20 20 23 3F    39 	.ascii	"    #?#   #?#   #?#   #?#   #?#\n"
        23 20 20 20 23 3F
        23 20 20 20 23 3F
        23 20 20 20 23 3F
        23 20 20 20 23 3F
        23 0A
   05A3 20 20 20 20 23 23    40 	.asciz	"    ###   ###   ###   ###   ###\n\n"
        23 20 20 20 23 23
        23 20 20 20 23 23
        23 20 20 20 23 23
        23 20 20 20 23 23
        23 0A 0A 00
                             41 
   05C5                      42 inicializar_juego:
   05C5 8E 05 42      [ 3]   43 	ldx	#cabecera_juego
   05C8 BD 09 75      [ 8]   44 	jsr	print
   05CB 86 01         [ 2]   45 	lda	#1	; Inicializamos el registro A a 1
   05CD 8E 05 63      [ 3]   46 	ldx	#fila_juego 	; Preparamos la columna en x para imprimirla posteriormente
                             47 
                             48 ; En este bucle imprimimos todas las columnas, que son equivalente al numero de intentos
   05D0                      49 bucle_columnas:
   05D0 81 06         [ 2]   50 	cmpa	#num_intentos	; Comprobamos que el registro A sea menor o igual al numero de intentos
   05D2 22 06         [ 3]   51 	bhi	jugar		; En caso de ser mayor o igual podemos iniciar el juego
   05D4 BD 09 75      [ 8]   52 	jsr	print		; Sacamos la columna por pantalla
   05D7 4C            [ 2]   53 	inca
   05D8 20 F6         [ 3]   54 	bra	bucle_columnas
                             55 
                             56 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                             57 ;   Jugar                                                                        ;
                             58 ;       Se encarga de realizar y llamar a todas las subrutinar                   ;
                             59 ;       necesarias para ejecutar el juego                                        ;
                             60 ;                                                                                ;
                             61 ;   Entrada: Ninguna                                                             ;
                             62 ;   Salida: Ninguna                                                              ;
                             63 ;   Registros afectados: CC                                                      ;
                             64 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   05DA                      65 jugar:
   05DA BD 05 F8      [ 8]   66 	jsr	colorcar_cursor	; Llamamos a la subrutina para colocar el cursor verticalmente
   05DD BD 06 20      [ 8]   67 	jsr	pedir_palabra	; Llamamos a la subrutina para pedir la palabra
                             68 
   05E0 8E 05 00      [ 3]   69 	ldx	#restore_cursor_position
   05E3 BD 09 75      [ 8]   70 	jsr	print
                             71 
                             72 	; DEBUG ELIMINAR INICIO
   05E6 8E 05 04      [ 3]   73 	ldx	#cadena_palabras
   05E9 BD 09 75      [ 8]   74 	jsr	print
                             75 
   05EC C6 0A F7      [ 3]   76 	ldx	#colores_palabras
                             77 	; DEBUG ELIMINAR FIN
                             78 
   05EF FF            [ 5]   79 	rts
                             80 
ASxxxx Assembler V05.00  (Motorola 6809), page 3.
Hexidecimal [16-Bits]



                             81 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                             82 ;   colocar_cursor                                                               ;
                             83 ;       Se encarga de color el cursor verticalmente dependiendo del intento      ;
                             84 ;       en el que nos encontremos                                                ;
                             85 ;                                                                                ;
                             86 ;   Entrada: Ninguna                                                             ;
                             87 ;   Salida: Ninguna                                                              ;
                             88 ;   Registros afectados: CC                                                      ;
                             89 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   0118                      90 colorcar_cursor:
   05F0 00 8E         [ 6]   91 	pshu	a
                             92 
   05F2 05 23 BD      [ 3]   93 	ldx	#save_cursor_position	; Guardamos la posicion inicial de cursor para recuperarla mas tarde.
   05F5 09 75 39      [ 8]   94 	jsr	print
                             95 
   05F8 86 06         [ 2]   96 	lda	#num_intentos		; Cargamos en a el numero de intentos que tenemos
                             97 
   05F8 36 02 8E      [ 3]   98 	ldx	#initial_up_offset	; Movemos el cursor el offset inicial, ya que no es del mismo numero de posiciones que para
                             99 					; avanzar de columna en columna
   05FB 04 FC BD      [ 8]  100 	jsr	print
                            101 
   0128                     102 bucle_cc:
   05FE 09 75         [ 2]  103 	cmpa	#1
   0600 86 06         [ 3]  104 	bhi	mover_cursor_cc		; Si el registro A vale mas o lo mismo que 1 avanzamos el cursor
   0602 8E 04         [ 3]  105 	bra	rts_cc
                            106 
   012E                     107 mover_cursor_cc:
   0604 DE BD 09      [ 3]  108 	ldx	#cursor_up		; Aumentamos el cursor
   0607 75 00 00      [ 8]  109 	jsr	print
   0608 4A            [ 2]  110 	deca				; Decrementamos el registro A para continuar con el bucle
   0608 81 01         [ 3]  111 	bra	bucle_cc
                            112 
   0137                     113 rts_cc:
   060A 22 02 20      [ 3]  114 	ldx	#cursor_right ; Por ultimo movemos el cursor una posicion a la derecha para iniciar la solicitud de la palabra
   060D 09 00 00      [ 8]  115 	jsr	print
                            116 
   060E 37 02         [ 6]  117 	pulu	a
   060E 8E            [ 5]  118 	rts
                            119 
                            120 
                            121 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                            122 ;   pedir_palabra                                                                ;
                            123 ;       Se encarga de pedirle a un usuario la palabra a insertar, llamará        ;
                            124 ;       a diferentes subrutinas para realizar las diferentes comprobaciones      ;
                            125 ;                                                                                ;
                            126 ;   Entrada: Ninguna                                                             ;
                            127 ;   Salida: Ninguna                                                              ;
                            128 ;   Registros afectados: CC                                                      ;
                            129 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   0140                     130 pedir_palabra:
   060F 04 E8         [ 8]  131 	pshu	d,x
   0611 BD 09 75      [ 8]  132 	jsr	preparar_puntero_cadena
   0614 4A 20         [ 2]  133 	ldb	#6	; Vamos a usar el registro B como contador para pedir un maximo de 6 caracteres
                            134 			; Pedimos 6 carecteres ya que necesitamos las 5 letras de la palabra
                            135 			; Y el ultimo caracter de control, confirmar, borrar, etc.
ASxxxx Assembler V05.00  (Motorola 6809), page 4.
Hexidecimal [16-Bits]



                            136 
   0147                     137 bucle_pp:
   0616 F1            [ 2]  138 	tstb
   0617 27 35         [ 3]  139 	beq	rts_pp	; Comprobamos que el contador ha llegado a 0 para salir
                            140 
   0617 8E 04 F2      [ 5]  141 	lda	0xFF02	; Pedimos el caracter
   061A BD 09 75      [ 8]  142 	jsr	comprobar_caracter_introducido
                            143 
   061D 37            [ 2]  144 	tsta	; comprobamos que el caracter es incorrecto
   061E 02 39         [ 3]  145 	beq	bucle_pp
                            146 
   0620 81 03         [ 2]  147 	cmpa	#3
   0620 36 16         [ 3]  148 	beq	eliminar_caracter_puntero_pp
                            149 
   0622 BD 07         [ 2]  150 	cmpa	#4
   0624 2C C6         [ 3]  151 	beq	iniciar_comprobaciones_pp
                            152 
   0626 06            [ 2]  153 	decb	; Decrementamos el contador (registro B)
   0627 20 16         [ 3]  154 	bra	correcto_pp
                            155 
   015E                     156 iniciar_comprobaciones_pp:
   0627 5D 27         [ 6]  157 	tfr	y,x
   0629 35 B6         [ 5]  158 	leax	-5,x
                            159 
   062B FF 02 BD      [ 8]  160 	jsr	comprobar_palabra_existente
                            161 
   062E 06            [ 2]  162 	tsta
   062F 62 4D         [ 3]  163 	beq	palabra_no_valida_pp
   0631 27 F4         [ 3]  164 	bra	palabra_valida_pp
                            165 
   016A                     166 palabra_no_valida_pp:
   0633 81 03 27      [ 8]  167 	jsr	colocar_cursor_en_fila
   0636 21 81         [ 3]  168 	bra	bucle_pp
                            169 
   016F                     170 palabra_valida_pp:
   0638 04 27 03      [ 8]  171 	jsr	comprobar_palabra_introducida
   063B 5A 20         [ 3]  172 	bra	rts_pp
                            173 
   0174                     174 correcto_pp:
   063D 16 A0         [ 6]  175 	sta	,y+	; Almacenamos a en la posicion de memoria que apunta Y, y aumentamos y.
   063E 20 CF         [ 3]  176 	bra	bucle_pp
                            177 
                            178 ; Si se ha eliminado un caracter tenemos que eliminarlo tmb del puntero
   0178                     179 eliminar_caracter_puntero_pp:
   063E 1F 21         [ 2]  180 	lda	#'?
   0640 30 1B         [ 6]  181 	sta	,-y
                            182 
   0642 BD            [ 2]  183 	incb	; Incrementamos el contador ya que hemos eliminado un caracter
                            184 
   0643 09 A4         [ 3]  185 	bra	bucle_pp
                            186 
   017F                     187 rts_pp:
   0645 4D 27         [ 8]  188 	pulu	d,x
   0647 02            [ 5]  189 	rts
                            190 
ASxxxx Assembler V05.00  (Motorola 6809), page 5.
Hexidecimal [16-Bits]



                            191 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                            192 ;   comprobar_caracter_introducido                                               ;
                            193 ;       Se encarga de comprobar el carcter escrito y llamar a la subrutina       ;
                            194 ;       correspondiente dependiendo del caracter introducido                     ;
                            195 ;                                                                                ;
                            196 ;   Entrada: A-El caracter introducido, B-El numero del caracter introducido     ;
                            197 ;   Salida: A-El caracter en mayuscula si el caracter es valido, 0 si no lo es,  ;
                            198 ;           1 si se ha pulsado la 'v' para volver al menu, '2' si se ha pulsado  ;
                            199 ;           la 'r' para reiniciar la partida, '3' si se ha eliminado un caracter ;
                            200 ;           o 4 si se ha pulsado enter y era la ultima posicion, para comprobar  ;
                            201 ;           la palabra                                                           ;
                            202 ;                                                                                ;
                            203 ;   Registros afectados: A, CC                                                   ;
                            204 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   0182                     205 comprobar_caracter_introducido:
   0648 20 05         [ 7]  206 	pshu	b,x
                            207 
   064A 81 41         [ 2]  208 	cmpa	#65	; Comprobamos que es un caracter no valido (por debajo de A)
   064A BD 07 07 20   [ 6]  209 	lblo	caracter_no_valido_cci
                            210 
   064E D8 5A         [ 2]  211 	cmpa	#90
   064F 10 23 00 0F   [ 6]  212 	lbls	caracter_valido_mayuscula_cci
                            213 
   064F BD 07         [ 2]  214 	cmpa	#97
   0651 43 20 0B 3D   [ 6]  215 	lblo	caracter_no_valido_cci
                            216 
   0654 81 7A         [ 2]  217 	cmpa	#122
   0654 A7 A0 20 CF   [ 6]  218 	lbls	caracter_valido_minuscula_cci
                            219 
   0658 16 00 34      [ 5]  220 	lbra	caracter_no_valido_cci
                            221 
   019F                     222 caracter_valido_mayuscula_cci:
   0658 86 3F         [ 2]  223 	cmpb	#1
   065A A7 A2         [ 3]  224 	beq	caracter_no_valido_cci
                            225 
   065C 5C 20 C8      [ 3]  226 	ldx	#cursor_right
   065F BD 00 00      [ 8]  227 	jsr	print
                            228 
   065F 37 16 39      [ 5]  229 	lbra	fin_cci
                            230 
   0662                     231 caracter_valido_minuscula_cci:
   0662 36 14         [ 2]  232 	cmpa	#'r
   0664 81 41         [ 3]  233 	beq	prep_salir_menu_cci
                            234 
   0666 10 25         [ 2]  235 	cmpa	#'v
   0668 00 49         [ 3]  236 	beq	prep_reiniciar_cci
                            237 
   066A 81 5A         [ 2]  238 	cmpb	#1
   066C 10 23         [ 3]  239 	beq	caracter_no_valido_cci
                            240 
   066E 00 0F         [ 2]  241 	suba	#32	; Le restamos a A 32 para pasarlo a mayuscula
                            242 
   0670 81 61         [ 2]  243 	ldb	#8	; Retrocedemos una posicion
   0672 10 25 00      [ 5]  244 	stb	0xFF00
                            245 
ASxxxx Assembler V05.00  (Motorola 6809), page 6.
Hexidecimal [16-Bits]



   0675 3D 81 7A      [ 5]  246 	sta	0xFF00	; Lo escribimos en mayusculas
                            247 
                            248 	; Avanzamos el cursor
                            249 	; Se podria llamar a caracter valido mayuscula para que haga lo mismo sin necesidad de copiar codigo
   0678 10 23 00      [ 3]  250 	ldx	#cursor_right
   067B 10 16 00      [ 8]  251 	jsr	print
                            252 
   067E 34 00 59      [ 5]  253 	lbra	fin_cci
                            254 
   067F                     255 prep_salir_menu_cci:
   067F C1 01         [ 2]  256 	lda	#1
   0681 27 30         [ 3]  257 	bra	fin_cci
                            258 
   01CF                     259 prep_reiniciar_cci:
   0683 8E 04         [ 2]  260 	lda	#2
   0685 F2 BD         [ 3]  261 	bra	fin_cci
                            262 
   01D3                     263 caracter_no_valido_cci:
   0687 09 75         [ 2]  264 	cmpa	#10
   0689 16 00         [ 3]  265 	beq	tecla_enter_pulsada
                            266 
   068B 78 04         [ 6]  267 	pshu	b
                            268 
   068C C6 08         [ 2]  269 	ldb	#8	; Volvemos a la posicion anterior
   068C 81 72 27      [ 5]  270 	stb	0xFF00
                            271 
   068F 1B 81         [ 2]  272 	ldb	#'?	; Sustituimos el caracter introducido por el usuario por la interrogacion
   0691 76 27 1B      [ 5]  273 	stb	0xFF00
                            274 
   0694 C1 01         [ 2]  275 	ldb	#8	; Volvemos a la posicion anterior para el proximo caracter a introducir del usuario
   0696 27 1B 80      [ 5]  276 	stb	0xFF00
                            277 
   0699 20 C6         [ 6]  278 	pulu	b
                            279 
   069B 08 F7         [ 2]  280 	cmpa	#32
   069D FF 00         [ 3]  281 	beq	borrar_caracter_cci
                            282 
   069F B7            [ 2]  283 	clra
                            284 
   06A0 FF 00         [ 3]  285 	bra	fin_cci
                            286 
   01F1                     287 borrar_caracter_cci:
   06A2 8E 04         [ 2]  288 	cmpb	#6
   06A4 F2 BD         [ 3]  289 	bne	cursor_izquierda_cci	; Si no es el primer caracter movemos el cursor a la izquierda
                            290 
   06A6 09 75         [ 2]  291 	ldb	#'?
   06A8 16 00 59      [ 5]  292 	stb	0xFF00
                            293 
   06AB C6 08         [ 2]  294 	ldb	#8
   06AB 86 01 20      [ 5]  295 	stb	0xFF00
                            296 
   06AE 55            [ 2]  297 	clra
                            298 
   06AF 20 22         [ 3]  299 	bra	fin_cci
                            300 
ASxxxx Assembler V05.00  (Motorola 6809), page 7.
Hexidecimal [16-Bits]



   0202                     301 cursor_izquierda_cci:
   06AF 86 02 20      [ 3]  302 	ldx	#cursor_left
   06B2 51 00 00      [ 8]  303 	jsr	print
                            304 
   06B3 C6 3F         [ 2]  305 	ldb	#'?
   06B3 81 0A 27      [ 5]  306 	stb	0xFF00
                            307 
   06B6 3F 36         [ 2]  308 	ldb	#8
   06B8 04 C6 08      [ 5]  309 	stb	0xFF00
                            310 
   06BB F7 FF         [ 2]  311 	lda	#3
                            312 
   06BD 00 C6         [ 3]  313 	bra	fin_cci
                            314 
   0216                     315 tecla_enter_pulsada:
   06BF 3F F7         [ 2]  316 	cmpb	#1
   06C1 FF 00         [ 3]  317 	beq	guardar_palabra
                            318 
   06C3 C6 08 F7      [ 8]  319 	jsr	colocar_cursor_en_fila
                            320 
   06C6 FF            [ 2]  321 	clra
                            322 
   06C7 00 37         [ 3]  323 	bra	fin_cci
   0220                     324 guardar_palabra:
   06C9 04 81         [ 2]  325 	lda	#4
   06CB 20 27         [ 3]  326 	bra	fin_cci
                            327 
   0224                     328 fin_cci:
   06CD 03 4F         [ 7]  329 	pulu	b,x
   06CF 20            [ 5]  330 	rts
                            331 
                            332 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                            333 ;   colocar_cursor_en_pila                                                       ;
                            334 ;       Subrutina que nos coloca el puntero en fila dependiendo de los caracteres;
                            335 ;       ya introduccidos                                                         ;
                            336 ;                                                                                ;
                            337 ;   Entrada: B-El numero del caracter que estamos introduciendo                  ;
                            338 ;   Salida: Ninguna                                                              ;
                            339 ;   Registros afectados: CC                                                      ;
                            340 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   0227                     341 colocar_cursor_en_fila:
   06D0 33 16         [ 8]  342 	pshu	a,b,x
                            343 
   06D1 1F 98         [ 6]  344 	tfr	b,a	; A tiene la posicion actual del caracter introducido
                            345 
   06D1 C1 06 26      [ 3]  346 	ldx	#cursor_up_una_posicion	; Movemos el cursor la posicion superior que ha bajado el enter
   06D4 0D C6 3F      [ 8]  347 	jsr	print
                            348 
   06D7 F7 FF         [ 2]  349 	ldb	#8	; Retrocedemos una posicion para eliminar el caracter escrito
   06D9 00 C6 08      [ 5]  350 	stb	0xFF00
                            351 
   06DC F7 FF 00      [ 3]  352 	ldx	#cursor_right	; Movemos el cursor 5 caracteres a la derecha
   06DF 4F 20 22      [ 8]  353 	jsr	print
                            354 
   06E2 8E 00 15      [ 3]  355 	ldx	#cursor_right_sin_caracter	; Cargamos x para mover el caracter 6 caracteres a la derecha
ASxxxx Assembler V05.00  (Motorola 6809), page 8.
Hexidecimal [16-Bits]



   023F                     356 bucle_ccef:
   06E2 8E 04         [ 2]  357 	cmpa	#6	; mientras a sea diferente de 6 ejecutamos
   06E4 F7 BD         [ 3]  358 	beq	fin_ccef
                            359 
   06E6 09 75 C6      [ 8]  360 	jsr	print	; movemos el cursor
                            361 
   06E9 3F            [ 2]  362 	inca
                            363 
   06EA F7 FF         [ 3]  364 	bra	bucle_ccef
                            365 
   0249                     366 fin_ccef:
   06EC 00 C6         [ 8]  367 	pulu	a,b,x
   06EE 08            [ 5]  368 	rts
                            369 
                            370 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                            371 ;   preparar_puntero_cadena                                                      ;
                            372 ;       Preparamos el puntero de pila Y para que apunte a la direccion           ;
                            373 ;       dentro de arreglo en la que queremos empezar a insertar la palabra       ;
                            374 ;                                                                                ;
                            375 ;   Entrada: Ninguna                                                             ;
                            376 ;   Salida: Y-La direccion a partir de la cual empezar a insertar la palabra     ;
                            377 ;   Registros afectados: Y, CC                                                   ;
                            378 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   024C                     379 preparar_puntero_cadena:
   06EF F7 FF         [ 6]  380 	pshu	a
   06F1 00 86 03 20   [ 4]  381 	ldy	#cadena_palabras
                            382 
   0252                     383 bucle_ppc:
   06F5 0E A0         [ 6]  384 	lda	,y+
                            385 
   06F6 81 3F         [ 2]  386 	cmpa	#'?
   06F6 C1 01         [ 3]  387 	beq	fin_ppc
                            388 
   06F8 27 06         [ 2]  389 	cmpa	#'\0
   06FA BD 07         [ 3]  390 	beq	fin_ppc
                            391 
   06FC 07 4F         [ 3]  392 	bra	bucle_ppc
                            393 
   025E                     394 fin_ppc:
   06FE 20 04         [ 5]  395 	leay	-1,y
                            396 
   0700 37 02         [ 6]  397 	pulu	a
   0700 86            [ 5]  398 	rts
                            399 
                            400 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                            401 ;   comprobar_palabra_introducida                                                ;
                            402 ;       En esta subrutina se comprobara la palabra introducida con la palabra    ;
                            403 ;       secreta, sacar los colores y comprobar que se ha acertado o no.          ;
                            404 ;                                                                                ;
                            405 ;   Entrada: Ninguna                                                             ;
                            406 ;   Salida: Ninguna                                                              ;
                            407 ;   Registros afectados: CC                                                      ;
                            408 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   0263                     409 comprobar_palabra_introducida:
   0701 04 20         [ 9]  410 	pshs	x,y,a,b
ASxxxx Assembler V05.00  (Motorola 6809), page 9.
Hexidecimal [16-Bits]



                            411 
   0703 00            [ 2]  412 	clrb	; Hacemos q b sea 0 ya que lo usaremos de contador
   0704 8E 00 00      [ 3]  413 	ldx	#palabra_secreta
   0704 37 14 39      [ 8]  414 	jsr	apuntar_ultima_palabra
                            415 
   0707                     416 bucle_comprobar_letras_dif_pos:
   0707 36 16         [ 6]  417 	lda	,x+
   0709 1F 98         [ 5]  418 	cmpa	b,y	; Vamos comparando el caracter de nuestra palabra con el de la palabra secreta
   070B 8E 04         [ 3]  419 	beq	poner_amarillo_cpi	; En el caso de ser iguales los ponemos a amarillo
                            420 
   070D E3 BD         [ 2]  421 	cmpa	#'\0	; Comprobamos que haya llegado al final de la palabra
   070F 09 75         [ 3]  422 	bne	bucle_comprobar_letras_dif_pos
                            423 
                            424 	; Reiniciarmos las varibles
   0711 C6 08 F7      [ 3]  425 	ldx	#palabra_secreta
                            426 
                            427 	; Incrementamos B
   0714 FF            [ 2]  428 	incb
                            429 
   0715 00 8E         [ 2]  430 	cmpb	#5	; Comprobamos que B es menor o igual q 0
   0717 04 F2         [ 3]  431 	ble	bucle_comprobar_letras_dif_pos
                            432 
                            433 	; En caso contrario preparamos para siguiente bucle (comprobar misma posicion)
   0719 BD 09 75      [ 3]  434 	ldx	#palabra_secreta
   071C 8E 04 ED      [ 8]  435 	jsr	apuntar_ultima_palabra
   071F 5F            [ 2]  436 	clrb
                            437 
   0285                     438 bucle_comprobar_letras_misma_pos:
   071F 81 06         [ 6]  439 	lda	,y+
   0721 27 06         [ 6]  440 	cmpa	,x+
   0723 BD 09 75      [ 5]  441 	sta	0xFF00
   0726 4C 20         [ 3]  442 	beq	poner_verde_cpi	; comprobamos que son iguales, si lo son ponemos el color a verde
                            443 
   0728 F6            [ 2]  444 	incb	; Aumentamos el contador del b (para saber la posicion en la que tenemos que establecer el color)
                            445 
                            446 	; Comprobamos que A no vale ni ? ni \0
                            447 	; ya que en ese caso ya habriamos leido todos los caracteres
   0729 81 3F         [ 2]  448 	cmpa	#'?
   0729 37 16         [ 3]  449 	bne	bucle_comprobar_letras_misma_pos
                            450 
   072B 39 00         [ 2]  451 	cmpa	#'\0
   072C 26 EE         [ 3]  452 	bne	bucle_comprobar_letras_misma_pos
                            453 
   072C 36 02 10      [ 5]  454 	sta	0xFF00
                            455 
   072F 8E 05         [ 3]  456 	bra	rts_cpi
                            457 
   029C                     458 poner_rojo_cpi:
   0731 04 00 02      [ 5]  459 	lda	2
   0732 BD 02 B7      [ 8]  460 	jsr	poner_color
   0732 A6 A0         [ 3]  461 	bra	bucle_comprobar_letras_dif_pos
                            462 
   02A4                     463 poner_amarillo_cpi:
   0734 81 3F 27      [ 5]  464 	lda	1
   0737 06 81 00      [ 8]  465 	jsr	poner_color
ASxxxx Assembler V05.00  (Motorola 6809), page 10.
Hexidecimal [16-Bits]



   073A 27 02         [ 3]  466 	bra	bucle_comprobar_letras_dif_pos
                            467 
   02AC                     468 poner_verde_cpi:
   073C 20 F4 00      [ 5]  469 	lda	0
   073E BD 02 B7      [ 8]  470 	jsr	poner_color
   073E 31 3F         [ 3]  471 	bra	bucle_comprobar_letras_misma_pos
                            472 
   02B4                     473 rts_cpi:
   0740 37 02         [ 9]  474 	puls	x,y,a,b
   0742 39            [ 5]  475 	rts
                            476 
                            477 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                            478 ;   apuntar_ultima_palabra                                                       ;
                            479 ;       En esta subrutina se almacenara en Y la direccion de inicio a la ultima  ;
                            480 ;       palabra introducida                                                      ;
                            481 ;                                                                                ;
                            482 ;   Entrada: B-Posicion a insertarlo                                             ;
                            483 ;   Salida: Ninguna.                                                             ;
                            484 ;   Registros afectados: CC                                                      ;
                            485 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   0743                     486 poner_color:
   0743 34 36         [ 7]  487 	pshu	y,a	; Usaremos Y para recorrer el vector donde almacenar los colores
                            488 
   0745 5F 8E 04 D8   [ 4]  489 	ldy	#colores_palabras
                            490 
   0749 BD 07         [ 2]  491 	lda	#6
   074B AB 00 06      [ 5]  492 	suba	num_intentos	; Cargamos A con 6 y le restamos el intento actual (asi sabremos los caracteres que tenemos q avanzar)
                            493 
   074C 36 04         [ 6]  494 	pshu	b
                            495 
   074C A6 80         [ 2]  496 	ldb	#6		; Cargamos B con el numero de intentos totales
   074E A1            [11]  497 	mul			; Multiplicamos A por B asi tendremos las posicion a avanzar en D
   074F 20 27         [ 5]  498 	leay	b,y		; Avanzamos el puntero Y las posiciones calculadas
                            499 
   0751 2E 81         [ 6]  500 	pulu	b
                            501 
   0753 00 26         [ 5]  502 	sta	b,y	; Almacenamos en la posicion de la letra el color verde, ya que b lleva la posicion de la letra
                            503 
   0755 F6 5C         [ 7]  504 	pulu	y,a
                            505 
   0757 31            [ 5]  506 	rts
                            507 
                            508 
                            509 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                            510 ;   apuntar_ultima_palabra                                                       ;
                            511 ;       En esta subrutina se almacenara en Y la direccion de inicio a la ultima  ;
                            512 ;       palabra introducida                                                      ;
                            513 ;                                                                                ;
                            514 ;   Entrada: Ninguna                                                             ;
                            515 ;   Salida: Y apuntara a la ultima palabra introducida                           ;
                            516 ;   Registros afectados: CC                                                      ;
                            517 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   02D0                     518 apuntar_ultima_palabra:
   0758 21 C1 05      [ 8]  519 	jsr	preparar_puntero_cadena	; Preparamos el puntero para que apunte a caracter a continuacion de la palabra a tomar
   075B 2F EF         [ 5]  520 	leay	-5,y			; Apuntamos al inicio de la nueva palabra
ASxxxx Assembler V05.00  (Motorola 6809), page 11.
Hexidecimal [16-Bits]



                            521 
   075D 8E            [ 5]  522 	rts
ASxxxx Assembler V05.00  (Motorola 6809), page 12.
Hexidecimal [16-Bits]

Symbol Table

    .__.$$$.       =   2710 L   |     .__.ABS.       =   0000 G
    .__.CPU.       =   0000 L   |     .__.H$L.       =   0001 L
  0 apuntar_ultima     02D0 R   |   0 borrar_caracte     01F1 R
  0 bucle_cc           0128 R   |   0 bucle_ccef         023F R
  0 bucle_columnas     00F8 R   |   0 bucle_comproba     026C R
  0 bucle_comproba     0285 R   |   0 bucle_pp           0147 R
  0 bucle_ppc          0252 R   |   0 cabecera_juego     006A R
  0 cadena_palabra     002C R   |   0 caracter_no_va     01D3 R
  0 caracter_valid     019F R   |   0 caracter_valid     01AC R
  0 colocar_cursor     0227 R   |   0 colorcar_curso     0118 R
  0 colores_palabr     004B R   |   0 comprobar_cara     0182 R
    comprobar_pala     **** GX  |   0 comprobar_pala     0263 R
  0 correcto_pp        0174 R   |   0 cursor_izquier     0202 R
  0 cursor_left        001F R   |   0 cursor_right       001A R
  0 cursor_right_s     0015 R   |   0 cursor_up          0010 R
  0 cursor_up_una_     000B R   |   0 eliminar_carac     0178 R
  0 fila_juego         008B R   |   0 fin_ccef           0249 R
  0 fin_cci            0224 R   |   0 fin_ppc            025E R
  0 guardar_palabr     0220 R   |   0 inicializar_ju     00ED GR
  0 iniciar_compro     015E R   |   0 initial_up_off     0006 R
  0 jugar              0102 R   |   0 mover_cursor_c     012E R
    num_intentos   =   0006     |   0 palabra_no_val     016A R
  0 palabra_secret     0000 R   |   0 palabra_valida     016F R
  0 pedir_palabra      0140 R   |   0 poner_amarillo     02A4 R
  0 poner_color        02B7 R   |   0 poner_rojo_cpi     029C R
  0 poner_verde_cp     02AC R   |   0 prep_reiniciar     01CF R
  0 prep_salir_men     01CB R   |   0 preparar_punte     024C R
    print              **** GX  |   0 restore_cursor     0028 R
  0 rts_cc             0137 R   |   0 rts_cpi            02B4 R
  0 rts_pp             017F R   |   0 save_cursor_po     0024 R
  0 tecla_enter_pu     0216 R

ASxxxx Assembler V05.00  (Motorola 6809), page 13.
Hexidecimal [16-Bits]

Area Table

[_CSEG]
   0 _C 04            size  2D6   flags C180
[_DSEG]
   1 _DATA            size    0   flags C0C0

