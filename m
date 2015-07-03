From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri,  3 Jul 2015 09:32:34 +0000 (UTC)
Subject: master - report: add infrastructure to recognize fuzzy reserved names and returning dynamic reserved values
Message-ID: <20150703093235.075B2610D9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=335707b0e2e657a40ae87fb47dbf744cb53d74fb
Commit:        335707b0e2e657a40ae87fb47dbf744cb53d74fb
Parent:        82ecfa6f0eea0e09dadc9b6e32f6d1359152997f
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue May 19 13:01:48 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Jul 3 10:47:09 2015 +0200

report: add infrastructure to recognize fuzzy reserved names and returning dynamic reserved values

With fuzzy names we mean the names for which it's hard or even impossible
to enumerate all possible variations of the name - the name needs to
be evaluated. An example of fuzzy name is a name which has a base
(substring) which matches and it can contain arbitrary variations
around this base. We can cover human language better with fuzzy
names as people may use several different names (or sentences) to
denote the same thing.

With dynamic values we mean the values which are not constants
and they need to be evaluated in runtime. An example of dynamic
value is a value which depends on current system state (e.g. time,
current configuration or any other state which may change and it
needs runtime evaluation).

There's a handler that can be registered with reporting/selection
using dm_report_reserved_handler instance. This is a central point
in which the computation/evaluation happens when processing reserved
values. Currently, there are two actions declared:

  DM_REPORT_RESERVED_PARSE_FUZZY_NAME
  (translates fuzzy name into canonical name)

  DM_REPORT_RESERVED_GET_DYNAMIC_VALUE
  (gets value for canonical name)

The handler is then registered as value in struct
dm_report_reserved_value (see explaining comments besided
the struct dm_report_reserved_value in libdevmapper.h).

Also, this patch provides support for simple caching of values
used during report/selection via dm_report_value_cache_{set,get}.
This is supposed to be used mainly in the dm_report_reserved_handler
instances to save values among calls so all the handler calls work
with the same base value used in computation/evaluation and/or
possibly to save resources if the evaluation is more time-consuming.
The cache is attached to the dm_report handle and so the cache is
dropped one dm_report is dropped.
---
 WHATS_NEW_DM                        |    4 ++
 lib/report/report.c                 |    8 +++++
 libdm/.exported_symbols.DM_1_02_101 |    2 +
 libdm/libdevmapper.h                |   54 ++++++++++++++++++++++++++++++++--
 libdm/libdm-report.c                |   18 +++++++++++
 5 files changed, 82 insertions(+), 4 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 38045d6..5e1f25f 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,9 @@
 Version 1.02.101 -
 =================================
+  Add dm_report_value_cache_{set,get} to support caching during report/select.
+  Add dm_report_reserved_handler to handle report reserved value actions.
+  Support dynamic value in select: DM_REPORT_FIELD_RESERVED_VALUE_DYNAMIC_VALUE.
+  Support fuzzy names in select: DM_REPORT_FIELD_RESERVED_VALUE_FUZZY_NAMES.
   Thin pool trace messages show a device name and major:minor.
 
 Version 1.02.100 - 30th June 2015
diff --git a/lib/report/report.c b/lib/report/report.c
index 40f947f..2e9a5d3 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -99,6 +99,8 @@ static const int32_t _reserved_num_undef_32 = INT32_C(-1);
 #define NOFLAG 0
 #define NAMED DM_REPORT_FIELD_RESERVED_VALUE_NAMED
 #define RANGE DM_REPORT_FIELD_RESERVED_VALUE_RANGE
+#define FUZZY DM_REPORT_FIELD_RESERVED_VALUE_FUZZY_NAMES
+#define DYNAMIC DM_REPORT_FIELD_RESERVED_VALUE_DYNAMIC_VALUE
 
 #define TYPE_RESERVED_VALUE(type, flags, id, desc, value, ...) \
 	static const char *_reserved_ ## id ## _names[] = { __VA_ARGS__, NULL}; \
