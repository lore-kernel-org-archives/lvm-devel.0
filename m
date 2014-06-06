From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri,  6 Jun 2014 12:03:56 +0000 (UTC)
Subject: dev-prajnoha-report-select - report: select: add dm_report_field_string_list to libdm
Message-ID: <20140606120356.5C7A160CAD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3bcf26dcbe3871c52448e283e39b4e1d5f0fd6ad
Commit:        3bcf26dcbe3871c52448e283e39b4e1d5f0fd6ad
Parent:        433fd6abc3a59e6030e163c9611b296348a442e1
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu May 29 09:41:18 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Jun 6 11:35:24 2014 +0200

report: select: add dm_report_field_string_list to libdm

Add a separate dm_report_field_string_list fn to libdevmapper to
support reporting string lists. Before, the code used libdevmappers's
dm_report_field_string fn which required formatting the list to a
single string. This functionality is now moved to libdevmapper
and the code that needs to report the string list just needs
to pass the list itself and libdevmapper will take care of this.
This also enhances code reuse.

The dm_report_field_string_list also accepts an argument to define
custom delimiter to use. If not defined, a default "," (comma) is
used as item delimiter in the string list reported.

The dm_report_field_string_list automatically sorts the items in
the list before formatting it to a final string. It also encodes
the position and length within the final string where each element
can be found. This can be used to support checking against each
list item reported since since when formatted as a single string
for the actual report, we would lose this information otherwise
(we don't want to copy each item, the position and length within
the final string is enough for us to get the original items back).

When such lists are checked against the selection tree, we can check
each item individually this way and we can support operators like
"match any" and "match all".
---
 libdm/libdevmapper.h |    2 +
 libdm/libdm-report.c |  127 ++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 129 insertions(+), 0 deletions(-)

diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index f3e2b92..e007b9b 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -1676,6 +1676,8 @@ int dm_report_set_output_field_name_prefix(struct dm_report *rh,
  */
 int dm_report_field_string(struct dm_report *rh, struct dm_report_field *field,
 			   const char *const *data);
+int dm_report_field_string_list(struct dm_report *rh, struct dm_report_field *field,
+				const struct dm_list *data, const char *delimiter);
 int dm_report_field_int32(struct dm_report *rh, struct dm_report_field *field,
 			  const int32_t *data);
 int dm_report_field_uint32(struct dm_report *rh, struct dm_report_field *field,
diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 6b18ec9..779baf1 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -198,6 +198,133 @@ int dm_report_field_string(struct dm_report *rh,
 	return 1;
 }
 
+static int _str_cmp(const void *a, const void *b)
+{
+	const char **str_a = (const char **) a;
+	const char **str_b = (const char **) b;
+
+	return strcmp(*str_a, *str_b);
+}
+
+struct str_list_sort_value_item {
+	unsigned pos;
+	size_t len;
+};
+
+struct str_list_sort_value {
+	const char *value;
+	struct str_list_sort_value_item *items;
+};
+
+int dm_report_field_string_list(struct dm_report *rh,
+				struct dm_report_field *field,
+				const struct dm_list *data,
+				const char *delimiter)
+{
+	static const char _string_list_grow_object_failed_msg[] = "dm_report_field_string_list: dm_pool_grow_object_failed";
+	struct str_list_sort_value *sort_value = NULL;
+	unsigned int list_size, pos, i;
+	const char **arr = NULL;
+	struct dm_str_list *sl;
+	size_t delimiter_len, len;
+	void *object;
+	int r = 0;
+
+	if (!(sort_value = dm_pool_zalloc(rh->mem, sizeof(struct str_list_sort_value)))) {
+		log_error("dm_report_field_string_list: dm_pool_zalloc failed for sort_value");
+		return 0;
+	}
+
+	list_size = dm_list_size(data);
+
+	/*
+	 * Sort value stores the pointer to the report_string and then
+	 * position and length for each list element withing the report_string.
+	 * The first element stores number of elements in 'len' (therefore
+	 * list_size + 1 is used below for the extra element).
+	 */
+	if (!(sort_value->items = dm_pool_zalloc(rh->mem, (list_size + 1) * sizeof(struct str_list_sort_value_item)))) {
+		log_error("dm_report_fiel_string_list: dm_pool_zalloc failed for sort value items");
+		goto out;
+	}
+	sort_value->items[0].len = list_size;
+
+	/* zero items */
+	if (!list_size) {
+		sort_value->value = field->report_string = "";
+		sort_value->items[1].pos = 0;
+		sort_value->items[1].len = 0;
+		field->sort_value = sort_value;
+		return 1;
+	}
+
+	/* one item */
+	if (list_size == 1) {
+		sl = (struct dm_str_list *) dm_list_first(data);
+		if (!(sort_value->value = field->report_string = dm_pool_strdup(rh->mem, sl->str))) {
+			log_error("dm_report_field_string_list: dm_pool_strdup failed");
+			goto out;
+		}
+		sort_value->items[1].pos = 0;
+		sort_value->items[1].len = strlen(sl->str);
+		field->sort_value = sort_value;
+		return 1;
+	}
+
+	/* more than one item - sort the list */
+	if (!(arr = dm_malloc(sizeof(char *) * list_size))) {
+		log_error("dm_report_field_string_list: dm_malloc failed");
+		goto out;
+	}
+	i = 0;
+	dm_list_iterate_items(sl, data)
+		arr[i++] = sl->str;
+	qsort(arr, i, sizeof(char *), _str_cmp);
+
+	if (!(dm_pool_begin_object(rh->mem, 256))) {
+		log_error(_string_list_grow_object_failed_msg);
+		goto out;
+	}
+
+	if (!delimiter)
+		delimiter = ",";
+	delimiter_len = strlen(delimiter);
+
+	/* start from 1 - the item 0 stores the list size! */
+	for (i = 1, pos = 0; i <= list_size; i++) {
+		len = strlen(arr[i-1]);
+		if (!dm_pool_grow_object(rh->mem, arr[i-1], len) ||
+		    (i != list_size && !dm_pool_grow_object(rh->mem, delimiter, delimiter_len))) {
+			log_error(_string_list_grow_object_failed_msg);
+			goto out;
+		}
+		/*
+		 * save position and length of the string
+		 * element in report_string for sort_value
+		 */
+		sort_value->items[i].pos = pos;
+		sort_value->items[i].len = len;
+		pos = i == list_size ? pos+len : pos+len+1;
+	}
+
+	if (!dm_pool_grow_object(rh->mem, "\0", 1)) {
+		log_error(_string_list_grow_object_failed_msg);
+		goto out;
+	}
+
+	object = dm_pool_end_object(rh->mem);
+	sort_value->value = object;
+	field->sort_value = sort_value;
+	field->report_string = object;
+	r = 1;
+out:
+	if (!r && sort_value)
+		dm_pool_free(rh->mem, sort_value);
+	if (arr)
+		dm_free(arr);
+	return r;
+}
+
 int dm_report_field_int(struct dm_report *rh,
 			struct dm_report_field *field, const int *data)
 {


