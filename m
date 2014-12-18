From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 18 Dec 2014 16:31:18 +0000 (UTC)
Subject: master - cleanup: use helper macros to get reserved value from values.h for vg_mda_copies and lv_read_ahead fields
Message-ID: <20141218163118.E1A956024C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=028ff309472834e82fe4b849ea4c243feb5098b9
Commit:        028ff309472834e82fe4b849ea4c243feb5098b9
Parent:        7e85d4f5f631e3abc9cd3332965a44df505fe396
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Dec 18 14:52:16 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Dec 18 15:07:46 2014 +0100

cleanup: use helper macros to get reserved value from values.h for vg_mda_copies and lv_read_ahead fields

Avoid making a copy of the keyword which is already registered in
values.h for "unmanaged" (vg_mda_copies field) and "auto" reserved
value (lv_read_ahead field). Also use helper macros to handle these
reserved - this is the correct approach - just do not copy the same
thing again and do not mix it! The GET_FIELD_RESERVED_VALUE and
GET_FIRST_RESERVED_NAME macros guarantees this - use it!

In addition to that, rename reserved values:
  vg_mda_copies --> vg_mda_copies_unmanaged
  lv_read_ahead --> lv_read_ahead_auto

So the field reserved values follows this scheme:

   "<field_name>_<reserved_value_name>".

The same applies for type reserved values with this scheme:

  "<report type name in lowercase>_<reserved_value_name>"

Add a comment about this scheme for others to follow as well
when adding new fields and their reserved values. This makes
it a bit easier to read the code then.
---
 lib/report/report.c |   44 +++++++++++++++++++++++---------------------
 lib/report/values.h |   12 ++++++++----
 2 files changed, 31 insertions(+), 25 deletions(-)

diff --git a/lib/report/report.c b/lib/report/report.c
index 81e10a1..5397d45 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -57,10 +57,10 @@ static const char _str_unknown[] = "unknown";
 
 /*
  * 32 bit signed is casted to 64 bit unsigned in dm_report_field internally!
- * So when stored in the struct, the _reserved_number_undef_32 is actually
- * equal to _reserved_number_undef_64.
+ * So when stored in the struct, the _reserved_num_undef_32 is actually
+ * equal to _reserved_num_undef_64.
  */
