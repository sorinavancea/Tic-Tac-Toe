.386
.model flat, stdcall
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;includem biblioteci, si declaram ce functii vrem sa importam
includelib msvcrt.lib
extern exit: proc
extern malloc: proc
extern memset: proc

includelib canvas.lib
extern BeginDrawing: proc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;declaram simbolul start ca public - de acolo incepe executia
public start
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;sectiunile programului, date, respectiv cod
.data
;aici declaram date
window_title DB "X&0-VANCEA SORINA",0

area_width EQU 680
area_height EQU 700
area DD 0

x DD 0
y DD 0

;variabile pentru fiecare patrat
var1 DD 2
var2 DD 2
var3 DD 2
var4 DD 2
var5 DD 2
var6 DD 2
var7 DD 2
var8 DD 2
var9 DD 2

count dd 1 ;pentru a stii cand il punem pe x ,cand pe 0 => numar click-uri-> impar: x, par: 0

puncte_x dd 0
puncte_0 dd 0

arg1 EQU 8 ;coloana sau x
arg2 EQU 12 ;randul sau y
arg3 EQU 16 ;lungimea
arg4 EQU 20 ;pointer 

symbol_width EQU 10
symbol_height EQU 20
include digits.inc
include letters.inc

.code

;procedura pentru a-l desena pe X
make_text proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1] ; citim simbolul de afisat
	cmp eax, 'A'
	jl make_digit
	cmp eax, 'Z'
	jg make_digit
	sub eax, 'A'
	lea esi, letters
	jmp draw_text
	
make_digit:
	cmp eax, '0'
	jl make_space
	cmp eax, '9'
	jg make_space
	sub eax, '0'
	lea esi, digits
	jmp draw_text
	
make_space:	
	mov eax, 26 ; de la 0 pana la 25 sunt litere, 26 e space
	lea esi, letters
	
draw_text:
	mov ebx, symbol_width
	mul ebx
	mov ebx, symbol_height
	mul ebx
	add esi, eax
	mov ecx, symbol_height
bucla_simbol_linii:
	mov edi, [ebp+arg2] ; pointer la matricea de pixeli
	mov eax, [ebp+arg4] ; pointer la coord y
	add eax, symbol_height
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3] ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, symbol_width
bucla_simbol_coloane:
	cmp byte ptr [esi], 0
	je simbol_pixel_alb
	mov dword ptr [edi], 00BFFFh
	jmp simbol_pixel_next
simbol_pixel_alb:
	mov dword ptr [edi], 0FFFFFFh
simbol_pixel_next:
	inc esi
	add edi, 4
	loop bucla_simbol_coloane
	pop ecx
	loop bucla_simbol_linii
	popa
	mov esp, ebp
	pop ebp
	ret
make_text endp


; un macro ca sa apelam mai usor desenarea simbolului,pentru X
make_text_macro macro symbol, drawArea, x, y
	push y
	push x
	push drawArea
	push symbol
	call make_text
	add esp, 16
endm

;procedura pentru a-l desena pe 0
make_text1 proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1] ; citim simbolul de afisat
	cmp eax, 'A'
	jl make_digit1
	cmp eax, 'Z'
	jg make_digit1
	sub eax, 'A'
	lea esi, letters
	jmp draw_text1
make_digit1:
	cmp eax, '0'
	jl make_space1
	cmp eax, '9'
	jg make_space1
	sub eax, '0'
	lea esi, digits
	jmp draw_text1
make_space1:	
	mov eax, 26 ; de la 0 pana la 25 sunt litere, 26 e space
	lea esi, letters
	
draw_text1:
	mov ebx, symbol_width
	mul ebx
	mov ebx, symbol_height
	mul ebx
	add esi, eax
	mov ecx, symbol_height
bucla_simbol_linii1:
	mov edi, [ebp+arg2] ; pointer la matricea de pixeli
	mov eax, [ebp+arg4] ; pointer la coord y
	add eax, symbol_height
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3] ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, symbol_width
bucla_simbol_coloane1:
	cmp byte ptr [esi], 0
	je simbol_pixel_alb1
	mov dword ptr [edi], 8A2BE2h ;culoarea cu care scriem
	jmp simbol_pixel_next1
simbol_pixel_alb1:
	mov dword ptr [edi], 0FFFFFFh ;fundal casutelor
