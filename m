From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 17 Jun 2014 14:34:37 +0000 (UTC)
Subject: master - report: select: add support for percent selection
Message-ID: <20140617143437.3265D60C4E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=51a86dc2f8cdfe3de9f0876548731ede1f6a4f24
Commit:        51a86dc2f8cdfe3de9f0876548731ede1f6a4f24
Parent:        cfed0d09e8ef8f0f819420a15c9165d4fd49a890
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Jun 9 16:23:45 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Jun 17 16:27:21 2014 +0200

report: select: add support for percent selection

---
 lib/properties/prop_common.h |    3 +-
 lib/report/columns.h         |   10 ++--
 lib/report/report.c          |    1 +
 libdm/libdevmapper.h         |    8 ++-
 libdm/libdm-report.c         |   99 ++++++++++++++++++++++++++++++------------
 5 files changed, 84 insertions(+), 37 deletions(-)

diff --git a/lib/properties/prop_common.h b/lib/properties/prop_common.h
index e2249e1..6972f9f 100644
--- a/lib/properties/prop_common.h
+++ b/lib/properties/prop_common.h
@@ -123,7 +123,8 @@ static int _ ## NAME ## _get (const void *obj, struct lvm_property_type *prop) \
 #define STR 1
 #define NUM 2
 #define SIZ 3
-#define STR_LIST 4
+#define PCT 4
+#define STR_LIST 5
 
 #define FIELD_MODIFIABLE 0x00000001
 #define FIELD(type, strct, field_type, head, field, width, fn, id, desc, settable) \
