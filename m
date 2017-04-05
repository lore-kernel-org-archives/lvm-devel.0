From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Wed, 5 Apr 2017 18:59:56 -0400
Subject: master - raid: reload on removing images
Message-ID: <201704052259.v35Mxuij007287@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e350b83d508aca11969ad5429d1095fb2e066432
Commit:        e350b83d508aca11969ad5429d1095fb2e066432
Parent:        a8d5ada452570e1c9b0c6e0ae0a311870056896a
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Thu Apr 6 00:47:34 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Thu Apr 6 00:47:34 2017 +0200

raid: reload on removing images

Requesting _raid_remove_images() to commit the
metadata missed to reload the origin causing a
kernel takeover error converting a 2-legged raid1
(with previously removed images) to raid5.
---
 lib/metadata/raid_manip.c |   13 ++++++-------
 1 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 07bb131..05cbb74 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -1592,7 +1592,6 @@ static int _lv_free_reshape_space_with_status(struct logical_volume *lv, enum al
 		 */
 		if (!_lv_alloc_reshape_space(lv, alloc_end, &where, NULL))
 			return_0;
-
 		seg->extents_copied = first_seg(lv)->area_len;
 		if (!lv_reduce(lv, total_reshape_len))
 			return_0;
@@ -2918,6 +2917,8 @@ static int _raid_remove_images(struct logical_volume *lv, int yes,
 		return 0;
 	}
 
+	first_seg(lv)->area_count = new_count;
+
 	/* Convert to linear? */
 	if (new_count == 1) {
 		if (!yes && yes_no_prompt("Are you sure you want to convert %s LV %s to type %s loosing all resilience? [y/n]: ",
@@ -2944,13 +2945,11 @@ static int _raid_remove_images(struct logical_volume *lv, int yes,
 	/*
 	 * Eliminate the extracted LVs
 	 */
-	if (!dm_list_empty(removal_lvs)) {
-		if (!_deactivate_and_remove_lvs(lv->vg, removal_lvs))
-			return_0;
+	if (!_deactivate_and_remove_lvs(lv->vg, removal_lvs))
+		return_0;
 
-		if (!vg_write(lv->vg) || !vg_commit(lv->vg))
-			return_0;
-	}
+	if (!lv_update_and_reload_origin(lv))
+		return_0;
 
 	backup(lv->vg);
 


