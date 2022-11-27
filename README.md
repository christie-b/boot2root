# Boot2root

Exploit an ISO and become root, 2 different methods must be found for the mandatory part, and the ISO cannot be modified.
## Introduction
[Penetration testing](https://en.wikipedia.org/wiki/Penetration_test) or Pen testing is a security exercise where a cyber-security expert attempts to find and exploit vulnerabilities in a computer system. The purpose of this simulated attack is to identify any weak spots in a system’s defenses which attackers could take advantage of.
## Writeups
We found 5 methods to root the machine, 1 writeup is given for each solution. Here is a list of the topics (be sure to check the writeup files to get the details of each step).
### Writeup 1: The "normal" way
- Reconnaissance phase
- HTTP enumeration
- Exploiting a file upload vulnerability
- Obtain credentials by scouting the machine
- Investigate on clues left in the machine
- Exploit a binary to pop a root shell
##### Note
From now on, we can reuse credentials found by our scouting phase done earlier to obtain an SSH access without the need to perform those operations again.
### Writeup 2: Create a root user
- From the scouting phase, we had some information about the OS of our target, the kernel is a linux, version <4.8.3
- Those versions are affected by the *Dirty COW* vulnerability 
- Send the file `scripts/script2` on the target machine via the `scp` protocol
- This script will exploit a race condition in order to perform a privilege escalation, we will be able to write where we normally can't
- The password is **infected**
### Writeup 3: Edit the init script via GRUB
- Holding Shift during boot can bring up the GRUB menu
- Edit the init script for our live device `live init=/bin/sh`
- The device will boot and give us a root shell since the init daemon will execute `/bin/sh`
### Writeup 4: Change the password of root
- This _exploit_ uses the _pokemon exploit_ of the dirtycow vulnerability
- Send the file `scripts/script4` on the target machine via the `scp` protocol
- Wait until the script completes, the password of _root_ will be changed to **root**
### Writeup 5: Hide a sudo user
- A user will get his privileges raised
- To do so, we will exploit a binary with an **obfuscated** **polymorphed** shellcode, since we need to overcome the restrictions of the binary
- This user will be hidden in a non-conventional place `/etc/sudoers.d/README` this file is interpreted and is a **valid** place to hide sudo users
