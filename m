From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 18 Dec 2014 16:31:16 +0000 (UTC)
Subject: master - refactor: rename existing helper macros for reserved value handling and add GET_FIELD_RESERVED_VALUE macro
Message-ID: <20141218163116.C77D5613B8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7e85d4f5f631e3abc9cd3332965a44df505fe396
Commit:        7e85d4f5f631e3abc9cd3332965a44df505fe396
Parent:        f6f32f39e4ef007fd8566fe32c00975f917fc807
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Dec 18 14:42:14 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Dec 18 14:42:14 2014 +0100

refactor: rename existing helper macros for reserved value handling and add GET_FIELD_RESERVED_VALUE macro

RESERVED(id)   --> GET_TYPE_RESERVED_VALUE(id)
FIRST_NAME(id) --> GET_FIRST_RESERVED_NAME(id)

Also add GET_FIELD_RESERVED_VALUE(id) macro to get per-field reserved value.

This makes it much more readable and hopefully it'll make it
easier to use these helper macros when adding new reporting
fields with reserved values if needed.
---
 lib/report/report.c |  107 ++++++++++++++++++++++++++-------------------------
 lib/report/values.h |    4 +-
 2 files changed, 56 insertions(+), 55 deletions(-)

diff --git a/lib/report/report.c b/lib/report/report.c
index a23b226..81e10a1 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -76,8 +76,9 @@ static const int32_t _reserved_number_undef_32 = INT32_C(-1);
  * 		- 'reserved_value_id_y' (for 1)
  * 		- 'reserved_value_id_n' (for 0)
  */
-#define RESERVED(id) _reserved_ ## id
-#define FIRST_NAME(id) _reserved_ ## id ## _names[0]
+#define GET_TYPE_RESERVED_VALUE(id) _reserved_ ## id
+#define GET_FIELD_RESERVED_VALUE(id) _reserved_ ## id.value
+#define GET_FIRST_RESERVED_NAME(id) _reserved_ ## id ## _names[0]
 
 #define NUM uint64_t
 
@@ -123,9 +124,9 @@ static const struct dm_report_reserved_value _report_reserved_values[] = {
 };
 
 #undef NUM
