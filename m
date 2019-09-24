From: David Teigland <teigland@sourceware.org>
Date: Tue, 24 Sep 2019 16:56:07 -0400
Subject: master - writecache: move code into new file
Message-ID: <201909242056.x8OKu7JW015860@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=76dd9b2b518e85a4fecbc752424a8a0f36616838
Commit:        76dd9b2b518e85a4fecbc752424a8a0f36616838
Parent:        56aadd7fe2a1d24043ea9d06543c29317ac1cc58
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Sep 24 15:28:02 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Sep 24 15:51:05 2019 -0500

writecache: move code into new file

put writecache specific code in writecache_manip.c

should be no functional change
---
 lib/Makefile.in                  |    1 +
 lib/metadata/metadata-exported.h |    1 +
 lib/metadata/metadata.c          |   27 -----
 lib/metadata/writecache_manip.c  |  201 ++++++++++++++++++++++++++++++++++++++
 tools/lvconvert.c                |  142 +--------------------------
 5 files changed, 208 insertions(+), 164 deletions(-)

diff --git a/lib/Makefile.in b/lib/Makefile.in
index 654c322..c037b41 100644
--- a/lib/Makefile.in
+++ b/lib/Makefile.in
@@ -66,6 +66,7 @@ SOURCES =\
 	locking/locking.c \
 	log/log.c \
 	metadata/cache_manip.c \
