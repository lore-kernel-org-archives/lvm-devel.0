From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue,  2 Aug 2016 22:52:10 +0000 (UTC)
Subject: master - lvconvert: Pass region_size to lv_raid_convert.
Message-ID: <20160802225210.0634E61074@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fdc3fcbfceb6282312e79200286be29ae08a5765
Commit:        fdc3fcbfceb6282312e79200286be29ae08a5765
Parent:        a234cebbed19657058cdba87a5e2c23d50ff05fe
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Aug 2 23:51:20 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Aug 2 23:51:20 2016 +0100

lvconvert: Pass region_size to lv_raid_convert.

---
 lib/metadata/metadata-exported.h |    1 +
 lib/metadata/raid_manip.c        |    8 ++++++--
 tools/lvconvert.c                |    3 ++-
 3 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index a8cbfa2..531fa03 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -1201,6 +1201,7 @@ int lv_raid_convert(struct logical_volume *lv,
 		    int yes, int force,
 		    const unsigned stripes,
 		    const unsigned new_stripe_size,
+		    const uint32_t new_region_size,
 		    struct dm_list *allocate_pvs);
 int lv_raid_replace(struct logical_volume *lv, struct dm_list *remove_pvs,
 		    struct dm_list *allocate_pvs);
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 0364f2f..9da05e5 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -2231,6 +2231,7 @@ static struct lv_segment *_convert_striped_to_raid0(struct logical_volume *lv,
 	unsigned new_image_count,		\
 	const unsigned new_stripes,		\
 	uint32_t new_stripe_size,		\
+	const uint32_t new_region_size,		\
 	struct dm_list *allocate_pvs
 
 typedef int (*takeover_fn_t)(TAKEOVER_FN_ARGS);
@@ -2737,6 +2738,7 @@ int lv_raid_convert(struct logical_volume *lv,
 		    int yes, int force,
 		    const unsigned new_stripes,
 		    const unsigned new_stripe_size,
+		    const uint32_t new_region_size,
 		    struct dm_list *allocate_pvs)
 {
 	struct lv_segment *seg = first_seg(lv);
@@ -2765,7 +2767,8 @@ int lv_raid_convert(struct logical_volume *lv,
 
 	/* Exit without doing activation checks if the combination isn't possible */
 	if (_takeover_not_possible(takeover_fn))
-		return takeover_fn(lv, new_segtype, yes, force, new_image_count, new_stripes, stripe_size, allocate_pvs);
+		return takeover_fn(lv, new_segtype, yes, force, new_image_count, new_stripes, stripe_size,
+				   new_region_size, allocate_pvs);
 
 	log_verbose("Converting %s from %s to %s.",
 		    display_lvname(lv), lvseg_name(first_seg(lv)),
@@ -2795,7 +2798,8 @@ int lv_raid_convert(struct logical_volume *lv,
 		return 0;
 	}
 
-	return takeover_fn(lv, new_segtype, yes, force, new_image_count, new_stripes, stripe_size, allocate_pvs);
+	return takeover_fn(lv, new_segtype, yes, force, new_image_count, new_stripes, stripe_size,
+			   new_region_size, allocate_pvs);
 }
 
 static int _remove_partial_multi_segment_image(struct logical_volume *lv,
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index c01eec9..d5eaee4 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1900,7 +1900,8 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 			log_error("RAID module does not support RAID0.");
 			return 0;
 		}
-		if (!lv_raid_convert(lv, lp->segtype, lp->yes, lp->force, lp->stripes, lp->stripe_size, lp->pvh))
+		if (!lv_raid_convert(lv, lp->segtype, lp->yes, lp->force, lp->stripes, lp->stripe_size,
+				     lp->region_size, lp->pvh))
 			return_0;
 		log_print_unless_silent("Logical volume %s successfully converted.",
 					display_lvname(lv));


