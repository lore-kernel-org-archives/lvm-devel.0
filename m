From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Mon, 28 Sep 2020 15:18:29 +0000 (GMT)
Subject: stable-2.02 - Revert "lvconvert: display warning if raid1 LV image count does not change"
Message-ID: <20200928151829.A81D9394CC3F@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7e2ceba2fb6ea6769608858f7ce9a88e5ff3eb68
Commit:        7e2ceba2fb6ea6769608858f7ce9a88e5ff3eb68
Parent:        7f41d49f497e2b886f197121551db585dff29b6e
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Mon Sep 28 17:17:26 2020 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Mon Sep 28 17:17:26 2020 +0200

Revert "lvconvert: display warning if raid1 LV image count does not change"

This reverts commit 7f41d49f497e2b886f197121551db585dff29b6e as
_lv_raid_change_image_count() already checks for non-changed image count.

Resolves: https://bugzilla.redhat.com/show_bug.cgi?id=1872130
---
 lib/metadata/raid_manip.c | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index b805d956c..f51e9c401 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -3234,11 +3234,6 @@ int lv_raid_change_image_count(struct logical_volume *lv, int yes, uint32_t new_
 	const char *level = seg->area_count == 1 ? "raid1 with " : "";
 	const char *resil = new_count < seg->area_count ? "reducing" : "enhancing";
 
-	if (new_count == seg->area_count) {
-		log_warn("Type %s LV %s already has %u images.", lvseg_name(seg), display_lvname(lv), new_count);
-		return 1;
-	}
-
 	/* LV must be active to perform raid conversion operations */
 	if (!lv_is_active(lv)) {
 		log_error("%s must be active to perform this operation.",


