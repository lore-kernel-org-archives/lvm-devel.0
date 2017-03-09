From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Wed, 8 Mar 2017 21:59:25 -0500
Subject: master - lvconvert: prompt when splitting off a tracked LV of a 2-legged raid1 LV
Message-ID: <201703090259.v292xPkI031423@int-mx13.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d250aa7208a6211d54cb2264b767fc3d2063eff8
Commit:        d250aa7208a6211d54cb2264b767fc3d2063eff8
Parent:        7fbe6ef16bfb95ffe7c02e29872ccd2d86445acf
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Thu Mar 9 03:22:55 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Thu Mar 9 03:22:55 2017 +0100

lvconvert: prompt when splitting off a tracked LV of a 2-legged raid1 LV

Splitting off an image LV of a 2-legged raid1 LV tracking changes
causes loosing partial resilience for any newly written data set.
Full resilience will be provided again after the split off image LV
got merged back in and the new data set got fully synchronized.
Reason being that the data is only stored on the remaining single
writable image during the split.

Ask user to avoid uninformed loss of such partial resilience.

Don't ask for N > 2 legged raid1 LVs.
---
 lib/metadata/metadata-exported.h |    1 +
 lib/metadata/raid_manip.c        |   13 +++++++++++++
 tools/lvconvert.c                |    2 +-
 3 files changed, 15 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 28e1f52..1b06354 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -1219,6 +1219,7 @@ int lv_raid_change_image_count(struct logical_volume *lv,
 int lv_raid_split(struct logical_volume *lv, const char *split_name,
 		  uint32_t new_count, struct dm_list *splittable_pvs);
 int lv_raid_split_and_track(struct logical_volume *lv,
+			    int yes,
 			    struct dm_list *splittable_pvs);
 int lv_raid_merge(struct logical_volume *lv);
 int lv_raid_convert(struct logical_volume *lv,
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index c1788c3..9f1ea8d 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -3228,6 +3228,7 @@ int lv_raid_split(struct logical_volume *lv, const char *split_name,
  * Returns: 1 on success, 0 on error
  */
 int lv_raid_split_and_track(struct logical_volume *lv,
+			    int yes,
 			    struct dm_list *splittable_pvs)
 {
 	int s;
@@ -3250,6 +3251,14 @@ int lv_raid_split_and_track(struct logical_volume *lv,
 		return 0;
 	}
 
+	/* Split and track changes on a 2-legged raid1 LV causes loosing resilience for newly written data. */
+	if (seg->area_count == 2 &&
+	    !yes && yes_no_prompt("Are you sure you want to split and track %s LV %s loosing resilience for any newly written data? [y/n]: ",
+				  lvseg_name(seg), display_lvname(lv)) == 'n') {
+		log_error("Logical volume %s NOT split.", display_lvname(lv));
+		return 0;
+	}
+
 	for (s = seg->area_count - 1; s >= 0; --s) {
 		if (!lv_is_on_pvs(seg_lv(seg, s), splittable_pvs))
 			continue;
@@ -3275,6 +3284,10 @@ int lv_raid_split_and_track(struct logical_volume *lv,
 	if (!activate_lv_excl_local(lv->vg->cmd, seg_lv(seg, s)))
 		return_0;
 
+	if (seg->area_count == 2)
+		log_warn("Any newly written data will be non-resilient on LV %s during the split!",
+			 display_lvname(lv));
+
 	log_print_unless_silent("Use 'lvconvert --merge %s' to merge back into %s.",
 				display_lvname(seg_lv(seg, s)),
 				display_lvname(lv));
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 3110522..4827d6e 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1346,7 +1346,7 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 	}
 
 	if (lp->track_changes)
-		return lv_raid_split_and_track(lv, lp->pvh);
+		return lv_raid_split_and_track(lv, lp->yes, lp->pvh);
 
 	if (lp->keep_mimages)
 		return lv_raid_split(lv, lp->lv_split_name, image_count, lp->pvh);


