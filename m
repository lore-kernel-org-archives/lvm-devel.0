From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 13 Aug 2014 14:10:26 +0000 (UTC)
Subject: master - select: add support for selection to match string list subset, recognize { } operator
Message-ID: <20140813141026.A7AF160E44@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fa793bed64a728185a9f8aa6196f0d411f89daf5
Commit:        fa793bed64a728185a9f8aa6196f0d411f89daf5
Parent:        6dd98c1fa89abb8ee9b91504a73d3a1c3f10e6d4
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Aug 13 15:39:03 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Aug 13 16:10:12 2014 +0200

select: add support for selection to match string list subset, recognize { } operator

Using "[ ]" operator together with "&&" (or ",") inside causes the
string list to be matched if and only if all the items given match
the value reported and the number of items also match. This is
strict list matching and the original behaviour we already have.

In contrast to that, the new "{ }" operator together with "&&" inside
causes the string list to be matched if and only if all the items given
match the value reported but the number of items don't need to match.
So we can provide a subset in selection criteria and if the subset
is found, it matches.

For example:

$ lvs -o name,tags
  LV    LV Tags
  lvol0 a
  lvol1 a,b
  lvol2 b,c,x
  lvol3 a,b,y

$ lvs -o name,tags -S 'tags=[a,b]'
  LV    LV Tags
  lvol1 a,b

$ lvs -o name,tags -S 'tags={a,b}'
  LV    LV Tags
  lvol1 a,b
  lvol3 a,b,y

So in the example above the a,b is subset of a,b,y and therefore
it also matches.

Clearly, when using "||" (or "#") inside, the { } and [ ] is the
same:

$ lvs -o name,tags -S 'tags=[a#b]'
  LV    LV Tags
  lvol0 a
  lvol1 a,b
  lvol2 b,c,x
  lvol3 a,b,y

$ lvs -o name,tags -S 'tags={a#b}'
  LV    LV Tags
  lvol0 a
  lvol1 a,b
  lvol2 b,c,x
  lvol3 a,b,y

Also in addition to the above feature, fix list with single value
matching when using [ ]:

Before this patch:
$ lvs -o name,tags -S 'tags=[a]'
  LV    LV Tags
  lvol0 a
  lvol1 a,b
  lvol3 a,b,y

With this patch applied:
$ lvs -o name,tags -S 'tags=[a]'
  LV    LV Tags
  lvol0 a

In case neither [] or {} is used, assume {} (the behaviour is not
changed here):

$ lvs -o name,tags -S 'tags=a'
  LV    LV Tags
  lvol0 a
  lvol1 a,b
  lvol3 a,b,y

So in new terms 'tags=a' is equal to 'tags={a}'.
---
 WHATS_NEW_DM         |    2 +
 libdm/libdm-report.c |  109 +++++++++++++++++++++++++++++++++++++++++---------
 2 files changed, 92 insertions(+), 19 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 7bb3f4c..cf74aca 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,7 @@
 Version 1.02.89 -
 =================================
+  Add support for selection to match string list subset, recognize { } operator.
+  Fix string list selection with '[value]' to not match list that's superset.
   Fix string list selection to match whole words only, not prefixes.
 
 Version 1.02.88 - 5th August 2014
diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 620283c..9363a92 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -131,6 +131,8 @@ static struct op_def _op_cmp[] = {
 #define SEL_LIST_MASK		0x000F0000
 #define SEL_LIST_LS		0x00010000
 #define SEL_LIST_LE		0x00020000
+#define SEL_LIST_SUBSET_LS	0x00040000
+#define SEL_LIST_SUBSET_LE	0x00080000
 
 static struct op_def _op_log[] = {
         { "&&", SEL_AND, "All fields must match" },
@@ -142,6 +144,8 @@ static struct op_def _op_log[] = {
         { ")", SEL_PRECEDENCE_PE, "Right parenthesis" },
         { "[", SEL_LIST_LS, "List start" },
         { "]", SEL_LIST_LE, "List end"},
+        { "{", SEL_LIST_SUBSET_LS, "List subset start"},
+        { "}", SEL_LIST_SUBSET_LE, "List subset end"},
         { NULL,  0, NULL},
 };
 
@@ -1247,9 +1251,9 @@ static int _cmp_field_string(const char *field_id, const char *a, const char *b,
 	return 0;
 }
 
-/* Matches if all items from selection string list match. */
-static int _cmp_field_string_list_all(const struct str_list_sort_value *val,
-				      const struct selection_str_list *sel)
+/* Matches if all items from selection string list match list value strictly 1:1. */
+static int _cmp_field_string_list_strict_all(const struct str_list_sort_value *val,
+					     const struct selection_str_list *sel)
 {
 	struct dm_str_list *sel_item;
 	unsigned int i = 1;
@@ -1269,7 +1273,36 @@ static int _cmp_field_string_list_all(const struct str_list_sort_value *val,
 	return 1;
 }
 
-/* Matches if any item from selection string list matches. */
+/* Matches if all items from selection string list match a subset of list value. */
+static int _cmp_field_string_list_subset_all(const struct str_list_sort_value *val,
+					     const struct selection_str_list *sel)
+{
+	struct dm_str_list *sel_item;
+	unsigned int i = 1, last_found = 1;;
+	int r = 0;
+
+	/* if value has no items and selection has at leas one, it's clear there's no match */
+	if ((val->items[0].len == 0) && dm_list_size(sel->list))
+		return 0;
+
+	/* Check selection is a subset of the value. */
+	dm_list_iterate_items(sel_item, sel->list) {
+		r = 0;
+		for (i = last_found; i <= val->items[0].len; i++) {
+			if ((strlen(sel_item->str) == val->items[i].len) &&
+			    !strncmp(sel_item->str, val->value + val->items[i].pos, val->items[i].len)) {
+				last_found = i;
+				r = 1;
+			}
+		}
+		if (!r)
+			break;
+	}
+
+	return r;
+}
+
+/* Matches if any item from selection string list matches list value. */
 static int _cmp_field_string_list_any(const struct str_list_sort_value *val,
 				      const struct selection_str_list *sel)
 {
@@ -1299,11 +1332,24 @@ static int _cmp_field_string_list(const char *field_id,
 				  const struct str_list_sort_value *value,
 				  const struct selection_str_list *selection, uint32_t flags)
 {
-	int r;
+	int subset, r;
+
+	switch (selection->type & SEL_LIST_MASK) {
+		case SEL_LIST_LS:
+			subset = 0;
+			break;
+		case SEL_LIST_SUBSET_LS:
+			subset = 1;
+			break;
+		default:
+			log_error(INTERNAL_ERROR "_cmp_field_string_list: unknown list type");
+			return 0;
+	}
 
 	switch (selection->type & SEL_MASK) {
 		case SEL_AND:
-			r = _cmp_field_string_list_all(value, selection);
+			r = subset ? _cmp_field_string_list_subset_all(value, selection)
+				   : _cmp_field_string_list_strict_all(value, selection);
 			break;
 		case SEL_OR:
 			r = _cmp_field_string_list_any(value, selection);
@@ -1932,11 +1978,11 @@ static const char *_tok_value_string_list(const struct dm_report_field_type *ft,
 	struct selection_str_list *ssl = NULL;
 	struct dm_str_list *item;
 	const char *begin_item, *end_item, *tmp;
-	uint32_t end_op_flags, end_op_flag_hit = 0;
+	uint32_t op_flags, end_op_flag_expected, end_op_flag_hit = 0;
 	struct dm_str_list **arr;
 	size_t list_size;
 	unsigned int i;
-	int list_end;
+	int list_end = 0;
 	char c;
 
 	if (!(ssl = dm_pool_alloc(mem, sizeof(*ssl))) ||
@@ -1948,8 +1994,8 @@ static const char *_tok_value_string_list(const struct dm_report_field_type *ft,
 	ssl->type = 0;
 	*begin = s;
 
-	if (!_tok_op_log(s, &tmp, SEL_LIST_LS)) {
-		/* Only one item - SEL_LIST_LS and SEL_LIST_LE not used */
+	if (!(op_flags = _tok_op_log(s, &tmp, SEL_LIST_LS | SEL_LIST_SUBSET_LS))) {
+		/* Only one item - SEL_LIST_{SUBSET_}LS and SEL_LIST_{SUBSET_}LE not used */
 		c = _get_and_skip_quote_char(&s);
 		if (!(s = _tok_value_string(s, &begin_item, &end_item, c, SEL_AND | SEL_OR | SEL_PRECEDENCE_PE, NULL))) {
 			log_error(_str_list_item_parsing_failed, ft->id);
@@ -1957,32 +2003,47 @@ static const char *_tok_value_string_list(const struct dm_report_field_type *ft,
 		}
 		if (!_add_item_to_string_list(mem, begin_item, end_item, ssl->list))
 			goto_bad;
-		ssl->type = SEL_OR;
+		ssl->type = SEL_OR | SEL_LIST_LS;
 		goto out;
 	}
 
-	/* More than one item - items enclosed in SEL_LIST_LS and SEL_LIST_LE.
+	/* More than one item - items enclosed in SEL_LIST_LS and SEL_LIST_LE
+	 * or SEL_LIST_SUBSET_LS and SEL_LIST_SUBSET_LE.
 	 * Each element is terminated by AND or OR operator or 'list end'.
 	 * The first operator hit is then the one allowed for the whole list,
 	 * no mixing allowed!
 	 */
-	end_op_flags = SEL_LIST_LE | SEL_AND | SEL_OR;
+
+	/* Are we using [] or {} for the list? */
+	end_op_flag_expected = (op_flags == SEL_LIST_LS) ? SEL_LIST_LE : SEL_LIST_SUBSET_LE;
+
+	op_flags = SEL_LIST_LE | SEL_LIST_SUBSET_LE | SEL_AND | SEL_OR;
 	s++;
 	while (*s) {
 		s = _skip_space(s);
 		c = _get_and_skip_quote_char(&s);
-		if (!(s = _tok_value_string(s, &begin_item, &end_item, c, end_op_flags, NULL))) {
+		if (!(s = _tok_value_string(s, &begin_item, &end_item, c, op_flags, NULL))) {
 			log_error(_str_list_item_parsing_failed, ft->id);
 			goto bad;
 		}
 		s = _skip_space(s);
 
-		if (!(end_op_flag_hit = _tok_op_log(s, &tmp, end_op_flags))) {
+		if (!(end_op_flag_hit = _tok_op_log(s, &tmp, op_flags))) {
 			log_error("Invalid operator in selection list.");
 			goto bad;
 		}
 
-		list_end = end_op_flag_hit == SEL_LIST_LE;
+		if (end_op_flag_hit & (SEL_LIST_LE | SEL_LIST_SUBSET_LE)) {
+			list_end = 1;
+			if (end_op_flag_hit != end_op_flag_expected) {
+				for (i = 0; _op_log[i].string; i++)
+					if (_op_log[i].flags == end_op_flag_expected)
+						break;
+				log_error("List ended with incorrect character, "
+					  "expecting \'%s\'.", _op_log[i].string);
+				goto bad;
+			}
+		}
 
 		if (ssl->type) {
 			if (!list_end && !(ssl->type & end_op_flag_hit)) {
@@ -1990,8 +2051,12 @@ static const char *_tok_value_string_list(const struct dm_report_field_type *ft,
 					  "in selection list at a time.");
 				goto bad;
 			}
-		} else
-			ssl->type = list_end ? SEL_OR : end_op_flag_hit;
+		} else {
+			if (list_end)
+				ssl->type = end_op_flag_expected == SEL_LIST_LE ? SEL_AND : SEL_OR;
+			else
+				ssl->type = end_op_flag_hit;
+		}
 
 		if (!_add_item_to_string_list(mem, begin_item, end_item, ssl->list))
 			goto_bad;
@@ -2002,11 +2067,17 @@ static const char *_tok_value_string_list(const struct dm_report_field_type *ft,
 			break;
 	}
 
-	if (end_op_flag_hit != SEL_LIST_LE) {
+	if (!(end_op_flag_hit & (SEL_LIST_LE | SEL_LIST_SUBSET_LE))) {
 		log_error("Missing list end for selection field %s", ft->id);
 		goto bad;
 	}
 
+	/* Store information whether [] or {} was used. */
+	if ((end_op_flag_expected == SEL_LIST_LE))
+		ssl->type |= SEL_LIST_LS;
+	else
+		ssl->type |= SEL_LIST_SUBSET_LS;
+
 	/* Sort the list. */
 	if (!(list_size = dm_list_size(ssl->list))) {
 		log_error(INTERNAL_ERROR "_tok_value_string_list: list has no items");


