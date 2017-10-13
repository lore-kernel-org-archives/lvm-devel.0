From: David Teigland <teigland@sourceware.org>
Date: Fri, 13 Oct 2017 17:21:57 -0400
Subject: master - replicator: remove the code
Message-ID: <201710132121.v9DLLvNq010102@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6ac1e04b3a6f57b65b66e95eff5640a023c4eaf9
Commit:        6ac1e04b3a6f57b65b66e95eff5640a023c4eaf9
Parent:        e14c0cabd961432d25d36ae11a26c47a7962ac24
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Oct 13 14:43:15 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Oct 13 16:20:42 2017 -0500

replicator: remove the code

It has not been used in a long time and is not
expected to be used further.
---
 WHATS_NEW                        |    1 +
 configure.in                     |   17 -
 include/configure.h.in           |    3 -
 lib/Makefile.in                  |   10 -
 lib/activate/activate.c          |   21 +-
 lib/activate/dev_manager.c       |  146 -------
 lib/commands/toolcontext.c       |    5 -
 lib/format_text/flags.c          |    2 -
 lib/locking/locking.h            |    5 +-
 lib/metadata/lv.h                |    4 -
 lib/metadata/lv_manip.c          |    1 -
 lib/metadata/merge.c             |   28 --
 lib/metadata/metadata-exported.h |   90 -----
 lib/metadata/metadata.c          |    4 -
 lib/metadata/metadata.h          |    5 -
 lib/metadata/replicator_manip.c  |  686 ---------------------------------
 lib/metadata/segtype.h           |    8 -
 lib/metadata/vg.h                |    2 -
 lib/replicator/.exported_symbols |    1 -
 lib/replicator/Makefile.in       |   25 --
 lib/replicator/replicator.c      |  792 --------------------------------------
 tools/vgchange.c                 |   10 +-
 22 files changed, 7 insertions(+), 1859 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 005a1bf..ebdc036 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.176 -
 ===================================
+  Remove the replicator code, including configure --with-replicators.
   Allow lvcreate --type mirror to work with 100%FREE.
   Improve selection of resource name for complex volume activation lock.
   Avoid cutting first character of resource name for activation lock.
diff --git a/configure.in b/configure.in
index 00e70aa..1366dc4 100644
--- a/configure.in
+++ b/configure.in
@@ -408,22 +408,6 @@ AC_DEFINE_UNQUOTED([DEFAULT_RAID10_SEGTYPE], ["$DEFAULT_RAID10_SEGTYPE"],
 		   [Default segtype used for raid10 volumes.])
 
 ################################################################################
-dnl -- asynchronous volume replicator inclusion type
-AC_MSG_CHECKING(whether to include replicators)
-AC_ARG_WITH(replicators,
-	    AC_HELP_STRING([--with-replicators=TYPE],
-			   [replicator support: internal/shared/none [none]]),
-	    REPLICATORS=$withval, REPLICATORS=none)
-AC_MSG_RESULT($REPLICATORS)
-
-case "$REPLICATORS" in
-  none|shared) ;;
-  internal) AC_DEFINE([REPLICATOR_INTERNAL], 1,
-		[Define to 1 to include built-in support for replicators.]) ;;
-  *) AC_MSG_ERROR([--with-replicators parameter invalid ($REPLICATORS)]) ;;
-esac
-
-
 AC_ARG_WITH(default-sparse-segtype,
 	    AC_HELP_STRING([--with-default-sparse-segtype=TYPE],
 			   [default sparse segtype: thin/snapshot [thin]]),
@@ -2211,7 +2195,6 @@ lib/format1/Makefile
 lib/format_pool/Makefile
 lib/locking/Makefile
 lib/mirror/Makefile
-lib/replicator/Makefile
 include/lvm-version.h
 lib/raid/Makefile
 lib/snapshot/Makefile
diff --git a/include/configure.h.in b/include/configure.h.in
index 5172650..be2f660 100644
--- a/include/configure.h.in
+++ b/include/configure.h.in
@@ -685,9 +685,6 @@
 /* Define to 1 to include the LVM readline shell. */
 #undef READLINE_SUPPORT
 
-/* Define to 1 to include built-in support for replicators. */
-#undef REPLICATOR_INTERNAL
-
 /* Define as the return type of signal handlers (`int' or `void'). */
 #undef RETSIGTYPE
 
diff --git a/lib/Makefile.in b/lib/Makefile.in
index ddbd8de..7e9fa91 100644
--- a/lib/Makefile.in
+++ b/lib/Makefile.in
@@ -36,10 +36,6 @@ ifeq ("@RAID@", "shared")
   SUBDIRS += raid
 endif
 
-ifeq ("@REPLICATORS@", "shared")
-  SUBDIRS += replicator
-endif
-
 ifeq ("@THIN@", "shared")
   SUBDIRS += thin
 endif
@@ -106,7 +102,6 @@ SOURCES =\
 	metadata/pv_manip.c \
 	metadata/pv_map.c \
 	metadata/raid_manip.c \
-	metadata/replicator_manip.c \
 	metadata/segtype.c \
 	metadata/snapshot_manip.c \
 	metadata/thin_manip.c \
@@ -165,10 +160,6 @@ ifeq ("@RAID@", "internal")
   SOURCES += raid/raid.c
 endif
 
-ifeq ("@REPLICATORS@", "internal")
-  SOURCES += replicator/replicator.c
-endif
-
 ifeq ("@THIN@", "internal")
   SOURCES += thin/thin.c
 endif
@@ -215,7 +206,6 @@ ifeq ($(MAKECMDGOALS),distclean)
 	mirror \
 	notify \
 	raid \
-	replicator \
 	thin \
 	cache_segtype \
 	locking
diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index d00e61e..edbb451 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -2125,9 +2125,6 @@ static int _lv_suspend(struct cmd_context *cmd, const char *lvid_s,
 		goto out;
 	}
 
-	if (!lv_read_replicator_vgs(lv))
-		goto_out;
-
 	lv_calculate_readahead(lv, NULL);
 
 	/*
@@ -2249,10 +2246,8 @@ static int _lv_suspend(struct cmd_context *cmd, const char *lvid_s,
 out:
 	if (lv_pre_to_free)
 		release_vg(lv_pre_to_free->vg);
-	if (lv_to_free) {
-		lv_release_replicator_vgs(lv_to_free);
+	if (lv_to_free)
 		release_vg(lv_to_free->vg);
-	}
 
 	return r;
 }
@@ -2436,9 +2431,6 @@ int lv_deactivate(struct cmd_context *cmd, const char *lvid_s, const struct logi
 			goto_out;
 	}
 
-	if (!lv_read_replicator_vgs(lv))
-		goto_out;
-
 	if (!monitor_dev_for_events(cmd, lv, &laopts, 0))
 		stack;
 
@@ -2453,10 +2445,8 @@ int lv_deactivate(struct cmd_context *cmd, const char *lvid_s, const struct logi
 		r = 0;
 	}
 out:
-	if (lv_to_free) {
-		lv_release_replicator_vgs(lv_to_free);
+	if (lv_to_free)
 		release_vg(lv_to_free->vg);
-	}
 
 	return r;
 }
@@ -2571,9 +2561,6 @@ static int _lv_activate(struct cmd_context *cmd, const char *lvid_s,
 		goto out;
 	}
 
-	if (!lv_read_replicator_vgs(lv))
-		goto_out;
-
 	lv_calculate_readahead(lv, NULL);
 
 	critical_section_inc(cmd, "activating");
@@ -2585,10 +2572,8 @@ static int _lv_activate(struct cmd_context *cmd, const char *lvid_s,
 		stack;
 
 out:
-	if (lv_to_free) {
-		lv_release_replicator_vgs(lv_to_free);
+	if (lv_to_free)
 		release_vg(lv_to_free->vg);
-	}
 
 	return r;
 }
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 8d96259..9b98c92 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -1774,84 +1774,6 @@ static int _add_dev_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 	return 1;
 }
 
-/*
- * Add replicator devices
- *
- * Using _add_dev_to_dtree() directly instead of _add_lv_to_dtree()
- * to avoid extra checks with extensions.
- */
-static int _add_partial_replicator_to_dtree(struct dev_manager *dm,
-					    struct dm_tree *dtree,
-					    const struct logical_volume *lv)
-{
-	struct logical_volume *rlv = first_seg(lv)->replicator;
-	struct replicator_device *rdev;
-	struct replicator_site *rsite;
-	struct dm_tree_node *rep_node, *rdev_node;
-	const char *uuid;
-
-	if (!lv_is_active_replicator_dev(lv)) {
-		if (!_add_dev_to_dtree(dm, dtree, lv->rdevice->lv,
-				      NULL))
-			return_0;
-		return 1;
-	}
-
-	/* Add _rlog and replicator device */
-	if (!_add_dev_to_dtree(dm, dtree, first_seg(rlv)->rlog_lv, NULL))
-		return_0;
-
-	if (!_add_dev_to_dtree(dm, dtree, rlv, NULL))
-		return_0;
-
-	if (!(uuid = build_dm_uuid(dm->mem, rlv, NULL)))
-		return_0;
-
-	rep_node = dm_tree_find_node_by_uuid(dtree, uuid);
-
-	/* Add all related devices for replicator */
-	dm_list_iterate_items(rsite, &rlv->rsites)
-		dm_list_iterate_items(rdev, &rsite->rdevices) {
-			if (rsite->state == REPLICATOR_STATE_ACTIVE) {
-				/* Add _rimage LV */
-				if (!_add_dev_to_dtree(dm, dtree, rdev->lv, NULL))
-					return_0;
-
-				/* Add replicator-dev LV, except of the already added one */
-				if ((lv != rdev->replicator_dev->lv) &&
-				    !_add_dev_to_dtree(dm, dtree,
-						       rdev->replicator_dev->lv, NULL))
-					return_0;
-
-				/* If replicator exists - try connect existing heads */
-				if (rep_node) {
-					uuid = build_dm_uuid(dm->mem,
-							     rdev->replicator_dev->lv,
-							     NULL);
-					if (!uuid)
-						return_0;
-
-					rdev_node = dm_tree_find_node_by_uuid(dtree, uuid);
-					if (rdev_node)
-						dm_tree_node_set_presuspend_node(rdev_node,
-										 rep_node);
-				}
-			}
-
-			if (!rdev->rsite->vg_name)
-				continue;
-
-			if (!_add_dev_to_dtree(dm, dtree, rdev->lv, NULL))
-				return_0;
-
-			if (rdev->slog &&
-			    !_add_dev_to_dtree(dm, dtree, rdev->slog, NULL))
-				return_0;
-		}
-
-	return 1;
-}
-
 struct pool_cb_data {
 	struct dev_manager *dm;
 	const struct logical_volume *pool_lv;
@@ -2156,11 +2078,6 @@ static int _add_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 			}
 		}
 
