From: agk@sourceware.org <agk@sourceware.org>
Date: 17 Aug 2010 01:16:42 -0000
Subject: LVM2 ./WHATS_NEW lib/activate/activate.c lib/a ...
Message-ID: <20100817011642.30578.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-08-17 01:16:41

Modified files:
	.              : WHATS_NEW 
	lib/activate   : activate.c activate.h 
	lib/mirror     : mirrored.c 
	lib/snapshot   : snapshot.c 
	tools          : vgchange.c 

Log message:
	Monitor origin -real device below snapshot instead of overlay device. (brassow)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1705&r2=1.1706
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.175&r2=1.176
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.h.diff?cvsroot=lvm2&r1=1.69&r2=1.70
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mirror/mirrored.c.diff?cvsroot=lvm2&r1=1.76&r2=1.77
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/snapshot/snapshot.c.diff?cvsroot=lvm2&r1=1.48&r2=1.49
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgchange.c.diff?cvsroot=lvm2&r1=1.111&r2=1.112

--- LVM2/WHATS_NEW	2010/08/16 23:29:09	1.1705
+++ LVM2/WHATS_NEW	2010/08/17 01:16:41	1.1706
@@ -1,5 +1,6 @@
 Version 2.02.73 - 
 ================================
+  Monitor origin -real device below snapshot instead of overlay device.
   Don't really change monitoring status when in test mode.
   Fix some exit statuses when starting/stopping monitoring fails.
   Enable snapshot monitoring by default when dmeventd is enabled.
--- LVM2/lib/activate/activate.c	2010/08/16 23:29:10	1.175
+++ LVM2/lib/activate/activate.c	2010/08/17 01:16:41	1.176
@@ -770,7 +770,8 @@
 	return path;
 }
 
-int target_registered_with_dmeventd(struct cmd_context *cmd, const char *dso, const char *lvid, int *pending)
+int target_registered_with_dmeventd(struct cmd_context *cmd, const char *dso,
+				    struct logical_volume *lv, int *pending)
 {
 	char *uuid;
 	enum dm_event_mask evmask = 0;
@@ -781,7 +782,8 @@
 	if (!dso)
 		return_0;
 
-	if (!(uuid = build_dm_uuid(cmd->mem, lvid, NULL)))
+	/* We always monitor the "real" device, never the "snapshot-origin" itself. */
+	if (!(uuid = build_dm_uuid(cmd->mem, lv->lvid.s, lv_is_origin(lv) ? "real" : NULL)))
 		return_0;
 
 	if (!(dmevh = _create_dm_event_handler(cmd, uuid, dso, 0, DM_EVENT_ALL_ERRORS)))
@@ -803,7 +805,7 @@
 	return evmask;
 }
 
