# 1 - Find the VM IP address

```
➜  ~ ifconfig

vboxnet0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 192.168.56.1  netmask 255.255.255.0  broadcast 192.168.56.255
        inet6 fe80::800:27ff:fe00:0  prefixlen 64  scopeid 0x20<link>
        ether 0a:00:27:00:00:00  txqueuelen 1000  (Ethernet)
        RX packets 0  bytes 0 (0.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 1468  bytes 300542 (300.5 KB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

```

-> VirtualBox ip address is 192.168.56.1, with a /24 submask.
Let's use nmap to see what hosts are available on this network.
```
┌──(kali㉿kali)-[~]
└─$ nmap 192.168.56.0-255
Starting Nmap 7.92 ( https://nmap.org ) at 2022-11-15 09:11 EST
Nmap scan report for e3r13p6.clusters.42paris.fr (192.168.56.1)
Host is up (0.0021s latency).
Not shown: 994 closed tcp ports (conn-refused)
PORT      STATE SERVICE
22/tcp    open  ssh
111/tcp   open  rpcbind
2049/tcp  open  nfs
5900/tcp  open  vnc
9100/tcp  open  jetdirect
34571/tcp open  unknown

Nmap scan report for 192.168.56.105
Host is up (0.0023s latency).
Not shown: 994 closed tcp ports (conn-refused)
PORT    STATE SERVICE
21/tcp  open  ftp
22/tcp  open  ssh
80/tcp  open  http
143/tcp open  imap
443/tcp open  https
993/tcp open  imaps

Nmap done: 256 IP addresses (2 hosts up) scanned in 2.81 seconds
```  
-> We know that virtualbox is running on 192.168.56.1, so the VM is running on 192.168.56.105.

-> we see that there are 2 http ports.

# 2 - Find the directories of the website

Let's run dirb to see what urls exist.

```
┌──(kali㉿kali)-[~]
└─$ dirb http://192.168.56.105 -rSwN 403 

-----------------
DIRB v2.22    
By The Dark Raver
-----------------

START_TIME: Tue Nov 15 11:03:23 2022
URL_BASE: http://192.168.56.105/
WORDLIST_FILES: /usr/share/dirb/wordlists/common.txt
OPTION: Ignoring NOT_FOUND code -> 403
OPTION: Not Recursive
OPTION: Silent Mode
OPTION: Not Stopping on warning messages

-----------------

GENERATED WORDS: 4612

---- Scanning URL: http://192.168.56.105/ ----
==> DIRECTORY: http://192.168.56.105/fonts/
+ http://192.168.56.105/index.html (CODE:200|SIZE:1025)

-----------------
END_TIME: Tue Nov 15 11:03:25 2022
DOWNLOADED: 4612 - FOUND: 1

===============================

┌──(kali㉿kali)-[~]
└─$ dirb https://192.168.56.105 -rSwN 403

-----------------
DIRB v2.22    
By The Dark Raver
-----------------

START_TIME: Tue Nov 15 10:50:46 2022
URL_BASE: https://192.168.56.105/
WORDLIST_FILES: /usr/share/dirb/wordlists/common.txt
OPTION: Ignoring NOT_FOUND code -> 403
OPTION: Not Recursive
OPTION: Silent Mode
OPTION: Not Stopping on warning messages

-----------------

GENERATED WORDS: 4612

---- Scanning URL: https://192.168.56.105/ ----
==> DIRECTORY: https://192.168.56.105/forum/
==> DIRECTORY: https://192.168.56.105/phpmyadmin/
==> DIRECTORY: https://192.168.56.105/webmail/

-----------------
END_TIME: Tue Nov 15 10:50:48 2022
DOWNLOADED: 4612 - FOUND: 0

```

# 3 - /forum

Let's check the forum url:
- we see 6 users, admin, lmezard, qudevide, zaz, wandre and thor.
- There is a log file, where we can see different login attempts. One is successful, and we can see the password:  
```
Oct 5 08:45:29 BornToSecHackMe sshd[7547]: Failed password for invalid user !q\]Ej?*5K5cy*AJ from 161.202.39.38 port 57764 ssh2
Oct 5 08:45:29 BornToSecHackMe sshd[7547]: Received disconnect from 161.202.39.38: 3: com.jcraft.jsch.JSchException: Auth fail [preauth]
Oct 5 08:46:01 BornToSecHackMe CRON[7549]: pam_unix(cron:session): session opened for user lmezard by (uid=1040)
```

-> login : `lmezard`
password: `!q\]Ej?*5K5cy*AJ`

When we log in with these credentials, we find her email address: `laurie@borntosec.net`

# 4 - /webmail

We can use the same credentials to log into her email account.  
We can find the root credentials for phpmyadmin in one of her emails.  

```
Hey Laurie,

You cant connect to the databases now. Use root/Fg-'kKXBj87E:aJ$

Best regards.
```

# phpmyadmin

When we log into the website, we see a database with hashed passwords  
![hashed_pwd](./misc/Screenshot%20from%202022-11-16%2014-23-21.png)  

All the database start with `mlf2_`, and we can see on the forum page, that the website is powered by my little forum.  
By digging on the github repo, we can find the following function:  
`https://github.com/ilosuna/mylittleforum/blob/c1617a7aa07472cefa2249147b2dc79dc864f7a4/includes/functions.inc.php`  

```
function generate_pw_hash($pw)
 {
  $salt = random_string(10,'0123456789abcdef');
  $salted_hash = sha1($pw.$salt);
  $hash_with_salt = $salted_hash.$salt;
  return $hash_with_salt;
 }
```
