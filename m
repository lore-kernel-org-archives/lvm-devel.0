From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Thu, 3 May 2018 15:39:44 -0400
Subject: master - raid: use new internal APIs
Message-ID: <201805031939.w43JdiUX016096@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=88fe07ad0ac8f12c2a2f4873d9bd32852c2f1536
Commit:        88fe07ad0ac8f12c2a2f4873d9bd32852c2f1536
Parent:        49db9b5e0b35f6b0a47ad10276fb252c09f438ef
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Thu May 3 21:35:32 2018 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Thu May 3 21:36:50 2018 +0200

raid: use new internal APIs

Use APIs introduced with commit 4ebfd8e8eb68442efc334b35bc1f22eda3e4dd3d
where appropriate to minimize redundant code.
---
 lib/metadata/raid_manip.c |   21 +++++----------------
 1 files changed, 5 insertions(+), 16 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 1b9ebcf..703f285 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -6789,10 +6789,8 @@ static int _lv_raid_rebuild_or_replace(struct logical_volume *lv,
 			return 0;
 		}
 
-		if (lv_is_virtual(seg_lv(raid_seg, s)) ||
-		    lv_is_virtual(seg_metalv(raid_seg, s)) ||
-		    lv_is_partial(seg_lv(raid_seg, s)) ||
-		    lv_is_partial(seg_metalv(raid_seg, s)) ||
+		if (_sublv_is_degraded(seg_lv(raid_seg, s)) ||
+		    _sublv_is_degraded(seg_metalv(raid_seg, s)) ||
 		    lv_is_on_pvs(seg_lv(raid_seg, s), remove_pvs) ||
 		    lv_is_on_pvs(seg_metalv(raid_seg, s), remove_pvs)) {
 			match_count++;
@@ -7122,10 +7120,8 @@ static int _partial_raid_lv_is_redundant(const struct logical_volume *lv)
 			if (!(i % copies))
 				rebuilds_per_group = 0;
 
-			if (lv_is_partial(seg_lv(raid_seg, s)) ||
-			    lv_is_partial(seg_metalv(raid_seg, s)) ||
-			    lv_is_virtual(seg_lv(raid_seg, s)) ||
-			    lv_is_virtual(seg_metalv(raid_seg, s)))
+			if (_sublv_is_degraded(seg_lv(raid_seg, s)) ||
+			    _sublv_is_degraded(seg_metalv(raid_seg, s)))
 				rebuilds_per_group++;
 
 			if (rebuilds_per_group >= copies) {
@@ -7138,14 +7134,7 @@ static int _partial_raid_lv_is_redundant(const struct logical_volume *lv)
 		return 1; /* Redundant */
 	}
 
-	for (s = 0; s < raid_seg->area_count; s++) {
-		if (lv_is_partial(seg_lv(raid_seg, s)) ||
-		    lv_is_partial(seg_metalv(raid_seg, s)) ||
-		    lv_is_virtual(seg_lv(raid_seg, s)) ||
-		    lv_is_virtual(seg_metalv(raid_seg, s)))
-			failed_components++;
-	}
-
+	failed_components = _lv_get_nr_failed_components(lv);
 	if (failed_components == raid_seg->area_count) {
 		log_verbose("All components of raid LV %s have failed.",
 			    display_lvname(lv));