+	metadata/writecache_manip.c \
 	metadata/lv.c \
 	metadata/lv_manip.c \
 	metadata/merge.c \
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 7c9aebb..ea8635e 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -1282,6 +1282,7 @@ struct logical_volume *lv_cache_create(struct logical_volume *pool_lv,
 int lv_cache_wait_for_clean(struct logical_volume *cache_lv, int *is_clean);
 int lv_cache_remove(struct logical_volume *cache_lv);
 int lv_detach_cache_vol(struct logical_volume *cache_lv, int noflush);
+int lv_detach_writecache_cachevol(struct logical_volume *cache_lv, int noflush);
 int wipe_cache_pool(struct logical_volume *cache_pool_lv);
 /* --  metadata/cache_manip.c */
 
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 644cd59..b434967 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -5166,30 +5166,3 @@ struct volume_group *vg_read_for_update(struct cmd_context *cmd, const char *vg_
 
 	return vg;
 }
-
-int lv_is_writecache_origin(const struct logical_volume *lv)
-{
-	struct seg_list *sl;
-
-	dm_list_iterate_items(sl, &lv->segs_using_this_lv) {
-		if (!sl->seg || !sl->seg->lv || !sl->seg->origin)
-			continue;
-		if (lv_is_writecache(sl->seg->lv) && (sl->seg->origin == lv))
-			return 1;
-	}
-	return 0;
-}
-
-int lv_is_writecache_cachevol(const struct logical_volume *lv)
-{
-	struct seg_list *sl;
-
-	dm_list_iterate_items(sl, &lv->segs_using_this_lv) {
-		if (!sl->seg || !sl->seg->lv || !sl->seg->writecache)
-			continue;
-		if (lv_is_writecache(sl->seg->lv) && (sl->seg->writecache == lv))
-			return 1;
-	}
-	return 0;
-}
-
diff --git a/lib/metadata/writecache_manip.c b/lib/metadata/writecache_manip.c
new file mode 100644
index 0000000..73fbd2e
--- /dev/null
+++ b/lib/metadata/writecache_manip.c
@@ -0,0 +1,201 @@
+/*
+ * Copyright (C) 2014-2015 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+ */
+
+#include "lib/misc/lib.h"
+#include "lib/metadata/metadata.h"
+#include "lib/locking/locking.h"
+#include "lib/misc/lvm-string.h"
+#include "lib/commands/toolcontext.h"
+#include "lib/display/display.h"
+#include "lib/metadata/segtype.h"
+#include "lib/activate/activate.h"
+#include "lib/config/defaults.h"
+#include "lib/metadata/lv_alloc.h"
+#include "lib/misc/lvm-signal.h"
+#include "lib/activate/dev_manager.h"
+
+int lv_is_writecache_origin(const struct logical_volume *lv)
+{
+	struct seg_list *sl;
+
+	dm_list_iterate_items(sl, &lv->segs_using_this_lv) {
+		if (!sl->seg || !sl->seg->lv || !sl->seg->origin)
+			continue;
+		if (lv_is_writecache(sl->seg->lv) && (sl->seg->origin == lv))
+			return 1;
+	}
+	return 0;
+}
+
+int lv_is_writecache_cachevol(const struct logical_volume *lv)
+{
+	struct seg_list *sl;
+
+	dm_list_iterate_items(sl, &lv->segs_using_this_lv) {
+		if (!sl->seg || !sl->seg->lv || !sl->seg->writecache)
+			continue;
+		if (lv_is_writecache(sl->seg->lv) && (sl->seg->writecache == lv))
+			return 1;
+	}
+	return 0;
+}
+
+static int _lv_writecache_detach(struct cmd_context *cmd, struct logical_volume *lv,
+				 struct logical_volume *lv_fast)
+{
+	struct lv_segment *seg = first_seg(lv);
+	struct logical_volume *origin;
+
+	if (!seg_is_writecache(seg)) {
+		log_error("LV %s segment is not writecache.", display_lvname(lv));
+		return 0;
+	}
+
+	if (!seg->writecache) {
+		log_error("LV %s writecache segment has no writecache.", display_lvname(lv));
+		return 0;
+	}
+
+	if (!(origin = seg_lv(seg, 0))) {
+		log_error("LV %s writecache segment has no origin", display_lvname(lv));
+		return 0;
+	}
+
+	if (!remove_seg_from_segs_using_this_lv(seg->writecache, seg))
+		return_0;
+
+	lv_set_visible(seg->writecache);
+
+	lv->status &= ~WRITECACHE;
+	seg->writecache = NULL;
+
+	lv_fast->status &= ~LV_CACHE_VOL;
+
+	if (!remove_layer_from_lv(lv, origin))
+		return_0;
+
+	if (!lv_remove(origin))
+		return_0;
+
+	return 1;
+}
+
+static int _get_writecache_kernel_error(struct cmd_context *cmd,
+					struct logical_volume *lv,
+					uint32_t *kernel_error)
+{
+	struct lv_with_info_and_seg_status status;
+
+	memset(&status, 0, sizeof(status));
+	status.seg_status.type = SEG_STATUS_NONE;
+
+	status.seg_status.seg = first_seg(lv);
+
+	/* FIXME: why reporter_pool? */
+	if (!(status.seg_status.mem = dm_pool_create("reporter_pool", 1024))) {
+		log_error("Failed to get mem for LV status.");
+		return 0;
+	}
+
+	if (!lv_info_with_seg_status(cmd, first_seg(lv), &status, 1, 1)) {
+		log_error("Failed to get device mapper status for %s", display_lvname(lv));
+		goto fail;
+	}
+
+	if (!status.info.exists) {
+		log_error("No device mapper info exists for %s", display_lvname(lv));
+		goto fail;
+	}
+
+	if (status.seg_status.type != SEG_STATUS_WRITECACHE) {
+		log_error("Invalid device mapper status type (%d) for %s",
+			  (uint32_t)status.seg_status.type, display_lvname(lv));
+		goto fail;
+	}
+
+	*kernel_error = status.seg_status.writecache->error;
+
+	dm_pool_destroy(status.seg_status.mem);
+	return 1;
+
+fail:
+	dm_pool_destroy(status.seg_status.mem);
+	return 0;
+}
+
+int lv_detach_writecache_cachevol(struct logical_volume *lv, int noflush)
+{
+	struct cmd_context *cmd = lv->vg->cmd;
+	struct logical_volume *lv_fast;
+	uint32_t kernel_error = 0;
+
+	lv_fast = first_seg(lv)->writecache;
+
+	if (noflush)
+		goto detach;
+
+	/*
+	 * Activate LV internally since the LV needs to be active to flush.
+	 * LV_TEMPORARY should keep the LV from being exposed to the user
+	 * and being accessed.
+	 */
+
+	lv->status |= LV_TEMPORARY;
+
+	if (!activate_lv(cmd, lv)) {
+		log_error("Failed to activate LV %s for flushing writecache.", display_lvname(lv));
+		return 0;
+	}
+
+	if (!sync_local_dev_names(cmd)) {
+		log_error("Failed to sync local devices before detaching writecache.");
+		return 0;
+	}
+
+	if (!lv_writecache_message(lv, "flush")) {
+		log_error("Failed to flush writecache for %s.", display_lvname(lv));
+		if (!deactivate_lv(cmd, lv))
+			log_error("Failed to deactivate %s.", display_lvname(lv));
+		return 0;
+	}
+
+	if (!_get_writecache_kernel_error(cmd, lv, &kernel_error)) {
+		log_error("Failed to get writecache error status for %s.", display_lvname(lv));
+		if (!deactivate_lv(cmd, lv))
+			log_error("Failed to deactivate %s.", display_lvname(lv));
+		return 0;
+	}
+
+	if (kernel_error) {
+		log_error("Failed to flush writecache (error %u) for %s.", kernel_error, display_lvname(lv));
+		deactivate_lv(cmd, lv);
+		return 0;
+	}
+
+	if (!deactivate_lv(cmd, lv)) {
+		log_error("Failed to deactivate LV %s for detaching writecache.", display_lvname(lv));
+		return 0;
+	}
+
+	lv->status &= ~LV_TEMPORARY;
+
+ detach:
+	if (!_lv_writecache_detach(cmd, lv, lv_fast)) {
+		log_error("Failed to detach writecache from %s", display_lvname(lv));
+		return 0;
+	}
+
+	return 1;
+}
+
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index e4f605e..07b5d6a 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -5237,94 +5237,11 @@ int lvconvert_to_vdopool_param_cmd(struct cmd_context *cmd, int argc, char **arg
 			       NULL, NULL, &_lvconvert_to_vdopool_single);
 }
 
