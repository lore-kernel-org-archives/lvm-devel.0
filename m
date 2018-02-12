From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 12 Feb 2018 16:20:51 -0500
Subject: master - activation: separate reporting of error and monitoring status
Message-ID: <201802122120.w1CLKp0E023752@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d90a6478026dc2810947d552d6165ec7f0534894
Commit:        d90a6478026dc2810947d552d6165ec7f0534894
Parent:        12fba201be314dd16ea01fc756e39c04c8ba50c3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jan 29 16:28:57 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 12 22:14:59 2018 +0100

activation: separate reporting of error and monitoring status

Avoid using same return code for reporting 2 different things
and stricly report error code by return value and add new
parameter for reporting monitoring status.

This makes easier to recognize which error we got from dm_event
and continue only with  ENOENT.
---
 WHATS_NEW                             |    1 +
 daemons/dmeventd/libdevmapper-event.c |    7 +--
 lib/activate/activate.c               |   84 ++++++++++++++++++++++++--------
 lib/activate/activate.h               |    2 +-
 lib/metadata/lv.c                     |   14 +++--
 lib/metadata/segtype.h                |    2 +-
 lib/mirror/mirrored.c                 |    4 +-
 lib/raid/raid.c                       |    4 +-
 lib/snapshot/snapshot.c               |    7 ++-
 lib/thin/thin.c                       |    4 +-
 10 files changed, 87 insertions(+), 42 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 1ffa3db..2bded4d 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.178 - 
 =====================================
+  Separate reporting of monitoring status and error status.
   Improve validation of created strings in vgimportclone.
   Add missing initialisation of mem pool in systemd generator.
   Do not reopen output streams for multithreaded users of liblvm.
diff --git a/daemons/dmeventd/libdevmapper-event.c b/daemons/dmeventd/libdevmapper-event.c
index 210e384..9aeb4c5 100644
--- a/daemons/dmeventd/libdevmapper-event.c
+++ b/daemons/dmeventd/libdevmapper-event.c
@@ -754,11 +754,10 @@ int dm_event_get_registered_device(struct dm_event_handler *dmevh, int next)
 	uuid = dm_task_get_uuid(dmt);
 
 	/* FIXME Distinguish errors connecting to daemon */
