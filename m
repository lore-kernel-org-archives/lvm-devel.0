From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 30 Jun 2015 08:50:27 +0000 (UTC)
Subject: master - cleanup: report: use internal wrapper for various variables used for handling reserved values
Message-ID: <20150630085027.7B62D6124D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d7b9349ce71f2747eb7d0a8992244bc3d34719be
Commit:        d7b9349ce71f2747eb7d0a8992244bc3d34719be
Parent:        d8996a17d1a0605cebfcf926a7a8d0e6b7fc1fcc
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Jun 30 10:23:35 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Jun 30 10:47:51 2015 +0200

cleanup: report: use internal wrapper for various variables used for handling reserved values

Just a cleanup - wrap several variables we use to handle reserved
values into a structure for easier manipulation in the code.
---
 libdm/libdm-report.c |   93 ++++++++++++++++++++++++++++++-------------------
 1 files changed, 57 insertions(+), 36 deletions(-)

diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 401e87a..4348db1 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -188,6 +188,12 @@ struct selection_node {
 	} selection;
 };
 
+struct reserved_value_wrapper {
+	const char *matched_name;
+	const struct dm_report_reserved_value *reserved;
+	const void *value;
+};
+
 /*
  * Report data field
  */
@@ -2080,14 +2086,14 @@ static const char *_reserved_name(const char **names, const char *s, size_t len)
 static const char *_get_reserved(struct dm_report *rh, unsigned type,
 				 uint32_t field_num, int implicit,
 				 const char *s, const char **begin, const char **end,
-				 const struct dm_report_reserved_value **reserved)
+				 struct reserved_value_wrapper *rvw)
 {
 	const struct dm_report_reserved_value *iter = implicit ? NULL : rh->reserved_values;
 	const char *tmp_begin, *tmp_end, *tmp_s = s;
 	const char *name = NULL;
 	char c;
 
-	*reserved = NULL;
+	rvw->reserved = NULL;
 
 	if (!iter)
 		return s;
@@ -2115,7 +2121,8 @@ static const char *_get_reserved(struct dm_report *rh, unsigned type,
 		*begin = tmp_begin;
 		*end = tmp_end;
 		s = tmp_s;
-		*reserved = iter;
+		rvw->reserved = iter;
+		rvw->matched_name = name;
 	}
 
 	return s;
@@ -2213,10 +2220,10 @@ static const char *_tok_value_regex(struct dm_report *rh,
 				    const struct dm_report_field_type *ft,
 				    const char *s, const char **begin,
 				    const char **end, uint32_t *flags,
-				    const struct dm_report_reserved_value **reserved)
+				    struct reserved_value_wrapper *rvw)
 {
 	char c;
-	*reserved = NULL;
+	rvw->reserved = NULL;
 
 	s = _skip_space(s);
 
@@ -2439,7 +2446,7 @@ static const char *_tok_value(struct dm_report *rh,
 			      const char *s,
 			      const char **begin, const char **end,
 			      uint32_t *flags,
-			      const struct dm_report_reserved_value **reserved,
+			      struct reserved_value_wrapper *rvw,
 			      struct dm_pool *mem, void *custom)
 {
 	int expected_type = ft->flags & DM_REPORT_FIELD_TYPE_MASK;
@@ -2450,8 +2457,8 @@ static const char *_tok_value(struct dm_report *rh,
 
 	s = _skip_space(s);
 
-	s = _get_reserved(rh, expected_type, field_num, implicit, s, begin, end, reserved);
-	if (*reserved) {
+	s = _get_reserved(rh, expected_type, field_num, implicit, s, begin, end, rvw);
+	if (rvw->reserved) {
 		*flags |= expected_type;
 		return s;
 	}
@@ -2553,12 +2560,23 @@ static const char *_tok_field_name(const char *s,
 	return s;
 }
 
-static const void *_get_reserved_value(const struct dm_report_reserved_value *reserved)
+static int _get_reserved_value(struct dm_report *rh, uint32_t field_num,
+			       struct reserved_value_wrapper *rvw)
 {
-	if (reserved->type & DM_REPORT_FIELD_TYPE_MASK)
-		return reserved->value;
+	const void *tmp_value;
+
+	if (!rvw->reserved) {
+		rvw->value = NULL;
+		return 1;
+	}
+
+	if (rvw->reserved->type & DM_REPORT_FIELD_TYPE_MASK)
+		tmp_value = rvw->reserved->value;
 	else
-		return ((const struct dm_report_field_reserved_value *) reserved->value)->value;
+		tmp_value = ((const struct dm_report_field_reserved_value *) rvw->reserved->value)->value;
+
+	rvw->value = tmp_value;
+	return 1;
 }
 
 static struct field_selection *_create_field_selection(struct dm_report *rh,
@@ -2567,7 +2585,7 @@ static struct field_selection *_create_field_selection(struct dm_report *rh,
 						       const char *v,
 						       size_t len,
 						       uint32_t flags,
-						       const struct dm_report_reserved_value *reserved,
+						       struct reserved_value_wrapper *rvw,
 						       void *custom)
 {
 	static const char *_out_of_range_msg = "Field selection value %s out of supported range for field %s.";
@@ -2576,7 +2594,6 @@ static struct field_selection *_create_field_selection(struct dm_report *rh,
 							     : rh->fields;
 	struct field_properties *fp, *found = NULL;
 	struct field_selection *fs;
-	const void *reserved_value;
 	const char *field_id;
 	uint64_t factor;
 	char *s;
@@ -2615,7 +2632,7 @@ static struct field_selection *_create_field_selection(struct dm_report *rh,
 		goto error;
 	}
 
-	if (reserved && (reserved->type & DM_REPORT_FIELD_RESERVED_VALUE_RANGE) &&
+	if (rvw->reserved && (rvw->reserved->type & DM_REPORT_FIELD_RESERVED_VALUE_RANGE) &&
 	    !(fs->value->next = dm_pool_zalloc(rh->selection->mem, sizeof(struct field_selection_value)))) {
 		log_error(_field_selection_value_alloc_failed_msg, field_id);
 		goto error;
@@ -2624,7 +2641,11 @@ static struct field_selection *_create_field_selection(struct dm_report *rh,
 	fs->fp = found;
 	fs->flags = flags;
 
-	reserved_value = reserved ? _get_reserved_value(reserved) : NULL;
+	if (!_get_reserved_value(rh, field_num, rvw)) {
+		log_error("dm_report: could not get reserved value "
+			  "while processing selection field %s", field_id);
+		goto error;
+	}
 
 	/* store comparison operand */
 	if (flags & FLD_CMP_REGEX) {
@@ -2654,10 +2675,10 @@ static struct field_selection *_create_field_selection(struct dm_report *rh,
 
 		switch (flags & DM_REPORT_FIELD_TYPE_MASK) {
 			case DM_REPORT_FIELD_TYPE_STRING:
-				if (reserved_value) {
-					fs->value->v.s = (const char *) reserved_value;
-					if (reserved->type & DM_REPORT_FIELD_RESERVED_VALUE_RANGE)
-						fs->value->next->v.s = (((const char **) reserved_value)[1]);
+				if (rvw->value) {
+					fs->value->v.s = (const char *) rvw->value;
+					if (rvw->reserved->type & DM_REPORT_FIELD_RESERVED_VALUE_RANGE)
+						fs->value->next->v.s = (((const char **) rvw->value)[1]);
 					dm_pool_free(rh->selection->mem, s);
 				} else {
 					fs->value->v.s = s;
@@ -2668,10 +2689,10 @@ static struct field_selection *_create_field_selection(struct dm_report *rh,
 				}
 				break;
 			case DM_REPORT_FIELD_TYPE_NUMBER:
-				if (reserved_value) {
-					fs->value->v.i = *(uint64_t *) reserved_value;
-					if (reserved->type & DM_REPORT_FIELD_RESERVED_VALUE_RANGE)
-						fs->value->next->v.i = (((uint64_t *) reserved_value)[1]);
+				if (rvw->value) {
+					fs->value->v.i = *(uint64_t *) rvw->value;
+					if (rvw->reserved->type & DM_REPORT_FIELD_RESERVED_VALUE_RANGE)
+						fs->value->next->v.i = (((uint64_t *) rvw->value)[1]);
 				} else {
 					if (((fs->value->v.i = strtoull(s, NULL, 10)) == ULLONG_MAX) &&
 						 (errno == ERANGE)) {
@@ -2686,10 +2707,10 @@ static struct field_selection *_create_field_selection(struct dm_report *rh,
 				dm_pool_free(rh->selection->mem, s);
 				break;
 			case DM_REPORT_FIELD_TYPE_SIZE:
-				if (reserved_value) {
-					fs->value->v.d = *(double *) reserved_value;
-					if (reserved->type & DM_REPORT_FIELD_RESERVED_VALUE_RANGE)
-						fs->value->next->v.d = (((double *) reserved_value)[1]);
+				if (rvw->value) {
+					fs->value->v.d = *(double *) rvw->value;
+					if (rvw->reserved->type & DM_REPORT_FIELD_RESERVED_VALUE_RANGE)
+						fs->value->next->v.d = (((double *) rvw->value)[1]);
 				} else {
 					fs->value->v.d = strtod(s, NULL);
 					if (errno == ERANGE) {
@@ -2707,10 +2728,10 @@ static struct field_selection *_create_field_selection(struct dm_report *rh,
 				dm_pool_free(rh->selection->mem, s);
 				break;
 			case DM_REPORT_FIELD_TYPE_PERCENT:
-				if (reserved_value) {
-					fs->value->v.i = *(uint64_t *) reserved_value;
-					if (reserved->type & DM_REPORT_FIELD_RESERVED_VALUE_RANGE)
-						fs->value->next->v.i = (((uint64_t *) reserved_value)[1]);
+				if (rvw->value) {
+					fs->value->v.i = *(uint64_t *) rvw->value;
+					if (rvw->reserved->type & DM_REPORT_FIELD_RESERVED_VALUE_RANGE)
+						fs->value->next->v.i = (((uint64_t *) rvw->value)[1]);
 				} else {
 					fs->value->v.d = strtod(s, NULL);
 					if ((errno == ERANGE) || (fs->value->v.d < 0) || (fs->value->v.d > 100)) {
@@ -2868,7 +2889,7 @@ static struct selection_node *_parse_selection(struct dm_report *rh,
 	int implicit;
 	const struct dm_report_field_type *ft;
 	struct selection_str_list *str_list;
-	const struct dm_report_reserved_value *reserved;
+	struct reserved_value_wrapper rvw = {0};
 	uint64_t factor;
 	void *custom = NULL;
 	char *tmp;
@@ -2931,7 +2952,7 @@ static struct selection_node *_parse_selection(struct dm_report *rh,
 
 	/* comparison value */
 	if (flags & FLD_CMP_REGEX) {
-		if (!(last = _tok_value_regex(rh, ft, last, &vs, &ve, &flags, &reserved)))
+		if (!(last = _tok_value_regex(rh, ft, last, &vs, &ve, &flags, &rvw)))
 			goto_bad;
 	} else {
 		if (ft->flags == DM_REPORT_FIELD_TYPE_SIZE ||
@@ -2944,14 +2965,14 @@ static struct selection_node *_parse_selection(struct dm_report *rh,
 			custom = NULL;
 		if (!(last = _tok_value(rh, ft, field_num, implicit,
 					last, &vs, &ve, &flags,
-					&reserved, rh->selection->mem, custom)))
+					&rvw, rh->selection->mem, custom)))
 			goto_bad;
 	}
 
 	*next = _skip_space(last);
 
 	/* create selection */
-	if (!(fs = _create_field_selection(rh, field_num, implicit, vs, (size_t) (ve - vs), flags, reserved, custom)))
+	if (!(fs = _create_field_selection(rh, field_num, implicit, vs, (size_t) (ve - vs), flags, &rvw, custom)))
 		return_NULL;
 
 	/* create selection node */


