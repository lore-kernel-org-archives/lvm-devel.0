From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Fri, 17 Mar 2017 09:04:30 -0400
Subject: master - raid: name variables consistently
Message-ID: <201703171304.v2HD4UQG008690@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1520fec3e81147a86f98713bfc8dd27848ce74ff
Commit:        1520fec3e81147a86f98713bfc8dd27848ce74ff
Parent:        17bee733d16e88d260b7de826c747c6ade9f797c
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Fri Mar 17 14:04:03 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Fri Mar 17 14:04:03 2017 +0100

raid: name variables consistently

Related: rhbz1191935
Related: rhbz1366296
---
 lib/metadata/raid_manip.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index df48897..3b3ef19 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -1848,7 +1848,7 @@ static int _raid_reshape_remove_images(struct logical_volume *lv,
 				       const unsigned new_stripes, const unsigned new_stripe_size,
 				       struct dm_list *allocate_pvs, struct dm_list *removal_lvs)
 {
-	uint32_t active_lvs, current_le_count, reduced_le_count, removed_lvs, s;
+	uint32_t available_slvs, current_le_count, reduced_le_count, removed_slvs, s;
 	uint64_t extend_le_count;
 	unsigned devs_health, devs_in_sync;
 	struct lv_segment *seg = first_seg(lv);
@@ -1943,7 +1943,7 @@ static int _raid_reshape_remove_images(struct logical_volume *lv,
 		 * -> remove the freed up images and reduce LV size
 		 *
 		 */
-		if (!_get_available_removed_sublvs(lv, &active_lvs,  &removed_lvs))
+		if (!_get_available_removed_sublvs(lv, &available_slvs,  &removed_slvs))
 			return_0;
 
 		if (devs_in_sync != new_image_count) {
@@ -1951,7 +1951,7 @@ static int _raid_reshape_remove_images(struct logical_volume *lv,
 			return 0;
 		}
 
-		if (active_lvs + removed_lvs != old_image_count) {
+		if (available_slvs + removed_slvs != old_image_count) {
 			log_error ("No correct kernel/lvm total LV count on %s.", display_lvname(lv));
 			return 0;
 		}


