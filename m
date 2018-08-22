From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Wed, 22 Aug 2018 11:14:24 -0400
Subject: master - lvconvert: fix conversion attempts to linear
Message-ID: <201808221514.w7MFEOeM012111@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e83c4f07ca4a84808178d5d22cba655e5e370cd8
Commit:        e83c4f07ca4a84808178d5d22cba655e5e370cd8
Parent:        10ede2cc0fdabaeb19c5b5b3341164432f6d4425
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Wed Aug 22 16:39:36 2018 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Wed Aug 22 17:12:43 2018 +0200

lvconvert: fix conversion attempts to linear

"lvconvert --type linear RaidLV" on striped and raid4/5/6/10
have to provide the convenient interim layouts.  Fix involves
a cleanup to the convenience type function.

As a result of testing, add missing sync waits to
lvconvert-raid-reshape-linear_to_raid6-single-type.sh.

Resolves: rhbz1447809
---
 WHATS_NEW                                          |    1 +
 lib/metadata/raid_manip.c                          |  147 +++++++++-----------
 ...ert-raid-reshape-linear_to_raid6-single-type.sh |    2 +
 3 files changed, 69 insertions(+), 81 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 0ea2789..fd1b732 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 3.0.0
 =============
+  Fix lvconvert conversion attempts to linear.
   Fix lvconvert raid0/raid0_meta -> striped regression.
   Fix lvconvert --splitmirror for mirror type (2.02.178).
   Do not pair cache policy and cache metadata format.
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 5441527..6cbf601 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -6110,8 +6110,7 @@ static int _set_convenient_raid145610_segtype_to(const struct lv_segment *seg_fr
 	const struct segment_type *segtype_sav = *segtype;
 
 	/* Linear -> striped request */
-	if (seg_is_striped(seg_from) &&
-	    seg_from->area_count == 1 &&
+	if (seg_is_linear(seg_from) &&
 	    segtype_is_striped(*segtype))
 		;
 	/* Bail out if same RAID level is requested. */
@@ -6120,24 +6119,20 @@ static int _set_convenient_raid145610_segtype_to(const struct lv_segment *seg_fr
 
 	log_debug("Checking LV %s requested %s segment type for convenience",
 		  display_lvname(seg_from->lv), (*segtype)->name);
-	/* striped/raid0 -> raid5/6 */
-	if (seg_is_striped(seg_from) || seg_is_any_raid0(seg_from)) {
-		/* linear -> raid*, interim/first conversion is to raid1 */
-		if (seg_from->area_count == 1)
-			seg_flag = SEG_RAID1;
-
-		else if (seg_is_any_raid0(seg_from) && segtype_is_striped(*segtype))
-			;
-
-		/* If this is any raid5 conversion request -> enforce raid5_n, because we convert from striped */
-		else if (((segtype_is_striped(*segtype) && !segtype_is_any_raid0(*segtype)) || segtype_is_any_raid5(*segtype)) &&
-			 !segtype_is_raid5_n(*segtype))
-			seg_flag = SEG_RAID5_N;
 
-		/* If this is any raid6 conversion request -> enforce raid6_n_6, because we convert from striped */
-		else if (segtype_is_any_raid6(*segtype) && !segtype_is_raid6_n_6(*segtype))
+	/* linear -> */
+	if (seg_is_linear(seg_from)) {
+		seg_flag = SEG_RAID1;
+
+	/* striped/raid0 -> */
+	} else if (seg_is_striped(seg_from) || seg_is_any_raid0(seg_from)) {
+		if (segtype_is_any_raid6(*segtype))
 			seg_flag = SEG_RAID6_N_6;
 
+		if (segtype_is_linear(*segtype) ||
+		    (!segtype_is_raid10(*segtype) && !segtype_is_striped(*segtype)))
+			seg_flag = SEG_RAID5_N;
+
 	/* raid1 -> */
 	} else if (seg_is_raid1(seg_from) && !segtype_is_mirror(*segtype)) {
 		if (seg_from->area_count != 2) {
@@ -6147,85 +6142,68 @@ static int _set_convenient_raid145610_segtype_to(const struct lv_segment *seg_fr
 		}
 
 		if (segtype_is_striped(*segtype) ||
-			   segtype_is_any_raid0(*segtype) ||
-			   segtype_is_raid10(*segtype))
+		    segtype_is_any_raid0(*segtype) ||
+		    segtype_is_raid10(*segtype))
 			seg_flag = SEG_RAID5_N;
 
 		else if (!segtype_is_raid4(*segtype) && !segtype_is_any_raid5(*segtype))
 			seg_flag = SEG_RAID5_LS;
 
-	/* raid4/raid5 -> striped/raid0/raid1/raid6/raid10 */
-	} else if (seg_is_raid4(seg_from) || seg_is_any_raid5(seg_from)) {
-		if ((segtype_is_raid1(*segtype) || segtype_is_linear(*segtype)) && seg_is_raid5_n(seg_from)) {
+	/* raid5* -> */
+	} else if (seg_is_any_raid5(seg_from)) {
+		if (segtype_is_raid1(*segtype) || segtype_is_linear(*segtype)) {
 			if (seg_from->area_count != 2) {
 				log_error("Converting %s LV %s to 2 stripes first.",
 					  lvseg_name(seg_from), display_lvname(seg_from->lv));
 				*new_image_count = 2;
-				seg_flag = SEG_RAID5_N;
+				*segtype = seg_from->segtype;
+				seg_flag = 0;
 			} else
 				seg_flag = SEG_RAID1;
 
-		} else if (segtype_is_raid1(*segtype) && seg_from->area_count != 2) {
-			log_error("Convert %s LV %s to 2 stripes first (i.e. --stripes 1).",
-				  lvseg_name(seg_from), display_lvname(seg_from->lv));
-			return 0;
-
-		} else if (seg_is_raid4(seg_from) &&
-		         (segtype_is_linear(*segtype) || segtype_is_any_raid5(*segtype)) &&
-			 !segtype_is_raid5_n(*segtype))
-			seg_flag = SEG_RAID5_N;
+		} else if (segtype_is_any_raid6(*segtype)) {
+			if (seg_from->area_count < 4) {
+				if (*stripes > 3)
+					*new_image_count = *stripes + seg_from->segtype->parity_devs;
+				else
+					*new_image_count = 4;
 
-		else if (seg_is_raid5_n(seg_from) && seg_from->area_count == 2) {
-			if (*stripes >= 2) {
+				*segtype = seg_from->segtype;
 				log_error("Converting %s LV %s to %u stripes first.",
-					  lvseg_name(seg_from), display_lvname(seg_from->lv), *stripes);
+					  lvseg_name(seg_from), display_lvname(seg_from->lv), *new_image_count);
+
+			} else
+				seg_flag = _raid_seg_flag_5_to_6(seg_from);
+
+		} else if (segtype_is_striped(*segtype) || segtype_is_raid10(*segtype)) {
+			int change = 0;
+
+			if (!seg_is_raid5_n(seg_from)) {
+				seg_flag = SEG_RAID5_N;
+
+			} else if (*stripes > 2 && *stripes != seg_from->area_count - seg_from->segtype->parity_devs) {
+				change = 1;
 				*new_image_count = *stripes + seg_from->segtype->parity_devs;
 				seg_flag = SEG_RAID5_N;
-			} else {
-				log_error("Convert %s LV %s to minimum 3 stripes first (i.e. --stripes 2).",
-					  lvseg_name(seg_from), display_lvname(seg_from->lv));
-				return 0;
-			}
-		} else if (seg_is_any_raid5(seg_from) &&
-		         (segtype_is_linear(*segtype) || segtype_is_raid4(*segtype)) &&
-			 !segtype_is_raid5_n(*segtype))
-			seg_flag = SEG_RAID5_N;
 
-		else if (segtype_is_raid10(*segtype)) {
-			if (seg_from->area_count < 3) {
-				if (*stripes >= 2) {
-					log_error("Converting %s LV %s to %u stripes first.",
-						  lvseg_name(seg_from), display_lvname(seg_from->lv), *stripes);
-					*new_image_count = *stripes + seg_from->segtype->parity_devs;
-					seg_flag = SEG_RAID5_N;
-				} else {
-					log_error("Convert %s LV %s to minimum 3 stripes first (i.e. --stripes 2).",
-						  lvseg_name(seg_from), display_lvname(seg_from->lv));
-					return 0;
-				}
-			} else
-				seg_flag = seg_is_raid5_n(seg_from) ? SEG_RAID0_META : SEG_RAID5_N;
+			} else if (seg_from->area_count < 3) {
+				change = 1;
+				*new_image_count = 3;
+				seg_flag = SEG_RAID5_N;
 
-		} else if (segtype_is_any_raid6(*segtype)) {
-			if (seg_from->area_count < 4 &&
-			    seg_is_any_raid5(seg_from)) {
-				if (*stripes >= 3) {
-					log_error("Converting %s LV %s to %u stripes first.",
-						  lvseg_name(seg_from), display_lvname(seg_from->lv), *stripes);
-					*new_image_count = *stripes + seg_from->segtype->parity_devs;
-					seg_flag = SEG_RAID5_LS;
-				} else {
-					log_error("Convert %s LV %s to minimum 4 stripes first (i.e. --stripes 3).",
-						  lvseg_name(seg_from), display_lvname(seg_from->lv));
-					return 0;
-				}
+			} else if (!segtype_is_striped(*segtype))
+				seg_flag = SEG_RAID0_META;
 
-			} else if (seg_is_raid4(seg_from) && !segtype_is_raid6_n_6(*segtype))
-				seg_flag = SEG_RAID6_N_6;
-			else
-				seg_flag = _raid_seg_flag_5_to_6(seg_from);
+			if (change)
+				log_error("Converting %s LV %s to %u stripes first.",
+					  lvseg_name(seg_from), display_lvname(seg_from->lv), *new_image_count);
 		}
 
+	/* raid4 -> !raid4/raid5* */
+	} else if (seg_is_raid4(seg_from) &&
+		   !segtype_is_raid4(*segtype) && !segtype_is_any_raid5(*segtype)) {
+		seg_flag = SEG_RAID5_N;
+
 	/* raid6 -> striped/raid0/raid5/raid10 */
 	} else if (seg_is_any_raid6(seg_from)) {
 		if (segtype_is_raid1(*segtype)) {
@@ -6237,6 +6215,9 @@ static int _set_convenient_raid145610_segtype_to(const struct lv_segment *seg_fr
 		} else if (segtype_is_any_raid10(*segtype)) {
 			seg_flag = seg_is_raid6_n_6(seg_from) ? SEG_RAID0_META : SEG_RAID6_N_6;
 
+		} else if (segtype_is_linear(*segtype)) {
+			seg_flag = seg_is_raid6_n_6(seg_from) ? SEG_RAID5_N : SEG_RAID6_N_6;
+
 		} else if (segtype_is_striped(*segtype) || segtype_is_any_raid0(*segtype)) {
 			if (!seg_is_raid6_n_6(seg_from))
 				seg_flag = SEG_RAID6_N_6;
@@ -6267,12 +6248,16 @@ static int _set_convenient_raid145610_segtype_to(const struct lv_segment *seg_fr
 			return 0;
 		}
 
-	/* raid10 -> ... */
-	} else if (seg_is_raid10(seg_from) &&
-		   !segtype_is_striped(*segtype) &&
-		   !segtype_is_any_raid0(*segtype))
-		seg_flag = SEG_RAID0_META;
+	} else if (seg_is_raid10(seg_from)) {
+		if (segtype_is_linear(*segtype) ||
+		    (!segtype_is_striped(*segtype) &&
+		    !segtype_is_any_raid0(*segtype))) {
+			seg_flag = SEG_RAID0_META;
+		}
+	}
 
+
+	/* raid10 -> ... */
 	if (seg_flag) {
 		if (!(*segtype = get_segtype_from_flag(cmd, seg_flag)))
 			return_0;
diff --git a/test/shell/lvconvert-raid-reshape-linear_to_raid6-single-type.sh b/test/shell/lvconvert-raid-reshape-linear_to_raid6-single-type.sh
index f01e7ef..05cb616 100644
--- a/test/shell/lvconvert-raid-reshape-linear_to_raid6-single-type.sh
+++ b/test/shell/lvconvert-raid-reshape-linear_to_raid6-single-type.sh
@@ -78,6 +78,7 @@ check lv_first_seg_field $vg/$lv data_stripes 3
 check lv_first_seg_field $vg/$lv stripesize "64.00k"
 check lv_first_seg_field $vg/$lv regionsize "128.00k"
 check lv_first_seg_field $vg/$lv reshape_len_le 0
+aux wait_for_sync $vg $lv
 
 # Convert raid6_ls_6 -> raid6(_zr) (reshape)
 lvconvert -y --type raid6 --stripes 3 --stripesize 64K --regionsize 128K $vg/$lv
@@ -88,6 +89,7 @@ check lv_first_seg_field $vg/$lv data_stripes 3
 check lv_first_seg_field $vg/$lv stripesize "64.00k"
 check lv_first_seg_field $vg/$lv regionsize "128.00k"
 check lv_first_seg_field $vg/$lv reshape_len_le 10
+aux wait_for_sync $vg $lv
 
 # Remove reshape space
 lvconvert -y --type raid6 --stripes 3 --stripesize 64K --regionsize 128K $vg/$lv


