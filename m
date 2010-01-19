From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 19 Jan 2010 13:25:01 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/lvm-functions.c ...
Message-ID: <20100119132501.15445.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2010-01-19 13:25:00

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : lvm-functions.c 
	lib/commands   : toolcontext.c 

Log message:
	Never scan suspended devices in clvmd.
	
	For mirror repair (and similar tasks) it can happen that full
	device rescan is issued from clvmd.
	
	Because code can be in the middle of repair (calling suspend)
	clvmd should never try to scan suspended devices
	(otherwise it causes deadlock).
	
	Also code must not change ignore_suspended_device flag when
	doing refresh_filters (called from lvmcache scan code).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1394&r2=1.1395
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.c.diff?cvsroot=lvm2&r1=1.82&r2=1.83
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.90&r2=1.91

--- LVM2/WHATS_NEW	2010/01/15 20:47:52	1.1394
+++ LVM2/WHATS_NEW	2010/01/19 13:25:00	1.1395
@@ -1,5 +1,6 @@
 Version 2.02.59 - 
 ===================================
+  Fix clvmd to never scan suspended devices.
   Initial version of the cmirror init script (Red Hat).
   Initial version of the cmirrord man page.
   Make cluster log communication structures architecture independant.
--- LVM2/daemons/clvmd/lvm-functions.c	2010/01/05 16:09:33	1.82
+++ LVM2/daemons/clvmd/lvm-functions.c	2010/01/19 13:25:00	1.83
@@ -499,6 +499,9 @@
 
 	cmd->partial_activation = (lock_flags & LCK_PARTIAL_MODE) ? 1 : 0;
 
+	/* clvmd should never try to read suspended device */
+	init_ignore_suspended_devices(1);
+
 	switch (command & LCK_MASK) {
 	case LCK_LV_EXCLUSIVE:
 		status = do_activate_lv(resource, lock_flags, LKM_EXMODE);
@@ -627,6 +630,7 @@
 	}
 
 	init_full_scan_done(0);
+	init_ignore_suspended_devices(1);
 	lvmcache_label_scan(cmd, 2);
 	dm_pool_empty(cmd->mem);
 
@@ -860,6 +864,7 @@
 
 	/* Check lvm.conf is setup for cluster-LVM */
 	check_config();
+	init_ignore_suspended_devices(1);
 
 	/* Remove any non-LV locks that may have been left around */
 	if (using_gulm)
--- LVM2/lib/commands/toolcontext.c	2010/01/07 19:54:21	1.90
+++ LVM2/lib/commands/toolcontext.c	2010/01/19 13:25:00	1.91
@@ -1231,12 +1231,21 @@
 
 int refresh_filters(struct cmd_context *cmd)
 {
+	int r, saved_ignore_suspended_devices = ignore_suspended_devices();
+
 	if (cmd->filter) {
 		cmd->filter->destroy(cmd->filter);
 		cmd->filter = NULL;
 	}
 
-	return _init_filters(cmd, 0);
+	r = _init_filters(cmd, 0);
+
+	/*
+	 * During repair code must not reset suspended flag.
+	 */
+	init_ignore_suspended_devices(saved_ignore_suspended_devices);
+
+	return r;
 }
 
 int refresh_toolcontext(struct cmd_context *cmd)


