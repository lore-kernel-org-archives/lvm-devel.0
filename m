From: Mike Snitzer <snitzer@redhat.com>
Date: Wed, 13 Oct 2010 14:53:02 -0400
Subject: [PATCH] lvconvert: provide useful error when snapshot-merge target missing
Message-ID: <20101013185302.GA2944@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Convey need for snapshot-merge target in lvconvert error message and man
page.

Add ->target_name to segtype_handler to allow a more specific target
name to be returned based on the state of the segment.

Before:
# lvconvert --merge vg/snap
  Can't expand LV lv: snapshot target support missing from kernel?
  Failed to suspend origin lv

After:
# lvconvert --merge vg/snap
  Can't process LV lv: snapshot-merge target support missing from kernel?
  Failed to suspend origin lv
  Unable to merge LV "snap" into it's origin.

Signed-off-by: Mike Snitzer <snitzer@redhat.com>
---
 lib/activate/dev_manager.c |   10 +++++++---
 lib/metadata/segtype.h     |    1 +
 lib/snapshot/snapshot.c    |    9 +++++++++
 man/lvconvert.8.in         |    6 ++++--
 tools/lvconvert.c          |    2 +-
 5 files changed, 22 insertions(+), 6 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index cee8f10..841bfc1 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -1350,19 +1350,23 @@ static int _add_segment_to_dtree(struct dev_manager *dm,
 	uint32_t s;
 	struct dm_list *snh;
 	struct lv_segment *seg_present;
+	const char *target_name;
 
 	/* Ensure required device-mapper targets are loaded */
 	seg_present = find_cow(seg->lv) ? : seg;
+	target_name = (seg_present->segtype->ops->target_name ?
+		       seg_present->segtype->ops->target_name(seg_present) :
+		       seg_present->segtype->name);
 
 	log_debug("Checking kernel supports %s segment type for %s%s%s",
-		  seg_present->segtype->name, seg->lv->name,
+		  target_name, seg->lv->name,
 		  layer ? "-" : "", layer ? : "");
 
 	if (seg_present->segtype->ops->target_present &&
 	    !seg_present->segtype->ops->target_present(seg_present->lv->vg->cmd,
 						       seg_present, NULL)) {
-		log_error("Can't expand LV %s: %s target support missing "
-			  "from kernel?", seg->lv->name, seg_present->segtype->name);
+		log_error("Can't process LV %s: %s target support missing "
+			  "from kernel?", seg->lv->name, target_name);
 		return 0;
 	}
 
diff --git a/lib/metadata/segtype.h b/lib/metadata/segtype.h
index d15df8b..c31cf32 100644
--- a/lib/metadata/segtype.h
+++ b/lib/metadata/segtype.h
@@ -66,6 +66,7 @@ struct segment_type {
 
 struct segtype_handler {
 	const char *(*name) (const struct lv_segment * seg);
+	const char *(*target_name) (const struct lv_segment * seg);
 	void (*display) (const struct lv_segment * seg);
 	int (*text_export) (const struct lv_segment * seg,
 			    struct formatter * f);
diff --git a/lib/snapshot/snapshot.c b/lib/snapshot/snapshot.c
index 92f8911..30e78d4 100644
--- a/lib/snapshot/snapshot.c
+++ b/lib/snapshot/snapshot.c
@@ -28,6 +28,14 @@ static const char *_snap_name(const struct lv_segment *seg)
 	return seg->segtype->name;
 }
 
+static const char *_snap_target_name(const struct lv_segment *seg)
+{
+	if (seg->status & MERGING)
+		return "snapshot-merge";
+
+	return _snap_name(seg);
+}
+
 static int _snap_text_import(struct lv_segment *seg, const struct config_node *sn,
 			struct dm_hash_table *pv_hash __attribute__((unused)))
 {
@@ -217,6 +225,7 @@ static void _snap_destroy(const struct segment_type *segtype)
 
 static struct segtype_handler _snapshot_ops = {
 	.name = _snap_name,
+	.target_name = _snap_target_name,
 	.text_import = _snap_text_import,
 	.text_export = _snap_text_export,
 	.target_status_compatible = _snap_target_status_compatible,
diff --git a/man/lvconvert.8.in b/man/lvconvert.8.in
index 3d4ba20..8e48793 100644
--- a/man/lvconvert.8.in
+++ b/man/lvconvert.8.in
@@ -135,8 +135,10 @@ Controls zeroing of the first KB of data in the snapshot.
 If the volume is read-only the snapshot will not be zeroed.
 .TP
 .I \-\-merge
-Merges a snapshot into its origin volume. If both the origin and snapshot volume
-are not open the merge will start immediately.  Otherwise, the merge will start
+Merges a snapshot into its origin volume.  To check if your kernel
+supports this feature, look for 'snapshot-merge' in the output
+of 'dmsetup targets'.  If both the origin and snapshot volume are not
+open the merge will start immediately.  Otherwise, the merge will start
 the first time either the origin or snapshot are activated and both are closed.
 Merging a snapshot into an origin that cannot be closed, for example a root
 filesystem, is deferred until the next time the origin volume is activated.
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index d39030b..4f02806 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1561,7 +1561,7 @@ static int _lvconvert_single(struct cmd_context *cmd, struct logical_volume *lv,
 			return ECMD_FAILED;
 		}
 		if (!lvconvert_merge(cmd, lv, lp)) {
-			stack;
+			log_error("Unable to merge LV \"%s\" into it's origin.", lv->name);
 			return ECMD_FAILED;
 		}
 	} else if (lp->snapshot) {


