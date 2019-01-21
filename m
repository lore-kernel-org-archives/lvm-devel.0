From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 21 Jan 2019 06:55:40 -0500
Subject: master - vdo: allow resize of VDO and VDO pool volumes
Message-ID: <201901211155.x0LBtekj024521@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=08cabe9b83bcce59a5aabc100aad2cb61a7bac0c
Commit:        08cabe9b83bcce59a5aabc100aad2cb61a7bac0c
Parent:        bd6709cec6ca9ecc2c5f4e5f7d587daee5bd8cd1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jan 10 18:00:06 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jan 21 12:53:16 2019 +0100

vdo: allow resize of VDO and VDO pool volumes

Now with newer VDO kvdo target we can start to use standard mechanism
to enable resize of VDO volumes.

VDO pool can be grown.

Virtual volume grows on top of VDO pool when is not big enough.
Reduced VDOLV is calling discard for reduced areas - this can
take long time!

TODO: implement some pollable mechanism for out-of-lock TRIM.
---
 WHATS_NEW               |    1 +
 lib/metadata/lv_manip.c |   19 +++++++++++--------
 2 files changed, 12 insertions(+), 8 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index ba27b7d..06848ea 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.02 - 
 ===================================
+  Support reszing for VDOPoolLV and VDOLV.
   Improve -lXXX%VG modifier which improves cache segment estimation.
   Ensure migration_threshold for cache is at least 8 chunks.
   Restore missing man info lvcreate --zero for thin-pools.
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 5418535..d32bd24 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -1857,7 +1857,8 @@ static int _setup_lv_size(struct logical_volume *lv, uint32_t extents)
 	lv->le_count = extents;
 	lv->size = (uint64_t) extents * lv->vg->extent_size;
 
-	if (lv_is_thin_pool_data(lv)) {
+	if (lv_is_thin_pool_data(lv) ||
+	    lv_is_vdo_pool_data(lv)) {
 		if (!(thin_pool_seg = get_only_segment_using_this_lv(lv)))
 			return_0;
 
@@ -4902,12 +4903,6 @@ static int _lvresize_check(struct logical_volume *lv,
 		return 0;
 	}
 
-	if (lv_is_vdo_type(lv)) {
-		log_error("Resize of VDO type volume %s is not yet supported.",
-			  display_lvname(lv));
-		return 0;
-	}
-
 	if (lv_is_raid(lv) &&
 	    lp->resize == LV_REDUCE) {
 		unsigned attrs;
@@ -4934,6 +4929,7 @@ static int _lvresize_check(struct logical_volume *lv,
 
 	if (!lv_is_visible(lv) &&
 	    !lv_is_thin_pool_metadata(lv) &&
+	    !lv_is_vdo_pool_data(lv) &&
 	    !lv_is_lockd_sanlock_lv(lv)) {
 		log_error("Can't resize internal logical volume %s.", display_lvname(lv));
 		return 0;
@@ -4967,6 +4963,8 @@ static int _lvresize_check(struct logical_volume *lv,
 	    (lv_is_thin_pool(lv) ||
 	     lv_is_thin_pool_data(lv) ||
 	     lv_is_thin_pool_metadata(lv) ||
+	     lv_is_vdo_pool(lv) ||
+	     lv_is_vdo_pool_data(lv) ||
 	     lv_is_pool_metadata_spare(lv) ||
 	     lv_is_lockd_sanlock_lv(lv))) {
 		log_print_unless_silent("Ignoring --resizefs as volume %s does not have a filesystem.",
@@ -5457,6 +5455,11 @@ static int _lvresize_check_type(const struct logical_volume *lv,
 			log_error("Thin pool metadata volumes cannot be reduced.");
 			return 0;
 		}
+		if (lv_is_vdo_pool_data(lv)) {
+			log_error("Cannot reduce VDO pool data volume %s.",
+				  display_lvname(lv));
+			return 0;
+		}
 	} else if (lp->resize == LV_EXTEND)  {
 		if (lv_is_thin_pool_metadata(lv) &&
 		    (!(seg = find_pool_seg(first_seg(lv))) ||
@@ -5529,7 +5532,7 @@ static int _lvresize_prepare(struct logical_volume **lv,
 {
 	struct volume_group *vg = (*lv)->vg;
 
-	if (lv_is_thin_pool(*lv))
+	if (lv_is_thin_pool(*lv) || lv_is_vdo_pool(*lv))
 		*lv = seg_lv(first_seg(*lv), 0); /* switch to data LV */
 
 	/* Resolve extents from size */


