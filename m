From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 18 Feb 2011 14:29:47 -0000
Subject: LVM2 ./WHATS_NEW lib/activate/activate.c lib/m ...
Message-ID: <20110218142947.9944.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-02-18 14:29:42

Modified files:
	.              : WHATS_NEW 
	lib/activate   : activate.c 
	lib/mirror     : mirrored.c 
	lib/snapshot   : snapshot.c 

Log message:
	Fix !DEVMAPPER_SUPPORT build
	
	Fix build when devmapper is disabled.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1917&r2=1.1918
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.194&r2=1.195
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mirror/mirrored.c.diff?cvsroot=lvm2&r1=1.83&r2=1.84
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/snapshot/snapshot.c.diff?cvsroot=lvm2&r1=1.52&r2=1.53

--- LVM2/WHATS_NEW	2011/02/18 14:26:31	1.1917
+++ LVM2/WHATS_NEW	2011/02/18 14:29:39	1.1918
@@ -1,5 +1,6 @@
 Version 2.02.85 - 
 ===================================
+  Fix compilation when devmapper is dissabled.
   Remove fs_unlock() from lv_suspend error path.
   Change memory locking semantic and use critical sections.
   Add configurable pv_min_size to select block devices by its size.
--- LVM2/lib/activate/activate.c	2011/02/18 14:26:31	1.194
+++ LVM2/lib/activate/activate.c	2011/02/18 14:29:39	1.195
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2011 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -171,7 +171,7 @@
 {
 	return 0;
 }
-int lvs_in_vg_opened(struct volume_group *vg)
+int lvs_in_vg_opened(const struct volume_group *vg)
 {
 	return 0;
 }
@@ -181,15 +181,16 @@
 	return 1;
 }
 *******/
-int lv_suspend_if_active(struct cmd_context *cmd, const char *lvid_s)
+int lv_suspend_if_active(struct cmd_context *cmd, const char *lvid_s, unsigned origin_only)
 {
 	return 1;
 }
-int lv_resume(struct cmd_context *cmd, const char *lvid_s)
+int lv_resume(struct cmd_context *cmd, const char *lvid_s, unsigned origin_only)
 {
 	return 1;
 }
-int lv_resume_if_active(struct cmd_context *cmd, const char *lvid_s)
+int lv_resume_if_active(struct cmd_context *cmd, const char *lvid_s,
+			unsigned origin_only, unsigned exclusive)
 {
 	return 1;
 }
@@ -210,28 +211,42 @@
 {
 	return 1;
 }
-
 int lv_mknodes(struct cmd_context *cmd, const struct logical_volume *lv)
 {
 	return 1;
 }
-
 int pv_uses_vg(struct physical_volume *pv,
 	       struct volume_group *vg)
 {
 	return 0;
 }
-
 void activation_release(void)
 {
-	return;
 }
-
 void activation_exit(void)
 {
-	return;
 }
-
+int lv_is_active(struct logical_volume *lv)
+{
+	return 0;
+}
+int lv_is_active_exclusive_locally(struct logical_volume *lv)
+{
+	return 0;
+}
+int lv_is_active_exclusive_remotely(struct logical_volume *lv)
+{
+	return 0;
+}
+int lv_check_transient(struct logical_volume *lv)
+{
+	return 1;
+}
+int monitor_dev_for_events(struct cmd_context *cmd, struct logical_volume *lv,
+			   unsigned origin_only, int monitor)
+{
+	return 1;
+}
 #else				/* DEVMAPPER_SUPPORT */
 
 static int _activation = 1;
--- LVM2/lib/mirror/mirrored.c	2011/01/05 12:27:56	1.83
+++ LVM2/lib/mirror/mirrored.c	2011/02/18 14:29:40	1.84
@@ -30,9 +30,6 @@
 
 #include <sys/utsname.h>
 
-static int _block_on_error_available = 0;
-static unsigned _mirror_attributes = 0;
-
 enum {
 	MIRR_DISABLED,
 	MIRR_RUNNING,
@@ -158,6 +155,9 @@
 }
 
 #ifdef DEVMAPPER_SUPPORT
+static int _block_on_error_available = 0;
+static unsigned _mirror_attributes = 0;
+
 static struct mirror_state *_mirrored_init_target(struct dm_pool *mem,
 					 struct cmd_context *cmd)
 {
@@ -641,10 +641,12 @@
 	segtype->private = NULL;
 	segtype->flags = SEG_AREAS_MIRRORED;
 
+#ifdef DEVMAPPER_SUPPORT
 #ifdef DMEVENTD
 	if (_get_mirror_dso_path(cmd))
 		segtype->flags |= SEG_MONITORED;
 #endif
+#endif
 
 	log_very_verbose("Initialised segtype: %s", segtype->name);
 
--- LVM2/lib/snapshot/snapshot.c	2010/12/20 13:32:50	1.52
+++ LVM2/lib/snapshot/snapshot.c	2011/02/18 14:29:41	1.53
@@ -260,10 +260,12 @@
 	segtype->private = NULL;
 	segtype->flags = SEG_SNAPSHOT;
 
+#ifdef DEVMAPPER_SUPPORT
 #ifdef DMEVENTD
 	if (_get_snapshot_dso_path(cmd))
 		segtype->flags |= SEG_MONITORED;
 #endif
+#endif
 	log_very_verbose("Initialised segtype: %s", segtype->name);
 
 	return segtype;


