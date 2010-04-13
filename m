From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 13 Apr 2010 14:36:25 -0000
Subject: LVM2 ./WHATS_NEW lib/locking/cluster_locking.c
Message-ID: <20100413143625.13259.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2010-04-13 14:36:25

Modified files:
	.              : WHATS_NEW 
	lib/locking    : cluster_locking.c 

Log message:
	Mask LCK_HOLD flag in cluster VG locks for compatibility reasons.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1512&r2=1.1513
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/cluster_locking.c.diff?cvsroot=lvm2&r1=1.41&r2=1.42

--- LVM2/WHATS_NEW	2010/04/13 01:54:32	1.1512
+++ LVM2/WHATS_NEW	2010/04/13 14:36:24	1.1513
@@ -1,5 +1,6 @@
 Version 2.02.63 -  
 ================================
+  Mask LCK_HOLD flag in cluster VG locks for compatibility reasons.
   Add activation/polling_interval to lvm.conf as --interval default.
   Don't ignore error if resuming any LV fails in resume_lvs.
   Skip closing persistent filter cache file if open failed.
--- LVM2/lib/locking/cluster_locking.c	2010/03/26 15:40:14	1.41
+++ LVM2/lib/locking/cluster_locking.c	2010/04/13 14:36:25	1.42
@@ -415,6 +415,13 @@
 
 		lock_scope = "VG";
 		clvmd_cmd = CLVMD_CMD_LOCK_VG;
+		/*
+		 * Old clvmd does not expect LCK_HOLD which was already processed
+		 * in lock_vol, mask it for compatibility reasons.
+		 */
+		if (flags != LCK_VG_COMMIT && flags != LCK_VG_REVERT)
+			flags &= ~LCK_HOLD;
+
 		break;
 
 	case LCK_LV:


