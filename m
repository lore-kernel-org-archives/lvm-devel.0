From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 12 Feb 2018 16:20:52 -0500
Subject: master - cleanup: decode dso path just once
Message-ID: <201802122120.w1CLKq7S023760@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e113df129ebc4c2b4fca2a973ac6e06630e1a470
Commit:        e113df129ebc4c2b4fca2a973ac6e06630e1a470
Parent:        6dff5dc653a6f31c2e995beb1c5ca5c58e83515e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Feb 9 23:40:37 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 12 22:15:03 2018 +0100

cleanup: decode dso path just once

Build dso plugin name during  segtype initialisation and just
use the string during command life-time.

Also slightlt update message verbosity and make it very_verbose
when operation is going to be made and 'verbose' when it's done.
---
 lib/activate/activate.c |    6 ++++--
 lib/metadata/segtype.h  |    1 +
 lib/mirror/mirrored.c   |   14 ++++++--------
 lib/raid/raid.c         |   31 ++++++++++++++-----------------
 lib/snapshot/snapshot.c |   15 ++++++---------
 lib/thin/thin.c         |   14 ++++++--------
 6 files changed, 37 insertions(+), 44 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index d8e1ccd..b39f314 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -1831,7 +1831,7 @@ int target_register_events(struct cmd_context *cmd, const char *dso, const struc
 	if (!r)
 		return_0;
 
-	log_very_verbose("%s %s for events", set ? "Monitored" : "Unmonitored", uuid);
+	log_verbose("%s %s for events", set ? "Monitored" : "Unmonitored", uuid);
 
 	return 1;
 }
