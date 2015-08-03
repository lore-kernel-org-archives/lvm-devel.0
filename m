From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon,  3 Aug 2015 14:35:41 +0000 (UTC)
Subject: master - report: recognize report field name variants without any underscores too
Message-ID: <20150803143541.D7AAD6072A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a5b476a7d3ffd06fa8124395857b4dcca32d612b
Commit:        a5b476a7d3ffd06fa8124395857b4dcca32d612b
Parent:        b3997469b56eb54f78fc84a8d9fde285ffd53c56
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Aug 3 16:29:50 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Aug 3 16:29:50 2015 +0200

report: recognize report field name variants without any underscores too

Whenver reporting field name is registered with libdevmapper and if
the field name contains any number of underscores ('_'), libdm
can now automatically recognize any of its variant without any
underscores used.

For example:

..for underscores in prefixes:
  pvs -o pv_name
  pvs -o name
  pvs -o pvname (newly recognized besides pvname)

..for underscores in the name:
  lvs -o cache_mode
  lvs -o cachemode

..or even multiple underscores:
  pvs -o pv___na___me

It's all variant of the same field name.
---
 WHATS_NEW_DM         |    1 +
 libdm/libdm-report.c |   92 ++++++++++++++++++++++++++++++++++++++++++++------
 2 files changed, 82 insertions(+), 11 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 2a006db..57cfce4 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.104 -
 =================================
+  Recognize report field name variants without any underscores too.
   Add dmsetup --interval and --count to repeat reports at specified intervals.
   Add report interval and waiting functions to libdevmapper.
   Add dm_timestamp functions to libdevmapper.
diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 5ae994d..64ba033 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -55,6 +55,7 @@ struct dm_report {
 
 	/* Array of field definitions */
 	const struct dm_report_field_type *fields;
+	const char **canonical_field_ids;
 	const struct dm_report_object_type *types;
 
 	/* To store caller private data */
@@ -816,25 +817,51 @@ static struct field_properties * _add_field(struct dm_report *rh,
 	return fp;
 }
 
+static int _get_canonical_field_name(const char *field,
+				     size_t flen,
+				     char *canonical_field,
+				     size_t fcanonical_len,
+				     int *differs)
+{
+	size_t i;
+	int diff = 0;
+
+	for (i = 0; *field && flen; field++, flen--) {
+		if (*field == '_') {
+			diff = 1;
+			continue;
+		}
+		if (i >= fcanonical_len) {
+			log_error("%s: field name too long", field);
+			return 0;
+		}
+		canonical_field[i++] = *field;
+	}
+
+	canonical_field[i] = '\0';
+	if (differs)
+		*differs = diff;
+	return 1;
+}
+
 /*
  * Compare name1 against name2 or prefix plus name2
  * name2 is not necessarily null-terminated.
  * len2 is the length of name2.
  */
-static int _is_same_field(const char *name1, const char *name2,
-			  size_t len2, const char *prefix)
+static int _is_same_field(const char *canonical_name1, const char *canonical_name2,
+			  const char *prefix)
 {
 	size_t prefix_len;
 
 	/* Exact match? */
-	if (!strncasecmp(name1, name2, len2) && strlen(name1) == len2)
+	if (!strcasecmp(canonical_name1, canonical_name2))
 		return 1;
 
 	/* Match including prefix? */
-	prefix_len = strlen(prefix);
-	if (!strncasecmp(prefix, name1, prefix_len) &&
-	    !strncasecmp(name1 + prefix_len, name2, len2) &&
-	    strlen(name1) == prefix_len + len2)
+	prefix_len = strlen(prefix) - 1;
+	if (!strncasecmp(prefix, canonical_name1, prefix_len) &&
+	    !strcasecmp(canonical_name1 + prefix_len, canonical_name2))
 		return 1;
 
 	return 0;
@@ -901,13 +928,17 @@ static int _add_all_fields(struct dm_report *rh, uint32_t type)
 static int _get_field(struct dm_report *rh, const char *field, size_t flen,
 		      uint32_t *f_ret, int *implicit)
 {
+	char field_canon[DM_REPORT_FIELD_TYPE_ID_LEN];
 	uint32_t f;
 
 	if (!flen)
 		return 0;
 
+	if (!_get_canonical_field_name(field, flen, field_canon, DM_REPORT_FIELD_TYPE_ID_LEN, NULL))
+		return 0;
+
 	for (f = 0; _implicit_report_fields[f].report_fn; f++) {
-		if (_is_same_field(_implicit_report_fields[f].id, field, flen, rh->field_prefix)) {
+		if (_is_same_field(_implicit_report_fields[f].id, field_canon, rh->field_prefix)) {
 			*f_ret = f;
 			*implicit = 1;
 			return 1;
@@ -915,7 +946,7 @@ static int _get_field(struct dm_report *rh, const char *field, size_t flen,
 	}
 
 	for (f = 0; rh->fields[f].report_fn; f++) {
-		if (_is_same_field(rh->fields[f].id, field, flen, rh->field_prefix)) {
+		if (_is_same_field(rh->canonical_field_ids[f], field_canon, rh->field_prefix)) {
 			*f_ret = f;
 			*implicit = 0;
 			return 1;
@@ -994,6 +1025,7 @@ static int _add_sort_key(struct dm_report *rh, uint32_t field_num, int implicit,
 static int _key_match(struct dm_report *rh, const char *key, size_t len,
 		      unsigned report_type_only)
 {
+	char key_canon[DM_REPORT_FIELD_TYPE_ID_LEN];
 	uint32_t f;
 	uint32_t flags;
 
@@ -1016,12 +1048,15 @@ static int _key_match(struct dm_report *rh, const char *key, size_t len,
 		return 0;
 	}
 
+	if (!_get_canonical_field_name(key, len, key_canon, DM_REPORT_FIELD_TYPE_ID_LEN, NULL))
+		return 0;
+
 	for (f = 0; _implicit_report_fields[f].report_fn; f++)
-		if (_is_same_field(_implicit_report_fields[f].id, key, len, rh->field_prefix))
+		if (_is_same_field(_implicit_report_fields[f].id, key_canon, rh->field_prefix))
 			return _add_sort_key(rh, f, 1, flags, report_type_only);
 
 	for (f = 0; rh->fields[f].report_fn; f++)
-		if (_is_same_field(rh->fields[f].id, key, len, rh->field_prefix))
+		if (_is_same_field(rh->canonical_field_ids[f], key_canon, rh->field_prefix))
 			return _add_sort_key(rh, f, 0, flags, report_type_only);
 
 	return 0;
@@ -1129,6 +1164,36 @@ static int _help_requested(struct dm_report *rh)
 	return 0;
 }
 
+static int _canonicalize_field_ids(struct dm_report *rh)
+{
+	size_t registered_field_count = 0, i;
+	char canonical_field[DM_REPORT_FIELD_TYPE_ID_LEN];
+	char *canonical_field_dup;
+	int differs;
+
+	while (*rh->fields[registered_field_count].id)
+		registered_field_count++;
+
+	if (!(rh->canonical_field_ids = dm_pool_alloc(rh->mem, registered_field_count * sizeof(const char *)))) {
+		log_error("_canonicalize_field_ids: dm_pool_alloc failed");
+		return 0;
+	}
+
+	for (i = 0; i < registered_field_count; i++) {
+		if (!_get_canonical_field_name(rh->fields[i].id, strlen(rh->fields[i].id),
+					       canonical_field, DM_REPORT_FIELD_TYPE_ID_LEN, &differs))
+			return_0;
+
+		if (differs) {
+			canonical_field_dup = dm_pool_strdup(rh->mem, canonical_field);
+			rh->canonical_field_ids[i] = canonical_field_dup;
+		} else
+			rh->canonical_field_ids[i] = rh->fields[i].id;
+	}
+
+	return 1;
+}
+
 struct dm_report *dm_report_init(uint32_t *report_types,
 				 const struct dm_report_object_type *types,
 				 const struct dm_report_field_type *fields,
@@ -1189,6 +1254,11 @@ struct dm_report *dm_report_init(uint32_t *report_types,
 		return NULL;
 	}
 
+	if (!_canonicalize_field_ids(rh)) {
+		dm_report_free(rh);
+		return NULL;
+	}
+
 	/*
 	 * To keep the code needed to add the "all" field to a minimum, we parse
 	 * the field lists twice.  The first time we only update the report type.


