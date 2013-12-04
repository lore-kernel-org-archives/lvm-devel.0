From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed,  4 Dec 2013 13:31:52 +0000 (UTC)
Subject: master - thin: enable thin snapshot merge
Message-ID: <20131204133152.372B060FFB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=91496e0eda9969f1efcf290803c13d79456067d4
Commit:        91496e0eda9969f1efcf290803c13d79456067d4
Parent:        971ab733b74e0ffecc3f9f60af48628cd3fba1db
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 29 21:28:18 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Dec 4 14:30:26 2013 +0100

thin: enable thin snapshot merge

---
 WHATS_NEW         |    1 +
 tools/lvconvert.c |  170 ++++++++++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 168 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index c81cb7a..5d41700 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.105 -
 =====================================
+  Support lvconvert --merge for thin snapshots.
   Add support to read thin device id from table line entry.
   Drop extra test for origin when testing merging origin in lv_refresh().
   Extend lv_remove_single() to not print info about removed LV.
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 84479fe..11ee21a 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -689,6 +689,46 @@ static int _swap_lv_identifiers(struct cmd_context *cmd,
 	return 1;
 }
 
+static void _move_lv_attributes(struct logical_volume *to, struct logical_volume *from)
+{
+	/* Maybe move this code into _finish_thin_merge() */
+	to->status = from->status; // FIXME maybe some masking ?
+	to->alloc = from->alloc;
+	to->profile = from->profile;
+	to->read_ahead = from->read_ahead;
+	to->major = from->major;
+	to->minor = from->minor;
+	to->timestamp = from->timestamp;
+	to->hostname = from->hostname;
+
+	/* Move tags */
+	dm_list_init(&to->tags);
+	dm_list_splice(&to->tags, &from->tags);
+
+	/* Anything else to preserve? */
+}
+
+/* Finalise merging of lv into merge_lv */
+static int _finish_thin_merge(struct cmd_context *cmd,
+			      struct logical_volume *merge_lv,
+			      struct logical_volume *lv)
+{
+	if (!_swap_lv_identifiers(cmd, merge_lv, lv)) {
+		log_error("Failed to swap %s with merging %s.",
+			  lv->name, merge_lv->name);
+		return 0;
+	}
+
+	/* Preserve origins' attributes */
+	_move_lv_attributes(lv, merge_lv);
+
+	/* Removed LV has to be visible */
+	if (!lv_remove_single(cmd, merge_lv, DONT_PROMPT, 1))
+		return_0;
+
+	return 1;
+}
+
 static int _finish_lvconvert_merge(struct cmd_context *cmd,
 				   struct volume_group *vg,
 				   struct logical_volume *lv,
@@ -702,7 +742,14 @@ static int _finish_lvconvert_merge(struct cmd_context *cmd,
 	}
 
 	log_print_unless_silent("Merge of snapshot into logical volume %s has finished.", lv->name);
-	if (!lv_remove_single(cmd, snap_seg->cow, DONT_PROMPT, 0)) {
+
+	if (seg_is_thin_volume(snap_seg)) {
+		clear_snapshot_merge(lv);
+
+		if (!_finish_thin_merge(cmd, lv, snap_seg->lv))
+			return_0;
+
+	} else if (!lv_remove_single(cmd, snap_seg->cow, DONT_PROMPT, 0)) {
 		log_error("Could not remove snapshot %s merged into %s.",
 			  snap_seg->cow->name, lv->name);
 		return 0;
@@ -742,6 +789,31 @@ static progress_t _poll_merge_progress(struct cmd_context *cmd,
 	return PROGRESS_UNFINISHED;
 }
 
+static progress_t _poll_thin_merge_progress(struct cmd_context *cmd,
+					    struct logical_volume *lv,
+					    const char *name __attribute__((unused)),
+					    struct daemon_parms *parms)
+{
+	uint32_t device_id;
+
+	if (!lv_thin_device_id(lv, &device_id)) {
+		stack;
+		return PROGRESS_CHECK_FAILED;
+	}
+
+	/*
+	 * There is no need to poll more than once,
+	 * a thin snapshot merge is immediate.
+	 */
+
+	if (device_id != find_snapshot(lv)->device_id) {
+		log_error("LV %s is not merged.", lv->name);
+		return PROGRESS_CHECK_FAILED;
+	}
+
+	return PROGRESS_FINISHED_ALL; /* Merging happend */
+}
+
 static struct poll_functions _lvconvert_mirror_fns = {
 	.get_copy_vg = _get_lvconvert_vg,
 	.get_copy_lv = _get_lvconvert_lv,
@@ -756,6 +828,13 @@ static struct poll_functions _lvconvert_merge_fns = {
 	.finish_copy = _finish_lvconvert_merge,
 };
 
+static struct poll_functions _lvconvert_thin_merge_fns = {
+	.get_copy_vg = _get_lvconvert_vg,
+	.get_copy_lv = _get_lvconvert_lv,
+	.poll_progress = _poll_thin_merge_progress,
+	.finish_copy = _finish_lvconvert_merge,
+};
+
 int lvconvert_poll(struct cmd_context *cmd, struct logical_volume *lv,
 		   unsigned background)
 {
@@ -782,7 +861,9 @@ int lvconvert_poll(struct cmd_context *cmd, struct logical_volume *lv,
 
 	if (lv_is_merging_origin(lv))
 		return poll_daemon(cmd, lv_full_name, uuid, background, 0,
-				   &_lvconvert_merge_fns, "Merged");
+				   lv_is_thin_volume(lv) ?
+				   &_lvconvert_thin_merge_fns : &_lvconvert_merge_fns,
+				   "Merged");
 
 	return poll_daemon(cmd, lv_full_name, uuid, background, 0,
 			   &_lvconvert_mirror_fns, "Converted");
@@ -2097,6 +2178,88 @@ out:
 	return r;
 }
 
+static int _lvconvert_merge_thin_snapshot(struct cmd_context *cmd,
+					  struct logical_volume *lv,
+					  struct lvconvert_params *lp)
+{
+	int origin_is_active = 0, r = 0;
+	struct lv_segment *snap_seg = first_seg(lv);
+	struct logical_volume *origin = snap_seg->origin;
+
+	if (!origin) {
+		log_error("\"%s\" is not a mergeable logical volume.",
+			  lv->name);
+		return 0;
+	}
+
+	/* Check if merge is possible */
+	if (lv_is_merging_origin(origin)) {
+		log_error("Snapshot %s is already merging into the origin.",
+			  find_snapshot(origin)->lv->name);
+		return 0;
+	}
+
+	if (lv_is_external_origin(origin)) {
+		log_error("\"%s\" is read-only external origin \"%s\".",
+			  lv->name, origin_from_cow(lv)->name);
+		return 0;
+	}
+
+	if (lv_is_origin(origin)) {
+		log_error("Merging into the old snapshot origin %s is not supported.",
+			  origin->name);
+		return 0;
+	}
+
+	if (!archive(lv->vg))
+		return_0;
+
+	// FIXME: allow origin to be specified
+	// FIXME: verify snapshot is descendant of specified origin
+
+	/*
+	 * Prevent merge with open device(s) as it would likely lead
+	 * to application/filesystem failure.  Merge on origin's next
+	 * activation if either the origin or snapshot LV can't be
+	 * deactivated.
+	 */
+	if (!deactivate_lv(cmd, lv))
+		log_print_unless_silent("Delaying merge since snapshot is open.");
+	else if ((origin_is_active = lv_is_active(origin)) &&
+		 !deactivate_lv(cmd, origin))
+		log_print_unless_silent("Delaying merge since origin volume is open.");
+	else {
+		/*
+		 * Both thin snapshot and origin are inactive,
+		 * replace the origin LV with its snapshot LV.
+		 */
+		if (!_finish_thin_merge(cmd, origin, lv))
+			goto_out;
+
+		if (origin_is_active && !activate_lv(cmd, lv)) {
+			log_error("Failed to reactivate origin %s.", lv->name);
+			goto out;
+		}
+
+		r = 1;
+		goto out;
+	}
+
+	init_snapshot_merge(snap_seg, origin);
+
+	/* Commit vg, merge will start with next activation */
+	if (!vg_write(lv->vg) || !vg_commit(lv->vg))
+		return_0;
+
+	log_print_unless_silent("Merging of thin snapshot %s will occur on "
+				"next activation.", lv->name);
+	r = 1;
+out:
+	backup(lv->vg);
+
+	return r;
+}
+
 static int _lvconvert_thinpool_repair(struct cmd_context *cmd,
 				      struct logical_volume *pool_lv,
 				      struct lvconvert_params *lp)
@@ -2742,7 +2905,8 @@ static int _lvconvert_single(struct cmd_context *cmd, struct logical_volume *lv,
 		}
 	}
 	if (lp->merge) {
-		if (!_lvconvert_merge_old_snapshot(cmd, lv, lp)) {
+		if ((lv_is_thin_volume(lv) && !_lvconvert_merge_thin_snapshot(cmd, lv, lp)) ||
+		    (!lv_is_thin_volume(lv) && !_lvconvert_merge_old_snapshot(cmd, lv, lp))) {
 			log_print_unless_silent("Unable to merge LV \"%s\" into its origin.", lv->name);
 			return ECMD_FAILED;
 		}


