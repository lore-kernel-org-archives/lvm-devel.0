From: pcaulfield@sourceware.org <pcaulfield@sourceware.org>
Date: 23 Aug 2007 15:43:20 -0000
Subject: LVM2 lib/locking/cluster_locking.c daemons/clv ...
Message-ID: <20070823154320.5472.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	pcaulfield at sourceware.org	2007-08-23 15:43:20

Modified files:
	lib/locking    : cluster_locking.c 
	daemons/clvmd  : clvmd-command.c 

Log message:
	Locking P_global causes a cache refresh.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/cluster_locking.c.diff?cvsroot=lvm2&r1=1.20&r2=1.21
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-command.c.diff?cvsroot=lvm2&r1=1.17&r2=1.18

--- LVM2/lib/locking/cluster_locking.c	2007/08/23 15:02:26	1.20
+++ LVM2/lib/locking/cluster_locking.c	2007/08/23 15:43:19	1.21
@@ -330,11 +330,14 @@
 	 * locks are cluster-wide.
 	 * Also, if the lock is exclusive it makes no sense to try to
 	 * acquire it on all nodes, so just do that on the local node too.
+	 * One exception, is that P_ locks /do/ get distributed across 
+	 * the cluster because they might have side-effects.
 	 */
-	if (cmd == CLVMD_CMD_LOCK_VG ||
-	    (flags & LCK_TYPE_MASK) == LCK_EXCL ||
-	    (flags & LCK_LOCAL) ||
-	    !(flags & LCK_CLUSTER_VG))
+	if (strncmp(name, "P_", 2) &&
+	    (cmd == CLVMD_CMD_LOCK_VG ||
+	     (flags & LCK_TYPE_MASK) == LCK_EXCL ||
+	     (flags & LCK_LOCAL) ||
+	     !(flags & LCK_CLUSTER_VG)))
 		node = ".";
 
 	status = _cluster_request(cmd, node, args, len,
--- LVM2/daemons/clvmd/clvmd-command.c	2007/08/17 11:51:23	1.17
+++ LVM2/daemons/clvmd/clvmd-command.c	2007/08/23 15:43:20	1.18
@@ -115,8 +115,13 @@
 		break;
 
 	case CLVMD_CMD_LOCK_VG:
+		lockname = &args[2];
 		/* Check to see if the VG is in use by LVM1 */
-		status = do_check_lvm1(&args[2]);
+		status = do_check_lvm1(lockname);
+		/* P_global causes a cache refresh */
+		if (strcmp(lockname, "P_global") == 0)
+		      do_refresh_cache();
+
 		break;
 
 	case CLVMD_CMD_LOCK_LV:


