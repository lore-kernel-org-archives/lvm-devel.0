From: David Teigland <teigland@sourceware.org>
Date: Wed, 11 Nov 2020 21:29:47 +0000 (GMT)
Subject: main - integrity: display total mismatches at raid LV level
Message-ID: <20201111212947.DF9873857C55@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5fef89361d45797d2e478419caff4528b5ac6150
Commit:        5fef89361d45797d2e478419caff4528b5ac6150
Parent:        2317ba393459a8848a83b43891188520c6a06559
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Nov 11 15:10:15 2020 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Nov 11 15:10:15 2020 -0600

integrity: display total mismatches at raid LV level

Each integrity image in a raid LV reports its own number
of integrity mismatches, e.g.

lvs -o integritymismatches vg/lv_rimage_0
lvs -o integritymismatches vg/lv_rimage_1

In addition to this, allow the total number of integrity
mismatches from all images to be displayed for the raid LV.

lvs -o integritymismatches vg/lv

shows the number of mismatches from both lv_rimage_0 and
lv_rimage_1.
---
 lib/metadata/integrity_manip.c   | 40 ++++++++++++++++++++++++++++++++++++++++
 lib/metadata/metadata-exported.h |  1 +
 lib/report/report.c              |  4 ++++
 3 files changed, 45 insertions(+)

diff --git a/lib/metadata/integrity_manip.c b/lib/metadata/integrity_manip.c
index 00d310e36..53ab1b3fa 100644
--- a/lib/metadata/integrity_manip.c
+++ b/lib/metadata/integrity_manip.c
@@ -895,12 +895,52 @@ int lv_get_raid_integrity_settings(struct logical_volume *lv, struct integrity_s
 	return 0;
 }
 
+int lv_raid_integrity_total_mismatches(struct cmd_context *cmd,
+			    const struct logical_volume *lv,
+			    uint64_t *mismatches)
+{
+	struct logical_volume *lv_image;
+	struct lv_segment *seg, *seg_image;
+	uint32_t s;
+	uint64_t mismatches_image;
+	uint64_t total = 0;
+	int errors = 0;
+
+	if (!lv_is_raid(lv))
+		return 0;
+
+	seg = first_seg(lv);
+
+	for (s = 0; s < seg->area_count; s++) {
+		lv_image = seg_lv(seg, s);
+		seg_image = first_seg(lv_image);
+
+		if (!seg_is_integrity(seg_image))
+			continue;
+
+		mismatches_image = 0;
+
+		if (!lv_integrity_mismatches(cmd, lv_image, &mismatches_image))
+			errors++;
+
+		total += mismatches_image;
+	}
+	*mismatches = total;
+
+	if (errors)
+		return 0;
+	return 1;
+}
+
 int lv_integrity_mismatches(struct cmd_context *cmd,
 			    const struct logical_volume *lv,
 			    uint64_t *mismatches)
 {
 	struct lv_with_info_and_seg_status status;
 
+	if (lv_is_raid(lv) && lv_raid_has_integrity((struct logical_volume *)lv))
+		return lv_raid_integrity_total_mismatches(cmd, lv, mismatches);
+
 	if (!lv_is_integrity(lv))
 		return_0;
 
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 37fe9d0ad..54dc29ffe 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -1433,5 +1433,6 @@ int lv_extend_integrity_in_raid(struct logical_volume *lv, struct dm_list *pvh);
 int lv_get_raid_integrity_settings(struct logical_volume *lv, struct integrity_settings **isettings);
 int integrity_mode_set(const char *mode, struct integrity_settings *settings);
 int lv_integrity_mismatches(struct cmd_context *cmd, const struct logical_volume *lv, uint64_t *mismatches);
+int lv_raid_integrity_total_mismatches(struct cmd_context *cmd, const struct logical_volume *lv, uint64_t *mismatches);
 
 #endif
diff --git a/lib/report/report.c b/lib/report/report.c
index 73a150a7e..2f50a990c 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -3338,6 +3338,10 @@ static int _integritymismatches_disp(struct dm_report *rh __attribute__((unused)
 	if (lv_is_integrity(lv) && lv_integrity_mismatches(lv->vg->cmd, lv, &mismatches))
 		return dm_report_field_uint64(rh, field, &mismatches);
 
+	if (lv_is_raid(lv) && lv_raid_has_integrity(lv) &&
+	    lv_raid_integrity_total_mismatches(lv->vg->cmd, lv, &mismatches))
+		return dm_report_field_uint64(rh, field, &mismatches);
+
 	return _field_set_value(field, "", &GET_TYPE_RESERVED_VALUE(num_undef_64));
 }
 


