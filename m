From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 18 Feb 2011 00:36:06 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/lvm-functions.c ...
Message-ID: <20110218003606.23273.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2011-02-18 00:36:05

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : lvm-functions.c 
	lib/activate   : activate.c activate.h 
	lib/locking    : file_locking.c no_locking.c 

Log message:
	Fix for bug 677739: removing final exclusive cmirror snapshot,
	results in clvmd deadlock
	
	When a logical volume is activated exclusively in a cluster, the
	local (non-cluster-aware) target is used.  However, when creating
	a snapshot on the exclusive LV, the resulting suspend/resume fails
	to load the appropriate device-mapper table - instead loading the
	cluster-aware target.
	
	This patch adds an 'exclusive' parameter to the pertinent resume
	functions to allow for the right target type to be loaded.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1912&r2=1.1913
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.c.diff?cvsroot=lvm2&r1=1.111&r2=1.112
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.191&r2=1.192
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.h.diff?cvsroot=lvm2&r1=1.74&r2=1.75
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/file_locking.c.diff?cvsroot=lvm2&r1=1.57&r2=1.58
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/no_locking.c.diff?cvsroot=lvm2&r1=1.27&r2=1.28

--- LVM2/WHATS_NEW	2011/02/09 12:11:21	1.1912
+++ LVM2/WHATS_NEW	2011/02/18 00:36:04	1.1913
@@ -1,5 +1,6 @@
 Version 2.02.85 - 
 ===================================
+  Fix to make resuming exclusive cluster mirror use local target type.
 
 Version 2.02.84 - 9th February 2011
 ===================================
--- LVM2/daemons/clvmd/lvm-functions.c	2011/02/04 20:30:17	1.111
+++ LVM2/daemons/clvmd/lvm-functions.c	2011/02/18 00:36:04	1.112
@@ -399,7 +399,7 @@
 /* Resume the LV if it was active */
 static int do_resume_lv(char *resource, unsigned char lock_flags)
 {
-	int oldmode;
+	int oldmode, origin_only, exclusive;
 
 	/* Is it open ? */
 	oldmode = get_current_lock(resource);
@@ -407,8 +407,10 @@
 		DEBUGLOG("do_resume_lv, lock not already held\n");
 		return 0;	/* We don't need to do anything */
 	}
+	origin_only = (lock_flags & LCK_ORIGIN_ONLY_MODE) ? 1 : 0;
+	exclusive = (oldmode == LCK_EXCL) ? 1 : 0;
 
-	if (!lv_resume_if_active(cmd, resource, (lock_flags & LCK_ORIGIN_ONLY_MODE) ? 1 : 0))
+	if (!lv_resume_if_active(cmd, resource, origin_only, exclusive))
 		return EIO;
 
 	return 0;
--- LVM2/lib/activate/activate.c	2011/02/04 20:30:18	1.191
+++ LVM2/lib/activate/activate.c	2011/02/18 00:36:05	1.192
@@ -1156,8 +1156,18 @@
 }
 ***********/
 
+ /*
+  * _lv_resume
+  * @cmd
+  * @lvid_s
+  * @origin_only
+  * @exclusive:  This parameter only has an affect in cluster-context.
+  *		 It forces local target type to be used (instead of
+  *		 cluster-aware type).
+  * @error_if_not_active
+  */
 static int _lv_resume(struct cmd_context *cmd, const char *lvid_s,
-		      unsigned origin_only,
+		      unsigned origin_only, unsigned exclusive,
 		      int error_if_not_active)
 {
 	struct logical_volume *lv;
@@ -1189,6 +1199,14 @@
 		goto out;
 	}
 
+	/*
+	 * When targets are activated exclusively in a cluster, the
+	 * non-clustered target should be used.  This only happens
+	 * if ACTIVATE_EXCL is set in lv->status.
+	 */
+	if (exclusive)
+		lv->status |= ACTIVATE_EXCL;
+
 	if (!_lv_activate_lv(lv, origin_only))
 		goto_out;
 
@@ -1206,14 +1224,15 @@
 }
 
 /* Returns success if the device is not active */
-int lv_resume_if_active(struct cmd_context *cmd, const char *lvid_s, unsigned origin_only)
+int lv_resume_if_active(struct cmd_context *cmd, const char *lvid_s,
+			unsigned origin_only, unsigned exclusive)
 {
-	return _lv_resume(cmd, lvid_s, origin_only, 0);
+	return _lv_resume(cmd, lvid_s, origin_only, exclusive, 0);
 }
 
 int lv_resume(struct cmd_context *cmd, const char *lvid_s, unsigned origin_only)
 {
-	return _lv_resume(cmd, lvid_s, origin_only, 1);
+	return _lv_resume(cmd, lvid_s, origin_only, 0, 1);
 }
 
 static int _lv_has_open_snapshots(struct logical_volume *lv)
--- LVM2/lib/activate/activate.h	2011/02/04 20:30:18	1.74
+++ LVM2/lib/activate/activate.h	2011/02/18 00:36:05	1.75
@@ -56,7 +56,8 @@
 /* int lv_suspend(struct cmd_context *cmd, const char *lvid_s); */
 int lv_suspend_if_active(struct cmd_context *cmd, const char *lvid_s, unsigned origin_only);
 int lv_resume(struct cmd_context *cmd, const char *lvid_s, unsigned origin_only);
-int lv_resume_if_active(struct cmd_context *cmd, const char *lvid_s, unsigned origin_only);
+int lv_resume_if_active(struct cmd_context *cmd, const char *lvid_s,
+			unsigned origin_only, unsigned exclusive);
 int lv_activate(struct cmd_context *cmd, const char *lvid_s, int exclusive);
 int lv_activate_with_filter(struct cmd_context *cmd, const char *lvid_s,
 			    int exclusive);
--- LVM2/lib/locking/file_locking.c	2011/02/04 19:18:17	1.57
+++ LVM2/lib/locking/file_locking.c	2011/02/18 00:36:05	1.58
@@ -293,7 +293,7 @@
 		switch (flags & LCK_TYPE_MASK) {
 		case LCK_UNLOCK:
 			log_very_verbose("Unlocking LV %s%s", resource, origin_only ? " without snapshots" : "");
-			if (!lv_resume_if_active(cmd, resource, origin_only))
+			if (!lv_resume_if_active(cmd, resource, origin_only, 0))
 				return 0;
 			break;
 		case LCK_NULL:
--- LVM2/lib/locking/no_locking.c	2011/02/04 19:21:47	1.27
+++ LVM2/lib/locking/no_locking.c	2011/02/18 00:36:05	1.28
@@ -46,7 +46,7 @@
 		case LCK_NULL:
 			return lv_deactivate(cmd, resource);
 		case LCK_UNLOCK:
-			return lv_resume_if_active(cmd, resource, (flags & LCK_ORIGIN_ONLY) ? 1: 0);
+			return lv_resume_if_active(cmd, resource, (flags & LCK_ORIGIN_ONLY) ? 1: 0, 0);
 		case LCK_READ:
 			return lv_activate_with_filter(cmd, resource, 0);
 		case LCK_WRITE:


