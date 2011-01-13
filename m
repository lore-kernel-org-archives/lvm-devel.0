From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 13 Jan 2011 14:56:18 -0000
Subject: LVM2 ./WHATS_NEW lib/locking/locking.c
Message-ID: <20110113145618.12179.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-01-13 14:56:17

Modified files:
	.              : WHATS_NEW 
	lib/locking    : locking.c 

Log message:
	Skip unnecessary lock_vol() call after volume deactivation
	
	Improve condition within lock_vol so we are not calling extra unlock
	if the volume just has been deactivated.
	
	Patch uses lck_type and replaces negative 'and' condition to more
	readable 'or' condition.
	Few missing strace traces added.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1879&r2=1.1880
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.c.diff?cvsroot=lvm2&r1=1.88&r2=1.89

--- LVM2/WHATS_NEW	2011/01/13 14:51:32	1.1879
+++ LVM2/WHATS_NEW	2011/01/13 14:56:17	1.1880
@@ -1,5 +1,6 @@
 Version 2.02.81 -
 ===================================
+  Skip unnecessary lock_vol() call after volume deactivation.
   Extend exec_cmd params to specify, when device sync is needed.
   Replace fs_unlock by sync_local_dev_names to notify local clvmd. (2.02.80)
   Introduce sync_local_dev_names and CLVMD_CMD_SYNC_NAMES to issue fs_unlock.
--- LVM2/lib/locking/locking.c	2011/01/12 20:42:50	1.88
+++ LVM2/lib/locking/locking.c	2011/01/13 14:56:17	1.89
@@ -406,6 +406,7 @@
 {
 	char resource[258] __attribute__((aligned(8)));
 	lv_operation_t lv_op;
+	int lck_type = flags & LCK_TYPE_MASK;
 
 	switch (flags & (LCK_SCOPE_MASK | LCK_TYPE_MASK)) {
 		case LCK_LV_SUSPEND:
@@ -432,15 +433,15 @@
 		if (is_orphan_vg(vol))
 			vol = VG_ORPHANS;
 		/* VG locks alphabetical, ORPHAN lock last */
-		if (((flags & LCK_TYPE_MASK) != LCK_UNLOCK) &&
-			 !(flags & LCK_CACHE) &&
-			 !lvmcache_verify_lock_order(vol))
-			return 0;
+		if ((lck_type != LCK_UNLOCK) &&
+		    !(flags & LCK_CACHE) &&
+		    !lvmcache_verify_lock_order(vol))
+			return_0;
 
 		/* Lock VG to change on-disk metadata. */
 		/* If LVM1 driver knows about the VG, it can't be accessed. */
 		if (!check_lvm1_vg_inactive(cmd, vol))
-			return 0;
+			return_0;
 		break;
 	case LCK_LV:
 		/* All LV locks are non-blocking. */
@@ -455,18 +456,18 @@
 	strncpy(resource, vol, sizeof(resource));
 
 	if (!_lock_vol(cmd, resource, flags, lv_op))
-		return 0;
+		return_0;
 
 	/*
 	 * If a real lock was acquired (i.e. not LCK_CACHE),
 	 * perform an immediate unlock unless LCK_HOLD was requested.
 	 */
-	if (!(flags & LCK_CACHE) && !(flags & LCK_HOLD) &&
-	    ((flags & LCK_TYPE_MASK) != LCK_UNLOCK)) {
-		if (!_lock_vol(cmd, resource,
-			       (flags & ~LCK_TYPE_MASK) | LCK_UNLOCK, lv_op))
-			return 0;
-	}
+	if ((lck_type == LCK_NULL) || (lck_type == LCK_UNLOCK) ||
+	    (flags & (LCK_CACHE | LCK_HOLD)))
+		return 1;
+
+	if (!_lock_vol(cmd, resource, (flags & ~LCK_TYPE_MASK) | LCK_UNLOCK, lv_op))
+		return_0;
 
 	return 1;
 }


