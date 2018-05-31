From: David Teigland <teigland@sourceware.org>
Date: Thu, 31 May 2018 10:14:20 -0400
Subject: master - lvmlockd: enable mirror split and merge with dlm lock_type
Message-ID: <201805311414.w4VEEKMT031189@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=db8d3bdfa93bb08a85953f2f3150ee27dffaa5fe
Commit:        db8d3bdfa93bb08a85953f2f3150ee27dffaa5fe
Parent:        3a4fe54ca12daf0af142e47092968cadb279d10b
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu May 24 15:02:35 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed May 30 09:25:45 2018 -0500

lvmlockd: enable mirror split and merge with dlm lock_type

---
 lib/metadata/mirror.c     |    8 ++++++++
 lib/metadata/raid_manip.c |   20 +++++++++++++++++---
 man/lvmlockd.8_main       |    5 ++++-
 tools/lvconvert.c         |    4 ++--
 4 files changed, 31 insertions(+), 6 deletions(-)

diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index 054ca99..25948ad 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -424,6 +424,11 @@ revert_new_lv:
 static int _activate_lv_like_model(struct logical_volume *model,
 				   struct logical_volume *lv)
 {
+	/* FIXME: run all cases through lv_active_change when clvm variants are gone. */
+
+	if (is_lockd_type(lv->vg->lock_type))
+		return lv_active_change(lv->vg->cmd, lv, CHANGE_AEY, 0);
+
 	if (lv_is_active_exclusive(model)) {
 		if (!activate_lv_excl(lv->vg->cmd, lv))
 			return_0;
@@ -705,6 +710,9 @@ static int _split_mirror_images(struct logical_volume *lv,
 		return 0;
 	}
 
+	if (!strcmp(lv->vg->lock_type, "dlm"))
+		new_lv->lock_args = lv->lock_args;
+
 	if (!dm_list_empty(&split_images)) {
 		/*
 		 * A number of images have been split and
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 703f285..0c631b4 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -21,6 +21,7 @@
 #include "activate.h"
 #include "lv_alloc.h"
 #include "lvm-string.h"
+#include "lvmlockd.h"
 
 typedef int (*fn_on_lv_t)(struct logical_volume *lv, void *data);
 static int _eliminate_extracted_lvs_optional_write_vg(struct volume_group *vg,
@@ -3315,7 +3316,7 @@ int lv_raid_split(struct logical_volume *lv, int yes, const char *split_name,
 	dm_list_init(&removal_lvs);
 	dm_list_init(&data_list);
 
-	if (is_lockd_type(lv->vg->lock_type)) {
+	if (lv->vg->lock_type && !strcmp(lv->vg->lock_type, "sanlock")) {
 		log_error("Splitting raid image is not allowed with lock_type %s.",
 			  lv->vg->lock_type);
 		return 0;
@@ -3394,6 +3395,9 @@ int lv_raid_split(struct logical_volume *lv, int yes, const char *split_name,
 
 	lvl->lv->name = split_name;
 
+	if (!strcmp(lv->vg->lock_type, "dlm"))
+		lvl->lv->lock_args = lv->lock_args;
+
 	if (!vg_write(lv->vg)) {
 		log_error("Failed to write changes for %s.",
 			  display_lvname(lv));
@@ -3419,7 +3423,13 @@ int lv_raid_split(struct logical_volume *lv, int yes, const char *split_name,
 	 * the original RAID LV having possibly had sub-LVs that have been
 	 * shifted and renamed.
 	 */
-	if (!activate_lv_excl_local(cmd, lvl->lv))
+
+	/* FIXME: run all cases through lv_active_change when clvm variants are gone. */
+
+	if (is_lockd_type(lvl->lv->vg->lock_type)) {
+		if (!lv_active_change(lv->vg->cmd, lvl->lv, CHANGE_AEY, 0))
+			return_0;
+	} else if (!activate_lv_excl_local(cmd, lvl->lv))
 		return_0;
 
 	dm_list_iterate_items(lvl, &removal_lvs)
@@ -3473,7 +3483,7 @@ int lv_raid_split_and_track(struct logical_volume *lv,
 	int s;
 	struct lv_segment *seg = first_seg(lv);
 
-	if (is_lockd_type(lv->vg->lock_type)) {
+	if (lv->vg->lock_type && !strcmp(lv->vg->lock_type, "sanlock")) {
 		log_error("Splitting raid image is not allowed with lock_type %s.",
 			  lv->vg->lock_type);
 		return 0;
@@ -3574,6 +3584,10 @@ int lv_raid_merge(struct logical_volume *image_lv)
 		return 0;
 	}
 
+	/* Ensure primary LV is not active elsewhere. */
+	if (!lockd_lv(vg->cmd, lvl->lv, "ex", 0))
+		return_0;
+
 	lv = lvl->lv;
 	seg = first_seg(lv);
 	for (s = 0; s < seg->area_count; ++s)
diff --git a/man/lvmlockd.8_main b/man/lvmlockd.8_main
index 6f982bd..90a07c7 100644
--- a/man/lvmlockd.8_main
+++ b/man/lvmlockd.8_main
@@ -852,7 +852,10 @@ using lvcreate to create cache pools or cache LVs (use lvconvert)
 using external origins for thin LVs
 .br
 \[bu]
-splitting mirrors and snapshots from LVs
+splitting snapshots from LVs
+.br
+\[bu]
+splitting mirrors in sanlock VGs
 .br
 \[bu]
 pvmove of entire PVs, or under LVs activated with shared locks
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 72f840a..e59a772 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -716,8 +716,8 @@ static int _lvconvert_mirrors_parse_params(struct cmd_context *cmd,
 	*old_mimage_count = lv_mirror_count(lv);
 	*old_log_count = _get_log_count(lv);
 
-	if (is_lockd_type(lv->vg->lock_type) && lp->keep_mimages) {
-		/* FIXME: we need to create a lock for the new LV. */
+	if (lv->vg->lock_type && !strcmp(lv->vg->lock_type, "sanlock") && lp->keep_mimages) {
+		/* FIXME: we need to create a sanlock lock on disk for the new LV. */
 		log_error("Unable to split mirrors in VG with lock_type %s", lv->vg->lock_type);
 		return 0;
 	}


