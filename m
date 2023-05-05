From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Fri,  5 May 2023 18:54:02 +0000 (GMT)
Subject: main - Fix "lvconvert -m 0 will always take rimage_0 even if it is out-of-sync"
Message-ID: <20230505185402.CD1013858D33@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d7e922480e04ecfb7c4d8b2d42533699ddef5c34
Commit:        d7e922480e04ecfb7c4d8b2d42533699ddef5c34
Parent:        368381fd4022dc99ffe551b30ed75c3ddbc5c5c8
Author:        heinzm <heinzm@redhat.com>
AuthorDate:    Fri May 5 15:00:49 2023 +0200
Committer:     heinzm <heinzm@redhat.com>
CommitterDate: Fri May 5 20:51:58 2023 +0200

Fix "lvconvert -m 0 will always take rimage_0 even if it is out-of-sync"

Bail out in case first rimage is out-of-sync.
Refresh first, i.e. "lvchange --resync $RaidLV",
then retry downgrade to linear after resynchronization.
---
 lib/metadata/raid_manip.c | 13 +++++++++++--
 1 file changed, 11 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 0e6a77bac..5112989ab 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -3112,14 +3112,23 @@ static int _raid_remove_images(struct logical_volume *lv, int yes,
 {
 	struct dm_list removed_lvs;
 
-	if (!archive(lv->vg))
-		return_0;
+	if (new_count == 1) {
+		struct lv_segment *seg = first_seg(lv);
+
+		if (seg_is_raid1(seg) && !lv_raid_image_in_sync(seg_lv(seg, 0))) {
+			log_error("%s is out-of-sync!  Please try refreshing first.", display_lvname(lv));
+			return 0;
+		}
+	}
 
 	if (!removal_lvs) {
 		dm_list_init(&removed_lvs);
 		removal_lvs = &removed_lvs;
 	}
 
+	if (!archive(lv->vg))
+		return_0;
+
 	if (!_raid_extract_images(lv, 0, new_count, allocate_pvs, 1,
 				 removal_lvs, removal_lvs)) {
 		log_error("Failed to extract images from %s.",