@@ -121,6 +123,8 @@ static const int32_t _reserved_num_undef_32 = INT32_C(-1);
 #undef TYPE_RESERVED_VALUE
 #undef FIELD_RESERVED_VALUE
 #undef FIELD_RESERVED_BINARY_VALUE
+#undef FUZZY
+#undef DYNAMIC
 
 /*
  * Create array of reserved values to be registered with reporting code via
@@ -133,6 +137,8 @@ static const int32_t _reserved_num_undef_32 = INT32_C(-1);
 #define NOFLAG 0
 #define NAMED DM_REPORT_FIELD_RESERVED_VALUE_NAMED
 #define RANGE DM_REPORT_FIELD_RESERVED_VALUE_RANGE
+#define FUZZY DM_REPORT_FIELD_RESERVED_VALUE_FUZZY_NAMES
+#define DYNAMIC DM_REPORT_FIELD_RESERVED_VALUE_DYNAMIC_VALUE
 
 #define TYPE_RESERVED_VALUE(type, flags, id, desc, value, ...) {type | flags, &_reserved_ ## id, _reserved_ ## id ## _names, desc},
 
@@ -151,6 +157,8 @@ static const struct dm_report_reserved_value _report_reserved_values[] = {
 #undef NOFLAG
 #undef NAMED
 #undef RANGE
+#undef FUZZY
+#undef DYNAMIC
 #undef TYPE_RESERVED_VALUE
 #undef FIELD_RESERVED_VALUE
 #undef FIELD_RESERVED_BINARY_VALUE
diff --git a/libdm/.exported_symbols.DM_1_02_101 b/libdm/.exported_symbols.DM_1_02_101
new file mode 100644
index 0000000..75089ba
--- /dev/null
+++ b/libdm/.exported_symbols.DM_1_02_101
@@ -0,0 +1,2 @@
+dm_report_value_cache_set
+dm_report_value_cache_get
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 7e30d8e..4ce2e6b 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -1688,6 +1688,8 @@ struct dm_report_field;
 #define DM_REPORT_FIELD_RESERVED_VALUE_MASK		0x0000000F
 #define DM_REPORT_FIELD_RESERVED_VALUE_NAMED		0x00000001 /* only named value, less strict form of reservation */
 #define DM_REPORT_FIELD_RESERVED_VALUE_RANGE		0x00000002 /* value is range - low and high value defined */
+#define DM_REPORT_FIELD_RESERVED_VALUE_DYNAMIC_VALUE	0x00000004 /* value is computed in runtime */
+#define DM_REPORT_FIELD_RESERVED_VALUE_FUZZY_NAMES	0x00000008 /* value names are recognized in runtime */
 
 #define DM_REPORT_FIELD_TYPE_ID_LEN 32
 #define DM_REPORT_FIELD_TYPE_HEADING_LEN 32
