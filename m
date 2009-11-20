From: Mike Snitzer <snitzer@redhat.com>
Date: Fri, 20 Nov 2009 17:35:54 -0500
Subject: [PATCH 14/15] lvm-merge-onactivate
In-Reply-To: <1258756555-14486-1-git-send-email-snitzer@redhat.com>
References: <1258756555-14486-1-git-send-email-snitzer@redhat.com>
Message-ID: <1258756555-14486-15-git-send-email-snitzer@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Merge on activate support.

If either the origin or snapshot that is to be merged is open the merge
will not start; only the merge metadata will be written.  The merge will
start on the next activation of the origin (or via lvchange --refresh)
IFF both the origin and snapshot are closed.

Merge on activate is particularly important if we want to merge over a
mounted filesystem that cannot be unmounted (until next boot) --- for
example root.

Signed-off-by: Mike Snitzer <snitzer@redhat.com>
Cc: Mikulas Patocka <mpatocka@redhat.com>
---
 lib/activate/dev_manager.c |   18 ++++++++++++++++++
 lib/report/report.c        |   12 ++++++++++--
 tools/lvconvert.c          |   23 +++++++++++++++++++----
 3 files changed, 47 insertions(+), 6 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 7208ecd..52103e3 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -1047,12 +1047,30 @@ static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 	struct lv_segment *seg;
 	struct lv_layer *lvlayer;
 	struct dm_tree_node *dnode;
+	struct dm_info dinfo;
 	char *name, *dlid, *lv_name;
 	uint32_t max_stripe_size = UINT32_C(0);
 	uint32_t read_ahead = lv->read_ahead;
 	uint32_t read_ahead_flags = UINT32_C(0);
 	uint16_t udev_flags = 0;
 
+	if (lv_is_origin(lv) && lv->merging_snapshot && !layer) {
+		/*
+		 * Clear merge attributes if merge isn't currently possible:
+		 * either origin or merging snapshot are open
+		 * (must refresh info's open_count, so using the tree's
+		 *  existing nodes' info isn't an option)
+		 */
+		if ((dev_manager_info(dm->mem, NULL, lv,
+				      0, 1, 0, &dinfo, NULL) && dinfo.open_count) ||
+		    (dev_manager_info(dm->mem, NULL, lv->merging_snapshot->cow,
+				      0, 1, 0, &dinfo, NULL) && dinfo.open_count)) {
+			/* clear merge attributes */
+			lv->merging_snapshot->status &= ~SNAPSHOT_MERGE;
+			lv->merging_snapshot = NULL;
+		}
+	}
+
 	lv_name = lv->name;
 	if (lv_is_cow(lv) && find_cow(lv)->status & SNAPSHOT_MERGE) {
 		if (layer) {
diff --git a/lib/report/report.c b/lib/report/report.c
index b65b492..878c7e0 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -1041,8 +1041,16 @@ static int _snpercent_disp(struct dm_report *rh __attribute((unused)), struct dm
 
 	if (!lv_snapshot_percent(lv, &snap_percent, &percent_range) ||
 				 (percent_range == PERCENT_INVALID)) {
-		*sortval = UINT64_C(100);
-		dm_report_field_set_value(field, "100.00", sortval);
+		if (!lv->merging_snapshot) {
+			*sortval = UINT64_C(100);
+			dm_report_field_set_value(field, "100.00", sortval);
+		} else {
+			/* onactivate merge that hasn't started yet would
+			 * otherwise display incorrect snap% in origin
+			 */
+			*sortval = UINT64_C(0);
+			dm_report_field_set_value(field, "", sortval);
+		}
 		return 1;
 	}
 
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 7447007..b398775 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -979,6 +979,7 @@ static int lvconvert_merge(struct cmd_context *cmd,
 			   struct lvconvert_params *lp)
 {
 	int r = 0;
+	int merge_on_activate = 0;
 	struct logical_volume *origin = origin_from_cow(lv);
 	struct lv_segment *cow_seg = find_cow(lv);
 	struct lvinfo info;
@@ -994,16 +995,20 @@ static int lvconvert_merge(struct cmd_context *cmd,
 		return 0;
 	}
 
+	/*
+	 * merge on origin's next activation if either the
+	 * origin or snapshot LV are currently open
+	 */
 	if (lv_info(cmd, origin, &info, 1, 0)) {
 		if (info.open_count) {
-			log_error("Can't merge over open origin volume");
-			return 0;
+			log_print("Can't merge over open origin volume");
+			merge_on_activate = 1;
 		}
 	}
 	if (lv_info(cmd, lv, &info, 1, 0)) {
 		if (info.open_count) {
-			log_error("Can't merge when snapshot is open");
-			return 0;
+			log_print("Can't merge when snapshot is open");
+			merge_on_activate = 1;
 		}
 	}
 
@@ -1025,6 +1030,16 @@ static int lvconvert_merge(struct cmd_context *cmd,
 	if (!vg_write(lv->vg))
 		return_0;
 
+	if (merge_on_activate) {
+		/* commit vg but skip starting the merge */
+		if (!vg_commit(lv->vg))
+			return_0;
+		r = 1;
+		log_print("Merging of snapshot %s will start "
+			  "next activation.", lv->name);
+		goto out;
+	}
+
 	/* Perform merge */
 	if (!suspend_lv(cmd, origin)) {
 		log_error("Failed to suspend origin %s", origin->name);
-- 
1.6.5.2


