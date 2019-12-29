
;Micut Andrei-Ion, Grupa 321CB

%include "includes/io.inc"

extern getAST
extern freeAST

; structura unui nod din arbore
struc Node
    data: resd 1
    left: resd 1
    right: resd 1
endstruc

section .bss
    ; La aceasta adresa, scheletul stocheaza radacina arborelui
    root: resd 1

section .text
global main

; functie ce primeste un sir de caractere si returneaza numarul
; reprezentat de acesta: int get_number(char *str);
get_number:
    push ebp
    mov ebp, esp

    ; punem in edi parametrul functiei (sirul de caractere)
    mov edi, [esp + 8]
    mov edi, [edi]

    ; in eax o sa se afle numarul final
    xor eax, eax
    ; ecx marcheaza semnul: 1 pentru pozitiv, -1 pentru negativ
    mov ecx, 1

    ; daca numarul este negativ se modifica ecx, altfel se trece
    ; direct la parcurgerea sirului de caractere si obtinerea nr
    cmp byte [edi], '-'
    jne get_number_loop

get_number_is_negative:
    inc edi
    mov ecx, -1

    ; echivalentul while (*str) { ...; ++ str;}
get_number_loop:
    ; se iese din loop daca am atins finalul sirului
    cmp byte [edi], 0
    je get_number_loop_end

    ; se pune in ebx cifra curenta (*str - '0')
    xor ebx, ebx
    mov bl, byte [edi]
    sub bl, '0'

    ; si se adauga la numarul deja existent (nr * 10 + cifra)
    imul eax, 10
    add eax, ebx

    ; se avanseaza in sir (++ str)
    inc edi
        
    jmp get_number_loop

get_number_loop_end:
    ; ii dam si semnul numarului (daca este pozitiv se inmulteste
    ; cu 1, deci nicio schimbare)
    imul eax, ecx

    leave
    ret

; functie ce returneaza rezultatul aplicarii unei functii asupra
; a doi operanzi: int compute_operation(int op1, int op2, char operand)
compute_operation:
    push ebp
    mov ebp, esp

    ; in edi se afla operandul
    mov edi, [esp + 8]
    ; in eax si ebx se pun parametrii operatiei
    mov ebx, [esp + 12]
    mov eax, [esp + 16]

    ; se determina tipul operatiei
    cmp byte [edi], '+'
    je addition

    cmp byte [edi], '-'
    je substraction

    cmp byte [edi], '/'
    je division

multiplication:
    imul eax, ebx
    jmp compute_operation_end

addition:
    add eax, ebx
    jmp compute_operation_end

substraction:
    sub eax, ebx
    jmp compute_operation_end

division:
    cdq
    idiv ebx
    jmp compute_operation_end

compute_operation_end:
    leave
    ret

; functie recursiva ce parcurge arborele AST si calculeaza rezultatul
; int solve(struct Node *root)
solve:
    push ebp
    mov ebp, esp

    ; se obtine parametrul (nodul curent din arbore)
    mov eax, [esp + 8]

    ; se verifica daca nodul este frunza (in acest caz este un numar)
    cmp dword [eax + left], 0
    jne operator_node

number_node:
    ; nodul este frunza == numar, se obtine numarul si se returneaza
    push dword eax
    call get_number
    add esp, 4

    jmp solve_end

operator_node:
    ; se salveaza nodul pe stiva
    push eax

    ; se apeleaza solve(root->left)
    push dword [eax + left]
    call solve
    add esp, 4

    ; se obtine nodul curent de pe stiva
    pop ebx
    ; se salveaza rezultatul returnat de solve(root->left)
    push eax
    ; si se salveaza iarasi nodul :/
    push ebx

    ; se apeleaza solve(root->right)
    push dword [ebx + right]
    call solve
    add esp, 4

    ; se scoate nodul de pe stiva
    pop ebx
    ; se pune pe stiva si rezultatul returnat de solve(root->right)
    push eax

    ; am obtinut rezultatele din cei doi subarbori, calculam rezultatul
    ; acestui subarbore 
    push dword [ebx + data]
    call compute_operation
    add esp, 12

solve_end:
    leave
    ret

main:
    ; NU MODIFICATI
    push ebp
    mov ebp, esp
    
    ; Se citeste arborele si se scrie la adresa indicata mai sus
    call getAST
    mov [root], eax

    ; Implementati rezolvarea aici:

    ; se pune nodul radacina pe stiva si se apeleaza solve(root)
    push dword [root]
    call solve
    add esp, 4

    ; se afiseaza rezultatul
    PRINT_DEC 4, eax

    ; NU MODIFICATI
    ; Se elibereaza memoria alocata pentru arbore
    push dword [root]
    call freeAST
    add esp, 4

    xor eax, eax
    leave
    ret