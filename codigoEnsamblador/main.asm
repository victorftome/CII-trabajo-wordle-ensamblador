.module main

.globl	print_presentacion

; Variables con la dirección de inicio de las pilas
; Se han elegido estas direcciones ya que se considera que
; en ningun caso se van a almacenar tanta cantidad de bytes como
; para que haya un desbordamiento.
pila_sistema	.equ	0xD000 ; Dirección inicio pila sistema
pila_usuario	.equ	0xE000 ; Dirección inicio pila usuario

; Variables constantes para ahorrarse escribir la dirección de memoria de cada referencia
teclado			.equ	0xFF02
pantalla		.equ	0xFF00

.globl	programa

programa:
	; Le indicamos a las Pilas la direccion de comienzo para evitar futuros problemas
	lds	#pila_sistema
	ldu	#pila_usuario

	jsr	print_presentacion

fin_programa:
	clra
	sta	0xFF01
	.area	FIJA(ABS)
	.org	0xFFFE
	.word 	programa