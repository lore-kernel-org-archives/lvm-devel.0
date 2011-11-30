From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 30 Nov 2011 17:00:59 -0000
Subject: LVM2 lib/locking/cluster_locking.c lib/locking ...
Message-ID: <20111130170059.3113.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-11-30 17:00:58

Modified files:
	lib/locking    : cluster_locking.c locking.h 
	daemons/clvmd  : lvm-functions.c 

Log message:
	Fix clvmd to respect DMEVENTD_MONITOR_IGNORE. Fixes a bug where dmeventd
	actions caused clvmd to turn off monitoring of the volume causing the action.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/cluster_locking.c.diff?cvsroot=lvm2&r1=1.60&r2=1.61
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.h.diff?cvsroot=lvm2&r1=1.69&r2=1.70
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.c.diff?cvsroot=lvm2&r1=1.125&r2=1.126

--- LVM2/lib/locking/cluster_locking.c	2011/10/21 15:49:45	1.60
+++ LVM2/lib/locking/cluster_locking.c	2011/11/30 17:00:57	1.61
@@ -341,7 +341,10 @@
 	 * But DMEVENTD_MONITOR_IGNORE is not propagated across the cluster.
 	 */
 	dmeventd_mode = dmeventd_monitor_mode();
-	if (dmeventd_mode != DMEVENTD_MONITOR_IGNORE && dmeventd_mode)
+	if (dmeventd_mode == DMEVENTD_MONITOR_IGNORE)
+		args[1] |= LCK_DMEVENTD_MONITOR_IGNORE;
+
+	if (dmeventd_mode)
 		args[1] |= LCK_DMEVENTD_MONITOR_MODE;
 
 	if (cmd->partial_activation)
--- LVM2/lib/locking/locking.h	2011/09/27 22:43:41	1.69
+++ LVM2/lib/locking/locking.h	2011/11/30 17:00:58	1.70
@@ -109,6 +109,7 @@
 #define LCK_ORIGIN_ONLY_MODE		0x20	/* Same as above */
 #define LCK_TEST_MODE			0x10    /* Test mode: No activation */
 #define LCK_REVERT_MODE			0x40	/* Remove inactive tables */
+#define LCK_DMEVENTD_MONITOR_IGNORE     0x80	/* Whether to ignore dmeventd */
 
 /*
  * Special cases of VG locks.
--- LVM2/daemons/clvmd/lvm-functions.c	2011/09/27 22:43:40	1.125
+++ LVM2/daemons/clvmd/lvm-functions.c	2011/11/30 17:00:58	1.126
@@ -132,13 +132,14 @@
 	static char buf[128];
 	int len;
 
-	len = sprintf(buf, "0x%x ( %s%s%s%s%s%s)", flags,
+	len = sprintf(buf, "0x%x ( %s%s%s%s%s%s%s)", flags,
 		flags & LCK_PARTIAL_MODE	  ? "PARTIAL_MODE|" : "",
 		flags & LCK_MIRROR_NOSYNC_MODE	  ? "MIRROR_NOSYNC|" : "",
 		flags & LCK_DMEVENTD_MONITOR_MODE ? "DMEVENTD_MONITOR|" : "",
 		flags & LCK_ORIGIN_ONLY_MODE ? "ORIGIN_ONLY|" : "",
 		flags & LCK_TEST_MODE ? "TEST|" : "",
-		flags & LCK_CONVERT ? "CONVERT|" : "");
+		flags & LCK_CONVERT ? "CONVERT|" : "",
+		flags & LCK_DMEVENTD_MONITOR_IGNORE ? "DMEVENTD_MONITOR_IGNORE|" : "");
 
 	if (len > 1)
 		buf[len - 2] = ' ';
@@ -512,10 +513,14 @@
 	if (lock_flags & LCK_MIRROR_NOSYNC_MODE)
 		init_mirror_in_sync(1);
 
-	if (lock_flags & LCK_DMEVENTD_MONITOR_MODE)
-		init_dmeventd_monitor(1);
-	else
-		init_dmeventd_monitor(0);
+	if (lock_flags & LCK_DMEVENTD_MONITOR_IGNORE)
+		init_dmeventd_monitor(DMEVENTD_MONITOR_IGNORE);
+	else {
+		if (lock_flags & LCK_DMEVENTD_MONITOR_MODE)
+			init_dmeventd_monitor(1);
+		else
+			init_dmeventd_monitor(0);
+	}
 
 	cmd->partial_activation = (lock_flags & LCK_PARTIAL_MODE) ? 1 : 0;
 


