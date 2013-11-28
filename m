From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 28 Nov 2013 11:48:53 +0000 (UTC)
Subject: master - cleanup: use compound literals for wipe_lv
Message-ID: <20131128114853.355E560F37@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8c96afd361686647e10f3bf70c03dea62b82bc01
Commit:        8c96afd361686647e10f3bf70c03dea62b82bc01
Parent:        a1eda8ea245ec7af684fb50e7f0abf5229d9bcfb
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Nov 28 11:22:24 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Nov 28 12:45:52 2013 +0100

cleanup: use compound literals for wipe_lv

Optimize and cleanup recently introduced new function wipe_lv.
Use compound literals to get nicely initialized wipe_params struct.
Pass in lv as explicit argument for wipe_lv.
Use cmd from lv structure.
Initialize only non-null members so it's easy to see what
is the special arg.
---
 lib/metadata/lv_manip.c          |   73 ++++++++++++++-----------------------
 lib/metadata/metadata-exported.h |    5 +--
 lib/metadata/mirror.c            |   13 ++-----
 lib/metadata/raid_manip.c        |   11 +-----
 lib/metadata/thin_manip.c        |   13 +------
 tools/lvchange.c                 |   13 +------
 tools/lvconvert.c                |   27 ++------------
 7 files changed, 40 insertions(+), 115 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 2480942..1fec9a5 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -2906,17 +2906,8 @@ static int _lv_extend_layered_lv(struct alloc_handle *ah,
 			 * wipe '1' to remove the superblock of any previous
 			 * RAID devices.  It is much quicker.
 			 */
-			struct wipe_lv_params wp = {
-				.lv = meta_lv,
-				.do_zero = 1,
-				.zero_sectors = 1,
-				.zero_value = 0,
-				.do_wipe_signatures = 0,
-				.yes = 0,
-				.force = PROMPT
-			};
-
-			if (!wipe_lv(meta_lv->vg->cmd, &wp)) {
+			if (!wipe_lv(meta_lv, (struct wipe_params)
+				     { .do_zero = 1, .zero_sectors = 1 })) {
 				log_error("Failed to zero %s/%s",
 					  meta_lv->vg->name, meta_lv->name);
 				return 0;
@@ -5382,19 +5373,19 @@ int insert_layer_for_segments_on_pv(struct cmd_context *cmd,
 /*
  * Initialize the LV with 'value'.
  */
-int wipe_lv(struct cmd_context *cmd, struct wipe_lv_params *wp)
+int wipe_lv(struct logical_volume *lv, struct wipe_params wp)
 {
 	struct device *dev;
-	char *name;
+	char name[PATH_MAX];
 	uint64_t zero_sectors;
 
-	if (!(wp->do_zero || wp->do_wipe_signatures))
+	if (!wp.do_zero && !wp.do_wipe_signatures)
 		/* nothing to do */
 		return 1;
 
-	if (!lv_is_active_locally(wp->lv)) {
+	if (!lv_is_active_locally(lv)) {
 		log_error("Volume \"%s/%s\" is not active locally.",
-			  wp->lv->vg->name, wp->lv->name);
+			  lv->vg->name, lv->name);
 		return 0;
 	}
 
@@ -5405,18 +5396,13 @@ int wipe_lv(struct cmd_context *cmd, struct wipe_lv_params *wp)
 	 * <ejt_> k, I'll drop a fixme to that effect
 	 *	   (I know the device is at least 4k, but not 32k)
 	 */
-	if (!(name = dm_pool_alloc(cmd->mem, PATH_MAX))) {
-		log_error("Name allocation failed - device not cleared");
-		return 0;
-	}
-
-	if (dm_snprintf(name, PATH_MAX, "%s%s/%s", cmd->dev_dir,
-			wp->lv->vg->name, wp->lv->name) < 0) {
-		log_error("Name too long - device not cleared (%s)", wp->lv->name);
+	if (dm_snprintf(name, sizeof(name), "%s%s/%s", lv->vg->cmd->dev_dir,
+			lv->vg->name, lv->name) < 0) {
+		log_error("Name too long - device not cleared (%s)", lv->name);
 		return 0;
 	}
 
-	sync_local_dev_names(cmd);  /* Wait until devices are available */
+	sync_local_dev_names(lv->vg->cmd);  /* Wait until devices are available */
 
 	if (!(dev = dev_cache_get(name, NULL))) {
 		log_error("%s: not found: device not cleared", name);
@@ -5426,23 +5412,23 @@ int wipe_lv(struct cmd_context *cmd, struct wipe_lv_params *wp)
 	if (!dev_open_quiet(dev))
 		return_0;
 
-	if (wp->do_wipe_signatures) {
+	if (wp.do_wipe_signatures) {
 		log_verbose("Wiping known signatures on logical volume \"%s/%s\"",
-			     wp->lv->vg->name, wp->lv->name);
-		if (!wipe_known_signatures(cmd, dev, name, wp->yes, wp->force))
+			     lv->vg->name, lv->name);
+		if (!wipe_known_signatures(lv->vg->cmd, dev, name, wp.yes, wp.force))
 			stack;
 	}
 
-	if (wp->do_zero) {
-		zero_sectors = wp->zero_sectors ? : UINT64_C(4096) >> SECTOR_SHIFT;
+	if (wp.do_zero) {
+		zero_sectors = wp.zero_sectors ? : UINT64_C(4096) >> SECTOR_SHIFT;
 
-		if (zero_sectors > wp->lv->size)
-			zero_sectors = wp->lv->size;
+		if (zero_sectors > lv->size)
+			zero_sectors = lv->size;
 
 		log_verbose("Clearing start of logical volume \"%s/%s\"",
-			     wp->lv->vg->name, wp->lv->name);
+			     lv->vg->name, lv->name);
 
-		if (!dev_set(dev, UINT64_C(0), (size_t) zero_sectors << SECTOR_SHIFT, wp->zero_value))
+		if (!dev_set(dev, UINT64_C(0), (size_t) zero_sectors << SECTOR_SHIFT, wp.zero_value))
 			stack;
 	}
 
@@ -5451,7 +5437,7 @@ int wipe_lv(struct cmd_context *cmd, struct wipe_lv_params *wp)
 	if (!dev_close_immediate(dev))
 		stack;
 
-	wp->lv->status &= ~LV_NOSCAN;
+	lv->status &= ~LV_NOSCAN;
 
 	return 1;
 }
@@ -6094,16 +6080,13 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 	if ((!seg_is_thin(lp) ||
 	    (lv_is_thin_volume(lv) && !lp->snapshot &&
 	     !first_seg(first_seg(lv)->pool_lv)->zero_new_blocks))) {
-		struct wipe_lv_params wp = {
-			.lv = lv,
-			.do_zero = lp->zero,
-			.zero_sectors = 0,
-			.zero_value = 0,
-			.do_wipe_signatures = lp->wipe_signatures,
-			.yes = lp->yes,
-			.force = lp->force
-		};
-		if (!wipe_lv(cmd, &wp)) {
+		if (!wipe_lv(lv, (struct wipe_params)
+			     {
+				     .do_zero = lp->zero,
+				     .do_wipe_signatures = lp->wipe_signatures,
+				     .yes = lp->yes,
+				     .force = lp->force
+			     })) {
 			log_error("Aborting. Failed to wipe %s.",
 				  lp->snapshot ? "snapshot exception store" :
 						 "start of new LV");
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index c274649..ece5f53 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -622,8 +622,7 @@ struct logical_volume *lv_create_empty(const char *name,
 				       alloc_policy_t alloc,
 				       struct volume_group *vg);
 
-struct wipe_lv_params {
-	struct logical_volume *lv;
+struct wipe_params {
 	int do_zero;		/* should we do zeroing of LV start? */
 	uint64_t zero_sectors;	/* sector count to zero */
 	int zero_value;		/* zero-out with this value */
@@ -633,7 +632,7 @@ struct wipe_lv_params {
 };
 
 /* Zero out LV and/or wipe signatures */
-int wipe_lv(struct cmd_context *cmd, struct wipe_lv_params *params);
+int wipe_lv(struct logical_volume *lv, struct wipe_params params);
 
 int lv_change_tag(struct logical_volume *lv, const char *tag, int add_tag);
 
diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index 83ba486..a2b2feb 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -340,16 +340,9 @@ static int _init_mirror_log(struct cmd_context *cmd,
 		str_list_del(&log_lv->tags, sl->str);
 
 	if (activation()) {
-		struct wipe_lv_params wp = {
-			.lv = log_lv,
-			.do_zero = 1,
-			.zero_sectors = log_lv->size,
-			.zero_value = in_sync ? -1 : 0,
-			.do_wipe_signatures = 0,
-			.yes = 0,
-			.force = PROMPT
-		};
-		if (!wipe_lv(cmd, &wp)) {
+		if (!wipe_lv(log_lv, (struct wipe_params)
+			     { .do_zero = 1, .zero_sectors = log_lv->size,
+			       .zero_value = in_sync ? -1 : 0 })) {
 			log_error("Aborting. Failed to wipe mirror log.");
 			goto deactivate_and_revert_new_lv;
 		}
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index d1bb330..a29ea85 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -170,15 +170,6 @@ static int _raid_remove_top_layer(struct logical_volume *lv,
 static int _clear_lv(struct logical_volume *lv)
 {
 	int was_active = lv_is_active_locally(lv);
-	struct wipe_lv_params wp = {
-		.lv = lv,
-		.do_zero = 1,
-		.zero_sectors = 1,
-		.zero_value = 0,
-		.do_wipe_signatures = 0,
-		.yes = 0,
-		.force = PROMPT
-	};
 
 	if (test_mode())
 		return 1;
@@ -196,7 +187,7 @@ static int _clear_lv(struct logical_volume *lv)
 	 * wipe the first sector to remove the superblock of any previous
 	 * RAID devices.  It is much quicker.
 	 */
-	if (!wipe_lv(lv->vg->cmd, &wp)) {
+	if (!wipe_lv(lv, (struct wipe_params) { .do_zero = 1, .zero_sectors = 1 })) {
 		log_error("Failed to zero %s", lv->name);
 		return 0;
 	}
diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index 4ee4411..b3fedcf 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -467,21 +467,10 @@ int create_pool(struct logical_volume *pool_lv, const struct segment_type *segty
 		 *
 		 * FIXME: implement lazy clearing when activation is disabled
 		 */
-
-		struct wipe_lv_params wp = {
-			.lv = pool_lv,
-			.do_zero = 1,
-			.zero_sectors = 0,
-			.zero_value = 0,
-			.do_wipe_signatures = 0,
-			.yes = 0,
-			.force = PROMPT
-		};
-
 		/* pool_lv is a new LV so the VG lock protects us */
 		if (!activate_lv_local(pool_lv->vg->cmd, pool_lv) ||
 		    /* Clear 4KB of metadata device for new thin-pool. */
-		    !wipe_lv(pool_lv->vg->cmd, &wp)) {
+		    !wipe_lv(pool_lv, (struct wipe_params) { .do_zero = 1 })) {
 			log_error("Aborting. Failed to wipe pool metadata %s.",
 				  pool_lv->name);
 			goto bad;
diff --git a/tools/lvchange.c b/tools/lvchange.c
index 59a554c..a0e350f 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -479,17 +479,8 @@ static int lvchange_resync(struct cmd_context *cmd, struct logical_volume *lv)
 				 (seg_is_raid(seg)) ? "metadata" : "log",
 				 lvl->lv->name);
 
-		struct wipe_lv_params wp = {
-			.lv = lvl->lv,
-			.do_zero = 1,
-			.zero_sectors = lvl->lv->size,
-			.zero_value = 0,
-			.do_wipe_signatures = 0,
-			.yes = 0,
-			.force = PROMPT
-		};
-
-		if (!wipe_lv(cmd, &wp)) {
+		if (!wipe_lv(lvl->lv, (struct wipe_params)
+			     { .do_zero = 1, .zero_sectors = lvl->lv->size })) {
 			log_error("Unable to reset sync status for %s",
 				  lv->name);
 			if (!deactivate_lv(cmd, lvl->lv))
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 34c8de2..9a542a6 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1847,22 +1847,10 @@ static int lvconvert_snapshot(struct cmd_context *cmd,
 
 	if (!lp->zero || !(lv->status & LVM_WRITE))
 		log_warn("WARNING: \"%s\" not zeroed", lv->name);
-	else {
-		struct wipe_lv_params wp = {
-			.lv = lv,
-			.do_zero = 1,
-			.zero_sectors = 0,
-			.zero_value = 0,
-			.do_wipe_signatures = 0,
-			.yes = 0,
-			.force = PROMPT
-		};
-
-		if (!wipe_lv(cmd, &wp)) {
+	else if (!wipe_lv(lv, (struct wipe_params) { .do_zero = 1 })) {
 		log_error("Aborting. Failed to wipe snapshot "
 			  "exception store.");
 		return 0;
-		}
 	}
 
 	if (!deactivate_lv(cmd, lv)) {
@@ -2506,17 +2494,8 @@ static int _lvconvert_thinpool(struct cmd_context *cmd,
 			return 0;
 		}
 
-		struct wipe_lv_params wp = {
-			.lv = metadata_lv,
-			.do_zero = 1,
-			.zero_sectors = 0,
-			.zero_value = 0,
-			.do_wipe_signatures = 0,
-			.yes = 0,
-			.force = PROMPT
-		};
 
-		if (!wipe_lv(cmd, &wp)) {
+		if (!wipe_lv(metadata_lv, (struct wipe_params) { .do_zero = 1 })) {
 			log_error("Aborting. Failed to wipe thin metadata lv.");
 			return 0;
 		}


