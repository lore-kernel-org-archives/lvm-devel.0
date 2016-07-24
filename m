From: Alasdair Kergon <agk@fedoraproject.org>
Date: Sun, 24 Jul 2016 00:41:37 +0000 (UTC)
Subject: master - raid_manip: Some validation functions.
Message-ID: <20160724004137.080586055F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3bc1adc4048def6dd58f1232bea1f388f9456ef9
Commit:        3bc1adc4048def6dd58f1232bea1f388f9456ef9
Parent:        ea543b5c6f2f7fd9e7c54d8e33abc32049aafc6d
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Sun Jul 24 01:40:24 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Sun Jul 24 01:40:24 2016 +0100

raid_manip: Some validation functions.

---
 lib/metadata/raid_manip.c |   61 ++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 60 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index ee05ae7..0364f2f 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -33,6 +33,40 @@ static int _check_restriping(uint32_t new_stripes, struct logical_volume *lv)
 	return 1;
 }
 
+/* Check that all lv has segments have exactly the required number of areas */
+static int _check_num_areas_in_lv_segments(struct logical_volume *lv, unsigned num_areas)
+{
+	struct lv_segment *seg;
+
+	dm_list_iterate_items(seg, &lv->segments)
+		if (seg->area_count != num_areas) {
+			log_error("For this operation LV %s needs exactly %u data areas per segment.",
+				  display_lvname(lv), num_areas);
+			return 0;
+		}
+
+	return 1;
+}
+
+/* Ensure region size exceeds the minimum for lv */
+static void _ensure_min_region_size(const struct logical_volume *lv)
+{
+	struct lv_segment *seg = first_seg(lv);
+	uint32_t min_region_size, region_size;
+
+	/* MD's bitmap is limited to tracking 2^21 regions */
+	min_region_size = lv->size / (1 << 21);
+	region_size = seg->region_size;
+
+	while (region_size < min_region_size)
+		region_size *= 2;
+
+	if (seg->region_size != region_size) {
+		log_very_verbose("Setting region_size to %u for %s", seg->region_size, display_lvname(lv));
+		seg->region_size = region_size;
+	}
+}
+
 /*
  * Check for maximum number of raid devices.
  * Constrained by kernel MD maximum device limits _and_ dm-raid superblock
@@ -41,13 +75,38 @@ static int _check_restriping(uint32_t new_stripes, struct logical_volume *lv)
 static int _check_max_raid_devices(uint32_t image_count)
 {
 	if (image_count > DEFAULT_RAID_MAX_IMAGES) {
-		log_error("Unable to handle arrays with more than %u devices",
+		log_error("Unable to handle raid arrays with more than %u devices",
 			  DEFAULT_RAID_MAX_IMAGES);
 		return 0;
 	}
+
+	return 1;
+}
+
+static int _check_max_mirror_devices(uint32_t image_count)
+{
+	if (image_count > DEFAULT_MIRROR_MAX_IMAGES) {
+		log_error("Unable to handle mirrors with more than %u devices",
+			  DEFAULT_MIRROR_MAX_IMAGES);
+		return 0;
+	}
+
 	return 1;
 }
 
+/*
+ * Fix up LV region_size if not yet set.
+ */
+/* FIXME Check this happens exactly once at the right place. */
+static void _check_and_adjust_region_size(const struct logical_volume *lv)
+{
+	struct lv_segment *seg = first_seg(lv);
+
+	seg->region_size = seg->region_size ? : get_default_region_size(lv->vg->cmd);
+
+	return _ensure_min_region_size(lv);
+}
+
 static int _lv_is_raid_with_tracking(const struct logical_volume *lv,
 				     struct logical_volume **tracking)
 {


