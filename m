From: agk@sourceware.org <agk@sourceware.org>
Date: 24 Jul 2009 18:15:08 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/lvm-functions.c ...
Message-ID: <20090724181508.2348.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-07-24 18:15:07

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : lvm-functions.c 
	lib/locking    : locking.c locking.h 

Log message:
	All LV locks are non-blocking so remove LCK_NONBLOCK from separate macros.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1200&r2=1.1201
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.c.diff?cvsroot=lvm2&r1=1.66&r2=1.67
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.c.diff?cvsroot=lvm2&r1=1.62&r2=1.63
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.h.diff?cvsroot=lvm2&r1=1.48&r2=1.49

--- LVM2/WHATS_NEW	2009/07/24 15:01:43	1.1200
+++ LVM2/WHATS_NEW	2009/07/24 18:15:06	1.1201
@@ -1,5 +1,6 @@
 Version 2.02.50 - 
 ================================
+  All LV locks are non-blocking so remove LCK_NONBLOCK from separate macros.
   Fix race condition with vgcreate and vgextend on same device (2.02.49).
   Remove redundant validate_name call from vgreduce.
   Add lvm_{pv|vg|lv}_get_{name|uuid} liblvm functions.
--- LVM2/daemons/clvmd/lvm-functions.c	2009/07/16 00:36:59	1.66
+++ LVM2/daemons/clvmd/lvm-functions.c	2009/07/24 18:15:07	1.67
@@ -65,8 +65,6 @@
 	int lock_mode;
 };
 
-#define LCK_MASK (LCK_TYPE_MASK | LCK_SCOPE_MASK)
-
 static const char *decode_locking_cmd(unsigned char cmdl)
 {
 	static char buf[128];
@@ -482,28 +480,28 @@
 	cmd->partial_activation = (lock_flags & LCK_PARTIAL_MODE) ? 1 : 0;
 
 	switch (command) {
-	case LCK_LV_EXCLUSIVE:
+	case LCK_LV_EXCLUSIVE & LCK_MASK:
 		status = do_activate_lv(resource, lock_flags, LKM_EXMODE);
 		break;
 
-	case LCK_LV_SUSPEND:
+	case LCK_LV_SUSPEND & LCK_MASK:
 		status = do_suspend_lv(resource);
 		if (!status)
 			suspended++;
 		break;
 
 	case LCK_UNLOCK:
-	case LCK_LV_RESUME:	/* if active */
+	case LCK_LV_RESUME & LCK_MASK:	/* if active */
 		status = do_resume_lv(resource);
 		if (!status)
 			suspended--;
 		break;
 
-	case LCK_LV_ACTIVATE:
+	case LCK_LV_ACTIVATE & LCK_MASK:
 		status = do_activate_lv(resource, lock_flags, LKM_CRMODE);
 		break;
 
-	case LCK_LV_DEACTIVATE:
+	case LCK_LV_DEACTIVATE & LCK_MASK:
 		status = do_deactivate_lv(resource, lock_flags);
 		break;
 
--- LVM2/lib/locking/locking.c	2009/07/15 05:49:47	1.62
+++ LVM2/lib/locking/locking.c	2009/07/24 18:15:07	1.63
@@ -386,9 +386,10 @@
 		/* If LVM1 driver knows about the VG, it can't be accessed. */
 		if (!check_lvm1_vg_inactive(cmd, vol))
 			return 0;
+		break;
 	case LCK_LV:
-		/* Suspend LV if it's active. */
-		strncpy(resource, vol, sizeof(resource));
+		/* All LV locks are non-blocking. */
+		flags |= LCK_NONBLOCK;
 		break;
 	default:
 		log_error("Unrecognised lock scope: %d",
@@ -396,6 +397,8 @@
 		return 0;
 	}
 
+	strncpy(resource, vol, sizeof(resource));
+
 	if (!_lock_vol(cmd, resource, flags))
 		return 0;
 
--- LVM2/lib/locking/locking.h	2009/06/12 08:30:19	1.48
+++ LVM2/lib/locking/locking.h	2009/07/24 18:15:07	1.49
@@ -106,17 +106,19 @@
 #define LCK_VG_DROP_CACHE	(LCK_VG | LCK_WRITE | LCK_CACHE)
 #define LCK_VG_BACKUP		(LCK_VG | LCK_CACHE)
 
-#define LCK_LV_EXCLUSIVE	(LCK_LV | LCK_EXCL | LCK_NONBLOCK)
-#define LCK_LV_SUSPEND		(LCK_LV | LCK_WRITE | LCK_NONBLOCK)
-#define LCK_LV_RESUME		(LCK_LV | LCK_UNLOCK | LCK_NONBLOCK)
-#define LCK_LV_ACTIVATE		(LCK_LV | LCK_READ | LCK_NONBLOCK)
-#define LCK_LV_DEACTIVATE	(LCK_LV | LCK_NULL | LCK_NONBLOCK)
+#define LCK_LV_EXCLUSIVE	(LCK_LV | LCK_EXCL)
+#define LCK_LV_SUSPEND		(LCK_LV | LCK_WRITE)
+#define LCK_LV_RESUME		(LCK_LV | LCK_UNLOCK)
+#define LCK_LV_ACTIVATE		(LCK_LV | LCK_READ)
+#define LCK_LV_DEACTIVATE	(LCK_LV | LCK_NULL)
+
+#define LCK_MASK (LCK_TYPE_MASK | LCK_SCOPE_MASK)
 
 #define LCK_LV_CLUSTERED(lv)	\
 	(vg_is_clustered((lv)->vg) ? LCK_CLUSTER_VG : 0)
 
 #define lock_lv_vol(cmd, lv, flags)	\
-	lock_vol(cmd, (lv)->lvid.s, flags | LCK_LV_CLUSTERED(lv))
+	lock_vol(cmd, (lv)->lvid.s, flags | LCK_LV_CLUSTERED(lv) | LCK_NONBLOCK)
 
 #define unlock_vg(cmd, vol)	lock_vol(cmd, vol, LCK_VG_UNLOCK)
 #define unlock_and_release_vg(cmd, vg, vol) \


