From: Mikulas Patocka <mpatocka@redhat.com>
Date: Tue, 14 Jul 2009 20:31:06 -0400 (EDT)
Subject: crash in dmeventd
Message-ID: <Pine.LNX.4.64.0907141942420.6368@hs20-bc2-1.build.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

I got another crash, when attempting to deactivate snapshot, origin and 
two mirrors at once. It seems like there are multiple bugs in dmeventd and 
it never worked in upstream code at all, you need to assign it to somebody 
to fix it.

Mikulas


(gdb) run -d
Starting program: /usr/src/LVM2.2.02.48/daemons/dmeventd/dmeventd -d
[Thread debugging using libthread_db enabled]
[New Thread 0xf7f726b0 (LWP 11031)]
[New Thread 0xf7b9ab90 (LWP 11053)]
[New Thread 0xf7b3ab90 (LWP 11072)]
[New Thread 0xf7aeeb90 (LWP 11073)]
[New Thread 0xf7aa2b90 (LWP 11092)]
[Thread 0xf7b9ab90 (LWP 11053) exited]
You have a memory leak (not released memory pool):
 [0x2a288]
 [0x29cd8]
 [0x29d20]
 [0x29d68]
 [0x29db0]
 [0x2a020]
 [0x2a068]
 [0x41640]
[Thread 0xf7aeeb90 (LWP 11073) exited]
device-mapper: waitevent ioctl failed: Bad file descriptor

Program received signal SIGSEGV, Segmentation fault.
[Switching to Thread 0xf7aa2b90 (LWP 11092)]
0xf7b3c9fc in ?? ()
(gdb) bt
#0  0xf7b3c9fc in ?? ()
#1  0xf7bffb18 in print_log (level=6, file=0xf7c735b8 "mm/memlock.c", 
line=118,
    format=0xf7c73648 "Unlocking memory") at log/log.c:172
#2  0xf7c22338 in _unlock_mem () at mm/memlock.c:118
#3  0xf7c22508 in memlock_dec () at mm/memlock.c:136
#4  0xf7c66984 in lvm2_run (handle=0x2ad90, cmdline=0xf7ca5c38 
"_memlock_dec") at lvmcmdlib.c:87
#5  0xf7ca5838 in unregister_device (device=0x2a308 "vg1-m",
    uuid=0x6ff90 
"LVM-VOPJIMgCzp0x7r0a2Yi8O2xLd8mteXYRgTM5gQeKumcDlvMPxa3S4Z36BpXsdgYH",
    major=254, minor=15, unused=0x6fee8) at dmeventd_mirror.c:288
#6  0x00013494 in _do_unregister_device (thread=0x6fea0) at dmeventd.c:664
#7  0x00013514 in _monitor_unregister (arg=0x6fea0) at dmeventd.c:682
#8  0x00013998 in _monitor_thread (arg=0x6fea0) at dmeventd.c:805
#9  0xf7ed6bfc in start_thread () from /lib/libpthread.so.0
#10 0xf7d9fbbc in ?? () from /lib/libc.so.6
#11 0xf7d9fbbc in ?? () from /lib/libc.so.6
Backtrace stopped: previous frame identical to this frame (corrupt stack?)
(gdb)



