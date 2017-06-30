From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 30 Jun 2017 15:13:59 -0400
Subject: master - coverity: just make impossible division by zero
Message-ID: <201706301913.v5UJDxwh030874@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2ceb5a0abbbdc3753cfcaff76251d6477a9ea088
Commit:        2ceb5a0abbbdc3753cfcaff76251d6477a9ea088
Parent:        3d08b0971f5f2610459343d0ae2a524d272142d2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 30 19:44:06 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 30 20:39:23 2017 +0200

coverity: just make impossible division by zero

Visible for analyzer  code will not try to use 0 for division.
---
 lib/metadata/raid_manip.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index df7e062..a22b529 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -844,7 +844,7 @@ static int _reorder_raid10_near_seg_areas(struct lv_segment *seg, enum raid0_rai
 
 	if (!(idx = dm_pool_zalloc(seg_lv(seg, 0)->vg->vgmem, seg->area_count * sizeof(*idx)))) {
 		log_error("Memory allocation failed.");
-		return_0;
+		return 0;
 	}
 
 	/* Set up positional index array */
@@ -874,6 +874,11 @@ static int _reorder_raid10_near_seg_areas(struct lv_segment *seg, enum raid0_rai
 		 * _reorder_raid10_near_seg_areas 2137 idx[8]=8
 		 */
 		/* idx[from] = to */
+		if (!stripes) {
+			log_error(INTERNAL_ERROR "LV %s is missing stripes.",
+				  display_lvname(seg->lv));
+			return 0;
+		}
 		for (s = ss = 0; s < seg->area_count; s++)
 			if (s < stripes)
 				idx[s] = s * data_copies;