simbol_pixel_next1:
	inc esi
	add edi, 4
	loop bucla_simbol_coloane1
	pop ecx
	loop bucla_simbol_linii1
	popa
	mov esp, ebp
	pop ebp
	ret
make_text1 endp

; un macro ca sa apelam mai usor desenarea simbolului,pentru 0
make_text_macro1 macro symbol, drawArea, x, y
	push y
	push x
	push drawArea
	push symbol
	call make_text1
	add esp, 16
endm


linieOrizontala proc ;linie orizontala (x,y,lungime) arg1, arg2, arg3
	push ebp
	mov ebp, esp
	pusha ;pune toti registrii pe stiva,nu se modif registrii la iesire->asigura nemodificarea lor
		
	mov eax, area_width ;mutam in eax latimea matricii
	mov ebx, [ebp+arg2] ;de pe ce rand vrem sa incepem(pointer la y)
	mul ebx;
	add eax, [ebp+arg1] ;de pe ce coloana vreau sa incep(pointer la x)
	shl eax, 2  ;innmultesc cu 4, am nevoie de un dword per pixeli
	mov ebx,area  
	add eax, ebx ;pozitia punctului	
	mov ecx, [ebp+arg3] ;lungimea liniei
	 
 linie: 
	mov dword ptr [eax],00FFCCh ;aici mai pot pune o culoare => ebp+20(parametru)
	add eax, 4;
	loop linie	
	
	popa
	mov esp, ebp
	pop ebp
	ret
linieOrizontala endp


linieVerticala proc;linie orizontala (x,y,lungime) arg1, arg2, arg3
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, area_width;
	mov ebx, [ebp+12]
	mul ebx;
	add eax, [ebp+8];
	shl eax, 2 ;am nevoie de un dword per pixeli
	mov ebx,area;
	add eax, ebx;
	mov ecx, [ebp+16];
linie: 
	mov dword ptr [eax],6500FFh;
	add eax, 4*area_width;
	loop linie

	popa
	mov esp, ebp
	pop ebp
	ret
linieVerticala endp

;in functia verificare vom face algoritmul propriu-zis + verificam x si 0
verificare proc

push ebp
	mov ebp, esp ;sa nu scada sub baza stivei
	pusha ; pune pe staiva toti regitrii	
	
	cmp puncte_0, 0
	je zero_pct
	cmp puncte_0,1
	je un_pct
	cmp puncte_0,2
	je doua_pct
	cmp puncte_0,3
	je trei_pct
	cmp puncte_0,4
	je patru_pct
	cmp puncte_0,5
	je cinci_pct
	cmp puncte_0,6
	je sase_pct
	cmp puncte_0,7
	je sapte_pct
	cmp puncte_0,8
	je opt_pct
	cmp puncte_0,9
	je noua_pct 
	
	
zero_pct:
	make_text_macro '0', area ,425, 545
	jmp pct_x
un_pct:
	make_text_macro '1', area ,425, 545
	jmp pct_x
doua_pct:
	make_text_macro '2', area ,425, 545
	jmp pct_x
trei_pct:
	make_text_macro '3', area ,425, 545
	jmp pct_x
patru_pct:
	make_text_macro '4', area ,425, 545
	jmp pct_x
cinci_pct:
	make_text_macro '5', area ,425, 545
	jmp pct_x
sase_pct:
	make_text_macro '6', area ,425, 545
	jmp pct_x
sapte_pct:
	make_text_macro '7', area ,425, 545
	jmp pct_x
opt_pct:
	make_text_macro '8', area ,425, 545
	jmp pct_x
noua_pct:
	make_text_macro '9', area ,425, 545
	jmp pct_x

pct_x:	
cmp puncte_x, 0
	je zero_pct1
	cmp puncte_x,1
	je un_pct1
	cmp puncte_x,2
	je doua_pct1
	cmp puncte_x,3
	je trei_pct1
	cmp puncte_x,4
	je patru_pct1
	cmp puncte_x,5
	je cinci_pct1
	cmp puncte_x,6
	je sase_pct1
	cmp puncte_x,7
	je sapte_pct1
	cmp puncte_x,8
	je opt_pct1
	cmp puncte_x,9
	je noua_pct1 
	
	
zero_pct1:
	make_text_macro '0', area ,375, 545
	jmp v1
un_pct1:
	make_text_macro '1', area ,375, 545
	jmp v1
