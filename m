From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri, 20 Jun 2014 10:41:53 +0000 (UTC)
Subject: master - pvvmove: add a few comments
Message-ID: <20140620104153.12AF661070@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f29ae59a4d88ff0f76cfd84a6061222ae178438b
Commit:        f29ae59a4d88ff0f76cfd84a6061222ae178438b
Parent:        f96a499c8d4ad784ccd7a15061e71b16342de104
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Jun 20 11:41:20 2014 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Jun 20 11:41:20 2014 +0100

pvvmove: add a few comments

---
 lib/metadata/lv_manip.c |    8 +++++---
 lib/metadata/merge.c    |    5 +++++
 2 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 44f94f4..069e5a6 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -2737,8 +2737,9 @@ int lv_add_segmented_mirror_image(struct alloc_handle *ah,
 	}
 
 	/*
-	 * Perform any necessary segment splitting before creating
-	 * the mirror layer.
+	 * If the allocator provided two or more PV allocations for any
+	 * single segment of the original LV, that LV segment must be
+	 * split up to match.
 	 */
 	dm_list_iterate_items(aa, &ah->alloced_areas[0]) {
 		if (!(seg = find_seg_by_le(lv, current_le))) {
@@ -2757,6 +2758,7 @@ int lv_add_segmented_mirror_image(struct alloc_handle *ah,
 		}
 		current_le += seg->area_len;
 	}
+
 	current_le = le;
 
 	if (!insert_layer_for_lv(lv->vg->cmd, lv, PVMOVE, "_mimage_0")) {
@@ -5222,7 +5224,7 @@ int remove_layers_for_segments(struct cmd_context *cmd,
 					  layer_lv->name, lseg->le);
 				return 0;
 			}
-			if (((lseg->status & status_mask) != status_mask)) {
+			if ((lseg->status & status_mask) != status_mask) {
 				log_error("Layer status does not match: "
 					  "%s:%" PRIu32 " status: 0x%" PRIx64 "/0x%" PRIx64,
 					  layer_lv->name, lseg->le,
diff --git a/lib/metadata/merge.c b/lib/metadata/merge.c
index 142d4d8..5aa7d00 100644
--- a/lib/metadata/merge.c
+++ b/lib/metadata/merge.c
@@ -40,6 +40,11 @@ int lv_merge_segments(struct logical_volume *lv)
 	struct dm_list *segh, *t;
 	struct lv_segment *seg, *current, *prev = NULL;
 
+	/*
+	 * Don't interfere with pvmoves as they rely upon two LVs
+	 * having a matching segment structure.
+	 */
+
 	if (lv->status & LOCKED || lv->status & PVMOVE)
 		return 1;
 


