From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Thu, 16 Mar 2017 17:11:20 -0400
Subject: master - lvconvert: ensure upconversion restrictions
Message-ID: <201703162111.v2GLBKrg016260@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b0336e8b3cb04908119e4cea816e39cdccd1a115
Commit:        b0336e8b3cb04908119e4cea816e39cdccd1a115
Parent:        76b843a4bfa89d4c518d35495dbe13e35614acea
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Thu Mar 16 22:10:32 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Thu Mar 16 22:10:32 2017 +0100

lvconvert: ensure upconversion restrictions

Ensure minimum number of 3 data stripes on conversions to raid6.

Add test for it.

Resolves: rhbz1432675
---
 lib/metadata/raid_manip.c             |   13 +++++++++++++
 test/shell/lvconvert-raid-takeover.sh |   11 ++++++++++-
 2 files changed, 23 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 720337b..dbffc5a 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -5087,6 +5087,19 @@ static int _takeover_upconvert_wrapper(TAKEOVER_FN_ARGS)
 		return 0;
 	}
 
+	if (segtype_is_any_raid6(new_segtype)) {
+		uint32_t min_areas = 3;
+
+		if (seg_is_raid4(seg) || seg_is_any_raid5(seg))
+			min_areas = 4;
+
+		if (seg->area_count < min_areas) {
+			log_error("Minimum of %" PRIu32 " stripes needed for conversion from %s to %s.",
+				  min_areas, lvseg_name(seg), new_segtype->name);
+			return 0;
+		}
+	}
+
 	if (seg_is_any_raid5(seg) && segtype_is_any_raid6(new_segtype) && seg->area_count < 4) {
 		log_error("Minimum of 3 stripes needed for conversion from %s to %s.",
 			  lvseg_name(seg), new_segtype->name);
diff --git a/test/shell/lvconvert-raid-takeover.sh b/test/shell/lvconvert-raid-takeover.sh
index 2ce6367..0e8e880 100644
--- a/test/shell/lvconvert-raid-takeover.sh
+++ b/test/shell/lvconvert-raid-takeover.sh
@@ -88,7 +88,16 @@ function _invalid_raid5_conversions
 	not _lvconvert raid6 raid6_n_6 4 6 $vg $lv1
 }
 
-# Delayst leg so that rebuilding status characters
+# Check raid6 conversion constrainst of minimum 3 stripes
+_lvcreate striped 2 2 4m $vg $lv1
+not _lvconvert raid6 raid6_n_6 2 4 $vg $lv1
+lvremove -y $vg
+
+_lvcreate raid0 3 3 4m $vg $lv1
+_lvconvert raid6 raid6_n_6 3 5 $vg $lv1
+lvremove -y $vg
+
+# Delay 1st leg so that rebuilding status characters
 #  can be read before resync finished too quick.
 # aux delay_dev "$dev1" 1
 


