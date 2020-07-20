From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Mon, 20 Jul 2020 13:43:55 +0000 (GMT)
Subject: stable-2.02 - lvconvert: display warning if raid1 LV image count does not change
Message-ID: <20200720134355.ACE113861020@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7f41d49f497e2b886f197121551db585dff29b6e
Commit:        7f41d49f497e2b886f197121551db585dff29b6e
Parent:        61e831aa5e09dfec25d6975f1c9950181c6a71f7
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Mon Jul 20 15:36:25 2020 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Mon Jul 20 15:43:31 2020 +0200

lvconvert: display warning if raid1 LV image count does not change

Fix "lvconvert -mN $RaidLV" to display a warning in
case the same number of images is being requested.

Resolves: https://bugzilla.redhat.com/show_bug.cgi?id=1774696
---
 lib/metadata/raid_manip.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index f51e9c401..b805d956c 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -3234,6 +3234,11 @@ int lv_raid_change_image_count(struct logical_volume *lv, int yes, uint32_t new_
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


