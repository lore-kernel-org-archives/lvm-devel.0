From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 20 Mar 2012 17:42:21 -0000
Subject: LVM2 ./WHATS_NEW lib/thin/thin.c
Message-ID: <20120320174221.5383.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-03-20 17:42:20

Modified files:
	.              : WHATS_NEW 
	lib/thin       : thin.c 

Log message:
	Fix regression in thin monitoring
	
	Patch https://www.redhat.com/archives/lvm-devel/2012-February/msg00118.html
	removed initilization of thin volume monitoring, leaving it only for
	thin pool - but missed the code move part for monitoring of thin pools.
	Effectively making thin pools not monitorable.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2360&r2=1.2361
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/thin/thin.c.diff?cvsroot=lvm2&r1=1.49&r2=1.50

--- LVM2/WHATS_NEW	2012/03/20 10:47:02	1.2360
+++ LVM2/WHATS_NEW	2012/03/20 17:42:19	1.2361
@@ -1,5 +1,6 @@
 Version 2.02.96 - 
 ================================
+  Fix initializiation of thin monitoring (2.02.92).
   Support improperly formated device numbers in /proc/devices (2.02.91).
   Fix fsadm propagation of -e option.
   Fix fsadm parsing of /proc/mounts files (don't check for substrings).
--- LVM2/lib/thin/thin.c	2012/03/02 21:43:26	1.49
+++ LVM2/lib/thin/thin.c	2012/03/20 17:42:20	1.50
@@ -337,6 +337,43 @@
 
 	return 1;
 }
+
+#  ifdef DMEVENTD
+static const char *_get_thin_dso_path(struct cmd_context *cmd)
+{
+	return get_monitor_dso_path(cmd, find_config_tree_str(cmd, "dmeventd/thin_library",
+							      DEFAULT_DMEVENTD_THIN_LIB));
+}
+
+/* FIXME Cache this */
+static int _target_registered(struct lv_segment *seg, int *pending)
+{
+	return target_registered_with_dmeventd(seg->lv->vg->cmd,
+					       _get_thin_dso_path(seg->lv->vg->cmd),
+					       seg->lv, pending);
+}
+
+/* FIXME This gets run while suspended and performs banned operations. */
+static int _target_set_events(struct lv_segment *seg, int evmask, int set)
+{
+	/* FIXME Make timeout (10) configurable */
+	return target_register_events(seg->lv->vg->cmd,
+				      _get_thin_dso_path(seg->lv->vg->cmd),
+				      seg->lv, evmask, set, 10);
+}
+
+static int _target_register_events(struct lv_segment *seg,
+				   int events)
+{
+	return _target_set_events(seg, events, 1);
+}
+
+static int _target_unregister_events(struct lv_segment *seg,
+				     int events)
+{
+	return _target_set_events(seg, events, 0);
+}
+#  endif /* DMEVENTD */
 #endif /* DEVMAPPER_SUPPORT */
 
 static const char *_thin_name(const struct lv_segment *seg)
@@ -462,43 +499,6 @@
 
 	return _present;
 }
-
-#  ifdef DMEVENTD
-static const char *_get_thin_dso_path(struct cmd_context *cmd)
-{
-	return get_monitor_dso_path(cmd, find_config_tree_str(cmd, "dmeventd/thin_library",
-							      DEFAULT_DMEVENTD_THIN_LIB));
-}
-
-/* FIXME Cache this */
-static int _target_registered(struct lv_segment *seg, int *pending)
-{
-	return target_registered_with_dmeventd(seg->lv->vg->cmd,
-					       _get_thin_dso_path(seg->lv->vg->cmd),
-					       seg->pool_lv, pending);
-}
-
-/* FIXME This gets run while suspended and performs banned operations. */
-static int _target_set_events(struct lv_segment *seg, int evmask, int set)
-{
-	/* FIXME Make timeout (10) configurable */
-	return target_register_events(seg->lv->vg->cmd,
-				      _get_thin_dso_path(seg->lv->vg->cmd),
-				      seg->pool_lv, evmask, set, 10);
-}
-
-static int _target_register_events(struct lv_segment *seg,
-				   int events)
-{
-	return _target_set_events(seg, events, 1);
-}
-
-static int _target_unregister_events(struct lv_segment *seg,
-				     int events)
-{
-	return _target_set_events(seg, events, 0);
-}
-#  endif /* DMEVENTD */
 #endif
 
 static int _thin_modules_needed(struct dm_pool *mem,
@@ -527,6 +527,11 @@
 	.add_target_line = _thin_pool_add_target_line,
 	.target_percent = _thin_pool_target_percent,
 	.target_present = _thin_target_present,
+#  ifdef DMEVENTD
+	.target_monitored = _target_registered,
+	.target_monitor_events = _target_register_events,
+	.target_unmonitor_events = _target_unregister_events,
+#  endif /* DMEVENTD */
 #endif
 	.modules_needed = _thin_modules_needed,
 	.destroy = _thin_destroy,
@@ -540,11 +545,6 @@
 	.add_target_line = _thin_add_target_line,
 	.target_percent = _thin_target_percent,
 	.target_present = _thin_target_present,
-#  ifdef DMEVENTD
-	.target_monitored = _target_registered,
-	.target_monitor_events = _target_register_events,
-	.target_unmonitor_events = _target_unregister_events,
-#  endif /* DMEVENTD */
 #endif
 	.modules_needed = _thin_modules_needed,
 	.destroy = _thin_destroy,


