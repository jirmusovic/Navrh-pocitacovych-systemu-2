; Autor reseni: Veronika Jirmusova  xjirmu00

; Projekt 2 - INP 2022
; Vernamova sifra na architekture MIPS64
; xjirmu00-r10-r28-r15-r17-r0-r4

; DATA SEGMENT
                .data
login:          .asciiz "xjirmu00"  ; sem doplnte vas login
key:            .asciiz "ji"        ; sifrovaci klic
cipher:         .space  17          ; misto pro zapis sifrovaneho loginu
plot:           .asciiz "az"

params_sys5:    .space  8           ; misto pro ulozeni adresy pocatku
                                    ; retezce pro vypis pomoci syscall 5
                                    ; (viz nize "funkce" print_string)

; CODE SEGMENT
                .text

                
main:
                xor     r10, r10, r10
                xor     r15, r15, r15

                daddi   r15, r0, login
                daddi   r17, r0, cipher
        magic:
                jal     is_number   ;overeni cisla + nacteni prvniho znaku loginu
                bnez    r10, end_magic
                sb      r28, 0(r17)
                



                daddi   r15, r15, 1
                daddi   r17, r17, 1
                jal     is_number   ;overeni cisla + nacteni prvniho znaku loginu
                bnez    r10, end_magic
                sb      r28, 0(r17)




                daddi   r15, r15, 1
                daddi   r17, r17, 1
                b       magic
        end_magic:
                daddi    r4, r0, cipher
                jal     print_string    ; vypis pomoci print_string - viz nize


                syscall 0   ; halt


is_number:

                lb      r28, 0(r15)
                daddi   r10, r0, plot   
                lb      r10, 0(r10)   

                slt     r10, r28, r10
                jr      r31

               



print_string:   ; adresa retezce se ocekava v r4
                sw      r4, params_sys5(r0)
                daddi   r14, r0, params_sys5    ; adr pro syscall 5 musi do r14
                syscall 5   ; systemova procedura - vypis retezce na terminal
                jr      r31 ; return - r31 je urcen na return address
