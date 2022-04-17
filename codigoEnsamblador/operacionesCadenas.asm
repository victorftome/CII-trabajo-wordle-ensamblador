;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   MODULO: operaciones_cadenas                                                  ;
;       En este modulo se van a crear todas las subrutinas que                   ;
;       van a realizar operaciones con cadenas                                   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.module operaciones_cadenas

; Variables globales
.globl	print
.globl	lineas_leidas

lineas_leidas:	.word   0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   print                                                                        ;
;       Imprime por pantalla la cadena apuntada por el registro X                ;
;                                                                                ;
;   Entrada: X-direccion de comienzo en la cadena                                ;
;   Salida: B-Número líneas mostradas                                            ;
;   Registros afectados: X, CC.                                              	 ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print:
	pshu	a	; Almacenamos el contenido del registro a en la pila de usuario
	clr	lineas_leidas

next_char:
	lda	,x+             ; Almacenamos el contenido de x en a y aumentamos el apuntador
	beq	string_end      ; Comprobamos que el contenido no sea 0, es decir, el caracter nulo (\0)
	sta	0xFF00          ; Imprimimos el contenido en pantalla 

	cmpa	#'\n ; Comprobamos que sea un final de linea
	bne	next_char ; En caso de que no lo sea simplemente leemos el siguiente caracter

	inc	lineas_leidas ; Incrementamos las lineas leidas, ya que hemos detectado un salto de linea
	bra	next_char

string_end:
	; bra	lineas_leidas_to_char
	pulu	a               ; Recuperamos el contenido de a
    	rts

; Pasaremos las lineas leidas a caracter para poder representarlo correctamente
lineas_leidas_to_char:
	pshu	d
	clra
	clrb
	ldb	lineas_leidas+1
bucle:
	inca
	subb	#10
	bhs	bucle
	sta	lineas_leidas
	addb	#58
	stb	lineas_leidas+1
	pulu	d

	bra	string_end