-	if (_do_event(next ? DM_EVENT_CMD_GET_NEXT_REGISTERED_DEVICE :
-		      DM_EVENT_CMD_GET_REGISTERED_DEVICE, dmevh->dmeventd_path,
-		      &msg, dmevh->dso, uuid, dmevh->mask, 0)) {
+	if ((ret = _do_event(next ? DM_EVENT_CMD_GET_NEXT_REGISTERED_DEVICE :
+			    DM_EVENT_CMD_GET_REGISTERED_DEVICE, dmevh->dmeventd_path,
+			    &msg, dmevh->dso, uuid, dmevh->mask, 0))) {
 		log_debug("%s: device not registered.", dm_task_get_name(dmt));
-		ret = -ENOENT;
 		goto fail;
 	}
 
diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 58e6873..6a4bc32 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -1681,6 +1681,7 @@ static struct dm_event_handler *_create_dm_event_handler(struct cmd_context *cmd
 
 bad:
 	dm_event_handler_destroy(dmevh);
+
 	return NULL;
 }
 
@@ -1712,13 +1713,18 @@ static char *_build_target_uuid(struct cmd_context *cmd, const struct logical_vo
 	return build_dm_uuid(cmd->mem, lv, layer);
 }
 
-static int _device_registered_with_dmeventd(struct cmd_context *cmd, const struct logical_volume *lv, int *pending, const char **dso)
+static int _device_registered_with_dmeventd(struct cmd_context *cmd,
+					    const struct logical_volume *lv,
+					    const char **dso,
+					    int *pending, int *monitored)
 {
 	char *uuid;
-	enum dm_event_mask evmask = 0;
+	enum dm_event_mask evmask;
 	struct dm_event_handler *dmevh;
+	int r;
 
 	*pending = 0;
+	*monitored = 0;
 
 	if (!(uuid = _build_target_uuid(cmd, lv)))
 		return_0;
@@ -1726,9 +1732,20 @@ static int _device_registered_with_dmeventd(struct cmd_context *cmd, const struc
 	if (!(dmevh = _create_dm_event_handler(cmd, uuid, NULL, 0, DM_EVENT_ALL_ERRORS)))
 		return_0;
 
-	if (dm_event_get_registered_device(dmevh, 0)) {
-		dm_event_handler_destroy(dmevh);
-		return 0;
+	if ((r = dm_event_get_registered_device(dmevh, 0))) {
+		if (r == -ENOENT) {
+			r = 1;
+			goto out;
+		}
+		r = 0;
+		goto_out;
+	}
+
+	/* FIXME: why do we care which 'dso' is monitoring? */
+	if (dso && (*dso = dm_event_handler_get_dso(dmevh)) &&
+	    !(*dso = dm_pool_strdup(cmd->mem, *dso))) {
+		r = 0;
+		goto_out;
 	}
 
 	evmask = dm_event_handler_get_event_mask(dmevh);
@@ -1737,21 +1754,25 @@ static int _device_registered_with_dmeventd(struct cmd_context *cmd, const struc
 		evmask &= ~DM_EVENT_REGISTRATION_PENDING;
 	}
 
-	if (dso && (*dso = dm_event_handler_get_dso(dmevh)) && !(*dso = dm_pool_strdup(cmd->mem, *dso)))
-		log_error("Failed to duplicate dso name.");
-
+	*monitored = evmask;
+	r = 1;
+out:
 	dm_event_handler_destroy(dmevh);
 
-	return evmask;
+	return r;
 }
 
 int target_registered_with_dmeventd(struct cmd_context *cmd, const char *dso,
-				    const struct logical_volume *lv, int *pending)
+				    const struct logical_volume *lv,
+				    int *pending, int *monitored)
 {
 	char *uuid;
-	enum dm_event_mask evmask = 0;
+	enum dm_event_mask evmask;
 	struct dm_event_handler *dmevh;
+	int r;
+
 	*pending = 0;
+	*monitored = 0;
 
 	if (!dso)
 		return_0;
@@ -1762,9 +1783,13 @@ int target_registered_with_dmeventd(struct cmd_context *cmd, const char *dso,
 	if (!(dmevh = _create_dm_event_handler(cmd, uuid, dso, 0, DM_EVENT_ALL_ERRORS)))
 		return_0;
 
-	if (dm_event_get_registered_device(dmevh, 0)) {
-		dm_event_handler_destroy(dmevh);
-		return 0;
+	if ((r = dm_event_get_registered_device(dmevh, 0))) {
+		if (r == -ENOENT) {
+			r = 1;
+			goto out;
+		}
+		r = 0;
+		goto_out;
 	}
 
 	evmask = dm_event_handler_get_event_mask(dmevh);
@@ -1773,9 +1798,12 @@ int target_registered_with_dmeventd(struct cmd_context *cmd, const char *dso,
 		evmask &= ~DM_EVENT_REGISTRATION_PENDING;
 	}
 
+	*monitored = evmask;
+	r = 1;
+out:
 	dm_event_handler_destroy(dmevh);
 
-	return evmask;
+	return r;
 }
 
 int target_register_events(struct cmd_context *cmd, const char *dso, const struct logical_volume *lv,
@@ -1818,7 +1846,7 @@ int monitor_dev_for_events(struct cmd_context *cmd, const struct logical_volume
 			   const struct lv_activate_opts *laopts, int monitor)
 {
 #ifdef DMEVENTD
-	int i, pending = 0, monitored;
+	int i, pending = 0, monitored = 0;
 	int r = 1;
 	struct dm_list *snh, *snht;
 	struct lv_segment *seg;
@@ -1964,11 +1992,21 @@ int monitor_dev_for_events(struct cmd_context *cmd, const struct logical_volume
 		    !seg->segtype->ops->target_monitored) /* doesn't support registration */
 			continue;
 
-		if (!monitor)
+		if (!monitor) {
 			/* When unmonitoring, obtain existing dso being used. */
-			monitored = _device_registered_with_dmeventd(cmd, seg_is_snapshot(seg) ? seg->cow : seg->lv, &pending, &dso);
-		else
-			monitored = seg->segtype->ops->target_monitored(seg, &pending);
+			if (!_device_registered_with_dmeventd(cmd, seg_is_snapshot(seg) ? seg->cow : seg->lv,
+							      &dso, &pending, &monitored)) {
+				log_warn("WARNING: Failed to %smonitor %s.",
+					 monitor ? "" : "un",
+					 display_lvname(seg_is_snapshot(seg) ? seg->cow : seg->lv));
+				return 0;
+			}
+		} else if (!seg->segtype->ops->target_monitored(seg, &pending, &monitored)) {
+			log_warn("WARNING: Failed to %smonitor %s.",
+				 monitor ? "" : "un",
+				 display_lvname(seg->lv));
+			return 0;
+		}
 
 		/* FIXME: We should really try again if pending */
 		monitored = (pending) ? 0 : monitored;
@@ -2021,7 +2059,11 @@ int monitor_dev_for_events(struct cmd_context *cmd, const struct logical_volume
 		/* Try a couple times if pending, but not forever... */
 		for (i = 0;; i++) {
 			pending = 0;
-			monitored = seg->segtype->ops->target_monitored(seg, &pending);
+			if (!seg->segtype->ops->target_monitored(seg, &pending, &monitored)) {
+				stack;
+				r = 0;
+				break;
+			}
 			if (!pending || i >= 40)
 				break;
 			log_very_verbose("%s %smonitoring still pending: waiting...",
diff --git a/lib/activate/activate.h b/lib/activate/activate.h
index 25b7cc8..b1cc176 100644
--- a/lib/activate/activate.h
+++ b/lib/activate/activate.h
@@ -208,7 +208,7 @@ int monitor_dev_for_events(struct cmd_context *cmd, const struct logical_volume
 #  include "libdevmapper-event.h"
 char *get_monitor_dso_path(struct cmd_context *cmd, const char *libpath);
 int target_registered_with_dmeventd(struct cmd_context *cmd, const char *dso,
-				    const struct logical_volume *lv, int *pending);
+				    const struct logical_volume *lv, int *pending, int *monitored);
 int target_register_events(struct cmd_context *cmd, const char *dso, const struct logical_volume *lv,
 			    int evmask __attribute__((unused)), int set, int timeout);
 #endif
diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 630880f..b19ae34 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -298,7 +298,7 @@ char *lvseg_monitor_dup(struct dm_pool *mem, const struct lv_segment *seg)
 
 #ifdef DMEVENTD
 	struct lvinfo info;
-	int pending = 0, monitored;
+	int pending = 0, monitored = 0;
 	struct lv_segment *segm = (struct lv_segment *) seg;
 
 	if (lv_is_cow(seg->lv) && !lv_is_merging_cow(seg->lv))
@@ -314,11 +314,13 @@ char *lvseg_monitor_dup(struct dm_pool *mem, const struct lv_segment *seg)
 	else if (!seg_monitored(segm) || (segm->status & PVMOVE))
 		s = "not monitored";
 	else if (lv_info(seg->lv->vg->cmd, seg->lv, 1, &info, 0, 0) && info.exists) {
-		monitored = segm->segtype->ops->target_monitored(segm, &pending);
-		if (pending)
-			s = "pending";
-		else
-			s = (monitored) ? "monitored" : "not monitored";
+		if (segm->segtype->ops->target_monitored(segm, &pending, &monitored)) {
+			if (pending)
+				s = "pending";
+			else
+				s = (monitored) ? "monitored" : "not monitored";
+		} else
+			s = "not monitored";
 	} // else log_debug("Not active");
 #endif
 	return dm_pool_strdup(mem, s);
diff --git a/lib/metadata/segtype.h b/lib/metadata/segtype.h
index 61a6580..fd8646c 100644
--- a/lib/metadata/segtype.h
+++ b/lib/metadata/segtype.h
@@ -259,7 +259,7 @@ struct segtype_handler {
 			       const struct lv_segment *seg,
 			       struct dm_list *modules);
 	void (*destroy) (struct segment_type * segtype);
-	int (*target_monitored) (struct lv_segment *seg, int *pending);
+	int (*target_monitored) (struct lv_segment *seg, int *pending, int *monitored);
 	int (*target_monitor_events) (struct lv_segment *seg, int events);
 	int (*target_unmonitor_events) (struct lv_segment *seg, int events);
 };
diff --git a/lib/mirror/mirrored.c b/lib/mirror/mirrored.c
index 602c30a..012501e 100644
--- a/lib/mirror/mirrored.c
+++ b/lib/mirror/mirrored.c
@@ -486,10 +486,10 @@ static const char *_get_mirror_dso_path(struct cmd_context *cmd)
 }
 
 /* FIXME Cache this */
-static int _target_registered(struct lv_segment *seg, int *pending)
+static int _target_registered(struct lv_segment *seg, int *pending, int *monitored)
 {
 	return target_registered_with_dmeventd(seg->lv->vg->cmd, _get_mirror_dso_path(seg->lv->vg->cmd),
-					       seg->lv, pending);
+					       seg->lv, pending, monitored);
 }
 
 /* FIXME This gets run while suspended and performs banned operations. */
diff --git a/lib/raid/raid.c b/lib/raid/raid.c
index 5d2e1ea..9b85373 100644
--- a/lib/raid/raid.c
+++ b/lib/raid/raid.c
@@ -544,12 +544,12 @@ static const char *_get_raid_dso_path(struct cmd_context *cmd)
 	return get_monitor_dso_path(cmd, config_str);
 }
 
-static int _raid_target_monitored(struct lv_segment *seg, int *pending)
+static int _raid_target_monitored(struct lv_segment *seg, int *pending, int *monitored)
 {
 	struct cmd_context *cmd = seg->lv->vg->cmd;
 	const char *dso_path = _get_raid_dso_path(cmd);
 
-	return target_registered_with_dmeventd(cmd, dso_path, seg->lv, pending);
+	return target_registered_with_dmeventd(cmd, dso_path, seg->lv, pending, monitored);
 }
 
 static int _raid_set_events(struct lv_segment *seg, int evmask, int set)
diff --git a/lib/snapshot/snapshot.c b/lib/snapshot/snapshot.c
index a80f283..68e01f5 100644
--- a/lib/snapshot/snapshot.c
+++ b/lib/snapshot/snapshot.c
@@ -186,10 +186,11 @@ static const char *_get_snapshot_dso_path(struct cmd_context *cmd)
 }
 
 /* FIXME Cache this */
-static int _target_registered(struct lv_segment *seg, int *pending)
+static int _target_registered(struct lv_segment *seg, int *pending, int *monitored)
 {
-	return target_registered_with_dmeventd(seg->lv->vg->cmd, _get_snapshot_dso_path(seg->lv->vg->cmd),
-					       seg->cow, pending);
+	return target_registered_with_dmeventd(seg->lv->vg->cmd,
+					       _get_snapshot_dso_path(seg->lv->vg->cmd),
+					       seg->cow, pending, monitored);
 }
 
 /* FIXME This gets run while suspended and performs banned operations. */
diff --git a/lib/thin/thin.c b/lib/thin/thin.c
index 73fffa6..9cb1ee0 100644
--- a/lib/thin/thin.c
+++ b/lib/thin/thin.c
@@ -437,11 +437,11 @@ static const char *_get_thin_dso_path(struct cmd_context *cmd)
 }
 
 /* FIXME Cache this */
-static int _target_registered(struct lv_segment *seg, int *pending)
+static int _target_registered(struct lv_segment *seg, int *pending, int *monitored)
 {
 	return target_registered_with_dmeventd(seg->lv->vg->cmd,
 					       _get_thin_dso_path(seg->lv->vg->cmd),
-					       seg->lv, pending);
+					       seg->lv, pending, monitored);
 }
 
 /* FIXME This gets run while suspended and performs banned operations. */


