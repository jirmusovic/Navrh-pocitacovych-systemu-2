; Autor reseni: Veronika Jirmusova  xjirmu00

; Projekt 2 - INP 2022
; Vernamova sifra na architekture MIPS64
; xjirmu00-r10-r28-r15-r17-r0-r4

; DATA SEGMENT
                .data
login:          .asciiz "xjirmu00"  ; sem doplnte vas login
key:            .asciiz "ji"        ; sifrovaci klic
cipher:         .space  17          ; misto pro zapis sifrovaneho loginu
stahp:          .asciiz "az"        ; ohraniceni pismen

params_sys5:    .space  8           ; misto pro ulozeni adresy pocatku
                                    ; retezce pro vypis pomoci syscall 5
                                    ; (viz nize "funkce" print_string)

; CODE SEGMENT
                .text

                
main:
        key_check:                      ; je potreba zmenit ascii hodnoty klice do rozmezi a-z
                daddi   r17, r0, key    ; key v r17
                lb      r28, 0(r17)     ; prvni byte z klice do r28
                daddi   r10, r0, stahp  ; presouvam az
                lb      r10, 0(r10)     ; nacteni a do r10
                sub     r28, r28, r10   ; odecteni hodnoty a od klice
                daddi   r28, r28, 1     ; pricteni 1 kvuli hranicim
                sb      r28, 0(r17)     ; ulozeni nove hodnoty klice zpet

                lb      r28, 1(r17)     ; prakticky to same, akorat se z
                daddi   r10, r0, stahp
                lb      r10, 0(r10)
                sub     r28, r28, r10
                daddi   r28, r28, 1
                sb      r28, 1(r17)     ; klic je komplet novy


                xor     r10, r10, r10
                xor     r15, r15, r15   ; cisteni registru

                daddi   r15, r0, login  ; login do r15
                daddi   r4, r0, cipher  ; sifra do r4

                
        magic:
                jal     is_number       ; overeni cisla + nacteni prvniho znaku loginu
                bnez    r10, end_magic  ; pokud je overeny znak cislo, vypis zasifrovane slovo a ukonci program
                daddi   r17, r0, key    ; nahrani klice
                lb      r17, 0(r17)     ; prvni byte z klice
                lb      r10, 0(r15)     ; prvni byte z loginu
                add     r28, r10, r17   ; sectu byte loginu a byte sifry
                jal     overflow_check  ; stavim abecedy za sebe tak, aby a predchazelo z a z nasledovalo a
                sb      r28, 0(r4)      ; store
                



                daddi   r15, r15, 1
                daddi   r4, r4, 1       ; inc r17 a r15 (posuneme se na dalsi byte)
                jal     is_number       ; overeni cisla + nacteni noveho prvniho znaku loginu
                bnez    r10, end_magic  ; opet koncime magii, pokud narazime na cislo
                daddi   r17, r0, key    
                lb      r17, 1(r17)     ; nacteni druheho bytu z klice
                lb      r10, 0(r15)
                sub     r28, r10, r17   ; odecteni klice od sudych pismen sifrovaneho slova
                jal     overflow_check
                sb      r28, 0(r4)   




                daddi   r15, r15, 1
                daddi   r4, r4, 1
                b       magic           ; loop magie do konce slova
        end_magic:
                daddi   r4, r0, cipher  ; do r4 nahrajeme vyslednou sifru
                jal     print_string    ; vypis pomoci print_string - viz nize


                syscall 0   ; halt


is_number:
                                                ; check sifrovaneho slova, aby ukoncil akci, kdyz narazi na cislo
                lb      r28, 0(r15)
                daddi   r10, r0, stahp          ; ohraniceni a-z
                lb      r10, 0(r10)   

                slt     r10, r28, r10           ; do r10 nacteme vysledek porovnani
                jr      r31                     ; jump back

;;;;;;;NEPREPISOVAT r4 A r15 prosim
overflow_check:                                 ; kruhovy buffer
                daddi      r10, r0, stahp
                lb         r10, 0(r10)
                ;;;;;;;;;;;  1  sif < a
                ;;;;;;;;;;   0  sif >= a
                slt        r10, r28, r10
                beqz       r10, great
                daddi      r28, r28, 26         ; pricitame, pokud je mensi nez a

        great:                                  
                daddi      r10, r0, stahp
                lb         r10, 1(r10)
                ;;;;;;;;;;;  1   z   < sif
                ;;;;;;;;;;   0   z   >= sif
                slt        r10, r10, r28
                beqz       r10, continue
                daddi      r28, r28, -26         ; odcitame, pokud je vetsi nez z

        continue:
                jr      r31







print_string:   ; adresa retezce se ocekava v r4
                sw      r4, params_sys5(r0)
                daddi   r14, r0, params_sys5    ; adr pro syscall 5 musi do r14
                syscall 5   ; systemova procedura - vypis retezce na terminal
                jr      r31 ; return - r31 je urcen na return address

;end of xjirmu00