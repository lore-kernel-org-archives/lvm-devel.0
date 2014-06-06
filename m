From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri,  6 Jun 2014 12:03:39 +0000 (UTC)
Subject: dev-prajnoha-report-select - report: select: add supporting infrastucture for token parsing in report selections
Message-ID: <20140606120339.A336B60180@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d99e8214a2f0a1d2756bb72a18502d093633a512
Commit:        d99e8214a2f0a1d2756bb72a18502d093633a512
Parent:        5e9c2000026b9babbca378bdaf6407ea76f20fb8
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu May 29 09:37:54 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Jun 6 11:11:20 2014 +0200

report: select: add supporting infrastucture for token parsing in report selections

This is rebased and edited version of the original design and
patch proposed by Jun'ichi Nomura:
  http://www.redhat.com/archives/dm-devel/2007-April/msg00025.html

Add support for parsing numbers, strings (quoted or unquoted), regexes
and operators amogst these operands in selection condition supplied.
---
 libdm/libdm-report.c |  277 ++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 277 insertions(+), 0 deletions(-)

diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 9bab350..64ec3b0 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -844,6 +844,283 @@ int dm_report_object(struct dm_report *rh, void *object)
 }
 
 /*
+ * Selection parsing
+ */
+
+/*
+ * Other tokens (FIELD, VALUE, STRING, NUMBER, REGEX)
+ *     FIELD := <strings of alphabet, number and '_'>
+ *     VALUE := NUMBER | STRING
+ *     REGEX := <strings quoted by '"', '\'', '(', '{', '[' or unquoted>
+ *     NUMBER := <strings of [0-9]> (because sort_value is unsigned)
+ *     STRING := <strings quoted by '"', '\'' or unquoted>
+ */
+
+static const char * _skip_space(const char *s)
+{
+	while (*s && isspace(*s))
+		s++;
+	return s;
+}
+
+static int _tok_op(struct op_def *t, const char *s, const char **end,
+		   uint32_t expect)
+{
+	size_t len;
+
+	s = _skip_space(s);
+
+	for (; t->string; t++) {
+		if (expect && !(t->flags & expect))
+			continue;
+
+		len = strlen(t->string);
+		if (!strncmp(s, t->string, len)) {
+			if (end)
+				*end = s + len;
+			return t->flags;
+		}
+	}
+
+	if (end)
+		*end = s;
+	return 0;
+}
+
+static inline int _tok_op_log(const char *s, const char **end, uint32_t expect)
+{
+	return _tok_op(_op_log, s, end, expect);
+}
+
+static inline int _tok_op_cmp(const char *s, const char **end)
+{
+	return _tok_op(_op_cmp, s, end, 0);
+}
+
+ /*
+  *
+  * Input:
+  *   s             - a pointer to the parsed string
+  * Output:
+  *   begin         - a pointer to the beginning of the token
+  *   end           - a pointer to the end of the token + 1
+  *                   or undefined if return value is NULL
+  *   return value  - a starting point of the next parsing or
+  *                   NULL if 's' doesn't match with token type
+  *                   (the parsing should be terminated)
+  */
+static const char *_tok_value_number(const char *s,
+				     const char **begin, const char **end)
+
+{
+	int is_float = 0;
+
+	*begin = s;
+	while (*s && ((!is_float && *s=='.' && (is_float=1)) || isdigit(*s)))
+		s++;
+	*end = s;
+
+	if (*begin == *end)
+		return NULL;
+
+	return s;
+}
+
+/*
+ * Input:
+ *   s               - a pointer to the parsed string
+ *   endchar         - terminating character
+ *   end_op_flags    - terminating operator flags (see _op_log)
+ *                     (if endchar is non-zero then endflags is ignored)
+ * Output:
+ *   begin           - a pointer to the beginning of the token
+ *   end             - a pointer to the end of the token + 1
+ *   end_op_flag_hit - the flag from endflags hit during parsing
+ *   return value    - a starting point of the next parsing
+ */
+static const char *_tok_value_string(const char *s,
+				     const char **begin, const char **end,
+				     const char endchar, uint32_t end_op_flags,
+				     uint32_t *end_op_flag_hit)
+{
+	uint32_t flag_hit = 0;
+
+	*begin = s;
+
+	/*
+	 * If endchar is defined, scan the string till
+	 * the endchar or the end of string is hit.
+	 * This is in case the string is quoted and we
+	 * know exact character that is the stopper.
+	 */
+	if (endchar) {
+		while (*s && *s != endchar)
+			s++;
+		if (*s != endchar) {
+			log_error("Missing end quote.");
+			return NULL;
+		}
+		*end = s;
+		s++;
+	} else {
+		/*
+		 * If endchar is not defined then endchar is/are the
+		 * operator/s as defined by 'endflags' arg or space char.
+		 * This is in case the string is not quoted and
+		 * we don't know which character is the exact stopper.
+		 */
+		while (*s) {
+			if ((flag_hit = _tok_op(_op_log, s, NULL, end_op_flags)) || *s == ' ')
+				break;
+			s++;
+		}
+		*end = s;
+		/*
+		 * If we hit one of the strings as defined by 'endflags'
+		 * and if 'endflag_hit' arg is provided, save the exact
+		 * string flag that was hit.
+		 */
+		if (end_op_flag_hit)
+			*end_op_flag_hit = flag_hit;
+	}
+
+	return s;
+}
+
+/*
+ * Input:
+ *   ft              - field type for which the value is parsed
+ *   s               - a pointer to the parsed string
+ * Output:
+ *   begin           - a pointer to the beginning of the token
+ *   end             - a pointer to the end of the token + 1
+ *   flags           - parsing flags
+ */
+static const char *_tok_value_regex(const struct dm_report_field_type *ft,
+				    const char *s, const char **begin,
+				    const char **end, uint32_t *flags)
+{
+	char c;
+
+	s = _skip_space(s);
+
+	if (!*s) {
+		log_error("Regular expression expected for selection field %s", ft->id);
+		return NULL;
+	}
+
+	switch (*s) {
+		case '(': c = ')'; break;
+		case '{': c = '}'; break;
+		case '[': c = ']'; break;
+		case '"':
+		case '\'': c = *s; break;
+		default:  c = 0;
+	}
+
+	if (!(s = _tok_value_string(c ? s + 1 : s, begin, end, c, SEL_AND | SEL_OR | SEL_PRECEDENCE_PE, NULL))) {
+		log_error("Failed to parse regex value for selection field %s.", ft->id);
+		return NULL;
+	}
+
+	*flags |= DM_REPORT_FIELD_TYPE_STRING;
+	return s;
+}
+
+/*
+ * Input:
+ *   ft              - field type for which the value is parsed
+ *   s               - a pointer to the parsed string
+ *   mem             - memory pool to allocate from
+ * Output:
+ *   begin           - a pointer to the beginning of the token
+ *   end             - a pointer to the end of the token + 1
+ *   flags           - parsing flags
+ *   custom          - custom data specific to token type
+ *                     (e.g. size unit factor)
+ */
+static const char *_tok_value(const struct dm_report_field_type *ft,
+			      const char *s, const char **begin,
+			      const char **end, uint32_t *flags,
+			      struct dm_pool *mem, void *custom)
+{
+	int expected_type = ft->flags & DM_REPORT_FIELD_TYPE_MASK;
+	uint64_t *factor;
+	const char *tmp;
+	char c = 0;
+
+	s = _skip_space(s);
+
+	switch (expected_type) {
+
+		case DM_REPORT_FIELD_TYPE_STRING:
+			if (*s == '"' || *s == '\'') {
+				c = *s;
+				s++;
+			}
+			if (!(s = _tok_value_string(s, begin, end, c, SEL_AND | SEL_OR | SEL_PRECEDENCE_PE, NULL))) {
+				log_error("Failed to parse string value "
+					  "for selection field %s.", ft->id);
+				return NULL;
+			}
+			*flags |= DM_REPORT_FIELD_TYPE_STRING;
+			break;
+
+		case DM_REPORT_FIELD_TYPE_NUMBER:
+		case DM_REPORT_FIELD_TYPE_SIZE:
+			if (!(s = _tok_value_number(s, begin, end))) {
+				log_error("Failed to parse numeric value "
+					  "for selection field %s.", ft->id);
+				return NULL;
+			}
+			factor = (uint64_t *) custom;
+			*factor = dm_units_to_factor(s, &c, 0, &tmp);
+
+			if (expected_type == DM_REPORT_FIELD_TYPE_NUMBER) {
+				if (*factor) {
+					log_error("Found size unit specifier but "
+						  "only numeric value expected for "
+						  "selection field %s.",ft->id);
+					return NULL;
+				}
+				*flags |= DM_REPORT_FIELD_TYPE_NUMBER;
+			} else {
+				s = tmp;
+				*flags |= DM_REPORT_FIELD_TYPE_SIZE;
+			}
+	}
+
+	return s;
+}
+
+/*
+ * Input:
+ *   s               - a pointer to the parsed string
+ * Output:
+ *   begin           - a pointer to the beginning of the token
+ *   end             - a pointer to the end of the token + 1
+ */
+static const char *_tok_field_name(const char *s,
+				    const char **begin, const char **end)
+{
+	char c;
+	s = _skip_space(s);
+
+	*begin = s;
+	while ((c = *s) &&
+	       (isalnum(c) || c == '_' || c == '-'))
+		s++;
+	*end = s;
+
+	if (*begin == *end)
+		return NULL;
+
+	return s;
+}
+
+
+
+/*
  * Print row of headings
  */
 static int _report_headings(struct dm_report *rh)


