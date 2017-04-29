	.data
	.align 4
size:		.space 4	#rozmiar pliku (w bajtach)
width:		.space 4	#szerokosc (piksele, bez paddingu)
height:		.space 4	#wysokosc (piksele)
offset:		.space 4	#adres poczatku tablicy pikseli
padding:	.space 4	#padding w bajtach
bufor:		.space 1024	#do wczytywania niepotrzebnych dla nas bajtow z deskryptora pliku
x1:		.space 4	#wspolrzedne trojkata
y1:		.space 4
x2:		.space 4
y2:		.space 4
x3:		.space 4
y3: 		.space 4
adres_start:	.space 4	
adres_bmp:	.space 4	
file_in:	.asciiz "filein.bmp"


start_prompt:	.asciiz "Witaj w programie podaj wspolrzedna X pierwszego wierzcholka trojkata "	
second_vertex:	.asciiz "Podaj wspolrzedna X drugiego wierzcholka trojkata "		
third_vertex:	.asciiz "Podaj wspolrzedna X trzeciego wierzcholka trojkata "	
y_value:	.asciiz "Podaj wspolrzedna Y wierzcholka "
error_prompt:	.asciiz "Cos sie, cos sie popsulo "
calc_result:	.asciiz "Oto wyniki obliczen Xs, Ys, R: "
space:		.asciiz ", "
the_end:	.asciiz "\nKONIEC"


	.text
	.globl main
	
main:
	li $v0, 4		#drukowanie
	la $a0, start_prompt  	#ladowanie wiadomosci powitalnej jako argumentu
	syscall
	
	li $v0, 5		#pobierz integer (x1)
	syscall
	
	move $s0, $v0		#pobrany integer zapisujemy w rejestrze s0 
	sw $s0, x1		#zapisz pod zmienn¹ x1
	sll $s0, $s0, 8		#zamiana int -> fixed point, scale = 8

	li $v0, 4		#drukowanie
	la $a0, y_value 	#ladowanie wiadomosci o checi wczytania y1
	syscall
	
	li $v0, 5		#pobierz integer (y1)
	syscall
	
	move $s1, $v0		#pobrany integer zapisujemy w rejestrze s1
	sw $s1, y1
	sll $s1, $s1, 8		#zamiana int -> fixed point, scale = 8

	li $v0, 4		#drukowanie
	la $a0, second_vertex	#ladowanie wiadomosci o checi wczytania x2
	syscall
	
	li $v0, 5		#pobierz integer (x2)
	syscall
	
	move $s2, $v0		#pobrany integer zapisujemy w rejestrze s2
	sw $s2, x2
	sll $s2, $s2, 8		#zamiana int -> fixed point, scale = 8

	li $v0, 4		#drukowanie
	la $a0, y_value 	#ladowanie wiadomosci o checi wczytania y2
	syscall
	
	li $v0, 5		#pobierz integer (y2)
	syscall
	
	move $s3, $v0		#pobrany integer zapisujemy w rejestrze s3
	sw $s3, y2
	sll $s3, $s3, 8		#zamiana int -> fixed point, scale = 8

	li $v0, 4		#drukowanie
	la $a0, third_vertex	#ladowanie wiadomosci o checi wczytania y1
	syscall
	
	li $v0, 5		#pobierz integer (x3)
	syscall
	
	move $s4, $v0		#pobrany integer zapisujemy w rejestrze s4
	sw $s4, x3
	sll $s4, $s4, 8		#zamiana int -> fixed point, scale = 8

	
	li $v0, 4		#drukowanie
	la $a0, y_value 	#ladowanie wiadomosci o checi wczytania y1
	syscall
	
	li $v0, 5		#pobierz integer (y3)
	syscall
	
	move $s5, $v0		#pobrany integer zapisujemy w rejestrze s5
	sw $s5, y3
	sll $s5, $s5, 8		#zamiana int -> fixed point, scale = 8

	
