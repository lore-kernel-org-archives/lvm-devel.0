From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 17 Jun 2014 14:34:32 +0000 (UTC)
Subject: master - report: select: add support for reserved value recognition in report selection string - add struct dm_report_reserved_value
Message-ID: <20140617143432.F3D7F60C4E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=35c4e4489c9eef22691332b43e51b03055e4fe92
Commit:        35c4e4489c9eef22691332b43e51b03055e4fe92
Parent:        a075ec15c4a8e704fbb9519326d0c97371ead2f3
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri May 30 15:02:21 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Jun 17 16:27:21 2014 +0200

report: select: add support for reserved value recognition in report selection string - add struct dm_report_reserved_value

Make dm_report_init_with_selection to accept an argument with an
array of reserved values where each element contains a triple:

  {dm report field type, reserved value, array of strings representing this value}

When the selection is parsed, we always check whether a string
representation of some reserved value is not hit and if it is,
we use the reserved value assigned for this string instead of
trying to parse it as a value of certain field type.

This makes it possible to define selections like:

   ... --select lv_major=undefined (or -1 or unknown or undef or whatever string representations are registered for this reserved value in the future)
   ... --select lv_read_ahead=auto
   ... --select vg_mda_copies=unmanaged

With this, each time the field value of certain type is hit
and when we compare it with the selection, we use the proper
value for comparison.

For now, register these reserved values that are used at the moment
(also more descriptive names are used for the values):

  const uint64_t _reserved_number_undef_64 = UINT64_MAX;
  const uint64_t _reserved_number_unmanaged_64 = UINT64_MAX - 1;
  const uint64_t _reserved_size_auto_64 = UINT64_MAX;

 {
  {DM_REPORT_FIELD_TYPE_NUMBER, _reserved_number_undef_64, {"-1", "undefined", "undef", "unknown", NULL}},
  {DM_REPORT_FIELD_TYPE_NUMBER, _reserved_number_unmanaged_64, {"unmanaged", NULL}},
  {DM_REPORT_FIELD_TYPE_SIZE, _reserved_size_auto_64, {"auto", NULL}},
  NULL
 }

Same reserved value of different field types do not collide.
All arrays are null-terminated.

The list of reserved values is automatically displayed within
selection help output:

  Selection operands
  ------------------
  ...

  Reserved values
  ---------------
    -1, undefined, undef, unknown   - Reserved value for undefined numeric value. [number]
    unmanaged                       - Reserved value for unmanaged number of metadata copies in VG. [number]
    auto                            - Reserved value for size that is automatically calculated. [size]

  Selection operators
  -------------------
  ...
---
 lib/report/report.c  |   72 +++++++++++------
 libdm/libdevmapper.h |   11 +++
 libdm/libdm-report.c |  226 ++++++++++++++++++++++++++++++++++++++++++++++----
 tools/dmsetup.c      |    2 +-
 4 files changed, 268 insertions(+), 43 deletions(-)

diff --git a/lib/report/report.c b/lib/report/report.c
index e8ff5bb..7f509e1 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -37,10 +37,33 @@ struct lvm_report_object {
 };
 
 static const uint64_t _hundred64 = UINT64_C(100);
-static const uint64_t _minusone64 = UINT64_C(-1);
-static const int32_t _minusone32 = INT32_C(-1);
 static const uint64_t _zero64 = UINT64_C(0);
 
