From: agk@sourceware.org <agk@sourceware.org>
Date: 14 Apr 2008 19:49:13 -0000
Subject: LVM2 ./WHATS_NEW lib/locking/cluster_locking.c
Message-ID: <20080414194913.15694.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-04-14 19:49:13

Modified files:
	.              : WHATS_NEW 
	lib/locking    : cluster_locking.c 

Log message:
	Don't attempt remote metadata backups of non-clustered VGs. (2.02.29)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.848&r2=1.849
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/cluster_locking.c.diff?cvsroot=lvm2&r1=1.25&r2=1.26

--- LVM2/WHATS_NEW	2008/04/14 19:24:15	1.848
+++ LVM2/WHATS_NEW	2008/04/14 19:49:12	1.849
@@ -1,5 +1,6 @@
 Version 2.02.35 - 
 =================================
+  Don't attempt remote metadata backups of non-clustered VGs. (2.02.29)
   Don't store fid in VG metadata cache to avoid clvmd segfault. (2.02.34)
   Update vgsplit tests to verify loosening of active LV restriction.
   Update vgsplit to only restrict split with active LVs involved in split.
--- LVM2/lib/locking/cluster_locking.c	2008/01/30 13:59:59	1.25
+++ LVM2/lib/locking/cluster_locking.c	2008/04/14 19:49:12	1.26
@@ -438,8 +438,10 @@
 		return 0;
 	}
 
-	/* If we are unlocking a VG, then trigger remote metadata backups */
-	if (cluster_cmd == CLVMD_CMD_LOCK_VG && ((flags & LCK_TYPE_MASK) == LCK_UNLOCK)) {
+	/* If we are unlocking a clustered VG, then trigger remote metadata backups */
+	if (cluster_cmd == CLVMD_CMD_LOCK_VG &&
+	    ((flags & LCK_TYPE_MASK) == LCK_UNLOCK) &&
+	    (flags & LCK_CLUSTER_VG)) {
 		log_very_verbose("Requesing backup of VG metadata for %s", resource);
 		_lock_for_cluster(CLVMD_CMD_VG_BACKUP, LCK_CLUSTER_VG, resource);
 	}


