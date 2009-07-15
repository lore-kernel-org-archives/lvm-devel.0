From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 15 Jul 2009 05:49:49 -0000
Subject: LVM2 lib/locking/locking.c lib/locking/locking ...
Message-ID: <20090715054949.6035.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2009-07-15 05:49:48

Modified files:
	lib/locking    : locking.c locking_types.h no_locking.c 
	lib/metadata   : metadata.c 
	lib/misc       : lvm-globals.c 
	tools          : lvchange.c vgchange.c 

Log message:
	Remove lockingfailed().
	
	We provide a lock type that behaves like no_locking, but is not
	clustered. Moreover, it also forbids any write locks. This magically (and
	consistently) prevents use of clustered VGs, or changing local VGs with
	--ignorelockingfailure. As a bonus, we can remove the special hacks in a few
	places. Of course, people looking for trouble can always set their locking_type
	to 0 to override.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.c.diff?cvsroot=lvm2&r1=1.61&r2=1.62
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking_types.h.diff?cvsroot=lvm2&r1=1.17&r2=1.18
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/no_locking.c.diff?cvsroot=lvm2&r1=1.15&r2=1.16
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.251&r2=1.252
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-globals.c.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvchange.c.diff?cvsroot=lvm2&r1=1.107&r2=1.108
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgchange.c.diff?cvsroot=lvm2&r1=1.81&r2=1.82

--- LVM2/lib/locking/locking.c	2009/07/14 11:01:26	1.61
+++ LVM2/lib/locking/locking.c	2009/07/15 05:49:47	1.62
@@ -215,8 +215,6 @@
  */
 int init_locking(int type, struct cmd_context *cmd)
 {
-	init_lockingfailed(0);
-
 	if (type < 0)
 		type = find_config_tree_int(cmd, "global/locking_type", 1);
 		
@@ -279,9 +277,7 @@
 
 	/* FIXME Ensure only read ops are permitted */
 	log_verbose("Locking disabled - only read operations permitted.");
-
-	init_no_locking(&_locking, cmd);
-	init_lockingfailed(1);
+	init_readonly_locking(&_locking, cmd);
 
 	return 1;
 }
--- LVM2/lib/locking/locking_types.h	2009/05/21 03:04:53	1.17
+++ LVM2/lib/locking/locking_types.h	2009/07/15 05:49:48	1.18
@@ -40,6 +40,8 @@
  */
 int init_no_locking(struct locking_type *locking, struct cmd_context *cmd);
 
+int init_boottime_locking(struct locking_type *locking, struct cmd_context *cmd);
+
 int init_file_locking(struct locking_type *locking, struct cmd_context *cmd);
 
 int init_external_locking(struct locking_type *locking, struct cmd_context *cmd);
--- LVM2/lib/locking/no_locking.c	2008/04/07 19:17:29	1.15
+++ LVM2/lib/locking/no_locking.c	2009/07/15 05:49:48	1.16
@@ -66,6 +66,17 @@
 	return 1;
 }
 
+static int _readonly_lock_resource(struct cmd_context *cmd,
+				   const char *resource,
+				   uint32_t flags)
+{
+	if (flags & LCK_TYPE_MASK == LCK_WRITE) {
+		log_error("Write locks are prohibited with --ignorelockingfailure.");
+		return 0;
+	}
+	return _no_lock_resource(cmd, resource, flags);
+}
+
 int init_no_locking(struct locking_type *locking, struct cmd_context *cmd __attribute((unused)))
 {
 	locking->lock_resource = _no_lock_resource;
@@ -75,3 +86,13 @@
 
 	return 1;
 }
+
+int init_readonly_locking(struct locking_type *locking, struct cmd_context *cmd __attribute((unused)))
+{
+	locking->lock_resource = _readonly_lock_resource;
+	locking->reset_locking = _no_reset_locking;
+	locking->fin_locking = _no_fin_locking;
+	locking->flags = 0;
+
+	return 1;
+}
--- LVM2/lib/metadata/metadata.c	2009/07/15 05:47:55	1.251
+++ LVM2/lib/metadata/metadata.c	2009/07/15 05:49:48	1.252
@@ -2772,8 +2772,7 @@
 	uint32_t failure = 0;
 
 	if ((status & CLUSTERED) &&
-	    (vg_is_clustered(vg)) && !locking_is_clustered() &&
-	    !lockingfailed()) {
+	    (vg_is_clustered(vg)) && !locking_is_clustered()) {
 		log_error("Skipping clustered volume group %s", vg->name);
 		/* Return because other flags are considered undefined. */
 		return FAILED_CLUSTERED;
@@ -2922,8 +2921,7 @@
 		goto_bad;
 	}
 
-	if (vg_is_clustered(vg) && !locking_is_clustered() &&
-	    !lockingfailed()) {
+	if (vg_is_clustered(vg) && !locking_is_clustered()) {
 		log_error("Skipping clustered volume group %s", vg->name);
 		failure |= FAILED_CLUSTERED;
 		goto_bad;
--- LVM2/lib/misc/lvm-globals.c	2008/12/18 05:27:18	1.2
+++ LVM2/lib/misc/lvm-globals.c	2009/07/15 05:49:48	1.3
@@ -31,7 +31,6 @@
 static int _debug_level = 0;
 static int _log_cmd_name = 0;
 static int _ignorelockingfailure = 0;
-static int _lockingfailed = 0;
 static int _security_level = SECURITY_LEVEL;
 static char _cmd_name[30] = "";
 static int _mirror_in_sync = 0;
@@ -77,11 +76,6 @@
 	_ignorelockingfailure = level;
 }
 
-void init_lockingfailed(int level)
-{
-	_lockingfailed = level;
-}
-
 void init_security_level(int level)
 {
 	_security_level = level;
@@ -161,11 +155,6 @@
 	return _trust_cache;
 }
 
-int lockingfailed()
-{
-	return _lockingfailed;
-}
-
 int ignorelockingfailure()
 {
 	return _ignorelockingfailure;
--- LVM2/tools/lvchange.c	2009/07/15 05:48:36	1.107
+++ LVM2/tools/lvchange.c	2009/07/15 05:49:48	1.108
@@ -119,12 +119,6 @@
 		if (!deactivate_lv(cmd, lv))
 			return_0;
 	} else {
-		if (lockingfailed() && (vg_is_clustered(lv->vg))) {
-			log_verbose("Locking failed: ignoring clustered "
-				    "logical volume %s", lv->name);
-			return 0;
-		}
-
 		if (lv_is_origin(lv) || (activate == CHANGE_AE)) {
 			log_verbose("Activating logical volume \"%s\" "
 				    "exclusively", lv->name);
--- LVM2/tools/vgchange.c	2009/07/15 05:47:55	1.81
+++ LVM2/tools/vgchange.c	2009/07/15 05:49:48	1.82
@@ -144,14 +144,8 @@
 		return ECMD_FAILED;
 	}
 
-	if (activate && lockingfailed() && (vg_is_clustered(vg))) {
-		log_error("Locking inactive: ignoring clustered "
-			  "volume group %s", vg->name);
-		return ECMD_FAILED;
-	}
-
 	/* FIXME Move into library where clvmd can use it */
-	if (activate && !lockingfailed())
+	if (activate)
 		check_current_backup(vg);
 
 	if (activate && (active = lvs_in_vg_activated(vg))) {


