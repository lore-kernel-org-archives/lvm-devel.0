From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 19 Jan 2016 13:30:41 +0000 (UTC)
Subject: master - report: change _format_pvsegs to return list instead of plain string, change associated report fields from STR to STR_LIST
Message-ID: <20160119133041.4820E602DD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b160b73800e867a791f196af7b1114243cfd1a65
Commit:        b160b73800e867a791f196af7b1114243cfd1a65
Parent:        2ed324648e4dad4bd504f0bea9d94efa2a99fe4c
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Jan 19 12:24:02 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Jan 19 14:17:41 2016 +0100

report: change _format_pvsegs to return list instead of plain string, change associated report fields from STR to STR_LIST

The associated devices,metadata_devices,seg_pe_ranges and
seg_metadata_le_ranges are reported as genuine string lists now.
This allows for using the items separately in -S|--select
(so searching for subsets etc.) and also it allows for
configuring the separator using report/list_item_separator
which may be useful in scripts (however, we'll enable this
only for seg_le_metadata_ranges and not for devices,seg_pe_ranges
and seg_metadata_devices for compatibility reasons - see following
patch).
---
 lib/metadata/lv.c       |  147 +++++++++++++++++++++++++++++------------------
 lib/metadata/lv.h       |   12 +++-
 lib/report/columns.h    |    8 +-
 lib/report/properties.c |   10 +--
 lib/report/report.c     |   44 ++++++++------
 5 files changed, 132 insertions(+), 89 deletions(-)

diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 6d52577..70a22b3 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -28,11 +28,10 @@
 static struct utsname _utsname;
 static int _utsinit = 0;
 
