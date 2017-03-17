From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Fri, 17 Mar 2017 09:25:06 -0400
Subject: master - raid: cleanup; remove unused function
Message-ID: <201703171325.v2HDP6aA012300@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=76709aaf39dd0f233ef36b4c49e5378d3735ec62
Commit:        76709aaf39dd0f233ef36b4c49e5378d3735ec62
Parent:        07ea9887d30ccdf71cc6363e45b2edf707066203
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Fri Mar 17 14:24:09 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Fri Mar 17 14:24:44 2017 +0100

raid: cleanup; remove unused function

Remove unused function (lv_has_constant_stripes() is used instead).
---
 lib/metadata/raid_manip.c |   16 ----------------
 1 files changed, 0 insertions(+), 16 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 808e3e1..7521e80 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -39,22 +39,6 @@ static int _check_restriping(uint32_t new_stripes, struct logical_volume *lv)
 	return 1;
 }
 
-__attribute__ ((__unused__))
-/* Check that all lv has segments have exactly the required number of areas */
-static int _check_num_areas_in_lv_segments(struct logical_volume *lv, unsigned num_areas)
-{
-	struct lv_segment *seg;
-
-	dm_list_iterate_items(seg, &lv->segments)
-		if (seg->area_count != num_areas) {
-			log_error("For this operation LV %s needs exactly %u data areas per segment.",
-				  display_lvname(lv), num_areas);
-			return 0;
-		}
-
-	return 1;
-}
-
 /*
  * Check if reshape is supported in the kernel.
  */


