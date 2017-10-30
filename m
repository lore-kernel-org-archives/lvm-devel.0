From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 30 Oct 2017 09:39:50 -0400
Subject: master - lvreduce: check LV has segment
Message-ID: <201710301339.v9UDdo0O015291@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=83d5db056ba646ae69135b5f0114d1cc19b26044
Commit:        83d5db056ba646ae69135b5f0114d1cc19b26044
Parent:        04244107732feb5274bc24efed428a0d4ddae8f6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 30 14:35:31 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 30 14:39:16 2017 +0100

lvreduce: check LV has segment

Before accessing content make sure LV has segment.
This can be used in case code removes LV without segments
(i.e. on some error path)
---
 lib/metadata/lv_manip.c |   16 ++++++++++++----
 1 files changed, 12 insertions(+), 4 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 01ba564..a3634ac 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -1315,13 +1315,19 @@ static int _lv_segment_reduce(struct lv_segment *seg, uint32_t reduction)
  */
 static int _lv_reduce(struct logical_volume *lv, uint32_t extents, int delete)
 {
-	struct lv_segment *seg = first_seg(lv);;
+	struct lv_segment *seg = NULL;
 	uint32_t count = extents;
 	uint32_t reduction;
 	struct logical_volume *pool_lv;
 	struct logical_volume *external_lv = NULL;
-	int is_raid10 = seg_is_any_raid10(seg) && seg->reshape_len;
-	uint32_t data_copies = seg->data_copies;
+	int is_raid10 = 0;
+	uint32_t data_copies = 0;
+
+	if (!dm_list_empty(&lv->segments)) {
+		seg = first_seg(lv);
+		is_raid10 = seg_is_any_raid10(seg) && seg->reshape_len;
+		data_copies = seg->data_copies;
+	}
 
 	if (lv_is_merging_origin(lv)) {
 		log_debug_metadata("Dropping snapshot merge of %s to removed origin %s.",
@@ -7660,8 +7666,10 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 		       lp->mirrors,
 		       segtype_is_pool(create_segtype) ? lp->pool_metadata_extents : lp->region_size,
 		       segtype_is_thin_volume(create_segtype) ? lp->virtual_extents : lp->extents,
-		       lp->pvh, lp->alloc, lp->approx_alloc))
+		       lp->pvh, lp->alloc, lp->approx_alloc)) {
+		unlink_lv_from_vg(lv); /* Keep VG consistent and remove LV without any segment */
 		return_NULL;
+	}
 
 	/* rhbz1269533: allow for 100%FREE allocation to work with "mirror" and a disk log */
 	if (segtype_is_mirror(create_segtype) &&


