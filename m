From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Mon, 20 Jul 2020 13:42:41 +0000 (GMT)
Subject: master - lvconvert: display warning if raid1 LV image count does not change
Message-ID: <20200720134241.58B463861020@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3c9177fdc0b8f94c0ae335790a485477901b685d
Commit:        3c9177fdc0b8f94c0ae335790a485477901b685d
Parent:        119d5947881a8b99640d81592986e508e040766d
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Mon Jul 20 15:36:25 2020 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Mon Jul 20 15:42:15 2020 +0200

lvconvert: display warning if raid1 LV image count does not change

Fix "lvconvert -mN $RaidLV" to display a warning in
case the same number of images is being requested.

Resolves: https://bugzilla.redhat.com/show_bug.cgi?id=1774696
---
 lib/metadata/raid_manip.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 3b3e1d373..1ff2a0c85 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -3229,6 +3229,11 @@ int lv_raid_change_image_count(struct logical_volume *lv, int yes, uint32_t new_
 	const char *level = seg->area_count == 1 ? "raid1 with " : "";
 	const char *resil = new_count < seg->area_count ? "reducing" : "enhancing";
 
+	if (new_count == seg->area_count) {
+		log_warn("Type %s LV %s already has %u images.", lvseg_name(seg), display_lvname(lv), new_count);
+		return 1;
+	}
+
 	/* LV must be active to perform raid conversion operations */
 	if (!lv_is_active(lv)) {
 		log_error("%s must be active to perform this operation.",


