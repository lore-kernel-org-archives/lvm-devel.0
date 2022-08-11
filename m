From: Peter Rajnoha <prajnoha@sourceware.org>
Date: Thu, 11 Aug 2022 11:06:06 +0000 (GMT)
Subject: main - libdm: report: enhance the way string list is stored internally
Message-ID: <20220811110606.5D6A53858C74@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=31cd8346ae92fcc32ce4f2f60f7962e620a7b12f
Commit:        31cd8346ae92fcc32ce4f2f60f7962e620a7b12f
Parent:        1e31621cebfb38f652233e2f80dd081cca5e8374
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Jun 28 17:00:00 2022 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Aug 11 11:10:11 2022 +0200

libdm: report: enhance the way string list is stored internally

Before, we stored only the report string itself for a string list
in field->report_string. The field->report_string has either
sorted items or not, depending on what we need for a field -
some report fields have sorted output, some don't...

The field->sort_value.value then contains pointer to the exact
field->report_string. The field->sort_value.items ALWAYS keeps
sorted array of individual items, represented as '[position,length]'
pairs pointing to the field->sort_value.value string.

This approach was fine as far as we didn't need to apply further
formatting to field->report_string. However, if we need to apply
further formatting to field->report_string content, taking into
account individual items, we also need to know where each item
starts and what is its length. Before, we only knew this when
items in report string were sorted, but not in the unsorted version.

We can't rely on the delimiter (default ",") only to separate items
back out of report string, because that delimiter can be contained
in the item value itself.

So this patch enhances the field->report_string for a string list so
it also contains '[position,length]' pairs for each individual item
inside field->report_string. We store this array right beyond the
string itself and we encode it in the same manner we already did for
field->sort_value.items before.

If field->report_string has sorted items, the field->sort_value.items
just points to the array of items we store beyond the report string.
If field->report_string has unsorted items, we store separate array
of items for both field->report_string and field->sort_value.

This patch also cleans up the _report_field_string_list function a bit
so it's easier and more straightforward to follow than the original
version.

Example. If we have "abc", "xy", "defgh" as list on input with ","
as delimiter, then:

  - field->report_string will have:

    - if we need field->report_string unsorted:

        abc,xy,defgh\0{[3,12],[0,3],[4,2],[7,5]}
        |____________||________________________|
           string      array of [pos,len] pairs
                       |____||________________|
                       #items      items

    - if we need field->report_string sorted:

                 repstr_extra
                      |
                      V
        abc,defgh,xy\0{[3,12],[0,3],[4,5],[10,2]}
        |____________||________________________|
           string      array of [pos,len] pairs
                       |____||________________|
                       #items      items

  - field->sort_value will have:

    - if field->report_string is unsorted:

        field->sort_value.value = field->report_string
        field->sort_value.items = {[0,3],[0,3],[7,5],[4,2]}
                                    (that is 'abc,defgh,xy')

    - if field->report_string is sorted already:

        field->sort_value.value = field->report_string
        field->sort_value.items = repstr_extra
                                  (that is also 'abc,defgh,xy')
---
 device_mapper/libdm-report.c | 306 +++++++++++++++++++++++++++----------------
 libdm/libdm-report.c         | 306 +++++++++++++++++++++++++++----------------
 2 files changed, 380 insertions(+), 232 deletions(-)

diff --git a/device_mapper/libdm-report.c b/device_mapper/libdm-report.c
index 3c4b01127..aab7bdd63 100644
--- a/device_mapper/libdm-report.c
+++ b/device_mapper/libdm-report.c
@@ -384,172 +384,246 @@ int dm_report_field_percent(struct dm_report *rh,
 	return 1;
 }
 
