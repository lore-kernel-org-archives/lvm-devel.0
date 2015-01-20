From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 20 Jan 2015 14:02:53 +0000 (UTC)
Subject: master - cleanup: add lv_is_error_when_full() macro
Message-ID: <20150120140253.7F77060E94@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=07eb1c7dc897fe75e45f1284301f0673a90ad70a
Commit:        07eb1c7dc897fe75e45f1284301f0673a90ad70a
Parent:        8f90f632f565f9796603e6fef081ab9ecd0f9e49
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jan 15 15:19:00 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jan 20 14:52:06 2015 +0100

cleanup: add lv_is_error_when_full() macro

Like with other status bits use macro for testing.
(in-release update)
---
 lib/metadata/merge.c             |    2 +-
 lib/metadata/metadata-exported.h |    1 +
 lib/thin/thin.c                  |    4 ++--
 3 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/lib/metadata/merge.c b/lib/metadata/merge.c
index 6d661f8..7fd5a07 100644
--- a/lib/metadata/merge.c
+++ b/lib/metadata/merge.c
@@ -147,7 +147,7 @@ int check_lv_segments(struct logical_volume *lv, int complete_vg)
 			inc_error_count;
 		}
 
-		if ((lv->status & LV_ERROR_WHEN_FULL) &&
+		if (lv_is_error_when_full(lv) &&
 		    !seg_can_error_when_full(seg)) {
 			log_error("LV %s: segment %u (%s) does not support flag "
 				  "ERROR_WHEN_FULL.", lv->name, seg_count, seg->segtype->name);
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 94e8ebf..0ab97fa 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -195,6 +195,7 @@
 #define lv_is_mirror_type(lv)	(((lv)->status & (MIRROR | MIRROR_LOG | MIRROR_IMAGE)) ? 1 : 0)
 
 #define lv_is_pending_delete(lv) (((lv)->status & LV_PENDING_DELETE) ? 1 : 0)
+#define lv_is_error_when_full(lv) (((lv)->status & LV_ERROR_WHEN_FULL) ? 1 : 0)
 #define lv_is_pvmove(lv)	(((lv)->status & PVMOVE) ? 1 : 0)
 
 #define lv_is_raid(lv)		(((lv)->status & RAID) ? 1 : 0)
diff --git a/lib/thin/thin.c b/lib/thin/thin.c
index 377d6ad..e250603 100644
--- a/lib/thin/thin.c
+++ b/lib/thin/thin.c
@@ -316,8 +316,8 @@ static int _thin_pool_add_target_line(struct dev_manager *dm,
 				  "not support discards (needs kernel >= 3.4).");
 
 	if (attr & THIN_FEATURE_ERROR_IF_NO_SPACE)
-		dm_tree_node_set_thin_pool_error_if_no_space(node, (seg->lv->status & LV_ERROR_WHEN_FULL) ? 1 : 0);
-	else if (seg->lv->status & LV_ERROR_WHEN_FULL)
+		dm_tree_node_set_thin_pool_error_if_no_space(node, lv_is_error_when_full(seg->lv));
+	else if (lv_is_error_when_full(seg->lv))
 		log_warn_suppress(_no_error_if_no_space++, "WARNING: Thin pool target does "
 				  "not support error if no space (needs version >= 1.10).");
 