as1:
	beq $s1, $s3, y1_equals_y2 #korzystamy z drugiej i trzeciej
		
	sub $t0, $s0, $s2	# x1-x2
	sub $t1, $s3, $s1	# y2-y1
	sll $t0, $t0, 8		# przesuniêcie licznika o scale w lewo przed operacj¹ dzielenia
	div $s6, $t0, $t1	# a1 - wspolczynnik nachylenia pierwszej symetralnej (s6)

	add $t0, $s1, $s3	# y1+y2
	add $t1, $s0, $s2	# x2+x1
	# przesuniêcie jednego czynnika o scale w prawo, tam gdzie s¹ wspó³rzêdne, nie tracimy ¿adnej dok³adnoœci, zachowujemy dok³adnoœæ na wspó³czynniku a, wiêc nie przesuwamy $s6
	sra $t1, $t1, 8
	mul $t8, $t1, $s6
	sub $t8, $t0, $t8
	sra $t8, $t8, 1 	# t8 = b1 - wyraz wolny pierwszej symetralnej
	
	beq $s3, $s5, y2_equals_y3 # korzystamy z pierwszej i trzeciej symetralnej
	 	
as2:

	sub $t0, $s2, $s4	# x2-x3
	sub $t1, $s5, $s3	# y3-y2
	sll $t0, $t0, 8		# przesuniêcie licznika o scale w lewo przed operacj¹ dzielenia
	div $s7, $t0, $t1	# a2 - wspolczynnik nachylenia drugiej symetralnej (s7)

	
	add $t0, $s5, $s3	# y2+y3
	add $t1, $s4, $s2	# x2+x3
	# przesuniêcie jednego czynnika o scale w prawo, tam gdzie s¹ wspó³rzêdne, nie tracimy ¿adnej dok³adnoœci, zachowujemy dok³adnoœæ na wspó³czynniku a, wiêc nie przesuwamy $s7
	sra $t1, $t1, 8
	mul $t9, $t1, $s7
	sub $t9, $t0, $t9
	sra $t9, $t9, 1		# t9 = b2 - wyraz wolny pierwszej symetralnej
	
	
	b circle
	
y2_equals_y3:

	sub $t0, $s0, $s4	# x1-x3
	sub $t1, $s5, $s1	# y3-y1
	sll $t0, $t0, 8		# przesuniêcie licznika o scale w lewo przed operacj¹ dzielenia
	div $s7, $t0, $t1	# a3 - wspolczynnik nachylenia trzeciej symetralnej (s7)

	
	add $t0, $s5, $s1	# y1+y3
	add $t1, $s4, $s0	# x1+x3
	# przesuniêcie jednego czynnika o scale w prawo, tam gdzie s¹ wspó³rzêdne, nie tracimy ¿adnej dok³adnoœci, zachowujemy dok³adnoœæ na wspó³czynniku a, wiêc nie przesuwamy $s7
	sra $t1, $t1, 8
	mul $t9, $t1, $s7
	sub $t9, $t0, $t9
	sra $t9, $t9, 1		# t9 = b3 - wyraz wolny trzeciej symetralnej

	b circle

y1_equals_y2:

	sub $t0, $s2, $s4	# x2-x3
	sub $t1, $s5, $s3	# y3-y2
	sll $t0, $t0, 8		# przesuniêcie licznika o scale w lewo przed operacj¹ dzielenia
	div $s7, $t0, $t1	# a2 - wspolczynnik nachylenia drugiej symetralnej (s7)

	
	add $t0, $s5, $s3	# y2+y3
	add $t1, $s4, $s2	# x2+x3
	# przesuniêcie jednego czynnika o scale w prawo, tam gdzie s¹ wspó³rzêdne, nie tracimy ¿adnej dok³adnoœci, zachowujemy dok³adnoœæ na wspó³czynniku a, wiêc nie przesuwamy $s7
	sra $t1, $t1, 8
	mul $t9, $t1, $s7
	sub $t9, $t0, $t9
	sra $t9, $t9, 1		# t9 = b2 - wyraz wolny pierwszej symetralnej

	sub $t0, $s0, $s4	# x1-x3
	sub $t1, $s5, $s1	# y3-y1
	sll $t0, $t0, 8		# przesuniêcie licznika o scale w lewo przed operacj¹ dzielenia
	div $s6, $t0, $t1	# a3 - wspolczynnik nachylenia trzeciej symetralnej (s6)

	
	add $t0, $s5, $s1	# y1+y3
	add $t1, $s4, $s0	# x1+x3
	# przesuniêcie jednego czynnika o scale w prawo, tam gdzie s¹ wspó³rzêdne, nie tracimy ¿adnej dok³adnoœci, zachowujemy dok³adnoœæ na wspó³czynniku a, wiêc nie przesuwamy $s6
	sra $t1, $t1, 8
	mul $t8, $t1, $s6
	sub $t8, $t0, $t8
	sra $t8, $t8, 1		# t8 = b3 - wyraz wolny trzeciej symetralnej
	
