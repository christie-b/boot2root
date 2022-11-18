# DirtyCOW Exploit

When connected to laurie through SSH, we can check the kernel version, which is `3.2.0`.  
```
laurie@BornToSecHackMe:~$ uname -r
3.2.0-91-generic-pae
```

This version is prone to a vulnerability, through the DirtyCow exploit.  
<!-- https://www.exploit-db.com/exploits/40839 -->

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
We can then modify the `/etc/passwd` file.  
This exploit replaces in `/etc/passwd` the user `root` by a new user called `firefart`, with a new password (set as `root` in the exploit).  