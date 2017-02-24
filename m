From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Fri, 24 Feb 2017 06:32:38 +0000 (UTC)
Subject: master - lvconvert: fix 2 issues identified in intesting
Message-ID: <20170224063238.B142E60AC5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3bdc4045c2abbf9ea11000b76eeefab9fed16033
Commit:        3bdc4045c2abbf9ea11000b76eeefab9fed16033
Parent:        d768fbe010914161e3e7bfff6e4e6e0e2cd3907d
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Fri Feb 24 05:58:45 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Fri Feb 24 05:58:45 2017 +0100

lvconvert: fix 2 issues identified in intesting

Allow regionsize on upconvert from linear:
fix related commit 2574d3257ad41 to actually work

Related: rhbz1394427

Remove setting raid5_n on conversions from raid1
as of commit 932db3db5357 because any raid5 mapping
may be requested.

Related: rhbz834579
Related: rhbz1191935
Related: rhbz1191978
---
 lib/metadata/raid_manip.c |   14 +++++---------
 1 files changed, 5 insertions(+), 9 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index ab0bfab..34567bd 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -2696,12 +2696,14 @@ static int _raid_add_images(struct logical_volume *lv,
 			    int commit, int use_existing_area_len)
 {
 	int rebuild_flag_cleared = 0;
-	struct lv_segment *seg;
-	uint32_t s;
+	struct lv_segment *seg = first_seg(lv);
+	uint32_t region_size = seg->region_size, s;
 
 	if (!_raid_add_images_without_commit(lv, new_count, pvs, use_existing_area_len))
 		return_0;
 
+	first_seg(lv)->region_size = region_size;
+
 	if (!commit)
 		return 1;
 
@@ -5623,7 +5625,7 @@ static uint64_t _raid_seg_flag_6_to_5(const struct lv_segment *seg)
 	return _get_r56_flag(seg, 1);
 }
 
-/* Change segtype for raid4 <-> raid5 <-> raid6 or raid1 <-> raid5 takeover where necessary. */
+/* Change segtype for raid4 <-> raid5 <-> raid6 where necessary. */
 static int _set_convenient_raid1456_segtype_to(const struct lv_segment *seg_from,
 					       const struct segment_type **segtype,
 					       int yes)
@@ -5650,12 +5652,6 @@ static int _set_convenient_raid1456_segtype_to(const struct lv_segment *seg_from
 			goto replaced;
 		}
 
-	/* raid1 -> raid5_n with 2 areas */
-	} else if (seg_is_raid1(seg_from) && seg_from->area_count == 2 &&
-                   segtype_is_any_raid5(*segtype) && !segtype_is_raid5_n(*segtype)) {
-		seg_flag = SEG_RAID5_N;
-		goto replaced;
-
 	/* raid4 -> raid5_n */
 	} else if (seg_is_raid4(seg_from) && segtype_is_any_raid5(*segtype)) {
 		seg_flag = SEG_RAID5_N;