circle:

	sub $t0, $t9, $t8 	# b2-b1
	sub $t1, $s6, $s7	# a1-a2
	sll $t0, $t0, 8		# przesuniêcie licznika o scale w lewo przed operacj¹ dzielenia
	div $t4, $t0, $t1	# t4 = Xs - wspolrzedna X srodka okregu

	
	mul $t0, $s6, $t4
	sra $t0, $t0, 8 	# przesuniêcie wyniku mno¿enia o scale w prawo
	add $t5, $t0, $t8	# t5 = Ys - wspolrzedna Y srodka okregu


	sub $t0, $s0, $t4
	mul $t0, $t0, $t0
	sra $t0, $t0, 8
	sub $t1, $s1, $t5
	mul $t1, $t1, $t1
	sra $t1, $t1, 8
	add $t0, $t0, $t1 #$t0 = R^2 = n
	
#LICZENIE PIERWIASTKA Z ALGORYTMU NEWTONA
	move $t6, $t0 #x
	li $t3, 0 # i
	sra $t2, $t0, 1 	#$t2 = n/2
	
	beqz $t2, result 	#warunek pocz¹tkowy pêtli
pentla:
 #algorytm Newtona
    	sll $t1, $t0, 8
    	div $t1, $t1, $t6  
    	add $t6, $t6, $t1
    	sra $t6, $t6, 1
   	addi $t3, $t3,  256
   	blt $t3, $t2, pentla	#warunek wyjœcia z pêtli

		
result:	#ZAMIANA Z FIXED POINT DO INT, ORAZ ZAOKR¥GLANIE, DRUKOWANIE OBLICZONYCH Xs, Ys, R
	
	andi $t0, $t4, 128 # jeœli >= .5 to zaokr¹glamy
	add $t4, $t4, $t0 
	sra $t4, $t4, 8 #FIXED POINT -> INT Xs

	andi $t0, $t5, 128 # jeœli >= .5 to zaokr¹glamy
	add $t5, $t5, $t0 
	sra $t5, $t5, 8	# Ys

	andi $t0, $t6, 128 # jeœli >= .5 to zaokr¹glamy
	add $t6, $t6, $t0 
	sra $t6, $t6, 8 # R

	li $v0,4
	la $a0,calc_result
	syscall
	
	li $v0,1
	move $a0, $t4
	syscall
	
	li $v0,4
	la $a0,space
	syscall
	
	li $v0,1
	move $a0, $t5
	syscall
	
	li $v0,4
	la $a0,space
	syscall
	
	li $v0,1
	move $a0, $t6
	syscall
	


