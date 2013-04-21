From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 21 Apr 2013 21:16:54 +0000 (UTC)
Subject: master - lv_manip: check remove_seg_from_segs_using_this_lv()
Message-ID: <20130421211654.5A8681241@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5e7eae59da2ce859e99c62b578f9164b87a1f944
Commit:        5e7eae59da2ce859e99c62b578f9164b87a1f944
Parent:        8f1dd00c3634d111be9a42524ab50b2f31962530
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Apr 21 13:18:53 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Apr 21 23:10:43 2013 +0200

lv_manip: check remove_seg_from_segs_using_this_lv()

Add missing check for result of remove_seg_from_segs_using_this_lv().
Failure is reported as internal error.
---
 lib/metadata/lv_manip.c   |    5 ++++-
 lib/metadata/mirror.c     |    3 ++-
 lib/metadata/raid_manip.c |    8 +++++---
 lib/metadata/thin_manip.c |    3 ++-
 4 files changed, 13 insertions(+), 6 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index a353932..7580464 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -246,6 +246,8 @@ int remove_seg_from_segs_using_this_lv(struct logical_volume *lv,
 		return 1;
 	}
 
+	log_error(INTERNAL_ERROR "Segment %s:%u is not a user of %s.",
+                  seg->lv->name, seg->le, lv->name);
 	return 0;
 }
 
@@ -514,7 +516,8 @@ static int _release_and_discard_lv_segment_area(struct lv_segment *seg, uint32_t
 				 seg->lv->name, seg->le, s,
 				 seg_lv(seg, s)->name, seg_le(seg, s));
 
-		remove_seg_from_segs_using_this_lv(seg_lv(seg, s), seg);
+		if (!remove_seg_from_segs_using_this_lv(seg_lv(seg, s), seg))
+			return_0;
 		seg_lv(seg, s) = NULL;
 		seg_le(seg, s) = 0;
 		seg_type(seg, s) = AREA_UNASSIGNED;
diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index fecab45..18d0d33 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -482,7 +482,8 @@ struct logical_volume *detach_mirror_log(struct lv_segment *mirrored_seg)
 	mirrored_seg->log_lv = NULL;
 	lv_set_visible(log_lv);
 	log_lv->status &= ~MIRROR_LOG;
-	remove_seg_from_segs_using_this_lv(log_lv, mirrored_seg);
+	if (!remove_seg_from_segs_using_this_lv(log_lv, mirrored_seg))
+		return_0;
 
 	return log_lv;
 }
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index f9d3861..707db1f 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -195,7 +195,8 @@ static int _raid_remove_top_layer(struct logical_volume *lv,
 	/* Add last metadata area to removal_list */
 	lvl_array[0].lv = seg_metalv(seg, 0);
 	lv_set_visible(seg_metalv(seg, 0));
-	remove_seg_from_segs_using_this_lv(seg_metalv(seg, 0), seg);
+	if (!remove_seg_from_segs_using_this_lv(seg_metalv(seg, 0), seg))
+		return_0;
 	seg_metatype(seg, 0) = AREA_UNASSIGNED;
 	dm_list_add(removal_list, &(lvl_array[0].list));
 
@@ -835,8 +836,9 @@ static int _extract_image_components(struct lv_segment *seg, uint32_t idx,
 	lv_set_visible(meta_lv);
 
 	/* release removes data and meta areas */
-	remove_seg_from_segs_using_this_lv(data_lv, seg);
-	remove_seg_from_segs_using_this_lv(meta_lv, seg);
+	if (!remove_seg_from_segs_using_this_lv(data_lv, seg) ||
+	    !remove_seg_from_segs_using_this_lv(meta_lv, seg))
+		return_0;
 
 	seg_type(seg, idx) = AREA_UNASSIGNED;
 	seg_metatype(seg, idx) = AREA_UNASSIGNED;
diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index 10c8f43..1239af9 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -474,7 +474,8 @@ int extend_pool(struct logical_volume *pool_lv, const struct segment_type *segty
 		return_0;
 
 	/* Drop reference as attach_pool_data_lv() takes it again */
-	remove_seg_from_segs_using_this_lv(data_lv, seg);
+	if (!remove_seg_from_segs_using_this_lv(data_lv, seg))
+		return_0;
 	if (!attach_pool_data_lv(seg, data_lv))
 		return_0;
 


