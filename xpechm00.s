; Vernamova sifra na architekture DLX
; Martin Pech xpechm00

        .data 0x04          ; zacatek data segmentu v pameti
login:  .asciiz "xpechm00"  ; <-- nahradte vasim loginem
cipher: .space 9 ; sem ukladejte sifrovane znaky (za posledni nezapomente dat 0)

        .align 2            ; dale zarovnavej na ctverice (2^2) bajtu
laddr:  .word login         ; 4B adresa vstupniho textu (pro vypis)
caddr:  .word cipher        ; 4B adresa sifrovaneho retezce (pro vypis)

        .text 0x40          ; adresa zacatku programu v pameti
        .global main        ; 

main:   ; sem doplnte reseni Vernamovy sifry dle specifikace v zadani
	;ROZDĚLENÍ REGISTRŮ
	;r1 ====> programový čítač
	;r9 ====> ukládání výsledku
	;r15 ===> čítač znaků
	;r20 ===> pracovní registr
	;r27 ===> načítaná data

	j init			;inicializace registrů

loop:
	nop
	lb r27, login(r15)	;načtení znaku z paměti (login)
	
	addi r20, r0, 97	;načtení ascii hodnoty prvního znaku (a)
	sgt r9, r20, r27	;pokud je načtený znak číslo (<97)
	bnez r9, final		;skoč na konec

	sgt r9, r1, r0		;pokud je čítač 0
	bnez r9, odd		;pokračuj, jinak skoč

even:	;řešení sudých čísel - přičtení p (+16)
	nop			;useless maybe?
	addi r9, r27, 16	;šifrování sudého čísla +16 (p)
	xor r20, r20, r20	
	addi r20, r0, 122	;načtení 'z'
	sgt r27, r9, r20	;když dojde k přetečení
	bnez r27, more		;přičítej od začátku
	sb cipher(r15), r9	;
	j nextStage

odd:	;řešení lichých čísel - odečtení e (-5)
	nop
	subi r9, r27, 5		;odečítání šifrovacího klíče
	sgt r27, r20, r9	
	bnez r27, less
	sb cipher(r15), r9
	j nextStage

more:	;přetečení posunu vpravo přes znak (z)
	nop
	subi r9, r9, 26
	sb cipher(r15), r9
	j nextStage
	
less:	;podtečení posunu vlevo pod znak (a)
	nop
	addi r9, r9, 26
	sb cipher(r15), r9
	j nextStage

nextStage:	;inkrementace čítače, zpracování výsledku
	nop
	addi r15, r15, 1
	sgt r9, r1, r0
	bnez r9, resetCounter
	addi r1, r1, 1
	j loop
	
resetCounter:	;reset čítače
	nop
	xor r1, r1, r1
	j loop

init: 
	nop
	xor r1, r1, r1		;Nulování registrů
	xor r9, r9, r9
	xor r15, r15, r15
	j loop

final: 				;Finalizování výstupu
	nop
	addi r15, r15, 1
	sb cipher(r15), r0	
	j end

end:    
	addi r14, r0, caddr ; <-- pro vypis sifry nahradte laddr adresou caddr
        trap 5  ; vypis textoveho retezce (jeho adresa se ocekava v r14)
        trap 0  ; ukonceni simulace
