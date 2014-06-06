From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri,  6 Jun 2014 12:04:00 +0000 (UTC)
Subject: dev-prajnoha-report-select - report: select: add support for processing string lists in selection
Message-ID: <20140606120400.8CB8860CAD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a0c002b453ea75f618700936ee6d7d19502deb21
Commit:        a0c002b453ea75f618700936ee6d7d19502deb21
Parent:        6100fd752dfe07a47068fe2c6d3b813a3d1bd510
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu May 29 09:41:50 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Jun 6 11:40:36 2014 +0200

report: select: add support for processing string lists in selection

Selection list items are enclosed in '[' and ']' (if there's only
one item, the '[' and ']' can be omitted). Each element of the list
is a string (either quoted or unquoted, like the usual string operand
used in selection) and each element is delimited either by conjunction
(meaining "match all") or disjunction operator (meaning "match any").

For example, if "," is the conjuction operator and "/" is the
disjunction operator then:

  lv_tags=[a,b,c]

...will match all fields where tags contain *all* a, b and c.

  lv_tags=[a/b/c]

...will match all fields where tags contain *any* of a, b, or c.

Mixing operators within the list is not supported:

  lv_tags=[a,b/c]

...will give an error.

The order in which items are defined in the selection do not matter.

This patch enhances the selection parsing functionality to recognize
such lists.
---
 libdm/libdm-report.c |  204 ++++++++++++++++++++++++++++++++++++++++++++++++--
 1 files changed, 198 insertions(+), 6 deletions(-)

diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 28831d6..5db638c 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -117,6 +117,10 @@ static struct op_def _op_cmp[] = {
 #define SEL_PRECEDENCE_PS	0x00001000
 #define SEL_PRECEDENCE_PE	0x00002000
 
+#define SEL_LIST_MASK		0x000F0000
+#define SEL_LIST_LS		0x00010000
+#define SEL_LIST_LE		0x00020000
+
 static struct op_def _op_log[] = {
         { "&&", SEL_AND, "Logical conjunction" },
 	{ ",", SEL_AND, "Logical conjunction (alternative)" },
@@ -125,9 +129,16 @@ static struct op_def _op_log[] = {
         { "!", SEL_MODIFIER_NOT, "Logical negation" },
         { "(", SEL_PRECEDENCE_PS, "Left parenthesis" },
         { ")", SEL_PRECEDENCE_PE, "Right parenthesis" },
+        { "[", SEL_LIST_LS, "List start" },
+        { "]", SEL_LIST_LE, "List end"},
         { NULL,  0, NULL},
 };
 
+struct selection_str_list {
+	unsigned type;			/* either SEL_AND or SEL_OR */
+	struct dm_list *list;
+};
+
 struct field_selection {
 	struct field_properties *fp;
 	uint32_t flags;
@@ -136,6 +147,7 @@ struct field_selection {
 		uint64_t i;
 		double d;
 		struct dm_regex *r;
+		struct selection_str_list *l;
 	} v;
 };
 
@@ -1343,6 +1355,171 @@ static const char *_tok_value_regex(const struct dm_report_field_type *ft,
 	return s;
 }
 
+static int _str_list_item_cmp(const void *a, const void *b)
+{
+	const struct dm_str_list **item_a = (const struct dm_str_list **) a;
+	const struct dm_str_list **item_b = (const struct dm_str_list **) b;
+
+	return strcmp((*item_a)->str, (*item_b)->str);
+}
+
+static int _add_item_to_string_list(struct dm_pool *mem, const char *begin,
+				    const char *end, struct dm_list *list)
+{
+	struct dm_str_list *item;
+
+	if (begin == end)
+		return_0;
+
+	if (!(item = dm_pool_zalloc(mem, sizeof(*item))) ||
+	    !(item->str = dm_pool_strndup(mem, begin, end - begin))) {
+		log_error("_add_item_to_string_list: memory allocation failed for string list item");
+		return 0;
+	}
+	dm_list_add(list, &item->list);
+
+	return 1;
+}
+
+static inline char _get_and_skip_quote_char(char const **s)
+{
+	char c = 0;
+
+	if (**s == '"' || **s == '\'') {
+		c = **s;
+		(*s)++;
+	}
+
+	return c;
+}
+
+/*
+ * Input:
+ *   ft              - field type for which the value is parsed
+ *   mem             - memory pool to allocate from
+ *   s               - a pointer to the parsed string
+ * Output:
+ *   begin           - a pointer to the beginning of the token (whole list)
+ *   end             - a pointer to the end of the token + 1 (whole list)
+ *   sel_str_list    - the list of strings parsed
+ */
+static const char *_tok_value_string_list(const struct dm_report_field_type *ft,
+					  struct dm_pool *mem, const char *s,
+					  const char **begin, const char **end,
+					  struct selection_str_list **sel_str_list)
+{
+	static const char _str_list_item_parsing_failed[] = "Failed to parse string list value "
+							    "for selection field %s.";
+	struct selection_str_list *ssl = NULL;
+	struct dm_str_list *item;
+	const char *begin_item, *end_item, *tmp;
+	uint32_t end_op_flags, end_op_flag_hit;
+	struct dm_str_list **arr;
+	size_t list_size;
+	unsigned int i;
+	int list_end;
+	char c;
+
+	if (!(ssl = dm_pool_alloc(mem, sizeof(*ssl))) ||
+	    !(ssl->list = dm_pool_alloc(mem, sizeof(*ssl->list)))) {
+		log_error("_tok_value_string_list: memory allocation failed for selection list");
+		goto bad;
+	}
+	dm_list_init(ssl->list);
+	ssl->type = 0;
+	*begin = s;
+
+	if (!_tok_op_log(s, &tmp, SEL_LIST_LS)) {
+		/* Only one item - SEL_LIST_LS and SEL_LIST_LE not used */
+		c = _get_and_skip_quote_char(&s);
+		if (!(s = _tok_value_string(s, &begin_item, &end_item, c, SEL_AND | SEL_OR | SEL_PRECEDENCE_PE, NULL))) {
+			log_error(_str_list_item_parsing_failed, ft->id);
+			goto bad;
+		}
+		if (!_add_item_to_string_list(mem, begin_item, end_item, ssl->list))
+			goto_bad;
+		ssl->type = SEL_OR;
+		goto out;
+	}
+
+	/* More than one item - items enclosed in SEL_LIST_LS and SEL_LIST_LE.
+	 * Each element is terminated by AND or OR operator or 'list end'.
+	 * The first operator hit is then the one allowed for the whole list,
+	 * no mixing allowed!
+	 */
+	end_op_flags = SEL_LIST_LE | SEL_AND | SEL_OR;
+	s++;
+	while (*s) {
+		s = _skip_space(s);
+		c = _get_and_skip_quote_char(&s);
+		if (!(s = _tok_value_string(s, &begin_item, &end_item, c, end_op_flags, NULL))) {
+			log_error(_str_list_item_parsing_failed, ft->id);
+			goto bad;
+		}
+		s = _skip_space(s);
+
+		if (!(end_op_flag_hit = _tok_op_log(s, &tmp, end_op_flags))) {
+			log_error("Invalid operator in selection list.");
+			goto bad;
+		}
+
+		list_end = end_op_flag_hit == SEL_LIST_LE;
+
+		if (ssl->type) {
+			if (!list_end && !(ssl->type & end_op_flag_hit)) {
+				log_error("Only one type of logical operator allowed "
+					  "in selection list at a time.");
+				goto bad;
+			}
+		} else
+			ssl->type = list_end ? SEL_OR : end_op_flag_hit;
+
+		if (!_add_item_to_string_list(mem, begin_item, end_item, ssl->list))
+			goto_bad;
+
+		s = tmp;
+
+		if (list_end)
+			break;
+	}
+
+	if (end_op_flag_hit != SEL_LIST_LE) {
+		log_error("Missing list end for selection field %s", ft->id);
+		goto bad;
+	}
+
+	/* Sort the list. */
+	if (!(list_size = dm_list_size(ssl->list))) {
+		log_error(INTERNAL_ERROR "_tok_value_string_list: list has no items");
+		goto bad;
+	} else if (list_size == 1)
+		goto out;
+	if (!(arr = dm_malloc(sizeof(item) * list_size))) {
+		log_error("_tok_value_string_list: memory allocation failed for sort array");
+		goto bad;
+	}
+
+	i = 0;
+	dm_list_iterate_items(item, ssl->list)
+		arr[i++] = item;
+	qsort(arr, list_size, sizeof(item), _str_list_item_cmp);
+	dm_list_init(ssl->list);
+	for (i = 0; i < list_size; i++)
+		dm_list_add(ssl->list, &arr[i]->list);
+
+	dm_free(arr);
+out:
+	*end = s;
+	*sel_str_list = ssl;
+	return s;
+bad:
+	*end = s;
+	if (ssl)
+		dm_pool_free(mem, ssl);
+	*sel_str_list = NULL;
+	return s;
+}
+
 /*
  * Input:
  *   ft              - field type for which the value is parsed
@@ -1361,19 +1538,17 @@ static const char *_tok_value(const struct dm_report_field_type *ft,
 			      struct dm_pool *mem, void *custom)
 {
 	int expected_type = ft->flags & DM_REPORT_FIELD_TYPE_MASK;
+	struct selection_str_list **str_list;
 	uint64_t *factor;
 	const char *tmp;
-	char c = 0;
+	char c;
 
 	s = _skip_space(s);
 
 	switch (expected_type) {
 
 		case DM_REPORT_FIELD_TYPE_STRING:
-			if (*s == '"' || *s == '\'') {
-				c = *s;
-				s++;
-			}
+			c = _get_and_skip_quote_char(&s);
 			if (!(s = _tok_value_string(s, begin, end, c, SEL_AND | SEL_OR | SEL_PRECEDENCE_PE, NULL))) {
 				log_error("Failed to parse string value "
 					  "for selection field %s.", ft->id);
@@ -1382,6 +1557,17 @@ static const char *_tok_value(const struct dm_report_field_type *ft,
 			*flags |= DM_REPORT_FIELD_TYPE_STRING;
 			break;
 
+		case DM_REPORT_FIELD_TYPE_STRING_LIST:
+			str_list = (struct selection_str_list **) custom;
+			s = _tok_value_string_list(ft, mem, s, begin, end, str_list);
+			if (!(*str_list)) {
+				log_error("Failed to parse string list value "
+					  "for selection field %s.", ft->id);
+				return NULL;
+			}
+			*flags |= DM_REPORT_FIELD_TYPE_STRING_LIST;
+			break;
+
 		case DM_REPORT_FIELD_TYPE_NUMBER:
 		case DM_REPORT_FIELD_TYPE_SIZE:
 			if (!(s = _tok_value_number(s, begin, end))) {
@@ -1498,7 +1684,7 @@ static struct field_selection *_create_field_selection(struct dm_report *rh,
 			goto error;
 		}
 	} else {
-		/* STRING, NUMBER or SIZE */
+		/* STRING, NUMBER, SIZE or STRING_LIST */
 		if (!(s = dm_pool_alloc(rh->mem, len + 1))) {
 			log_error("dm_report: dm_pool_alloc failed to store "
 				  "value for selection field %s", field_id);
@@ -1530,6 +1716,9 @@ static struct field_selection *_create_field_selection(struct dm_report *rh,
 				fs->v.d /= 512; /* store size in sectors! */
 				dm_pool_free(rh->mem, s);
 				break;
+			case DM_REPORT_FIELD_TYPE_STRING_LIST:
+				fs->v.l = *(struct selection_str_list **)custom;
+				break;
 			default:
 				log_error(INTERNAL_ERROR "_create_field_selection: "
 					  "unknown type of selection field %s", field_id);
@@ -1592,6 +1781,7 @@ static struct selection_node *_parse_selection(struct dm_report *rh,
 	const char *last;
 	uint32_t flags, field_num;
 	const struct dm_report_field_type *ft;
+	struct selection_str_list *str_list;
 	uint64_t factor;
 	void *custom;
 	char *tmp;
@@ -1641,6 +1831,8 @@ static struct selection_node *_parse_selection(struct dm_report *rh,
 		if (ft->flags == DM_REPORT_FIELD_TYPE_SIZE ||
 		    ft->flags == DM_REPORT_FIELD_TYPE_NUMBER)
 			custom = &factor;
+		else if (ft->flags == DM_REPORT_FIELD_TYPE_STRING_LIST)
+			custom = &str_list;
 		else
 			custom = NULL;
 		if (!(last = _tok_value(ft, last, &vs, &ve, &flags, rh->mem, custom)))