-	/* Adding LV head of replicator adds all other related devs */
-	if (lv_is_replicator_dev(lv) &&
-	    !_add_partial_replicator_to_dtree(dm, dtree, lv))
-		return_0;
-
 	/* Add any LVs used by segments in this LV */
 	dm_list_iterate_items(seg, &lv->segments) {
 		if (seg->external_lv && dm->track_external_lv_deps &&
@@ -2524,64 +2441,6 @@ static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 				struct lv_activate_opts *laopts,
 				const char *layer);
 
-/* Add all replicators' LVs */
-static int _add_replicator_dev_target_to_dtree(struct dev_manager *dm,
-					       struct dm_tree *dtree,
-					       struct lv_segment *seg,
-					       struct lv_activate_opts *laopts)
-{
-	struct replicator_device *rdev;
-	struct replicator_site *rsite;
-
-	/* For inactive replicator add linear mapping */
-	if (!lv_is_active_replicator_dev(seg->lv)) {
-		if (!_add_new_lv_to_dtree(dm, dtree, seg->lv->rdevice->lv, laopts, NULL))
-			return_0;
-		return 1;
-	}
-
-	/* Add rlog and replicator nodes */
-	if (!seg->replicator ||
-	    !first_seg(seg->replicator)->rlog_lv ||
-	    !_add_new_lv_to_dtree(dm, dtree,
-				  first_seg(seg->replicator)->rlog_lv,
-				  laopts, NULL) ||
-	    !_add_new_lv_to_dtree(dm, dtree, seg->replicator, laopts, NULL))
-	    return_0;
-
-	/* Activation of one replicator_dev node activates all other nodes */
-	dm_list_iterate_items(rsite, &seg->replicator->rsites) {
-		dm_list_iterate_items(rdev, &rsite->rdevices) {
-			if (rdev->lv &&
-			    !_add_new_lv_to_dtree(dm, dtree, rdev->lv,
-						  laopts, NULL))
-				return_0;
-
-			if (rdev->slog &&
-			    !_add_new_lv_to_dtree(dm, dtree, rdev->slog,
-						  laopts, NULL))
-				return_0;
-		}
-	}
-	/* Add remaining replicator-dev nodes in the second loop
-	 * to avoid multiple retries for inserting all elements */
-	dm_list_iterate_items(rsite, &seg->replicator->rsites) {
-		if (rsite->state != REPLICATOR_STATE_ACTIVE)
-			continue;
-		dm_list_iterate_items(rdev, &rsite->rdevices) {
-			if (rdev->replicator_dev->lv == seg->lv)
-				continue;
-			if (!rdev->replicator_dev->lv ||
-			    !_add_new_lv_to_dtree(dm, dtree,
-						  rdev->replicator_dev->lv,
-						  laopts, NULL))
-				return_0;
-		}
-	}
-
-	return 1;
-}
-
 static int _add_new_external_lv_to_dtree(struct dev_manager *dm,
 					 struct dm_tree *dtree,
 					 struct logical_volume *external_lv,
@@ -2682,11 +2541,6 @@ static int _add_segment_to_dtree(struct dev_manager *dm,
 				  lv_layer(seg->pool_lv)))
 		return_0;
 
-	if (seg_is_replicator_dev(seg)) {
-		if (!_add_replicator_dev_target_to_dtree(dm, dtree, seg, laopts))
-			return_0;
-	}
-
 	/* Add any LVs used by this segment */
 	for (s = 0; s < seg->area_count; ++s) {
 		if ((seg_type(seg, s) == AREA_LV) &&
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 39b300a..3cb3cf8 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -1501,11 +1501,6 @@ static int _init_segtypes(struct cmd_context *cmd)
 		dm_list_add(&cmd->segtypes, &segtype->list);
 	}
 
-#ifdef REPLICATOR_INTERNAL
-	if (!init_replicator_segtype(cmd, &seglib))
-		return 0;
-#endif
-
 #ifdef RAID_INTERNAL
 	if (!init_raid_segtypes(cmd, &seglib))
 		return 0;
diff --git a/lib/format_text/flags.c b/lib/format_text/flags.c
index 51acc46..7e793b3 100644
--- a/lib/format_text/flags.c
+++ b/lib/format_text/flags.c
@@ -90,8 +90,6 @@ static const struct flag _lv_flags[] = {
 	{PARTIAL_LV, NULL, 0},
 	{POSTORDER_FLAG, NULL, 0},
 	{VIRTUAL_ORIGIN, NULL, 0},
-	{REPLICATOR, NULL, 0},
-	{REPLICATOR_LOG, NULL, 0},
 	{THIN_VOLUME, NULL, 0},
 	{THIN_POOL, NULL, 0},
 	{THIN_POOL_DATA, NULL, 0},
diff --git a/lib/locking/locking.h b/lib/locking/locking.h
index 10c26b2..2381631 100644
--- a/lib/locking/locking.h
+++ b/lib/locking/locking.h
@@ -166,10 +166,7 @@ int check_lvm1_vg_inactive(struct cmd_context *cmd, const char *vgname);
 #define LCK_LV_CLUSTERED(lv)	\
 	(vg_is_clustered((lv)->vg) ? LCK_CLUSTER_VG : 0)
 
-#define lock_lv_vol(cmd, lv, flags)	\
-	(find_replicator_vgs((lv)) ? \
-		 lock_vol(cmd, (lv)->lvid.s, flags | LCK_LV_CLUSTERED(lv), lv) :	\
-		0)
+#define lock_lv_vol(cmd, lv, flags) lock_vol(cmd, (lv)->lvid.s, flags | LCK_LV_CLUSTERED(lv), lv) 
 
 /*
  * Activation locks are wrapped around activation commands that have to
diff --git a/lib/metadata/lv.h b/lib/metadata/lv.h
index bd6643c..3fb10ae 100644
--- a/lib/metadata/lv.h
+++ b/lib/metadata/lv.h
@@ -19,7 +19,6 @@
 
 union lvid;
 struct lv_segment;
-struct replicator_device;
 enum activation_change;
 
 struct logical_volume {
@@ -43,9 +42,6 @@ struct logical_volume {
 	struct dm_list snapshot_segs;
 	struct lv_segment *snapshot;
 
-	struct replicator_device *rdevice;/* For replicator-devs, rimages, slogs - reference to rdevice */
-	struct dm_list rsites;	/* For replicators - all sites */
-
 	struct dm_list segments;
 	struct dm_list tags;
 	struct dm_list segs_using_this_lv;
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 15a08aa..e71e2eb 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -5748,7 +5748,6 @@ struct logical_volume *alloc_lv(struct dm_pool *mem)
 	dm_list_init(&lv->tags);
 	dm_list_init(&lv->segs_using_this_lv);
 	dm_list_init(&lv->indirect_glvs);
-	dm_list_init(&lv->rsites);
 
 	return lv;
 }
diff --git a/lib/metadata/merge.c b/lib/metadata/merge.c
index 9462a36..7de0c10 100644
--- a/lib/metadata/merge.c
+++ b/lib/metadata/merge.c
@@ -219,17 +219,6 @@ static void _check_non_raid_seg_members(struct lv_segment *seg, int *error_count
 		raid_seg_error("non-zero cow LV");
 	if (!dm_list_empty(&seg->origin_list)) /* snap */
 		raid_seg_error("non-zero origin_list");
-	/* replicator members (deprecated) */
-	if (seg->replicator)
-		raid_seg_error("non-zero replicator");
-	if (seg->rlog_lv)
-		raid_seg_error("non-zero rlog LV");
-	if (seg->rlog_type)
-		raid_seg_error("non-zero rlog type");
-	if (seg->rdevice_index_highest)
-		raid_seg_error("non-zero rdevice_index_highests");
-	if (seg->rsite_index_highest)
-		raid_seg_error("non-zero rsite_index_highests");
 	/* .... more members? */
 }
 
@@ -513,8 +502,6 @@ int check_lv_segments(struct logical_volume *lv, int complete_vg)
 	struct seg_list *sl;
 	struct glv_list *glvl;
 	int error_count = 0;
-	struct replicator_site *rsite;
-	struct replicator_device *rdev;
 
 	dm_list_iterate_items(seg, &lv->segments) {
 		seg_count++;
@@ -551,9 +538,6 @@ int check_lv_segments(struct logical_volume *lv, int complete_vg)
 			}
 		}
 
-		if (seg_is_replicator(seg) && !check_replicator_segment(seg))
-			inc_error_count;
-
 		if (complete_vg)
 			_check_lv_segment(lv, seg, seg_count, &error_count);
 
@@ -655,18 +639,6 @@ int check_lv_segments(struct logical_volume *lv, int complete_vg)
 			if (seg->meta_areas && seg_is_raid_with_meta(seg) && (lv == seg_metalv(seg, s)))
 				seg_found++;
 		}
-		if (seg_is_replicator_dev(seg)) {
-			dm_list_iterate_items(rsite, &seg->replicator->rsites) {
-				dm_list_iterate_items(rdev, &rsite->rdevices) {
-					if (lv == rdev->lv || lv == rdev->slog)
-						seg_found++;
-				}
-			}
-			if (lv == seg->replicator)
-				seg_found++;
-		}
-		if (seg_is_replicator(seg) && lv == seg->rlog_lv)
-			seg_found++;
 		if (seg->log_lv == lv)
 			seg_found++;
 		if (seg->metadata_lv == lv || seg->pool_lv == lv)
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 4a8c519..cd6e92a 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -94,8 +94,6 @@
 
 #define MERGING			UINT64_C(0x0000000010000000)	/* LV SEG */
 
-#define REPLICATOR		UINT64_C(0x0000000020000000)	/* LV -internal use only for replicator */
-#define REPLICATOR_LOG		UINT64_C(0x0000000040000000)	/* LV -internal use only for replicator-dev */
 #define UNLABELLED_PV		UINT64_C(0x0000000080000000)	/* PV -this PV had no label written yet */
 
 #define RAID			UINT64_C(0x0000000100000000)	/* LV - Internal use only */
@@ -253,8 +251,6 @@
 #define lv_is_pool_metadata_spare(lv)	(((lv)->status & POOL_METADATA_SPARE) ? 1 : 0)
 #define lv_is_lockd_sanlock_lv(lv)	(((lv)->status & LOCKD_SANLOCK_LV) ? 1 : 0)
 
