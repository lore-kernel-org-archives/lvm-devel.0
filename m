From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 23 Jan 2014 13:23:44 +0000 (UTC)
Subject: master - thin: validate resize of thin LV with ext. origin
Message-ID: <20140123132344.8C7A06062C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=902b343e0ed071e684dfe89086c740db2e20c663
Commit:        902b343e0ed071e684dfe89086c740db2e20c663
Parent:        2dae78b722cff63eb6e11aa6cedad1ee3545871b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jan 23 13:10:29 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jan 23 14:20:34 2014 +0100

thin: validate resize of thin LV with ext. origin

When thin volume is using external origin, current thin target
is not able to supply 'extended' size with empty pages.

lvm2 detects version and disables extension of LV past the external
origin size in this case.

Thin LV could be however still reduced and extended freely bellow
this size.
---
 WHATS_NEW               |    1 +
 conf/example.conf.in    |    1 +
 lib/activate/activate.h |    1 +
 lib/metadata/lv_manip.c |    8 ++++++++
 lib/thin/thin.c         |   11 +++++++++++
 5 files changed, 22 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index e491ed8..c385951 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.106 - 
 ====================================
+  Detect thin feature external_origin_extend and limit extend when missing.
   Rename internal pool_can_resize_metadata() to thin_pool_feature_supported().
   Issue error if libbblkid detects signature and fails to return offset/length.
   Update autoconf config.guess/sub to 2014-01-01.
diff --git a/conf/example.conf.in b/conf/example.conf.in
index 0c2fc0a..0f73cf3 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -691,6 +691,7 @@ global {
     #   discards_non_power_2
     #   external_origin
     #   metadata_resize
+    #   external_origin_extend
     #
     # thin_disabled_features = [ "discards", "block_size" ]
 }
diff --git a/lib/activate/activate.h b/lib/activate/activate.h
index 1881f75..f748a04 100644
--- a/lib/activate/activate.h
+++ b/lib/activate/activate.h
@@ -64,6 +64,7 @@ enum {
 	THIN_FEATURE_BLOCK_SIZE			= (1 << 3),
 	THIN_FEATURE_DISCARDS_NON_POWER_2	= (1 << 4),
 	THIN_FEATURE_METADATA_RESIZE		= (1 << 5),
+	THIN_FEATURE_EXTERNAL_ORIGIN_EXTEND	= (1 << 6),
 };
 
 void set_activation(int activation);
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 6333ef6..c875b69 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -2452,6 +2452,14 @@ int lv_add_virtual_segment(struct logical_volume *lv, uint64_t status,
 	lv->le_count += extents;
 	lv->size += (uint64_t) extents *lv->vg->extent_size;
 
+	/* Validate thin target supports bigger size of thin volume then external origin */
+	if (lv_is_thin_volume(lv) && first_seg(lv)->external_lv &&
+	    first_seg(lv)->external_lv->size < lv->size &&
+	    !thin_pool_feature_supported(first_seg(lv)->pool_lv, THIN_FEATURE_EXTERNAL_ORIGIN_EXTEND)) {
+		log_error("Thin target does not support external origin smaller then thin volume.");
+		return 0;
+	}
+
 	return 1;
 }
 
diff --git a/lib/thin/thin.c b/lib/thin/thin.c
index 6011d77..cf74964 100644
--- a/lib/thin/thin.c
+++ b/lib/thin/thin.c
@@ -528,6 +528,7 @@ static int _thin_add_target_line(struct dev_manager *dm,
 {
 	char *pool_dlid, *external_dlid;
 	uint32_t device_id = seg->device_id;
+	unsigned attr;
 
 	if (!seg->pool_lv) {
 		log_error(INTERNAL_ERROR "Segment %s has no pool.",
@@ -560,6 +561,15 @@ static int _thin_add_target_line(struct dev_manager *dm,
 
 	/* Add external origin LV */
 	if (seg->external_lv) {
+		if (seg->external_lv->size < seg->lv->size) {
+			/* Validate target supports smaller external origin */
+			if (!_thin_target_present(cmd, first_seg(seg->pool_lv), &attr) ||
+			    !(attr & THIN_FEATURE_EXTERNAL_ORIGIN_EXTEND)) {
+				log_error("Thin target does not support smaller size of external origin LV %s.",
+					  seg->external_lv->name);
+				return 0;
+			}
+		}
 		if (!(external_dlid = build_dm_uuid(mem, seg->external_lv->lvid.s,
 						    lv_layer(seg->external_lv)))) {
 			log_error("Failed to build uuid for external origin LV %s.",
@@ -619,6 +629,7 @@ static int _thin_target_present(struct cmd_context *cmd,
 		{ 1, 4, THIN_FEATURE_BLOCK_SIZE, "block_size" },
 		{ 1, 5, THIN_FEATURE_DISCARDS_NON_POWER_2, "discards_non_power_2" },
 		{ 1, 10, THIN_FEATURE_METADATA_RESIZE, "metadata_resize" },
+		{ 9, 11, THIN_FEATURE_EXTERNAL_ORIGIN_EXTEND, "external_origin_extend" },
 	};
 
 	static const char _lvmconf[] = "global/thin_disabled_features";


