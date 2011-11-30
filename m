From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 30 Nov 2011 17:02:38 -0000
Subject: LVM2/lib/locking cluster_locking.c
Message-ID: <20111130170238.3562.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-11-30 17:02:38

Modified files:
	lib/locking    : cluster_locking.c 

Log message:
	Update comment on LCK_*DMEVENTD*.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/cluster_locking.c.diff?cvsroot=lvm2&r1=1.61&r2=1.62

--- LVM2/lib/locking/cluster_locking.c	2011/11/30 17:00:57	1.61
+++ LVM2/lib/locking/cluster_locking.c	2011/11/30 17:02:37	1.62
@@ -337,8 +337,9 @@
 		args[1] |= LCK_TEST_MODE;
 
 	/*
-	 * Must handle tri-state return from dmeventd_monitor_mode.
-	 * But DMEVENTD_MONITOR_IGNORE is not propagated across the cluster.
+	 * We propagate dmeventd_monitor_mode() to clvmd faithfully, since
+	 * dmeventd monitoring is tied to activation which happens inside clvmd
+	 * when locking_type = 3.
 	 */
 	dmeventd_mode = dmeventd_monitor_mode();
 	if (dmeventd_mode == DMEVENTD_MONITOR_IGNORE)


