# DirtyCOW Exploit

When connected to laurie through SSH, we can check the kernel version, which is `3.2.0`.  
```
laurie@BornToSecHackMe:~$ uname -r
3.2.0-91-generic-pae
```

This version is prone to a vulnerability, through the DirtyCow exploit.  

// https://www.exploit-db.com/exploits/40839  

# Steps

We copie the exploit binary, which contains the Dirty Cow exploit, into Laurie's home.  
`scp exploit laurie@192.168.56.105:/home/laurie`

Then, we execute it. After some time, we gain root access:  
```
laurie@BornToSecHackMe:~$ ./exploit
[...]
Password:
root

firefart@BornToSecHackMe:/home/laurie# id
uid=0(firefart) gid=0(root) groups=0(root)
```

# Exploit explanation

There is a race condition in the implementation of the copy-on-write (COW) mechanism in the kernel's memory-management subsystem.  
Because of the race condition, with the right timing, a local attacker can exploit the copy-on-write mechanism to turn a read-only mapping of a file into a writable mapping.  

There are 3 steps:  
- Make a copy of the mapped memory
- Update the page table, so the virtual memory points to
copied memory
- Write to the memory

`madvise` tells the kernel that we do not need the claimed part of the address any more. The kernel will free the resource of the claimed address and the process’s page table will point back to the original physical memory. 
It is used between the 2nd and 3rd step:  
- the 2nd step will make the virtual memory point to the copied memory
- `madvise` will change it back to the original physical memory
- the 3rd step will modify the original physical memory instead of the private copy.

We can therefore modify the `/etc/passwd` file.  
This exploit replaces in `/etc/passwd` the user `root` by a new user called `firefart`, with a new password (set as `root` in the exploit).  

![dirty_cow](/misc/dirty_cow.png)  
https://fengweiz.github.io/19fa-cs315/slides/lab9-slides-dirty-cow.pdf