wczytywanie_pliku:
	li $v0, 13	#otwarcie pliku, wczytanie do v0 file descriptor
	la $a0, file_in	#nazwa pliku
	li $a1, 0	#flaga, 0 - read-only, 1 - write-only
	li $a2, 0
	syscall
	
	move $t0, $v0	#t0 = file descriptor
	bltz $t0, error

	li $v0, 14	#wczytywanie z pliku
	move $a0, $t0	#wczytujemy z pliku pierwsze 2 bajty (SIGNATURE)
	la $a1, bufor
	li $a2, 2	#wczytujemy 2 bajty
	syscall		
	
	li $v0, 14
	move $a0, $t0
	la $a1, size
	li $a2, 4	#wczytujemy 4 bajty (FILESIZE)
	syscall		#wczytanie rozmiaru pliku do rozmiar 
	lw $t1, size	#s1 = rozmiar
	
	li $v0, 9
	move $a0, $t1	#skopiowanie rozmiaru pliku do rejestru a0
	syscall		#alokacja pamieci na bitmape
	move $s6, $v0	#skopiowanie adresu zaalokowanej pamieci do rejestru s6
	sw $s6, adres_bmp
	
	li $v0, 14
	move $a0, $t0	#ponizej przeskakujemy 4 bajty zarezerwowane (RESERVED1 & RESERVED2)
	la $a1, bufor
	li $a2, 4
	syscall
	
	li $v0, 14
	move $a0, $t0
	la $a1, offset
	li $a2, 4	#wczytujemy 4 bajty offsetu (FILE OFFSET TO PIXEL ARRAY)
	syscall
	
	li $v0, 14
	move $a0, $t0	#ponizej przeskakujemy 4 bajty naglowka informacyjnego (DIB HEADER SIZE)
	la $a1, bufor
	li $a2, 4	#wczytujemy 4 bajty
	syscall
	
	li $v0, 14	#wczytywanie z pliku
	move $a0, $t0	#skopiowanie deskryptora pliku do a0
	la $a1, width
	li $a2, 4	#wczytujemy 4 bajty	(IMAGE WIDTH)
	syscall
	
	lw $t2, width
	
	li $v0, 14
	move $a0, $t0	# skopiowanie deskryptora do a0
	la $a1, height
	li $a2, 4	# wczytujemy 4 bajty 	(IMAGE HEIGHT)
	syscall
	
	lw $t3, height
	
	move $a0, $t0	#skopiowanie deskryptora pliku do a0
	li $v0, 16	#zamkniecie pliku
	syscall		#zamykamy plik zeby wskaznik czytania ustawil sie na poczatku
	
	
kopiowanie_pliku_do_pamieci:
	li $v0, 13	#otwieranie pliku
	la $a0, file_in
	li $a1, 0	#flaga otwarcia ustawiona na 0 aby moc czytac z pliku
	li $a2, 0
	syscall		#w v0 znajduje sie deskryptor pliku
	
	move $t0, $v0	#skopiowanie deskryptora do rejestru t0
	
	bltz $t0, end	#przeskocz do konca jesli wczytywanie sie nie powiodlo
	lw $t1, size
	
	li $v0, 14
	move $a0, $t0
	la $a1, ($s6)	#adres zaalokowanej pamieci
	la $a2, ($t1)	#wczytujemy tyle bajtow, jaki jest rozmiar pliku (t1= size)
	syscall

	move $a0, $t0
	li $v0, 16	#zamkniecie pliku
	syscall
	
				#ponizej ustawiamy wskaznik t7 na adres, w ktorym jest
	lw $t7, offset		#poczatek tablicy pikseli. W s6 jest adres poczatku pliku bmp,
	addu $t7, $t7, $s6	#a offset przesuwa wskaznik t7 na poczatek tablicy pikseli
	sw $t7,	adres_start	# adres_start to adres pierwszego piksela
	
padding_check:
	mul $t9, $t2, 3 		# szerokosc razy 3 (kazdy piksel ma 3 bity), bez paddingu
	andi $t9, $t9, 0x00000003	#w t9 znajduje sie reszta z dzielenia przez 4 czyli nadmiar bitowy
	beqz, $t9, padding_zero
	li $t0, 4
	sub $t9, $t0, $t9		# 1 - nadmiar bitowy = padding
	sw $t9, padding
	b starting_point

padding_zero:
	lw $zero, padding
	
