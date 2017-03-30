From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Thu, 30 Mar 2017 12:43:40 -0400
Subject: master - raid: more coverity issues
Message-ID: <201703301643.v2UGhehm016369@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=980e4f673eb9189f9fe2dd5844a56f107d078f40
Commit:        980e4f673eb9189f9fe2dd5844a56f107d078f40
Parent:        c34ab29ec6c3e737b65a1b589ef4091944a5127d
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Thu Mar 30 18:39:04 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Thu Mar 30 18:39:04 2017 +0200

raid: more coverity issues

---
 lib/metadata/raid_manip.c |   14 ++++++++------
 1 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 8e5b1a8..63a2a6c 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -751,6 +751,11 @@ static int _reorder_raid10_near_seg_areas(struct lv_segment *seg, enum raid0_rai
 	uint32_t *idx, stripes = seg->area_count;
 	unsigned i = 0;
 
+	if (!stripes) {
+		log_error(INTERNAL_ERROR "stripes may not be 0.");
+		return 0;
+	}
+
 	/* Internal sanity checks... */
 	if (!(conv == reorder_to_raid10_near || conv == reorder_from_raid10_near))
 		return_0;
@@ -2082,7 +2087,7 @@ static int _activate_sub_lvs_excl_local(struct logical_volume *lv, uint32_t star
 			   display_lvname(lv));
 	for (s = start_idx; s < seg->area_count; s++)
 		if (!_activate_sub_lv_excl_local(seg_lv(seg, s)) ||
-		    !_activate_sub_lv_excl_local(seg_metalv(seg, s)))
+		    (seg->meta_areas && !_activate_sub_lv_excl_local(seg_metalv(seg, s))))
 			return 0;
 
 	return 1;
@@ -4598,7 +4603,7 @@ static int _clear_meta_lvs(struct logical_volume *lv)
 	struct lv_segment_area *tmp_areas;
 	const struct segment_type *tmp_segtype;
 	struct dm_list meta_lvs;
-	struct lv_list *lvl_array, *lvl;
+	struct lv_list *lvl;
 	int is_raid45n10 = seg_is_raid4(seg) || seg_is_raid5_n(seg) || seg_is_raid10(seg);
 
 	/* Reject non-raid0_meta/raid4/raid5_n segment types cautiously */
@@ -4606,9 +4611,6 @@ static int _clear_meta_lvs(struct logical_volume *lv)
 	    (!seg_is_raid0_meta(seg) && !is_raid45n10))
 		return_0;
 
-	if (!(lvl_array = dm_pool_alloc(lv->vg->vgmem, seg->area_count * sizeof(*lvl_array))))
-		return_0;
-
 	dm_list_init(&meta_lvs);
 	tmp_segtype = seg->segtype;
 	tmp_areas = seg->meta_areas;
@@ -5894,7 +5896,7 @@ int lv_raid_convert(struct logical_volume *lv,
 	struct lv_segment *seg = first_seg(lv);
 	uint32_t stripes = new_stripes, stripe_size;
 	uint32_t new_image_count = seg->area_count;
-	uint32_t region_size = new_region_size;
+	uint32_t region_size;
 	uint32_t data_copies = seg->data_copies;
 	uint32_t available_slvs, removed_slvs;
 	takeover_fn_t takeover_fn;