-#undef TYPE_RESERVED_VALUE_REG
-#undef FIELD_RESERVED_VALUE_REG
-#undef FIELD_RESERVED_BINARY_VALUE_REG
+#undef TYPE_RESERVED_VALUE
+#undef FIELD_RESERVED_VALUE
+#undef FIELD_RESERVED_BINARY_VALUE
 
 static int _field_set_value(struct dm_report_field *field, const void *data, const void *sort)
 {
@@ -170,9 +171,9 @@ static int _binary_undef_disp(struct dm_report *rh, struct dm_pool *mem __attrib
 	const struct cmd_context *cmd = (const struct cmd_context *) private;
 
 	if (cmd->report_binary_values_as_numeric)
-		return _field_set_value(field, FIRST_NAME(number_undef_64), &RESERVED(number_undef_64));
+		return _field_set_value(field, GET_FIRST_RESERVED_NAME(number_undef_64), &GET_TYPE_RESERVED_VALUE(number_undef_64));
 	else
-		return _field_set_value(field, _str_unknown, &RESERVED(number_undef_64));
+		return _field_set_value(field, _str_unknown, &GET_TYPE_RESERVED_VALUE(number_undef_64));
 }
 
 static int _string_disp(struct dm_report *rh, struct dm_pool *mem __attribute__((unused)),
@@ -259,12 +260,12 @@ static int _cache_settings_disp(struct dm_report *rh, struct dm_pool *mem,
 	if (seg_is_cache(seg))
 		seg = first_seg(seg->pool_lv);
 	else
-		return _field_set_value(field, "", NULL /* TODO: FIRST_NAME(cache_settings_undef) */);
+		return _field_set_value(field, "", NULL /* TODO: GET_FIRST_RESERVED_NAME(cache_settings_undef) */);
 
 	if (seg->policy_settings)
 		settings = seg->policy_settings->child;
 	else
-		return _field_set_value(field, "", NULL /* TODO: FIRST_NAME(cache_settings_default) */);
+		return _field_set_value(field, "", NULL /* TODO: GET_FIRST_RESERVED_NAME(cache_settings_default) */);
 
 	if (!(result = str_list_create(mem)))
 		return_0;
@@ -290,7 +291,7 @@ static int _cache_policy_disp(struct dm_report *rh, struct dm_pool *mem,
 	if (seg_is_cache(seg))
 		seg = first_seg(seg->pool_lv);
 	else
-		return _field_set_value(field, "", FIRST_NAME(cache_policy_undef));
+		return _field_set_value(field, "", GET_FIRST_RESERVED_NAME(cache_policy_undef));
 
 	if (seg->policy_name) {
 		if (!(cache_policy_name = dm_pool_strdup(mem, seg->policy_name))) {
@@ -370,7 +371,7 @@ static int _lvkmaj_disp(struct dm_report *rh, struct dm_pool *mem __attribute__(
 	if (lvdm->info && lvdm->info->exists && lvdm->info->major >= 0)
 		return dm_report_field_int(rh, field, &lvdm->info->major);
 
-	return dm_report_field_int32(rh, field, &RESERVED(number_undef_32));
+	return dm_report_field_int32(rh, field, &GET_TYPE_RESERVED_VALUE(number_undef_32));
 }
 
 static int _lvkmin_disp(struct dm_report *rh, struct dm_pool *mem __attribute__((unused)),
@@ -382,7 +383,7 @@ static int _lvkmin_disp(struct dm_report *rh, struct dm_pool *mem __attribute__(
 	if (lvdm->info && lvdm->info->exists && lvdm->info->minor >= 0)
 		return dm_report_field_int(rh, field, &lvdm->info->minor);
 
-	return dm_report_field_int32(rh, field, &RESERVED(number_undef_32));
+	return dm_report_field_int32(rh, field, &GET_TYPE_RESERVED_VALUE(number_undef_32));
 }
 
 static int _lvstatus_disp(struct dm_report *rh __attribute__((unused)), struct dm_pool *mem,
@@ -707,7 +708,7 @@ static int _lvreadahead_disp(struct dm_report *rh, struct dm_pool *mem,
 	const struct logical_volume *lv = (const struct logical_volume *) data;
 
 	if (lv->read_ahead == DM_READ_AHEAD_AUTO)
-		return _field_set_value(field, "auto", &RESERVED(number_undef_64));
+		return _field_set_value(field, "auto", &GET_TYPE_RESERVED_VALUE(number_undef_64));
 
 	return _size32_disp(rh, mem, field, &lv->read_ahead, private);
 }
@@ -720,7 +721,7 @@ static int _lvkreadahead_disp(struct dm_report *rh, struct dm_pool *mem,
 	const struct lv_with_info_and_seg_status *lvdm = (const struct lv_with_info_and_seg_status *) data;
 
 	if (!lvdm->info || !lvdm->info->exists)
-		return dm_report_field_int32(rh, field, &RESERVED(number_undef_32));
+		return dm_report_field_int32(rh, field, &GET_TYPE_RESERVED_VALUE(number_undef_32));
 
 	return _size32_disp(rh, mem, field, &lvdm->info->read_ahead, private);
 }
@@ -808,7 +809,7 @@ static int _transactionid_disp(struct dm_report *rh, struct dm_pool *mem,
 	if (seg_is_thin_pool(seg))
 		return dm_report_field_uint64(rh, field, &seg->transaction_id);
 
-	return _field_set_value(field, "", &RESERVED(number_undef_64));
+	return _field_set_value(field, "", &GET_TYPE_RESERVED_VALUE(number_undef_64));
 }
 
 static int _thinid_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -820,7 +821,7 @@ static int _thinid_disp(struct dm_report *rh, struct dm_pool *mem,
 	if (seg_is_thin_volume(seg))
 		return dm_report_field_uint32(rh, field, &seg->device_id);
 
-	return _field_set_value(field, "", &RESERVED(number_undef_64));
+	return _field_set_value(field, "", &GET_TYPE_RESERVED_VALUE(number_undef_64));
 }
 
 static int _discards_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -1006,7 +1007,7 @@ static int _vgmdacopies_disp(struct dm_report *rh, struct dm_pool *mem,
 	uint32_t count = vg_mda_copies(vg);
 
 	if (count == VGMETADATACOPIES_UNMANAGED)
-		return _field_set_value(field, "unmanaged", &RESERVED(number_undef_64));
+		return _field_set_value(field, "unmanaged", &GET_TYPE_RESERVED_VALUE(number_undef_64));
 
 	return _uint32_disp(rh, mem, field, &count, private);
 }
@@ -1171,7 +1172,7 @@ static int _raidmismatchcount_disp(struct dm_report *rh __attribute__((unused)),
 	if (lv_is_raid(lv) && lv_raid_mismatch_count(lv, &mismatch_count))
 		return dm_report_field_uint64(rh, field, &mismatch_count);
 
-	return _field_set_value(field, "", &RESERVED(number_undef_64));
+	return _field_set_value(field, "", &GET_TYPE_RESERVED_VALUE(number_undef_64));
 }
 
 static int _raidwritebehind_disp(struct dm_report *rh __attribute__((unused)),
@@ -1185,7 +1186,7 @@ static int _raidwritebehind_disp(struct dm_report *rh __attribute__((unused)),
 	if (lv_is_raid_type(lv) && first_seg(lv)->writebehind)
 		return dm_report_field_uint32(rh, field, &first_seg(lv)->writebehind);
 
-	return _field_set_value(field, "", &RESERVED(number_undef_64));
+	return _field_set_value(field, "", &GET_TYPE_RESERVED_VALUE(number_undef_64));
 }
 
 static int _raidminrecoveryrate_disp(struct dm_report *rh __attribute__((unused)),
@@ -1200,7 +1201,7 @@ static int _raidminrecoveryrate_disp(struct dm_report *rh __attribute__((unused)
 		return dm_report_field_uint32(rh, field,
 					      &first_seg(lv)->min_recovery_rate);
 
-	return _field_set_value(field, "", &RESERVED(number_undef_64));
+	return _field_set_value(field, "", &GET_TYPE_RESERVED_VALUE(number_undef_64));
 }
 
 static int _raidmaxrecoveryrate_disp(struct dm_report *rh __attribute__((unused)),
@@ -1215,7 +1216,7 @@ static int _raidmaxrecoveryrate_disp(struct dm_report *rh __attribute__((unused)
 		return dm_report_field_uint32(rh, field,
 					      &first_seg(lv)->max_recovery_rate);
 
-	return _field_set_value(field, "", &RESERVED(number_undef_64));
+	return _field_set_value(field, "", &GET_TYPE_RESERVED_VALUE(number_undef_64));
 }
 
 static int _datapercent_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -1277,7 +1278,7 @@ static int _lvmetadatasize_disp(struct dm_report *rh, struct dm_pool *mem,
 		return _size64_disp(rh, mem, field, &size, private);
 	}
 
-	return _field_set_value(field, "", &RESERVED(number_undef_64));
+	return _field_set_value(field, "", &GET_TYPE_RESERVED_VALUE(number_undef_64));
 }
 
 static int _thincount_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -1292,7 +1293,7 @@ static int _thincount_disp(struct dm_report *rh, struct dm_pool *mem,
 		return _uint32_disp(rh, mem, field, &count, private);
 	}
 
-	return _field_set_value(field, "", &RESERVED(number_undef_64));
+	return _field_set_value(field, "", &GET_TYPE_RESERVED_VALUE(number_undef_64));
 }
 
 static int _lvtime_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -1336,7 +1337,7 @@ static int _pvallocatable_disp(struct dm_report *rh, struct dm_pool *mem,
 			       const void *data, void *private)
 {
 	int allocatable = (((const struct physical_volume *) data)->status & ALLOCATABLE_PV) != 0;
-	return _binary_disp(rh, mem, field, allocatable, FIRST_NAME(pv_allocatable_y), private);
+	return _binary_disp(rh, mem, field, allocatable, GET_FIRST_RESERVED_NAME(pv_allocatable_y), private);
 }
 
 static int _pvexported_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -1344,7 +1345,7 @@ static int _pvexported_disp(struct dm_report *rh, struct dm_pool *mem,
 			    const void *data, void *private)
 {
 	int exported = (((const struct physical_volume *) data)->status & EXPORTED_VG) != 0;
-	return _binary_disp(rh, mem, field, exported, FIRST_NAME(pv_exported_y), private);
+	return _binary_disp(rh, mem, field, exported, GET_FIRST_RESERVED_NAME(pv_exported_y), private);
 }
 
 static int _pvmissing_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -1352,15 +1353,15 @@ static int _pvmissing_disp(struct dm_report *rh, struct dm_pool *mem,
 			   const void *data, void *private)
 {
 	int missing = (((const struct physical_volume *) data)->status & MISSING_PV) != 0;
-	return _binary_disp(rh, mem, field, missing, FIRST_NAME(pv_missing_y), private);
+	return _binary_disp(rh, mem, field, missing, GET_FIRST_RESERVED_NAME(pv_missing_y), private);
 }
 
 static int _vgpermissions_disp(struct dm_report *rh, struct dm_pool *mem,
 			       struct dm_report_field *field,
 			       const void *data, void *private)
 {
-	const char *perms = ((const struct volume_group *) data)->status & LVM_WRITE ? FIRST_NAME(vg_permissions_rw)
-										     : FIRST_NAME(vg_permissions_r);
+	const char *perms = ((const struct volume_group *) data)->status & LVM_WRITE ? GET_FIRST_RESERVED_NAME(vg_permissions_rw)
+										     : GET_FIRST_RESERVED_NAME(vg_permissions_r);
 	return _string_disp(rh, mem, field, &perms, private);
 }
 
@@ -1369,7 +1370,7 @@ static int _vgextendable_disp(struct dm_report *rh, struct dm_pool *mem,
 			      const void *data, void *private)
 {
 	int extendable = (vg_is_resizeable((const struct volume_group *) data)) != 0;
-	return _binary_disp(rh, mem, field, extendable, FIRST_NAME(vg_extendable_y),private);
+	return _binary_disp(rh, mem, field, extendable, GET_FIRST_RESERVED_NAME(vg_extendable_y),private);
 }
 
 static int _vgexported_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -1377,7 +1378,7 @@ static int _vgexported_disp(struct dm_report *rh, struct dm_pool *mem,
 			    const void *data, void *private)
 {
 	int exported = (vg_is_exported((const struct volume_group *) data)) != 0;
-	return _binary_disp(rh, mem, field, exported, FIRST_NAME(vg_exported_y), private);
+	return _binary_disp(rh, mem, field, exported, GET_FIRST_RESERVED_NAME(vg_exported_y), private);
 }
 
 static int _vgpartial_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -1385,7 +1386,7 @@ static int _vgpartial_disp(struct dm_report *rh, struct dm_pool *mem,
 			   const void *data, void *private)
 {
 	int partial = (vg_missing_pv_count((const struct volume_group *) data)) != 0;
-	return _binary_disp(rh, mem, field, partial, FIRST_NAME(vg_partial_y), private);
+	return _binary_disp(rh, mem, field, partial, GET_FIRST_RESERVED_NAME(vg_partial_y), private);
 }
 
 static int _vgallocationpolicy_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -1401,7 +1402,7 @@ static int _vgclustered_disp(struct dm_report *rh, struct dm_pool *mem,
 			     const void *data, void *private)
 {
 	int clustered = (vg_is_clustered((const struct volume_group *) data)) != 0;
-	return _binary_disp(rh, mem, field, clustered, FIRST_NAME(vg_clustered_y), private);
+	return _binary_disp(rh, mem, field, clustered, GET_FIRST_RESERVED_NAME(vg_clustered_y), private);
 }
 
 static int _lvlayout_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -1448,7 +1449,7 @@ static int _lvinitialimagesync_disp(struct dm_report *rh, struct dm_pool *mem,
 	else
 		initial_image_sync = 0;
 
-	return _binary_disp(rh, mem, field, initial_image_sync, FIRST_NAME(lv_initial_image_sync_y), private);
+	return _binary_disp(rh, mem, field, initial_image_sync, GET_FIRST_RESERVED_NAME(lv_initial_image_sync_y), private);
 }
 
 static int _lvimagesynced_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -1465,7 +1466,7 @@ static int _lvimagesynced_disp(struct dm_report *rh, struct dm_pool *mem,
 	else
 		image_synced = 0;
 
-	return _binary_disp(rh, mem, field, image_synced, FIRST_NAME(lv_image_synced_y), private);
+	return _binary_disp(rh, mem, field, image_synced, GET_FIRST_RESERVED_NAME(lv_image_synced_y), private);
 }
 
 static int _lvmerging_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -1484,7 +1485,7 @@ static int _lvmerging_disp(struct dm_report *rh, struct dm_pool *mem,
 	else
 		merging = 0;
 
-	return _binary_disp(rh, mem, field, merging, FIRST_NAME(lv_merging_y), private);
+	return _binary_disp(rh, mem, field, merging, GET_FIRST_RESERVED_NAME(lv_merging_y), private);
 }
 
 static int _lvconverting_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -1508,11 +1509,11 @@ static int _lvpermissions_disp(struct dm_report *rh, struct dm_pool *mem,
 			if (!lvdm->info->exists)
 				perms = _str_unknown;
 			else if (lvdm->info->read_only)
-				perms = FIRST_NAME(lv_permissions_r_override);
+				perms = GET_FIRST_RESERVED_NAME(lv_permissions_r_override);
 			else
-				perms = FIRST_NAME(lv_permissions_rw);
+				perms = GET_FIRST_RESERVED_NAME(lv_permissions_rw);
 		} else if (lvdm->lv->status & LVM_READ)
-			perms = FIRST_NAME(lv_permissions_r);
+			perms = GET_FIRST_RESERVED_NAME(lv_permissions_r);
 		else
 			perms = _str_unknown;
 	}
@@ -1534,7 +1535,7 @@ static int _lvallocationlocked_disp(struct dm_report *rh, struct dm_pool *mem,
 {
 	int alloc_locked = (((const struct logical_volume *) data)->status & LOCKED) != 0;
 
-	return _binary_disp(rh, mem, field, alloc_locked, FIRST_NAME(lv_allocation_locked_y), private);
+	return _binary_disp(rh, mem, field, alloc_locked, GET_FIRST_RESERVED_NAME(lv_allocation_locked_y), private);
 }
 
 static int _lvfixedminor_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -1543,7 +1544,7 @@ static int _lvfixedminor_disp(struct dm_report *rh, struct dm_pool *mem,
 {
 	int fixed_minor = (((const struct logical_volume *) data)->status & FIXED_MINOR) != 0;
 
-	return _binary_disp(rh, mem, field, fixed_minor, FIRST_NAME(lv_fixed_minor_y), private);
+	return _binary_disp(rh, mem, field, fixed_minor, GET_FIRST_RESERVED_NAME(lv_fixed_minor_y), private);
 }
 
 static int _lvactive_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -1576,7 +1577,7 @@ static int _lvactivelocally_disp(struct dm_report *rh, struct dm_pool *mem,
 	} else
 		active_locally = lv_is_active(lv);
 
-	return _binary_disp(rh, mem, field, active_locally, FIRST_NAME(lv_active_locally_y), private);
+	return _binary_disp(rh, mem, field, active_locally, GET_FIRST_RESERVED_NAME(lv_active_locally_y), private);
 }
 
 static int _lvactiveremotely_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -1616,7 +1617,7 @@ static int _lvactiveremotely_disp(struct dm_report *rh, struct dm_pool *mem,
 	} else
 		active_remotely = 0;
 
-	return _binary_disp(rh, mem, field, active_remotely, FIRST_NAME(lv_active_remotely_y), private);
+	return _binary_disp(rh, mem, field, active_remotely, GET_FIRST_RESERVED_NAME(lv_active_remotely_y), private);
 }
 
 static int _lvactiveexclusively_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -1635,7 +1636,7 @@ static int _lvactiveexclusively_disp(struct dm_report *rh, struct dm_pool *mem,
 	} else
 		active_exclusively = lv_is_active(lv);
 
-	return _binary_disp(rh, mem, field, active_exclusively, FIRST_NAME(lv_active_exclusively_y), private);
+	return _binary_disp(rh, mem, field, active_exclusively, GET_FIRST_RESERVED_NAME(lv_active_exclusively_y), private);
 }
 
 static int _lvmergefailed_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -1647,10 +1648,10 @@ static int _lvmergefailed_disp(struct dm_report *rh, struct dm_pool *mem,
 	int merge_failed;
 
 	if (!lv_is_cow(lv) || !lv_snapshot_percent(lv, &snap_percent))
-		return _field_set_value(field, _str_unknown, &RESERVED(number_undef_64));
+		return _field_set_value(field, _str_unknown, &GET_TYPE_RESERVED_VALUE(number_undef_64));
 
 	merge_failed = snap_percent == LVM_PERCENT_MERGE_FAILED;
-	return _binary_disp(rh, mem, field, merge_failed, FIRST_NAME(lv_merge_failed_y), private);
+	return _binary_disp(rh, mem, field, merge_failed, GET_FIRST_RESERVED_NAME(lv_merge_failed_y), private);
 }
 
 static int _lvsnapshotinvalid_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -1662,10 +1663,10 @@ static int _lvsnapshotinvalid_disp(struct dm_report *rh, struct dm_pool *mem,
 	int snap_invalid;
 
 	if (!lv_is_cow(lv))
-		return _field_set_value(field, _str_unknown, &RESERVED(number_undef_64));
+		return _field_set_value(field, _str_unknown, &GET_TYPE_RESERVED_VALUE(number_undef_64));
 
 	snap_invalid = !lv_snapshot_percent(lv, &snap_percent) || snap_percent == DM_PERCENT_INVALID;
-	return _binary_disp(rh, mem, field, snap_invalid, FIRST_NAME(lv_snapshot_invalid_y), private);
+	return _binary_disp(rh, mem, field, snap_invalid, GET_FIRST_RESERVED_NAME(lv_snapshot_invalid_y), private);
 }
 
 static int _lvsuspended_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -1675,7 +1676,7 @@ static int _lvsuspended_disp(struct dm_report *rh, struct dm_pool *mem,
 	const struct lv_with_info_and_seg_status *lvdm = (const struct lv_with_info_and_seg_status *) data;
 
 	if (lvdm->info->exists)
-		return _binary_disp(rh, mem, field, lvdm->info->suspended, FIRST_NAME(lv_suspended_y), private);
+		return _binary_disp(rh, mem, field, lvdm->info->suspended, GET_FIRST_RESERVED_NAME(lv_suspended_y), private);
 
 	return _binary_undef_disp(rh, mem, field, private);
 }
@@ -1687,7 +1688,7 @@ static int _lvlivetable_disp(struct dm_report *rh, struct dm_pool *mem,
 	const struct lv_with_info_and_seg_status *lvdm = (const struct lv_with_info_and_seg_status *) data;
 
 	if (lvdm->info->exists)
-		return _binary_disp(rh, mem, field, lvdm->info->live_table, FIRST_NAME(lv_live_table_y), private);
+		return _binary_disp(rh, mem, field, lvdm->info->live_table, GET_FIRST_RESERVED_NAME(lv_live_table_y), private);
 
 	return _binary_undef_disp(rh, mem, field, private);
 }
@@ -1699,7 +1700,7 @@ static int _lvinactivetable_disp(struct dm_report *rh, struct dm_pool *mem,
 	const struct lv_with_info_and_seg_status *lvdm = (const struct lv_with_info_and_seg_status *) data;
 
 	if (lvdm->info->exists)
-		return _binary_disp(rh, mem, field, lvdm->info->inactive_table, FIRST_NAME(lv_inactive_table_y), private);
+		return _binary_disp(rh, mem, field, lvdm->info->inactive_table, GET_FIRST_RESERVED_NAME(lv_inactive_table_y), private);
 
 	return _binary_undef_disp(rh, mem, field, private);
 }
@@ -1711,7 +1712,7 @@ static int _lvdeviceopen_disp(struct dm_report *rh, struct dm_pool *mem,
 	const struct lv_with_info_and_seg_status *lvdm = (const struct lv_with_info_and_seg_status *) data;
 
 	if (lvdm->info->exists)
-		return _binary_disp(rh, mem, field, lvdm->info->open_count, FIRST_NAME(lv_device_open_y), private);
+		return _binary_disp(rh, mem, field, lvdm->info->open_count, GET_FIRST_RESERVED_NAME(lv_device_open_y), private);
 
 	return _binary_undef_disp(rh, mem, field, private);
 }
@@ -1723,7 +1724,7 @@ static int _thinzero_disp(struct dm_report *rh, struct dm_pool *mem,
 	const struct lv_segment *seg = (const struct lv_segment *) data;
 
 	if (seg_is_thin_pool(seg))
-		return _binary_disp(rh, mem, field, seg->zero_new_blocks, FIRST_NAME(zero_y), private);
+		return _binary_disp(rh, mem, field, seg->zero_new_blocks, GET_FIRST_RESERVED_NAME(zero_y), private);
 
 	return _binary_undef_disp(rh, mem, field, private);
 }
@@ -1774,7 +1775,7 @@ static int _cache_ ## cache_status_field_name ## _disp (struct dm_report *rh, \
 { \
 	const struct lv_with_info_and_seg_status *lvdm = (const struct lv_with_info_and_seg_status *) data; \
 	if (lvdm->seg_status->type != SEG_STATUS_CACHE) \
-		return _field_set_value(field, "", &RESERVED(number_undef_64)); \
+		return _field_set_value(field, "", &GET_TYPE_RESERVED_VALUE(number_undef_64)); \
 	return dm_report_field_uint64(rh, field, (void *) ((char *) lvdm->seg_status->status + offsetof(struct dm_status_cache, cache_status_field_name))); \
 }
 
diff --git a/lib/report/values.h b/lib/report/values.h
index b0382c0..adf22b3 100644
--- a/lib/report/values.h
+++ b/lib/report/values.h
@@ -56,7 +56,7 @@ FIELD_RESERVED_BINARY_VALUE(vg_partial, vg_partial, "", "partial")
 FIELD_RESERVED_BINARY_VALUE(vg_clustered, vg_clustered, "", "clustered")
 FIELD_RESERVED_VALUE(vg_permissions, vg_permissions_rw, "", "writeable", "writeable", "rw", "read-write")
 FIELD_RESERVED_VALUE(vg_permissions, vg_permissions_r, "", "read-only", "read-only", "r", "ro")
-FIELD_RESERVED_VALUE(vg_mda_copies, vg_mda_copies, "", &RESERVED(number_undef_64), "unmanaged")
+FIELD_RESERVED_VALUE(vg_mda_copies, vg_mda_copies, "", &GET_TYPE_RESERVED_VALUE(number_undef_64), "unmanaged")
 
 /* Reserved values for LV fields */
 FIELD_RESERVED_BINARY_VALUE(lv_initial_image_sync, lv_initial_image_sync, "", "initial image sync", "sync")
@@ -79,7 +79,7 @@ FIELD_RESERVED_BINARY_VALUE(zero, zero, "", "zero")
 FIELD_RESERVED_VALUE(lv_permissions, lv_permissions_rw, "", "writeable", "writeable", "rw", "read-write")
 FIELD_RESERVED_VALUE(lv_permissions, lv_permissions_r, "", "read-only", "read-only", "r", "ro")
 FIELD_RESERVED_VALUE(lv_permissions, lv_permissions_r_override, "", "read-only-override", "read-only-override", "ro-override", "r-override", "R")
-FIELD_RESERVED_VALUE(lv_read_ahead, lv_read_ahead, "", &RESERVED(number_undef_64), "auto")
+FIELD_RESERVED_VALUE(lv_read_ahead, lv_read_ahead, "", &GET_TYPE_RESERVED_VALUE(number_undef_64), "auto")
 
 /* Reserved values for SEG fields */
 FIELD_RESERVED_VALUE(cache_policy, cache_policy_undef, "", "undefined", "undefined")


