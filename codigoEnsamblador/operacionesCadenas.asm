;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   MODULO: operaciones_cadenas                                                  ;
;       En este modulo se van a crear todas las subrutinas que                   ;
;       van a realizar operaciones con cadenas                                   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.module operaciones_cadenas

; Variables globales
.globl	print
.globl	int_to_char
.globl	palabras
.globl	comprobar_palabra_existente

lcn_max:	.byte	4

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   print                                                                        ;
;       Imprime por pantalla la cadena apuntada por el registro X                ;
;                                                                                ;
;   Entrada: X-direccion de comienzo en la cadena                                ;
;   Salida: B-Número líneas mostradas                                            ;
;   Registros afectados: B, CC.                                              	 ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print:
	pshu	a,x	; Almacenamos el contenido del registro a en la pila de usuario
	clrb

next_char:
	lda	,x+             ; Almacenamos el contenido de x en a y aumentamos el apuntador
	beq	string_end      ; Comprobamos que el contenido no sea 0, es decir, el caracter nulo (\0)
	sta	0xFF00          ; Imprimimos el contenido en pantalla 

	cmpa	#'\n ; Comprobamos que sea un final de linea
	bne	next_char ; En caso de que no lo sea simplemente leemos el siguiente caracter

	incb	; Incrementamos las lineas leidas, que almacenamos en b.
	bra	next_char

string_end:
	; bra	lineas_leidas_to_char
	pulu	a,x	; Recuperamos el contenido de a
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   print_char                                                                   ;
;       Imprime por pantalla el caracter apuntado en y                           ;
;                                                                                ;
;   Entrada: Y-direccion del caracter a imprimir                                 ;
;   Salida: Ninguna                                                              ;
;   Registros afectados: CC.                                                     ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print_char:
	pshu	a,y

	lda	,y
	sta	0xFF00

	pulu	a,y
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   int_to_char                                                                  ;
;       Pasa un numero entero de un maximo de dos cifras a caracter              ;
;                                                                                ;
;   Entrada: B-Número a pasar a caracteres                                       ;
;   Salida: D-El número pasado a caracter                                        ;
;   Registros afectados: D, CC.                                              	 ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
int_to_char:
	clra	; Ponemos A a 0

bucle_div_10:
	cmpb	#10	; Comprobamos que el numero restante en B sea menor que 10
	blo		fin_itc	; En el caso de que sea menor que 10 es porque ya tenemos las unidades

	subb	#10	; Restamos 10 a B
	inca		; Incrementamos A, ya que A van a ser las decenas

	bra		bucle_div_10

fin_itc:
	; Sumamos 48 a ambos registros.
	; ya que en a tenemos las decenas y en b nos quedan las unidades
	adda	#48
	addb	#48

	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   comprobar_palabra_existente                                                  ;
;       Comprueba que la palabra introducida por el usuario existe               ;
;       en el diccionario                                                        ;
;                                                                                ;
;   Entrada: X-La direccion de memoria al primer caracter de la palabra          ;
;            introducida por el usuario.                                         ;
;                                                                                ;
;   Salida: A-Un 0 si la palabra no se encuentra en el diccionario y un 1 si se  ;
;           ha encontrado                                                        ;
;                                                                                ;
;   Registros afectados: CC.                                                     ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
dir_inicio_palabra:	.word	0	;,Variable sobre la que nos apollamos para almacenar la direccion de memoria del primer
					; caracter de la palabra introducida por el usuario.

comprobar_palabra_existente:
	pshu	y,b
	stx	dir_inicio_palabra
	ldy	#palabras

bucle_comprobar_existencia_cpe:
	lda	,y+	; Cargamos en A el caracter apuntado por Y y avanzamos el puntero.

	cmpa	,x+	; Comparamos el contenido de A con el contenido de B, es decir, los caracteres
	beq	bucle_comprobar_existencia_cpe	; si son iguales comprobamos el siguiente caracter

; Aqui vamos a comprobar si se ha llegado a este salto porque las palabras
; son diferentes, o porque se ha acabado de leer la palabra contenido en y,
; llegando a un \n
comprobar_salida_cpe:
	cmpa	#'\n	; En caso de haber llegado a un \n querra decir que se ha llegado al final de una palabra
			; Por tanto la palabra existe en el diccionario
	beq	palabra_valida_cpe

	cmpa	#'\0	; En caso de haber llegado a un \0 querra decir que ya se han acabado de leer todas las palabras del diccionario
	beq	palabra_no_valida	; por lo tanto no hemos llegado a ningun \n en ningun momento, la palabra no esta en el diccionario

	ldx	dir_inicio_palabra	; Hacemos q x apunte otra vez al inicio de la palabra

bucle_prepara_siguiente_palabra_cpe:
	lda	,y+	; seguimos recorriendo y hasta que demos con un \n
	cmpa	#'\n
	beq	bucle_comprobar_existencia_cpe
	bra	bucle_prepara_siguiente_palabra_cpe

palabra_valida_cpe:
	lda	#1	; Establecemos A a 1
	bra	fin_cpe

palabra_no_valida:
	clra	; Ponemos A a 0

fin_cpe:
	pulu	y,b
	rts