doua_pct1:
	make_text_macro '2', area ,375, 545
	jmp v1
trei_pct1:
	make_text_macro '3', area ,375, 545
	jmp v1
patru_pct1:
	make_text_macro '4', area ,375, 545
	jmp v1
cinci_pct1:
	make_text_macro '5', area ,375, 545
	jmp v1
sase_pct1:
	make_text_macro '6', area ,375, 545
	jmp v1
sapte_pct1:
	make_text_macro '7', area ,375, 545
	jmp v1
opt_pct1:
	make_text_macro '8', area ,375, 545
	jmp v1
noua_pct1:
	make_text_macro '9', area ,375, 545
	jmp v1
	
v1:
	mov eax, var1
	add eax,var2
	add eax,var3
	cmp eax,0
	je castiga0
	
	mov eax, var4
	add eax, var5
	add eax, var6
	cmp eax, 0
	je castiga0
	
	mov eax, var7
	add eax, var8
	add eax, var9
	cmp eax, 0
	je castiga0
	
	mov eax, var1
	add eax, var5
	add eax, var9
	cmp eax, 0
	je castiga0
	
	mov eax, var3
	add eax, var5
	add eax, var7
	cmp eax, 0
	je castiga0
	
	mov eax, var1
	add eax, var4
	add eax, var7
	cmp eax, 0
	je castiga0
	
	mov eax, var2
	add eax, var5
	add eax, var8
	cmp eax, 0
	je castiga0
	
	mov eax, var3
	add eax, var6
	add eax, var9
	cmp eax, 0
	je castiga0
	
	cmp var1,1
	jne v2
	cmp var2,1
	jne v2
	cmp var3,1
	jne v2
	jmp castigax
	
v2:
	cmp var4,1
	jne v3
	cmp var5,1
	jne v3
	cmp var6,1
	jne v3
	jmp castigax
	
v3:
    cmp var7,1
	jne v4
	cmp var8,1
	jne v4
	cmp var9,1
	jne v4
	jmp castigax	
	
v4:
	cmp var1,1
	jne v5
	cmp var4,1
	jne v5
	cmp var7,1
	jne v5
	jmp castigax
	
v5:
	cmp var2,1
	jne v6
	cmp var5,1
	jne v6
	cmp var8,1
	jne v6
	jmp castigax
	
v6:
	cmp var3,1
	jne v7
	cmp var6,1
	jne v7
	cmp var9,1
	jne v7
	jmp castigax

v7:
	cmp var1,1
	jne v8
	cmp var5,1
	jne v8
	cmp var9,1
	jne v8
	jmp castigax

v8:
	cmp var3,1
	jne pt_remiza
	cmp var5,1
	jne pt_remiza
	cmp var7,1
	jne pt_remiza
	jmp castigax
	
pt_remiza:
	cmp var1,2
	je final1
	cmp var2,2
	je final1
	cmp var3,2
	je final1
	cmp var4,2
	je final1
	cmp var5,2
	je final1
	cmp var6,2
	je final1
	cmp var7,2
	je final1
	cmp var8,2
	je final1
	cmp var9,2
	je final1
	jmp remiza

	jmp final1
	
castigax:
	make_text_macro 'C', area, 250, 430
	make_text_macro 'A', area, 260, 430
	make_text_macro 'S', area, 270, 430
	make_text_macro 'T', area, 280, 430
	make_text_macro 'I', area, 290, 430
	make_text_macro 'G', area, 300, 430
	make_text_macro 'A', area, 310, 430
	make_text_macro ' ', area, 320, 430
	make_text_macro 'X', area, 330, 430
	inc puncte_x
	jmp initializeaza
	
castiga0:
	make_text_macro1 'C', area, 250, 430
	make_text_macro1 'A', area, 260, 430
	make_text_macro1 'S', area, 270, 430
	make_text_macro1 'T', area, 280, 430
	make_text_macro1 'I', area, 290, 430
	make_text_macro1 'G', area, 300, 430
	make_text_macro1 'A', area, 310, 430
	make_text_macro1 ' ', area, 320, 430
	make_text_macro1 '0', area, 330, 430
	inc puncte_0
	jmp initializeaza
	
remiza:
	make_text_macro ' ', area, 250, 430
	make_text_macro ' ', area, 260, 430
	make_text_macro 'R', area, 270, 430
	make_text_macro 'E', area, 280, 430
	make_text_macro 'M', area, 290, 430
	make_text_macro 'I', area, 300, 430
	make_text_macro 'Z', area, 310, 430
	make_text_macro 'A', area, 320, 430
	make_text_macro ' ', area, 330, 430
	jmp initializeaza
	
