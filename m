From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 16 Jun 2017 11:13:41 -0400
Subject: master - cleanup: show what happens when passed prompt
Message-ID: <201706161513.v5GFDf4H011208@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=cdb55c19cd7633cd3467525f6f2b84ef77350d72
Commit:        cdb55c19cd7633cd3467525f6f2b84ef77350d72
Parent:        14816222a19c01e3846d8a38f89113613ae531e8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 15 11:53:01 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 16 17:04:02 2017 +0200

cleanup: show what happens when passed prompt

When we show prompt and user passes --yes - we still
do tell user which action is going to happen.
---
 lib/metadata/raid_manip.c |   27 ++++++++++++++++-----------
 1 files changed, 16 insertions(+), 11 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 87b6c01..0f52ecf 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -3220,11 +3220,13 @@ int lv_raid_split(struct logical_volume *lv, int yes, const char *split_name,
 	}
 
 	/* Split on a 2-legged raid1 LV causes losing all resilience */
-	if (new_count == 1 &&
-	    !yes && yes_no_prompt("Are you sure you want to split %s LV %s losing all resilience? [y/n]: ",
-				  lvseg_name(first_seg(lv)), display_lvname(lv)) == 'n') {
-		log_error("Logical volume %s NOT split.", display_lvname(lv));
-		return 0;
+	if (new_count == 1) {
+		if (!yes && yes_no_prompt("Are you sure you want to split %s LV %s losing all resilience? [y/n]: ",
+					  lvseg_name(first_seg(lv)), display_lvname(lv)) == 'n') {
+			log_error("Logical volume %s NOT split.", display_lvname(lv));
+			return 0;
+		}
+		log_verbose("Losing all resilience for logical volume %s.", display_lvname(lv));
 	}
 
 	/*
@@ -3362,11 +3364,14 @@ int lv_raid_split_and_track(struct logical_volume *lv,
 	}
 
 	/* Split and track changes on a 2-legged raid1 LV causes losing resilience for newly written data. */
-	if (seg->area_count == 2 &&
-	    !yes && yes_no_prompt("Are you sure you want to split and track %s LV %s losing resilience for any newly written data? [y/n]: ",
-				  lvseg_name(seg), display_lvname(lv)) == 'n') {
-		log_error("Logical volume %s NOT split.", display_lvname(lv));
-		return 0;
+	if (seg->area_count == 2) {
+		if (!yes && yes_no_prompt("Are you sure you want to split and track %s LV %s losing resilience for any newly written data? [y/n]: ",
+					  lvseg_name(seg), display_lvname(lv)) == 'n') {
+			log_error("Logical volume %s NOT split.", display_lvname(lv));
+			return 0;
+		}
+		log_verbose("Losing resilience for newly written data on logical volume %s.",
+			    display_lvname(lv));
 	}
 
 	for (s = seg->area_count - 1; s >= 0; --s) {
@@ -3395,7 +3400,7 @@ int lv_raid_split_and_track(struct logical_volume *lv,
 		return_0;
 
 	if (seg->area_count == 2)
-		log_warn("Any newly written data will be non-resilient on LV %s during the split!",
+		log_warn("WARNING: Any newly written data will be non-resilient on LV %s during the split!",
 			 display_lvname(lv));
 
 	log_print_unless_silent("Use 'lvconvert --merge %s' to merge back into %s.",


