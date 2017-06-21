From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 21 Jun 2017 06:36:58 -0400
Subject: master - raid: use log_error on error path
Message-ID: <201706211036.v5LAawiL021077@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=07fe64b47317daba1744c8c1ccbef38754fe8a4e
Commit:        07fe64b47317daba1744c8c1ccbef38754fe8a4e
Parent:        61980bcf0624790bfdc07d371fd510d1c4079fb5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jun 21 11:58:38 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jun 21 12:35:17 2017 +0200

raid: use log_error on error path

Converting log_warn to log_error since error must be logged
when tool returns error.
---
 lib/metadata/raid_manip.c |   22 +++++++++++-----------
 1 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 31fb0f7..b91bfba 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -1969,7 +1969,7 @@ static int _raid_reshape_remove_images(struct logical_volume *lv,
 			 new_stripes, display_lvname(lv));
 
 		if (!force) {
-			log_warn("WARNING: Can't remove stripes without --force option.");
+			log_error("Can't remove stripes without --force option.");
 			return 0;
 		}
 
@@ -5956,7 +5956,7 @@ static int _set_convenient_raid145610_segtype_to(const struct lv_segment *seg_fr
 	/* raid1 -> */
 	} else if (seg_is_raid1(seg_from) && !segtype_is_mirror(*segtype)) {
 		if (seg_from->area_count != 2) {
-			log_warn("Convert %s LV %s to 2 images first.",
+			log_error("Convert %s LV %s to 2 images first.",
 				 lvseg_name(seg_from), display_lvname(seg_from->lv));
 			return 0;
 
@@ -5972,8 +5972,8 @@ static int _set_convenient_raid145610_segtype_to(const struct lv_segment *seg_fr
 	} else if (seg_is_raid4(seg_from) || seg_is_any_raid5(seg_from)) {
 		if (segtype_is_raid1(*segtype) &&
 		    seg_from->area_count != 2) {
-			log_warn("Convert %s LV %s to 2 stripes first (i.e. --stripes 1).",
-				 lvseg_name(seg_from), display_lvname(seg_from->lv));
+			log_error("Convert %s LV %s to 2 stripes first (i.e. --stripes 1).",
+				  lvseg_name(seg_from), display_lvname(seg_from->lv));
 			return 0;
 
 		} else if (seg_is_raid4(seg_from) &&
@@ -5988,8 +5988,8 @@ static int _set_convenient_raid145610_segtype_to(const struct lv_segment *seg_fr
 
 		else if (segtype_is_raid10(*segtype)) {
 			if (seg_from->area_count < 3) {
-				log_warn("Convert %s LV %s to minimum 3 stripes first (i.e. --stripes 2).",
-					 lvseg_name(seg_from), display_lvname(seg_from->lv));
+				log_error("Convert %s LV %s to minimum 3 stripes first (i.e. --stripes 2).",
+					  lvseg_name(seg_from), display_lvname(seg_from->lv));
 				return 0;
 			}
 
@@ -5997,8 +5997,8 @@ static int _set_convenient_raid145610_segtype_to(const struct lv_segment *seg_fr
 
 		} else if (segtype_is_any_raid6(*segtype)) {
 			if (seg_from->area_count < 4) {
-				log_warn("Convert %s LV %s to minimum 4 stripes first (i.e. --stripes 3).",
-					 lvseg_name(seg_from), display_lvname(seg_from->lv));
+				log_error("Convert %s LV %s to minimum 4 stripes first (i.e. --stripes 3).",
+					  lvseg_name(seg_from), display_lvname(seg_from->lv));
 				return 0;
 
 			} else if (seg_is_raid4(seg_from) && !segtype_is_raid6_n_6(*segtype))
@@ -6034,12 +6034,12 @@ static int _set_convenient_raid145610_segtype_to(const struct lv_segment *seg_fr
 	/* -> raid1 */
 	} else if (!seg_is_mirror(seg_from) && segtype_is_raid1(*segtype)) {
 		if (!seg_is_raid4(seg_from) && !seg_is_any_raid5(seg_from)) {
-			log_warn("Convert %s LV %s to raid4/raid5 first.",
-				 lvseg_name(seg_from), display_lvname(seg_from->lv));
+			log_error("Convert %s LV %s to raid4/raid5 first.",
+				  lvseg_name(seg_from), display_lvname(seg_from->lv));
 			return 0;
 
 		} else if (seg_from->area_count != 2) {
-			log_warn("Convert %s LV %s to 2 stripes first (i.e. --stripes 1).",
+			log_error("Convert %s LV %s to 2 stripes first (i.e. --stripes 1).",
 				 lvseg_name(seg_from), display_lvname(seg_from->lv));
 			return 0;
 