-static const int32_t _reserved_number_undef_32 = INT32_C(-1);
+static const int32_t _reserved_num_undef_32 = INT32_C(-1);
 
 /*
  * Reserved values and their assigned names.
@@ -171,9 +171,9 @@ static int _binary_undef_disp(struct dm_report *rh, struct dm_pool *mem __attrib
 	const struct cmd_context *cmd = (const struct cmd_context *) private;
 
 	if (cmd->report_binary_values_as_numeric)
-		return _field_set_value(field, GET_FIRST_RESERVED_NAME(number_undef_64), &GET_TYPE_RESERVED_VALUE(number_undef_64));
+		return _field_set_value(field, GET_FIRST_RESERVED_NAME(num_undef_64), &GET_TYPE_RESERVED_VALUE(num_undef_64));
 	else
-		return _field_set_value(field, _str_unknown, &GET_TYPE_RESERVED_VALUE(number_undef_64));
+		return _field_set_value(field, _str_unknown, &GET_TYPE_RESERVED_VALUE(num_undef_64));
 }
 
 static int _string_disp(struct dm_report *rh, struct dm_pool *mem __attribute__((unused)),
@@ -371,7 +371,7 @@ static int _lvkmaj_disp(struct dm_report *rh, struct dm_pool *mem __attribute__(
 	if (lvdm->info && lvdm->info->exists && lvdm->info->major >= 0)
 		return dm_report_field_int(rh, field, &lvdm->info->major);
 
-	return dm_report_field_int32(rh, field, &GET_TYPE_RESERVED_VALUE(number_undef_32));
+	return dm_report_field_int32(rh, field, &GET_TYPE_RESERVED_VALUE(num_undef_32));
 }
 
 static int _lvkmin_disp(struct dm_report *rh, struct dm_pool *mem __attribute__((unused)),
@@ -383,7 +383,7 @@ static int _lvkmin_disp(struct dm_report *rh, struct dm_pool *mem __attribute__(
 	if (lvdm->info && lvdm->info->exists && lvdm->info->minor >= 0)
 		return dm_report_field_int(rh, field, &lvdm->info->minor);
 
-	return dm_report_field_int32(rh, field, &GET_TYPE_RESERVED_VALUE(number_undef_32));
+	return dm_report_field_int32(rh, field, &GET_TYPE_RESERVED_VALUE(num_undef_32));
 }
 
 static int _lvstatus_disp(struct dm_report *rh __attribute__((unused)), struct dm_pool *mem,
@@ -708,7 +708,8 @@ static int _lvreadahead_disp(struct dm_report *rh, struct dm_pool *mem,
 	const struct logical_volume *lv = (const struct logical_volume *) data;
 
 	if (lv->read_ahead == DM_READ_AHEAD_AUTO)
-		return _field_set_value(field, "auto", &GET_TYPE_RESERVED_VALUE(number_undef_64));
+		return _field_set_value(field, GET_FIRST_RESERVED_NAME(lv_read_ahead_auto),
+					&GET_FIELD_RESERVED_VALUE(lv_read_ahead_auto));
 
 	return _size32_disp(rh, mem, field, &lv->read_ahead, private);
 }
@@ -721,7 +722,7 @@ static int _lvkreadahead_disp(struct dm_report *rh, struct dm_pool *mem,
 	const struct lv_with_info_and_seg_status *lvdm = (const struct lv_with_info_and_seg_status *) data;
 
 	if (!lvdm->info || !lvdm->info->exists)
-		return dm_report_field_int32(rh, field, &GET_TYPE_RESERVED_VALUE(number_undef_32));
+		return dm_report_field_int32(rh, field, &GET_TYPE_RESERVED_VALUE(num_undef_32));
 
 	return _size32_disp(rh, mem, field, &lvdm->info->read_ahead, private);
 }
@@ -809,7 +810,7 @@ static int _transactionid_disp(struct dm_report *rh, struct dm_pool *mem,
 	if (seg_is_thin_pool(seg))
 		return dm_report_field_uint64(rh, field, &seg->transaction_id);
 
-	return _field_set_value(field, "", &GET_TYPE_RESERVED_VALUE(number_undef_64));
+	return _field_set_value(field, "", &GET_TYPE_RESERVED_VALUE(num_undef_64));
 }
 
 static int _thinid_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -821,7 +822,7 @@ static int _thinid_disp(struct dm_report *rh, struct dm_pool *mem,
 	if (seg_is_thin_volume(seg))
 		return dm_report_field_uint32(rh, field, &seg->device_id);
 
-	return _field_set_value(field, "", &GET_TYPE_RESERVED_VALUE(number_undef_64));
+	return _field_set_value(field, "", &GET_TYPE_RESERVED_VALUE(num_undef_64));
 }
 
 static int _discards_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -1007,7 +1008,8 @@ static int _vgmdacopies_disp(struct dm_report *rh, struct dm_pool *mem,
 	uint32_t count = vg_mda_copies(vg);
 
 	if (count == VGMETADATACOPIES_UNMANAGED)
-		return _field_set_value(field, "unmanaged", &GET_TYPE_RESERVED_VALUE(number_undef_64));
+		return _field_set_value(field, GET_FIRST_RESERVED_NAME(vg_mda_copies_unmanaged),
+					&GET_FIELD_RESERVED_VALUE(vg_mda_copies_unmanaged));
 
 	return _uint32_disp(rh, mem, field, &count, private);
 }
@@ -1172,7 +1174,7 @@ static int _raidmismatchcount_disp(struct dm_report *rh __attribute__((unused)),
 	if (lv_is_raid(lv) && lv_raid_mismatch_count(lv, &mismatch_count))
 		return dm_report_field_uint64(rh, field, &mismatch_count);
 
-	return _field_set_value(field, "", &GET_TYPE_RESERVED_VALUE(number_undef_64));
+	return _field_set_value(field, "", &GET_TYPE_RESERVED_VALUE(num_undef_64));
 }
 
 static int _raidwritebehind_disp(struct dm_report *rh __attribute__((unused)),
@@ -1186,7 +1188,7 @@ static int _raidwritebehind_disp(struct dm_report *rh __attribute__((unused)),
 	if (lv_is_raid_type(lv) && first_seg(lv)->writebehind)
 		return dm_report_field_uint32(rh, field, &first_seg(lv)->writebehind);
 
-	return _field_set_value(field, "", &GET_TYPE_RESERVED_VALUE(number_undef_64));
+	return _field_set_value(field, "", &GET_TYPE_RESERVED_VALUE(num_undef_64));
 }
 
 static int _raidminrecoveryrate_disp(struct dm_report *rh __attribute__((unused)),
@@ -1201,7 +1203,7 @@ static int _raidminrecoveryrate_disp(struct dm_report *rh __attribute__((unused)
 		return dm_report_field_uint32(rh, field,
 					      &first_seg(lv)->min_recovery_rate);
 
-	return _field_set_value(field, "", &GET_TYPE_RESERVED_VALUE(number_undef_64));
+	return _field_set_value(field, "", &GET_TYPE_RESERVED_VALUE(num_undef_64));
 }
 
 static int _raidmaxrecoveryrate_disp(struct dm_report *rh __attribute__((unused)),
@@ -1216,7 +1218,7 @@ static int _raidmaxrecoveryrate_disp(struct dm_report *rh __attribute__((unused)
 		return dm_report_field_uint32(rh, field,
 					      &first_seg(lv)->max_recovery_rate);
 
-	return _field_set_value(field, "", &GET_TYPE_RESERVED_VALUE(number_undef_64));
+	return _field_set_value(field, "", &GET_TYPE_RESERVED_VALUE(num_undef_64));
 }
 
 static int _datapercent_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -1278,7 +1280,7 @@ static int _lvmetadatasize_disp(struct dm_report *rh, struct dm_pool *mem,
 		return _size64_disp(rh, mem, field, &size, private);
 	}
 
-	return _field_set_value(field, "", &GET_TYPE_RESERVED_VALUE(number_undef_64));
+	return _field_set_value(field, "", &GET_TYPE_RESERVED_VALUE(num_undef_64));
 }
 
 static int _thincount_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -1293,7 +1295,7 @@ static int _thincount_disp(struct dm_report *rh, struct dm_pool *mem,
 		return _uint32_disp(rh, mem, field, &count, private);
 	}
 
-	return _field_set_value(field, "", &GET_TYPE_RESERVED_VALUE(number_undef_64));
+	return _field_set_value(field, "", &GET_TYPE_RESERVED_VALUE(num_undef_64));
 }
 
 static int _lvtime_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -1648,7 +1650,7 @@ static int _lvmergefailed_disp(struct dm_report *rh, struct dm_pool *mem,
 	int merge_failed;
 
 	if (!lv_is_cow(lv) || !lv_snapshot_percent(lv, &snap_percent))
-		return _field_set_value(field, _str_unknown, &GET_TYPE_RESERVED_VALUE(number_undef_64));
+		return _field_set_value(field, _str_unknown, &GET_TYPE_RESERVED_VALUE(num_undef_64));
 
 	merge_failed = snap_percent == LVM_PERCENT_MERGE_FAILED;
 	return _binary_disp(rh, mem, field, merge_failed, GET_FIRST_RESERVED_NAME(lv_merge_failed_y), private);
@@ -1663,7 +1665,7 @@ static int _lvsnapshotinvalid_disp(struct dm_report *rh, struct dm_pool *mem,
 	int snap_invalid;
 
 	if (!lv_is_cow(lv))
-		return _field_set_value(field, _str_unknown, &GET_TYPE_RESERVED_VALUE(number_undef_64));
+		return _field_set_value(field, _str_unknown, &GET_TYPE_RESERVED_VALUE(num_undef_64));
 
 	snap_invalid = !lv_snapshot_percent(lv, &snap_percent) || snap_percent == DM_PERCENT_INVALID;
 	return _binary_disp(rh, mem, field, snap_invalid, GET_FIRST_RESERVED_NAME(lv_snapshot_invalid_y), private);
@@ -1775,7 +1777,7 @@ static int _cache_ ## cache_status_field_name ## _disp (struct dm_report *rh, \
 { \
 	const struct lv_with_info_and_seg_status *lvdm = (const struct lv_with_info_and_seg_status *) data; \
 	if (lvdm->seg_status->type != SEG_STATUS_CACHE) \
-		return _field_set_value(field, "", &GET_TYPE_RESERVED_VALUE(number_undef_64)); \
+		return _field_set_value(field, "", &GET_TYPE_RESERVED_VALUE(num_undef_64)); \
 	return dm_report_field_uint64(rh, field, (void *) ((char *) lvdm->seg_status->status + offsetof(struct dm_status_cache, cache_status_field_name))); \
 }
 
diff --git a/lib/report/values.h b/lib/report/values.h
index adf22b3..4e12294 100644
--- a/lib/report/values.h
+++ b/lib/report/values.h
@@ -21,9 +21,13 @@
  *
  * TYPE_RESERVED_VALUE defines reserved value that is not bound to any field,
  * but rather it's bound to a certain type. This can be used as a reserved
- * value for all fields of that type then.
+ * value for all fields of that type then. When naming type reserved value,
+ * please follow this naming scheme:
+ *   <report type name in lowercase>_<reserved_value_name>
  *
  * FIELD_RESERVED_VALUE defines reserved value bound to a single field.
+ * When naming reserved value for the field, please follow this naming scheme:
+ *   <field_name>_<reserved_value_name>
  *
  * FIELD_BINARY_RESERVED_VALUE is similar to FIELD_RESERVED_VALUE but it
  * is specifically designed for defintion of reserved names for fields
@@ -42,7 +46,7 @@
 /* *INDENT-OFF* */
 
 /* Per-type reserved values usable for all fields of certain type. */
