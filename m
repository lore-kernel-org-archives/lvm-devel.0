From: Jonathan Brassow <jbrassow@redhat.com>
Date: Wed, 05 Aug 2009 13:17:59 -0500
Subject: PATCH REPOST] Fix clvmd segfault
Message-ID: <1249496279.15327.12.camel@hydrogen.msp.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

My last patch failed to include the pthread unlock.

 brassow

clvmd: Fix segfault.

I don't know /why/ it is failing... and I don't even know
exactly where the problem gets started, but here is what
I've found so far...

>From the core dump:
Program terminated with signal 11, Segmentation fault.
#0  persistent_filter_wipe (f=0x0) at filters/filter-persistent.c:54
54              struct pfilter *pf = (struct pfilter *) f->private;
(gdb) bt
#0  persistent_filter_wipe (f=0x0) at filters/filter-persistent.c:54
#1  0x000000000041d83a in dev_iter_create (f=0x0, dev_scan=1) at device/dev-cache.c:740
#2  0x0000000000416b85 in lvmcache_label_scan (cmd=0x112aacd0, full_scan=2) at cache/lvmcache.c:463
#3  0x0000000000410ad0 in do_refresh_cache () at lvm-functions.c:606
#4  0x000000000040d3ea in do_command (client=0x11441fd0, msg=<value optimized out>, msglen=30,
    buf=0x4296a0c0, buflen=1481, retlen=0x4296a0cc) at clvmd-command.c:127
#5  0x000000000040e973 in lvm_thread_fn (arg=<value optimized out>) at clvmd.c:1554
#6  0x0000003992a064a7 in start_thread () from /lib64/libpthread.so.0
#7  0x00000039922d3c2d in clone () from /lib64/libc.so.6

'f' is being dereferenced in persistent_filter_wipe - initially provided by
lvmcache_label_scan, here:

463             if (!(iter = dev_iter_create(cmd->filter, (full_scan == 2) ? 1 : 0))) {
464                     log_error("dev_iter creation failed");
465                     goto out;
466             }

'cmd->filter' isn't set because 'refresh_toolcontext' failed in
do_refresh_cache:

604             ret = refresh_toolcontext(cmd);
605             init_full_scan_done(0);
606             lvmcache_label_scan(cmd, 2);
(gdb) p ret
$2 = 0

'refresh_toolcontext' failed at 
_init_lvm_conf->_load_config_file->read_config_file->read_config_fd'

client=0x114f6090, msg=(nil), len=0, csid=(nil), xid=10574
  /etc/lvm/lvm.conf: mmap failed: Bad file descriptor
  /etc/lvm/lvm.conf: munmap failed: Invalid argument
  /etc/lvm/lvm.conf: close failed: Bad file descriptor
  Failed to load config file /etc/lvm/lvm.conf

Is the file descriptor being lost, corrupted, etc?

This patch is a bandaid for the problem.

Index: LVM2/daemons/clvmd/lvm-functions.c
===================================================================
--- LVM2.orig/daemons/clvmd/lvm-functions.c
+++ LVM2/daemons/clvmd/lvm-functions.c
@@ -593,20 +593,23 @@ int do_check_lvm1(const char *vgname)
 
 int do_refresh_cache()
 {
-	int ret;
 	DEBUGLOG("Refreshing context\n");
 	log_notice("Refreshing context");
 
 	pthread_mutex_lock(&lvm_lock);
 
-	ret = refresh_toolcontext(cmd);
+	if (!refresh_toolcontext(cmd)) {
+		pthread_mutex_unlock(&lvm_lock);
+		return -1;
+	}
+
 	init_full_scan_done(0);
 	lvmcache_label_scan(cmd, 2);
 	dm_pool_empty(cmd->mem);
 
 	pthread_mutex_unlock(&lvm_lock);
 
-	return ret==1?0:-1;
+	return 0;
 }
 
 



