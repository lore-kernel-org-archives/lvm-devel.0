From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Mon, 28 Sep 2020 15:18:39 +0000 (GMT)
Subject: master - Revert "lvconvert: display warning if raid1 LV image count does not change"
Message-ID: <20200928151839.D1ED43952DA4@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8952dcbff0c1ca9bfaa2f8fe8b6da78a10319e6b
Commit:        8952dcbff0c1ca9bfaa2f8fe8b6da78a10319e6b
Parent:        bbc164991afc5d28bcf12bd4709c4137c913e412
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Mon Sep 28 17:14:03 2020 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Mon Sep 28 17:14:03 2020 +0200

Revert "lvconvert: display warning if raid1 LV image count does not change"

This reverts superfluous commit 3c9177fdc0b8f94c0ae335790a485477901b685d as
_lv_raid_change_image_count() already checks for non-changed image count.

Resolves: https://bugzilla.redhat.com/show_bug.cgi?id=1872130
---
 lib/metadata/raid_manip.c | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 1ff2a0c85..3b3e1d373 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -3229,11 +3229,6 @@ int lv_raid_change_image_count(struct logical_volume *lv, int yes, uint32_t new_
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