initializeaza:
	mov var1,2
	mov var2,2
	mov var3,2
	mov var4,2
	mov var5,2
	mov var6,2
	mov var7,2
	mov var8,2
	mov var9,2
	mov count,1
	make_text_macro ' ', area, 160 , 114
	make_text_macro ' ', area, 300 , 114
	make_text_macro ' ', area, 430 , 114
	make_text_macro ' ', area, 160 , 210
	make_text_macro ' ', area, 300 , 210
	make_text_macro ' ', area, 430 , 210
	make_text_macro ' ', area, 160 , 315
	make_text_macro ' ', area, 300 , 315
	make_text_macro ' ', area, 430 , 315


	
final1:

	popa
	mov esp, ebp
	pop ebp
	ret

verificare endp

draw proc
	push ebp
	mov ebp, esp ;sa nu scada sub baza stivei
	pusha ; pune pe staiva toti regitrii	
		
	mov eax, [ebp+arg1]
	cmp eax, 1
	jz evt_click
	cmp eax, 0
	jz intitializare
	jmp final	
intitializare:
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	push 255
	push area
	call memset
	add esp, 12
	 jmp final
	 
evt_click:
	 mov eax, [EBP + arg3] ;y
	 mov ebx, [ebp +arg2] ;X
	 		
desen_x:
	cmp eax, 75
	jl final
	cmp eax, 400
	jg final
	cmp ebx, 100
	jl final
	cmp ebx, 500
	jg final
	
	cmp eax, 175
	jg rand2
	cmp ebx, 230
	jl desen1	
	cmp ebx, 368
	jl desen2	
	jmp desen3
rand2:
	 cmp eax, 275
	 jg rand3 
	 cmp ebx, 230
	 jl desen4 
	 cmp ebx, 368
	 jl desen5
	 jmp desen6		 
rand3:
	 cmp ebx, 230
	 jl desen7	 
	 cmp ebx, 368
	 jl desen8	 
	 jmp desen9

desen1:
	cmp var1,2
	jne final
	inc count	
	mov eax, count
	mov edx ,0
	mov ecx,2
	div ecx
	cmp edx,0
	je face_x1
	make_text_macro1 'O',area,160,114
	mov var1,0
	call verificare
	jmp final
	face_x1:
	make_text_macro 'X',area,160,114
	mov var1,1
	call verificare
	jmp final	
desen2:
    cmp var2,2
	jne final
	inc count
	mov eax, count
	mov edx ,0
	mov ecx,2
	div ecx
	cmp edx,0
	je face_x2
	make_text_macro1 'O',area,300,114
	mov var2,0
	call verificare
	jmp final
	face_x2:
	make_text_macro 'X',area,300,114
	mov var2,1
	call verificare
	jmp final
desen3:
	cmp var3,2
	jne final
	inc count
	mov eax, count
	mov edx ,0
	mov ecx,2
	div ecx
	cmp edx,0
	je face_x3
	make_text_macro1 'O',area,430,114
	mov var3,0	
	call verificare
	jmp final
	face_x3:
	make_text_macro 'X',area,430,114
	mov var3,1
	call verificare
	jmp final
desen4:
	cmp var4,2
	jne final
	inc count
	mov eax, count
	mov edx ,0
	mov ecx,2
	div ecx
	cmp edx,0
	je face_x4	
	make_text_macro1 'O', area, 160 , 210
	mov var4,0
	call verificare
	jmp final
	face_x4:
	make_text_macro 'X', area, 160 , 210
	mov var4,1
	call verificare
	jmp final
desen5:
	cmp var5,2
	jne final
	inc count
	mov eax, count
	mov edx ,0
	mov ecx,2
	div ecx
	cmp edx,0
	je face_x5
	make_text_macro1 'O', area, 300 , 210
	mov var5,0
	call verificare
	jmp final
	face_x5:
	make_text_macro 'X', area, 300, 210
	mov var5,1
	call verificare
	jmp final
