From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 22 Jul 2013 10:42:16 +0000 (UTC)
Subject: master - coverity: pointer validation
Message-ID: <20130722104216.3331B60DCC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=aed4e9c703a81aec0a56dc7134ff336683ab5c1a
Commit:        aed4e9c703a81aec0a56dc7134ff336683ab5c1a
Parent:        90bdbcc2017cf9bc868aaa95616fcdb3de19b96f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jul 19 17:28:43 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 22 12:41:21 2013 +0200

coverity: pointer validation

Check for metadata_lv and make sure we have got proper thin pool segment.

Check we are working with merging snapshot when adding merging target.
---
 lib/activate/dev_manager.c |    7 ++++++-
 lib/thin/thin.c            |    5 +++++
 2 files changed, 11 insertions(+), 1 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 50e52d1..6a68653 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -1998,7 +1998,12 @@ static int _add_snapshot_merge_target_to_dtree(struct dev_manager *dm,
 					       struct logical_volume *lv)
 {
 	const char *origin_dlid, *cow_dlid, *merge_dlid;
-	struct lv_segment *merging_snap_seg = find_merging_snapshot(lv);
+	struct lv_segment *merging_snap_seg;
+
+	if (!(merging_snap_seg = find_merging_snapshot(lv))) {
+		log_error(INTERNAL_ERROR "LV %s is not merging snapshot.", lv->name);
+		return 0;
+	}
 
 	if (!(origin_dlid = build_dm_uuid(dm->mem, lv->lvid.s, "real")))
 		return_0;
diff --git a/lib/thin/thin.c b/lib/thin/thin.c
index 520a3d2..bdb9c88 100644
--- a/lib/thin/thin.c
+++ b/lib/thin/thin.c
@@ -245,6 +245,11 @@ static int _thin_pool_add_target_line(struct dev_manager *dm,
 	if (!_thin_target_present(cmd, seg, &attr))
 		return_0;
 
+	if (!seg->metadata_lv) {
+		log_error(INTERNAL_ERROR "Thin pool is missing metadata device.");
+		return 0;
+	}
+
 	if (!(attr & THIN_FEATURE_BLOCK_SIZE) &&
 	    (seg->chunk_size & (seg->chunk_size - 1))) {
 		log_error("Thin pool target does not support %uKiB chunk size "