-static int _lv_writecache_detach(struct cmd_context *cmd, struct logical_volume *lv,
-				 struct logical_volume *lv_fast)
-{
-	struct lv_segment *seg = first_seg(lv);
-	struct logical_volume *origin;
-
-	if (!seg_is_writecache(seg)) {
-		log_error("LV %s segment is not writecache.", display_lvname(lv));
-		return 0;
-	}
-
-	if (!seg->writecache) {
-		log_error("LV %s writecache segment has no writecache.", display_lvname(lv));
-		return 0;
-	}
-
-	if (!(origin = seg_lv(seg, 0))) {
-		log_error("LV %s writecache segment has no origin", display_lvname(lv));
-		return 0;
-	}
-
-	if (!remove_seg_from_segs_using_this_lv(seg->writecache, seg))
-		return_0;
-
-	lv_set_visible(seg->writecache);
-
-	lv->status &= ~WRITECACHE;
-	seg->writecache = NULL;
-
-	lv_fast->status &= ~LV_CACHE_VOL;
-
-	if (!remove_layer_from_lv(lv, origin))
-		return_0;
-
-	if (!lv_remove(origin))
-		return_0;
-
-	return 1;
-}
-
-static int _get_writecache_kernel_error(struct cmd_context *cmd,
-					struct logical_volume *lv,
-					uint32_t *kernel_error)
-{
-	struct lv_with_info_and_seg_status status;
-
-	memset(&status, 0, sizeof(status));
-	status.seg_status.type = SEG_STATUS_NONE;
-
-	status.seg_status.seg = first_seg(lv);
-
-	/* FIXME: why reporter_pool? */
-	if (!(status.seg_status.mem = dm_pool_create("reporter_pool", 1024))) {
-		log_error("Failed to get mem for LV status.");
-		return 0;
-	}
-
-	if (!lv_info_with_seg_status(cmd, first_seg(lv), &status, 1, 1)) {
-		log_error("Failed to get device mapper status for %s", display_lvname(lv));
-		goto fail;
-	}
-
-	if (!status.info.exists) {
-		log_error("No device mapper info exists for %s", display_lvname(lv));
-		goto fail;
-	}
-
-	if (status.seg_status.type != SEG_STATUS_WRITECACHE) {
-		log_error("Invalid device mapper status type (%d) for %s",
-			  (uint32_t)status.seg_status.type, display_lvname(lv));
-		goto fail;
-	}
-
-	*kernel_error = status.seg_status.writecache->error;
-
-	dm_pool_destroy(status.seg_status.mem);
-	return 1;
-
-fail:
-	dm_pool_destroy(status.seg_status.mem);
-	return 0;
-}
-
 static int _lvconvert_detach_writecache(struct cmd_context *cmd,
 					struct logical_volume *lv,
 					struct logical_volume *lv_fast)
 {
-	uint32_t kernel_error = 0;
+	int noflush = 0;
 
 	/*
 	 * LV must be inactive externally before detaching cache.
@@ -5354,61 +5271,12 @@ static int _lvconvert_detach_writecache(struct cmd_context *cmd,
 			log_error("Conversion aborted.");
 			return 0;
 		}
-
-		goto detach;
-	}
-
-	/*
-	 * Activate LV internally since the LV needs to be active to flush.
-	 * LV_TEMPORARY should keep the LV from being exposed to the user
-	 * and being accessed.
-	 */
-
-	lv->status |= LV_TEMPORARY;
-
-	if (!activate_lv(cmd, lv)) {
-		log_error("Failed to activate LV %s for flushing.", display_lvname(lv));
-		return 0;
-	}
-
-	if (!sync_local_dev_names(cmd)) {
-		log_error("Failed to sync local devices before detaching LV %s.",
-			  display_lvname(lv));
-		return 0;
-	}
-
-	if (!lv_writecache_message(lv, "flush")) {
-		log_error("Failed to flush writecache for %s.", display_lvname(lv));
-		if (!deactivate_lv(cmd, lv))
-			log_error("Failed to deactivate %s.", display_lvname(lv));
-		return 0;
-	}
-
-	if (!_get_writecache_kernel_error(cmd, lv, &kernel_error)) {
-		log_error("Failed to get writecache error status for %s.", display_lvname(lv));
-		if (!deactivate_lv(cmd, lv))
-			log_error("Failed to deactivate %s.", display_lvname(lv));
-		return 0;
-	}
-
-	if (kernel_error) {
-		log_error("Failed to flush writecache (error %u) for %s.", kernel_error, display_lvname(lv));
-		deactivate_lv(cmd, lv);
-		return 0;
-	}
-
-	if (!deactivate_lv(cmd, lv)) {
-		log_error("Failed to deactivate LV %s for detaching writecache.", display_lvname(lv));
-		return 0;
+		
+		noflush = 1;
 	}
 
-	lv->status &= ~LV_TEMPORARY;
-
- detach:
-	if (!_lv_writecache_detach(cmd, lv, lv_fast)) {
-		log_error("Failed to detach writecache from %s", display_lvname(lv));
-		return 0;
-	}
+	if (!lv_detach_writecache_cachevol(lv, noflush))
+		return_0;
 
 	if (!vg_write(lv->vg) || !vg_commit(lv->vg))
 		return_0;


