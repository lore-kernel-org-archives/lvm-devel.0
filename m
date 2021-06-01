From: Wu Guanghao <wuguanghao3@huawei.com>
Date: Tue, 1 Jun 2021 16:14:39 +0800
Subject: [PATCH]pvchange: Fix the deadlock problem
Message-ID: <eed37eea-bf93-158e-6366-cc6e338851c8@huawei.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

I found a deadlock problem during testing?the reason is that the pvchange command
did not acquire the global lock first.


The process 143116 obtains the global lock, it tries to obtain the hint file lock;
The process 143112 obtains the hint file lock, it tries to obtain the global lock.
Two processes formed a deadlock.

# gdb attach 143116
0x0000ffffae5e5754 in flock () from /usr/lib64/libc.so.6
(gdb) bt
#0  0x0000ffffae5e5754 in flock () from /usr/lib64/libc.so.6
#1  0x0000aaaaade66a1c in _lock_hints (mode=mode at entry=2, nonblock=nonblock at entry=0, cmd=0xaaaaebd61a60) at label/hints.c:320
#2  0x0000aaaaade68054 in _lock_hints (nonblock=0, mode=2, cmd=0xaaaaebd61a60) at label/hints.c:1097
#3  clear_hint_file (cmd=cmd at entry=0xaaaaebd61a60) at label/hints.c:1091
#4  0x0000aaaaade2e9bc in vgreduce (cmd=0xaaaaebd61a60, argc=1, argv=0xffffefe1bd98) at vgreduce.c:227
#5  0x0000aaaaade062b8 in lvm_run_command (cmd=cmd at entry=0xaaaaebd61a60, argc=<optimized out>, argc at entry=3, argv=<optimized out>, argv at entry=0xffffefe1bd88) at lvmcmdline.c:3131
#6  0x0000aaaaade072e8 in lvm2_main (argc=3, argv=0xffffefe1bd88) at lvmcmdline.c:3661
#7  0x0000ffffae541f80 in __libc_start_main () from /usr/lib64/libc.so.6
#8  0x0000aaaaadde4434 in _start ()

# gdb attach 143112
0x0000ffffaf52e754 in flock () from /usr/lib64/libc.so.6
(gdb) bt
#0  0x0000ffffaf52e754 in flock () from /usr/lib64/libc.so.6
#1  0x0000aaaabf0a3d80 in _do_flock (file=file at entry=0xffffc4da6a68 "/run/lock/lvm/P_global", fd=fd at entry=0xaaaad30eb6e0, operation=operation at entry=1, nonblock=nonblock at entry=0) at misc/lvm-flock.c:129
...
#11 0x0000aaaabefcb1b8 in pvchange (cmd=0xaaaad2fd3a60, argc=1, argv=0xffffc4da85f0) at pvchange.c:237
#12 0x0000aaaabefc62b8 in lvm_run_command (cmd=cmd at entry=0xaaaad2fd3a60, argc=<optimized out>, argc at entry=4, argv=<optimized out>, argv at entry=0xffffc4da85d8) at lvmcmdline.c:3131
#13 0x0000aaaabefc72e8 in lvm2_main (argc=4, argv=0xffffc4da85d8) at lvmcmdline.c:3661
#14 0x0000ffffaf48af80 in __libc_start_main () from /usr/lib64/libc.so.6
#15 0x0000aaaabefa4434 in _start ()

# cat /proc/locks
1: FLOCK  ADVISORY  WRITE 143116 00:16:206122 0 EOF
1: -> FLOCK  ADVISORY  READ  143120 00:16:206122 0 EOF
1: -> FLOCK  ADVISORY  READ  143121 00:16:206122 0 EOF
1: -> FLOCK  ADVISORY  WRITE 143117 00:16:206122 0 EOF
1: -> FLOCK  ADVISORY  READ  143112 00:16:206122 0 EOF
...
6: FLOCK  ADVISORY  WRITE 143112 00:16:929 0 EOF
6: -> FLOCK  ADVISORY  WRITE 143116 00:16:929 0 EOF

# ls -li /run/lock/lvm/P_global
206122 -rwx------. 1 root root 0 May 29 18:10 /run/lock/lvm/P_global
# ls -li /run/lvm/hints
929 -rw-------. 1 root root 64 May 29 18:10 /run/lvm/hints

Signed-off-by: Wu Guanghao <wuguanghao3@huawei.com>
---
 tools/pvchange.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/tools/pvchange.c b/tools/pvchange.c
index d6e35d66f..6b4fa45b8 100644
--- a/tools/pvchange.c
+++ b/tools/pvchange.c
@@ -248,6 +248,9 @@ int pvchange(struct cmd_context *cmd, int argc, char **argv)

 	set_pv_notify(cmd);

+	if (!lock_global(cmd, "ex"))
+		return_ECMD_FAILED;
+
 	clear_hint_file(cmd);

 	ret = process_each_pv(cmd, argc, argv, NULL, 0, READ_FOR_UPDATE, handle, _pvchange_single);
-- 

Regards

Wu Guanghao



