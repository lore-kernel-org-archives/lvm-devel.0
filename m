From: Peter Rajnoha <prajnoha@redhat.com>
Date: Fri, 15 Nov 2013 16:01:06 +0100
Subject: [PATCH 3/6] lv_manip: rename set_lv -> wipe_lv and include signature wiping capability
Message-ID: <52863732.4040603@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Use common wipe_lv (former set_lv) fn to do zeroing as well as signature
wiping if needed. Provide new struct wipe_lv_params to define the
functionality.

Bind "lvcreate -W/--wipesignatures y" with proper wipe_lv call.

Also, add "yes" and "force" to lvcreate_params so it's possible
to apply them for the prompt: "WARNING: %s detected on %s. Wipe it? [y/n]".
---
 lib/metadata/lv_manip.c          | 98 ++++++++++++++++++++++++++++------------
 lib/metadata/metadata-exported.h | 18 ++++++--
 lib/metadata/mirror.c            | 18 ++++++--
 lib/metadata/raid_manip.c        | 11 ++++-
 lib/metadata/thin_manip.c        | 12 ++++-
 tools/lvchange.c                 | 13 +++++-
 tools/lvconvert.c                | 27 ++++++++++-
 tools/lvcreate.c                 |  2 +
 8 files changed, 157 insertions(+), 42 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 4a224e4..2f09ae5 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -2906,7 +2906,17 @@ static int _lv_extend_layered_lv(struct alloc_handle *ah,
 			 * wipe '1' to remove the superblock of any previous
 			 * RAID devices.  It is much quicker.
 			 */
-			if (!set_lv(meta_lv->vg->cmd, meta_lv, 1, 0)) {
+			struct wipe_lv_params wp = {
+				.lv = meta_lv,
+				.do_zero = 1,
+				.zero_sectors = 1,
+				.zero_value = 0,
+				.do_wipe_signatures = 0,
+				.yes = 0,
+				.force = PROMPT
+			};
+
+			if (!wipe_lv(meta_lv->vg->cmd, &wp)) {
 				log_error("Failed to zero %s/%s",
 					  meta_lv->vg->name, meta_lv->name);
 				return 0;
@@ -5375,15 +5385,19 @@ int insert_layer_for_segments_on_pv(struct cmd_context *cmd,
 /*
  * Initialize the LV with 'value'.
  */
-int set_lv(struct cmd_context *cmd, struct logical_volume *lv,
-	   uint64_t sectors, int value)
+int wipe_lv(struct cmd_context *cmd, struct wipe_lv_params *wp)
 {
 	struct device *dev;
 	char *name;
+	uint64_t zero_sectors;
 
-	if (!lv_is_active_locally(lv)) {
+	if (!(wp->do_zero || wp->do_wipe_signatures))
+		/* nothing to do */
+		return 1;
+
+	if (!lv_is_active_locally(wp->lv)) {
 		log_error("Volume \"%s/%s\" is not active locally.",
-			  lv->vg->name, lv->name);
+			  wp->lv->vg->name, wp->lv->name);
 		return 0;
 	}
 
@@ -5400,15 +5414,13 @@ int set_lv(struct cmd_context *cmd, struct logical_volume *lv,
 	}
 
 	if (dm_snprintf(name, PATH_MAX, "%s%s/%s", cmd->dev_dir,
-			lv->vg->name, lv->name) < 0) {
-		log_error("Name too long - device not cleared (%s)", lv->name);
+			wp->lv->vg->name, wp->lv->name) < 0) {
+		log_error("Name too long - device not cleared (%s)", wp->lv->name);
 		return 0;
 	}
 
 	sync_local_dev_names(cmd);  /* Wait until devices are available */
 
-	log_verbose("Clearing start of logical volume \"%s\"", lv->name);
-
 	if (!(dev = dev_cache_get(name, NULL))) {
 		log_error("%s: not found: device not cleared", name);
 		return 0;
@@ -5417,21 +5429,32 @@ int set_lv(struct cmd_context *cmd, struct logical_volume *lv,
 	if (!dev_open_quiet(dev))
 		return_0;
 
-	if (!sectors)
-		sectors = UINT64_C(4096) >> SECTOR_SHIFT;
+	if (wp->do_wipe_signatures) {
+		log_verbose("Wiping known signatures on logical volume \"%s/%s\"",
+			     wp->lv->vg->name, wp->lv->name);
+		if (!wipe_known_sbs(dev, name, wp->yes, wp->force))
+			stack;
+	}
 
-	if (sectors > lv->size)
-		sectors = lv->size;
+	if (wp->do_zero) {
+		zero_sectors = wp->zero_sectors ? : UINT64_C(4096) >> SECTOR_SHIFT;
 
-	if (!dev_set(dev, UINT64_C(0), (size_t) sectors << SECTOR_SHIFT, value))
-		stack;
+		if (zero_sectors > wp->lv->size)
+			zero_sectors = wp->lv->size;
+
+		log_verbose("Clearing start of logical volume \"%s/%s\"",
+			     wp->lv->vg->name, wp->lv->name);
+
+		if (!dev_set(dev, UINT64_C(0), (size_t) zero_sectors << SECTOR_SHIFT, wp->zero_value))
+			stack;
+	}
 
 	dev_flush(dev);
 
 	if (!dev_close_immediate(dev))
 		stack;
 
-	lv->status &= ~LV_NOSCAN;
+	wp->lv->status &= ~LV_NOSCAN;
 
 	return 1;
 }
@@ -5985,12 +6008,12 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 	backup(vg);
 
 	if (test_mode()) {
-		log_verbose("Test mode: Skipping activation and zeroing.");
+		log_verbose("Test mode: Skipping activation, zeroing and signature wiping.");
 		goto out;
 	}
 
-	/* Do not scan this LV until properly zeroed. */
-	if (lp->zero)
+	/* Do not scan this LV until properly zeroed/wiped. */
+	if (lp->zero | lp->wipe_signatures)
 		lv->status |= LV_NOSCAN;
 
 	if (lp->temporary)
@@ -6059,21 +6082,36 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 		}
 	} else if (!lv_active_change(cmd, lv, lp->activate)) {
 		log_error("Failed to activate new LV.");
-		if (lp->zero)
+		if (lp->zero || lp->wipe_signatures)
 			goto deactivate_and_revert_new_lv;
 		return NULL;
 	}
 
-	if (!seg_is_thin(lp) && !lp->zero && !lp->snapshot)
-		log_warn("WARNING: \"%s\" not zeroed", lv->name);
-	else if ((!seg_is_thin(lp) ||
-		  (lv_is_thin_volume(lv) && !lp->snapshot &&
-		   !first_seg(first_seg(lv)->pool_lv)->zero_new_blocks)) &&
-		 !set_lv(cmd, lv, UINT64_C(0), 0)) {
-		log_error("Aborting. Failed to wipe %s.",
-			  lp->snapshot ? "snapshot exception store" :
-					 "start of new LV");
-		goto deactivate_and_revert_new_lv;
+	if (!seg_is_thin(lp) && !lp->snapshot) {
+		if (!lp->zero)
+			log_warn("WARNING: \"%s/%s\" not zeroed", lv->vg->name, lv->name);
+		if (!lp->wipe_signatures)
+			log_verbose("Signature wiping on \"%s/%s\" not requested", lv->vg->name, lv->name);
+	}
+
+	if ((!seg_is_thin(lp) ||
+	    (lv_is_thin_volume(lv) && !lp->snapshot &&
+	     !first_seg(first_seg(lv)->pool_lv)->zero_new_blocks))) {
+		struct wipe_lv_params wp = {
+			.lv = lv,
+			.do_zero = lp->zero,
+			.zero_sectors = 0,
+			.zero_value = 0,
+			.do_wipe_signatures = lp->wipe_signatures,
+			.yes = lp->yes,
+			.force = lp->force
+		};
+		if (!wipe_lv(cmd, &wp)) {
+			log_error("Aborting. Failed to wipe %s.",
+				  lp->snapshot ? "snapshot exception store" :
+						 "start of new LV");
+			goto deactivate_and_revert_new_lv;
+		}
 	}
 
 	if (lp->snapshot && !seg_is_thin(lp)) {
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 52c04d9..d166fe1 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -620,9 +620,18 @@ struct logical_volume *lv_create_empty(const char *name,
 				       alloc_policy_t alloc,
 				       struct volume_group *vg);
 
-/* Write out LV contents */
-int set_lv(struct cmd_context *cmd, struct logical_volume *lv,
-	   uint64_t sectors, int value);
+struct wipe_lv_params {
+	struct logical_volume *lv;
+	int do_zero;		/* should we do zeroing of LV start? */
+	uint64_t zero_sectors;	/* sector count to zero */
+	int zero_value;		/* zero-out with this value */
+	int do_wipe_signatures;	/* should we wipe known signatures found on LV? */
+	int yes;		/* answer yes automatically to all questions */
+	force_t force;		/* force mode */
+};
+
+/* Zero out LV and/or wipe signatures */
+int wipe_lv(struct cmd_context *cmd, struct wipe_lv_params *params);
 
 int lv_change_tag(struct logical_volume *lv, const char *tag, int add_tag);
 
@@ -777,6 +786,9 @@ struct lvcreate_params {
 	alloc_policy_t alloc; /* all */
 
 	struct dm_list tags;	/* all */
+
+	int yes;
+	force_t force;
 };
 
 struct logical_volume *lv_create_single(struct volume_group *vg,
diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index 24c9786..83ba486 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -339,10 +339,20 @@ static int _init_mirror_log(struct cmd_context *cmd,
 	dm_list_iterate_items(sl, tags)
 		str_list_del(&log_lv->tags, sl->str);
 
-	if (activation() && !set_lv(cmd, log_lv, log_lv->size,
-				    in_sync ? -1 : 0)) {
-		log_error("Aborting. Failed to wipe mirror log.");
-		goto deactivate_and_revert_new_lv;
+	if (activation()) {
+		struct wipe_lv_params wp = {
+			.lv = log_lv,
+			.do_zero = 1,
+			.zero_sectors = log_lv->size,
+			.zero_value = in_sync ? -1 : 0,
+			.do_wipe_signatures = 0,
+			.yes = 0,
+			.force = PROMPT
+		};
+		if (!wipe_lv(cmd, &wp)) {
+			log_error("Aborting. Failed to wipe mirror log.");
+			goto deactivate_and_revert_new_lv;
+		}
 	}
 
 	if (activation() && !_write_log_header(cmd, log_lv)) {
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 147b478..d1bb330 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -170,6 +170,15 @@ static int _raid_remove_top_layer(struct logical_volume *lv,
 static int _clear_lv(struct logical_volume *lv)
 {
 	int was_active = lv_is_active_locally(lv);
+	struct wipe_lv_params wp = {
+		.lv = lv,
+		.do_zero = 1,
+		.zero_sectors = 1,
+		.zero_value = 0,
+		.do_wipe_signatures = 0,
+		.yes = 0,
+		.force = PROMPT
+	};
 
 	if (test_mode())
 		return 1;
@@ -187,7 +196,7 @@ static int _clear_lv(struct logical_volume *lv)
 	 * wipe the first sector to remove the superblock of any previous
 	 * RAID devices.  It is much quicker.
 	 */
-	if (!set_lv(lv->vg->cmd, lv, 1, 0)) {
+	if (!wipe_lv(lv->vg->cmd, &wp)) {
 		log_error("Failed to zero %s", lv->name);
 		return 0;
 	}
diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index bd5b117..4ee4411 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -468,10 +468,20 @@ int create_pool(struct logical_volume *pool_lv, const struct segment_type *segty
 		 * FIXME: implement lazy clearing when activation is disabled
 		 */
 
+		struct wipe_lv_params wp = {
+			.lv = pool_lv,
+			.do_zero = 1,
+			.zero_sectors = 0,
+			.zero_value = 0,
+			.do_wipe_signatures = 0,
+			.yes = 0,
+			.force = PROMPT
+		};
+
 		/* pool_lv is a new LV so the VG lock protects us */
 		if (!activate_lv_local(pool_lv->vg->cmd, pool_lv) ||
 		    /* Clear 4KB of metadata device for new thin-pool. */
-		    !set_lv(pool_lv->vg->cmd, pool_lv, UINT64_C(0), 0)) {
+		    !wipe_lv(pool_lv->vg->cmd, &wp)) {
 			log_error("Aborting. Failed to wipe pool metadata %s.",
 				  pool_lv->name);
 			goto bad;
diff --git a/tools/lvchange.c b/tools/lvchange.c
index 1931c03..0590510 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -478,7 +478,18 @@ static int lvchange_resync(struct cmd_context *cmd, struct logical_volume *lv)
 		log_very_verbose("Clearing %s device %s",
 				 (seg_is_raid(seg)) ? "metadata" : "log",
 				 lvl->lv->name);
-		if (!set_lv(cmd, lvl->lv, lvl->lv->size, 0)) {
+
+		struct wipe_lv_params wp = {
+			.lv = lvl->lv,
+			.do_zero = 1,
+			.zero_sectors = lvl->lv->size,
+			.zero_value = 0,
+			.do_wipe_signatures = 0,
+			.yes = 0,
+			.force = PROMPT
+		};
+
+		if (!wipe_lv(cmd, &wp)) {
 			log_error("Unable to reset sync status for %s",
 				  lv->name);
 			if (!deactivate_lv(cmd, lvl->lv))
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 92a2022..9b3f90d 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1846,10 +1846,22 @@ static int lvconvert_snapshot(struct cmd_context *cmd,
 
 	if (!lp->zero || !(lv->status & LVM_WRITE))
 		log_warn("WARNING: \"%s\" not zeroed", lv->name);
-	else if (!set_lv(cmd, lv, UINT64_C(0), 0)) {
+	else {
+		struct wipe_lv_params wp = {
+			.lv = lv,
+			.do_zero = 1,
+			.zero_sectors = 0,
+			.zero_value = 0,
+			.do_wipe_signatures = 0,
+			.yes = 0,
+			.force = PROMPT
+		};
+
+		if (!wipe_lv(cmd, &wp)) {
 		log_error("Aborting. Failed to wipe snapshot "
 			  "exception store.");
 		return 0;
+		}
 	}
 
 	if (!deactivate_lv(cmd, lv)) {
@@ -2462,7 +2474,18 @@ static int _lvconvert_thinpool(struct cmd_context *cmd,
 			log_error("Aborting. Failed to activate thin metadata lv.");
 			return 0;
 		}
-		if (!set_lv(cmd, metadata_lv, UINT64_C(0), 0)) {
+
+		struct wipe_lv_params wp = {
+			.lv = metadata_lv,
+			.do_zero = 1,
+			.zero_sectors = 0,
+			.zero_value = 0,
+			.do_wipe_signatures = 0,
+			.yes = 0,
+			.force = PROMPT
+		};
+
+		if (!wipe_lv(cmd, &wp)) {
 			log_error("Aborting. Failed to wipe thin metadata lv.");
 			return 0;
 		}
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 8184024..57d9464 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -710,6 +710,8 @@ static int _read_activation_params(struct lvcreate_params *lp, struct cmd_contex
 		return 0;
 	}
 
+	lp->yes = arg_count(cmd, yes_ARG);
+	lp->force = (force_t) arg_count(cmd, force_ARG);
 
 	return 1;
 }
-- 
1.8.4.2


