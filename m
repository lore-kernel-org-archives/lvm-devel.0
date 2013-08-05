From: Jonathan Brassow <jbrassow@redhat.com>
Date: Mon,  5 Aug 2013 15:03:13 -0500
Subject: [PATCH 2/6] RAID: Support moving RAID sub-LVs with pvmove
In-Reply-To: <1375732997-23644-1-git-send-email-jbrassow@redhat.com>
References: <1375732997-23644-1-git-send-email-jbrassow@redhat.com>
Message-ID: <1375732997-23644-3-git-send-email-jbrassow@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch allows pvmove to operate on RAID logical volumes.
The key component is the ability to avoid moving a RAID
sub-LV onto a PV that already has another RAID sub-LV on it.
(e.g. Avoid placing both images of a RAID1 LV on the same PV.)

Top-level LVs are processed to determine which PVs to avoid for
the sake of redundancy, while bottom-level LVs are processed
to determine which segments/extents to move.
---
 tools/pvmove.c |  111 +++++++++++++++++++++++++++++++++++++++++++++++++-------
 1 files changed, 98 insertions(+), 13 deletions(-)

diff --git a/tools/pvmove.c b/tools/pvmove.c
index cb5c9ec..64db144 100644
--- a/tools/pvmove.c
+++ b/tools/pvmove.c
@@ -16,6 +16,7 @@
 #include "tools.h"
 #include "polldaemon.h"
 #include "display.h"
+#include "metadata-exported.h" /* for 'get_only_segment_using_this_lv' */
 
 #define PVMOVE_FIRST_TIME   0x00000001      /* Called for first time */
 #define PVMOVE_EXCLUSIVE    0x00000002      /* Require exclusive LV */
@@ -135,6 +136,47 @@ static struct dm_list *_get_allocatable_pvs(struct cmd_context *cmd, int argc,
 }
 
 /*
+ * _trim_allocatable_pvs
+ * @alloc_list
+ * @trim_list
+ *
+ * Remove PVs in 'trim_list' from 'alloc_list'.
+ *
+ * Returns: 1 on success, 0 on error
+ */
+static int _trim_allocatable_pvs(struct dm_list *alloc_list,
+				 struct dm_list *trim_list,
+				 alloc_policy_t alloc)
+{
+	struct dm_list *pvht, *pvh, *trim_pvh;
+	struct pv_list *pvl, *trim_pvl;
+
+	if (!alloc_list) {
+		log_error(INTERNAL_ERROR "alloc_list is NULL");
+		return 0;
+	}
+
+	if (!trim_list || dm_list_empty(trim_list))
+		return 1; /* alloc_list stays the same */
+
+	dm_list_iterate_safe(pvh, pvht, alloc_list) {
+		pvl = dm_list_item(pvh, struct pv_list);
+
+		dm_list_iterate(trim_pvh, trim_list) {
+			trim_pvl = dm_list_item(trim_pvh, struct pv_list);
+
+			/* Don't allocate onto a trim PV */
+			if ((alloc != ALLOC_ANYWHERE) &&
+			    (pvl->pv == trim_pvl->pv)) {
+				dm_list_del(&pvl->list);
+				break;  /* goto next in alloc_list */
+			}
+		}
+	}
+	return 1;
+}
+
+/*
  * Replace any LV segments on given PV with temporary mirror.
  * Returns list of LVs changed.
  */
@@ -181,6 +223,8 @@ static struct logical_volume *_set_up_pvmove_lv(struct cmd_context *cmd,
 	struct logical_volume *lv_mirr, *lv;
 	struct lv_segment *seg;
 	struct lv_list *lvl;
+	struct pv_list *pvl, *tmp_pvl;
+	struct dm_list trim_list;
 	uint32_t log_count = 0;
 	int lv_found = 0;
 	int lv_skipped = 0;
@@ -204,7 +248,48 @@ static struct logical_volume *_set_up_pvmove_lv(struct cmd_context *cmd,
 
 	dm_list_init(*lvs_changed);
 
-	/* Find segments to be moved and set up mirrors */
+	/*
+	 * First,
+	 * use top-level LVs (like RAID, mirror, or thin)
+	 * to build a list of PVs that must be avoided due to
+	 * the need to maintain redundancy (e.g. no two RAID images
+	 * should be placed on the same device - unless ALLOC_ANYWHERE).
+	 */
+	dm_list_iterate_items(lvl, &vg->lvs) {
+		lv = lvl->lv;
+		if (lv == lv_mirr)
+			continue;
+
+		if (lv_name && strcmp(lv->name, lv_name))
+			continue;
+
+		if (!lv_is_on_pvs(lv, source_pvl))
+			continue;
+
+		dm_list_init(&trim_list);
+
+		if (seg_is_raid(first_seg(lv))) {
+			if (!get_pv_list_for_lv(lv->vg->cmd->mem,
+						lv, &trim_list))
+				return_NULL;
+
+			if (!_trim_allocatable_pvs(allocatable_pvs,
+						   &trim_list, alloc))
+				return_NULL;
+
+			/* Free list obtained from 'get_pv_list_for_lv' */
+			dm_list_iterate_items_safe(pvl, tmp_pvl, &trim_list) {
+				dm_list_del(&pvl->list);
+				dm_pool_free(lv->vg->cmd->mem, pvl);
+			}
+		}
+	}
+
+	/*
+	 * Second,
+	 * use bottom-level LVs (like *_mimage_*, *_mlog, *_rmeta_*, etc)
+	 * to find segments to be moved and then set up mirrors.
+	 */
 	dm_list_iterate_items(lvl, &vg->lvs) {
 		lv = lvl->lv;
 		if (lv == lv_mirr)
@@ -214,23 +299,23 @@ static struct logical_volume *_set_up_pvmove_lv(struct cmd_context *cmd,
 				continue;
 			lv_found = 1;
 		}
+
+		if (!lv_is_on_pvs(lv, source_pvl))
+			continue;
+
 		if (lv_is_origin(lv) || lv_is_cow(lv)) {
 			lv_skipped = 1;
 			log_print_unless_silent("Skipping snapshot-related LV %s", lv->name);
 			continue;
 		}
-		if (lv_is_raid_type(lv)) {
-			seg = first_seg(lv);
-			if (seg_is_raid(seg)) {
-				lv_skipped = 1;
-				log_print_unless_silent("Skipping %s LV %s",
-							seg->segtype->ops->name(seg),
-							lv->name);
-				continue;
-			}
-			lv_skipped = 1;
-			log_print_unless_silent("Skipping RAID sub-LV %s",
-						lv->name);
+		seg = first_seg(lv);
+		if (seg_is_raid(seg)) {
+			/*
+			 * Pass over top-level LVs - they were handled.
+			 * Allow sub-LVs to proceed.
+			 */
+			log_debug("Ignoring top-level %s LV, %s",
+				  seg->segtype->ops->name(seg), lv->name);
 			continue;
 		}
 		if (lv->status & MIRRORED) {
-- 
1.7.7.6