desen6:
	cmp var6,2
	jne final
	inc count
	mov eax, count
	mov edx ,0
	mov ecx,2
	div ecx
	cmp edx,0
	je face_x6
	make_text_macro1 'O', area, 430 , 210
	mov var6,0
	call verificare
	jmp final
	face_x6:
	make_text_macro 'X', area, 430, 210
	mov var6,1
	call verificare
	jmp final
desen7:
	cmp var7,2
	jne final
	inc count
	mov eax, count
	mov edx ,0
	mov ecx,2
	div ecx
	cmp edx,0
	je face_x7
	make_text_macro1 'O', area, 160, 315
	mov var7,0
	call verificare
	jmp final
	face_x7:
	make_text_macro 'X', area, 160, 315
	mov var7,1
	call verificare
	jmp final
desen8:
	cmp var8,2
	jne final
	inc count
	mov eax, count
	mov edx ,0
	mov ecx,2
	div ecx
	cmp edx,0
	je face_x8
	make_text_macro1 'O', area, 300,315
	mov var8,0
	call verificare
	jmp final
	face_x8:
	make_text_macro 'X', area,300,315
	mov var8,1
	call verificare
	jmp final
desen9:
	cmp var9,2
	jne final
	inc count
	mov eax, count
	mov edx ,0
	mov ecx,2
	div ecx
	cmp edx,0
	je face_x9
	make_text_macro1 'O', area, 430, 315
	mov var9,0
	call verificare
	jmp final
	face_x9:
	make_text_macro 'X', area,  430, 315
	mov var9,1
	call verificare
	
	
final:
	
afisare_litere:
	
	push dword ptr 400 	;x
	push dword ptr 75	;y
	push dword ptr 100	;lungime-cat de in stanga sau in drepta
	call linieOrizontala
	add esp, 12
	
	push dword ptr 400
	push dword ptr 175
	push dword ptr 100 
	call linieOrizontala
	add esp, 12
	
	push dword ptr 400
	push dword ptr 275
	push dword ptr 100
	call linieOrizontala
	add esp, 12
	
	push dword ptr 400
	push dword ptr 375
	push dword ptr 100
	call linieOrizontala
	add esp, 12
	
	push dword ptr 300 ;cat de inalta
	push dword ptr 76 ;cat de jos,cat de sus
	push dword ptr 100 ;latimea patratului
	call linieVerticala
	add esp, 12
	
	push dword ptr 300
	push dword ptr 76
	push dword ptr 232
	call linieVerticala
	add esp, 12
	
	push dword ptr 300
	push dword ptr 76
	push dword ptr 368
	call linieVerticala
	add esp, 12
	
	push dword ptr 300
	push dword ptr 76
	push dword ptr 500
	call linieVerticala
	add esp, 12
	
	;pentru tabelul mic->care tine scorul
	;tine evidenta pentru scorul general (x,y),de cate ori a castigat x,de cate ori a castigat y
	
	
	push dword ptr 110 ;dimensiunea
	push dword ptr 530 ;cat de jos,cat de sus
	push dword ptr 350 ;cat de in stanga,cat de in drepta
	call linieOrizontala
	add esp,12
	
	push dword ptr 110
	push dword ptr 500
	push dword ptr 350
	call linieOrizontala
	add esp,12
	
	push dword ptr 80
	push dword ptr 500
	push dword ptr 350
	call linieVerticala
	add esp,12
	
	push dword ptr 80 ;cat de inalta
	push dword ptr 500 ;cat de jos,cat de sus
	push dword ptr 460 ;latimea patratului
	call linieVerticala
	add esp, 12
	
	push dword ptr 80
	push dword ptr 500
	push dword ptr 405
	call linieVerticala
	add esp,12
	
	push dword ptr 110
	push dword ptr 580
	push dword ptr 350
	call linieOrizontala
	add esp,12
	
	make_text_macro 'X', area, 375, 505
	make_text_macro '0', area, 425, 505
	
	popa; scoate de pe stiva toti registrii
	mov esp, ebp
	pop ebp
	ret ; scoate adresa de revenire
draw endp


start:
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	call malloc
	add esp, 4
	mov area, eax
	;apelam functia de desenare a ferestrei
	; typedef void (*DrawFunc)(int evt, int x, int y);
	; void __cdecl BeginDrawing(const char *title, int width, int height, unsigned int *area, DrawFunc draw);
	push offset draw
	push area
	push area_height
	push area_width
	push offset window_title
	call BeginDrawing
	add esp, 20
	
	;terminarea programului
	push 0
	call exit
end start
