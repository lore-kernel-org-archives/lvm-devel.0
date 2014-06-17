From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 17 Jun 2014 14:34:05 +0000 (UTC)
Subject: master - report: select: add dm_report_init_with_selection to libdm
Message-ID: <20140617143405.500DB60C4F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0103738ef5ed5dc165d9b1d29ccc4902bda5998f
Commit:        0103738ef5ed5dc165d9b1d29ccc4902bda5998f
Parent:        2c3e84a68d1f991bfe47637017723b7cf0435dff
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu May 29 09:38:08 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Jun 17 16:27:20 2014 +0200

report: select: add dm_report_init_with_selection to libdm

This is rebased and edited version of the original design and
patch proposed by Jun'ichi Nomura:
  http://www.redhat.com/archives/dm-devel/2007-April/msg00025.html

The dm_report_init_with_selection is the same as dm_report_init
but it contains an additional argument to set the selection
in the form of a string that contains field names to check against and
selection operators. The selection string is parsend and a selection
tree is composed for use in the checks against individual fields when
the report is processed. The parsed selection tree is stored in dm_report
structure as "selection_root".
---
 libdm/libdevmapper.h |   11 ++
 libdm/libdm-report.c |  434 ++++++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 436 insertions(+), 9 deletions(-)

diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 3a51e14..319b07c 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -1641,7 +1641,18 @@ struct dm_report *dm_report_init(uint32_t *report_types,
 				 uint32_t output_flags,
 				 const char *sort_keys,
 				 void *private_data);
+struct dm_report *dm_report_init_with_selection(uint32_t *report_types,
+						const struct dm_report_object_type *types,
+						const struct dm_report_field_type *fields,
+						const char *output_fields,
+						const char *output_separator,
+						uint32_t output_flags,
+						const char *sort_keys,
+						const char *selection,
+						void *private_data);
 int dm_report_object(struct dm_report *rh, void *object);
+int dm_report_set_output_selection(struct dm_report *rh, uint32_t *report_types,
+				   const char *selection);
 int dm_report_output(struct dm_report *rh);
 void dm_report_free(struct dm_report *rh);
 
diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 882bf3e..1d00c51 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -48,6 +48,8 @@ struct dm_report {
 
 	/* To store caller private data */
 	void *private;
+
+	struct selection_node *selection_root;
 };
 
 /*
@@ -496,6 +498,23 @@ static int _add_all_fields(struct dm_report *rh, uint32_t type)
 	return 1;
 }
 
+static int _get_field(struct dm_report *rh, const char *field, size_t flen, uint32_t *f_ret)
+{
+	uint32_t f;
+
+	if (!flen)
+		return 0;
+
+	for (f = 0; rh->fields[f].report_fn; f++) {
+		if (_is_same_field(rh->fields[f].id, field, flen, rh->field_prefix)) {
+			*f_ret = f;
+			return 1;
+		}
+	}
+
+	return 0;
+}
+
 static int _field_match(struct dm_report *rh, const char *field, size_t flen,
 			unsigned report_type_only)
 {
@@ -504,15 +523,13 @@ static int _field_match(struct dm_report *rh, const char *field, size_t flen,
 	if (!flen)
 		return 0;
 
-	for (f = 0; rh->fields[f].report_fn; f++)
-		if (_is_same_field(rh->fields[f].id, field, flen,
-				   rh->field_prefix)) {
-			if (report_type_only) {
-				rh->report_types |= rh->fields[f].type;
-				return 1;
-			} else
-				return _add_field(rh, f, 0) ? 1 : 0;
-		}
+	if ((_get_field(rh, field, flen, &f))) {
+		if (report_type_only) {
+			rh->report_types |= rh->fields[f].type;
+			return 1;
+		} else
+			return _add_field(rh, f, 0) ? 1 : 0;
+	}
 
 	if ((type = _all_match(rh, field, flen))) {
 		if (report_type_only) {
@@ -1096,6 +1113,13 @@ static const char *_tok_value(const struct dm_report_field_type *ft,
 				*flags |= DM_REPORT_FIELD_TYPE_NUMBER;
 			} else {
 				s = tmp;
+				/*
+				 * If size unit is not defined in the selection
+				 * use  use 'm' (1 MiB) by default. This is the
+				 * same behaviour as seen in lvcreate -L <size>.
+				 */
+				if (!*factor)
+					*factor = 1024*1024;
 				*flags |= DM_REPORT_FIELD_TYPE_SIZE;
 			}
 	}
