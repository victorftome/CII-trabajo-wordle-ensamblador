;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   MODULO: operaciones_cadenas                                                  ;
;       En este modulo se van a crear todas las subrutinas que                   ;
;       van a realizar operaciones con cadenas                                   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.module operaciones_cadenas

; Variables globales
.globl	print
.globl  int_to_char
.globl	lineas_leidas

lineas_leidas:	.byte	0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   print                                                                        ;
;       Imprime por pantalla la cadena apuntada por el registro X                ;
;                                                                                ;
;   Entrada: X-direccion de comienzo en la cadena                                ;
;   Salida: B-Número líneas mostradas                                            ;
;   Registros afectados: X, CC.                                               ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print:
    pshu    a               ; Almacenamos el contenido del registro a en la pila de usuario
	clr lineas_leidas

next_char:
    lda     ,x+             ; Almacenamos el contenido de x en a y aumentamos el apuntador
    beq     string_end      ; Comprobamos que el contenido no sea 0, es decir, el caracter nulo (\0)
    sta     0xFF00          ; Imprimimos el contenido en pantalla 

	cmpa	#'\n ; Comprobamos que sea un final de linea
	bne		next_char ; En caso de que no lo sea simplemente leemos el siguiente caracter

	inc		lineas_leidas ; Incrementamos las lineas leidas, ya que hemos detectado un salto de linea

    bra     next_char

string_end:
    pulu    a               ; Recuperamos el contenido de a
    rts

; TODO: Completar int_to_char
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   int_to_char                                                                  ;
;       Pasa un numero a caracter                                                ;
;                                                                                ;
;   Entrada: B-Número a pasar a caracter                                         ;
;   Salida: B-El número transformado a caracteres correstamente                  ;
;   Registros afectados: B, X, CC.                                               ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

int_to_char:

    rts