starting_point:
	# w $t7 jest adres na pierwszy piksel
	lw $t1, padding
	lw $t0, width
	mul $s2, $t0, 3
	add $s2, $s2, $t1 	# bajty w 1 linijce pikseli (3* width + padding)
	subi $t1, $t5, 1 	#(Ys-1)
	add $t1, $t1, $t6	#(Ys-1 + R)
	mul $t0, $s2, $t1  	# (szerokosc + padding)*(Ys-1+R)
	mul $t1, $t4, 3
	add $t0, $t0, $t1  	# (szerokosc + padding)*(Ys-1+R) + Xs
	add $t0, $t0, $t7
	
	#ustawienie wspolrzednych srodka kola (O,R) = ($t7,$t8)
	li $t7, 0
	move $t8, $t6
	mul $t1, $t6, $t6# R^2
	
	#nie ma warunku wejscia do pêtli poniewa¿ zawsze narysujemy jakieœ punkty, jeœli R>0
color_loop:
	#tutaj bedziemy kolorowac 8 pikseli (x,y) (x, -y) (-x, y) (-x, -y) (y, x) (y, -x) (-y, x) (-y, -x)
	#s2 = padding + width
	move $s4, $t0 #zapamietany(x,y)
	
	#(x,y)
	sb $zero, ($t0)		#kolorowanie na czarno
	addi $t0, $t0, 1	
	sb $zero, ($t0)
	addi $t0, $t0, 1
	sb $zero, ($t0)
	subi $t0, $t0, 2 	#powrot na pierwszy bajt piksela
	mul $t9, $t7, 6
	sub $t0, $t0, $t9
	#(-x,y)
	sb $zero, ($t0)		#kolorowanie na czarno
	addi $t0, $t0, 1	
	sb $zero, ($t0)
	addi $t0, $t0, 1
	sb $zero, ($t0)
	subi $t0, $t0, 2 	#powrot na pierwszy bajt piksela
	mul $t9, $t8, 2
	mul $t9, $t9, $s2
	sub $t0, $t0, $t9
	#(-x,-y)
	sb $zero, ($t0)		#kolorowanie na czarno
	addi $t0, $t0, 1	
	sb $zero, ($t0)
	addi $t0, $t0, 1
	sb $zero, ($t0)
	subi $t0, $t0, 2 	#powrot na pierwszy bajt piksela
	mul $t9, $t7, 6
	add $t0, $t0, $t9
	#(x,-y)
	sb $zero, ($t0)		#kolorowanie na czarno
	addi $t0, $t0, 1	
	sb $zero, ($t0)
	addi $t0, $t0, 1
	sb $zero, ($t0)
	subi $t0, $t0, 2 	#powrot na pierwszy bajt piksela
	sub $t9, $zero, $t7
	add $t9, $t9, $t8
	mul $t9, $t9, 3
	add $t0, $t0, $t9 #(y,-y)
	add $t9, $zero, $t8
	add $t9, $t9, $t7
	mul $t9, $t9, $s2
	add $t0, $t0, $t9
	#(y,x)
	sb $zero, ($t0)		#kolorowanie na czarno
	addi $t0, $t0, 1	
	sb $zero, ($t0)
	addi $t0, $t0, 1
	sb $zero, ($t0)
	subi $t0, $t0, 2 	#powrot na pierwszy bajt piksela
	mul $t9, $t8, 6
	sub $t0, $t0, $t9 
	#(-y,x)
	sb $zero, ($t0)		#kolorowanie na czarno
	addi $t0, $t0, 1	
	sb $zero, ($t0)
	addi $t0, $t0, 1
	sb $zero, ($t0)
	subi $t0, $t0, 2 	#powrot na pierwszy bajt piksela
	mul $t9, $t7, $s2
	mul $t9, $t9, 2
	sub $t0, $t0, $t9
	#(-y,-x)
	sb $zero, ($t0)		#kolorowanie na czarno
	addi $t0, $t0, 1	
	sb $zero, ($t0)
	addi $t0, $t0, 1
	sb $zero, ($t0)
	subi $t0, $t0, 2 	#powrot na pierwszy bajt piksela
	mul $t9, $t8, 6
	add $t0, $t0, $t9
	#(y, -x)
	sb $zero, ($t0)		#kolorowanie na czarno
	addi $t0, $t0, 1	
	sb $zero, ($t0)
	addi $t0, $t0, 1
	sb $zero, ($t0)
	subi $t0, $t0, 2 	#powrot na pierwszy bajt piksela
	move $t0, $s4 #powrot do (x,y)
	
	
	#w algorytmie przy inkrementacji X musimy sprawdzic czy powinnismy sie przesunac o 1 piksel w prawo czy po skosie prawo-dol
	# OBLICZANIE RÓWNANIA X^2+Y^2-R^2 DLA PIKSELA PO PRAWEJ
	add $t2, $t7, 1 # (x+1)
	mul $t2, $t2, $t2 # (x+1)^2
	mul $t3, $t8, $t8# y^2
	add $s0, $t2, $t3# (x+1)^2 + y^2
	sub $s0, $s0, $t1# (x+1)^2 + y^2 - R^2
	
	# OBLICZANIE RÓWNANIA X^2+Y^2-R^2 DLA PIKSELA NA SKOS PRAWO-DÓ£
	subi $t3, $t8, 1 # (y-1)
	mul $t3, $t3, $t3 # (y-1)^2
	add $s1, $t2, $t3 # (x+1)^2 + (y-1)^2
	sub $s1, $s1, $t1 # (x+1)^2 + (y-1)^2 - R^2
	abs $s1, $s1 	#wartoœæ bezwzglêdna (poniewa¿ to równanie mo¿e daæ wynik <0)
	
	blt $s0, $s1, go_right  # s0 < s1, przesuwamy sie w prawo

go_right_down:
	addi $t7, $t7, 1
	subi $t8, $t8, 1
	sub $t0, $t0, $s2
	addi $t0, $t0, 3 #przesuniecie wskaznika na piksel na ukos prawo-dol
	blt $t8, $t7, triangle 	#WARUNEK KOÑCZ¥CY PÊTLE
	b color_loop
	
	
go_right:
	addi $t7, $t7, 1
	addi $t0, $t0, 3 #przesuniecie wskaznika na piksel po prawo
	blt $t8, $t7, triangle	#WARUNEK KOÑCZ¥CY PÊTLE
	b color_loop
	
	
triangle:	
	#load (x1,y1) and (x2,y2) to temporary variables
	lw $t1, x1
	lw $s1, y1
	lw $t2, x2
	lw $s2, y2
	lw $t6, width
	mul $t6, $t6, 3
	lw $t3, padding
	add $t6, $t6, $t3 #jedna linijka bajtów (3* width + padding)
	lw $t9, adres_start
	
	
	li $t3, 0		#licznik pomalowanych boków = 0
	#PRZEJŒCIE NA START
	subi $t5, $s1, 1	#(y1-1)
	mul $s4, $t6, $t5	#(y1-1)*(3* width + padding)
	add $t9, $t9, $s4	#x1
	mul $s4, $t1, 3		#3*x1
	add $t9, $t9, $s4	#t9 = (x1, y1)
	
	
	sb $zero, ($t9)		#kolorowanie na czarno
	addi $t9, $t9, 1	#kolejny bajt
	sb $zero, ($t9)
	addi $t9, $t9, 1
	sb $zero, ($t9)
	subi $t9, $t9, 2	#powrot do pierwszego bajtu pixela



loop_begin:
	ble $t1, $t2, step1     # jeœli x1 <= x2 kx = 3 
	li $s6, -3		# jeœli x1 > x2	kx = -3
	b step2			
step1:
	li $s6, 3		# jeœli x1 <= x2 kx = 3 
	
step2:
	ble $s1, $s2, step3     #jeœli y1 <= y2 ky = + linijka bajtów
	sub $s7, $zero, $t6	#jeœli y1 > y2 ky - linijka bajtów
	b step4
step3:
	add $s7, $zero, $t6	#jeœli y1 <= y2 ky = + linijka bajtów

step4:

	sub $t5, $t2, $t1	#dx = x2 - x1
	abs $t5, $t5		#wartoœæ bezwzglêdna z dx


	sub $s0, $s2, $s1	#dy = y2 - y1
	abs $s0, $s0		#wartoœæ bezwzglêdna z dy

	