-static char *_format_pvsegs(struct dm_pool *mem, const struct lv_segment *seg,
-			    int range_format, int metadata_areas_only,
-			    int mark_hidden)
+static struct dm_list *_format_pvsegs(struct dm_pool *mem, const struct lv_segment *seg,
+				      int range_format, int metadata_areas_only,
+				      int mark_hidden)
 {
-	static const char pool_grow_object_failed_msg[] = "dm_pool_grow_object failed";
 	unsigned int s;
 	const char *name = NULL;
 	uint32_t extent = 0;
@@ -40,10 +39,13 @@ static char *_format_pvsegs(struct dm_pool *mem, const struct lv_segment *seg,
 	char extent_str[32];
 	struct logical_volume *lv;
 	int visible = 1;
+	char *list_item;
+	size_t list_item_len;
+	struct dm_list *result = NULL;
 
-	if (!dm_pool_begin_object(mem, 256)) {
-		log_error("dm_pool_begin_object failed");
-		return NULL;
+	if (!(result = str_list_create(mem))) {
+		log_error("_format_pvsegs: str_list_create failed");
+		goto bad;
 	}
 
 	if (metadata_areas_only && (!seg_is_raid(seg) || lv_is_raid_metadata(seg->lv) || lv_is_raid_image(seg->lv)))
@@ -73,84 +75,119 @@ static char *_format_pvsegs(struct dm_pool *mem, const struct lv_segment *seg,
 			break;
 		default:
 			log_error(INTERNAL_ERROR "Unknown area segtype.");
-			return NULL;
-		}
-
-		if (!visible && mark_hidden && !dm_pool_grow_object(mem, "[", 1)) {
-			log_error(pool_grow_object_failed_msg);
-			return NULL;
-		}
-
-		if (!dm_pool_grow_object(mem, name, strlen(name))) {
-			log_error(pool_grow_object_failed_msg);
-			return NULL;
-		}
-
-		if (!visible && mark_hidden && !dm_pool_grow_object(mem, "]", 1)) {
-			log_error(pool_grow_object_failed_msg);
-			return NULL;
+			goto bad;
 		}
 
-		if (dm_snprintf(extent_str, sizeof(extent_str),
-				"%s%" PRIu32 "%s",
-				range_format ? ":" : "(", extent,
-				range_format ? "-"  : ")") < 0) {
-			log_error("Extent number dm_snprintf failed");
-			return NULL;
-		}
-		if (!dm_pool_grow_object(mem, extent_str, strlen(extent_str))) {
-			log_error(pool_grow_object_failed_msg);
-			return NULL;
-		}
+		list_item_len = strlen(name);
+		if (!visible && mark_hidden)
+			/* +2 for [ ] */
+			list_item_len += 2;
 
 		if (range_format) {
 			if (dm_snprintf(extent_str, sizeof(extent_str),
-					FMTu32, extent + seg_len - 1) < 0) {
-				log_error("Extent number dm_snprintf failed");
-				return NULL;
+					":%" PRIu32 "-%" PRIu32,
+					extent, extent + seg_len - 1) < 0) {
+				log_error("_format_pvseggs: extent range dm_snprintf failed");
+				goto bad;
 			}
-			if (!dm_pool_grow_object(mem, extent_str, strlen(extent_str))) {
-				log_error(pool_grow_object_failed_msg);
-				return NULL;
+		} else {
+			if (dm_snprintf(extent_str, sizeof(extent_str),
+					"(%" PRIu32 ")", extent) < 0) {
+				log_error("_format_pvsegs: extent number dm_snprintf failed");
+				goto bad;
 			}
 		}
+		list_item_len += strlen(extent_str);
+		/* trialing 0 */
+		list_item_len += 1;
 
-		if ((s != seg->area_count - 1) &&
-		    !dm_pool_grow_object(mem, range_format ? " " : ",", 1)) {
-			log_error(pool_grow_object_failed_msg);
-			return NULL;
+		if (!(list_item = dm_pool_zalloc(mem, list_item_len))) {
+			log_error("_format_pvsegs: list item dm_pool_zalloc failed");
+			goto bad;
 		}
-	}
 
-out:
-	if (!dm_pool_grow_object(mem, "\0", 1)) {
-		log_error("dm_pool_grow_object failed");
-		return NULL;
-	}
+		if (dm_snprintf(list_item, list_item_len,
+				"%s%s%s%s",
+				(!visible && mark_hidden) ? "[" : "",
+				name,
+				(!visible && mark_hidden) ? "]" : "",
+				extent_str) < 0) {
+			log_error("_format_pvsegs: list item dmsnprintf failed");
+			goto bad;
+		}
 
-	return dm_pool_end_object(mem);
+		if (!str_list_add_no_dup_check(mem, result, list_item)) {
+			log_error("_format_pvsegs: failed to add item to list");
+			goto bad;
+		}
+	}
+out:
+	return result;
+bad:
+	dm_pool_free(mem, result);
+	return NULL;
 }
 
-char *lvseg_devices(struct dm_pool *mem, const struct lv_segment *seg)
+struct dm_list *lvseg_devices(struct dm_pool *mem, const struct lv_segment *seg)
 {
 	return _format_pvsegs(mem, seg, 0, 0, seg->lv->vg->cmd->report_mark_hidden_devices);
 }
 
-char *lvseg_metadata_devices(struct dm_pool *mem, const struct lv_segment *seg)
+char *lvseg_devices_str(struct dm_pool *mem, const struct lv_segment *seg)
+{
+	struct dm_list *list;
+
+	if (!(list = lvseg_devices(mem, seg)))
+		return_NULL;
+
+	return str_list_to_str(mem, list, ",");
+}
+
+struct dm_list *lvseg_metadata_devices(struct dm_pool *mem, const struct lv_segment *seg)
 {
 	return _format_pvsegs(mem, seg, 0, 1, seg->lv->vg->cmd->report_mark_hidden_devices);
 }
 
-char *lvseg_seg_pe_ranges(struct dm_pool *mem, const struct lv_segment *seg)
+char *lvseg_metadata_devices_str(struct dm_pool *mem, const struct lv_segment *seg)
+{
+	struct dm_list *list;
+
+	if (!(list = lvseg_devices(mem, seg)))
+		return_NULL;
+
+	return str_list_to_str(mem, list, ",");
+}
+
+struct dm_list *lvseg_seg_pe_ranges(struct dm_pool *mem, const struct lv_segment *seg)
 {
 	return _format_pvsegs(mem, seg, 1, 0, seg->lv->vg->cmd->report_mark_hidden_devices);
 }
 
-char *lvseg_seg_metadata_le_ranges(struct dm_pool *mem, const struct lv_segment *seg)
+char *lvseg_seg_pe_ranges_str(struct dm_pool *mem, const struct lv_segment *seg)
+{
+	struct dm_list *list;
+
+	if (!(list = lvseg_seg_pe_ranges(mem, seg)))
+		return_NULL;
+
+	return str_list_to_str(mem, list, " ");
+}
+
+struct dm_list *lvseg_seg_metadata_le_ranges(struct dm_pool *mem, const struct lv_segment *seg)
 {
 	return _format_pvsegs(mem, seg, 1, 1, seg->lv->vg->cmd->report_mark_hidden_devices);
 }
 
+char *lvseg_seg_metadata_le_ranges_str(struct dm_pool *mem, const struct lv_segment *seg)
+{
+	struct dm_list *list;
+
+	if (!(list = lvseg_seg_metadata_le_ranges(mem, seg)))
+		return_NULL;
+
+	return str_list_to_str(mem, list, " ");
+}
+
 char *lvseg_tags_dup(const struct lv_segment *seg)
 {
 	return tags_format_and_copy(seg->lv->vg->vgmem, &seg->tags);
diff --git a/lib/metadata/lv.h b/lib/metadata/lv.h
index 18c662b..6b5115f 100644
--- a/lib/metadata/lv.h
+++ b/lib/metadata/lv.h
@@ -86,10 +86,14 @@ int lv_raid_image_in_sync(const struct logical_volume *lv);
 int lv_raid_healthy(const struct logical_volume *lv);
 const char *lvseg_name(const struct lv_segment *seg);
 uint64_t lvseg_start(const struct lv_segment *seg);
-char *lvseg_devices(struct dm_pool *mem, const struct lv_segment *seg);
-char *lvseg_metadata_devices(struct dm_pool *mem, const struct lv_segment *seg);
-char *lvseg_seg_pe_ranges(struct dm_pool *mem, const struct lv_segment *seg);
-char *lvseg_seg_metadata_le_ranges(struct dm_pool *mem, const struct lv_segment *seg);
+struct dm_list *lvseg_devices(struct dm_pool *mem, const struct lv_segment *seg);
+char *lvseg_devices_str(struct dm_pool *mem, const struct lv_segment *seg);
+struct dm_list *lvseg_metadata_devices(struct dm_pool *mem, const struct lv_segment *seg);
+char *lvseg_metadata_devices_str(struct dm_pool *mem, const struct lv_segment *seg);
+struct dm_list *lvseg_seg_pe_ranges(struct dm_pool *mem, const struct lv_segment *seg);
+char *lvseg_seg_pe_ranges_str(struct dm_pool *mem, const struct lv_segment *seg);
+struct dm_list *lvseg_seg_metadata_le_ranges(struct dm_pool *mem, const struct lv_segment *seg);
+char *lvseg_seg_metadata_le_ranges_str(struct dm_pool *mem, const struct lv_segment *seg);
 
 /* LV kernel properties */
 int lv_kernel_major(const struct logical_volume *lv);
diff --git a/lib/report/columns.h b/lib/report/columns.h
index 9bd9fd4..04b9aa1 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -192,10 +192,10 @@ FIELD(SEGS, seg, NUM, "Start", list, 5, segstartpe, seg_start_pe, "Offset within
 FIELD(SEGS, seg, SIZ, "SSize", list, 5, segsize, seg_size, "Size of segment in current units.", 0)
 FIELD(SEGS, seg, SIZ, "SSize", list, 5, segsizepe, seg_size_pe, "Size of segment in physical extents.", 0)
 FIELD(SEGS, seg, STR_LIST, "Seg Tags", tags, 8, tags, seg_tags, "Tags, if any.", 0)
-FIELD(SEGS, seg, STR, "PE Ranges", list, 9, peranges, seg_pe_ranges, "Ranges of Physical Extents of underlying devices in command line format.", 0)
-FIELD(SEGS, seg, STR, "Metadata LE Ranges", list, 18, metadataleranges, seg_metadata_le_ranges, "Ranges of Logical Extents of underlying metadata devices in command line format.", 0)
-FIELD(SEGS, seg, STR, "Devices", list, 7, devices, devices, "Underlying devices used with starting extent numbers.", 0)
-FIELD(SEGS, seg, STR, "Metadata Devs", list, 13, metadatadevices, metadata_devices, "Underlying metadata devices used with starting extent numbers.", 0)
+FIELD(SEGS, seg, STR_LIST, "PE Ranges", list, 9, peranges, seg_pe_ranges, "Ranges of Physical Extents of underlying devices in command line format.", 0)
+FIELD(SEGS, seg, STR_LIST, "Metadata LE Ranges", list, 18, metadataleranges, seg_metadata_le_ranges, "Ranges of Logical Extents of underlying metadata devices in command line format.", 0)
+FIELD(SEGS, seg, STR_LIST, "Devices", list, 7, devices, devices, "Underlying devices used with starting extent numbers.", 0)
+FIELD(SEGS, seg, STR_LIST, "Metadata Devs", list, 13, metadatadevices, metadata_devices, "Underlying metadata devices used with starting extent numbers.", 0)
 FIELD(SEGS, seg, STR, "Monitor", list, 7, segmonitor, seg_monitor, "Dmeventd monitoring status of the segment.", 0)
 FIELD(SEGS, seg, STR, "Cache Policy", list, 12, cache_policy, cache_policy, "The cache policy (cached segments only).", 0)
 FIELD(SEGS, seg, STR_LIST, "Cache Settings", list, 14, cache_settings, cache_settings, "Cache settings/parameters (cached segments only).", 0)
diff --git a/lib/report/properties.c b/lib/report/properties.c
index 6218835..bd5f081 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -464,15 +464,13 @@ GET_LVSEG_NUM_PROPERTY_FN(seg_size_pe, lvseg->len)
 #define _seg_size_pe_set prop_not_implemented_set
 GET_LVSEG_STR_PROPERTY_FN(seg_tags, lvseg_tags_dup(lvseg))
 #define _seg_tags_set prop_not_implemented_set
-GET_LVSEG_STR_PROPERTY_FN(seg_pe_ranges,
-			  lvseg_seg_pe_ranges(lvseg->lv->vg->vgmem, lvseg))
+GET_LVSEG_STR_PROPERTY_FN(seg_pe_ranges, lvseg_seg_pe_ranges_str(lvseg->lv->vg->vgmem, lvseg))
 #define _seg_pe_ranges_set prop_not_implemented_set
-GET_LVSEG_STR_PROPERTY_FN(seg_metadata_le_ranges,
-			  lvseg_seg_metadata_le_ranges(lvseg->lv->vg->vgmem, lvseg))
+GET_LVSEG_STR_PROPERTY_FN(seg_metadata_le_ranges, lvseg_seg_metadata_le_ranges_str(lvseg->lv->vg->vgmem, lvseg))
 #define _seg_metadata_le_ranges_set prop_not_implemented_set
-GET_LVSEG_STR_PROPERTY_FN(devices, lvseg_devices(lvseg->lv->vg->vgmem, lvseg))
+GET_LVSEG_STR_PROPERTY_FN(devices, lvseg_devices_str(lvseg->lv->vg->vgmem, lvseg))
 #define _devices_set prop_not_implemented_set
-GET_LVSEG_STR_PROPERTY_FN(metadata_devices, lvseg_metadata_devices(lvseg->lv->vg->vgmem, lvseg))
+GET_LVSEG_STR_PROPERTY_FN(metadata_devices, lvseg_metadata_devices_str(lvseg->lv->vg->vgmem, lvseg))
 #define _metadata_devices_set prop_not_implemented_set
 GET_LVSEG_STR_PROPERTY_FN(seg_monitor, lvseg_monitor_dup(lvseg->lv->vg->vgmem, lvseg))
 #define _seg_monitor_set prop_not_implemented_set
diff --git a/lib/report/report.c b/lib/report/report.c
index 4b00a76..02d8b22 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -1293,52 +1293,56 @@ static int _dev_name_disp(struct dm_report *rh, struct dm_pool *mem,
 	return _string_disp(rh, mem, field, &name, private);
 }
 
-static int _devices_disp(struct dm_report *rh __attribute__((unused)), struct dm_pool *mem,
+static int _devices_disp(struct dm_report *rh, struct dm_pool *mem,
 			 struct dm_report_field *field,
-			 const void *data, void *private __attribute__((unused)))
+			 const void *data, void *private)
 {
-	char *str;
+	const struct lv_segment *seg = (const struct lv_segment *) data;
+	struct dm_list *list;
 
-	if (!(str = lvseg_devices(mem, (const struct lv_segment *) data)))
+	if (!(list = lvseg_devices(mem, seg)))
 		return_0;
 
-	return _field_set_value(field, str, NULL);
+	return _field_set_string_list(rh, field, list, private, 0, ",");
 }
 
-static int _metadatadevices_disp(struct dm_report *rh __attribute__((unused)), struct dm_pool *mem,
+static int _metadatadevices_disp(struct dm_report *rh, struct dm_pool *mem,
 				 struct dm_report_field *field,
-				 const void *data, void *private __attribute__((unused)))
+				 const void *data, void *private)
 {
-	char *str;
+	const struct lv_segment *seg = (const struct lv_segment *) data;
+	struct dm_list *list;
 
-	if (!(str = lvseg_metadata_devices(mem, (const struct lv_segment *) data)))
+	if (!(list = lvseg_metadata_devices(mem, seg)))
 		return_0;
 
-	return _field_set_value(field, str, NULL);
+	return _field_set_string_list(rh, field, list, private, 0, ",");
 }
 
-static int _peranges_disp(struct dm_report *rh __attribute__((unused)), struct dm_pool *mem,
+static int _peranges_disp(struct dm_report *rh, struct dm_pool *mem,
 			  struct dm_report_field *field,
-			  const void *data, void *private __attribute__((unused)))
+			  const void *data, void *private)
 {
-	char *str;
+	const struct lv_segment *seg = (const struct lv_segment *) data;
+	struct dm_list *list;
 
-	if (!(str = lvseg_seg_pe_ranges(mem, (const struct lv_segment *) data)))
+	if (!(list = lvseg_seg_pe_ranges(mem, seg)))
 		return_0;
 
-	return _field_set_value(field, str, NULL);
+	return _field_set_string_list(rh, field, list, private, 0, " ");
 }
 
-static int _metadataleranges_disp(struct dm_report *rh __attribute__((unused)), struct dm_pool *mem,
+static int _metadataleranges_disp(struct dm_report *rh, struct dm_pool *mem,
 				  struct dm_report_field *field,
-				  const void *data, void *private __attribute__((unused)))
+				  const void *data, void *private)
 {
-	char *str;
+	const struct lv_segment *seg = (const struct lv_segment *) data;
+	struct dm_list *list;
 
-	if (!(str = lvseg_seg_metadata_le_ranges(mem, (const struct lv_segment *) data)))
+	if (!(list = lvseg_seg_metadata_le_ranges(mem, seg)))
 		return_0;
 
-	return _field_set_value(field, str, NULL);
+	return _field_set_string_list(rh, field, list, private, 0, " ");
 }
 
 static int _tags_disp(struct dm_report *rh, struct dm_pool *mem,