@@ -1128,7 +1152,399 @@ static const char *_tok_field_name(const char *s,
 	return s;
 }
 
+static struct field_selection *_create_field_selection(struct dm_report *rh,
+						       uint32_t field_num,
+						       const char *v,
+						       size_t len,
+						       uint32_t flags,
+						       void *custom)
+{
+	static const char *_out_of_range_msg = "Field selection value %s out of supported range for field %s.";
+	struct field_properties *fp, *found = NULL;
+	struct field_selection *fs;
+	const char *field_id;
+	uint64_t factor;
+	char *s;
+
+	dm_list_iterate_items(fp, &rh->field_props) {
+		if (fp->field_num == field_num) {
+			found = fp;
+			break;
+		}
+	}
+
+	/* The field is neither used in display options nor sort keys. */
+	if (!found) {
+		if (!(found = _add_field(rh, field_num, FLD_HIDDEN)))
+			return NULL;
+		rh->report_types |= rh->fields[field_num].type;
+	}
+
+	field_id = rh->fields[found->field_num].id;
+
+	if (!(found->flags & flags & DM_REPORT_FIELD_TYPE_MASK)) {
+		log_error("dm_report: incompatible comparison "
+			  "type for selection field %s", field_id);
+		return NULL;
+	}
+
+	/* set up selection */
+	if (!(fs = dm_pool_zalloc(rh->mem, sizeof(struct field_selection)))) {
+		log_error("dm_report: struct field_selection "
+			  "allocation failed for selection field %s", field_id);
+		return NULL;
+	}
+	fs->fp = found;
+	fs->flags = flags;
+
+	/* store comparison operand */
+	if (flags & FLD_CMP_REGEX) {
+		/* REGEX */
+		if (!(s = dm_malloc(len + 1))) {
+			log_error("dm_report: dm_malloc failed to store "
+				  "regex value for selection field %s", field_id);
+			goto error;
+		}
+		memcpy(s, v, len);
+		s[len] = '\0';
+
+		fs->v.r = dm_regex_create(rh->mem, (const char **) &s, 1);
+		dm_free(s);
+		if (!fs->v.r) {
+			log_error("dm_report: failed to create regex "
+				  "matcher for selection field %s", field_id);
+			goto error;
+		}
+	} else {
+		/* STRING, NUMBER or SIZE */
+		if (!(s = dm_pool_alloc(rh->mem, len + 1))) {
+			log_error("dm_report: dm_pool_alloc failed to store "
+				  "value for selection field %s", field_id);
+			goto error;
+		}
+		memcpy(s, v, len);
+		s[len] = '\0';
+
+		switch (flags & DM_REPORT_FIELD_TYPE_MASK) {
+			case DM_REPORT_FIELD_TYPE_STRING:
+				fs->v.s = s;
+				break;
+			case DM_REPORT_FIELD_TYPE_NUMBER:
+				if (((fs->v.i = strtoull(s, NULL, 10)) == ULLONG_MAX) &&
+				    (errno == ERANGE)) {
+					log_error(_out_of_range_msg, s, field_id);
+					goto error;
+				}
+				dm_pool_free(rh->mem, s);
+				break;
+			case DM_REPORT_FIELD_TYPE_SIZE:
+				fs->v.d = strtod(s, NULL);
+				if (errno == ERANGE) {
+					log_error(_out_of_range_msg, s, field_id);
+					goto error;
+				}
+				if (custom && (factor = *((uint64_t *)custom)))
+					fs->v.d *= factor;
+				fs->v.d /= 512; /* store size in sectors! */
+				dm_pool_free(rh->mem, s);
+				break;
+			default:
+				log_error(INTERNAL_ERROR "_create_field_selection: "
+					  "unknown type of selection field %s", field_id);
+				goto error;
+		}
+	}
+
+	return fs;
+error:
+	dm_pool_free(rh->mem, fs);
+	return NULL;
+}
+
+static struct selection_node *_alloc_selection_node(struct dm_pool *mem, uint32_t type)
+{
+	struct selection_node *sn;
+
+	if (!(sn = dm_pool_zalloc(mem, sizeof(struct selection_node)))) {
+		log_error("dm_report: struct selection_node allocation failed");
+		return NULL;
+	}
+
+	dm_list_init(&sn->list);
+	sn->type = type;
+	if (!(type & SEL_ITEM))
+		dm_list_init(&sn->selection.set);
+
+	return sn;
+}
+
+static char _sel_syntax_error_at_msg[] = "Selection syntax error at '%s'.";
+
+/*
+ * Selection parser
+ *
+ * _parse_* functions
+ *
+ *   Input:
+ *     s             - a pointer to the parsed string
+ *   Output:
+ *     next          - a pointer used for next _parse_*'s input,
+ *                     next == s if return value is NULL
+ *     return value  - a filter node pointer,
+ *                     NULL if s doesn't match
+ */
+
+/*
+ * SELECTION := FIELD_NAME OP_CMP STRING |
+ *              FIELD_NAME OP_CMP NUMBER  |
+ *              FIELD_NAME OP_REGEX REGEX
+ */
+static struct selection_node *_parse_selection(struct dm_report *rh,
+					       const char *s,
+					       const char **next)
+{
+	struct field_selection *fs;
+	struct selection_node *sn;
+	const char *ws, *we; /* field name */
+	const char *vs, *ve; /* value */
+	const char *last;
+	uint32_t flags, field_num;
+	const struct dm_report_field_type *ft;
+	uint64_t factor;
+	void *custom;
+	char *tmp;
+	char c;
+
+	/* field name */
+	if (!(last = _tok_field_name(s, &ws, &we))) {
+		log_error("Expecting field name");
+		goto bad;
+	}
+
+	/* check if the field with given name exists */
+	if (!_get_field(rh, ws, (size_t) (we - ws), &field_num)) {
+		c = we[0];
+		tmp = (char *) we;
+		tmp[0] = '\0';
+		log_error("Unrecognised selection field: %s", ws);
+		tmp[0] = c;
+		goto bad;
+	}
+
+	ft = &rh->fields[field_num];
+
+	/* comparison operator */
+	if (!(flags = _tok_op_cmp(we, &last))) {
+		log_error("Unrecognised comparison operator: %s", we);
+		goto bad;
+	}
+	if (!last) {
+		log_error("Missing value after operator");
+		goto bad;
+	}
+
+	/* some operators can compare only numeric fields */
+	if ((flags & FLD_CMP_NUMBER) &&
+	    (ft->flags != DM_REPORT_FIELD_TYPE_NUMBER) &&
+	    (ft->flags != DM_REPORT_FIELD_TYPE_SIZE)) {
+		log_error("Operator can be used only with numeric or size fields: %s", ws);
+		goto bad;
+	}
+
+	/* comparison value */
+	if (flags & FLD_CMP_REGEX) {
+		if (!(last = _tok_value_regex(ft, last, &vs, &ve, &flags)))
+			goto_bad;
+	} else {
+		if (ft->flags == DM_REPORT_FIELD_TYPE_SIZE)
+			custom = &factor;
+		else
+			custom = NULL;
+		if (!(last = _tok_value(ft, last, &vs, &ve, &flags, rh->mem, custom)))
+			goto_bad;
+	}
+
+	*next = _skip_space(last);
+
+	/* create selection */
+	if (!(fs = _create_field_selection(rh, field_num, vs, (size_t) (ve - vs), flags, custom)))
+		return_NULL;
+
+	/* create selection node */
+	if (!(sn = _alloc_selection_node(rh->mem, SEL_ITEM)))
+		return_NULL;
+
+	/* add selection to selection node */
+	sn->selection.item = fs;
+
+	return sn;
+bad:
+	log_error(_sel_syntax_error_at_msg, s);
+	*next = s;
+	return NULL;
+}
+
+static struct selection_node *_parse_or_ex(struct dm_report *rh,
+					   const char *s,
+					   const char **next,
+					   struct selection_node *or_sn);
 