diff --git a/lib/report/columns.h b/lib/report/columns.h
index e3998ef..70a3b65 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -44,11 +44,11 @@ FIELD(LVS, lv, SIZ, "MSize", lvid, 6, lvmetadatasize, lv_metadata_size, "For thi
 FIELD(LVS, lv, NUM, "#Seg", lvid, 4, lvsegcount, seg_count, "Number of segments in LV.", 0)
 FIELD(LVS, lv, STR, "Origin", lvid, 6, origin, origin, "For snapshots, the origin device of this LV.", 0)
 FIELD(LVS, lv, SIZ, "OSize", lvid, 5, originsize, origin_size, "For snapshots, the size of the origin device of this LV.", 0)
-FIELD(LVS, lv, NUM, "Data%", lvid, 6, datapercent, data_percent, "For snapshot and thin pools and volumes, the percentage full if LV is active.", 0)
-FIELD(LVS, lv, NUM, "Snap%", lvid, 6, snpercent, snap_percent, "For snapshots, the percentage full if LV is active.", 0)
-FIELD(LVS, lv, NUM, "Meta%", lvid, 6, metadatapercent, metadata_percent, "For thin pools, the percentage of metadata full if LV is active.", 0)
-FIELD(LVS, lv, NUM, "Cpy%Sync", lvid, 8, copypercent, copy_percent, "For RAID, mirrors and pvmove, current percentage in-sync.", 0)
-FIELD(LVS, lv, NUM, "Cpy%Sync", lvid, 8, copypercent, sync_percent, "For RAID, mirrors and pvmove, current percentage in-sync.", 0)
+FIELD(LVS, lv, PCT, "Data%", lvid, 6, datapercent, data_percent, "For snapshot and thin pools and volumes, the percentage full if LV is active.", 0)
+FIELD(LVS, lv, PCT, "Snap%", lvid, 6, snpercent, snap_percent, "For snapshots, the percentage full if LV is active.", 0)
+FIELD(LVS, lv, PCT, "Meta%", lvid, 6, metadatapercent, metadata_percent, "For thin pools, the percentage of metadata full if LV is active.", 0)
+FIELD(LVS, lv, PCT, "Cpy%Sync", lvid, 8, copypercent, copy_percent, "For RAID, mirrors and pvmove, current percentage in-sync.", 0)
+FIELD(LVS, lv, PCT, "Cpy%Sync", lvid, 8, copypercent, sync_percent, "For RAID, mirrors and pvmove, current percentage in-sync.", 0)
 FIELD(LVS, lv, NUM, "Mismatches", lvid, 10, raidmismatchcount, raid_mismatch_count, "For RAID, number of mismatches found or repaired.", 0)
 FIELD(LVS, lv, STR, "SyncAction", lvid, 10, raidsyncaction, raid_sync_action, "For RAID, the current synchronization action being performed.", 0)
 FIELD(LVS, lv, NUM, "WBehind", lvid, 7, raidwritebehind, raid_write_behind, "For RAID1, the number of outstanding writes allowed to writemostly devices.", 0)
diff --git a/lib/report/report.c b/lib/report/report.c
index 6f507b6..34b7b07 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -1203,6 +1203,7 @@ static const struct dm_report_object_type _devtypes_report_types[] = {
 #define STR DM_REPORT_FIELD_TYPE_STRING
 #define NUM DM_REPORT_FIELD_TYPE_NUMBER
 #define SIZ DM_REPORT_FIELD_TYPE_SIZE
+#define PCT DM_REPORT_FIELD_TYPE_PERCENT
 #define STR_LIST DM_REPORT_FIELD_TYPE_STRING_LIST
 #define FIELD(type, strct, sorttype, head, field, width, func, id, desc, writeable) \
 	{type, sorttype, offsetof(type_ ## strct, field), width, \
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index ecf5640..fab1071 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -1628,15 +1628,16 @@ struct dm_report_field;
 /*
  * dm_report_field_type flags
  */
-#define DM_REPORT_FIELD_MASK			0x000000FF
+#define DM_REPORT_FIELD_MASK			0x00000FFF
 #define DM_REPORT_FIELD_ALIGN_MASK		0x0000000F
 #define DM_REPORT_FIELD_ALIGN_LEFT		0x00000001
 #define DM_REPORT_FIELD_ALIGN_RIGHT		0x00000002
-#define DM_REPORT_FIELD_TYPE_MASK		0x000000F0
+#define DM_REPORT_FIELD_TYPE_MASK		0x00000FF0
 #define DM_REPORT_FIELD_TYPE_STRING		0x00000010
 #define DM_REPORT_FIELD_TYPE_NUMBER		0x00000020
 #define DM_REPORT_FIELD_TYPE_SIZE		0x00000040
-#define DM_REPORT_FIELD_TYPE_STRING_LIST	0x00000080
+#define DM_REPORT_FIELD_TYPE_PERCENT		0x00000080
+#define DM_REPORT_FIELD_TYPE_STRING_LIST	0x00000100
 
 #define DM_REPORT_FIELD_TYPE_ID_LEN 32
 #define DM_REPORT_FIELD_TYPE_HEADING_LEN 32
@@ -1666,6 +1667,7 @@ struct dm_report_reserved_value {
 	const void const *value;	/* reserved value:
 						uint64_t for DM_REPORT_FIELD_TYPE_NUMBER
 						uint64_t for DM_REPORT_FIELD_TYPE_SIZE (number of 512-byte sectors)
+						uint64_t for DM_REPORT_FIELD_TYPE_PERCENT
 						const char * for DM_REPORT_FIELD_TYPE_STRING */
 	const char **names;		/* null-terminated array of names for this reserved value */
 	const char *description;	/* description of the reserved value */
diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index f053f3d..0461bdf 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -59,10 +59,10 @@ struct dm_report {
 /*
  * Internal per-field flags
  */
-#define FLD_HIDDEN	0x00000100
-#define FLD_SORT_KEY	0x00000200
-#define FLD_ASCENDING	0x00000400
-#define FLD_DESCENDING	0x00000800
+#define FLD_HIDDEN	0x00001000
+#define FLD_SORT_KEY	0x00002000
+#define FLD_ASCENDING	0x00004000
+#define FLD_DESCENDING	0x00008000
 
 struct field_properties {
 	struct dm_list list;
@@ -82,15 +82,15 @@ struct op_def {
 	const char *desc;
 };
 
-#define FLD_CMP_MASK	0x000FF000
-#define FLD_CMP_EQUAL	0x00001000
-#define FLD_CMP_NOT	0x00002000
-#define FLD_CMP_GT	0x00004000
-#define FLD_CMP_LT	0x00008000
-#define FLD_CMP_REGEX	0x00010000
-#define FLD_CMP_NUMBER  0x00020000
+#define FLD_CMP_MASK	0x00FF0000
+#define FLD_CMP_EQUAL	0x00010000
+#define FLD_CMP_NOT	0x00020000
+#define FLD_CMP_GT	0x00040000
+#define FLD_CMP_LT	0x00080000
+#define FLD_CMP_REGEX	0x00100000
+#define FLD_CMP_NUMBER  0x00200000
 /*
- * #define FLD_CMP_STRING 0x00040000
+ * #define FLD_CMP_STRING 0x00400000
  * We could defined FLD_CMP_STRING here for completeness here,
  * but it's not needed - we can check operator compatibility with
  * field type by using FLD_CMP_REGEX and FLD_CMP_NUMBER flags only.
@@ -515,6 +515,7 @@ static const char *_get_field_type_name(unsigned field_type)
 		case DM_REPORT_FIELD_TYPE_STRING: return "string";
 		case DM_REPORT_FIELD_TYPE_NUMBER: return "number";
 		case DM_REPORT_FIELD_TYPE_SIZE: return "size";
+		case DM_REPORT_FIELD_TYPE_PERCENT: return "percent";
 		case DM_REPORT_FIELD_TYPE_STRING_LIST: return "string list";
 		default: return "unknown";
 	}
@@ -1150,6 +1151,13 @@ static int _compare_selection_field(struct dm_report *rh,
 		r = _cmp_field_regex((const char *) f->sort_value, fs->v.r, fs->flags);
 	else {
 		switch(f->props->flags & DM_REPORT_FIELD_TYPE_MASK) {
+			case DM_REPORT_FIELD_TYPE_PERCENT:
+				/*
+				 * Check against real percent values only.
+				 * That means DM_PERCENT_0 <= percent <= DM_PERCENT_100.
+				 */
+				if (*(const uint64_t *) f->sort_value > DM_PERCENT_100)
+					return 0;
 			case DM_REPORT_FIELD_TYPE_NUMBER:
 				r = _cmp_field_int(field_id, *(const uint64_t *) f->sort_value, fs->v.i, fs->flags);
 				break;
@@ -1553,6 +1561,7 @@ static int _check_reserved_values_supported(const struct dm_report_reserved_valu
 	const struct dm_report_reserved_value *iter;
 	static uint32_t supported_reserved_types = DM_REPORT_FIELD_TYPE_NUMBER |
 						   DM_REPORT_FIELD_TYPE_SIZE |
+						   DM_REPORT_FIELD_TYPE_PERCENT |
 						   DM_REPORT_FIELD_TYPE_STRING;
 
 	if (!reserved_values)
@@ -1835,33 +1844,46 @@ static const char *_tok_value(struct dm_report *rh,
 
 		case DM_REPORT_FIELD_TYPE_NUMBER:
 		case DM_REPORT_FIELD_TYPE_SIZE:
+		case DM_REPORT_FIELD_TYPE_PERCENT:
 			if (!(s = _tok_value_number(s, begin, end))) {
 				log_error("Failed to parse numeric value "
 					  "for selection field %s.", ft->id);
 				return NULL;
 			}
+
 			factor = (uint64_t *) custom;
-			*factor = dm_units_to_factor(s, &c, 0, &tmp);
 
-			if (expected_type == DM_REPORT_FIELD_TYPE_NUMBER) {
-				if (*factor) {
-					log_error("Found size unit specifier but "
-						  "only numeric value expected for "
-						  "selection field %s.",ft->id);
+			if (*s == DM_PERCENT_CHAR) {
+				s++;
+				c = DM_PERCENT_CHAR;
+				if (expected_type != DM_REPORT_FIELD_TYPE_PERCENT) {
+					log_error("Found percent value but %s value "
+						  "expected for selection field %s.",
+						  expected_type == DM_REPORT_FIELD_TYPE_NUMBER ?
+							"numeric" : "size", ft->id);
 					return NULL;
 				}
-				*flags |= DM_REPORT_FIELD_TYPE_NUMBER;
-			} else {
+			} else if ((*factor = dm_units_to_factor(s, &c, 0, &tmp))) {
 				s = tmp;
+				if (expected_type != DM_REPORT_FIELD_TYPE_SIZE) {
+					log_error("Found size unit specifier "
+						  "but %s value expected for "
+						  "selection field %s.",
+						  expected_type == DM_REPORT_FIELD_TYPE_NUMBER ?
+							"numeric" : "percent", ft->id);
+					return NULL;
+				}
+			} else if (expected_type == DM_REPORT_FIELD_TYPE_SIZE) {
 				/*
 				 * If size unit is not defined in the selection
-				 * use  use 'm' (1 MiB) by default. This is the
+				 * and the type expected is size, use use 'm'
+				 * (1 MiB) for the unit by default. This is the
 				 * same behaviour as seen in lvcreate -L <size>.
 				 */
-				if (!*factor)
-					*factor = 1024*1024;
-				*flags |= DM_REPORT_FIELD_TYPE_SIZE;
+				*factor = 1024*1024;
 			}
+
+			*flags |= expected_type;
 	}
 
 	return s;
@@ -2014,6 +2036,24 @@ static struct field_selection *_create_field_selection(struct dm_report *rh,
 				}
 				dm_pool_free(rh->mem, s);
 				break;
+			case DM_REPORT_FIELD_TYPE_PERCENT:
+				if (reserved)
+					fs->v.i = *(uint64_t *) reserved->value;
+				else {
+					fs->v.d = strtod(s, NULL);
+					if ((errno == ERANGE) || (fs->v.d < 0) || (fs->v.d > 100)) {
+						log_error(_out_of_range_msg, s, field_id);
+						goto error;
+					}
+
+					fs->v.i = (dm_percent_t) (DM_PERCENT_1 * fs->v.d);
+
+					if (_check_value_is_reserved(rh, DM_REPORT_FIELD_TYPE_PERCENT, &fs->v.i)) {
+						log_error("Percent value %s found in selection is reserved.", s);
+						goto error;
+					}
+				}
+				break;
 			case DM_REPORT_FIELD_TYPE_STRING_LIST:
 				fs->v.l = *(struct selection_str_list **)custom;
 				if (_check_value_is_reserved(rh, DM_REPORT_FIELD_TYPE_STRING_LIST, fs->v.l)) {
@@ -2065,6 +2105,7 @@ static void _display_selection_help(struct dm_report *rh)
 	log_warn("  field               - Reporting field.");
 	log_warn("  number              - Non-negative integer value.");
 	log_warn("  size                - Floating point value with units, 'm' unit used by default if not specified.");
+	log_warn("  percent             - Non-negative integer with or without %% suffix.");
 	log_warn("  string              - Characters quoted by \' or \" or unquoted.");
 	log_warn("  string list         - Strings enclosed by [ ] and elements delimited by either");
 	log_warn("                        \"all items must match\" or \"at least one item must match\" operator.");
@@ -2191,12 +2232,13 @@ static struct selection_node *_parse_selection(struct dm_report *rh,
 		goto bad;
 	}
 
-	/* some operators can compare only numeric fields */
+	/* some operators can compare only numeric fields (NUMBER, SIZE or PERCENT) */
 	if ((flags & FLD_CMP_NUMBER) &&
 	    (ft->flags != DM_REPORT_FIELD_TYPE_NUMBER) &&
-	    (ft->flags != DM_REPORT_FIELD_TYPE_SIZE)) {
+	    (ft->flags != DM_REPORT_FIELD_TYPE_SIZE) &&
+	    (ft->flags != DM_REPORT_FIELD_TYPE_PERCENT)) {
 		_display_selection_help(rh);
-		log_error("Operator can be used only with numeric or size fields: %s", ws);
+		log_error("Operator can be used only with number, size or percent fields: %s", ws);
 		goto bad;
 	}
 
@@ -2206,7 +2248,8 @@ static struct selection_node *_parse_selection(struct dm_report *rh,
 			goto_bad;
 	} else {
 		if (ft->flags == DM_REPORT_FIELD_TYPE_SIZE ||
-		    ft->flags == DM_REPORT_FIELD_TYPE_NUMBER)
+		    ft->flags == DM_REPORT_FIELD_TYPE_NUMBER ||
+		    ft->flags == DM_REPORT_FIELD_TYPE_PERCENT)
 			custom = &factor;
 		else if (ft->flags == DM_REPORT_FIELD_TYPE_STRING_LIST)
 			custom = &str_list;


