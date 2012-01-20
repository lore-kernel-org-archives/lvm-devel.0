From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 20 Jan 2012 00:27:26 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/lvm-functions.c ...
Message-ID: <20120120002726.23316.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2012-01-20 00:27:24

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : lvm-functions.c 
	lib/activate   : activate.c activate.h 
	lib/locking    : file_locking.c no_locking.c 

Log message:
	Preserve exclusive activation of cluster mirror when converting.
	
	This patch to the suspend code - like the similar change for resume -
	queries the lock mode of a cluster volume and records whether it is active
	exclusively.  This is necessary for suspend due to the possibility of
	preloading targets.  Failure to check to exclusivity causes the cluster target
	of an exclusively activated mirror to be used when converting - rather than
	the single machine target.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2224&r2=1.2225
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.c.diff?cvsroot=lvm2&r1=1.128&r2=1.129
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.230&r2=1.231
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.h.diff?cvsroot=lvm2&r1=1.93&r2=1.94
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/file_locking.c.diff?cvsroot=lvm2&r1=1.61&r2=1.62
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/no_locking.c.diff?cvsroot=lvm2&r1=1.30&r2=1.31

--- LVM2/WHATS_NEW	2012/01/19 16:22:42	1.2224
+++ LVM2/WHATS_NEW	2012/01/20 00:27:18	1.2225
@@ -1,6 +1,7 @@
 Version 2.02.89 - 
 ==================================
-  Keep into about creation host and time for each logical volume.
+  Preserve exclusive activation of cluster mirror when converting.
+  Keep info about creation host and time for each logical volume.
   Make error message hit when preallocated memlock memory exceeded clearer.
   Use R lv_attr to indicate read-only activation of non-read-only device in lvs.
   Show read-only activation override in lvdisplay & add 4 to perms in -c.
--- LVM2/daemons/clvmd/lvm-functions.c	2011/12/08 21:24:08	1.128
+++ LVM2/daemons/clvmd/lvm-functions.c	2012/01/20 00:27:19	1.129
@@ -430,6 +430,7 @@
 	int oldmode;
 	struct lvinfo lvi;
 	unsigned origin_only = (lock_flags & LCK_ORIGIN_ONLY_MODE) ? 1 : 0;
+	unsigned exclusive;
 
 	/* Is it open ? */
 	oldmode = get_current_lock(resource);
@@ -438,11 +439,14 @@
 		return 0; /* Not active, so it's OK */
 	}
 
+	exclusive = (oldmode == LCK_EXCL) ? 1 : 0;
+
 	/* Only suspend it if it exists */
 	if (!lv_info_by_lvid(cmd, resource, origin_only, &lvi, 0, 0))
 		return EIO;
 
-	if (lvi.exists && !lv_suspend_if_active(cmd, resource, origin_only))
+	if (lvi.exists &&
+	    !lv_suspend_if_active(cmd, resource, origin_only, exclusive))
 		return EIO;
 
 	return 0;
--- LVM2/lib/activate/activate.c	2012/01/19 15:27:54	1.230
+++ LVM2/lib/activate/activate.c	2012/01/20 00:27:19	1.231
@@ -1455,9 +1455,12 @@
 }
 
 /* Returns success if the device is not active */
-int lv_suspend_if_active(struct cmd_context *cmd, const char *lvid_s, unsigned origin_only)
+int lv_suspend_if_active(struct cmd_context *cmd, const char *lvid_s, unsigned origin_only, unsigned exclusive)
 {
-	struct lv_activate_opts laopts = { .origin_only = origin_only };
+	struct lv_activate_opts laopts = {
+		.origin_only = origin_only,
+		.exclusive = exclusive
+	};
 
 	return _lv_suspend(cmd, lvid_s, &laopts, 0);
 }
--- LVM2/lib/activate/activate.h	2012/01/19 15:27:54	1.93
+++ LVM2/lib/activate/activate.h	2012/01/20 00:27:19	1.94
@@ -64,7 +64,7 @@
 void activation_exit(void);
 
 /* int lv_suspend(struct cmd_context *cmd, const char *lvid_s); */
-int lv_suspend_if_active(struct cmd_context *cmd, const char *lvid_s, unsigned origin_only);
+int lv_suspend_if_active(struct cmd_context *cmd, const char *lvid_s, unsigned origin_only, unsigned exclusive);
 int lv_resume(struct cmd_context *cmd, const char *lvid_s, unsigned origin_only);
 int lv_resume_if_active(struct cmd_context *cmd, const char *lvid_s,
 			unsigned origin_only, unsigned exclusive, unsigned revert);
--- LVM2/lib/locking/file_locking.c	2011/09/27 22:43:41	1.61
+++ LVM2/lib/locking/file_locking.c	2012/01/20 00:27:20	1.62
@@ -312,7 +312,7 @@
 			break;
 		case LCK_WRITE:
 			log_very_verbose("Locking LV %s (W)%s", resource, origin_only ? " without snapshots" : "");
-			if (!lv_suspend_if_active(cmd, resource, origin_only))
+			if (!lv_suspend_if_active(cmd, resource, origin_only, 0))
 				return 0;
 			break;
 		case LCK_EXCL:
--- LVM2/lib/locking/no_locking.c	2011/09/27 22:43:41	1.30
+++ LVM2/lib/locking/no_locking.c	2012/01/20 00:27:21	1.31
@@ -50,7 +50,7 @@
 		case LCK_READ:
 			return lv_activate_with_filter(cmd, resource, 0);
 		case LCK_WRITE:
-			return lv_suspend_if_active(cmd, resource, (flags & LCK_ORIGIN_ONLY) ? 1 : 0);
+			return lv_suspend_if_active(cmd, resource, (flags & LCK_ORIGIN_ONLY) ? 1 : 0, 0);
 		case LCK_EXCL:
 			return lv_activate_with_filter(cmd, resource, 1);
 		default:


