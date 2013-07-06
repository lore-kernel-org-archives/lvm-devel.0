From: Alasdair Kergon <agk@fedoraproject.org>
Date: Sat,  6 Jul 2013 02:31:30 +0000 (UTC)
Subject: master - lvresize: separate validation from action
Message-ID: <20130706023130.D10BA60E66@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7c6526aae277c049aa4a6e41b7c2b30d366c9852
Commit:        7c6526aae277c049aa4a6e41b7c2b30d366c9852
Parent:        a64239f225463d418dd4ccb931ceda88535fc6e2
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Sat Jul 6 03:28:21 2013 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Sat Jul 6 03:28:21 2013 +0100

lvresize: separate validation from action

Start separating the validation from the action in the basic lvresize
code moved to the library.
Remove incorrect use of command line error codes from lvresize library
functions.  Move errors.h to tools directory to reinforce this,
exporting public versions of the error codes in lvm2cmd.h for dmeventd
plugins to use.
---
 WHATS_NEW                                          |    2 +
 daemons/dmeventd/plugins/mirror/dmeventd_mirror.c  |    5 +-
 daemons/dmeventd/plugins/raid/dmeventd_raid.c      |    5 +-
 .../dmeventd/plugins/snapshot/dmeventd_snapshot.c  |    3 +-
 daemons/dmeventd/plugins/thin/dmeventd_thin.c      |    3 +-
 include/.symlinks.in                               |    1 -
 lib/commands/errors.h                              |   26 --
 lib/metadata/lv_manip.c                            |  265 ++++++++++++--------
 lib/metadata/metadata-exported.h                   |   10 +-
 lib/metadata/pv_manip.c                            |   29 ++-
 liblvm/lvm_lv.c                                    |   14 +-
 liblvm/lvm_pv.c                                    |    4 +-
 tools/errors.h                                     |   26 ++
 tools/lvm2cmd.h                                    |    6 +
 tools/lvresize.c                                   |   28 ++-
 tools/pvcreate.c                                   |    3 +-
 tools/pvremove.c                                   |    6 +-
 17 files changed, 261 insertions(+), 175 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index b174cb3..e389a36 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,7 @@
 Version 2.02.99 - 
 ===================================
+  Define LVM2_* command errors in lvm2cmd.h and use in dmeventd plugins.
+  Move errors.h to tools dir.
   Add man page entries for profile configuration and related options.
   Improve error loging when user tries to interrupt commands.
   Rename _swap_lv to _swap_lv_identifiers and move to allow an additional user.
diff --git a/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c b/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c
index e59feb4..864f0e2 100644
--- a/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c
+++ b/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c
@@ -15,7 +15,6 @@
 #include "lib.h"
 
 #include "lvm2cmd.h"
-#include "errors.h"
 #include "libdevmapper-event.h"
 #include "dmeventd_lvm.h"
 #include "defaults.h"
@@ -145,9 +144,9 @@ static int _remove_failed_devices(const char *device)
 	r = dmeventd_lvm2_run(cmd_str);
 
 	syslog(LOG_INFO, "Repair of mirrored device %s %s.", device,
-	       (r == ECMD_PROCESSED) ? "finished successfully" : "failed");
+	       (r == LVM2_COMMAND_SUCCEEDED) ? "finished successfully" : "failed");
 
-	return (r == ECMD_PROCESSED) ? 0 : -1;
+	return (r == LVM2_COMMAND_SUCCEEDED) ? 0 : -1;
 }
 
 void process_event(struct dm_task *dmt,
diff --git a/daemons/dmeventd/plugins/raid/dmeventd_raid.c b/daemons/dmeventd/plugins/raid/dmeventd_raid.c
index a3ecdc1..9da2e7c 100644
--- a/daemons/dmeventd/plugins/raid/dmeventd_raid.c
+++ b/daemons/dmeventd/plugins/raid/dmeventd_raid.c
@@ -15,7 +15,6 @@
 #include "lib.h"
 
 #include "lvm2cmd.h"
-#include "errors.h"
 #include "libdevmapper-event.h"
 #include "dmeventd_lvm.h"
 
@@ -41,10 +40,10 @@ static int run_repair(const char *device)
 
 	r = dmeventd_lvm2_run(cmd_str);
 
-	if (r != ECMD_PROCESSED)
+	if (r != LVM2_COMMAND_SUCCEEDED)
 		syslog(LOG_INFO, "Repair of RAID device %s failed.", device);
 
-	return (r == ECMD_PROCESSED) ? 0 : -1;
+	return (r == LVM2_COMMAND_SUCCEEDED) ? 0 : -1;
 }
 
 static int _process_raid_event(char *params, const char *device)
diff --git a/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c b/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c
index 98dd1b4..c4b69e2 100644
--- a/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c
+++ b/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c
@@ -15,7 +15,6 @@
 #include "lib.h"
 
 #include "lvm2cmd.h"
-#include "errors.h"
 #include "libdevmapper-event.h"
 #include "dmeventd_lvm.h"
 
@@ -82,7 +81,7 @@ static int _run(const char *cmd, ...)
 
 static int _extend(const char *cmd)
 {
-	return dmeventd_lvm2_run(cmd) == ECMD_PROCESSED;
+	return dmeventd_lvm2_run(cmd) == LVM2_COMMAND_SUCCEEDED;
 }
 
 static void _umount(const char *device, int major, int minor)
diff --git a/daemons/dmeventd/plugins/thin/dmeventd_thin.c b/daemons/dmeventd/plugins/thin/dmeventd_thin.c
index f32424ad..8b173f1 100644
--- a/daemons/dmeventd/plugins/thin/dmeventd_thin.c
+++ b/daemons/dmeventd/plugins/thin/dmeventd_thin.c
@@ -15,7 +15,6 @@
 #include "lib.h"
 
 #include "lvm2cmd.h"
-#include "errors.h"
 #include "libdevmapper-event.h"
 #include "dmeventd_lvm.h"
 
@@ -147,7 +146,7 @@ static int _extend(struct dso_state *state)
 #if THIN_DEBUG
 	syslog(LOG_INFO, "dmeventd executes: %s.\n", state->cmd_str);
 #endif
-	return (dmeventd_lvm2_run(state->cmd_str) == ECMD_PROCESSED);
+	return (dmeventd_lvm2_run(state->cmd_str) == LVM2_COMMAND_SUCCEEDED);
 }
 
 static int _run(const char *cmd, ...)
diff --git a/include/.symlinks.in b/include/.symlinks.in
index facadbe..7fdc045 100644
--- a/include/.symlinks.in
+++ b/include/.symlinks.in
@@ -6,7 +6,6 @@
 @top_srcdir@/lib/activate/targets.h
 @top_srcdir@/lib/cache/lvmcache.h
 @top_srcdir@/lib/cache/lvmetad.h
- at top_srcdir@/lib/commands/errors.h
 @top_srcdir@/lib/commands/toolcontext.h
 @top_srcdir@/lib/config/config.h
 @top_srcdir@/lib/config/config_settings.h
diff --git a/lib/commands/errors.h b/lib/commands/errors.h
deleted file mode 100644
index a644fc7..0000000
--- a/lib/commands/errors.h
+++ /dev/null
@@ -1,26 +0,0 @@
-/*
- * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
- *
- * This file is part of LVM2.
- *
- * This copyrighted material is made available to anyone wishing to use,
- * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU Lesser General Public License v.2.1.
- *
- * You should have received a copy of the GNU Lesser General Public License
- * along with this program; if not, write to the Free Software Foundation,
- * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
- */
-
-#ifndef _LVM_ERRORS_H
-#define _LVM_ERRORS_H
-
-#define ECMD_PROCESSED		1
-#define ENO_SUCH_CMD		2
-#define EINVALID_CMD_LINE	3
-#define ECMD_FAILED		5
-
-/* FIXME Also returned by cmdlib. */
-
-#endif
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index b7914dd..9d67e71 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -28,7 +28,6 @@
 #include "str_list.h"
 #include "defaults.h"
 #include "lvm-exec.h"
-#include "errors.h"
 
 typedef enum {
 	PREFERRED,
@@ -1719,7 +1718,7 @@ static area_use_t _check_pva(struct alloc_handle *ah, struct pv_area *pva, uint3
 		if (((alloc_parms->flags & A_CONTIGUOUS_TO_LVSEG) || (ah->maximise_cling && alloc_parms->prev_lvseg)) &&
 		    _check_contiguous(ah->cmd, alloc_parms->prev_lvseg, pva, alloc_state))
 			return PREFERRED;
-	
+
 		/* Try next area on same PV if looking for contiguous space */
 		if (alloc_parms->flags & A_CONTIGUOUS_TO_LVSEG)
 			return NEXT_AREA;
@@ -2046,7 +2045,7 @@ static int _find_some_parallel_space(struct alloc_handle *ah, const struct alloc
 				alloc_state->areas[ix_offset++].pva = NULL;
 			}
 	}
-	
+
 	/*
 	 * First time around, if there's a log, allocate it on the
 	 * smallest device that has space for it.
@@ -3447,6 +3446,7 @@ static int _lvresize_poolmetadata(struct cmd_context *cmd, struct volume_group *
 			vg->extent_size;
 	}
 
+	/* FIXME Split here and move validation code earlier alongside rest of validation code */
 	if (extents == lv->le_count) {
 		log_print_unless_silent("Metadata volume %s has already %s.",
 					lv->name, display_size(cmd, lv->size));
@@ -3474,32 +3474,10 @@ static int _lvresize_poolmetadata(struct cmd_context *cmd, struct volume_group *
 	return 1;
 }
 
-int lv_resize(struct cmd_context *cmd, struct volume_group *vg,
-		     struct lvresize_params *lp, struct dm_list *pvh)
+static int _lvresize_check_lv(struct cmd_context *cmd, struct logical_volume *lv, 
+			      struct lvresize_params *lp)
 {
-	struct logical_volume *lv;
-	uint32_t stripesize_extents;
-	uint32_t seg_stripes = 0, seg_stripesize = 0, seg_size;
-	uint32_t seg_mirrors = 0;
-	uint32_t extents_used;
-	uint32_t size_rest;
-	uint32_t pv_extent_count;
-	alloc_policy_t alloc;
-	struct logical_volume *lock_lv = NULL;
-	struct lv_list *lvl;
-	struct lv_segment *seg, *uninitialized_var(mirr_seg);
-	uint32_t seg_extents;
-	uint32_t sz, str;
-	int status;
-
-	/* does LV exist? */
-	if (!(lvl = find_lv_in_vg(vg, lp->lv_name))) {
-		log_error("Logical volume %s not found in volume group %s",
-			  lp->lv_name, lp->vg_name);
-		return ECMD_FAILED;
-	}
-
-	lv = lvl->lv;
+	struct volume_group *vg = lv->vg;
 
 	if (lv_is_external_origin(lv)) {
 		/*
@@ -3507,20 +3485,20 @@ int lv_resize(struct cmd_context *cmd, struct volume_group *vg,
 		 * there is no way to use extended areas.
 		 */
 		log_error("Cannot resize external origin \"%s\".", lv->name);
-		return EINVALID_CMD_LINE;
+		return 0;
 	}
 
 	if (lv->status & (RAID_IMAGE | RAID_META)) {
 		log_error("Cannot resize a RAID %s directly",
 			  (lv->status & RAID_IMAGE) ? "image" :
 			  "metadata area");
-		return ECMD_FAILED;
+		return 0;
 	}
 
 	if (lv_is_raid_with_tracking(lv)) {
 		log_error("Cannot resize %s while it is tracking a split image",
 			  lv->name);
-		return ECMD_FAILED;
+		return 0;
 	}
 
 	if (lp->ac_stripes) {
@@ -3537,37 +3515,41 @@ int lv_resize(struct cmd_context *cmd, struct volume_group *vg,
 			log_warn("Mirrors not supported. Ignoring.");
 	}
 
-	if (lp->ac_stripesize &&
-	    !_validate_stripesize(cmd, vg, lp))
-		return EINVALID_CMD_LINE;
+	if (lp->ac_stripesize && !_validate_stripesize(cmd, vg, lp))
+		return_0;
 
-	if (lp->ac_policy) {
-		if (!lv_is_cow(lv) &&
-		    !lv_is_thin_pool(lv)) {
-			log_error("Policy-based resize is supported only for snapshot and thin pool volumes.");
-			return ECMD_FAILED;
-		}
-		if (!_adjust_policy_params(cmd, lv, lp))
-			return_ECMD_FAILED;
+	if (lp->ac_policy && !lv_is_cow(lv) && !lv_is_thin_pool(lv)) {
+		log_error("Policy-based resize is supported only for snapshot and thin pool volumes.");
+		return 0;
 	}
 
-	if (!lv_is_visible(lv) &&
-	    !lv_is_thin_pool_metadata(lv)) {
+	if (!lv_is_visible(lv) && !lv_is_thin_pool_metadata(lv)) {
 		log_error("Can't resize internal logical volume %s", lv->name);
-		return ECMD_FAILED;
+		return 0;
 	}
 
 	if (lv->status & LOCKED) {
 		log_error("Can't resize locked LV %s", lv->name);
-		return ECMD_FAILED;
+		return 0;
 	}
 
 	if (lv->status & CONVERTING) {
 		log_error("Can't resize %s while lvconvert in progress", lv->name);
-		return ECMD_FAILED;
+		return 0;
 	}
 
-	alloc = (alloc_policy_t)(lp->ac_alloc)?lp->ac_alloc: lv->alloc;
+	if (!lv_is_thin_pool(lv) && lp->poolmetadatasize) {
+		log_error("--poolmetadatasize can be used only with thin pools.");
+		return 0;
+	}
+
+	return 1;
+}
+
+static int _lvresize_adjust_size(struct cmd_context *cmd, struct logical_volume *lv, 
+				 struct lvresize_params *lp)
+{
+	struct volume_group *vg = lv->vg;
 
 	/*
 	 * First adjust to an exact multiple of extent size.
@@ -3590,9 +3572,26 @@ int lv_resize(struct cmd_context *cmd, struct volume_group *vg,
 		lp->extents = lp->size / vg->extent_size;
 	}
 
-	if (lp->sizeargs) { /* TODO: reindent or move to function */
 
-	switch(lp->percent) {
+	return 1;
+}
+
+static int _lvresize_adjust_extents(struct cmd_context *cmd, struct logical_volume *lv, 
+				    struct lvresize_params *lp, struct dm_list *pvh)
+{
+	struct volume_group *vg = lv->vg;
+	uint32_t pv_extent_count;
+	uint32_t extents_used;
+	uint32_t seg_stripes = 0, seg_stripesize = 0, seg_size;
+	uint32_t seg_mirrors = 0;
+	struct lv_segment *seg, *uninitialized_var(mirr_seg);
+	uint32_t sz, str;
+	uint32_t seg_extents;
+	uint32_t stripesize_extents;
+	uint32_t size_rest;
+
+	/* If percent options were used, convert them into actual numbers of extents */
+	switch (lp->percent) {
 		case PERCENT_VG:
 			lp->extents = percent_of_extents(lp->extents, vg->extent_count,
 							 (lp->sign != SIGN_MINUS));
@@ -3617,7 +3616,7 @@ int lv_resize(struct cmd_context *cmd, struct volume_group *vg,
 		case PERCENT_ORIGIN:
 			if (!lv_is_cow(lv)) {
 				log_error("Specified LV does not have an origin LV.");
-				return EINVALID_CMD_LINE;
+				return 0;
 			}
 			lp->extents = percent_of_extents(lp->extents, origin_from_cow(lv)->le_count,
 							 (lp->sign != SIGN_MINUS));
@@ -3630,7 +3629,7 @@ int lv_resize(struct cmd_context *cmd, struct volume_group *vg,
 		if (lp->extents >= (MAX_EXTENT_COUNT - lv->le_count)) {
 			log_error("Unable to extend %s by %u extents, exceeds limit (%u).",
 				  lp->lv_name, lv->le_count, MAX_EXTENT_COUNT);
-			return EINVALID_CMD_LINE;
+			return 0;
 		}
 		lp->extents += lv->le_count;
 		if (lv_is_cow(lv)) {
@@ -3639,15 +3638,18 @@ int lv_resize(struct cmd_context *cmd, struct volume_group *vg,
 				log_print_unless_silent("Reached maximum COW size %s.",
 							display_size(vg->cmd, (uint64_t) vg->extent_size * extents_used));
 				lp->extents = extents_used;
-				if (lp->extents == lv->le_count)
-					return ECMD_PROCESSED;
+				if (lp->extents == lv->le_count) {
+					/* Signal that normal resizing is not required */
+					lp->sizeargs = 0;
+					return 1;
+				}
 			}
 		}
 	} else if (lp->sign == SIGN_MINUS) {
 		if (lp->extents >= lv->le_count) {
 			log_error("Unable to reduce %s below 1 extent",
 				  lp->lv_name);
-			return EINVALID_CMD_LINE;
+			return 0;
 		}
 
 		lp->extents = lv->le_count - lp->extents;
@@ -3655,21 +3657,20 @@ int lv_resize(struct cmd_context *cmd, struct volume_group *vg,
 
 	if (!lp->extents) {
 		log_error("New size of 0 not permitted");
-		return EINVALID_CMD_LINE;
+		return 0;
 	}
 
 	if (lp->extents == lv->le_count) {
-		/* A bit of hack - but still may resize metadata */
-		if (lp->poolmetadatasize) {
+		if (lp->poolmetadatasize || lp->ac_policy) {
+			/* Signal that normal resizing is not required */
 			lp->sizeargs = 0;
-			goto metadata_resize;
+			return 1;
 		}
-		if (lp->ac_policy)
-			return ECMD_PROCESSED; /* Nothing to do. */
+
 		if (!lp->resizefs) {
 			log_error("New size (%d extents) matches existing size "
 				  "(%d extents)", lp->extents, lv->le_count);
-			return EINVALID_CMD_LINE;
+			return 0;
 		}
 		lp->resize = LV_EXTEND; /* lets pretend zero size extension */
 	}
@@ -3682,7 +3683,7 @@ int lv_resize(struct cmd_context *cmd, struct volume_group *vg,
 	/* FIXME Support LVs with mixed segment types */
 	if (lp->segtype != get_segtype_from_string(cmd, (lp->ac_type)?lp->ac_type:lp->segtype->name)) {
 		log_error("VolumeType does not match (%s)", lp->segtype->name);
-		return EINVALID_CMD_LINE;
+		return 0;
 	}
 
 	/* If extending, find mirrors of last segment */
@@ -3710,7 +3711,7 @@ int lv_resize(struct cmd_context *cmd, struct volume_group *vg,
 		if ((lp->ac_mirrors || seg_mirrors) &&
 		    (lp->mirrors != seg_mirrors)) {
 			log_error("Cannot vary number of mirrors in LV yet.");
-			return EINVALID_CMD_LINE;
+			return 0;
 		}
 
 		if (seg_mirrors && !strcmp(mirr_seg->segtype->name, "raid10")) {
@@ -3742,7 +3743,7 @@ int lv_resize(struct cmd_context *cmd, struct volume_group *vg,
 			    (seg_stripes && seg_stripes != str && !lp->stripes)) {
 				log_error("Please specify number of "
 					  "stripes (-i) and stripesize (-I)");
-				return EINVALID_CMD_LINE;
+				return 0;
 			}
 
 			seg_stripesize = sz;
@@ -3754,7 +3755,7 @@ int lv_resize(struct cmd_context *cmd, struct volume_group *vg,
 		else if (seg_is_raid(first_seg(lv)) &&
 			 (lp->stripes != seg_stripes)) {
 			log_error("Unable to extend \"%s\" segment type with different number of stripes.", first_seg(lv)->segtype->ops->name(first_seg(lv)));
-			return ECMD_FAILED;
+			return 0;
 		}
 
 		if (!lp->stripe_size && lp->stripes > 1) {
@@ -3804,14 +3805,14 @@ int lv_resize(struct cmd_context *cmd, struct volume_group *vg,
 
 	if (lp->stripes > 1 && !lp->stripe_size) {
 		log_error("Stripesize for striped segment should not be 0!");
-		return EINVALID_CMD_LINE;
+		return 0;
 	}
 
 	if (lp->stripes > 1) {
 		if (lp->stripe_size < STRIPE_SIZE_MIN) {
 			log_error("Invalid stripe size %s",
 				  display_size(cmd, (uint64_t) lp->stripe_size));
-			return EINVALID_CMD_LINE;
+			return 0;
 		}
 
 		if (!(stripesize_extents = lp->stripe_size / vg->extent_size))
@@ -3843,7 +3844,7 @@ int lv_resize(struct cmd_context *cmd, struct volume_group *vg,
 			log_error("New size given (%d extents) not larger "
 				  "than existing size (%d extents)",
 				  lp->extents, lv->le_count);
-			return EINVALID_CMD_LINE;
+			return 0;
 		}
 		lp->resize = LV_REDUCE;
 	} else if (lp->extents > lv->le_count) {
@@ -3851,47 +3852,62 @@ int lv_resize(struct cmd_context *cmd, struct volume_group *vg,
 			log_error("New size given (%d extents) not less than "
 				  "existing size (%d extents)", lp->extents,
 				  lv->le_count);
-			return EINVALID_CMD_LINE;
+			return 0;
 		}
 		lp->resize = LV_EXTEND;
-	} else if (lp->extents == lv->le_count) {
-		if (lp->ac_policy)
-			return ECMD_PROCESSED; /* Nothing to do. */
+	} else if ((lp->extents == lv->le_count) && !lp->ac_policy) {
 		if (!lp->resizefs) {
 			log_error("New size (%d extents) matches existing size "
 				  "(%d extents)", lp->extents, lv->le_count);
-			return EINVALID_CMD_LINE;
+			return 0;
 		}
 		lp->resize = LV_EXTEND;
 	}
 
+	return 1;
+}
+
+static int _lvresize_check_type(struct cmd_context *cmd, const struct logical_volume *lv,
+				struct lvresize_params *lp)
+{
 	if (lv_is_origin(lv)) {
 		if (lp->resize == LV_REDUCE) {
 			log_error("Snapshot origin volumes cannot be reduced "
 				  "in size yet.");
-			return ECMD_FAILED;
+			return 0;
 		}
 
 		if (lv_is_active(lv)) {
 			log_error("Snapshot origin volumes can be resized "
 				  "only while inactive: try lvchange -an");
-			return ECMD_FAILED;
+			return 0;
 		}
 	}
 
 	if (lv_is_thin_pool(lv)) {
 		if (lp->resize == LV_REDUCE) {
 			log_error("Thin pool volumes cannot be reduced in size yet.");
-			return ECMD_FAILED;
+			return 0;
 		}
+	}
+
+	return 1;
+}
+
+static struct logical_volume *_lvresize_volume(struct cmd_context *cmd,
+					       struct logical_volume *lv,
+					       struct lvresize_params *lp, struct dm_list *pvh,
+					       alloc_policy_t alloc)
+{
+	struct volume_group *vg = lv->vg;
+	struct logical_volume *lock_lv = NULL;
+	int status;
 
+	if (lv_is_thin_pool(lv)) {
 		if (lp->resizefs) {
 			log_warn("Thin pool volumes do not have filesystem.");
 			lp->resizefs = 0;
 		}
-	} else if (lp->poolmetadatasize) {
-		log_error("--poolmetadatasize can be used only with thin pools.");
-		return ECMD_FAILED;
 	}
 
 	if ((lp->resize == LV_REDUCE) && lp->argc)
@@ -3900,27 +3916,28 @@ int lv_resize(struct cmd_context *cmd, struct volume_group *vg,
 	/* Request confirmation before operations that are often mistakes. */
 	if ((lp->resizefs || (lp->resize == LV_REDUCE)) &&
 	    !_request_confirmation(cmd, vg, lv, lp))
-		return_ECMD_FAILED;
+		return_NULL;
 
 	if (lp->resizefs) {
 		if (!lp->nofsck &&
 		    !_fsadm_cmd(cmd, vg, lp, FSADM_CMD_CHECK, &status)) {
 			if (status != FSADM_CHECK_FAILS_FOR_MOUNTED) {
 				log_error("Filesystem check failed.");
-				return ECMD_FAILED;
+				return NULL;
 			}
 			/* some filesystems supports online resize */
 		}
 
+		/* FIXME forks here */
 		if ((lp->resize == LV_REDUCE) &&
 		    !_fsadm_cmd(cmd, vg, lp, FSADM_CMD_RESIZE, NULL)) {
 			log_error("Filesystem resize failed.");
-			return ECMD_FAILED;
+			return NULL;
 		}
 	}
 
 	if (!archive(vg))
-		return_ECMD_FAILED;
+		return_NULL;
 
 	log_print_unless_silent("%sing logical volume %s to %s",
 				(lp->resize == LV_REDUCE) ? "Reduc" : "Extend",
@@ -3929,48 +3946,92 @@ int lv_resize(struct cmd_context *cmd, struct volume_group *vg,
 
 	if (lp->resize == LV_REDUCE) {
 		if (!lv_reduce(lv, lv->le_count - lp->extents))
-			return ECMD_FAILED;
+			return NULL;
 	} else if ((lp->extents > lv->le_count) && /* Ensure we extend */
 		   !lv_extend(lv, lp->segtype,
 			      lp->stripes, lp->stripe_size,
 			      lp->mirrors, first_seg(lv)->region_size,
 			      lp->extents - lv->le_count, NULL,
 			      pvh, alloc))
-		return_ECMD_FAILED;
+		return_NULL;
 
 	/* If thin metadata, must suspend thin pool */
 	if (lv_is_thin_pool_metadata(lv)) {
 		if (!(lock_lv = find_pool_lv(lv)))
-			return_0;
+			return_NULL;
 	/* If snapshot, must suspend all associated devices */
 	} else if (lv_is_cow(lv))
 		lock_lv = origin_from_cow(lv);
 	else
 		lock_lv = lv;
 
-	} /* lp->sizeargs */
+	return lock_lv;
+}
+
+int lv_resize_prepare(struct cmd_context *cmd, struct logical_volume *lv, 
+		      struct lvresize_params *lp, struct dm_list *pvh)
+{
+	if (!_lvresize_check_lv(cmd, lv, lp))
+		return_0;
+
+	if (lp->ac_policy && !_adjust_policy_params(cmd, lv, lp))
+		return_0;
+
+	if (!_lvresize_adjust_size(cmd, lv, lp))
+		return_0;
+
+	if (lp->sizeargs && !_lvresize_adjust_extents(cmd, lv, lp, pvh))
+		return_0;
+
+	if ((lp->extents == lv->le_count) && lp->ac_policy) {
+		/* Nothing to do. */
+		lp->sizeargs = 0;
+		lp->poolmetadatasize = 0;
+	}
+
+	if (lp->sizeargs && !_lvresize_check_type(cmd, lv, lp))
+		return_0;
+
+	return 1;
+}
+
+/* lv_resize_prepare MUST be called before this */
+int lv_resize(struct cmd_context *cmd, struct logical_volume *lv, 
+	      struct lvresize_params *lp, struct dm_list *pvh)
+{
+	struct volume_group *vg = lv->vg;
+	struct logical_volume *lock_lv = NULL;
+	alloc_policy_t alloc;
+	int r;
+
+	/* FIXME Could pool metadata have different policy? */
+	alloc = lp->ac_alloc ?: lv->alloc;
+
+	if (lp->sizeargs) {
+		if (!(lock_lv = _lvresize_volume(cmd, lv, lp, pvh, alloc)))
+			return_0;
+	}
 
 	if (lp->poolmetadatasize) {
-metadata_resize:
-		if (!(status = _lvresize_poolmetadata(cmd, vg, lp, lv, pvh, alloc)))
-			return_ECMD_FAILED;
-		else if ((status == 2) && !lp->sizeargs)
-			return ECMD_PROCESSED;
-		lock_lv = lv;
+		/* FIXME Pull validation / calculcations out of this function and do earlier */
+		if (!(r = _lvresize_poolmetadata(cmd, vg, lp, lv, pvh, alloc)))
+			return_0;
+		else if (r == 1)	/* Metadata needs writing out */
+			lock_lv = lv;
 	}
 
 	if (!lock_lv)
-		return ECMD_PROCESSED; /* Nothing to do */
+		return 1; /* Nothing to do */
 
 	/* store vg on disk(s) */
 	if (!vg_write(vg))
-		return_ECMD_FAILED;
+		return_0;
 
 	if (!suspend_lv(cmd, lock_lv)) {
 		log_error("Failed to suspend %s", lock_lv->name);
 		vg_revert(vg);
 		backup(vg);
-		return ECMD_FAILED;
+		return 0;
 	}
 
 	if (!vg_commit(vg)) {
@@ -3978,13 +4039,13 @@ metadata_resize:
 		if (!resume_lv(cmd, lock_lv))
 			stack;
 		backup(vg);
-		return ECMD_FAILED;
+		return 0;
 	}
 
 	if (!resume_lv(cmd, lock_lv)) {
 		log_error("Problem reactivating %s", lock_lv->name);
 		backup(vg);
-		return ECMD_FAILED;
+		return 0;
 	}
 
 	if (lv_is_cow_covering_origin(lv))
@@ -4003,15 +4064,15 @@ metadata_resize:
 	 */
 	if (lv_is_thin_pool(lv) &&
 	    !update_pool_lv(lv, !lv_is_active(lv)))
-		return_ECMD_FAILED;
+		return_0;
 
 	log_print_unless_silent("Logical volume %s successfully resized", lp->lv_name);
 
 	if (lp->resizefs && (lp->resize == LV_EXTEND) &&
 	    !_fsadm_cmd(cmd, vg, lp, FSADM_CMD_RESIZE, NULL))
-		return_ECMD_FAILED;
+		return_0;
 
-	return ECMD_PROCESSED;
+	return 1;
 }
 
 char *generate_lv_name(struct volume_group *vg, const char *format,
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index ee3ae66..412d29c 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -26,7 +26,6 @@
 #include "vg.h"
 #include "lv.h"
 #include "lvm-percent.h"
-#include "errors.h"
 
 #define MAX_STRIPES 128U
 #define SECTOR_SHIFT 9L
@@ -466,6 +465,7 @@ struct lvresize_params {
 	int argc;
 	char **argv;
 
+	/* FIXME Deal with meaningless 'ac' */
 	/* Arg counts & values */
 	unsigned ac_policy;
 	unsigned ac_stripes;
@@ -474,7 +474,7 @@ struct lvresize_params {
 	uint32_t ac_mirrors_value;
 	unsigned ac_stripesize;
 	uint64_t ac_stripesize_value;
-	unsigned ac_alloc;
+	alloc_policy_t ac_alloc;
 	unsigned ac_no_sync;
 	unsigned ac_force;
 
@@ -532,8 +532,10 @@ int vgs_are_compatible(struct cmd_context *cmd,
 		       struct volume_group *vg_to);
 uint32_t vg_lock_newname(struct cmd_context *cmd, const char *vgname);
 
-int lv_resize(struct cmd_context *cmd, struct volume_group *vg,
-		     struct lvresize_params *lp, struct dm_list *pvh);
+int lv_resize_prepare(struct cmd_context *cmd, struct logical_volume *lv,
+		      struct lvresize_params *lp, struct dm_list *pvh);
+int lv_resize(struct cmd_context *cmd, struct logical_volume *lv,
+	      struct lvresize_params *lp, struct dm_list *pvh);
 
 /*
  * Return a handle to VG metadata.
diff --git a/lib/metadata/pv_manip.c b/lib/metadata/pv_manip.c
index 5ab2d24..3a3ac09 100644
--- a/lib/metadata/pv_manip.c
+++ b/lib/metadata/pv_manip.c
@@ -22,7 +22,7 @@
 #include "lvmetad.h"
 #include "display.h"
 #include "label.h"
-#include "../../tools/tools.h"
+#include "archiver.h"
 
 static struct pv_segment *_alloc_pv_segment(struct dm_pool *mem,
 					    struct physical_volume *pv,
@@ -739,15 +739,15 @@ bad:
 }
 
 int pvremove_single(struct cmd_context *cmd, const char *pv_name,
-			   void *handle __attribute__((unused)), unsigned force_count,
-			   unsigned prompt)
+		    void *handle __attribute__((unused)), unsigned force_count,
+		    unsigned prompt)
 {
 	struct device *dev;
-	int ret = ECMD_FAILED;
+	int r = 0;
 
 	if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE, NULL)) {
 		log_error("Can't get lock for orphan PVs");
-		return ECMD_FAILED;
+		return 0;
 	}
 
 	if (!pvremove_check(cmd, pv_name, force_count, prompt))
@@ -778,30 +778,31 @@ int pvremove_single(struct cmd_context *cmd, const char *pv_name,
 	log_print_unless_silent("Labels on physical volume \"%s\" successfully wiped",
 				pv_name);
 
-	ret = ECMD_PROCESSED;
+	r = 1;
 
 out:
 	unlock_vg(cmd, VG_ORPHANS);
 
-	return ret;
+	return r;
 }
 
 int pvcreate_locked(struct cmd_context *cmd, const char *pv_name,
 		struct pvcreate_params *pp)
 {
-	int ret = ECMD_PROCESSED;
+	int r = 0;
 
 	if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE, NULL)) {
 		log_error("Can't get lock for orphan PVs");
-		return ECMD_FAILED;
+		return 0;
 	}
 
-	if (!(pvcreate_single(cmd, pv_name, pp, 1))) {
-		stack;
-		ret = ECMD_FAILED;
-	}
+	if (!(pvcreate_single(cmd, pv_name, pp, 1)))
+		goto_out;
+
+	r = 1;
 
+out:
 	unlock_vg(cmd, VG_ORPHANS);
 
-	return ret;
+	return r;
 }
diff --git a/liblvm/lvm_lv.c b/liblvm/lvm_lv.c
index 15bd813..4171baa 100644
--- a/liblvm/lvm_lv.c
+++ b/liblvm/lvm_lv.c
@@ -22,6 +22,8 @@
 #include "lvm_misc.h"
 #include "lvm2app.h"
 
+/* FIXME Improve all the log messages to include context. Which VG/LV as a minimum? */
+
 struct lvm_lv_create_params
 {
 	uint32_t magic;
@@ -229,6 +231,7 @@ int lvm_lv_activate(lv_t lv)
 		log_verbose("Activating logical volume \"%s\" "
 			    "exclusively", lv->name);
 		if (!activate_lv_excl(lv->vg->cmd, lv)) {
+			/* FIXME Improve msg */
 			log_error("Activate exclusive failed.");
 			return -1;
 		}
@@ -236,6 +239,7 @@ int lvm_lv_activate(lv_t lv)
 		log_verbose("Activating logical volume \"%s\"",
 			    lv->name);
 		if (!activate_lv(lv->vg->cmd, lv)) {
+			/* FIXME Improve msg */
 			log_error("Activate failed.");
 			return -1;
 		}
@@ -320,7 +324,8 @@ lv_t lvm_lv_from_uuid(vg_t vg, const char *uuid)
 int lvm_lv_rename(lv_t lv, const char *new_name)
 {
 	if (!lv_rename(lv->vg->cmd, lv, new_name)) {
-		log_verbose("LV Rename failed.");
+		/* FIXME Improve msg */
+		log_error("LV rename failed.");
 		return -1;
 	}
 	return 0;
@@ -339,8 +344,11 @@ int lvm_lv_resize(const lv_t lv, uint64_t new_size)
 	lp.ac_force = 1;	/* Assume the user has a good backup? */
 	lp.sizeargs = 1;
 
-	if (ECMD_PROCESSED != lv_resize(lv->vg->cmd, lv->vg, &lp, &lv->vg->pvs)) {
-		log_verbose("LV Re-size failed.");
+	if (!lv_resize_prepare(lv->vg->cmd, lv, &lp, &lv->vg->pvs) ||
+	    !lv_resize(lv->vg->cmd, lv, &lp, &lv->vg->pvs)) {
+		/* FIXME Improve msg */
+		log_error("LV resize failed.");
+		/* FIXME Define consistent symbolic return codes */
 		return -1;
 	}
 
diff --git a/liblvm/lvm_pv.c b/liblvm/lvm_pv.c
index 622ef98..5d8a66b 100644
--- a/liblvm/lvm_pv.c
+++ b/liblvm/lvm_pv.c
@@ -73,7 +73,7 @@ int lvm_pv_remove(lvm_t libh, const char *pv_name)
 {
 	struct cmd_context *cmd = (struct cmd_context *)libh;
 
-	if (pvremove_single(cmd, pv_name, NULL, 0, 0) != 1)
+	if (!pvremove_single(cmd, pv_name, NULL, 0, 0))
 		return -1;
 
 	return 0;
@@ -235,7 +235,7 @@ int lvm_pv_create(lvm_t libh, const char *pv_name, uint64_t size)
 
 	pp.size = size_sectors;
 
-	if (pvcreate_locked(cmd, pv_name, &pp) != ECMD_PROCESSED)
+	if (!pvcreate_locked(cmd, pv_name, &pp))
 		return -1;
 
 	return 0;
diff --git a/tools/errors.h b/tools/errors.h
new file mode 100644
index 0000000..a644fc7
--- /dev/null
+++ b/tools/errors.h
@@ -0,0 +1,26 @@
+/*
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
+ * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
+#ifndef _LVM_ERRORS_H
+#define _LVM_ERRORS_H
+
+#define ECMD_PROCESSED		1
+#define ENO_SUCH_CMD		2
+#define EINVALID_CMD_LINE	3
+#define ECMD_FAILED		5
+
+/* FIXME Also returned by cmdlib. */
+
+#endif
diff --git a/tools/lvm2cmd.h b/tools/lvm2cmd.h
index bf93787..6df959d 100644
--- a/tools/lvm2cmd.h
+++ b/tools/lvm2cmd.h
@@ -36,6 +36,12 @@ typedef void (*lvm2_log_fn_t) (int level, const char *file, int line,
 #define LVM2_LOG_VERY_VERBOSE	6
 #define LVM2_LOG_DEBUG		7
 
+/* Return values */
+#define LVM2_COMMAND_SUCCEEDED	1	/* ECMD_PROCESSED */
+#define LVM2_NO_SUCH_COMMAND	2	/* ENO_SUCH_CMD */
+#define LVM2_INVALID_PARAMETERS	3	/* EINVALID_CMD_LINE */
+#define LVM2_PROCESSING_FAILED	5	/* ECMD_FAILED */
+
 /*
  * Define external function to replace the built-in logging function.
  * It receives output line-by-line.
diff --git a/tools/lvresize.c b/tools/lvresize.c
index 7c73341..c5f01da 100644
--- a/tools/lvresize.c
+++ b/tools/lvresize.c
@@ -156,7 +156,7 @@ static int _lvresize_params(struct cmd_context *cmd, int argc, char **argv,
 	}
 
 	lp->ac_no_sync = arg_count(cmd, nosync_ARG);
-	lp->ac_alloc = arg_uint_value(cmd, alloc_ARG, 0);
+	lp->ac_alloc = (alloc_policy_t) arg_uint_value(cmd, alloc_ARG, 0);
 
 	lp->ac_type = arg_str_value(cmd, type_ARG, NULL);
 	lp->ac_force = arg_count(cmd, force_ARG);
@@ -168,8 +168,9 @@ int lvresize(struct cmd_context *cmd, int argc, char **argv)
 {
 	struct lvresize_params lp = { 0 };
 	struct volume_group *vg;
-	int r;
 	struct dm_list *pvh = NULL;
+	struct lv_list *lvl;
+	int r = ECMD_FAILED;
 
 	if (!_lvresize_params(cmd, argc, argv, &lp))
 		return EINVALID_CMD_LINE;
@@ -181,15 +182,28 @@ int lvresize(struct cmd_context *cmd, int argc, char **argv)
 		return_ECMD_FAILED;
 	}
 
-	/* How does this list get cleaned up? */
+        /* Does LV exist? */
+        if (!(lvl = find_lv_in_vg(vg, lp.lv_name))) {
+                log_error("Logical volume %s not found in volume group %s",
+                          lp.lv_name, lp.vg_name);
+		goto out;
+        }
+
 	if (!(pvh = lp.argc ? create_pv_list(cmd->mem, vg, lp.argc,
-						     lp.argv, 1) : &vg->pvs)) {
-		return_ECMD_FAILED;
+					     lp.argv, 1) : &vg->pvs))
+		goto_out;
+
+	if (!lv_resize_prepare(cmd, lvl->lv, &lp, pvh)) {
+		r = EINVALID_CMD_LINE;
+		goto_out;
 	}
 
-	if (!(r = lv_resize(cmd, vg, &lp, pvh)))
-		stack;
+	if (!lv_resize(cmd, lvl->lv, &lp, pvh))
+		goto_out;
+
+	r = ECMD_PROCESSED;
 
+out:
 	unlock_and_release_vg(cmd, vg, lp.vg_name);
 
 	return r;
diff --git a/tools/pvcreate.c b/tools/pvcreate.c
index b18e400..38642f6 100644
--- a/tools/pvcreate.c
+++ b/tools/pvcreate.c
@@ -113,9 +113,8 @@ int pvcreate(struct cmd_context *cmd, int argc, char **argv)
 
 		dm_unescape_colons_and_at_signs(argv[i], NULL, NULL);
 
-		if (ECMD_PROCESSED != pvcreate_locked(cmd, argv[i], &pp)) {
+		if (!pvcreate_locked(cmd, argv[i], &pp))
 			ret = ECMD_FAILED;
-		}
 	}
 
 	return ret;
diff --git a/tools/pvremove.c b/tools/pvremove.c
index a99a9bd..45c675e 100644
--- a/tools/pvremove.c
+++ b/tools/pvremove.c
@@ -16,7 +16,6 @@
 #include "tools.h"
 #include "metadata.h"
 
-
 int pvremove(struct cmd_context *cmd, int argc, char **argv)
 {
 	int i, r;
@@ -34,9 +33,8 @@ int pvremove(struct cmd_context *cmd, int argc, char **argv)
 
 	for (i = 0; i < argc; i++) {
 		dm_unescape_colons_and_at_signs(argv[i], NULL, NULL);
-		r = pvremove_single(cmd, argv[i], NULL, force_count, prompt);
-		if (r > ret)
-			ret = r;
+		if (!pvremove_single(cmd, argv[i], NULL, force_count, prompt))
+			ret = ECMD_FAILED;
 	}
 
 	return ret;