+static const uint64_t _reserved_number_undef_64 = UINT64_C(-1);
+static const uint64_t _reserved_number_unmanaged_64 = UINT64_C(-2);
+static const uint64_t _reserved_size_auto_64 = UINT64_C(-1);
+
+/*
+ * 32 bit signed is casted to 64 bit unsigned in dm_report_field internally!
+ * So when stored in the struct, the _reserved_number_undef_32 is actually
+ * equal to _reserved_number_undef_64.
+ */
+static const int32_t _reserved_number_undef_32 = INT32_C(-1);
+
+static const char const *_reserved_number_undef_64_names[]={"-1", "undefined", "undef", "unknown", NULL};
+static const char const *_reserved_number_unmanaged_64_names[]={"unmanaged", NULL};
+static const char const *_reserved_size_auto_64_names[]={"auto", NULL};
+
+static const struct dm_report_reserved_value _report_reserved_values[] = {
+	{DM_REPORT_FIELD_TYPE_NUMBER, &_reserved_number_undef_64, _reserved_number_undef_64_names,
+		"Reserved value for undefined numeric value."},
+	{DM_REPORT_FIELD_TYPE_NUMBER, &_reserved_number_unmanaged_64, _reserved_number_unmanaged_64_names,
+		"Reserved value for unmanaged number of metadata copies in VG."},
+	{DM_REPORT_FIELD_TYPE_SIZE, &_reserved_size_auto_64, _reserved_size_auto_64_names,
+		"Reserved value for size that is automatically calculated."},
+	{0, NULL, NULL}
+};
+
 static int _field_set_value(struct dm_report_field *field, const void *data, const void *sort)
 {
 	dm_report_field_set_value(field, data, sort);
@@ -56,7 +79,7 @@ static int _field_set_percent(struct dm_report_field *field,
 	uint64_t *sortval;
 
 	if (percent == PERCENT_INVALID)
-		return _field_set_value(field, "", &_minusone64);
+		return _field_set_value(field, "", &_reserved_number_undef_64);
 
 	if (!(repstr = dm_pool_alloc(mem, 8)) ||
 	    !(sortval = dm_pool_alloc(mem, sizeof(uint64_t)))) {
@@ -203,7 +226,7 @@ static int _lvkmaj_disp(struct dm_report *rh, struct dm_pool *mem __attribute__(
 	if ((major = lv_kernel_major(lv)) >= 0)
 		return dm_report_field_int(rh, field, &major);
 
-	return dm_report_field_int32(rh, field, &_minusone32);
+	return dm_report_field_int32(rh, field, &_reserved_number_undef_32);
 }
 
 static int _lvkmin_disp(struct dm_report *rh, struct dm_pool *mem __attribute__((unused)),
@@ -216,7 +239,7 @@ static int _lvkmin_disp(struct dm_report *rh, struct dm_pool *mem __attribute__(
 	if ((minor = lv_kernel_minor(lv)) >= 0)
 		return dm_report_field_int(rh, field, &minor);
 
-	return dm_report_field_int32(rh, field, &_minusone32);
+	return dm_report_field_int32(rh, field, &_reserved_number_undef_32);
 }
 
 static int _lvstatus_disp(struct dm_report *rh __attribute__((unused)), struct dm_pool *mem,
@@ -502,7 +525,7 @@ static int _lvreadahead_disp(struct dm_report *rh, struct dm_pool *mem,
 	const struct logical_volume *lv = (const struct logical_volume *) data;
 
 	if (lv->read_ahead == DM_READ_AHEAD_AUTO)
-		return _field_set_value(field, "auto", &_minusone64);
+		return _field_set_value(field, "auto", &_reserved_size_auto_64);
 
 	return _size32_disp(rh, mem, field, &lv->read_ahead, private);
 }
@@ -516,7 +539,7 @@ static int _lvkreadahead_disp(struct dm_report *rh, struct dm_pool *mem,
 	uint32_t read_ahead = lv_kernel_read_ahead(lv);
 
 	if (read_ahead == UINT32_MAX)
-		return dm_report_field_int32(rh, field, &_minusone32);
+		return dm_report_field_int32(rh, field, &_reserved_number_undef_32);
 
 	return _size32_disp(rh, mem, field, &read_ahead, private);
 }
@@ -604,7 +627,7 @@ static int _thinzero_disp(struct dm_report *rh, struct dm_pool *mem,
 	if (seg_is_thin_pool(seg))
 		return _uint32_disp(rh, mem, field, &seg->zero_new_blocks, private);
 
-	return _field_set_value(field, "", &_minusone64);
+	return _field_set_value(field, "", &_reserved_number_undef_64);
 }
 
 static int _transactionid_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -616,7 +639,7 @@ static int _transactionid_disp(struct dm_report *rh, struct dm_pool *mem,
 	if (seg_is_thin_pool(seg))
 		return dm_report_field_uint64(rh, field, &seg->transaction_id);
 
-	return _field_set_value(field, "", &_minusone64);
+	return _field_set_value(field, "", &_reserved_number_undef_64);
 }
 
 static int _thinid_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -628,7 +651,7 @@ static int _thinid_disp(struct dm_report *rh, struct dm_pool *mem,
 	if (seg_is_thin_volume(seg))
 		return dm_report_field_uint32(rh, field, &seg->device_id);
 
-	return _field_set_value(field, "", &_minusone64);
+	return _field_set_value(field, "", &_reserved_number_undef_64);
 }
 
 static int _discards_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -794,7 +817,7 @@ static int _vgmdacopies_disp(struct dm_report *rh, struct dm_pool *mem,
 	uint32_t count = vg_mda_copies(vg);
 
 	if (count == VGMETADATACOPIES_UNMANAGED)
-		return _field_set_value(field, "unmanaged", &_minusone64);
+		return _field_set_value(field, "unmanaged", &_reserved_number_unmanaged_64);
 
 	return _uint32_disp(rh, mem, field, &count, private);
 }
@@ -903,7 +926,7 @@ static int _snpercent_disp(struct dm_report *rh __attribute__((unused)), struct
 		 */
 	}
 
-	return _field_set_value(field, "", &_minusone64);
+	return _field_set_value(field, "", &_reserved_number_undef_64);
 }
 
 static int _copypercent_disp(struct dm_report *rh __attribute__((unused)),
@@ -923,7 +946,7 @@ static int _copypercent_disp(struct dm_report *rh __attribute__((unused)),
 		return _field_set_percent(field, mem, percent);
 	}
 
-	return _field_set_value(field, "", &_minusone64);
+	return _field_set_value(field, "", &_reserved_number_undef_64);
 }
 
 static int _raidsyncaction_disp(struct dm_report *rh __attribute__((unused)),
@@ -953,7 +976,7 @@ static int _raidmismatchcount_disp(struct dm_report *rh __attribute__((unused)),
 	if (lv_is_raid(lv) && lv_raid_mismatch_count(lv, &mismatch_count))
 		return dm_report_field_uint64(rh, field, &mismatch_count);
 
-	return _field_set_value(field, "", &_minusone64);
+	return _field_set_value(field, "", &_reserved_number_undef_64);
 }
 
 static int _raidwritebehind_disp(struct dm_report *rh __attribute__((unused)),
@@ -967,7 +990,7 @@ static int _raidwritebehind_disp(struct dm_report *rh __attribute__((unused)),
 	if (lv_is_raid_type(lv) && first_seg(lv)->writebehind)
 		return dm_report_field_uint32(rh, field, &first_seg(lv)->writebehind);
 
-	return _field_set_value(field, "", &_minusone64);
+	return _field_set_value(field, "", &_reserved_number_undef_64);
 }
 
 static int _raidminrecoveryrate_disp(struct dm_report *rh __attribute__((unused)),
@@ -982,7 +1005,7 @@ static int _raidminrecoveryrate_disp(struct dm_report *rh __attribute__((unused)
 		return dm_report_field_uint32(rh, field,
 					      &first_seg(lv)->min_recovery_rate);
 
-	return _field_set_value(field, "", &_minusone64);
+	return _field_set_value(field, "", &_reserved_number_undef_64);
 }
 
 static int _raidmaxrecoveryrate_disp(struct dm_report *rh __attribute__((unused)),
@@ -997,7 +1020,7 @@ static int _raidmaxrecoveryrate_disp(struct dm_report *rh __attribute__((unused)
 		return dm_report_field_uint32(rh, field,
 					      &first_seg(lv)->max_recovery_rate);
 
-	return _field_set_value(field, "", &_minusone64);
+	return _field_set_value(field, "", &_reserved_number_undef_64);
 }
 
 /* Called only with lv_is_thin_pool/volume */
@@ -1011,7 +1034,7 @@ static int _dtpercent_disp(int metadata, struct dm_pool *mem,
 	/* Suppress data percent if not using driver */
 	/* cannot use lv_is_active_locally - need to check for layer -tpool */
 	if (!lv_info(lv->vg->cmd, lv, 1, NULL, 0, 0))
-		return _field_set_value(field, "",  &_minusone64);
+		return _field_set_value(field, "",  &_reserved_number_undef_64);
 
 	if (lv_is_thin_pool(lv)) {
 		if (!lv_thin_pool_percent(lv, metadata, &percent))
@@ -1036,7 +1059,7 @@ static int _datapercent_disp(struct dm_report *rh, struct dm_pool *mem,
 	if (lv_is_thin_pool(lv) || lv_is_thin_volume(lv))
 		return _dtpercent_disp(0, mem, field, data, private);
 
-	return _field_set_value(field, "", &_minusone64);
+	return _field_set_value(field, "", &_reserved_number_undef_64);
 }
 
 static int _metadatapercent_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -1048,7 +1071,7 @@ static int _metadatapercent_disp(struct dm_report *rh, struct dm_pool *mem,
 	if (lv_is_thin_pool(lv))
 		return _dtpercent_disp(1, mem, field, data, private);
 
-	return _field_set_value(field, "", &_minusone64);
+	return _field_set_value(field, "", &_reserved_number_undef_64);
 }
 
 static int _lvmetadatasize_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -1063,7 +1086,7 @@ static int _lvmetadatasize_disp(struct dm_report *rh, struct dm_pool *mem,
 		return _size64_disp(rh, mem, field, &size, private);
 	}
 
-	return _field_set_value(field, "", &_minusone64);
+	return _field_set_value(field, "", &_reserved_number_undef_64);
 }
 
 static int _thincount_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -1078,7 +1101,7 @@ static int _thincount_disp(struct dm_report *rh, struct dm_pool *mem,
 		return _uint32_disp(rh, mem, field, &count, private);
 	}
 
-	return _field_set_value(field, "", &_minusone64);
+	return _field_set_value(field, "", &_reserved_number_undef_64);
 }
 
 static int _lvtime_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -1264,8 +1287,9 @@ void *report_init(struct cmd_context *cmd, const char *format, const char *keys,
 
 	rh = dm_report_init_with_selection(report_type,
 		devtypes_report ? _devtypes_report_types : _report_types,
-		devtypes_report ? _devtypes_fields : _fields, format,
-		separator, report_flags, keys, selection, cmd);
+		devtypes_report ? _devtypes_fields : _fields,
+		format, separator, report_flags, keys,
+		selection, _report_reserved_values, cmd);
 
 	if (rh && field_prefixes)
 		dm_report_set_output_field_name_prefix(rh, "lvm2_");
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index d256373..0dae981 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -1631,6 +1631,16 @@ struct dm_report_field_type {
 	const char *desc;	/* description of the field */
 };
 
+struct dm_report_reserved_value {
+	const unsigned type;		/* DM_REPORT_FIELD_TYPE_* */
+	const void const *value;	/* reserved value:
+						uint64_t for DM_REPORT_FIELD_TYPE_NUMBER
+						uint64_t for DM_REPORT_FIELD_TYPE_SIZE (number of 512-byte sectors)
+						const char * for DM_REPORT_FIELD_TYPE_STRING */
+	const char **names;		/* null-terminated array of names for this reserved value */
+	const char *description;	/* description of the reserved value */
+};
+
 /*
  * dm_report_init output_flags
  */
@@ -1658,6 +1668,7 @@ struct dm_report *dm_report_init_with_selection(uint32_t *report_types,
 						uint32_t output_flags,
 						const char *sort_keys,
 						const char *selection,
+						const struct dm_report_reserved_value reserved_values[],
 						void *private_data);
 int dm_report_object(struct dm_report *rh, void *object);
 int dm_report_set_output_selection(struct dm_report *rh, uint32_t *report_types,
diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 1c35166..aa640de 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -52,6 +52,8 @@ struct dm_report {
 	void *private;
 
 	struct selection_node *selection_root;
+	/* Null-terminated array of reserved values */
+	const struct dm_report_reserved_value *reserved_values;
 };
 
 /*
@@ -1412,6 +1414,102 @@ static const char *_tok_value_string(const char *s,
 }
 
 /*
+ * Used to replace a string representation of the reserved value
+ * found in selection with the exact reserved value of certain type.
+ */
+static const char *_get_reserved_value(struct dm_report *rh, unsigned type,
+				       const char *s, const char **begin, const char **end,
+				       const struct dm_report_reserved_value **reserved)
+{
+	const struct dm_report_reserved_value *iter = rh->reserved_values;
+	const char **name;
+
+	*reserved = NULL;
+
+	if (!iter)
+		return s;
+
+	while (iter->type) {
+		if (iter->type & type) {
+			name = iter->names;
+			while (*name) {
+				if (!strcmp(*name, s)) {
+					*begin = s;
+					*end = s += strlen(*name);
+					*reserved = iter;
+					return s;
+				}
+				name++;
+			}
+		}
+		iter++;
+	}
+
+	return s;
+}
+
+/*
+ * Used to check whether a value of certain type used in selection is reserved.
+ */
+static int _check_value_is_reserved(struct dm_report *rh, unsigned type, const void *value)
+{
+	const struct dm_report_reserved_value *iter = rh->reserved_values;
+
+	if (!iter)
+		return 0;
+
+	while (iter->type) {
+		if (iter->type & type) {
+			switch (type) {
+				case DM_REPORT_FIELD_TYPE_NUMBER:
+					if (*(uint64_t *)iter->value == *(uint64_t *)value)
+						return 1;
+					break;
+				case DM_REPORT_FIELD_TYPE_STRING:
+					if (!strcmp((const char *)iter->value, (const char *) value))
+						return 1;
+					break;
+				case DM_REPORT_FIELD_TYPE_SIZE:
+					if (_close_enough(*(double *)iter->value, *(double *) value))
+						return 1;
+					break;
+				case DM_REPORT_FIELD_TYPE_STRING_LIST:
+					// TODO: add comparison for string list
+					break;
+			}
+		}
+		iter++;
+	}
+
+	return 0;
+}
+
+/*
+ * Used to check whether the reserved_values definition passed to
+ * dm_report_init_with_selection contains only supported reserved value types.
+ */
+static int _check_reserved_values_supported(const struct dm_report_reserved_value reserved_values[])
+{
+	const struct dm_report_reserved_value *iter;
+	static uint32_t supported_reserved_types = DM_REPORT_FIELD_TYPE_NUMBER |
+						   DM_REPORT_FIELD_TYPE_SIZE |
+						   DM_REPORT_FIELD_TYPE_STRING;
+
+	if (!reserved_values)
+		return 1;
+
+	iter = reserved_values;
+
+	while (iter->type) {
+		if (!(iter->type & supported_reserved_types))
+			return 0;
+		iter++;
+	}
+
+	return 1;
+}
+
+/*
  * Input:
  *   ft              - field type for which the value is parsed
  *   s               - a pointer to the parsed string
@@ -1420,11 +1518,14 @@ static const char *_tok_value_string(const char *s,
  *   end             - a pointer to the end of the token + 1
  *   flags           - parsing flags
  */
-static const char *_tok_value_regex(const struct dm_report_field_type *ft,
+static const char *_tok_value_regex(struct dm_report *rh,
+				    const struct dm_report_field_type *ft,
 				    const char *s, const char **begin,
-				    const char **end, uint32_t *flags)
+				    const char **end, uint32_t *flags,
+				    const struct dm_report_reserved_value **reserved)
 {
 	char c;
+	*reserved = NULL;
 
 	s = _skip_space(s);
 
@@ -1628,9 +1729,11 @@ bad:
  *   custom          - custom data specific to token type
  *                     (e.g. size unit factor)
  */
-static const char *_tok_value(const struct dm_report_field_type *ft,
+static const char *_tok_value(struct dm_report *rh,
+			      const struct dm_report_field_type *ft,
 			      const char *s, const char **begin,
 			      const char **end, uint32_t *flags,
+			      const struct dm_report_reserved_value **reserved,
 			      struct dm_pool *mem, void *custom)
 {
 	int expected_type = ft->flags & DM_REPORT_FIELD_TYPE_MASK;
@@ -1641,6 +1744,12 @@ static const char *_tok_value(const struct dm_report_field_type *ft,
 
 	s = _skip_space(s);
 
+	s = _get_reserved_value(rh, expected_type, s, begin, end, reserved);
+	if (*reserved) {
+		*flags |= expected_type;
+		return s;
+	}
+
 	switch (expected_type) {
 
 		case DM_REPORT_FIELD_TYPE_STRING:
@@ -1728,6 +1837,7 @@ static struct field_selection *_create_field_selection(struct dm_report *rh,
 						       const char *v,
 						       size_t len,
 						       uint32_t flags,
+						       const struct dm_report_reserved_value *reserved,
 						       void *custom)
 {
 	static const char *_out_of_range_msg = "Field selection value %s out of supported range for field %s.";
@@ -1798,29 +1908,58 @@ static struct field_selection *_create_field_selection(struct dm_report *rh,
 
 		switch (flags & DM_REPORT_FIELD_TYPE_MASK) {
 			case DM_REPORT_FIELD_TYPE_STRING:
-				fs->v.s = s;
+				if (reserved) {
+					fs->v.s = (const char *) reserved->value;
+					dm_pool_free(rh->mem, s);
+				} else {
+					fs->v.s = s;
+					if (_check_value_is_reserved(rh, DM_REPORT_FIELD_TYPE_STRING, fs->v.s)) {
+						log_error("String value %s found in selection is reserved.", fs->v.s);
+						goto error;
+					}
+				}
 				break;
 			case DM_REPORT_FIELD_TYPE_NUMBER:
-				if (((fs->v.i = strtoull(s, NULL, 10)) == ULLONG_MAX) &&
-				    (errno == ERANGE)) {
-					log_error(_out_of_range_msg, s, field_id);
-					goto error;
+				if (reserved)
+					fs->v.i = *(uint64_t *) reserved->value;
+				else {
+					if (((fs->v.i = strtoull(s, NULL, 10)) == ULLONG_MAX) &&
+						 (errno == ERANGE)) {
+						log_error(_out_of_range_msg, s, field_id);
+						goto error;
+					}
+					if (_check_value_is_reserved(rh, DM_REPORT_FIELD_TYPE_NUMBER, &fs->v.i)) {
+						log_error("Numeric value %" PRIu64 " found in selection is reserved.", fs->v.i);
+						goto error;
+					}
 				}
 				dm_pool_free(rh->mem, s);
 				break;
 			case DM_REPORT_FIELD_TYPE_SIZE:
-				fs->v.d = strtod(s, NULL);
-				if (errno == ERANGE) {
-					log_error(_out_of_range_msg, s, field_id);
-					goto error;
+				if (reserved)
+					fs->v.d = (double) * (uint64_t *) reserved->value;
+				else {
+					fs->v.d = strtod(s, NULL);
+					if (errno == ERANGE) {
+						log_error(_out_of_range_msg, s, field_id);
+						goto error;
+					}
+					if (custom && (factor = *((uint64_t *)custom)))
+						fs->v.d *= factor;
+					fs->v.d /= 512; /* store size in sectors! */
+					if (_check_value_is_reserved(rh, DM_REPORT_FIELD_TYPE_SIZE, &fs->v.d)) {
+						log_error("Size value %f found in selection is reserved.", fs->v.d);
+						goto error;
+					}
 				}
-				if (custom && (factor = *((uint64_t *)custom)))
-					fs->v.d *= factor;
-				fs->v.d /= 512; /* store size in sectors! */
 				dm_pool_free(rh->mem, s);
 				break;
 			case DM_REPORT_FIELD_TYPE_STRING_LIST:
 				fs->v.l = *(struct selection_str_list **)custom;
+				if (_check_value_is_reserved(rh, DM_REPORT_FIELD_TYPE_STRING_LIST, fs->v.l)) {
+					log_error("String list value found in selection is reserved.");
+					goto error;
+				}
 				break;
 			default:
 				log_error(INTERNAL_ERROR "_create_field_selection: "
@@ -1854,7 +1993,12 @@ static struct selection_node *_alloc_selection_node(struct dm_pool *mem, uint32_
 
 static void _display_selection_help(struct dm_report *rh)
 {
+	static const char _grow_object_failed_msg[] = "_display_selection_help: dm_pool_grow_object failed";
 	struct op_def *t;
+	const struct dm_report_reserved_value *rv;
+	size_t len_all, len_final = 0;
+	const char **rvs;
+	char *rvs_all;
 
 	log_warn("Selection operands");
 	log_warn("------------------");
@@ -1866,6 +2010,42 @@ static void _display_selection_help(struct dm_report *rh)
 	log_warn("                        \"all items must match\" or \"at least one item must match\" operator.");
 	log_warn("  regular expression  - Characters quoted by \' or \" or unquoted.");
 	log_warn(" ");
+	if (rh->reserved_values) {
+		log_warn("Reserved values");
+		log_warn("---------------");
+
+		for (rv = rh->reserved_values; rv->type; rv++) {
+			for (len_all = 0, rvs = rv->names; *rvs; rvs++)
+				len_all += strlen(*rvs) + 2;
+			if (len_all > len_final)
+				len_final = len_all;
+		}
+
+		for (rv = rh->reserved_values; rv->type; rv++) {
+			if (!dm_pool_begin_object(rh->mem, 256)) {
+				log_error("_display_selection_help: dm_pool_begin_object failed");
+				break;
+			}
+			for (rvs = rv->names; *rvs; rvs++) {
+				if (((rvs != rv->names) && !dm_pool_grow_object(rh->mem, ", ", 2)) ||
+				    !dm_pool_grow_object(rh->mem, *rvs, strlen(*rvs))) {
+					log_error(_grow_object_failed_msg);
+					goto out_reserved_values;
+				}
+			}
+			if (!dm_pool_grow_object(rh->mem, "\0", 1)) {
+				log_error(_grow_object_failed_msg);
+				goto out_reserved_values;
+			}
+			rvs_all = dm_pool_end_object(rh->mem);
+
+			log_warn("  %-*s - %s [%s]", (int) len_final, rvs_all, rv->description,
+						     _get_field_type_name(rv->type));
+			dm_pool_free(rh->mem, rvs_all);
+		}
+		log_warn(" ");
+	}
+out_reserved_values:
 	log_warn("Selection operators");
 	log_warn("-------------------");
 	log_warn("  Comparison operators:");
@@ -1913,6 +2093,7 @@ static struct selection_node *_parse_selection(struct dm_report *rh,
 	uint32_t flags, field_num;
 	const struct dm_report_field_type *ft;
 	struct selection_str_list *str_list;
+	const struct dm_report_reserved_value *reserved;
 	uint64_t factor;
 	void *custom;
 	char *tmp;
@@ -1961,7 +2142,7 @@ static struct selection_node *_parse_selection(struct dm_report *rh,
 
 	/* comparison value */
 	if (flags & FLD_CMP_REGEX) {
-		if (!(last = _tok_value_regex(ft, last, &vs, &ve, &flags)))
+		if (!(last = _tok_value_regex(rh, ft, last, &vs, &ve, &flags, &reserved)))
 			goto_bad;
 	} else {
 		if (ft->flags == DM_REPORT_FIELD_TYPE_SIZE ||
@@ -1971,14 +2152,14 @@ static struct selection_node *_parse_selection(struct dm_report *rh,
 			custom = &str_list;
 		else
 			custom = NULL;
-		if (!(last = _tok_value(ft, last, &vs, &ve, &flags, rh->mem, custom)))
+		if (!(last = _tok_value(rh, ft, last, &vs, &ve, &flags, &reserved, rh->mem, custom)))
 			goto_bad;
 	}
 
 	*next = _skip_space(last);
 
 	/* create selection */
-	if (!(fs = _create_field_selection(rh, field_num, vs, (size_t) (ve - vs), flags, custom)))
+	if (!(fs = _create_field_selection(rh, field_num, vs, (size_t) (ve - vs), flags, reserved, custom)))
 		return_NULL;
 
 	/* create selection node */
@@ -2119,6 +2300,7 @@ struct dm_report *dm_report_init_with_selection(uint32_t *report_types,
 						uint32_t output_flags,
 						const char *sort_keys,
 						const char *selection,
+						const struct dm_report_reserved_value reserved_values[],
 						void *private_data)
 {
 	struct dm_report *rh;
@@ -2134,6 +2316,14 @@ struct dm_report *dm_report_init_with_selection(uint32_t *report_types,
 		return rh;
 	}
 
+	if (!_check_reserved_values_supported(reserved_values)) {
+		log_error(INTERNAL_ERROR "dm_report_init_with_selection: "
+			  "trying to register unsupported reserved value type, "
+			  "skipping report selection");
+		return rh;
+	}
+	rh->reserved_values = reserved_values;
+
 	if (!strcasecmp(selection, DM_REPORT_FIELD_RESERVED_NAME_HELP) ||
 	    !strcmp(selection, DM_REPORT_FIELD_RESERVED_NAME_HELP_ALT)) {
 		_display_fields(rh, 0, 1);
diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 1a5e068..454141e 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -2934,7 +2934,7 @@ static int _report_init(const struct command *cmd)
 
 	if (!(_report = dm_report_init_with_selection(&_report_type, _report_types,
 				_report_fields, options, separator, flags, keys,
-				selection, NULL)))
+				selection, NULL, NULL)))
 		goto out;
 
 	if ((_report_type & DR_TREE) && !_build_whole_deptree(cmd)) {


