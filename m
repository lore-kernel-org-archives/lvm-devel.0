From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 21 May 2010 14:29:51 -0000
Subject: LVM2 ./WHATS_NEW lib/locking/locking.h
Message-ID: <20100521142951.27953.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-05-21 14:29:49

Modified files:
	.              : WHATS_NEW 
	lib/locking    : locking.h 

Log message:
	Replicator: lock_lv_vol() finds missing VGs
	
	Find and check for all needed VGs before calling lock_vol().

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1587&r2=1.1588
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.h.diff?cvsroot=lvm2&r1=1.55&r2=1.56

--- LVM2/WHATS_NEW	2010/05/21 14:15:39	1.1587
+++ LVM2/WHATS_NEW	2010/05/21 14:29:49	1.1588
@@ -1,5 +1,6 @@
 Version 2.02.67 -
 ===============================
+  Check for missing VGs before taking lock_lv_vol (for Replicator).
   Update process_each_lv_in_vg() to use cmd_vg structure.
   Update _process_one_vg() to work with cmd_vg structure.
   Add functions for read and release VGs list.
--- LVM2/lib/locking/locking.h	2010/05/19 01:49:08	1.55
+++ LVM2/lib/locking/locking.h	2010/05/21 14:29:49	1.56
@@ -130,7 +130,9 @@
 	(vg_is_clustered((lv)->vg) ? LCK_CLUSTER_VG : 0)
 
 #define lock_lv_vol(cmd, lv, flags)	\
-	lock_vol(cmd, (lv)->lvid.s, flags | LCK_LV_CLUSTERED(lv))
+	(find_replicator_vgs((lv)) ? \
+		lock_vol(cmd, (lv)->lvid.s, flags | LCK_LV_CLUSTERED(lv)) : \
+		0)
 
 #define unlock_vg(cmd, vol)	lock_vol(cmd, vol, LCK_VG_UNLOCK)
 #define unlock_and_release_vg(cmd, vg, vol) \