-#define lv_is_rlog(lv)		(((lv)->status & REPLICATOR_LOG) ? 1 : 0)
-
 #define lv_is_removed(lv)	(((lv)->status & LV_REMOVED) ? 1 : 0)
 
 int lv_layout_and_role(struct dm_pool *mem, const struct logical_volume *lv,
@@ -416,53 +412,6 @@ struct lv_thin_message {
 
 struct segment_type;
 
-/* List with vg_name, vgid and flags */
-struct cmd_vg {
-	struct dm_list list;
-	const char *vg_name;
-	const char *vgid;
-	uint32_t flags;
-	struct volume_group *vg;
-};
-
-/* ++ Replicator datatypes */
-typedef enum {
-	REPLICATOR_STATE_PASSIVE,
-	REPLICATOR_STATE_ACTIVE,
-	NUM_REPLICATOR_STATE
-} replicator_state_t;
-
-struct replicator_site {
-	struct dm_list list;		/* Chained list of sites */
-	struct dm_list rdevices;	/* Device list */
-
-	struct logical_volume *replicator; /* Reference to replicator */
-
-	const char *name;		/* Site name */
-	const char *vg_name;		/* VG name */
-	struct volume_group *vg;	/* resolved vg  (activate/deactive) */
-	unsigned site_index;
-	replicator_state_t state;	/* Active or pasive state of site */
-	dm_replicator_mode_t op_mode;	/* Operation mode sync or async fail|warn|drop|stall */
-	uint64_t fall_behind_data;	/* Bytes */
-	uint32_t fall_behind_ios;	/* IO operations */
-	uint32_t fall_behind_timeout;	/* Seconds */
-};
-
-struct replicator_device {
-	struct dm_list list;		/* Chained list of devices from same site */
-
-	struct lv_segment *replicator_dev; /* Reference to replicator-dev segment */
-	struct replicator_site *rsite;	/* Reference to site parameters */
-
-	uint64_t device_index;
-	const char *name;		/* Device LV name */
-	struct logical_volume *lv;	/* LV from replicator site's VG */
-	struct logical_volume *slog;	/* Synclog lv from VG  */
-	const char *slog_name;		/* Debug - specify size of core synclog */
-};
-/* -- Replicator datatypes */
-
 struct lv_segment {
 	struct dm_list list;
 	struct logical_volume *lv;
@@ -514,12 +463,6 @@ struct lv_segment {
 	const char *policy_name;		/* For cache_pool */
 	struct dm_config_node *policy_settings;	/* For cache_pool */
 	unsigned cleaner_policy;		/* For cache */
-
-	struct logical_volume *replicator;/* For replicator-devs - link to replicator LV */
-	struct logical_volume *rlog_lv;	/* For replicators */
-	const char *rlog_type;		/* For replicators */
-	uint64_t rdevice_index_highest;	/* For replicators */
-	unsigned rsite_index_highest;	/* For replicators */
 };
 
 #define seg_type(seg, s)	(seg)->areas[(s)].type
@@ -1202,26 +1145,6 @@ int reconfigure_mirror_images(struct lv_segment *mirrored_seg, uint32_t num_mirr
 int collapse_mirrored_lv(struct logical_volume *lv);
 int shift_mirror_images(struct lv_segment *mirrored_seg, unsigned mimage);
 
-/* ++  metadata/replicator_manip.c */
-int replicator_add_replicator_dev(struct logical_volume *replicator_lv,
-				  struct lv_segment *replicator_dev_seg);
-struct logical_volume *replicator_remove_replicator_dev(struct lv_segment *rdev_seg);
-int replicator_add_rlog(struct lv_segment *replicator_seg, struct logical_volume *rlog_lv);
-struct logical_volume *replicator_remove_rlog(struct lv_segment *replicator_seg);
-
-int replicator_dev_add_slog(struct replicator_device *rdev, struct logical_volume *slog);
-struct logical_volume *replicator_dev_remove_slog(struct replicator_device *rdev);
-int replicator_dev_add_rimage(struct replicator_device *rdev, struct logical_volume *lv);
-struct logical_volume *replicator_dev_remove_rimage(struct replicator_device *rdev);
-
-int lv_is_active_replicator_dev(const struct logical_volume *lv);
-int lv_is_replicator(const struct logical_volume *lv);
-int lv_is_replicator_dev(const struct logical_volume *lv);
-int lv_is_rimage(const struct logical_volume *lv);
-int lv_is_slog(const struct logical_volume *lv);
-struct logical_volume *first_replicator_dev(const struct logical_volume *lv);
-/* --  metadata/replicator_manip.c */
-
 /* ++  metadata/raid_manip.c */
 int lv_is_raid_with_tracking(const struct logical_volume *lv);
 uint32_t lv_raid_image_count(const struct logical_volume *lv);
@@ -1303,19 +1226,6 @@ int lv_cache_remove(struct logical_volume *cache_lv);
 int wipe_cache_pool(struct logical_volume *cache_pool_lv);
 /* --  metadata/cache_manip.c */
 
-struct cmd_vg *cmd_vg_add(struct dm_pool *mem, struct dm_list *cmd_vgs,
-			  const char *vg_name, const char *vgid,
-			  uint32_t flags);
-struct cmd_vg *cmd_vg_lookup(struct dm_list *cmd_vgs,
-			     const char *vg_name, const char *vgid);
-int cmd_vg_read(struct cmd_context *cmd, struct dm_list *cmd_vgs);
-void free_cmd_vgs(struct dm_list *cmd_vgs);
-
-int find_replicator_vgs(const struct logical_volume *lv);
-
-int lv_read_replicator_vgs(const struct logical_volume *lv);
-void lv_release_replicator_vgs(const struct logical_volume *lv);
-
 struct logical_volume *find_pvmove_lv(struct volume_group *vg,
 				      struct device *dev, uint64_t lv_type);
 const struct logical_volume *find_pvmove_lv_in_lv(const struct logical_volume *lv);
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index c50d579..1606b39 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -2404,8 +2404,6 @@ static int _lv_each_dependency(struct logical_volume *lv,
 	struct dm_list *snh;
 
 	struct logical_volume *deps[] = {
-		(lv->rdevice && lv != lv->rdevice->lv) ? lv->rdevice->lv : 0,
-		(lv->rdevice && lv != lv->rdevice->slog) ? lv->rdevice->slog : 0,
 		lv->snapshot ? lv->snapshot->origin : 0,
 		lv->snapshot ? lv->snapshot->cow : 0 };
 	for (i = 0; i < DM_ARRAY_SIZE(deps); ++i) {
@@ -2418,8 +2416,6 @@ static int _lv_each_dependency(struct logical_volume *lv,
 			return_0;
 		if (lvseg->log_lv && !fn(lvseg->log_lv, data))
 			return_0;
-		if (lvseg->rlog_lv && !fn(lvseg->rlog_lv, data))
-			return_0;
 		if (lvseg->pool_lv && !fn(lvseg->pool_lv, data))
 			return_0;
 		if (lvseg->metadata_lv && !fn(lvseg->metadata_lv, data))
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index ab3db4a..f3b1c95 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -421,11 +421,6 @@ int check_lv_segments(struct logical_volume *lv, int complete_vg);
 int lv_has_constant_stripes(struct logical_volume *lv);
 
 /*
- * Checks that a replicator segment is correct.
- */
-int check_replicator_segment(const struct lv_segment *rseg);
-
-/*
  * Sometimes (eg, after an lvextend), it is possible to merge two
  * adjacent segments into a single segment.  This function trys
  * to merge as many segments as possible.
diff --git a/lib/metadata/replicator_manip.c b/lib/metadata/replicator_manip.c
deleted file mode 100644
index 0501713..0000000
--- a/lib/metadata/replicator_manip.c
+++ /dev/null
@@ -1,686 +0,0 @@
-/*
- * Copyright (C) 2009-2010 Red Hat, Inc. All rights reserved.
- *
- * This file is part of LVM2.
- *
- * This copyrighted material is made available to anyone wishing to use,
- * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU Lesser General Public License v.2.1.
- *
- * You should have received a copy of the GNU Lesser General Public License
- * along with this program; if not, write to the Free Software Foundation,
- * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
- */
-
-#include "lib.h"
-#include "locking.h"
-#include "metadata.h"
-#include "segtype.h"
-#include "toolcontext.h"
-#include "lvmetad.h"
-
-/* Add lv as replicator_dev device */
-int replicator_dev_add_rimage(struct replicator_device *rdev,
-			      struct logical_volume *lv)
-{
-	if (!lv || !rdev)
-		return_0;
-
-	if (lv_is_rimage(lv)) {
-		log_error("Logical volume %s is already part of other "
-			  "replicator.", lv->name);
-		return 0;
-	}
-
-	if (rdev->lv) {
-		log_error("Logical volume %s can not be attached to an "
-			  "already defined replicator device", lv->name);
-		return 0;
-	}
-
-	lv_set_hidden(lv);
-	lv->rdevice = rdev;
-	rdev->lv = lv;
-
-	return add_seg_to_segs_using_this_lv(lv, rdev->replicator_dev);
-}
-
-/* Remove lv from replicator_dev device */
-struct logical_volume *replicator_dev_remove_rimage(struct replicator_device *rdev)
-{
-	struct logical_volume *lv;
-
-	if (!rdev || !rdev->lv)
-		return_NULL;
-
-	lv = rdev->lv;
-	if (!remove_seg_from_segs_using_this_lv(lv, rdev->replicator_dev))
-		return_NULL;
-
-	/* FIXME: - check for site references */
-	rdev->lv = NULL;
-	lv->rdevice = NULL;
-	lv_set_visible(lv);
-
-	return lv;
-}
-
-int replicator_dev_add_slog(struct replicator_device *rdev,
-			    struct logical_volume *slog)
-{
-	if (!slog || !rdev)
-		return_0;
-
-	if (rdev->slog) {
-		log_error("Replicator device in site %s already has sync log.",
-			  rdev->rsite->name);
-		return 0;
-	}
-
-	if (slog->rdevice) {
-		log_error("Sync log %s is already used by replicator %s.",
-			  slog->name, slog->rdevice->rsite->replicator->name);
-		return 0;
-	}
-
-	lv_set_hidden(slog);
-	slog->rdevice = rdev;
-	rdev->slog = slog;
-
-	return add_seg_to_segs_using_this_lv(slog, rdev->replicator_dev);
-}
-
-struct logical_volume *replicator_dev_remove_slog(struct replicator_device *rdev)
-{
-	struct logical_volume *lv;
-
-	if (!rdev)
-		return_NULL;
-
-	lv = rdev->slog;
-	if (!lv) {
-		log_error("Replicator device in site %s does not have sync log.",
-			  rdev->rsite->name);
-		return NULL;
-	}
-
-	if (!remove_seg_from_segs_using_this_lv(lv, rdev->replicator_dev))
-		return_NULL;
-
-	rdev->slog = NULL;
-	lv->rdevice = NULL;
-	lv_set_visible(lv);
-
-	return lv;
-}
-
-int replicator_add_replicator_dev(struct logical_volume *replicator_lv,
-				  struct lv_segment *replicator_dev_seg)
-{
-	if (!replicator_lv)
-		return_0;
-
-	if (!(replicator_lv->status & REPLICATOR)) {
-		dm_list_init(&replicator_lv->rsites);
-		lv_set_hidden(replicator_lv);
-		replicator_lv->status |= REPLICATOR;
-	}
-
-	if (!replicator_dev_seg)
-		return 1;
-
-	if (replicator_dev_seg->replicator) {
-		log_error("Replicator device %s is already part of replicator.",
-			  replicator_dev_seg->lv->name);
-		return 0;
-	}
-
-	replicator_dev_seg->replicator = replicator_lv;
-
-	return add_seg_to_segs_using_this_lv(replicator_lv, replicator_dev_seg);
-}
-
-/**
- * Returns rimage ?? lv upon succeful detach of device
- * entire LV entry should be removed by this crootall ??
- */
-struct logical_volume *replicator_remove_replicator_dev(struct lv_segment *replicator_dev_seg)
-{
-	struct logical_volume *lv = NULL;
-
-	log_error("FIXME: not implemented.");
-#if 0
-	/* FIXME: - this is going to be complex.... */
-	if (!replicator_dev_seg)
-		return_NULL;
-
-	/* if slog or rimage - exit */
-
-	if (!remove_seg_from_segs_using_this_lv(lv, replicator_seg))
-		return_NULL;
-
-	replicator_seg->rlog_lv = NULL;
-	lv->status &= ~REPLICATOR_LOG;
-	lv_set_visible(lv);
-#endif
-
-	return lv;
-}
-
-int replicator_add_rlog(struct lv_segment *replicator_seg,
-			struct logical_volume *rlog_lv)
-{
-	if (!rlog_lv)
-		return_0;
-
-	if (rlog_lv->status & REPLICATOR_LOG) {
-		log_error("Rlog device %s is already used.", rlog_lv->name);
-		return 0;
-	}
-
-	lv_set_hidden(rlog_lv);
-	rlog_lv->status |= REPLICATOR_LOG;
-	replicator_seg->rlog_lv = rlog_lv;
-
-	return add_seg_to_segs_using_this_lv(rlog_lv, replicator_seg);
-}
-
-struct logical_volume *replicator_remove_rlog(struct lv_segment *replicator_seg)
-{
-	struct logical_volume *lv;
-
-	if (!replicator_seg)
-		return_0;
-
-	if (!(lv = replicator_seg->rlog_lv)) {
-		log_error("Replog segment %s does not have rlog.",
-			  replicator_seg->lv->name);
-		return NULL;
-	}
-
-	if (!remove_seg_from_segs_using_this_lv(lv, replicator_seg))
-		return_NULL;
-
-	replicator_seg->rlog_lv = NULL;
-	lv->status &= ~REPLICATOR_LOG;
-	lv_set_visible(lv);
-
-	return lv;
-}
-
-
-#if 0
-/*
- * Create new LV to pretend the original LV
- * this target will have a 'replicator' segment
- */
-int lv_add_replicator(struct logical_volume *origin, const char *rep_suffix)
-{
-	struct logical_volume *rep_lv;
-	char *name;
-	size_t slen;
-
-	if (!(name = strstr(origin->name, rep_suffix))) {
-		log_error("Failed to find replicator suffix %s in LV name %s",
-			  rep_suffix, origin->name);
-		return 0;
-	}
-	slen = (size_t)(name - origin->name);
-	name = alloca(slen + 1);
-	memcpy(name, origin->name, slen);
-	name[slen] = 0;
-
-	if ((rep_lv = find_lv(origin->vg, name))) {
-		rep_lv->status |= VIRTUAL;
-		return 1;
-	}
-
-	if (!(rep_lv = lv_create_empty(name, &origin->lvid,
-				       LVM_READ | LVM_WRITE | VISIBLE_LV,
-				       ALLOC_INHERIT, origin->vg)))
-		return_0;
-
-	if (!lv_add_virtual_segment(rep_lv, 0, origin->le_count,
-				    get_segtype_from_string(origin->vg->cmd,
-							    "error")))
-		return_0;
-
-	rep_lv->status |= VIRTUAL;
-	return 1;
-}
-
-int lv_remove_replicator(struct logical_volume *lv)
-{
-	return 1;
-}
-#endif
-
-/*
- * Check all replicator structures:
- *  only non-clustered VG for Replicator
- *  only one segment in replicator LV
- *  site has correct combination of operation_mode parameters
- *  site and related devices have correct index numbers
- *  duplicate site names, site indexes, device names, device indexes
- */
-int check_replicator_segment(const struct lv_segment *rseg)
-{
-	struct replicator_site *rsite, *rsiteb;
-	struct replicator_device *rdev, *rdevb;
-        struct logical_volume *lv = rseg->lv;
-	int r = 1;
-
-	if (vg_is_clustered(lv->vg)) {
-		log_error("Volume Group %s of replicator %s is clustered",
-			  lv->vg->name, lv->name);
-		return 0;
-	}
-
-	if (dm_list_size(&lv->segments) != 1) {
-		log_error("Replicator %s segment size %d != 1",
-			  lv->name, dm_list_size(&lv->segments));
-		return 0;
-	}
-
-	dm_list_iterate_items(rsite, &lv->rsites) {
-		if (rsite->op_mode == DM_REPLICATOR_SYNC) {
-			if (rsite->fall_behind_timeout) {
-				log_error("Defined fall_behind_timeout="
-					  "%d for sync replicator %s/%s.",
-					  rsite->fall_behind_timeout, lv->name,
-					  rsite->name);
-				r = 0;
-			}
-			if (rsite->fall_behind_ios) {
-				log_error("Defined fall_behind_ios="
-					  "%d for sync replicator %s/%s.",
-					  rsite->fall_behind_ios, lv->name, rsite->name);
-				r = 0;
-			}
-			if (rsite->fall_behind_data) {
-				log_error("Defined fall_behind_data="
-					  FMTu64 " for sync replicator %s/%s.",
-					  rsite->fall_behind_data, lv->name, rsite->name);
-				r = 0;
-			}
-		} else {
-			if (rsite->fall_behind_timeout && rsite->fall_behind_ios) {
-				log_error("Defined fall_behind_timeout and"
-					  " fall_behind_ios for async replicator %s/%s.",
-					  lv->name, rsite->name);
-				r = 0;
-			}
-			if (rsite->fall_behind_timeout && rsite->fall_behind_data) {
-				log_error("Defined fall_behind_timeout and"
-					  " fall_behind_data for async replicator %s/%s.",
-					  lv->name, rsite->name);
-				r = 0;
-			}
-			if (rsite->fall_behind_ios && rsite->fall_behind_data) {
-				log_error("Defined fall_behind_ios and"
-					  " fall_behind_data for async replicator %s/%s.",
-					  lv->name, rsite->name);
-				r = 0;
-			}
-			if (!rsite->fall_behind_ios &&
-			    !rsite->fall_behind_data &&
-			    !rsite->fall_behind_timeout) {
-				log_error("fall_behind_timeout,"
-					  " fall_behind_ios and fall_behind_data are"
-					  " undefined for async replicator %s/%s.",
-					  lv->name, rsite->name);
-				r = 0;
-			}
-		}
-		dm_list_iterate_items(rsiteb, &lv->rsites) {
-			if (rsite == rsiteb)
-				break;
-			if (strcasecmp(rsite->name, rsiteb->name) == 0) {
-				log_error("Duplicate site name "
-					  "%s detected for replicator %s.",
-					  rsite->name, lv->name);
-				r = 0;
-			}
-			if ((rsite->vg_name && rsiteb->vg_name &&
-			     strcasecmp(rsite->vg_name, rsiteb->vg_name) == 0) ||
-			    (!rsite->vg_name && !rsiteb->vg_name)) {
-				log_error("Duplicate VG name "
-					  "%s detected for replicator %s.",
-					  (rsite->vg_name) ? rsite->vg_name : "<local>",
-					  lv->name);
-				r = 0;
-			}
-			if (rsite->site_index == rsiteb->site_index) {
-				log_error("Duplicate site index %d detected "
-					  "for replicator site %s/%s.",
-					  rsite->site_index, lv->name,
-					  rsite->name);
-				r = 0;
-			}
-			if (rsite->site_index > rseg->rsite_index_highest) {
-				log_error("Site index %d > %d (too high) "
-					  "for replicator site %s/%s.",
-					  rsite->site_index,
-					  rseg->rsite_index_highest,
-					  lv->name, rsite->name);
-				r = 0;
-			}
-		}
-
-		dm_list_iterate_items(rdev, &rsite->rdevices) {
-			dm_list_iterate_items(rdevb, &rsite->rdevices) {
-				if (rdev == rdevb)
-					break;
-				if (rdev->slog && (rdev->slog == rdevb->slog)) {
-					log_error("Duplicate sync log %s "
-						  "detected for replicator %s.",
-						  rdev->slog->name, lv->name);
-					r = 0;
-				}
-				if (strcasecmp(rdev->name, rdevb->name) == 0) {
-					log_error("Duplicate device name %s "
-						  "detected for replicator %s.",
-						  rdev->name, lv->name);
-					r = 0;
-				}
-				if (rdev->device_index == rdevb->device_index) {
-					log_error("Duplicate device index %"
-						  PRId64 " detected for "
-						  "replicator site %s/%s.",
-						  rdev->device_index,
-						  lv->name, rsite->name);
-					r = 0;
-				}
-				if (rdev->device_index > rseg->rdevice_index_highest) {
-					log_error("Device index %" PRIu64
-						  " > %" PRIu64 " (too high) "
-						  "for replicator site %s/%s.",
-						  rdev->device_index,
-						  rseg->rdevice_index_highest,
-						  lv->name, rsite->name);
-					r = 0;
-				}
-			}
-		}
-	}
-
-	return r;
-}
-
-/**
- * Is this segment part of active replicator
- */
-int lv_is_active_replicator_dev(const struct logical_volume *lv)
-{
-	return ((lv->status & REPLICATOR) &&
-		lv->rdevice &&
-		lv->rdevice->rsite &&
-		lv->rdevice->rsite->state == REPLICATOR_STATE_ACTIVE);
-}
-
-/**
- * Is this LV replicator control device
- */
-int lv_is_replicator(const struct logical_volume *lv)
-{
-	return ((lv->status & REPLICATOR) &&
-		!dm_list_empty(&lv->segments) &&
-		seg_is_replicator(first_seg(lv)));
-}
-
-/**
- * Is this LV replicator device
- */
-int lv_is_replicator_dev(const struct logical_volume *lv)
-{
-	return ((lv->status & REPLICATOR) &&
-		!dm_list_empty(&lv->segments) &&
-		seg_is_replicator_dev(first_seg(lv)));
-}
-
-/**
- * Is this LV replicated origin lv
- */
-int lv_is_rimage(const struct logical_volume *lv)
-{
-	return (lv->rdevice && lv->rdevice->lv == lv);
-}
-
-/**
- * Is this LV sync log
- */
-int lv_is_slog(const struct logical_volume *lv)
-{
-	return (lv->rdevice && lv->rdevice->slog == lv);
-}
-
-/**
- * Returns first replicator-dev in site in case the LV is replicator-dev,
- * NULL otherwise
- */
-struct logical_volume *first_replicator_dev(const struct logical_volume *lv)
-{
-	struct replicator_device *rdev;
-	struct replicator_site *rsite;
-
-	if (lv_is_replicator_dev(lv))
-		dm_list_iterate_items(rsite, &first_seg(lv)->replicator->rsites) {
-			dm_list_iterate_items(rdev, &rsite->rdevices)
-				return rdev->replicator_dev->lv;
-			break;
-		}
-
-	return NULL;
-}
-
-/**
- * Add VG open parameters to sorted cmd_vg list.
- *
- * Maintain the alphabeticaly ordered list, avoid duplications.
- *
- * \return	Returns newly created or already present cmd_vg entry,
- *		or NULL in error case.
- */
-struct cmd_vg *cmd_vg_add(struct dm_pool *mem, struct dm_list *cmd_vgs,
-			  const char *vg_name, const char *vgid,
-			  uint32_t flags)
-{
-	struct cmd_vg *cvl, *ins;
-
-	if (!vg_name && !vgid) {
-		log_error("Either vg_name or vgid must be set.");
-		return NULL;
-	}
-
-	/* Is it already in the list ? */
-	if ((cvl = cmd_vg_lookup(cmd_vgs, vg_name, vgid)))
-		return cvl;
-
-	if (!(cvl = dm_pool_zalloc(mem, sizeof(*cvl)))) {
-		log_error("Allocation of cmd_vg failed.");
-		return NULL;
-	}
-
-	if (vg_name && !(cvl->vg_name = dm_pool_strdup(mem, vg_name))) {
-		dm_pool_free(mem, cvl);
-		log_error("Allocation of vg_name failed.");
-		return NULL;
-	}
-
-	if (vgid && !(cvl->vgid = dm_pool_strdup(mem, vgid))) {
-		dm_pool_free(mem, cvl);
-		log_error("Allocation of vgid failed.");
-		return NULL;
-	}
-
-	cvl->flags = flags;
-
-	if (vg_name)
-		dm_list_iterate_items(ins, cmd_vgs)
-			if (strcmp(vg_name, ins->vg_name) < 0) {
-				cmd_vgs = &ins->list; /* new position */
-				break;
-			}
-
-	dm_list_add(cmd_vgs, &cvl->list);
-
-	return cvl;
-}
-
-/**
- * Find cmd_vg with given vg_name in cmd_vgs list.
- *
- * \param cmd_vgs	List of cmd_vg entries.
- *
- * \param vg_name	Name of VG to be found.
-
- * \param vgid		UUID of VG to be found.
- *
- * \return		Returns cmd_vg entry if vg_name or vgid is found,
- *			NULL otherwise.
- */
-struct cmd_vg *cmd_vg_lookup(struct dm_list *cmd_vgs,
-			     const char *vg_name, const char *vgid)
-{
-	struct cmd_vg *cvl;
-
-	dm_list_iterate_items(cvl, cmd_vgs)
-		if ((vgid && cvl->vgid && !strcmp(vgid, cvl->vgid)) ||
-		    (vg_name && cvl->vg_name && !strcmp(vg_name, cvl->vg_name)))
-			return cvl;
-	return NULL;
-}
-
-/**
- * Read and lock multiple VGs stored in cmd_vgs list alphabeticaly.
- * On the success list head pointer is set to VGs' cmd_vgs.
- * (supports FAILED_INCONSISTENT)
- *
- * \param cmd_vg	Contains list of cmd_vg entries.
- *
- * \return		Returns 1 if all VG in cmd_vgs list are correctly
- *			openned and locked, 0 otherwise.
- */
-int cmd_vg_read(struct cmd_context *cmd, struct dm_list *cmd_vgs)
-{
-	struct cmd_vg *cvl;
-
-	/* Iterate through alphabeticaly ordered cmd_vg list */
-	dm_list_iterate_items(cvl, cmd_vgs) {
-		cvl->vg = vg_read(cmd, cvl->vg_name, cvl->vgid, cvl->flags, 0);
-		if (vg_read_error(cvl->vg)) {
-			log_debug_metadata("Failed to vg_read %s", cvl->vg_name);
-			return 0;
-		}
-		cvl->vg->cmd_vgs = cmd_vgs;	/* Make it usable in VG */
-	}
-
-	return 1;
-}
-
-/**
- * Release opened and locked VGs from list.
- *
- * \param cmd_vgs	Contains list of cmd_vg entries.
- */
-void free_cmd_vgs(struct dm_list *cmd_vgs)
-{
-	struct cmd_vg *cvl;
-
-	/* Backward iterate cmd_vg list */
-	dm_list_iterate_back_items(cvl, cmd_vgs) {
-		if (vg_read_error(cvl->vg))
-			release_vg(cvl->vg);
-		else
-			unlock_and_release_vg(cvl->vg->cmd, cvl->vg, cvl->vg_name);
-		cvl->vg = NULL;
-	}
-}
-
-/**
- * Find all needed remote VGs for processing given LV.
- * Missing VGs are added to VG's cmd_vg list and flag cmd_missing_vgs is set.
- */
-int find_replicator_vgs(const struct logical_volume *lv)
-{
-	struct replicator_site *rsite;
-	int ret = 1;
-
-	if (!lv_is_replicator_dev(lv))
-		return 1;
-
-	dm_list_iterate_items(rsite, &first_seg(lv)->replicator->rsites) {
-		if (!rsite->vg_name || !lv->vg->cmd_vgs ||
-		    cmd_vg_lookup(lv->vg->cmd_vgs, rsite->vg_name, NULL))
-			continue;
-		ret = 0;
-		/* Using cmd memory pool for cmd_vg list allocation */
-		if (!cmd_vg_add(lv->vg->cmd->mem, lv->vg->cmd_vgs,
-				rsite->vg_name, NULL, 0)) {
-			lv->vg->cmd_missing_vgs = 0; /* do not retry */
-			stack;
-			break;
-		}
-
-		log_debug_metadata("VG: %s added as missing.", rsite->vg_name);
-		lv->vg->cmd_missing_vgs++;
-	}
-
-	return ret;
-}
-
-/**
- * Read all remote VGs from lv's replicator sites.
- * Function is used in activation context and needs all VGs already locked.
- */
-int lv_read_replicator_vgs(const struct logical_volume *lv)
-{
-	struct replicator_device *rdev;
-	struct replicator_site *rsite;
-	struct volume_group *vg;
-
-	if (!lv_is_replicator_dev(lv))
-		return 1;
-
-	dm_list_iterate_items(rsite, &first_seg(lv)->replicator->rsites) {
-		if (!rsite->vg_name)
-			continue;
-		vg = vg_read(lv->vg->cmd, rsite->vg_name, 0, 0, 0); // READ_WITHOUT_LOCK
-		if (vg_read_error(vg)) {
-			log_error("Unable to read volume group %s",
-				  rsite->vg_name);
-			goto bad;
-		}
-		rsite->vg = vg;
-		/* FIXME: handling missing LVs needs to be better */
-		dm_list_iterate_items(rdev, &rsite->rdevices)
-			if (!(rdev->lv = find_lv(vg, rdev->name))) {
-				log_error("Unable to find %s in volume group %s",
-					  rdev->name, rsite->vg_name);
-				goto bad;
-			}
-	}
-
-	return 1;
-bad:
-	lv_release_replicator_vgs(lv);
-	return 0;
-}
-
-/**
- * Release all VG resources taken by lv's replicator sites.
- * Function is used in activation context and needs all VGs already locked.
- */
-void lv_release_replicator_vgs(const struct logical_volume *lv)
-{
-	struct replicator_site *rsite;
-
-	if (!lv_is_replicator_dev(lv))
-		return;
-
-	dm_list_iterate_back_items(rsite, &first_seg(lv)->replicator->rsites)
-		if (rsite->vg_name && rsite->vg) {
-			release_vg(rsite->vg);
-			rsite->vg = NULL;
-		}
-}
diff --git a/lib/metadata/segtype.h b/lib/metadata/segtype.h
index 2acb894..c00cee6 100644
--- a/lib/metadata/segtype.h
+++ b/lib/metadata/segtype.h
@@ -36,8 +36,6 @@ struct dev_manager;
 #define SEG_VIRTUAL		(1ULL <<  5)
 #define SEG_CANNOT_BE_ZEROED	(1ULL <<  6)
 #define SEG_MONITORED		(1ULL <<  7)
-#define SEG_REPLICATOR		(1ULL <<  8)
-#define SEG_REPLICATOR_DEV	(1ULL <<  9)
 #define SEG_RAID		(1ULL << 10)
 #define SEG_THIN_POOL		(1ULL << 11)
 #define SEG_THIN_VOLUME		(1ULL << 12)
@@ -198,8 +196,6 @@ struct dev_manager;
 #define seg_is_raid_with_meta(seg)	segtype_is_raid_with_meta((seg)->segtype)
 #define seg_is_striped_raid(seg)	segtype_is_striped_raid((seg)->segtype)
 #define	seg_is_reshapable_raid(seg)	segtype_is_reshapable_raid((seg)->segtype)
-#define seg_is_replicator(seg)	((seg)->segtype->flags & SEG_REPLICATOR ? 1 : 0)
-#define seg_is_replicator_dev(seg) ((seg)->segtype->flags & SEG_REPLICATOR_DEV ? 1 : 0)
 #define seg_is_snapshot(seg)	segtype_is_snapshot((seg)->segtype)
 #define seg_is_striped(seg)	segtype_is_striped((seg)->segtype)
 #define seg_is_thin(seg)	segtype_is_thin((seg)->segtype)
@@ -313,10 +309,6 @@ struct segment_type *init_unknown_segtype(struct cmd_context *cmd,
 int init_raid_segtypes(struct cmd_context *cmd, struct segtype_library *seglib);
 #endif
 
-#ifdef REPLICATOR_INTERNAL
-int init_replicator_segtype(struct cmd_context *cmd, struct segtype_library *seglib);
-#endif
-
 #define THIN_FEATURE_DISCARDS			(1U << 0)
 #define THIN_FEATURE_EXTERNAL_ORIGIN		(1U << 1)
 #define THIN_FEATURE_HELD_ROOT			(1U << 2)
diff --git a/lib/metadata/vg.h b/lib/metadata/vg.h
index 4ce7151..bc2c2dd 100644
--- a/lib/metadata/vg.h
+++ b/lib/metadata/vg.h
@@ -47,8 +47,6 @@ struct volume_group {
 	struct format_instance *fid;
 	const struct format_type *original_fmt;	/* Set when processing backup files */
 	struct lvmcache_vginfo *vginfo;
-	struct dm_list *cmd_vgs;/* List of wanted/locked and opened VGs */
-	uint32_t cmd_missing_vgs;/* Flag marks missing VG */
 	uint32_t seqno;		/* Metadata sequence number */
 	unsigned skip_validate_lock_args : 1;
 	unsigned lvmetad_update_pending: 1;
diff --git a/lib/replicator/.exported_symbols b/lib/replicator/.exported_symbols
deleted file mode 100644
index 1c92c6a..0000000
--- a/lib/replicator/.exported_symbols
+++ /dev/null
@@ -1 +0,0 @@
-init_segtype
diff --git a/lib/replicator/Makefile.in b/lib/replicator/Makefile.in
deleted file mode 100644
index 48d2dbc..0000000
--- a/lib/replicator/Makefile.in
+++ /dev/null
@@ -1,25 +0,0 @@
-#
-# Copyright (C) 2009-2010 Red Hat, Inc. All rights reserved.
-#
-# This file is part of LVM2.
-#
-# This copyrighted material is made available to anyone wishing to use,
-# modify, copy, or redistribute it subject to the terms and conditions
-# of the GNU General Public License v.2.
-#
-# You should have received a copy of the GNU General Public License
-# along with this program; if not, write to the Free Software Foundation,
-# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
-
-srcdir = @srcdir@
-top_srcdir = @top_srcdir@
-top_builddir = @top_builddir@
-
-SOURCES = replicator.c
-
-LIB_SHARED = liblvm2replicator.$(LIB_SUFFIX)
-LIB_VERSION = $(LIB_VERSION_LVM)
-
-include $(top_builddir)/make.tmpl
-
-install: install_lib_shared_plugin
diff --git a/lib/replicator/replicator.c b/lib/replicator/replicator.c
deleted file mode 100644
index 8f43f8b..0000000
--- a/lib/replicator/replicator.c
+++ /dev/null
@@ -1,792 +0,0 @@
-/*
- * Copyright (C) 2009-2010 Red Hat, Inc. All rights reserved.
- *
- * This file is part of LVM2.
- *
- * This copyrighted material is made available to anyone wishing to use,
- * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU Lesser General Public License v.2.1.
- *
- * You should have received a copy of the GNU Lesser General Public License
- * along with this program; if not, write to the Free Software Foundation,
- * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
- */
-
-#include "lib.h"
-#include "toolcontext.h"
-#include "metadata.h"
-#include "segtype.h"
-#include "text_export.h"
-#include "activate.h"
-#include "str_list.h"
-#ifdef DMEVENTD
-#  include "libdevmapper-event.h"
-#endif
-
-/* Dm kernel module name for replicator */
-#define REPLICATOR_MODULE "replicator"
-#define REPLICATOR_DEV_MODULE "replicator-dev"
-
-/*
- * Macro used as return argument - returns 0.
- * return is left to be written in the function for better readability.
- */
-#define SEG_LOG_ERROR(t, p...) \
-	log_error(t " segment %s of logical volume %s.", ## p, \
-		  dm_config_parent_name(sn), seg->lv->name), 0;
-
-
-/*
- *  Replicator target
- */
-
-/* FIXME: missing implementation */
-static void _replicator_display(const struct lv_segment *seg)
-{
-	//const char *size;
-	//uint32_t s;
-
-	log_print("  Replicator");
-	if (seg->rlog_lv)
-		log_print("  Replicator volume\t%s", seg->rlog_lv->name);
-}
-
-/* Wrapper for dm_config_get_uint32() with default value */
-static uint32_t _get_config_uint32(const struct dm_config_node *cn,
-				   const char *path,
-				   uint32_t def)
-{
-	uint32_t t;
-
-	return dm_config_get_uint32(cn, path, &t) ? t : def;
-}
-
-/* Wrapper for dm_config_get_uint64() with default value */
-static uint64_t _get_config_uint64(const struct dm_config_node *cn,
-				   const char *path,
-				   uint64_t def)
-{
-	uint64_t t;
-
-	return dm_config_get_uint64(cn, path, &t) ? t : def;
-}
-
-
-/* Strings replicator_state_t enum */
-static const char _state_txt[NUM_REPLICATOR_STATE][8] = {
-	"passive",
-	"active"
-};
-
-/* Parse state string */
-static replicator_state_t _get_state(const struct dm_config_node *sn,
-				     const char *path, replicator_state_t def)
-{
-	const char *str;
-	unsigned i;
-
-	if (dm_config_get_str(sn, path, &str)) {
-		for (i = 0; i < sizeof(_state_txt)/sizeof(_state_txt[0]); ++i)
-			if (strcasecmp(str, _state_txt[i]) == 0)
-				return (replicator_state_t) i;
-
-		log_warn("%s: unknown value '%s', using default '%s' state",
-			 path, str, _state_txt[def]);
-	}
-
-	return def;
-}
-
-/* Strings for replicator_action_t enum */
-static const char _op_mode_txt[NUM_DM_REPLICATOR_MODES][8] = {
-	"sync",
-	"warn",
-	"stall",
-	"drop",
-	"fail"
-};
-
-
-/* Parse action string */
-static dm_replicator_mode_t _get_op_mode(const struct dm_config_node *sn,
-					 const char *path, dm_replicator_mode_t def)
-{
-	const char *str;
-	unsigned i;
-
-	if (dm_config_get_str(sn, path, &str)) {
-		for (i = 0; i < sizeof(_op_mode_txt)/sizeof(_op_mode_txt[0]); ++i)
-			if (strcasecmp(str, _op_mode_txt[i]) == 0) {
-				log_very_verbose("Setting %s to %s",
-						 path, _op_mode_txt[i]);
-				return (dm_replicator_mode_t) i;
-			}
-		log_warn("%s: unknown value '%s', using default '%s' operation mode",
-			 path, str, _op_mode_txt[def]);
-	}
-
-	return def;
-}
-
-static struct replicator_site *_get_site(struct logical_volume *replicator,
-					 const char *key)
-{
-	struct dm_pool *mem = replicator->vg->vgmem;
-	struct replicator_site *rsite;
-
-	dm_list_iterate_items(rsite, &replicator->rsites)
-		if (strcasecmp(rsite->name, key) == 0)
-			return rsite;
-
-	if (!(rsite = dm_pool_zalloc(mem, sizeof(*rsite))))
-		return_NULL;
-
-	if (!(rsite->name = dm_pool_strdup(mem, key)))
-		return_NULL;
-
-	rsite->replicator = replicator;
-	dm_list_init(&rsite->rdevices);
-	dm_list_add(&replicator->rsites, &rsite->list);
-
-	return rsite;
-}
-
-
-/* Parse replicator site element */
-static int _add_site(struct lv_segment *seg,
-		     const char *key,
-		     const struct dm_config_node *sn)
-{
-	struct dm_pool *mem = seg->lv->vg->vgmem;
-	const struct dm_config_node *cn;
-	struct replicator_site *rsite;
-
-	if (!(rsite = _get_site(seg->lv, key)))
-		return_0;
-
-	if (!dm_config_find_node(sn, "site_index"))
-		return SEG_LOG_ERROR("Mandatory site_index is missing for");
-
-	rsite->state = _get_state(sn, "state", REPLICATOR_STATE_PASSIVE);
-	rsite->site_index = _get_config_uint32(sn, "site_index", 0);
-	if (rsite->site_index > seg->rsite_index_highest)
-		return SEG_LOG_ERROR("site_index=%d > highest_site_index=%d for",
-				     rsite->site_index, seg->rsite_index_highest);
-
-	rsite->fall_behind_data = _get_config_uint64(sn, "fall_behind_data", 0);
-	rsite->fall_behind_ios = _get_config_uint32(sn, "fall_behind_ios", 0);
-	rsite->fall_behind_timeout = _get_config_uint32(sn, "fall_behind_timeout", 0);
-	rsite->op_mode = DM_REPLICATOR_SYNC;
-
-	if (rsite->fall_behind_data ||
-	    rsite->fall_behind_ios ||
-	    rsite->fall_behind_timeout) {
-		if (rsite->fall_behind_data && rsite->fall_behind_ios)
-			return SEG_LOG_ERROR("Defined both fall_behind_data "
-					     "and fall_behind_ios in");
-
-		if (rsite->fall_behind_data && rsite->fall_behind_timeout)
-			return SEG_LOG_ERROR("Defined both fall_behind_data "
-					     "and fall_behind_timeout in");
-
-		if (rsite->fall_behind_ios && rsite->fall_behind_timeout)
-			return SEG_LOG_ERROR("Defined both fall_behind_ios "
-					     "and fall_behind_timeout in");
-
-		rsite->op_mode = _get_op_mode(sn, "operation_mode",
-					      rsite->op_mode);
-	}
-
-	if ((cn = dm_config_find_node(sn, "volume_group"))) {
-		if (!cn->v || cn->v->type != DM_CFG_STRING)
-			return SEG_LOG_ERROR("volume_group must be a string in");
-
-		if (!(rsite->vg_name = dm_pool_strdup(mem, cn->v->v.str)))
-			return_0;
-
-	} else if (rsite->site_index != 0)
-		return SEG_LOG_ERROR("volume_group is mandatory for remote site in");
-
-	return 1;
-}
-
-
-/* Import replicator segment */
-static int _replicator_text_import(struct lv_segment *seg,
-				   const struct dm_config_node *sn,
-				   struct dm_hash_table *pv_hash __attribute__((unused)))
-{
-	const struct dm_config_node *cn;
-	struct logical_volume *rlog_lv;
-
-	if (!replicator_add_replicator_dev(seg->lv, NULL))
-		return_0;
-
-	if (!(cn = dm_config_find_node(sn, "replicator_log")) ||
-	    !cn->v || cn->v->type != DM_CFG_STRING)
-		return SEG_LOG_ERROR("Replicator log type must be a string in");
-
-	if (!(rlog_lv = find_lv(seg->lv->vg, cn->v->v.str)))
-		return SEG_LOG_ERROR("Unknown replicator log %s in",
-				     cn->v->v.str);
-
-	if (!(cn = dm_config_find_node(sn, "replicator_log_type")) ||
-	    !cn->v || cn->v->type != DM_CFG_STRING)
-		return SEG_LOG_ERROR("Replicator log's type must be a string in");
-	if (strcasecmp(cn->v->v.str, "ringbuffer"))
-		return SEG_LOG_ERROR("Only ringbuffer replicator log type is supported in");
-
-	if (!(seg->rlog_type = dm_pool_strdup(seg->lv->vg->vgmem, cn->v->v.str)))
-		return_0;
-
-
-	log_very_verbose("replicator_log = %s", rlog_lv->name);
-	log_very_verbose("replicator_log_type = %s", seg->rlog_type);
-
-	if (!replicator_add_rlog(seg, rlog_lv))
-		return_0;
-
-	seg->rdevice_index_highest = _get_config_uint64(sn, "highest_device_index", 0);
-	seg->rsite_index_highest = _get_config_uint32(sn, "highest_site_index", 0);
-
-	seg->region_size = _get_config_uint32(sn, "sync_log_size", 0);
-
-	for (; sn; sn = sn->sib)
-		if (!sn->v) {
-			for (cn = sn->sib; cn; cn = cn->sib)
-				if (!cn->v && (strcasecmp(cn->key ,sn->key) == 0))
-					return SEG_LOG_ERROR("Detected duplicate site "
-							     "name %s in", sn->key);
-			if (!_add_site(seg, sn->key, sn->child))
-				return_0;
-		}
-	return 1;
-}
-
-/* Export replicator segment */
-static int _replicator_text_export(const struct lv_segment *seg,
-				   struct formatter *f)
-{
-	struct replicator_site *rsite;
-
-	if (!seg->rlog_lv)
-                return_0;
-
-	outf(f, "replicator_log = \"%s\"", seg->rlog_lv->name);
-	outf(f, "replicator_log_type = \"%s\"", seg->rlog_type);
-	outf(f, "highest_device_index = %" PRIu64, seg->rdevice_index_highest);
-	outf(f, "highest_site_index = %d", seg->rsite_index_highest);
-
-	if (seg->region_size)
-		outsize(f, (uint64_t)seg->region_size,
-			"sync_log_size = %" PRIu32, seg->region_size);
-
-	if (!dm_list_empty(&seg->lv->rsites))
-		outnl(f);
-
-	dm_list_iterate_items(rsite, &seg->lv->rsites) {
-		outf(f, "%s {", rsite->name);
-		out_inc_indent(f);
-
-		outf(f, "state = \"%s\"", _state_txt[rsite->state]);
-		outf(f, "site_index = %d", rsite->site_index);
-
-		/* Only non-default parameters are written */
-		if (rsite->op_mode != DM_REPLICATOR_SYNC)
-			outf(f, "operation_mode = \"%s\"",
-			     _op_mode_txt[rsite->op_mode]);
-		if (rsite->fall_behind_timeout)
-			outfc(f, "# seconds", "fall_behind_timeout = %u",
-			     rsite->fall_behind_timeout);
-		if (rsite->fall_behind_ios)
-			outfc(f, "# io operations", "fall_behind_ios = %u",
-			     rsite->fall_behind_ios);
-		if (rsite->fall_behind_data)
-			outsize(f, rsite->fall_behind_data, "fall_behind_data = %" PRIu64,
-				rsite->fall_behind_data);
-		if (rsite->state != REPLICATOR_STATE_ACTIVE && rsite->vg_name)
-			outf(f, "volume_group = \"%s\"", rsite->vg_name);
-
-		out_dec_indent(f);
-		outf(f, "}");
-	}
-
-	return 1;
-}
-
-#ifdef DEVMAPPER_SUPPORT
-static int _replicator_add_target_line(struct dev_manager *dm,
-				       struct dm_pool *mem,
-				       struct cmd_context *cmd,
-				       void **target_state,
-				       struct lv_segment *seg,
-				       const struct lv_activate_opts *laopts,
-				       struct dm_tree_node *node,
-				       uint64_t len,
-				       uint32_t *pvmove_mirror_count)
-{
-	const char *rlog_dlid;
-	struct replicator_site *rsite;
-
-	if (!seg->rlog_lv)
-		return_0;
-
-	if (!(rlog_dlid = build_dm_uuid(mem, seg->rlog_lv, NULL)))
-		return_0;
-
-	dm_list_iterate_items(rsite, &seg->lv->rsites) {
-		if (!dm_tree_node_add_replicator_target(node,
-							seg->rlog_lv->size,
-							rlog_dlid,
-							seg->rlog_type,
-							rsite->site_index,
-							rsite->op_mode,
-							rsite->fall_behind_timeout,
-							rsite->fall_behind_data,
-							rsite->fall_behind_ios)) {
-			if (rsite->site_index == 0) {
-				log_error("Failed to add replicator log '%s' "
-					  "to replicator '%s'.",
-					  rlog_dlid, seg->lv->name);
-				return 0;
-			}
-			// FIXME:
-		}
-	}
-
-	return 1;
-}
-
-/* FIXME: write something useful for replicator here */
-static int _replicator_target_percent(void **target_state,
-				      dm_percent_t *percent,
-				      struct dm_pool *mem,
-				      struct cmd_context *cmd,
-				      struct lv_segment *seg,
-				      char *params, uint64_t *total_numerator,
-				      uint64_t *total_denominator)
-{
-	return 1;
-}
-
-/* Check for module presence */
-static int _replicator_target_present(struct cmd_context *cmd,
-				      const struct lv_segment *seg __attribute__((unused)),
-				      unsigned *attributes __attribute__((unused)))
-{
-	static int _checked = 0;
-	static int _present = 0;
-
-	if (!activation())
-		return 0;
-
-	if (!_checked) {
-		_checked = 1;
-		_present = target_present(cmd, REPLICATOR_MODULE, 1);
-	}
-
-	return _present;
-}
-
-#endif
-
-static int _replicator_modules_needed(struct dm_pool *mem,
-				      const struct lv_segment *seg __attribute__((unused)),
-				      struct dm_list *modules)
-{
-	if (!str_list_add(mem, modules, REPLICATOR_MODULE))
-		return_0;
-
-	if (!str_list_add(mem, modules, REPLICATOR_DEV_MODULE))
-		return_0;
-
-	return 1;
-}
-
-static void _replicator_destroy(struct segment_type *segtype)
-{
-	dm_free(segtype);
-}
-
-static struct segtype_handler _replicator_ops = {
-	.display = _replicator_display,
-	.text_import = _replicator_text_import,
-	.text_export = _replicator_text_export,
-#ifdef DEVMAPPER_SUPPORT
-	.add_target_line = _replicator_add_target_line,
-	.target_percent = _replicator_target_percent,
-	.target_present = _replicator_target_present,
-#endif
-	.modules_needed = _replicator_modules_needed,
-	.destroy = _replicator_destroy,
-};
-
-/*
- *  Replicator-dev  target
- */
-static void _replicator_dev_display(const struct lv_segment *seg)
-{
-	//const char *size;
-	//uint32_t s;
-	// FIXME: debug test code for now
-	log_print("  Replicator\t\t%u", seg->area_count);
-	log_print("  Mirror size\t\t%u", seg->area_len);
-	if (seg->log_lv)
-		log_print("  Replicator log volume\t%s", seg->rlog_lv->name);
-
-}
-
-static int _add_device(struct lv_segment *seg,
-		       const char *site_name,
-		       const struct dm_config_node *sn,
-		       uint64_t devidx)
-{
-	struct dm_pool *mem = seg->lv->vg->vgmem;
-	struct logical_volume *lv = NULL;
-	struct logical_volume *slog_lv = NULL;
-	struct replicator_site *rsite = _get_site(seg->replicator, site_name);
-	struct replicator_device *rdev;
-	const char *dev_str = NULL;
-	const char *slog_str = NULL;
-	const struct dm_config_node *cn;
-
-	dm_list_iterate_items(rdev, &rsite->rdevices)
-		if (rdev->replicator_dev == seg)
-			return SEG_LOG_ERROR("Duplicate site found in");
-
-	if ((cn = dm_config_find_node(sn, "sync_log"))) {
-		if (!cn->v || !cn->v->v.str)
-			return SEG_LOG_ERROR("Sync log must be a string in");
-		slog_str = cn->v->v.str;
-	}
-
-	if (!(cn = dm_config_find_node(sn, "logical_volume")) ||
-	    !cn->v || !cn->v->v.str)
-		return SEG_LOG_ERROR("Logical volume must be a string in");
-
-	dev_str = cn->v->v.str;
-
-	if (!seg->lv->rdevice) {
-		if (slog_str)
-			return SEG_LOG_ERROR("Sync log %s defined for local "
-					     "device in", slog_str);
-
-		/* Check for device in current VG */
-		if (!(lv = find_lv(seg->lv->vg, dev_str)))
-			return SEG_LOG_ERROR("Logical volume %s not found in",
-					     dev_str);
-	} else {
-		if (!slog_str)
-			return SEG_LOG_ERROR("Sync log is missing for remote "
-					     "device in");
-		/* Check for slog device in current VG */
-		if (!(slog_lv = find_lv(seg->lv->vg, slog_str)))
-			return SEG_LOG_ERROR("Sync log %s not found in",
-					     slog_str);
-	}
-
-	if (!(rdev = dm_pool_zalloc(mem, sizeof(*rdev))))
-		return_0;
-
-	if (!(rdev->name = dm_pool_strdup(mem, dev_str)))
-		return_0;
-
-	rdev->replicator_dev = seg;
-	rdev->rsite = rsite;
-	rdev->device_index = devidx;
-
-	if (!seg->lv->rdevice) {
-		if (!replicator_dev_add_rimage(rdev, lv))
-			return SEG_LOG_ERROR("LV inconsistency found in");
-		seg->lv->rdevice = rdev;
-	} else {
-		if (!slog_str ||
-		    !(rdev->slog_name = dm_pool_strdup(mem, slog_str)))
-			return_0;
-
-		if (!replicator_dev_add_slog(rdev, slog_lv))
-			return SEG_LOG_ERROR("Sync log inconsistency found in");
-	}
-
-	dm_list_add(&rsite->rdevices, &rdev->list);// linked site list
-
-	return 1;
-}
-
-/* Import replicator segment */
-static int _replicator_dev_text_import(struct lv_segment *seg,
-				       const struct dm_config_node *sn,
-				       struct dm_hash_table *pv_hash __attribute__((unused)))
-{
-	const struct dm_config_node *cn;
-	struct logical_volume *replicator;
-	uint64_t devidx;
-
-	if (!(cn = dm_config_find_node(sn, "replicator")))
-		return SEG_LOG_ERROR("Replicator is missing for");
-
-	if (!cn->v || !cn->v->v.str)
-		return SEG_LOG_ERROR("Replicator must be a string for");
-
-	if (!(replicator = find_lv(seg->lv->vg, cn->v->v.str)))
-		return SEG_LOG_ERROR("Unknown replicator %s for", cn->v->v.str);
-
-	if (!replicator_add_replicator_dev(replicator, seg))
-		return_0;
-
-	log_very_verbose("replicator=%s", replicator->name);
-
-	/* Mandatory */
-	if (!dm_config_find_node(sn, "device_index") ||
-	    !dm_config_get_uint64(sn, "device_index", &devidx))
-		return SEG_LOG_ERROR("Could not read 'device_index' for");
-
-	/* Read devices from sites */
-	for (; sn; sn = sn->sib)
-		if (!(sn->v) && !_add_device(seg, sn->key, sn->child, devidx))
-			return_0;
-
-	if (!seg->lv->rdevice)
-		return SEG_LOG_ERROR("Replicator device without site in");
-
-	seg->rlog_lv = NULL;
-	seg->lv->status |= REPLICATOR;
-
-	return 1;
-}
-
-/* Export replicator-dev segment */
-static int _replicator_dev_text_export(const struct lv_segment *seg,
-				       struct formatter *f)
-{
-	struct replicator_site *rsite;
-	struct replicator_device *rdev;
-
-	if (!seg->replicator || !seg->lv->rdevice)
-		return_0;
-
-	outf(f, "replicator = \"%s\"", seg->replicator->name);
-	outf(f, "device_index = %" PRId64, seg->lv->rdevice->device_index);
-
-	outnl(f);
-
-	dm_list_iterate_items(rsite, &seg->replicator->rsites) {
-		dm_list_iterate_items(rdev, &rsite->rdevices) {
-			if (rdev->replicator_dev != seg)
-				continue;
-
-			outf(f, "%s {", rdev->rsite->name);
-
-			out_inc_indent(f);
-
-			outf(f, "logical_volume = \"%s\"",
-			     rdev->name ? rdev->name : rdev->lv->name);
-
-			if (rdev->slog)
-				outf(f, "sync_log = \"%s\"", rdev->slog->name);
-			else if (rdev->slog_name)
-				outf(f, "sync_log = \"%s\"", rdev->slog_name);
-
-			out_dec_indent(f);
-
-			outf(f, "}");
-		}
-	}
-
-	return 1;
-}
-
-#ifdef DEVMAPPER_SUPPORT
-/*
- * Add target for passive site matching the device index
- */
-static int _replicator_dev_add_target_line(struct dev_manager *dm,
-					   struct dm_pool *mem,
-					   struct cmd_context *cmd,
-					   void **target_state,
-					   struct lv_segment *seg,
-					   const struct lv_activate_opts *laopts,
-					   struct dm_tree_node *node,
-					   uint64_t len,
-					   uint32_t *pvmove_mirror_count)
-{
-	const char *replicator_dlid, *rdev_dlid, *slog_dlid;
-	struct replicator_device *rdev, *rdev_search;
-	struct replicator_site *rsite;
-	uint32_t slog_size;
-	uint32_t slog_flags;
-
-	if (!lv_is_active_replicator_dev(seg->lv)) {
-		/* Create passive linear mapping */
-		log_very_verbose("Inactive replicator %s using %s.",
-				 seg->lv->name, seg->lv->rdevice->lv->name);
-		if (!add_linear_area_to_dtree(node, seg->lv->size, seg->lv->vg->extent_size,
-					      cmd->use_linear_target,
-					      seg->lv->vg->name, seg->lv->name))
-			return_0;
-		if (!(rdev_dlid = build_dm_uuid(mem, seg->lv->rdevice->lv, NULL)))
-			return_0;
-		return dm_tree_node_add_target_area(node, NULL, rdev_dlid, 0);
-	}
-
-	if (seg->lv->rdevice->rsite->site_index) {
-		log_error("Active site with site_index != 0 (%s, %d)",
-			  seg->lv->rdevice->rsite->name,
-			  seg->lv->rdevice->rsite->site_index);
-		return 0; /* Replicator without any active site */
-	}
-
-	/*
-	 * At this point all devices that have some connection with replicator
-	 * must be present in dm_tree
-	 */
-	if (!seg_is_replicator_dev(seg) ||
-	    !(replicator_dlid = build_dm_uuid(mem, seg->replicator, NULL)))
-		return_0;
-
-	/* Select remote devices with the same device index */
-	dm_list_iterate_items(rsite, &seg->replicator->rsites) {
-		if (rsite->site_index == 0) {
-			/* Local slink0 device */
-			rdev = seg->lv->rdevice;
-		} else {
-			rdev = NULL;
-			dm_list_iterate_items(rdev_search, &rsite->rdevices) {
-				if (rdev_search->replicator_dev == seg) {
-					rdev = rdev_search;
-					break;
-				}
-			}
-
-			if (!rdev) {
-				log_error(INTERNAL_ERROR "rdev list not found.");
-				return 0;
-			}
-		}
-
-		if (!rdev->lv ||
-		    !(rdev_dlid = build_dm_uuid(mem, rdev->lv, NULL)))
-			return_0;
-
-		slog_dlid = NULL;
-
-		/* Using either disk or core (in memory) log */
-		if (rdev->slog) {
-			slog_flags = DM_NOSYNC;
-			slog_size = (uint32_t) rdev->slog->size;
-			if (!(slog_dlid = build_dm_uuid(mem, rdev->slog, NULL)))
-				return_0;
-		} else if (rdev->slog_name &&
-			   sscanf(rdev->slog_name, FMTu32, &slog_size) == 1) {
-			slog_flags = DM_CORELOG | DM_FORCESYNC;
-			if (slog_size == 0) {
-				log_error("Failed to use empty corelog size "
-					  "in replicator '%s'.",
-					  rsite->replicator->name);
-				return 0;
-			}
-		} else  {
-			slog_flags = DM_CORELOG | DM_FORCESYNC;
-			slog_size = 0; /* NOLOG */
-		}
-
-		if (!dm_tree_node_add_replicator_dev_target(node,
-							    seg->lv->size,
-							    replicator_dlid,
-							    seg->lv->rdevice->device_index,
-							    rdev_dlid,
-							    rsite->site_index,
-							    slog_dlid,
-							    slog_flags,
-							    slog_size)) {
-			return_0;
-			/* FIXME: handle 'state = dropped' in future */
-		}
-	}
-
-	return 1;
-}
-
-/* FIXME: write something useful for replicator-dev here */
-static int _replicator_dev_target_percent(void **target_state,
-					  dm_percent_t *percent,
-					  struct dm_pool *mem,
-					  struct cmd_context *cmd,
-					  struct lv_segment *seg,
-					  char *params,
-					  uint64_t *total_numerator,
-					  uint64_t *total_denominator)
-{
-	return 1;
-}
-
-/* Check for module presence */
-static int _replicator_dev_target_present(struct cmd_context *cmd,
-					  const struct lv_segment *seg __attribute__((unused)),
-					  unsigned *attributes __attribute__((unused)))
-{
-	static int _checked = 0;
-	static int _present = 0;
-
-	if (!_checked) {
-		_present = target_present(cmd, REPLICATOR_DEV_MODULE, 1);
-		_checked = 1;
-	}
-
-	return _present;
-}
-
-#endif
-
-static struct segtype_handler _replicator_dev_ops = {
-	.display = _replicator_dev_display,
-	.text_import = _replicator_dev_text_import,
-	.text_export = _replicator_dev_text_export,
-#ifdef DEVMAPPER_SUPPORT
-	.add_target_line = _replicator_dev_add_target_line,
-	.target_percent = _replicator_dev_target_percent,
-	.target_present = _replicator_dev_target_present,
-#endif
-	.modules_needed = _replicator_modules_needed,
-	.destroy = _replicator_destroy,
-};
-
-#ifdef REPLICATOR_INTERNAL
-int init_replicator_segtype(struct cmd_context *cmd, struct segtype_library *seglib)
-#else /* Shared */
-int init_multiple_segtype(struct cmd_context *cmd, struct segtype_library *seglib);
-int init_multiple_segtype(struct cmd_context *cmd, struct segtype_library *seglib)
-#endif
-{
-	struct segment_type *segtype;
-
-	if (!(segtype = dm_zalloc(sizeof(*segtype))))
-		return_0;
-
-	segtype->ops = &_replicator_ops;
-	segtype->name = REPLICATOR_MODULE;
-	segtype->private = NULL;
-	segtype->flags = SEG_REPLICATOR;
-
-	if (!lvm_register_segtype(seglib, segtype))
-		/* segtype is already destroyed */
-		return_0;
-
-	log_very_verbose("Initialised segtype: " REPLICATOR_MODULE);
-
-	if (!(segtype = dm_zalloc(sizeof(*segtype))))
-		return_0;
-
-	segtype->ops = &_replicator_dev_ops;
-	segtype->name = REPLICATOR_DEV_MODULE;
-	segtype->private = NULL;
-	segtype->flags = SEG_REPLICATOR_DEV;
-
-	if (!lvm_register_segtype(seglib, segtype))
-		/* segtype is already destroyed */
-		return_0;
-
-	log_very_verbose("Initialised segtype: " REPLICATOR_DEV_MODULE);
-
-	return 1;
-}
diff --git a/tools/vgchange.c b/tools/vgchange.c
index 263b5a6..3de635d 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -114,11 +114,6 @@ static int _activate_lvs_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 		if (lv_is_mirror_image(lv) || lv_is_mirror_log(lv))
 			continue;
 
-		/* Only request activation of the first replicator-dev LV */
-		/* Avoids retry with all heads in case of failure */
-		if (lv_is_replicator_dev(lv) && (lv != first_replicator_dev(lv)))
-			continue;
-
 		if (lv_activation_skip(lv, activate, arg_is_set(cmd, ignoreactivationskip_ARG)))
 			continue;
 
@@ -254,9 +249,8 @@ int vgchange_activate(struct cmd_context *cmd, struct volume_group *vg,
 	}
 
 	/* Print message only if there was not found a missing VG */
-	if (!vg->cmd_missing_vgs)
-		log_print_unless_silent("%d logical volume(s) in volume group \"%s\" now active",
-					lvs_in_vg_activated(vg), vg->name);
+	log_print_unless_silent("%d logical volume(s) in volume group \"%s\" now active",
+				lvs_in_vg_activated(vg), vg->name);
 	return r;
 }
 


