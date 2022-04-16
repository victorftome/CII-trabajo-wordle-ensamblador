.module main

.globl	print_presentacion
.globl	print_menu

; Variables con la dirección de inicio de las pilas
; Se han elegido estas direcciones ya que se considera que
; en ningun caso se van a almacenar tanta cantidad de bytes como
; para que haya un desbordamiento.
pila_sistema	.equ	0xD000 ; Dirección inicio pila sistema
pila_usuario	.equ	0xE000 ; Dirección inicio pila usuario

.globl	main

main:
	; Le indicamos a las Pilas la direccion de comienzo para evitar futuros problemas
	lds	#pila_sistema
	ldu	#pila_usuario

	jsr	print_presentacion

menu:
	jsr	print_menu

fin_programa:
	lda	#'\n
	sta	0xFF00

	clra
	sta	0xFF01
	.area	FIJA(ABS)
	.org	0xFFFE
	.word 	main