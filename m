From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  1 Apr 2014 18:55:56 +0000 (UTC)
Subject: master - cache: never activate cache pool
Message-ID: <20140401185556.DF604600DF@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a018c57f0bd36f1b56c67a2afe5254e6da8251b7
Commit:        a018c57f0bd36f1b56c67a2afe5254e6da8251b7
Parent:        504c328e3d2c0a8b6b946fe7d323e1f28887e285
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Apr 1 17:53:18 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 1 20:17:10 2014 +0200

cache: never activate cache pool

Since cache-pool is purely lvm abstraction layer LV, it never
need any device node, so do not add even 'error' device for it.
---
 lib/activate/dev_manager.c |   26 +++++++++++++++++++++-----
 lib/metadata/lv_manip.c    |    8 +++++++-
 tools/lvchange.c           |    5 +++++
 tools/vgchange.c           |    4 ++++
 4 files changed, 37 insertions(+), 6 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 490218c..cde39af 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -1828,6 +1828,16 @@ static int _add_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 	struct dm_tree_node *thin_node;
 	const char *uuid;
 
+	if (lv_is_cache_pool(lv)) {
+		/* origin_only is ignored */
+		/* cache pool is 'meta' LV and does not have a real device node */
+		if (!_add_lv_to_dtree(dm, dtree, seg_lv(first_seg(lv), 0), 0))
+			return_0;
+		if (!_add_lv_to_dtree(dm, dtree, first_seg(lv)->metadata_lv, 0))
+			return_0;
+		return 1;
+	}
+
 	if (!origin_only && !_add_dev_to_dtree(dm, dtree, lv, NULL))
 		return_0;
 
@@ -1917,14 +1927,11 @@ static int _add_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 		if (seg->metadata_lv &&
 		    !_add_lv_to_dtree(dm, dtree, seg->metadata_lv, 0))
 			return_0;
-		if (seg->pool_lv && !dm->skip_external_lv &&
+		if (seg->pool_lv &&
+		    (lv_is_cache_pool(seg->pool_lv) || !dm->skip_external_lv) &&
 		    !_add_lv_to_dtree(dm, dtree, seg->pool_lv, 1)) /* stack */
 			return_0;
 
-		if (seg->pool_lv && lv_is_cache_pool(seg->pool_lv) &&
-		    !_add_lv_to_dtree(dm, dtree, seg->pool_lv, 0))
-			return_0;
-
 		for (s = 0; s < seg->area_count; s++) {
 			if (seg_type(seg, s) == AREA_LV && seg_lv(seg, s) &&
 			    !_add_lv_to_dtree(dm, dtree, seg_lv(seg, s), 0))
@@ -2495,6 +2502,15 @@ static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 	uint32_t read_ahead = lv->read_ahead;
 	uint32_t read_ahead_flags = UINT32_C(0);
 
+	if (lv_is_cache_pool(lv)) {
+		/* cache pool is 'meta' LV and does not have a real device node */
+		if (!_add_new_lv_to_dtree(dm, dtree, seg_lv(first_seg(lv), 0), laopts, NULL))
+			return_0;
+		if (!_add_new_lv_to_dtree(dm, dtree, first_seg(lv)->metadata_lv, laopts, NULL))
+			return_0;
+		return 1;
+	}
+
 	/* FIXME Seek a simpler way to lay out the snapshot-merge tree. */
 
 	if (!layer && lv_is_merging_origin(lv)) {
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index bb812e2..17933a2 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4714,7 +4714,8 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 	/* FIXME Ensure not referred to by another existing LVs */
 	ask_discard = find_config_tree_bool(cmd, devices_issue_discards_CFG, NULL);
 
-	if (lv_info(cmd, lv, 0, &info, 1, 0)) {
+	if (!lv_is_cache_pool(lv) &&
+	    lv_info(cmd, lv, 0, &info, 1, 0)) {
 		if (!lv_check_not_in_use(cmd, lv, &info))
 			return_0;
 
@@ -6293,6 +6294,11 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 		goto out;
 	}
 
+	if (lv_is_cache_pool(lv)) {
+		log_verbose("Cache pool is prepared.");
+		goto out;
+	}
+
 	/* Do not scan this LV until properly zeroed/wiped. */
 	if (_should_wipe_lv(lp, lv))
 		lv->status |= LV_NOSCAN;
diff --git a/tools/lvchange.c b/tools/lvchange.c
index 8ceacc5..982e620 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -950,6 +950,11 @@ static int lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 		return EINVALID_CMD_LINE;
 	}
 
+	if (lv_is_cache_pool(lv)) {
+		log_error("Can't change cache pool logical volume.");
+		return ECMD_FAILED;
+	}
+
 	if (lv_is_origin(lv) && !lv_is_thin_volume(lv) &&
 	    (arg_count(cmd, contiguous_ARG) || arg_count(cmd, permission_ARG) ||
 	     arg_count(cmd, readahead_ARG) || arg_count(cmd, persistent_ARG) ||
diff --git a/tools/vgchange.c b/tools/vgchange.c
index e7b5e59..2856b28 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -98,6 +98,10 @@ static int _activate_lvs_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 		if (!lv_is_visible(lv))
 			continue;
 
+		/* Cache pool cannot be activated */
+		if (lv_is_cache_pool(lv))
+			continue;
+
 		/* If LV is sparse, activate origin instead */
 		if (lv_is_cow(lv) && lv_is_virtual_origin(origin_from_cow(lv)))
 			lv = origin_from_cow(lv);