-TYPE_RESERVED_VALUE(NUM, number_undef_64, "Reserved value for undefined numeric value.", UINT64_C(-1), "-1", "unknown", "undefined", "undef")
+TYPE_RESERVED_VALUE(NUM, num_undef_64, "Reserved value for undefined numeric value.", UINT64_C(-1), "-1", "unknown", "undefined", "undef")
 
 /* Reserved values for PV fields */
 FIELD_RESERVED_BINARY_VALUE(pv_allocatable, pv_allocatable, "", "allocatable")
@@ -56,7 +60,7 @@ FIELD_RESERVED_BINARY_VALUE(vg_partial, vg_partial, "", "partial")
 FIELD_RESERVED_BINARY_VALUE(vg_clustered, vg_clustered, "", "clustered")
 FIELD_RESERVED_VALUE(vg_permissions, vg_permissions_rw, "", "writeable", "writeable", "rw", "read-write")
 FIELD_RESERVED_VALUE(vg_permissions, vg_permissions_r, "", "read-only", "read-only", "r", "ro")
-FIELD_RESERVED_VALUE(vg_mda_copies, vg_mda_copies, "", &GET_TYPE_RESERVED_VALUE(number_undef_64), "unmanaged")
+FIELD_RESERVED_VALUE(vg_mda_copies, vg_mda_copies_unmanaged, "", &GET_TYPE_RESERVED_VALUE(num_undef_64), "unmanaged")
 
 /* Reserved values for LV fields */
 FIELD_RESERVED_BINARY_VALUE(lv_initial_image_sync, lv_initial_image_sync, "", "initial image sync", "sync")
@@ -79,7 +83,7 @@ FIELD_RESERVED_BINARY_VALUE(zero, zero, "", "zero")
 FIELD_RESERVED_VALUE(lv_permissions, lv_permissions_rw, "", "writeable", "writeable", "rw", "read-write")
 FIELD_RESERVED_VALUE(lv_permissions, lv_permissions_r, "", "read-only", "read-only", "r", "ro")
 FIELD_RESERVED_VALUE(lv_permissions, lv_permissions_r_override, "", "read-only-override", "read-only-override", "ro-override", "r-override", "R")
-FIELD_RESERVED_VALUE(lv_read_ahead, lv_read_ahead, "", &GET_TYPE_RESERVED_VALUE(number_undef_64), "auto")
+FIELD_RESERVED_VALUE(lv_read_ahead, lv_read_ahead_auto, "", &GET_TYPE_RESERVED_VALUE(num_undef_64), "auto")
 
 /* Reserved values for SEG fields */
 FIELD_RESERVED_VALUE(cache_policy, cache_policy_undef, "", "undefined", "undefined")