-int target_register_events(struct cmd_context *cmd, const char *dso, const char *lvid,
+int target_register_events(struct cmd_context *cmd, const char *dso, struct logical_volume *lv,
 			    int evmask __attribute__((unused)), int set, int timeout)
 {
 	char *uuid;
@@ -813,7 +815,8 @@
 	if (!dso)
 		return_0;
 
-	if (!(uuid = build_dm_uuid(cmd->mem, lvid, NULL)))
+	/* We always monitor the "real" device, never the "snapshot-origin" itself. */
+	if (!(uuid = build_dm_uuid(cmd->mem, lv->lvid.s, lv_is_origin(lv) ? "real" : NULL)))
 		return_0;
 
 	if (!(dmevh = _create_dm_event_handler(cmd, uuid, dso, timeout,
@@ -869,18 +872,14 @@
 
 	/*
 	 * In case this LV is a snapshot origin, we instead monitor
-	 * each of its respective snapshots (the origin itself does
-	 * not need to be monitored).
-	 *
-	 * TODO: This may change when snapshots of mirrors are allowed.
+	 * each of its respective snapshots.  The origin itself may
+	 * also need to be monitored if it is a mirror, for example.
 	 */
-	if (lv_is_origin(lv)) {
+	if (lv_is_origin(lv))
 		dm_list_iterate_safe(snh, snht, &lv->snapshot_segs)
 			if (!monitor_dev_for_events(cmd, dm_list_struct_base(snh,
 				    struct lv_segment, origin_list)->cow, monitor))
 				r = 0;
-		return r;
-	}
 
 	/*
 	 * If the volume is mirrored and its log is also mirrored, monitor
--- LVM2/lib/activate/activate.h	2010/08/16 22:54:36	1.69
+++ LVM2/lib/activate/activate.h	2010/08/17 01:16:41	1.70
@@ -105,8 +105,9 @@
 #ifdef DMEVENTD
 #  include "libdevmapper-event.h"
 char *get_monitor_dso_path(struct cmd_context *cmd, const char *libpath);
-int target_registered_with_dmeventd(struct cmd_context *cmd, const char *libpath, const char *lvid, int *pending);
-int target_register_events(struct cmd_context *cmd, const char *dso, const char *lvid,
+int target_registered_with_dmeventd(struct cmd_context *cmd, const char *libpath,
+				    struct logical_volume *lv, int *pending);
+int target_register_events(struct cmd_context *cmd, const char *dso, struct logical_volume *lv,
 			    int evmask __attribute__((unused)), int set, int timeout);
 #endif
 
--- LVM2/lib/mirror/mirrored.c	2010/08/16 22:54:36	1.76
+++ LVM2/lib/mirror/mirrored.c	2010/08/17 01:16:41	1.77
@@ -548,17 +548,18 @@
 							      DEFAULT_DMEVENTD_MIRROR_LIB));
 }
 
+/* FIXME Cache this */
 static int _target_registered(struct lv_segment *seg, int *pending)
 {
 	return target_registered_with_dmeventd(seg->lv->vg->cmd, _get_mirror_dso_path(seg->lv->vg->cmd),
-					       seg->lv->lvid.s, pending);
+					       seg->lv, pending);
 }
 
 /* FIXME This gets run while suspended and performs banned operations. */
 static int _target_set_events(struct lv_segment *seg, int evmask, int set)
 {
 	return target_register_events(seg->lv->vg->cmd, _get_mirror_dso_path(seg->lv->vg->cmd),
-				      seg->lv->lvid.s, evmask, set, 0);
+				      seg->lv, evmask, set, 0);
 }
 
 static int _target_monitor_events(struct lv_segment *seg, int events)
--- LVM2/lib/snapshot/snapshot.c	2010/08/16 22:54:36	1.48
+++ LVM2/lib/snapshot/snapshot.c	2010/08/17 01:16:41	1.49
@@ -168,10 +168,11 @@
 							      DEFAULT_DMEVENTD_SNAPSHOT_LIB));
 }
 
+/* FIXME Cache this */
 static int _target_registered(struct lv_segment *seg, int *pending)
 {
 	return target_registered_with_dmeventd(seg->lv->vg->cmd, _get_snapshot_dso_path(seg->lv->vg->cmd),
-					       seg->cow->lvid.s, pending);
+					       seg->cow, pending);
 }
 
 /* FIXME This gets run while suspended and performs banned operations. */
@@ -179,7 +180,7 @@
 {
 	/* FIXME Make timeout (10) configurable */
 	return target_register_events(seg->lv->vg->cmd, _get_snapshot_dso_path(seg->lv->vg->cmd),
-				      seg->cow->lvid.s, evmask, set, 10);
+				      seg->cow, evmask, set, 10);
 }
 
 static int _target_register_events(struct lv_segment *seg,
--- LVM2/tools/vgchange.c	2010/08/16 22:54:37	1.111
+++ LVM2/tools/vgchange.c	2010/08/17 01:16:41	1.112
@@ -190,7 +190,7 @@
 
 static int _vgchange_available(struct cmd_context *cmd, struct volume_group *vg)
 {
-	int lv_open, active, monitored;
+	int lv_open, active, monitored = 0;
 	int available, ret_max = ECMD_PROCESSED;
 	int activate = 1;
 


