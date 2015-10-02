From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri,  2 Oct 2015 09:13:26 +0000 (UTC)
Subject: master - raid: Add metadata dev information to reports.
Message-ID: <20151002091326.57E2A6101E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fb957ef3223939424cf1faff4ca9dd104882ab46
Commit:        fb957ef3223939424cf1faff4ca9dd104882ab46
Parent:        5e5d48348b0c7afdd7a3fb56ddd6875a8b81dc68
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Oct 2 10:09:28 2015 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Oct 2 10:09:28 2015 +0100

raid: Add metadata dev information to reports.

Add metadata_devices and seg_metadata_le_ranges report fields.
Currently only defined for raid, but should probably be extended
to all other segment types that don't report all their device
usage in the 'devices' field.
---
 WHATS_NEW               |    1 +
 lib/metadata/lv.c       |   31 ++++++++++++++++++++++++-------
 lib/metadata/lv.h       |    2 ++
 lib/report/columns.h    |    2 ++
 lib/report/properties.c |    5 +++++
 lib/report/report.c     |   24 ++++++++++++++++++++++++
 6 files changed, 58 insertions(+), 7 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index d693ab8..5da1552 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.133 - 
 ======================================
+  Add metadata_devices and seg_metadata_le_ranges report fields for raid vols.
   Fix lvm2-{activation,clvmd,cmirrord,monitor} service to exec before mounting.
 
 Version 2.02.132 - 22nd September 2015
diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index e0080b1..3126086 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -29,7 +29,7 @@ static struct utsname _utsname;
 static int _utsinit = 0;
 
 static char *_format_pvsegs(struct dm_pool *mem, const struct lv_segment *seg,
-			     int range_format)
+			    int range_format, int metadata_areas_only)
 {
 	unsigned int s;
 	const char *name = NULL;
@@ -41,13 +41,19 @@ static char *_format_pvsegs(struct dm_pool *mem, const struct lv_segment *seg,
 		return NULL;
 	}
 
+	if (metadata_areas_only && (!seg_is_raid(seg) || lv_is_raid_metadata(seg->lv) || lv_is_raid_image(seg->lv)))
+		goto out;
+
 	for (s = 0; s < seg->area_count; s++) {
-		switch (seg_type(seg, s)) {
+		switch (metadata_areas_only ? seg_metatype(seg, s) : seg_type(seg, s)) {
 		case AREA_LV:
-			name = seg_lv(seg, s)->name;
-			extent = seg_le(seg, s);
+			name = metadata_areas_only ? seg_metalv(seg, s)->name : seg_lv(seg, s)->name;
+			extent = metadata_areas_only ? seg_le(seg, s) : 0;
 			break;
 		case AREA_PV:
+			/* Raid metadata never uses PVs directly */
+			if (metadata_areas_only)
+				continue;
 			name = dev_name(seg_dev(seg, s));
 			extent = seg_pe(seg, s);
 			break;
@@ -79,7 +85,7 @@ static char *_format_pvsegs(struct dm_pool *mem, const struct lv_segment *seg,
 
 		if (range_format) {
 			if (dm_snprintf(extent_str, sizeof(extent_str),
-					FMTu32, extent + seg->area_len - 1) < 0) {
+					FMTu32, metadata_areas_only ? extent + seg_metalv(seg, s)->le_count - 1 : extent + seg->area_len - 1) < 0) {
 				log_error("Extent number dm_snprintf failed");
 				return NULL;
 			}
@@ -96,6 +102,7 @@ static char *_format_pvsegs(struct dm_pool *mem, const struct lv_segment *seg,
 		}
 	}
 
+out:
 	if (!dm_pool_grow_object(mem, "\0", 1)) {
 		log_error("dm_pool_grow_object failed");
 		return NULL;
@@ -106,12 +113,22 @@ static char *_format_pvsegs(struct dm_pool *mem, const struct lv_segment *seg,
 
 char *lvseg_devices(struct dm_pool *mem, const struct lv_segment *seg)
 {
-	return _format_pvsegs(mem, seg, 0);
+	return _format_pvsegs(mem, seg, 0, 0);
+}
+
+char *lvseg_metadata_devices(struct dm_pool *mem, const struct lv_segment *seg)
+{
+	return _format_pvsegs(mem, seg, 0, 1);
 }
 
 char *lvseg_seg_pe_ranges(struct dm_pool *mem, const struct lv_segment *seg)
 {
-	return _format_pvsegs(mem, seg, 1);
+	return _format_pvsegs(mem, seg, 1, 0);
+}
+
+char *lvseg_seg_metadata_le_ranges(struct dm_pool *mem, const struct lv_segment *seg)
+{
+	return _format_pvsegs(mem, seg, 1, 1);
 }
 
 char *lvseg_tags_dup(const struct lv_segment *seg)
diff --git a/lib/metadata/lv.h b/lib/metadata/lv.h
index a839489..172d29f 100644
--- a/lib/metadata/lv.h
+++ b/lib/metadata/lv.h
@@ -101,7 +101,9 @@ char *lvseg_cachemode_dup(struct dm_pool *mem, const struct lv_segment *seg);
 char *lvseg_monitor_dup(struct dm_pool *mem, const struct lv_segment *seg);
 char *lvseg_tags_dup(const struct lv_segment *seg);
 char *lvseg_devices(struct dm_pool *mem, const struct lv_segment *seg);
+char *lvseg_metadata_devices(struct dm_pool *mem, const struct lv_segment *seg);
 char *lvseg_seg_pe_ranges(struct dm_pool *mem, const struct lv_segment *seg);
+char *lvseg_seg_metadata_le_ranges(struct dm_pool *mem, const struct lv_segment *seg);
 char *lv_time_dup(struct dm_pool *mem, const struct logical_volume *lv, int iso_mode);
 char *lv_host_dup(struct dm_pool *mem, const struct logical_volume *lv);
 int lv_set_creation(struct logical_volume *lv,
diff --git a/lib/report/columns.h b/lib/report/columns.h
index 3b58aee..6041eeb 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -190,7 +190,9 @@ FIELD(SEGS, seg, SIZ, "SSize", list, 5, segsize, seg_size, "Size of segment in c
 FIELD(SEGS, seg, SIZ, "SSize", list, 5, segsizepe, seg_size_pe, "Size of segment in physical extents.", 0)
 FIELD(SEGS, seg, STR_LIST, "Seg Tags", tags, 8, tags, seg_tags, "Tags, if any.", 0)
 FIELD(SEGS, seg, STR, "PE Ranges", list, 9, peranges, seg_pe_ranges, "Ranges of Physical Extents of underlying devices in command line format.", 0)
+FIELD(SEGS, seg, STR, "Metadata LE Ranges", list, 18, metadataleranges, seg_metadata_le_ranges, "Ranges of Logical Extents of underlying metadata devices in command line format.", 0)
 FIELD(SEGS, seg, STR, "Devices", list, 7, devices, devices, "Underlying devices used with starting extent numbers.", 0)
+FIELD(SEGS, seg, STR, "Metadata Devs", list, 13, metadatadevices, metadata_devices, "Underlying metadata devices used with starting extent numbers.", 0)
 FIELD(SEGS, seg, STR, "Monitor", list, 7, segmonitor, seg_monitor, "Dmeventd monitoring status of the segment.", 0)
 FIELD(SEGS, seg, STR, "Cache Policy", list, 12, cache_policy, cache_policy, "The cache policy (cached segments only).", 0)
 FIELD(SEGS, seg, STR_LIST, "Cache Settings", list, 14, cache_settings, cache_settings, "Cache settings/parameters (cached segments only).", 0)
diff --git a/lib/report/properties.c b/lib/report/properties.c
index 72dcaff..262cc26 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -463,8 +463,13 @@ GET_LVSEG_STR_PROPERTY_FN(seg_tags, lvseg_tags_dup(lvseg))
 GET_LVSEG_STR_PROPERTY_FN(seg_pe_ranges,
 			  lvseg_seg_pe_ranges(lvseg->lv->vg->vgmem, lvseg))
 #define _seg_pe_ranges_set prop_not_implemented_set
+GET_LVSEG_STR_PROPERTY_FN(seg_metadata_le_ranges,
+			  lvseg_seg_metadata_le_ranges(lvseg->lv->vg->vgmem, lvseg))
+#define _seg_metadata_le_ranges_set prop_not_implemented_set
 GET_LVSEG_STR_PROPERTY_FN(devices, lvseg_devices(lvseg->lv->vg->vgmem, lvseg))
 #define _devices_set prop_not_implemented_set
+GET_LVSEG_STR_PROPERTY_FN(metadata_devices, lvseg_metadata_devices(lvseg->lv->vg->vgmem, lvseg))
+#define _metadata_devices_set prop_not_implemented_set
 GET_LVSEG_STR_PROPERTY_FN(seg_monitor, lvseg_monitor_dup(lvseg->lv->vg->vgmem, lvseg))
 #define _seg_monitor_set prop_not_implemented_set
 
diff --git a/lib/report/report.c b/lib/report/report.c
index bf2f1c8..7ac1ac5 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -1304,6 +1304,18 @@ static int _devices_disp(struct dm_report *rh __attribute__((unused)), struct dm
 	return _field_set_value(field, str, NULL);
 }
 
+static int _metadatadevices_disp(struct dm_report *rh __attribute__((unused)), struct dm_pool *mem,
+				 struct dm_report_field *field,
+				 const void *data, void *private __attribute__((unused)))
+{
+	char *str;
+
+	if (!(str = lvseg_metadata_devices(mem, (const struct lv_segment *) data)))
+		return_0;
+
+	return _field_set_value(field, str, NULL);
+}
+
 static int _peranges_disp(struct dm_report *rh __attribute__((unused)), struct dm_pool *mem,
 			  struct dm_report_field *field,
 			  const void *data, void *private __attribute__((unused)))
@@ -1316,6 +1328,18 @@ static int _peranges_disp(struct dm_report *rh __attribute__((unused)), struct d
 	return _field_set_value(field, str, NULL);
 }
 
+static int _metadataleranges_disp(struct dm_report *rh __attribute__((unused)), struct dm_pool *mem,
+				  struct dm_report_field *field,
+				  const void *data, void *private __attribute__((unused)))
+{
+	char *str;
+
+	if (!(str = lvseg_seg_metadata_le_ranges(mem, (const struct lv_segment *) data)))
+		return_0;
+
+	return _field_set_value(field, str, NULL);
+}
+
 static int _tags_disp(struct dm_report *rh, struct dm_pool *mem,
 		      struct dm_report_field *field,
 		      const void *data, void *private)


