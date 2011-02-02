From: agk@sourceware.org <agk@sourceware.org>
Date: 2 Feb 2011 23:39:40 -0000
Subject: LVM2 ./WHATS_NEW lib/locking/cluster_locking.c
Message-ID: <20110202233940.17166.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-02-02 23:39:39

Modified files:
	.              : WHATS_NEW 
	lib/locking    : cluster_locking.c 

Log message:
	Allow CLVMD_CMD_SYNC_NAMES to be propagated around the cluster if requested.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1897&r2=1.1898
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/cluster_locking.c.diff?cvsroot=lvm2&r1=1.51&r2=1.52

--- LVM2/WHATS_NEW	2011/02/01 21:41:31	1.1897
+++ LVM2/WHATS_NEW	2011/02/02 23:39:39	1.1898
@@ -1,5 +1,6 @@
 Version 2.02.83 - 
 ===================================
+  Allow CLVMD_CMD_SYNC_NAMES to be propagated around the cluster if requested.
   Add "dmsetup ls --tree" output to lvmdump.
   Fix udev synchronization with no-locking --sysinit (2.02.80).
   Updating man pages for pvcreate, pvremove, pvresize, pvscan.
--- LVM2/lib/locking/cluster_locking.c	2011/02/01 17:31:40	1.51
+++ LVM2/lib/locking/cluster_locking.c	2011/02/02 23:39:39	1.52
@@ -347,13 +347,17 @@
 	 * One exception, is that P_ locks (except VG_SYNC_NAMES) /do/ get 
 	 * distributed across the cluster because they might have side-effects.
 	 */
-	if ((strncmp(name, "P_", 2) &&
-	     (clvmd_cmd == CLVMD_CMD_LOCK_VG ||
-	      (flags & LCK_TYPE_MASK) == LCK_EXCL ||
-	      (flags & LCK_LOCAL) ||
-	      !(flags & LCK_CLUSTER_VG))) ||
-	    (clvmd_cmd == CLVMD_CMD_SYNC_NAMES && (flags & LCK_LOCAL)))
-		node = ".";
+	if (clvmd_cmd == CLVMD_CMD_SYNC_NAMES) {
+		if (flags & LCK_LOCAL)
+			node = ".";
+	} else if (clvmd_cmd != CLVMD_CMD_VG_BACKUP) {
+		if (strncmp(name, "P_", 2) &&
+		    (clvmd_cmd == CLVMD_CMD_LOCK_VG ||
+		     (flags & LCK_TYPE_MASK) == LCK_EXCL ||
+		     (flags & LCK_LOCAL) ||
+		     !(flags & LCK_CLUSTER_VG)))
+			node = ".";
+	}
 
 	status = _cluster_request(clvmd_cmd, node, args, len,
 				  &response, &num_responses);


