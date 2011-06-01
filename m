From: agk@sourceware.org <agk@sourceware.org>
Date: 1 Jun 2011 21:16:57 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/clvmd-command.c ...
Message-ID: <20110601211657.29635.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-06-01 21:16:56

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : clvmd-command.c lvm-functions.c 
	lib/locking    : cluster_locking.c locking.h 

Log message:
	Propagate test mode to clvmd to skip activation and changes to held locks.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2004&r2=1.2005
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-command.c.diff?cvsroot=lvm2&r1=1.54&r2=1.55
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.c.diff?cvsroot=lvm2&r1=1.116&r2=1.117
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/cluster_locking.c.diff?cvsroot=lvm2&r1=1.55&r2=1.56
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.h.diff?cvsroot=lvm2&r1=1.65&r2=1.66

--- LVM2/WHATS_NEW	2011/06/01 19:29:31	1.2004
+++ LVM2/WHATS_NEW	2011/06/01 21:16:55	1.2005
@@ -1,5 +1,6 @@
 Version 2.02.86 -  
 =================================
+  Propagate test mode to clvmd to skip activation and changes to held locks.
   Defer writing PV labels to vg_write.
   Store label_sector only in struct physical_volume.
   Permit --available with lvcreate so non-snapshot LVs need not be activated.
--- LVM2/daemons/clvmd/clvmd-command.c	2011/04/08 14:40:18	1.54
+++ LVM2/daemons/clvmd/clvmd-command.c	2011/06/01 21:16:56	1.55
@@ -80,6 +80,9 @@
 	unsigned char lock_cmd;
 	unsigned char lock_flags;
 
+	/* Reset test mode before we start */
+	init_test(0);
+
 	/* Do the command */
 	switch (msg->cmd) {
 		/* Just a test message */
@@ -109,6 +112,8 @@
 		lockname = &args[2];
 		/* Check to see if the VG is in use by LVM1 */
 		status = do_check_lvm1(lockname);
+		if (lock_flags & LCK_TEST_MODE)
+			init_test(1);
 		do_lock_vg(lock_cmd, lock_flags, lockname);
 		break;
 
@@ -117,6 +122,8 @@
 		lock_cmd = args[0] & (LCK_NONBLOCK | LCK_HOLD | LCK_SCOPE_MASK | LCK_TYPE_MASK);
 		lock_flags = args[1];
 		lockname = &args[2];
+		if (lock_flags & LCK_TEST_MODE)
+			init_test(1);
 		status = do_lock_lv(lock_cmd, lock_flags, lockname);
 		/* Replace EIO with something less scary */
 		if (status == EIO) {
@@ -251,6 +258,7 @@
 	int status = 0;
 	char *lockname;
 
+	init_test(0);
 	switch (header->cmd) {
 	case CLVMD_CMD_TEST:
 		status = sync_lock("CLVMD_TEST", LCK_EXCL, 0, &lockid);
@@ -269,6 +277,8 @@
 		lock_cmd = args[0];
 		lock_flags = args[1];
 		lockname = &args[2];
+		if (lock_flags & LCK_TEST_MODE)
+			init_test(1);
 		status = pre_lock_lv(lock_cmd, lock_flags, lockname);
 		break;
 
@@ -300,6 +310,7 @@
 	char *args = header->node + strlen(header->node) + 1;
 	char *lockname;
 
+	init_test(0);
 	switch (header->cmd) {
 	case CLVMD_CMD_TEST:
 		status =
@@ -311,6 +322,8 @@
 		lock_cmd = args[0];
 		lock_flags = args[1];
 		lockname = &args[2];
+		if (lock_flags & LCK_TEST_MODE)
+			init_test(1);
 		status = post_lock_lv(lock_cmd, lock_flags, lockname);
 		break;
 
--- LVM2/daemons/clvmd/lvm-functions.c	2011/05/07 13:50:13	1.116
+++ LVM2/daemons/clvmd/lvm-functions.c	2011/06/01 21:16:56	1.117
@@ -137,6 +137,7 @@
 		flags & LCK_MIRROR_NOSYNC_MODE	  ? "MIRROR_NOSYNC|" : "",
 		flags & LCK_DMEVENTD_MONITOR_MODE ? "DMEVENTD_MONITOR|" : "",
 		flags & LCK_ORIGIN_ONLY_MODE ? "ORIGIN_ONLY|" : "",
+		flags & LCK_TEST_MODE ? "TEST|" : "",
 		flags & LCK_CONVERT ? "CONVERT|" : "");
 
 	if (len > 1)
@@ -235,6 +236,9 @@
 	int saved_errno;
 	struct lv_info *lvi;
 
+	if (test_mode())
+		return 0;
+
 	/* Mask off invalid options */
 	flags &= LCKF_NOQUEUE | LCKF_CONVERT;
 
@@ -298,6 +302,9 @@
 	int status;
 	int saved_errno;
 
+	if (test_mode())
+		return 0;
+
 	if (!(lvi = lookup_info(resource))) {
 		DEBUGLOG("hold_unlock, lock not already held\n");
 		return 0;
--- LVM2/lib/locking/cluster_locking.c	2011/04/08 14:40:19	1.55
+++ LVM2/lib/locking/cluster_locking.c	2011/06/01 21:16:56	1.56
@@ -329,6 +329,9 @@
 	if (mirror_in_sync())
 		args[1] |= LCK_MIRROR_NOSYNC_MODE;
 
+	if (test_mode())
+		args[1] |= LCK_TEST_MODE;
+
 	/*
 	 * Must handle tri-state return from dmeventd_monitor_mode.
 	 * But DMEVENTD_MONITOR_IGNORE is not propagated across the cluster.
--- LVM2/lib/locking/locking.h	2011/04/29 00:21:14	1.65
+++ LVM2/lib/locking/locking.h	2011/06/01 21:16:56	1.66
@@ -106,6 +106,7 @@
 #define LCK_DMEVENTD_MONITOR_MODE	0x04	/* Register with dmeventd */
 #define LCK_CONVERT			0x08	/* Convert existing lock */
 #define LCK_ORIGIN_ONLY_MODE		0x20	/* Same as above */
+#define LCK_TEST_MODE			0x10    /* Test mode: No activation */
 
 /*
  * Special cases of VG locks.