+static struct selection_node *_parse_ex(struct dm_report *rh,
+					const char *s,
+					const char **next)
+{
+	static const char _ps_expected_msg[] = "Syntax error: left parenthesis expected at \'%s\'";
+	static const char _pe_expected_msg[] = "Syntax error: right parenthesis expected at \'%s\'";
+	struct selection_node *sn = NULL;
+	uint32_t t;
+	const char *tmp;
+
+	t = _tok_op_log(s, next, SEL_MODIFIER_NOT | SEL_PRECEDENCE_PS);
+	if (t == SEL_MODIFIER_NOT) {
+		/* '!' '(' EXPRESSION ')' */
+		if (!_tok_op_log(*next, &tmp, SEL_PRECEDENCE_PS)) {
+			log_error(_ps_expected_msg, *next);
+			goto error;
+		}
+		if (!(sn = _parse_or_ex(rh, tmp, next, NULL)))
+			goto error;
+		sn->type |= SEL_MODIFIER_NOT;
+		if (!_tok_op_log(*next, &tmp, SEL_PRECEDENCE_PE)) {
+			log_error(_pe_expected_msg, *next);
+			goto error;
+		}
+		*next = tmp;
+	} else if (t == SEL_PRECEDENCE_PS) {
+		/* '(' EXPRESSION ')' */
+		if (!(sn = _parse_or_ex(rh, *next, &tmp, NULL)))
+			goto error;
+		if (!_tok_op_log(tmp, next, SEL_PRECEDENCE_PE)) {
+			log_error(_pe_expected_msg, *next);
+			goto error;
+		}
+	} else if ((s = _skip_space(s))) {
+		/* SELECTION */
+		sn = _parse_selection(rh, s, next);
+	} else {
+		sn = NULL;
+		*next = s;
+	}
+
+	return sn;
+error:
+	*next = s;
+	return NULL;
+}
+
+/* AND_EXPRESSION := EX (AND_OP AND_EXPRSSION) */
+static struct selection_node *_parse_and_ex(struct dm_report *rh,
+					    const char *s,
+					    const char **next,
+					    struct selection_node *and_sn)
+{
+	struct selection_node *n;
+	const char *tmp;
+
+	n = _parse_ex(rh, s, next);
+	if (!n)
+		goto error;
+
+	if (!_tok_op_log(*next, &tmp, SEL_AND)) {
+		if (!and_sn)
+			return n;
+		dm_list_add(&and_sn->selection.set, &n->list);
+		return and_sn;
+	}
+
+	if (!and_sn) {
+		if (!(and_sn = _alloc_selection_node(rh->mem, SEL_AND)))
+			goto error;
+	}
+	dm_list_add(&and_sn->selection.set, &n->list);
+
+	return _parse_and_ex(rh, tmp, next, and_sn);
+error:
+	*next = s;
+	return NULL;
+}
+
+/* OR_EXPRESSION := AND_EXPRESSION (OR_OP OR_EXPRESSION) */
+static struct selection_node *_parse_or_ex(struct dm_report *rh,
+					   const char *s,
+					   const char **next,
+					   struct selection_node *or_sn)
+{
+	struct selection_node *n;
+	const char *tmp;
+
+	n = _parse_and_ex(rh, s, next, NULL);
+	if (!n)
+		goto error;
+
+	if (!_tok_op_log(*next, &tmp, SEL_OR)) {
+		if (!or_sn)
+			return n;
+		dm_list_add(&or_sn->selection.set, &n->list);
+		return or_sn;
+	}
+
+	if (!or_sn) {
+		if (!(or_sn = _alloc_selection_node(rh->mem, SEL_OR)))
+			goto error;
+	}
+	dm_list_add(&or_sn->selection.set, &n->list);
+
+	return _parse_or_ex(rh, tmp, next, or_sn);
+error:
+	*next = s;
+	return NULL;
+}
+
+struct dm_report *dm_report_init_with_selection(uint32_t *report_types,
+						const struct dm_report_object_type *types,
+						const struct dm_report_field_type *fields,
+						const char *output_fields,
+						const char *output_separator,
+						uint32_t output_flags,
+						const char *sort_keys,
+						const char *selection,
+						void *private_data)
+{
+	struct dm_report *rh;
+	struct selection_node *root = NULL;
+	const char *fin, *next;
+
+	if (!(rh = dm_report_init(report_types, types, fields, output_fields,
+			output_separator, output_flags, sort_keys, private_data)))
+		return NULL;
+
+	if (!selection || !selection[0]) {
+		rh->selection_root = NULL;
+		return rh;
+	}
+
+	if (!(root = _alloc_selection_node(rh->mem, SEL_OR)))
+		return_0;
+
+	if (!_parse_or_ex(rh, selection, &fin, root))
+		goto error;
+
+	next = _skip_space(fin);
+	if (*next) {
+		log_error("Expecting logical operator");
+		log_error(_sel_syntax_error_at_msg, next);
+		goto error;
+	}
+
+	if (report_types)
+		*report_types = rh->report_types;
+
+	rh->selection_root = root;
+	return rh;
+error:	
+	dm_report_free(rh);
+	return NULL;
+}
 
 /*
  * Print row of headings


