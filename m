From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 9 Feb 2018 05:01:33 -0500
Subject: master - toolcontext: do not change stream for pthreaded programs
Message-ID: <201802091001.w19A1XQ6011094@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=83258e33852166a3111a009f1720cc87f62efc73
Commit:        83258e33852166a3111a009f1720cc87f62efc73
Parent:        1b6d0346a37d34394471080ec2aff55cea1bdafe
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Feb 9 00:26:22 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Feb 9 10:56:40 2018 +0100

toolcontext: do not change stream for pthreaded programs

With pthreaded daemons like 'dmeventd' using  liblvm via plugin,
lvm2 actually should not 'play' with streams at all - as there
could be parallel outputs running.

As a current quick workaround just disable change for pthreaded
program (gettid() != getpid()).

TODO: it's possible the change of buffering actually doesn't serve us
any measurable benefit and could be dropped as whole later...

Meanwhile this patch is fixing this occasional valgrind race report:

Invalid read of size 4
   at 0x571892C: vfprintf (in /usr/lib64/libc-2.26.9000.so)
   by 0x57216B3: fprintf (in /usr/lib64/libc-2.26.9000.so)
   by 0x5042886: dm_event_log (libdevmapper-event.c:925)
   by 0x10B015: _dmeventd_log (dmeventd.c:125)
   by 0x10D289: _unregister_for_event (dmeventd.c:1146)
   by 0x10E52E: _handle_request (dmeventd.c:1583)
   by 0x10E6D7: _do_process_request (dmeventd.c:1631)
   by 0x10E7C6: _process_request (dmeventd.c:1660)
   by 0x1101A4: main (dmeventd.c:2285)
 Address 0x6264d30 is 192 bytes inside a block of size 552 free'd
   at 0x4C2ED68: free (vg_replace_malloc.c:530)
   by 0x573907D: fclose@@GLIBC_2.2.5 (in /usr/lib64/libc-2.26.9000.so)
   by 0x6AC5C00: reopen_standard_stream (log.c:189)
   by 0x6A8E62C: destroy_toolcontext (toolcontext.c:2271)
   by 0x6BA5C22: lvm_fin (lvmcmdline.c:3339)
   by 0x6BD5EF3: lvm2_exit (lvmcmdlib.c:123)
   by 0x6856013: dmeventd_lvm2_exit (dmeventd_lvm.c:103)
   by 0x66535B8: unregister_device (dmeventd_thin.c:432)
   by 0x10CBBC: _do_unregister_device (dmeventd.c:926)
   by 0x10CD74: _monitor_unregister (dmeventd.c:979)
   by 0x10D094: _monitor_thread (dmeventd.c:1066)
   by 0x54B35E0: start_thread (in /usr/lib64/libpthread-2.26.9000.so)
   by 0x57C30EE: clone (in /usr/lib64/libc-2.26.9000.so)
 Block was alloc'd at
   at 0x4C2DBBB: malloc (vg_replace_malloc.c:299)
   by 0x573932B: fdopen@@GLIBC_2.2.5 (in /usr/lib64/libc-2.26.9000.so)
   by 0x6AC5DC2: reopen_standard_stream (log.c:200)
   by 0x6A8D11D: create_toolcontext (toolcontext.c:1898)
   by 0x6BA5B6B: init_lvm (lvmcmdline.c:3319)
   by 0x6BD5BC8: cmdlib_lvm2_init (lvmcmdlib.c:34)
   by 0x6BD5F04: lvm2_init (lvm2cmd.c:20)
   by 0x6855EA7: dmeventd_lvm2_init (dmeventd_lvm.c:67)
   by 0x665305F: register_device (dmeventd_thin.c:352)
   by 0x10CB7A: _do_register_device (dmeventd.c:916)
   by 0x10CEE4: _monitor_thread (dmeventd.c:1006)
   by 0x54B35E0: start_thread (in /usr/lib64/libpthread-2.26.9000.so)
   by 0x57C30EE: clone (in /usr/lib64/libc-2.26.9000.so)
....
Process terminating with default action of signal 6 (SIGABRT): dumping core
   at 0x570016B: raise (in /usr/lib64/libc-2.26.9000.so)
   by 0x5701520: abort (in /usr/lib64/libc-2.26.9000.so)
   by 0x57437D8: __libc_message (in /usr/lib64/libc-2.26.9000.so)
   by 0x5743831: __libc_fatal (in /usr/lib64/libc-2.26.9000.so)
   by 0x5744056: _IO_vtable_check (in /usr/lib64/libc-2.26.9000.so)
   by 0x574751C: __overflow (in /usr/lib64/libc-2.26.9000.so)
   by 0x574191A: fputc (in /usr/lib64/libc-2.26.9000.so)
   by 0x50428E3: dm_event_log (libdevmapper-event.c:934)
   by 0x10B015: _dmeventd_log (dmeventd.c:125)
   by 0x10D289: _unregister_for_event (dmeventd.c:1146)
   by 0x10E52E: _handle_request (dmeventd.c:1583)
   by 0x10E6D7: _do_process_request (dmeventd.c:1631)
   by 0x10E7C6: _process_request (dmeventd.c:1660)
   by 0x1101A4: main (dmeventd.c:2285)
---
 WHATS_NEW                  |    1 +
 lib/commands/toolcontext.c |   11 +++++++++--
 2 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 197adc3..bf46281 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.178 - 
 =====================================
+  Do not reopen output streams for multithreaded users of liblvm.
   Use versionsort to fix archive file expiry beyond 100000 files.
   Add devices/use_aio, aio_max, aio_memory to configure AIO limits.
   Support asynchronous I/O when scanning devices.
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 0080a68..ba757dd 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -46,6 +46,7 @@
 
 #include <locale.h>
 #include <sys/stat.h>
+#include <sys/syscall.h>
 #include <sys/utsname.h>
 #include <syslog.h>
 #include <time.h>
@@ -1883,7 +1884,13 @@ struct cmd_context *create_toolcontext(unsigned is_long_lived,
 
 #ifndef VALGRIND_POOL
 	/* Set in/out stream buffering before glibc */
-	if (set_buffering) {
+	if (set_buffering
+#ifdef SYS_gettid
+	    /* For threaded programs no changes of streams */
+            /* On linux gettid() is implemented only via syscall */
+	    && (syscall(SYS_gettid) == getpid())
+#endif
+	   ) {
 		/* Allocate 2 buffers */
 		if (!(cmd->linebuffer = dm_malloc(2 * _linebuffer_size))) {
 			log_error("Failed to allocate line buffer.");
@@ -1914,7 +1921,7 @@ struct cmd_context *create_toolcontext(unsigned is_long_lived,
 			}
 		}
 		/* Buffers are used for lines without '\n' */
-	} else
+	} else if (!set_buffering)
 		/* Without buffering, must not use stdin/stdout */
 		init_silent(1);
 #endif


