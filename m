From: agk@sourceware.org <agk@sourceware.org>
Date: 2 Feb 2011 23:57:48 -0000
Subject: LVM2/lib/locking cluster_locking.c
Message-ID: <20110202235748.21698.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-02-02 23:57:48

Modified files:
	lib/locking    : cluster_locking.c 

Log message:
	a few more comments

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/cluster_locking.c.diff?cvsroot=lvm2&r1=1.52&r2=1.53

--- LVM2/lib/locking/cluster_locking.c	2011/02/02 23:39:39	1.52
+++ LVM2/lib/locking/cluster_locking.c	2011/02/02 23:57:48	1.53
@@ -342,10 +342,14 @@
 	 * VG locks are just that: locks, and have no side effects
 	 * so we only need to do them on the local node because all
 	 * locks are cluster-wide.
+	 *
 	 * Also, if the lock is exclusive it makes no sense to try to
 	 * acquire it on all nodes, so just do that on the local node too.
-	 * One exception, is that P_ locks (except VG_SYNC_NAMES) /do/ get 
-	 * distributed across the cluster because they might have side-effects.
+	 *
+	 * P_ locks /do/ get distributed across the cluster because they might
+	 * have side-effects.
+	 *
+	 * SYNC_NAMES and VG_BACKUP use the VG name directly without prefix.
 	 */
 	if (clvmd_cmd == CLVMD_CMD_SYNC_NAMES) {
 		if (flags & LCK_LOCAL)


