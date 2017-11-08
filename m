From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Wed, 8 Nov 2017 11:49:26 -0500
Subject: master - raid: reject conversion request to striped/raid0 on 2-legged raid4/5
Message-ID: <201711081649.vA8GnQSX020239@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=763db8aab02d7df551a3e8500d261ef6c9651bdb
Commit:        763db8aab02d7df551a3e8500d261ef6c9651bdb
Parent:        b78add3df5bcb40708c71c153ae2e6a8e2c109f2
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Wed Nov 8 17:49:04 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Wed Nov 8 17:49:04 2017 +0100

raid: reject conversion request to striped/raid0 on 2-legged raid4/5

raid4/5 LVs may only be converted to striped or raid0/raid0_meta
in case they have at least 3 legs. 2-legged raid4/5 are a result
of either converting a raid1 to raid4/5 (takeover) or converting
a raid4/5 with more than 2 legs to raid1 with 2 legs (reshape).

The raid4/5 personalities map those as raid1,
thus reject conversion to striped/raid0.

Resolves: rhbz1511047
---
 lib/metadata/raid_manip.c |   24 ++++++++++++++++--------
 1 files changed, 16 insertions(+), 8 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index da00905..816c6d4 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -5163,15 +5163,23 @@ static int _takeover_downconvert_wrapper(TAKEOVER_FN_ARGS)
 		return 0;
 	}
 
-	if (seg_is_any_raid5(seg) &&
-	    segtype_is_raid1(new_segtype)) {
-		if (seg->area_count != 2) {
-			log_error("Can't convert %s LV %s to %s with != 2 legs.",
-				  lvseg_name(seg), display_lvname(lv), new_segtype->name);
-			return 0;
+	if (seg_is_raid4(seg) || seg_is_any_raid5(seg)) {
+		if (segtype_is_raid1(new_segtype)) {
+			if (seg->area_count != 2) {
+				log_error("Can't convert %s LV %s to %s with != 2 legs.",
+					  lvseg_name(seg), display_lvname(lv), new_segtype->name);
+				return 0;
+			}
+			if (seg->area_count != new_image_count) {
+				log_error(INTERNAL_ERROR "Bogus new_image_count converting %s LV %s to %s.",
+					  lvseg_name(seg), display_lvname(lv), new_segtype->name);
+				return 0;
+			}
 		}
-		if (seg->area_count != new_image_count) {
-			log_error(INTERNAL_ERROR "Bogus new_image_count converting %s LV %s to %s.",
+
+		if ((segtype_is_striped_target(new_segtype) || segtype_is_any_raid0(new_segtype)) &&
+		    seg->area_count < 3) {
+			log_error("Can't convert %s LV %s to %s with < 3 legs.",
 				  lvseg_name(seg), display_lvname(lv), new_segtype->name);
 			return 0;
 		}


