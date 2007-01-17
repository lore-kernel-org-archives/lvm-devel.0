From: agk@sourceware.org <agk@sourceware.org>
Date: 17 Jan 2007 15:00:57 -0000
Subject: LVM2/lib/mirror mirrored.c
Message-ID: <20070117150057.18109.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-01-17 15:00:57

Modified files:
	lib/mirror     : mirrored.c 

Log message:
	merge  _target_*register_events
	introduce _create_dm_event_handler()

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mirror/mirrored.c.diff?cvsroot=lvm2&r1=1.42&r2=1.43

--- LVM2/lib/mirror/mirrored.c	2007/01/16 23:05:13	1.42
+++ LVM2/lib/mirror/mirrored.c	2007/01/17 15:00:57	1.43
@@ -368,7 +368,7 @@
 }
 
 #ifdef DMEVENTD
-static int _setup_registration(struct cmd_context *cmd, char **dso)
+static int _get_mirror_dso_path(struct cmd_context *cmd, char **dso)
 {
 	char *path;
 	const char *libpath;
@@ -388,6 +388,29 @@
 	return 1;
 }
 
+static struct dm_event_handler *_create_dm_event_handler(const char *dmname,
+							 const char *dso,
+							 enum dm_event_mask mask)
+{
+	struct dm_event_handler *dmevh;
+
+	if (!(dmevh = dm_event_handler_create()))
+		return_0;
+
+       if (dm_event_handler_set_dso(dmevh, dso))
+		goto fail;
+
+	if (dm_event_handler_set_dev_name(dmevh, dmname))
+		goto fail;
+
+	dm_event_handler_set_event_mask(dmevh, mask);
+	return dmevh;
+
+fail:
+	dm_event_handler_destroy(dmevh);
+	return NULL;
+}
+
 static int _target_registered(struct lv_segment *seg, int *pending)
 {
 	char *dso, *name;
@@ -400,21 +423,15 @@
 	vg = lv->vg;
 
 	*pending = 0;
-	if (!_setup_registration(vg->cmd, &dso)) {
-		stack;
-		return 0;
-	}
+	if (!_get_mirror_dso_path(vg->cmd, &dso))
+		return_0;
 
 	if (!(name = build_dm_name(vg->cmd->mem, vg->name, lv->name, NULL)))
 		return_0;
 
-	if (!(dmevh = dm_event_handler_create()))
+	if (!(dmevh = _create_dm_event_handler(name, dso, DM_EVENT_ALL_ERRORS)))
 		return_0;
 
-	dm_event_handler_set_dso(dmevh, dso);
-	dm_event_handler_set_dev_name(dmevh, name);
-	dm_event_handler_set_event_mask(dmevh, DM_EVENT_ALL_ERRORS);
-
 	if (dm_event_get_registered_device(dmevh, 0)) {
 		dm_event_handler_destroy(dmevh);
 		return 0;
@@ -432,79 +449,50 @@
 }
 
 /* FIXME This gets run while suspended and performs banned operations. */
-/* FIXME Merge these two functions */
-static int _target_register_events(struct cmd_context *cmd,
+static int _target_set_events(struct cmd_context *cmd,
 				   struct lv_segment *seg,
-				   int evmask)
+				   int evmask, int set)
 {
 	char *dso, *name;
 	struct logical_volume *lv;
 	struct volume_group *vg;
 	struct dm_event_handler *dmevh;
+	int r;
 
 	lv = seg->lv;
 	vg = lv->vg;
 
-	if (!_setup_registration(cmd, &dso)) {
-		stack;
-		return 0;
-	}
+	if (!_get_mirror_dso_path(cmd, &dso))
+		return_0;
 
 	if (!(name = build_dm_name(cmd->mem, vg->name, lv->name, NULL)))
 		return_0;
 
-	if (!(dmevh = dm_event_handler_create()))
+	if (!(dmevh = _create_dm_event_handler(name, dso, DM_EVENT_ALL_ERRORS)))
 		return_0;
 
-	dm_event_handler_set_dso(dmevh, dso);
-	dm_event_handler_set_dev_name(dmevh, name);
-	dm_event_handler_set_event_mask(dmevh, DM_EVENT_ALL_ERRORS);
-	if (!dm_event_register_handler(dmevh)) {
-		dm_event_handler_destroy(dmevh);
-		return_0;
-	}
+	r = set ? dm_event_register_handler(dmevh) : dm_event_unregister_handler(dmevh);
 	dm_event_handler_destroy(dmevh);
+	if (!r)
+		return_0;
 
-	log_info("Registered %s for events", name);
+	log_info("%s %s for events", set ? "Registered" : "Unregistered", name);
 
 	return 1;
 }
 
-static int _target_unregister_events(struct cmd_context *cmd,
+static int _target_register_events(struct cmd_context *cmd,
 				     struct lv_segment *seg,
-				     int evmask)
+				     int events)
 {
-	char *dso;
-	char *name;
-	struct logical_volume *lv;
-	struct volume_group *vg;
-	struct dm_event_handler *dmevh;
-
-	lv = seg->lv;
-	vg = lv->vg;
-
-	/* FIXME Remove this and use handle to avoid config file race */
-	if (!_setup_registration(cmd, &dso))
-		return_0;
-
-	if (!(name = build_dm_name(cmd->mem, vg->name, lv->name, NULL)))
-		return_0;
-
-	if (!(dmevh = dm_event_handler_create()))
-		return_0;
-
-	dm_event_handler_set_dso(dmevh, dso);
-	dm_event_handler_set_dev_name(dmevh, name);
-	dm_event_handler_set_event_mask(dmevh, DM_EVENT_ALL_ERRORS);
-	if (!dm_event_unregister_handler(dmevh)) {
-		dm_event_handler_destroy(dmevh);
-		return_0;
-	}
-	dm_event_handler_destroy(dmevh);
-
-	log_info("Unregistered %s for events", name);
+	return _target_set_events(cmd, seg, events, 1);
+}
 
-	return 1;
+static int _target_unregister_events(struct cmd_context *cmd,
+				     struct lv_segment *seg,
+				     int events)
+{
+	return _target_set_events(cmd, seg, events, 0);
 }
 
 #endif /* DMEVENTD */


