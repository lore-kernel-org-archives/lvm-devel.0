From: David Teigland <teigland@sourceware.org>
Date: Wed,  2 Sep 2020 17:41:14 +0000 (GMT)
Subject: master - integrity: improve lv type checks
Message-ID: <20200902174114.2EAB53945C1D@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d1019a6434a0ffb2b9ed63985e1895435ddeadcf
Commit:        d1019a6434a0ffb2b9ed63985e1895435ddeadcf
Parent:        9a7b81fb7262dbd896b74bc76a98f070a9309fed
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Sep 2 12:40:45 2020 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Sep 2 12:40:45 2020 -0500

integrity: improve lv type checks

---
 lib/metadata/integrity_manip.c | 52 ++++++++++++++++++++++++++----------------
 1 file changed, 32 insertions(+), 20 deletions(-)

diff --git a/lib/metadata/integrity_manip.c b/lib/metadata/integrity_manip.c
index 5854a2a52..ddcce9886 100644
--- a/lib/metadata/integrity_manip.c
+++ b/lib/metadata/integrity_manip.c
@@ -155,6 +155,9 @@ int lv_extend_integrity_in_raid(struct logical_volume *lv, struct dm_list *pvh)
 	uint32_t meta_extents, prev_meta_extents;
 	uint32_t area_count, s;
 
+	if (!lv_is_raid(lv))
+		return_0;
+
 	seg_top = first_seg(lv);
 		                
 	if (!(segtype = get_segtype_from_string(cmd, SEG_TYPE_NAME_STRIPED)))
@@ -794,6 +797,11 @@ void lv_clear_integrity_recalculate_metadata(struct logical_volume *lv)
 	struct lv_segment *seg, *seg_image;
 	uint32_t s;
 
+	if (!lv_is_raid(lv) && !lv_is_integrity(lv)) {
+		log_error("Invalid LV type for clearing integrity");
+		return;
+	}
+
 	seg = first_seg(lv);
 
 	if (seg_is_raid(seg)) {
@@ -804,9 +812,6 @@ void lv_clear_integrity_recalculate_metadata(struct logical_volume *lv)
 		}
 	} else if (seg_is_integrity(seg)) {
 		seg->integrity_recalculate = 0;
-	} else {
-		log_error("Invalid LV type for clearing integrity");
-		return;
 	}
 
 	if (!vg_write(vg) || !vg_commit(vg)) {
@@ -822,6 +827,9 @@ int lv_has_integrity_recalculate_metadata(struct logical_volume *lv)
 	uint32_t s;
 	int ret = 0;
 
+	if (!lv_is_raid(lv) && !lv_is_integrity(lv))
+		return_0;
+
 	seg = first_seg(lv);
 
 	if (seg_is_raid(seg)) {
@@ -847,17 +855,17 @@ int lv_raid_has_integrity(struct logical_volume *lv)
 	struct lv_segment *seg, *seg_image;
 	uint32_t s;
 
-	if (!(seg = first_seg(lv)))
-		return 0;
+	if (!lv_is_raid(lv))
+		return_0;
 
-	if (seg_is_raid(seg)) {
-		for (s = 0; s < seg->area_count; s++) {
-			lv_image = seg_lv(seg, s);
-			seg_image = first_seg(lv_image);
+	seg = first_seg(lv);
 
-			if (seg_is_integrity(seg_image))
-				return 1;
-		}
+	for (s = 0; s < seg->area_count; s++) {
+		lv_image = seg_lv(seg, s);
+		seg_image = first_seg(lv_image);
+
+		if (seg_is_integrity(seg_image))
+			return 1;
 	}
 
 	return 0;
@@ -869,17 +877,18 @@ int lv_get_raid_integrity_settings(struct logical_volume *lv, struct integrity_s
 	struct lv_segment *seg, *seg_image;
 	uint32_t s;
 
+	if (!lv_is_raid(lv))
+		return_0;
+
 	seg = first_seg(lv);
 
-	if (seg_is_raid(seg)) {
-		for (s = 0; s < seg->area_count; s++) {
-			lv_image = seg_lv(seg, s);
-			seg_image = first_seg(lv_image);
+	for (s = 0; s < seg->area_count; s++) {
+		lv_image = seg_lv(seg, s);
+		seg_image = first_seg(lv_image);
 
-			if (seg_is_integrity(seg_image)) {
-				*isettings = &seg_image->integrity_settings;
-				return 1;
-			}
+		if (seg_is_integrity(seg_image)) {
+			*isettings = &seg_image->integrity_settings;
+			return 1;
 		}
 	}
 
@@ -892,6 +901,9 @@ int lv_integrity_mismatches(struct cmd_context *cmd,
 {
 	struct lv_with_info_and_seg_status status;
 
+	if (!lv_is_integrity(lv))
+		return_0;
+
 	memset(&status, 0, sizeof(status));
 	status.seg_status.type = SEG_STATUS_NONE;
 


