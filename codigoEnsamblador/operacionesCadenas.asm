;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   MODULO: operaciones_cadenas                                                  ;
;       En este modulo se van a crear todas las subrutinas que                   ;
;       van a realizar operaciones con cadenas                                   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.module operaciones_cadenas

; Variables globales
.globl	print
.globl	int_to_char

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
;   leer_cadena_max								 ;
;		Utilizado para leer una cadena de caracteres de máximo 5 letras	 ;
;		Permitiendo la lectura de caracteres de "control" del programa	 ;
;               La variable usada es: "lcn_max" para el contador		 ;
;										 ;
;   Entrada: X -> direccion de comienzo en la cadena                             ;
;   Salida: Ninguna                                                              ;
;   Registros afectados: CC, A, B                                                ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Inicio subrutina, utilizar psh u/s para recuperar valores que se hayan necesitado
;leer_cadena_max:
	
;		lda		#0				; Poner A a 0, para el contador
;		ldb		teclado			; Cargar en B el valor introducido por el user
	
;		cmpb	#'\n			; Comprobar con el salto de línea y ver si ha metido 5 letras
;		beq		salto_linea		
		
;		cmpb	#32				; Si el caracter introducido es " ", comprobar si hay al menos
;		beq		dist_cero		; una letra introducida, para retirarla
	
;		cmpb	#r				; Si el caracter introducido es "r", realizar la acción correspondiente
;		beq		codigo_r		;
	
;		cmpb	#v				; Si el caracter introducido es "v", realizar la acción correspondiente
;		beq		codigo_v		;
	
;		beq		no_codigo		; Si no es ningún caracter de control, guardar letra
		
;	salto_linea:
	
;		cmpa	lcn_max			; Si el contador de letras no es igual a 4 ignorar el
;		bne		leer_cadena_max	; salto de lína, pues la palabra no está completa
;		bra		fin_cadena_max	; Si el contador es 4, acabar la subrutina (del 0 al 4)
	
;	dist_cero:
		
;		cmpa	#0				; Si no hay ninguna letra introducida, no hacer
;		beq		leer_cadena_max	; nada, y volver al inico de la subrutina
;		clr		,-x				; Borrar la última letra guardada y después
;		bra 	leer_cadena_max	; volver al inicio de la subrutina
		
;	codigo_r:
		
		
;	codigo_v:
	
	
;	no_codigo:
	
;		cmpa	lcn_max			; Si ya hay 5 letras, no hacer nada
;		beq		leer_cadena_max	
;		stb		,x+				; Guardar lo que hay en B a X
;		inca					; Añadir 1 al contador en A
;		beq		leer_cadena_max
	
	
	; Final de la subrutina, utilizar pul u/s para recuperar valores que se hayan necesitado
;	fin_cadena_max: