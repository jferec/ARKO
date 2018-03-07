
;rsi - width
;rdx - height
;xmm0 - re_c
;xmm1 - im_c
;xmm2 - zoom
;xmm3 - view_x
;xmm4 - view_y

DEFAULT REL

section .text
	global juliaset

juliaset:

	push rbp
	mov rbp, rsp

	mov r15,2
	cvtsi2sd	xmm12, r15

	mov r15,4
	cvtsi2sd	xmm13, r15
	
	mov r15, rsi
	cvtsi2sd xmm14, rsi; 	wysokosc
	mov r15, rdx
	cvtsi2sd xmm15, rdx; 	szerokosc

	mov r10, [rdi]
	mov rax, 0; 		x piksela
	mov rbx, -1; 		y piksela(odrazu inkrementujemy do 0)
	mov rcx, 0; 		iter
	mov rsp, 255; 		iter_range
	
	
check_y:
	inc rbx 
	mov rax, 0 ; 		zerowanie x
	cmp rbx, rdx ; 		sprawdz y piksela </> wysokosc			
	jge end;				if y > rdx wszystkie linie zrobione 

next_x:
	cmp rax, rsi
	jge check_y

julia_begin:
	cvtsi2sd 	xmm5, rax;		wspolrzedna x na wykresie
	cvtsi2sd	xmm6, rbx;		wspolrzedna y na wykresie

	movsd		xmm7, xmm12	;laduje 2
	divsd		xmm7, xmm2	; 2/zoom
	movsd 		xmm8, xmm12	; 2
	mulsd		xmm8, xmm5	; 2*px
	divsd		xmm8, xmm15	; 2*px/szer
	movsd		xmm9, xmm12
	divsd		xmm9, xmm9	; 1
	subsd		xmm8, xmm9	; 2*px/szer - 1
	mulsd		xmm7, xmm8
	addsd		xmm7, xmm3
	movsd		xmm5, xmm7



	movsd		xmm7, xmm12	;	laduje 2
	divsd		xmm7, xmm2	; 2/zoom
	movsd 		xmm8, xmm12	; 2
	mulsd		xmm8, xmm6	; 2*py
	divsd		xmm8, xmm14	; 2*py/wys
	movsd		xmm9, xmm12
	divsd		xmm9, xmm9	; 1
	subsd		xmm8, xmm9	; 2*px/wys - 1
	mulsd		xmm7, xmm8
	addsd		xmm7, xmm4
	movsd		xmm6, xmm7

	movsd		xmm8, xmm5;		wspolrzedna x do kalkulacji zbioru
	movsd		xmm9, xmm6;		wspolrzedna y do kalkulacji zbioru
	mov		rcx, 0;			iter = 0

	

julia_loop_1:
	movsd		xmm5, xmm8;		x
	movsd		xmm10, xmm8;
	mulsd		xmm10, xmm10;		x^2
	movsd		xmm11, xmm9;	
	mulsd		xmm11, xmm11;		y^2
	movsd		xmm7, xmm10;		x^2
	
	addsd		xmm7, xmm11;		x^2+y^2 = |z|
	comisd		xmm7, xmm13;		|z| </> 4.0
	ja		escapee	;		if |z|=>4.0 uciekinier

	cmp		rcx, rsp;		if |z| < 4.0 && iter=iter_range wiezien
	je		prisoner
	inc		rcx;			else iter++

	movsd		xmm8, xmm10;		zaczynamy liczyc wspolrzedna x do nast iter
	subsd		xmm8, xmm11;		
	addsd		xmm8, xmm0;		x = x^2 - y^2 + re_c - obliczona

	mulsd		xmm9, xmm5;		zaczynamy liczyc wspolrzedna y do nast iter
	mulsd		xmm9, xmm12
	addsd		xmm9, xmm1;		y = 2*x*y + im_c - obliczona

	jmp 		julia_loop_1;		po obliczeniu x,y do nast iter skaczemy na pocz
		
escapee:



	mov		r14, rdx;			wysokosc
	sub		r14, rbx;			wysokosc- wspolrzedna y
	sub		r14, 1;
	imul		r14, rsi;		(wys-y)*szer
	add		r14, rax;
	imul		r14, 3;


	mov		byte[r10+r14],0;
	mov		[r10+r14+1], rcx;		koloruj 
	mov		byte[r10+r14+2], 255;	koloruj 




	inc		rax;	
	jmp		next_x;			skacz do nast x
	
prisoner:	
	
		
	mov		r14, rdx;		wysokosc
	sub		r14, rbx;		wysokosc- wspolrzedna y
	sub		r14, 1;
	imul		r14, rsi;		(wys-y)*szer
	add		r14, rax;
	imul		r14, 3;
	

	mov		byte[r10+r14], 0;
	mov		byte[r10+r14+1], 0;
	mov		byte[r10+r14+2], 0;	koloruj 

	inc		rax;	
	jmp		next_x;			skacz do nast x

end:
	mov rsp,rbp
	pop rbp
	ret


	
	
	