@@ -1721,7 +1723,8 @@ struct dm_report_field_reserved_value {
 };
 
 /*
- * Reserved value is a 'value' that is used directly if any of the 'names' is hit.
+ * Reserved value is a 'value' that is used directly if any of the 'names' is hit
+ * or in case of fuzzy names, if such fuzzy name matches.
  *
  * If type is any of DM_REPORT_FIELD_TYPE_*, the reserved value is recognized
  * for all fields of that type.
@@ -1736,16 +1739,59 @@ struct dm_report_field_reserved_value {
 struct dm_report_reserved_value {
 	const uint32_t type;		/* DM_REPORT_FIELD_RESERVED_VALUE_* and DM_REPORT_FIELD_TYPE_*  */
 	const void *value;		/* reserved value:
-						struct dm_report_field_reserved_value for DM_REPORT_FIELD_TYPE_NONE
 						uint64_t for DM_REPORT_FIELD_TYPE_NUMBER
 						uint64_t for DM_REPORT_FIELD_TYPE_SIZE (number of 512-byte sectors)
 						uint64_t for DM_REPORT_FIELD_TYPE_PERCENT
-						const char * for DM_REPORT_FIELD_TYPE_STRING */
-	const char **names;		/* null-terminated array of names for this reserved value */
+						const char* for DM_REPORT_FIELD_TYPE_STRING
+						struct dm_report_field_reserved_value for DM_REPORT_FIELD_TYPE_NONE
+						dm_report_reserved_handler* if DM_REPORT_FIELD_RESERVED_VALUE_{DYNAMIC_VALUE,FUZZY_NAMES} is used */
+	const char **names;		/* null-terminated array of static names for this reserved value */
 	const char *description;	/* description of the reserved value */
 };
 
 /*
+ * Available actions for dm_report_reserved_value_handler.
+ */
+typedef enum {
+	DM_REPORT_RESERVED_PARSE_FUZZY_NAME,
+	DM_REPORT_RESERVED_GET_DYNAMIC_VALUE,
+} dm_report_reserved_action_t;
+
+/*
+ * Generic reserved value handler to process reserved value names and/or values.
+ *
+ * Actions and their input/output:
+ *
+ * 	DM_REPORT_RESERVED_PARSE_FUZZY_NAME
+ *		data_in:  const char *fuzzy_name
+ *		data_out: const char *canonical_name, NULL if fuzzy_name not recognized
+ *
+ * 	DM_REPORT_RESERVED_GET_DYNAMIC_VALUE
+ * 		data_in:  const char *canonical_name
+ * 		data_out: void *value, NULL if canonical_name not recognized
+ *
+ * All actions return:
+ *
+ *	-1 if action not implemented
+ * 	0 on error
+ * 	1 on success
+ */
+typedef int (*dm_report_reserved_handler) (struct dm_report *rh,
+					   struct dm_pool *mem,
+					   uint32_t field_num,
+					   dm_report_reserved_action_t action,
+					   const void *data_in,
+					   const void **data_out);
+
+/*
+ * The dm_report_value_cache_{set,get} are helper functions to store and retrieve
+ * various values used during reporting (dm_report_field_type.report_fn) and/or
+ * selection processing (dm_report_reserved_handler instances) to avoid
+ * recalculation of these values or to share values among calls.
+ */
+int dm_report_value_cache_set(struct dm_report *rh, const char *name, const void *data);
+const void *dm_report_value_cache_get(struct dm_report *rh, const char *name);
+/*
  * dm_report_init output_flags
  */
 #define DM_REPORT_OUTPUT_MASK			0x000000FF
diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index f8bd581..559d463 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -63,6 +63,7 @@ struct dm_report {
 
 	/* Null-terminated array of reserved values */
 	const struct dm_report_reserved_value *reserved_values;
+	struct dm_hash_table *value_cache;
 };
 
 /*
@@ -1222,6 +1223,8 @@ void dm_report_free(struct dm_report *rh)
 {
 	if (rh->selection)
 		dm_pool_destroy(rh->selection->mem);
+	if (rh->value_cache)
+		dm_hash_destroy(rh->value_cache);
 	dm_pool_destroy(rh->mem);
 	dm_free(rh);
 }
@@ -2205,6 +2208,21 @@ dm_percent_t dm_make_percent(uint64_t numerator, uint64_t denominator)
 	}
 }
 
+int dm_report_value_cache_set(struct dm_report *rh, const char *name, const void *data)
+{
+	if (!rh->value_cache && (!(rh->value_cache = dm_hash_create(64)))) {
+		log_error("Failed to create cache for values used during reporting.");
+		return 0;
+	}
+
+	return dm_hash_insert(rh->value_cache, name, (void *) data);
+}
+
+const void *dm_report_value_cache_get(struct dm_report *rh, const char *name)
+{
+	return (rh->value_cache) ? dm_hash_lookup(rh->value_cache, name) : NULL;
+}
+
 /*
  * Used to check whether the reserved_values definition passed to
  * dm_report_init_with_selection contains only supported reserved value types.


