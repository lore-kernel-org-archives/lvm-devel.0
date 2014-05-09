From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri,  9 May 2014 06:56:52 +0000 (UTC)
Subject: dev-prajnoha-selout - selout: add supporting infrastucture for token parsing in report selections
Message-ID: <20140509065652.2D56B60F95@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=55a278edb71f3fbe9b2c77e5106cea14e66e1b39
Commit:        55a278edb71f3fbe9b2c77e5106cea14e66e1b39
Parent:        6ab77a026b93fb1e10a1c10a5ae3d4ff527cf0d9
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Apr 28 11:56:48 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri May 9 08:51:00 2014 +0200

selout: add supporting infrastucture for token parsing in report selections

---
 libdm/libdm-report.c |  213 ++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 213 insertions(+), 0 deletions(-)

diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 9cd9028..150022b 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -837,6 +837,219 @@ int dm_report_object(struct dm_report *rh, void *object)
 }
 
 /*
+ * Selection parsing
+ */
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
+			*end = s + len;
+			return t->flags;
+		}
+	}
+
+	*end = s;
+	return 0;
+}
+
+static int _tok_op_log(const char *s, const char **end, uint32_t expect)
+{
+	return _tok_op(_op_log, s, end, expect);
+}
+
+static int _tok_op_cmp(const char *s, const char **end)
+{
+	return _tok_op(_op_cmp, s, end, 0);
+}
+
+/*
+ * Other tokens (FIELD, VALUE, STRING, NUMBER, REGEX)
+ *     FIELD := <strings of alphabet, number and '_'>
+ *     VALUE := NUMBER | STRING
+ *     REGEX := <strings quoted by any character>
+ *     NUMBER := <strings of [0-9]> (because sort_value is unsigned)
+ *     STRING := <strings quoted by '"' or '\''>
+ *
+ * _tok_* functions
+ *
+ *   Input:
+ *     s             - a pointer to the parsed string
+ *   Output:
+ *     begin         - a pointer to the beginning of the token
+ *     end           - a pointer to the end of the token + 1
+ *                     or undefined if return value is NULL
+ *     is_float      - set if the number is a floating point number
+ *     return value  - a starting point of the next parsing
+ *                     NULL if s doesn't match with token type
+ *                     (the parsing should be terminated)
+ */
+static const char *_tok_number(const char *s,
+				const char **begin, const char **end)
+
+{
+	int is_float = 0;
+
+	*begin = s;
+	while (*s && ((!is_float && *s=='.' && (is_float=1)) || isdigit(*s)))
+		s++;
+	*end = s;
+
+	return s;
+}
+
+static const char *_tok_string(const char *s,
+			       const char **begin, const char **end,
+			       const char endchar)
+{
+	*begin = s;
+
+	if (endchar)
+		while (*s && *s != endchar)
+			s++;
+	else
+		/*
+		 * If endchar not defined then endchar is AND/OR operator or
+		 * '(' or space char. This is in case the string is not quoted.
+		 */
+		while (*s) {
+			if (!strncmp(s, SEL_AND_TOK, strlen(SEL_AND_TOK)) ||
+			    !strncmp(s, SEL_OR_TOK, strlen(SEL_OR_TOK)) ||
+			    !strncmp(s, SEL_PE_TOK, strlen(SEL_PE_TOK)) ||
+			    (*s == ' '))
+				break;
+			s++;
+		}
+
+	*end = s;
+	return s;
+}
+
+static const char *_tok_regex(const struct dm_report_field_type *ft,
+			      const char *s, const char **begin,
+			      const char **end, uint32_t *flags)
+{
+	char c;
+
+	s = _skip_space(s);
+
+	if (!*s) {
+		log_error("Regular expression expected for field %s", ft->id);
+		return NULL;
+	}
+
+	switch (*s) {
+		case '(': c = ')'; break;
+		case '{': c = '}'; break;
+		case '[': c = ']'; break;
+		default:  c = *s;
+	}
+
+	s = _tok_string(s + 1, begin, end, c);
+	if (!*s) {
+		log_error("Missing end quote of regex for field %s", ft->id);
+		return NULL;
+	}
+	s++;
+
+	*flags |= DM_REPORT_FIELD_TYPE_STRING;
+
+	return s;
+}
+
+static const char *_tok_value(const struct dm_report_field_type *ft,
+			      const char *s, const char **begin,
+			      const char **end, uint64_t *factor,
+			      uint32_t *flags)
+{
+	int expected_type = ft->flags & DM_REPORT_FIELD_TYPE_MASK;
+	char *tmp;
+	char c;
+
+	s = _skip_space(s);
+
+	switch (expected_type) {
+
+		case DM_REPORT_FIELD_TYPE_STRING:
+			if (*s == '"' || *s == '\'') {
+				c = *s;
+				s++;
+			} else
+				c = 0;
+			s = _tok_string(s, begin, end, c);
+			if (c && !*s) {
+				log_error("Failed to parse string value "
+					  "for field %s.", ft->id);
+				return NULL;
+			}
+			if (c)
+				s++;
+			*flags |= DM_REPORT_FIELD_TYPE_STRING;
+			break;
+
+		case DM_REPORT_FIELD_TYPE_NUMBER:
+		case DM_REPORT_FIELD_TYPE_SIZE:
+			s = _tok_number(s, begin, end);
+			if (*begin == *end) {
+				log_error("Failed to parse numeric value "
+					  "for field %s.", ft->id);
+				return NULL;
+			}
+			*factor = dm_units_to_factor(s, &c, 0, &tmp);
+
+			if (expected_type == DM_REPORT_FIELD_TYPE_NUMBER) {
+				if (factor) {
+					log_error("Found size unit specifier but "
+						  "only numeric value expected for "
+						  "field %s.",ft->id);
+					return NULL;
+				}
+				*flags |= DM_REPORT_FIELD_TYPE_NUMBER;
+			} else {
+				s = (const char *) tmp;
+				*flags |= DM_REPORT_FIELD_TYPE_SIZE;
+			}
+	}
+
+	return s;
+}
+
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