step5:		
	
	li $t7, 0 		#licznik = 0
	
	blt $t5, $s0, step6  	#jeœli dx<dy
	
	srl $s4, $t5, 1		#jeœli dx>=dy	e = dx/2 
	
	bge $t7, $t5, end_loops	# jeœli licznik >= dx koñcz pêtle

loop1:	
	add $t9, $t9, $s6        # p = p + kx (przesuwamy siê w prawo o kx - 1 piksel), p to adres piksela na ktory wskazujemy
	sub $s4, $s4, $s0        # e = e - dy (dekrementacja e o dy)
	
	
	bgez $s4, step7	 	#jeœli e>=0
				#jeœli e<0
	add $t9, $t9, $s7        # p = p + ky (przesuwamy siê o piksel do góry)
	add $s4, $s4, $t5        # e = e + dx
	
step7:	
	sb $zero, ($t9)		#malowanie piksela
	addi $t9, $t9, 1	
	sb $zero, ($t9)
	addi $t9, $t9, 1
	sb $zero, ($t9)
	subi $t9, $t9, 2	
        addi $t7, $t7, 1	#licznik++
        
        #while
        blt $t7, $t5, loop1	#jeœli licznik < dx skacz do loop1
        b end_loops		#jeœli licznik >= dx skacz na koniec
        
step6:	# jeœli dx<dy

	srl $s4, $s0, 1		#e = dy/2 
	
	bge $t7, $s0, end_loops	#jeœli licznik>= dy skacz na koniec
loop2:
	add $t9, $t9, $s7       # p = p + ky (piksel do góry)
	sub $s4, $s4, $t5       # e = e - dx (dekrementacja o dx)
	
	bgez $s4, step8		#jeœli e>=0
				#jeœli e<0
	add $t9, $t9, $s6 	# p = p + kx 
	add $s4, $s4, $s0       # e = e + dy
	
step8:	# jeœli e>0
	sb $zero, ($t9)		
	addi $t9, $t9, 1	
	sb $zero, ($t9)
	addi $t9, $t9, 1
	sb $zero, ($t9)
	subi $t9, $t9, 2	
        addi $t7, $t7, 1	#licznik++
        

        blt $t7, $s0, loop2	#jeœli licznik < dy skacz do loop2
       				#jeœli licznik >= dy idziesz na koniec
        
        
end_loops: 
	addi $t3, $t3, 1	#inkrementacja licznika pomalowanych boków
	
				
	bne $t3, 1, step9	#jeœli licznik jest ró¿ny od 1 sprawdŸ dalej
				#jeœli licznik jest równy 1 ³aduj DRUGI BOK
	lw $t1, x2
	lw $s1, y2
	lw $t2, x3
	lw $s2, y3
	b loop_begin
	
step9:				#jeœli licznik jest ró¿ny od 1 sprawdŸ dalej
 	
 	bne $t3, 2, zapisz_plik	#jeœli licznik ró¿ny od 2 KOÑCZ
				#jeœli licznik jest równy 2 ³aduj OSTATNI BOK
	lw $t1, x3
	lw $s1, y3
	lw $t2, x1
	lw $s2, y1
	b loop_begin
	
	
zapisz_plik:
	la $a0, file_in
	li $a1, 1	# flaga otwarcia ustawiona na 1 - zapisywanie do pliku
	li $a2, 0
	li $v0, 13	# otwarcie pliku
	syscall		# w $v0 znajduje sie deskryptor pliku
	
	move $t0, $v0	# skopiowanie deskryptora do rejestru t0
	lw $t1, size
	lw $s6, adres_bmp
	bltz $t0, error
	
	move $a0, $t0
	la $a1, ($s6)	# zapisujemy do pliku dane spod adresu s6 - poczatek pliku bmp w pamieci RAM
	la $a2, ($t1)	# kopiujemy do pliku tyle bajtow ile wynosi rozmiar pliku
	li $v0, 15	# zapisywanie do pliku
	syscall
	
	move $a0, $t0
	li $v0, 16	# zamkniecie pliku
	syscall
end:
	li $v0, 4
	la $a0, the_end
	syscall
	li $v0, 10
	syscall
error:
	li $v0, 4
	la $a0, error_prompt
	syscall
	b end 