-struct str_list_sort_value_item {
+struct pos_len {
 	unsigned pos;
 	size_t len;
 };
 
-struct str_list_sort_value {
-	const char *value;
-	struct str_list_sort_value_item *items;
+struct str_pos_len {
+	const char *str;
+	struct pos_len item;
 };
 
-struct str_list_sort_item {
-	const char *str;
-	struct str_list_sort_value_item item;
+struct str_list_sort_value {
+	const char *value;
+	struct pos_len *items;
 };
 
-static int _str_list_sort_item_cmp(const void *a, const void *b)
+static int _str_sort_cmp(const void *a, const void *b)
 {
-	const struct str_list_sort_item *slsi_a = (const struct str_list_sort_item *) a;
-	const struct str_list_sort_item *slsi_b = (const struct str_list_sort_item *) b;
-
-	return strcmp(slsi_a->str, slsi_b->str);
+	return strcmp(((const struct str_pos_len *) a)->str, ((const struct str_pos_len *) b)->str);
 }
 
+#define FIELD_STRING_LIST_DEFAULT_DELIMITER ","
+
 static int _report_field_string_list(struct dm_report *rh,
 				     struct dm_report_field *field,
 				     const struct dm_list *data,
 				     const char *delimiter,
-				     int sort)
+				     int sort_repstr)
 {
-	static const char _string_list_grow_object_failed_msg[] = "dm_report_field_string_list: dm_pool_grow_object_failed";
-	struct str_list_sort_value *sort_value = NULL;
-	unsigned int list_size, pos, i;
-	struct str_list_sort_item *arr = NULL;
+	static const char _error_msg_prefix[] = "_report_field_string_list: ";
+	unsigned int list_size, i, pos;
+	struct str_pos_len *arr = NULL;
 	struct dm_str_list *sl;
-	size_t delimiter_len, len;
-	void *object;
+	size_t delimiter_len, repstr_str_len, repstr_size;
+	char *repstr = NULL;
+	struct pos_len *repstr_extra;
+	struct str_list_sort_value *sortval = NULL;
 	int r = 0;
 
-	if (!(sort_value = dm_pool_zalloc(rh->mem, sizeof(struct str_list_sort_value)))) {
-		log_error("dm_report_field_string_list: dm_pool_zalloc failed for sort_value");
-		return 0;
-	}
-
-	list_size = dm_list_size(data);
-
 	/*
-	 * Sort value stores the pointer to the report_string and then
-	 * position and length for each list element withing the report_string.
-	 * The first element stores number of elements in 'len' (therefore
-	 * list_size + 1 is used below for the extra element).
-	 * For example, with this input:
-	 *   sort = 0;  (we don't want to report sorted)
-	 *   report_string = "abc,xy,defgh";  (this is reported)
+	 * The 'field->report_string' has 2 parts:
+	 *
+	 *    - string representing the whole string list
+	 *      (terminated by '\0' at its end as usual)
+	 *
+	 *    - extra info beyond the end of the string representing
+	 *      position and length of each list item within the
+	 *      field->report_string (array of 'struct pos_len')
+	 *
+	 * We can use the extra info to unambiguously identify list items,
+	 * the delimiter is not enough here as it's not assured it won't appear
+	 * in list item itself. We will make use of this extra info in case
+	 * we need to apply further formatting to the list in dm_report_output
+	 * where the pure field->report_string is not enough for printout.
+	 *
+	 *
+	 * The 'field->sort_value' contains a value of type 'struct
+	 * str_list_sort_value' ('sortval'). This one has a pointer to the
+	 * 'field->report_string' string ('sortval->value') and info
+	 * about position and length of each list item within the string
+	 * (array of 'struct pos_len').
+	 *
+	 *
+	 * The 'field->report_string' is either in sorted or unsorted form,
+	 * depending on 'sort_repstr' arg.
 	 *
-	 * ...we end up with:
-	 *   sort_value->value = report_string; (we'll use the original report_string for indices)
-	 *   sort_value->items[0] = {0,3};  (we have 3 items)
-	 *   sort_value->items[1] = {0,3};  ("abc")
-	 *   sort_value->items[2] = {7,5};  ("defgh")
-	 *   sort_value->items[3] = {4,2};  ("xy")
+	 * The 'field->sort_value.items' is always in sorted form because
+	 * we need that for effective sorting and selection.
 	 *
-	 *   The items alone are always sorted while in report_string they can be
-	 *   sorted or not (based on "sort" arg) - it depends on how we prefer to
-	 *   display the list. Having items sorted internally helps with searching
-	 *   through them.
+	 * If 'field->report_string' is sorted, then field->report_string
+	 * and field->sort_value.items share the same array of
+	 * 'struct pos_len' (because they're both sorted the same way),
+	 * otherwise, each one has its own array.
+	 *
+	 * The very first item in the array of 'struct pos_len' is always
+	 * a pair denoting '[list_size,strlen(field->report_string)]'. The
+	 * rest of items denote start and lenght of each item in the list.
+         *
+	 *
+	 * For example, if we have a list with "abc", "xy", "defgh"
+	 * as input and delimiter is ",", we end up with either:
+	 *
+	 *  A) if we don't want the report string sorted ('sort_repstr == 0'):
+	 *
+	 *    - field->report_string = repstr
+	 *
+	 *       repstr      repstr_extra
+	 *         |             |
+	 *         V             V
+	 *         abc,xy,defgh\0{[3,12],[0,3],[4,2],[7,5]}
+	 *         |____________||________________________|
+	 *             string     array of struct pos_len
+	 *                        |____||________________|
+	 *                        #items      items
+	 *
+	 *    - field->sort_value = sortval
+	 *
+	 *       sortval->value = repstr
+	 *       sortval->items = {[3,12],[0,3],[7,5],[4,2]}
+	 *                         (that is 'abc,defgh,xy')
+	 *
+	 *
+	 *  B) if we want the report string sorted ('sort_repstr == 1'):
+	 *
+	 *    - field->report_string = repstr
+	 *
+	 *       repstr     repstr_extra
+	 *         |             |
+	 *         V             V
+	 *         abc,defgh,xy\0{[3,12],[0,3],[4,5],[10,2]}
+	 *         |____________||________________________|
+	 *             string     array of struct pos_len
+	 *                        |____||________________|
+	 *                        #items      items
+	 *
+	 *     - field->sort_value = sortval
+	 *
+	 *       sortval->value = repstr
+	 *       sortval->items = repstr_extra
+	 *                       (that is 'abc,defgh,xy')
 	 */
-	if (!(sort_value->items = dm_pool_zalloc(rh->mem, (list_size + 1) * sizeof(struct str_list_sort_value_item)))) {
-		log_error("dm_report_fiel_string_list: dm_pool_zalloc failed for sort value items");
+
+	if (!delimiter)
+		delimiter = FIELD_STRING_LIST_DEFAULT_DELIMITER;
+	delimiter_len = strlen(delimiter);
+	list_size = dm_list_size(data);
+
+	if (!(sortval = dm_pool_alloc(rh->mem, sizeof(struct str_list_sort_value)))) {
+		log_error("%s failed to allocate sort value structure", _error_msg_prefix);
 		goto out;
 	}
-	sort_value->items[0].len = list_size;
 
 	/* zero items */
-	if (!list_size) {
-		sort_value->value = field->report_string = "";
-		field->sort_value = sort_value;
+	if (list_size == 0) {
+		field->report_string = sortval->value = "";
+		sortval->items = NULL;
+		field->sort_value = sortval;
 		return 1;
 	}
 
 	/* one item */
 	if (list_size == 1) {
 		sl = (struct dm_str_list *) dm_list_first(data);
-		if (!sl ||
-		    !(sort_value->value = field->report_string = dm_pool_strdup(rh->mem, sl->str))) {
-			log_error("dm_report_field_string_list: dm_pool_strdup failed");
+
+		repstr_str_len = strlen(sl->str);
+		repstr_size = repstr_str_len + 1 + (2 * sizeof(struct pos_len));
+
+		if (!(repstr = dm_pool_alloc(rh->mem, repstr_size))) {
+			log_error("%s failed to allocate report string structure", _error_msg_prefix);
 			goto out;
 		}
-		sort_value->items[1].pos = 0;
-		sort_value->items[1].len = strlen(sl->str);
-		field->sort_value = sort_value;
-		return 1;
-	}
+		repstr_extra = (struct pos_len *) (repstr + repstr_str_len + 1);
 
-	/* more than one item - sort the list */
-	if (!(arr = malloc(sizeof(struct str_list_sort_item) * list_size))) {
-		log_error("dm_report_field_string_list: malloc failed");
-		goto out;
+		memcpy(repstr, sl->str, repstr_str_len + 1);
+		memcpy(repstr_extra, &((struct pos_len) {.pos = 1, .len = repstr_str_len}), sizeof(struct pos_len));
+		memcpy(repstr_extra + 1, &((struct pos_len) {.pos = 0, .len = repstr_str_len}), sizeof(struct pos_len));
+
+		sortval->value = field->report_string = repstr;
+		sortval->items = repstr_extra;
+		field->sort_value = sortval;
+		return 1;
 	}
 
-	if (!(dm_pool_begin_object(rh->mem, 256))) {
-		log_error(_string_list_grow_object_failed_msg);
+	/* more than one item - allocate temporary array for string list items for further processing */
+	if (!(arr = malloc(list_size * sizeof(struct str_pos_len)))) {
+		log_error("%s failed to allocate temporary array for processing", _error_msg_prefix);
 		goto out;
 	}
 
-	if (!delimiter)
-		delimiter = ",";
-	delimiter_len = strlen(delimiter);
-
-	i = pos = 0;
+	i = 0;
+	repstr_size = 0;
 	dm_list_iterate_items(sl, data) {
 		arr[i].str = sl->str;
-		if (!sort) {
-			/* sorted outpud not required - report the list as it is */
-			len = strlen(sl->str);
-			if (!dm_pool_grow_object(rh->mem, arr[i].str, len) ||
-			    (i+1 != list_size && !dm_pool_grow_object(rh->mem, delimiter, delimiter_len))) {
-				log_error(_string_list_grow_object_failed_msg);
-				goto out;
-			}
-			arr[i].item.pos = pos;
-			arr[i].item.len = len;
-			pos = i+1 == list_size ? pos+len : pos+len+delimiter_len;
-		}
+		repstr_size += (arr[i].item.len = strlen(sl->str));
 		i++;
 	}
 
-	qsort(arr, i, sizeof(struct str_list_sort_item), _str_list_sort_item_cmp);
+	/*
+	 * At this point, repstr_size contains sum of lengths of all string list items.
+	 * Now, add these to the repstr_size:
+	 *
+	 * 	--> sum of character count used by all delimiters: + ((list_size - 1) * delimiter_len)
+	 *
+	 * 	--> '\0' used at the end of the string list: + 1
+	 *
+	 * 	--> sum of structures used to keep info about pos and length of each string list item:
+	 * 	    [0, <list_size>] [<pos1>,<size1>] [<pos2>,<size2>] ...
+	 * 	    That is: + ((list_size + 1) * sizeof(struct pos_len))
+	 */
+	repstr_size += ((list_size - 1) * delimiter_len);
+	repstr_str_len = repstr_size;
+	repstr_size += 1 + ((list_size + 1) * sizeof(struct pos_len));
+
+	if (sort_repstr)
+		qsort(arr, list_size, sizeof(struct str_pos_len), _str_sort_cmp);
 
+	if (!(repstr = dm_pool_alloc(rh->mem, repstr_size))) {
+		log_error("%s failed to allocate report string structure", _error_msg_prefix);
+		goto out;
+	}
+	repstr_extra = (struct pos_len *) (repstr + repstr_str_len + 1);
+
+	memcpy(repstr_extra, &(struct pos_len) {.pos = list_size, .len = repstr_str_len}, sizeof(struct pos_len));
 	for (i = 0, pos = 0; i < list_size; i++) {
-		if (sort) {
-			/* sorted output required - report the list as sorted */
-			len = strlen(arr[i].str);
-			if (!dm_pool_grow_object(rh->mem, arr[i].str, len) ||
-			    (i+1 != list_size && !dm_pool_grow_object(rh->mem, delimiter, delimiter_len))) {
-				log_error(_string_list_grow_object_failed_msg);
-				goto out;
-			}
-			/*
-			 * Save position and length of the string
-			 * element in report_string for sort_value.
-			 * Use i+1 here since items[0] stores list size!!!
-			 */
-			sort_value->items[i+1].pos = pos;
-			sort_value->items[i+1].len = len;
-			pos = i+1 == list_size ? pos+len : pos+len+delimiter_len;
-		} else {
-			sort_value->items[i+1].pos = arr[i].item.pos;
-			sort_value->items[i+1].len = arr[i].item.len;
+		arr[i].item.pos = pos;
+
+		memcpy(repstr + pos, arr[i].str, arr[i].item.len);
+		memcpy(repstr_extra + i + 1, &arr[i].item, sizeof(struct pos_len));
+
+		pos += arr[i].item.len;
+		if (i + 1 < list_size) {
+			memcpy(repstr + pos, delimiter, delimiter_len);
+			pos += delimiter_len;
 		}
 	}
+	*(repstr + pos) = '\0';
 
-	if (!dm_pool_grow_object(rh->mem, "\0", 1)) {
-		log_error(_string_list_grow_object_failed_msg);
-		goto out;
+	sortval->value = repstr;
+	if (sort_repstr)
+		sortval->items = repstr_extra;
+	else {
+		if (!(sortval->items = dm_pool_alloc(rh->mem, (list_size + 1) * sizeof(struct pos_len)))) {
+			log_error("%s failed to allocate array of items inside sort value structure",
+				  _error_msg_prefix);
+			goto out;
+		}
+
+		qsort(arr, list_size, sizeof(struct str_pos_len), _str_sort_cmp);
+
+		sortval->items[0] = (struct pos_len) {.pos = list_size, .len = repstr_str_len};
+		for (i = 0; i < list_size; i++)
+			sortval->items[i+1] = arr[i].item;
 	}
 
-	object = dm_pool_end_object(rh->mem);
-	sort_value->value = object;
-	field->sort_value = sort_value;
-	field->report_string = object;
+	field->report_string = repstr;
+	field->sort_value = sortval;
 	r = 1;
 out:
-	if (!r && sort_value)
-		dm_pool_free(rh->mem, sort_value);
+	if (!r && sortval)
+		dm_pool_free(rh->mem, sortval);
 	free(arr);
-
 	return r;
 }
 
@@ -1688,7 +1762,7 @@ static int _cmp_field_string_list_strict_all(const struct str_list_sort_value *v
 	struct dm_str_list *sel_item;
 	unsigned int i = 1;
 
-	if (!val->items[0].len) {
+	if (!val->items) {
 		if (sel_list_size == 1) {
 			/* match blank string list with selection defined as blank string only */
 			sel_item = dm_list_item(dm_list_first(&sel->str_list.list), struct dm_str_list);
@@ -1698,7 +1772,7 @@ static int _cmp_field_string_list_strict_all(const struct str_list_sort_value *v
 	}
 
 	/* if item count differs, it's clear the lists do not match */
-	if (val->items[0].len != sel_list_size)
+	if (val->items[0].pos != sel_list_size)
 		return 0;
 
 	/* both lists are sorted so they either match 1:1 or not */
@@ -1721,7 +1795,7 @@ static int _cmp_field_string_list_subset_all(const struct str_list_sort_value *v
 	unsigned int i, last_found = 1;
 	int r = 0;
 
-	if (!val->items[0].len) {
+	if (!val->items) {
 		if (sel_list_size == 1) {
 			/* match blank string list with selection defined as blank string only */
 			sel_item = dm_list_item(dm_list_first(&sel->str_list.list), struct dm_str_list);
@@ -1733,7 +1807,7 @@ static int _cmp_field_string_list_subset_all(const struct str_list_sort_value *v
 	/* check selection is a subset of the value */
 	dm_list_iterate_items(sel_item, &sel->str_list.list) {
 		r = 0;
-		for (i = last_found; i <= val->items[0].len; i++) {
+		for (i = last_found; i <= val->items[0].pos; i++) {
 			if ((strlen(sel_item->str) == val->items[i].len) &&
 			    !strncmp(sel_item->str, val->value + val->items[i].pos, val->items[i].len)) {
 				last_found = i;
@@ -1755,7 +1829,7 @@ static int _cmp_field_string_list_any(const struct str_list_sort_value *val,
 	unsigned int i;
 
 	/* match blank string list with selection that contains blank string */
-	if (!val->items[0].len) {
+	if (!val->items) {
 		dm_list_iterate_items(sel_item, &sel->str_list.list) {
 			if (!strcmp(sel_item->str, ""))
 				return 1;
@@ -1768,7 +1842,7 @@ static int _cmp_field_string_list_any(const struct str_list_sort_value *val,
 		 * TODO: Optimize this so we don't need to compare the whole lists' content.
 		 *       Make use of the fact that the lists are sorted!
 		 */
-		for (i = 1; i <= val->items[0].len; i++) {
+		for (i = 1; i <= val->items[0].pos; i++) {
 			if ((strlen(sel_item->str) == val->items[i].len) &&
 			    !strncmp(sel_item->str, val->value + val->items[i].pos, val->items[i].len))
 				return 1;
diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index df52ee088..9fac341a4 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -383,172 +383,246 @@ int dm_report_field_percent(struct dm_report *rh,
 	return 1;
 }
 
-struct str_list_sort_value_item {
+struct pos_len {
 	unsigned pos;
 	size_t len;
 };
 
-struct str_list_sort_value {
-	const char *value;
-	struct str_list_sort_value_item *items;
+struct str_pos_len {
+	const char *str;
+	struct pos_len item;
 };
 
-struct str_list_sort_item {
-	const char *str;
-	struct str_list_sort_value_item item;
+struct str_list_sort_value {
+	const char *value;
+	struct pos_len *items;
 };
 
-static int _str_list_sort_item_cmp(const void *a, const void *b)
+static int _str_sort_cmp(const void *a, const void *b)
 {
-	const struct str_list_sort_item *slsi_a = (const struct str_list_sort_item *) a;
-	const struct str_list_sort_item *slsi_b = (const struct str_list_sort_item *) b;
-
-	return strcmp(slsi_a->str, slsi_b->str);
+	return strcmp(((const struct str_pos_len *) a)->str, ((const struct str_pos_len *) b)->str);
 }
 
+#define FIELD_STRING_LIST_DEFAULT_DELIMITER ","
+
 static int _report_field_string_list(struct dm_report *rh,
 				     struct dm_report_field *field,
 				     const struct dm_list *data,
 				     const char *delimiter,
-				     int sort)
+				     int sort_repstr)
 {
-	static const char _string_list_grow_object_failed_msg[] = "dm_report_field_string_list: dm_pool_grow_object_failed";
-	struct str_list_sort_value *sort_value = NULL;
-	unsigned int list_size, pos, i;
-	struct str_list_sort_item *arr = NULL;
+	static const char _error_msg_prefix[] = "_report_field_string_list: ";
+	unsigned int list_size, i, pos;
+	struct str_pos_len *arr = NULL;
 	struct dm_str_list *sl;
-	size_t delimiter_len, len;
-	void *object;
+	size_t delimiter_len, repstr_str_len, repstr_size;
+	char *repstr = NULL;
+	struct pos_len *repstr_extra;
+	struct str_list_sort_value *sortval = NULL;
 	int r = 0;
 
-	if (!(sort_value = dm_pool_zalloc(rh->mem, sizeof(struct str_list_sort_value)))) {
-		log_error("dm_report_field_string_list: dm_pool_zalloc failed for sort_value");
-		return 0;
-	}
-
-	list_size = dm_list_size(data);
-
 	/*
-	 * Sort value stores the pointer to the report_string and then
-	 * position and length for each list element withing the report_string.
-	 * The first element stores number of elements in 'len' (therefore
-	 * list_size + 1 is used below for the extra element).
-	 * For example, with this input:
-	 *   sort = 0;  (we don't want to report sorted)
-	 *   report_string = "abc,xy,defgh";  (this is reported)
+	 * The 'field->report_string' has 2 parts:
+	 *
+	 *    - string representing the whole string list
+	 *      (terminated by '\0' at its end as usual)
+	 *
+	 *    - extra info beyond the end of the string representing
+	 *      position and length of each list item within the
+	 *      field->report_string (array of 'struct pos_len')
+	 *
+	 * We can use the extra info to unambiguously identify list items,
+	 * the delimiter is not enough here as it's not assured it won't appear
+	 * in list item itself. We will make use of this extra info in case
+	 * we need to apply further formatting to the list in dm_report_output
+	 * where the pure field->report_string is not enough for printout.
+	 *
+	 *
+	 * The 'field->sort_value' contains a value of type 'struct
+	 * str_list_sort_value' ('sortval'). This one has a pointer to the
+	 * 'field->report_string' string ('sortval->value') and info
+	 * about position and length of each list item within the string
+	 * (array of 'struct pos_len').
+	 *
+	 *
+	 * The 'field->report_string' is either in sorted or unsorted form,
+	 * depending on 'sort_repstr' arg.
 	 *
-	 * ...we end up with:
-	 *   sort_value->value = report_string; (we'll use the original report_string for indices)
-	 *   sort_value->items[0] = {0,3};  (we have 3 items)
-	 *   sort_value->items[1] = {0,3};  ("abc")
-	 *   sort_value->items[2] = {7,5};  ("defgh")
-	 *   sort_value->items[3] = {4,2};  ("xy")
+	 * The 'field->sort_value.items' is always in sorted form because
+	 * we need that for effective sorting and selection.
 	 *
-	 *   The items alone are always sorted while in report_string they can be
-	 *   sorted or not (based on "sort" arg) - it depends on how we prefer to
-	 *   display the list. Having items sorted internally helps with searching
-	 *   through them.
+	 * If 'field->report_string' is sorted, then field->report_string
+	 * and field->sort_value.items share the same array of
+	 * 'struct pos_len' (because they're both sorted the same way),
+	 * otherwise, each one has its own array.
+	 *
+	 * The very first item in the array of 'struct pos_len' is always
+	 * a pair denoting '[list_size,strlen(field->report_string)]'. The
+	 * rest of items denote start and lenght of each item in the list.
+         *
+	 *
+	 * For example, if we have a list with "abc", "xy", "defgh"
+	 * as input and delimiter is ",", we end up with either:
+	 *
+	 *  A) if we don't want the report string sorted ('sort_repstr == 0'):
+	 *
+	 *    - field->report_string = repstr
+	 *
+	 *       repstr      repstr_extra
+	 *         |             |
+	 *         V             V
+	 *         abc,xy,defgh\0{[3,12],[0,3],[4,2],[7,5]}
+	 *         |____________||________________________|
+	 *             string     array of struct pos_len
+	 *                        |____||________________|
+	 *                        #items      items
+	 *
+	 *    - field->sort_value = sortval
+	 *
+	 *       sortval->value = repstr
+	 *       sortval->items = {[3,12],[0,3],[7,5],[4,2]}
+	 *                         (that is 'abc,defgh,xy')
+	 *
+	 *
+	 *  B) if we want the report string sorted ('sort_repstr == 1'):
+	 *
+	 *    - field->report_string = repstr
+	 *
+	 *       repstr     repstr_extra
+	 *         |             |
+	 *         V             V
+	 *         abc,defgh,xy\0{[3,12],[0,3],[4,5],[10,2]}
+	 *         |____________||________________________|
+	 *             string     array of struct pos_len
+	 *                        |____||________________|
+	 *                        #items      items
+	 *
+	 *     - field->sort_value = sortval
+	 *
+	 *       sortval->value = repstr
+	 *       sortval->items = repstr_extra
+	 *                       (that is 'abc,defgh,xy')
 	 */
-	if (!(sort_value->items = dm_pool_zalloc(rh->mem, (list_size + 1) * sizeof(struct str_list_sort_value_item)))) {
-		log_error("dm_report_fiel_string_list: dm_pool_zalloc failed for sort value items");
+
+	if (!delimiter)
+		delimiter = FIELD_STRING_LIST_DEFAULT_DELIMITER;
+	delimiter_len = strlen(delimiter);
+	list_size = dm_list_size(data);
+
+	if (!(sortval = dm_pool_alloc(rh->mem, sizeof(struct str_list_sort_value)))) {
+		log_error("%s failed to allocate sort value structure", _error_msg_prefix);
 		goto out;
 	}
-	sort_value->items[0].len = list_size;
 
 	/* zero items */
-	if (!list_size) {
-		sort_value->value = field->report_string = "";
-		field->sort_value = sort_value;
+	if (list_size == 0) {
+		field->report_string = sortval->value = "";
+		sortval->items = NULL;
+		field->sort_value = sortval;
 		return 1;
 	}
 
 	/* one item */
 	if (list_size == 1) {
 		sl = (struct dm_str_list *) dm_list_first(data);
-		if (!sl ||
-		    !(sort_value->value = field->report_string = dm_pool_strdup(rh->mem, sl->str))) {
-			log_error("dm_report_field_string_list: dm_pool_strdup failed");
+
+		repstr_str_len = strlen(sl->str);
+		repstr_size = repstr_str_len + 1 + (2 * sizeof(struct pos_len));
+
+		if (!(repstr = dm_pool_alloc(rh->mem, repstr_size))) {
+			log_error("%s failed to allocate report string structure", _error_msg_prefix);
 			goto out;
 		}
-		sort_value->items[1].pos = 0;
-		sort_value->items[1].len = strlen(sl->str);
-		field->sort_value = sort_value;
-		return 1;
-	}
+		repstr_extra = (struct pos_len *) (repstr + repstr_str_len + 1);
 
-	/* more than one item - sort the list */
-	if (!(arr = dm_malloc(sizeof(struct str_list_sort_item) * list_size))) {
-		log_error("dm_report_field_string_list: dm_malloc failed");
-		goto out;
+		memcpy(repstr, sl->str, repstr_str_len + 1);
+		memcpy(repstr_extra, &((struct pos_len) {.pos = 1, .len = repstr_str_len}), sizeof(struct pos_len));
+		memcpy(repstr_extra + 1, &((struct pos_len) {.pos = 0, .len = repstr_str_len}), sizeof(struct pos_len));
+
+		sortval->value = field->report_string = repstr;
+		sortval->items = repstr_extra;
+		field->sort_value = sortval;
+		return 1;
 	}
 
-	if (!(dm_pool_begin_object(rh->mem, 256))) {
-		log_error(_string_list_grow_object_failed_msg);
+	/* more than one item - allocate temporary array for string list items for further processing */
+	if (!(arr = dm_malloc(list_size * sizeof(struct str_pos_len)))) {
+		log_error("%s failed to allocate temporary array for processing", _error_msg_prefix);
 		goto out;
 	}
 
-	if (!delimiter)
-		delimiter = ",";
-	delimiter_len = strlen(delimiter);
-
-	i = pos = 0;
+	i = 0;
+	repstr_size = 0;
 	dm_list_iterate_items(sl, data) {
 		arr[i].str = sl->str;
-		if (!sort) {
-			/* sorted outpud not required - report the list as it is */
-			len = strlen(sl->str);
-			if (!dm_pool_grow_object(rh->mem, arr[i].str, len) ||
-			    (i+1 != list_size && !dm_pool_grow_object(rh->mem, delimiter, delimiter_len))) {
-				log_error(_string_list_grow_object_failed_msg);
-				goto out;
-			}
-			arr[i].item.pos = pos;
-			arr[i].item.len = len;
-			pos = i+1 == list_size ? pos+len : pos+len+delimiter_len;
-		}
+		repstr_size += (arr[i].item.len = strlen(sl->str));
 		i++;
 	}
 
-	qsort(arr, i, sizeof(struct str_list_sort_item), _str_list_sort_item_cmp);
+	/*
+	 * At this point, repstr_size contains sum of lengths of all string list items.
+	 * Now, add these to the repstr_size:
+	 *
+	 * 	--> sum of character count used by all delimiters: + ((list_size - 1) * delimiter_len)
+	 *
+	 * 	--> '\0' used at the end of the string list: + 1
+	 *
+	 * 	--> sum of structures used to keep info about pos and length of each string list item:
+	 * 	    [0, <list_size>] [<pos1>,<size1>] [<pos2>,<size2>] ...
+	 * 	    That is: + ((list_size + 1) * sizeof(struct pos_len))
+	 */
+	repstr_size += ((list_size - 1) * delimiter_len);
+	repstr_str_len = repstr_size;
+	repstr_size += 1 + ((list_size + 1) * sizeof(struct pos_len));
+
+	if (sort_repstr)
+		qsort(arr, list_size, sizeof(struct str_pos_len), _str_sort_cmp);
 
+	if (!(repstr = dm_pool_alloc(rh->mem, repstr_size))) {
+		log_error("%s failed to allocate report string structure", _error_msg_prefix);
+		goto out;
+	}
+	repstr_extra = (struct pos_len *) (repstr + repstr_str_len + 1);
+
+	memcpy(repstr_extra, &(struct pos_len) {.pos = list_size, .len = repstr_str_len}, sizeof(struct pos_len));
 	for (i = 0, pos = 0; i < list_size; i++) {
-		if (sort) {
-			/* sorted output required - report the list as sorted */
-			len = strlen(arr[i].str);
-			if (!dm_pool_grow_object(rh->mem, arr[i].str, len) ||
-			    (i+1 != list_size && !dm_pool_grow_object(rh->mem, delimiter, delimiter_len))) {
-				log_error(_string_list_grow_object_failed_msg);
-				goto out;
-			}
-			/*
-			 * Save position and length of the string
-			 * element in report_string for sort_value.
-			 * Use i+1 here since items[0] stores list size!!!
-			 */
-			sort_value->items[i+1].pos = pos;
-			sort_value->items[i+1].len = len;
-			pos = i+1 == list_size ? pos+len : pos+len+delimiter_len;
-		} else {
-			sort_value->items[i+1].pos = arr[i].item.pos;
-			sort_value->items[i+1].len = arr[i].item.len;
+		arr[i].item.pos = pos;
+
+		memcpy(repstr + pos, arr[i].str, arr[i].item.len);
+		memcpy(repstr_extra + i + 1, &arr[i].item, sizeof(struct pos_len));
+
+		pos += arr[i].item.len;
+		if (i + 1 < list_size) {
+			memcpy(repstr + pos, delimiter, delimiter_len);
+			pos += delimiter_len;
 		}
 	}
+	*(repstr + pos) = '\0';
 
-	if (!dm_pool_grow_object(rh->mem, "\0", 1)) {
-		log_error(_string_list_grow_object_failed_msg);
-		goto out;
+	sortval->value = repstr;
+	if (sort_repstr)
+		sortval->items = repstr_extra;
+	else {
+		if (!(sortval->items = dm_pool_alloc(rh->mem, (list_size + 1) * sizeof(struct pos_len)))) {
+			log_error("%s failed to allocate array of items inside sort value structure",
+				  _error_msg_prefix);
+			goto out;
+		}
+
+		qsort(arr, list_size, sizeof(struct str_pos_len), _str_sort_cmp);
+
+		sortval->items[0] = (struct pos_len) {.pos = list_size, .len = repstr_str_len};
+		for (i = 0; i < list_size; i++)
+			sortval->items[i+1] = arr[i].item;
 	}
 
-	object = dm_pool_end_object(rh->mem);
-	sort_value->value = object;
-	field->sort_value = sort_value;
-	field->report_string = object;
+	field->report_string = repstr;
+	field->sort_value = sortval;
 	r = 1;
 out:
-	if (!r && sort_value)
-		dm_pool_free(rh->mem, sort_value);
+	if (!r && sortval)
+		dm_pool_free(rh->mem, sortval);
 	dm_free(arr);
-
 	return r;
 }
 
@@ -1687,7 +1761,7 @@ static int _cmp_field_string_list_strict_all(const struct str_list_sort_value *v
 	struct dm_str_list *sel_item;
 	unsigned int i = 1;
 
-	if (!val->items[0].len) {
+	if (!val->items) {
 		if (sel_list_size == 1) {
 			/* match blank string list with selection defined as blank string only */
 			sel_item = dm_list_item(dm_list_first(&sel->str_list.list), struct dm_str_list);
@@ -1697,7 +1771,7 @@ static int _cmp_field_string_list_strict_all(const struct str_list_sort_value *v
 	}
 
 	/* if item count differs, it's clear the lists do not match */
-	if (val->items[0].len != sel_list_size)
+	if (val->items[0].pos != sel_list_size)
 		return 0;
 
 	/* both lists are sorted so they either match 1:1 or not */
@@ -1720,7 +1794,7 @@ static int _cmp_field_string_list_subset_all(const struct str_list_sort_value *v
 	unsigned int i, last_found = 1;
 	int r = 0;
 
-	if (!val->items[0].len) {
+	if (!val->items) {
 		if (sel_list_size == 1) {
 			/* match blank string list with selection defined as blank string only */
 			sel_item = dm_list_item(dm_list_first(&sel->str_list.list), struct dm_str_list);
@@ -1732,7 +1806,7 @@ static int _cmp_field_string_list_subset_all(const struct str_list_sort_value *v
 	/* check selection is a subset of the value */
 	dm_list_iterate_items(sel_item, &sel->str_list.list) {
 		r = 0;
-		for (i = last_found; i <= val->items[0].len; i++) {
+		for (i = last_found; i <= val->items[0].pos; i++) {
 			if ((strlen(sel_item->str) == val->items[i].len) &&
 			    !strncmp(sel_item->str, val->value + val->items[i].pos, val->items[i].len)) {
 				last_found = i;
@@ -1754,7 +1828,7 @@ static int _cmp_field_string_list_any(const struct str_list_sort_value *val,
 	unsigned int i;
 
 	/* match blank string list with selection that contains blank string */
-	if (!val->items[0].len) {
+	if (!val->items) {
 		dm_list_iterate_items(sel_item, &sel->str_list.list) {
 			if (!strcmp(sel_item->str, ""))
 				return 1;
@@ -1767,7 +1841,7 @@ static int _cmp_field_string_list_any(const struct str_list_sort_value *val,
 		 * TODO: Optimize this so we don't need to compare the whole lists' content.
 		 *       Make use of the fact that the lists are sorted!
 		 */
-		for (i = 1; i <= val->items[0].len; i++) {
+		for (i = 1; i <= val->items[0].pos; i++) {
 			if ((strlen(sel_item->str) == val->items[i].len) &&
 			    !strncmp(sel_item->str, val->value + val->items[i].pos, val->items[i].len))
 				return 1;