@@ -2016,7 +2016,9 @@ int monitor_dev_for_events(struct cmd_context *cmd, const struct logical_volume
 			if (monitored)
 				log_verbose("%s already monitored.", display_lvname(lv));
 			else if (seg->segtype->ops->target_monitor_events) {
-				log_verbose("Monitoring %s%s", display_lvname(lv), test_mode() ? " [Test mode: skipping this]" : "");
+				log_very_verbose("Monitoring %s with %s.%s", display_lvname(lv),
+						 seg->segtype->dso,
+						 test_mode() ? " [Test mode: skipping this]" : "");
 				monitor_fn = seg->segtype->ops->target_monitor_events;
 			}
 		} else {
diff --git a/lib/metadata/segtype.h b/lib/metadata/segtype.h
index fd8646c..3941612 100644
--- a/lib/metadata/segtype.h
+++ b/lib/metadata/segtype.h
@@ -217,6 +217,7 @@ struct segment_type {
 
 	struct segtype_handler *ops;
 	const char *name;
+	const char *dso;
 
 	void *library;			/* lvm_register_segtype() sets this. */
 	void *private;			/* For the segtype handler to use. */
diff --git a/lib/mirror/mirrored.c b/lib/mirror/mirrored.c
index 012501e..16a5852 100644
--- a/lib/mirror/mirrored.c
+++ b/lib/mirror/mirrored.c
@@ -480,22 +480,17 @@ static int _mirrored_target_present(struct cmd_context *cmd,
 }
 
 #  ifdef DMEVENTD
-static const char *_get_mirror_dso_path(struct cmd_context *cmd)
-{
-	return get_monitor_dso_path(cmd, find_config_tree_str(cmd, dmeventd_mirror_library_CFG, NULL));
-}
-
 /* FIXME Cache this */
 static int _target_registered(struct lv_segment *seg, int *pending, int *monitored)
 {
-	return target_registered_with_dmeventd(seg->lv->vg->cmd, _get_mirror_dso_path(seg->lv->vg->cmd),
+	return target_registered_with_dmeventd(seg->lv->vg->cmd, seg->segtype->dso,
 					       seg->lv, pending, monitored);
 }
 
 /* FIXME This gets run while suspended and performs banned operations. */
 static int _target_set_events(struct lv_segment *seg, int evmask, int set)
 {
-	return target_register_events(seg->lv->vg->cmd, _get_mirror_dso_path(seg->lv->vg->cmd),
+	return target_register_events(seg->lv->vg->cmd, seg->segtype->dso,
 				      seg->lv, evmask, set, 0);
 }
 
@@ -577,7 +572,10 @@ struct segment_type *init_segtype(struct cmd_context *cmd)
 
 #ifdef DEVMAPPER_SUPPORT
 #  ifdef DMEVENTD
-	if (_get_mirror_dso_path(cmd))
+	segtype->dso = get_monitor_dso_path(cmd,
+		find_config_tree_str(cmd, dmeventd_mirror_library_CFG, NULL));
+
+	if (segtype->dso)
 		segtype->flags |= SEG_MONITORED;
 #  endif	/* DMEVENTD */
 #endif
diff --git a/lib/raid/raid.c b/lib/raid/raid.c
index 9b85373..eb75c1b 100644
--- a/lib/raid/raid.c
+++ b/lib/raid/raid.c
@@ -538,26 +538,16 @@ static int _raid_modules_needed(struct dm_pool *mem,
 }
 
 #  ifdef DMEVENTD
-static const char *_get_raid_dso_path(struct cmd_context *cmd)
-{
-	const char *config_str = find_config_tree_str(cmd, dmeventd_raid_library_CFG, NULL);
-	return get_monitor_dso_path(cmd, config_str);
-}
-
 static int _raid_target_monitored(struct lv_segment *seg, int *pending, int *monitored)
 {
-	struct cmd_context *cmd = seg->lv->vg->cmd;
-	const char *dso_path = _get_raid_dso_path(cmd);
-
-	return target_registered_with_dmeventd(cmd, dso_path, seg->lv, pending, monitored);
+	return target_registered_with_dmeventd(seg->lv->vg->cmd, seg->segtype->dso,
+					       seg->lv, pending, monitored);
 }
 
 static int _raid_set_events(struct lv_segment *seg, int evmask, int set)
 {
-	struct cmd_context *cmd = seg->lv->vg->cmd;
-	const char *dso_path = _get_raid_dso_path(cmd);
-
-	return target_register_events(cmd, dso_path, seg->lv, evmask, set, 0);
+	return target_register_events(seg->lv->vg->cmd, seg->segtype->dso,
+				      seg->lv, evmask, set, 0);
 }
 
 static int _raid_target_monitor_events(struct lv_segment *seg, int events)
@@ -623,6 +613,7 @@ static const struct raid_type {
 
 static struct segment_type *_init_raid_segtype(struct cmd_context *cmd,
 					       const struct raid_type *rt,
+					       const char *dso,
 					       uint64_t monitored)
 {
 	struct segment_type *segtype = dm_zalloc(sizeof(*segtype));
@@ -638,8 +629,10 @@ static struct segment_type *_init_raid_segtype(struct cmd_context *cmd,
 	segtype->flags = SEG_RAID | SEG_ONLY_EXCLUSIVE | rt->extra_flags;
 
 	/* Never monitor raid0 or raid0_meta LVs */
-	if (!segtype_is_any_raid0(segtype))
+	if (!segtype_is_any_raid0(segtype)) {
+		segtype->dso = dso;
 		segtype->flags |= monitored;
+	}
 
 	segtype->parity_devs = rt->parity;
 
@@ -657,18 +650,22 @@ int init_multiple_segtypes(struct cmd_context *cmd, struct segtype_library *segl
 #endif
 {
 	struct segment_type *segtype;
+	const char *dso;
 	unsigned i;
 	uint64_t monitored = 0;
 
 #ifdef DEVMAPPER_SUPPORT
 #  ifdef DMEVENTD
-	if (_get_raid_dso_path(cmd))
+	dso = get_monitor_dso_path(cmd,
+		find_config_tree_str(cmd, dmeventd_raid_library_CFG, NULL));
+
+	if (dso)
 		monitored = SEG_MONITORED;
 #  endif
 #endif
 
 	for (i = 0; i < DM_ARRAY_SIZE(_raid_types); ++i)
-		if ((segtype = _init_raid_segtype(cmd, &_raid_types[i], monitored)) &&
+		if ((segtype = _init_raid_segtype(cmd, &_raid_types[i], dso, monitored)) &&
 		    !lvm_register_segtype(seglib, segtype))
 			/* segtype is already destroyed */
 			return_0;
diff --git a/lib/snapshot/snapshot.c b/lib/snapshot/snapshot.c
index 68e01f5..e44a49a 100644
--- a/lib/snapshot/snapshot.c
+++ b/lib/snapshot/snapshot.c
@@ -179,17 +179,11 @@ static int _snap_target_present(struct cmd_context *cmd,
 }
 
 #  ifdef DMEVENTD
-
-static const char *_get_snapshot_dso_path(struct cmd_context *cmd)
-{
-	return get_monitor_dso_path(cmd, find_config_tree_str(cmd, dmeventd_snapshot_library_CFG, NULL));
-}
-
 /* FIXME Cache this */
 static int _target_registered(struct lv_segment *seg, int *pending, int *monitored)
 {
 	return target_registered_with_dmeventd(seg->lv->vg->cmd,
-					       _get_snapshot_dso_path(seg->lv->vg->cmd),
+					       seg->segtype->dso,
 					       seg->cow, pending, monitored);
 }
 
@@ -197,7 +191,7 @@ static int _target_registered(struct lv_segment *seg, int *pending, int *monitor
 static int _target_set_events(struct lv_segment *seg, int evmask, int set)
 {
 	/* FIXME Make timeout (10) configurable */
-	return target_register_events(seg->lv->vg->cmd, _get_snapshot_dso_path(seg->lv->vg->cmd),
+	return target_register_events(seg->lv->vg->cmd, seg->segtype->dso,
 				      seg->cow, evmask, set, 10);
 }
 
@@ -269,7 +263,10 @@ struct segment_type *init_segtype(struct cmd_context *cmd)
 
 #ifdef DEVMAPPER_SUPPORT
 #  ifdef DMEVENTD
-	if (_get_snapshot_dso_path(cmd))
+	segtype->dso = get_monitor_dso_path(cmd,
+		find_config_tree_str(cmd, dmeventd_snapshot_library_CFG, NULL));
+
+	if (segtype->dso)
 		segtype->flags |= SEG_MONITORED;
 #  endif	/* DMEVENTD */
 #endif
diff --git a/lib/thin/thin.c b/lib/thin/thin.c
index 9cb1ee0..06854ed 100644
--- a/lib/thin/thin.c
+++ b/lib/thin/thin.c
@@ -431,16 +431,11 @@ static int _thin_pool_target_percent(void **target_state __attribute__((unused))
 }
 
 #  ifdef DMEVENTD
-static const char *_get_thin_dso_path(struct cmd_context *cmd)
-{
-	return get_monitor_dso_path(cmd, find_config_tree_str(cmd, dmeventd_thin_library_CFG, NULL));
-}
-
 /* FIXME Cache this */
 static int _target_registered(struct lv_segment *seg, int *pending, int *monitored)
 {
 	return target_registered_with_dmeventd(seg->lv->vg->cmd,
-					       _get_thin_dso_path(seg->lv->vg->cmd),
+					       seg->segtype->dso,
 					       seg->lv, pending, monitored);
 }
 
@@ -449,7 +444,7 @@ static int _target_set_events(struct lv_segment *seg, int evmask, int set)
 {
 	/* FIXME Make timeout (10) configurable */
 	return target_register_events(seg->lv->vg->cmd,
-				      _get_thin_dso_path(seg->lv->vg->cmd),
+				      seg->segtype->dso,
 				      seg->lv, evmask, set, 10);
 }
 
@@ -821,8 +816,11 @@ int init_multiple_segtypes(struct cmd_context *cmd, struct segtype_library *segl
 
 #ifdef DEVMAPPER_SUPPORT
 #  ifdef DMEVENTD
+		segtype->dso = get_monitor_dso_path(cmd,
+			find_config_tree_str(cmd, dmeventd_thin_library_CFG, NULL));
+
 		if ((reg_segtypes[i].flags & SEG_THIN_POOL) &&
-		    _get_thin_dso_path(cmd))
+		    segtype->dso)
 			segtype->flags |= SEG_MONITORED;
 #  endif /* DMEVENTD */
 #endif


