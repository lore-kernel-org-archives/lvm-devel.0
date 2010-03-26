From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 26 Mar 2010 15:40:15 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/lvm-functions.c ...
Message-ID: <20100326154015.1322.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2010-03-26 15:40:14

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : lvm-functions.c 
	lib/locking    : cluster_locking.c 

Log message:
	Fix clvmd cluster propagation of dmeventd monitoring mode.
	
	clvmd's do_lock_lv() already properly controls dmeventd monitoring based
	on LCK_DMEVENTD_MONITOR_MODE in lock_flags -- though one small fix was
	needed for this to work: _lock_for_cluster() must treat
	dmeventd_monitor_mode()'s return as a tri-state value.
	
	Also cleanup do_lock_lv() to:
	- explicitly init_dmeventd_monitor() based on LCK_DMEVENTD_MONITOR_MODE
	- no longer reset init_dmeventd_monitor() to default at the end of
	do_lock_lv() -- it is unnecessary

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1482&r2=1.1483
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.c.diff?cvsroot=lvm2&r1=1.86&r2=1.87
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/cluster_locking.c.diff?cvsroot=lvm2&r1=1.40&r2=1.41

--- LVM2/WHATS_NEW	2010/03/25 21:19:26	1.1482
+++ LVM2/WHATS_NEW	2010/03/26 15:40:13	1.1483
@@ -1,5 +1,6 @@
 Version 2.02.63 -  
 ================================
+  Fix clvmd cluster propagation of dmeventd monitoring mode.
   Allow ALLOC_ANYWHERE to split contiguous areas.
   Use INTERNAL_ERROR for internal errors throughout tree.
   Add some assertions to allocation code.
--- LVM2/daemons/clvmd/lvm-functions.c	2010/03/24 22:25:11	1.86
+++ LVM2/daemons/clvmd/lvm-functions.c	2010/03/26 15:40:14	1.87
@@ -499,7 +499,9 @@
 	if (lock_flags & LCK_MIRROR_NOSYNC_MODE)
 		init_mirror_in_sync(1);
 
-	if (!(lock_flags & LCK_DMEVENTD_MONITOR_MODE))
+	if (lock_flags & LCK_DMEVENTD_MONITOR_MODE)
+		init_dmeventd_monitor(1);
+	else
 		init_dmeventd_monitor(0);
 
 	cmd->partial_activation = (lock_flags & LCK_PARTIAL_MODE) ? 1 : 0;
@@ -542,9 +544,6 @@
 	if (lock_flags & LCK_MIRROR_NOSYNC_MODE)
 		init_mirror_in_sync(0);
 
-	if (!(lock_flags & LCK_DMEVENTD_MONITOR_MODE))
-		init_dmeventd_monitor(DEFAULT_DMEVENTD_MONITOR);
-
 	cmd->partial_activation = 0;
 
 	/* clean the pool for another command */
--- LVM2/lib/locking/cluster_locking.c	2010/01/05 16:07:57	1.40
+++ LVM2/lib/locking/cluster_locking.c	2010/03/26 15:40:14	1.41
@@ -307,6 +307,7 @@
 	char *args;
 	const char *node = "";
 	int len;
+	int dmeventd_mode;
 	int saved_errno = errno;
 	lvm_response_t *response = NULL;
 	int num_responses;
@@ -324,7 +325,12 @@
 	if (mirror_in_sync())
 		args[1] |= LCK_MIRROR_NOSYNC_MODE;
 
-	if (dmeventd_monitor_mode())
+	/*
+	 * Must handle tri-state return from dmeventd_monitor_mode.
+	 * But DMEVENTD_MONITOR_IGNORE is not propagated across the cluster.
+	 */
+	dmeventd_mode = dmeventd_monitor_mode();
+	if (dmeventd_mode != DMEVENTD_MONITOR_IGNORE && dmeventd_mode)
 		args[1] |= LCK_DMEVENTD_MONITOR_MODE;
 
 	if (cmd->partial_activation)


