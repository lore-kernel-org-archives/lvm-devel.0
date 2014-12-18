From: heinzm@redhat.com <heinzm@redhat.com>
Date: Thu, 18 Dec 2014 19:00:08 +0100
Subject: [PATCH v2] lv_raid_manip: fix r_mimage_r_rimage_N name flaw resultiong from conversion mirror -> raid1 (bz#1175500)
Message-ID: <1418925608-15340-1-git-send-email-heinzm@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

From: Heinz Mauelshagen <heinzm@redhat.com>

(Replacement for previous submission, which had a typo in)

"lvconvert --type raid1 $LV" to convert from "mirror" to "raid1"
results in strange "${LV}_mimage_r_rimage_N" hidden data logical volume
names.
This fix returns to the familiar "${LV}_rimage_N" namespace.


Signed-off-by: Heinz Mauelshagen <heinzm@redhat.com>

---
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 59d3adb..6f951f4 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -1409,7 +1409,7 @@ static int _convert_mirror_to_raid1(struct logical_volume *lv,
 	}
 
 	for (s = 0; s < seg->area_count; ++s) {
-		if (!(new_name = _generate_raid_name(seg_lv(seg, s), "rimage", s)))
+		if (!(new_name = _generate_raid_name(lv, "rimage", s)))
 			return_0;
 		log_debug_metadata("Renaming %s to %s", seg_lv(seg, s)->name, new_name);
 		seg_lv(seg, s)->name = new_name;
-- 
2.1.0


