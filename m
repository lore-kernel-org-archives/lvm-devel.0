From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 25 Aug 2014 14:15:02 +0000 (UTC)
Subject: master - report: add dm_report_field_string_list_unsorted
Message-ID: <20140825141502.ADB6E60E1A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=02dc3c773e6c8728b5df1dd7be8e1dc8c5f58e72
Commit:        02dc3c773e6c8728b5df1dd7be8e1dc8c5f58e72
Parent:        993f8d1b3f6cd6f04d0b9bfe858c35161e262dc4
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Aug 25 10:04:08 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Aug 25 16:11:40 2014 +0200

report: add dm_report_field_string_list_unsorted

---
 WHATS_NEW_DM         |    1 +
 libdm/libdevmapper.h |    2 +
 libdm/libdm-report.c |  133 ++++++++++++++++++++++++++++++++++----------------
 3 files changed, 94 insertions(+), 42 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 4a2c8b4..9f16797 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.89 -
 =================================
+  Add dm_report_field_string_list_unsorted for str. list report without sorting.
   Support --deferred with dmsetup remove to defer removal of open devices.
   Update dm-ioctl.h to include DM_DEFERRED_REMOVE flag.
   Add support for selection to match string list subset, recognize { } operator.
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index bf8a658..31574af 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -1755,6 +1755,8 @@ int dm_report_field_string(struct dm_report *rh, struct dm_report_field *field,
 			   const char *const *data);
 int dm_report_field_string_list(struct dm_report *rh, struct dm_report_field *field,
 				const struct dm_list *data, const char *delimiter);
+int dm_report_field_string_list_unsorted(struct dm_report *rh, struct dm_report_field *field,
+					 const struct dm_list *data, const char *delimiter);
 int dm_report_field_int32(struct dm_report *rh, struct dm_report_field *field,
 			  const int32_t *data);
 int dm_report_field_uint32(struct dm_report *rh, struct dm_report_field *field,
diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 261b436..cd42b11 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -283,24 +283,6 @@ int dm_report_field_string(struct dm_report *rh,
 	return 1;
 }
 
-static int _str_cmp(const void *a, const void *b)
-{
-	const char **str_a = (const char **) a;
-	const char **str_b = (const char **) b;
-
-	return strcmp(*str_a, *str_b);
-}
-
-struct str_list_sort_value_item {
-	unsigned pos;
-	size_t len;
-};
-
-struct str_list_sort_value {
-	const char *value;
-	struct str_list_sort_value_item *items;
-};
-
 int dm_report_field_percent(struct dm_report *rh,
 			    struct dm_report_field *field,
 			    const dm_percent_t *data)
@@ -336,15 +318,39 @@ int dm_report_field_percent(struct dm_report *rh,
 	return 1;
 }
 
-int dm_report_field_string_list(struct dm_report *rh,
-				struct dm_report_field *field,
-				const struct dm_list *data,
-				const char *delimiter)
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
+struct str_list_sort_item {
+	const char *str;
+	struct str_list_sort_value_item item;
+};
+
+static int _str_list_sort_item_cmp(const void *a, const void *b)
+{
+	const struct str_list_sort_item *slsi_a = (const struct str_list_sort_item *) a;
+	const struct str_list_sort_item *slsi_b = (const struct str_list_sort_item *) b;
+
+	return strcmp(slsi_a->str, slsi_b->str);
+}
+
+static int _report_field_string_list(struct dm_report *rh,
+				     struct dm_report_field *field,
+				     const struct dm_list *data,
+				     const char *delimiter,
+				     int sort)
 {
 	static const char _string_list_grow_object_failed_msg[] = "dm_report_field_string_list: dm_pool_grow_object_failed";
 	struct str_list_sort_value *sort_value = NULL;
 	unsigned int list_size, pos, i;
-	const char **arr = NULL;
+	struct str_list_sort_item *arr = NULL;
 	struct dm_str_list *sl;
 	size_t delimiter_len, len;
 	void *object;
@@ -392,14 +398,10 @@ int dm_report_field_string_list(struct dm_report *rh,
 	}
 
 	/* more than one item - sort the list */
-	if (!(arr = dm_malloc(sizeof(char *) * list_size))) {
+	if (!(arr = dm_malloc(sizeof(struct str_list_sort_item) * list_size))) {
 		log_error("dm_report_field_string_list: dm_malloc failed");
 		goto out;
 	}
-	i = 0;
-	dm_list_iterate_items(sl, data)
-		arr[i++] = sl->str;
-	qsort(arr, i, sizeof(char *), _str_cmp);
 
 	if (!(dm_pool_begin_object(rh->mem, 256))) {
 		log_error(_string_list_grow_object_failed_msg);
@@ -410,21 +412,47 @@ int dm_report_field_string_list(struct dm_report *rh,
 		delimiter = ",";
 	delimiter_len = strlen(delimiter);
 
-	/* start from 1 - the item 0 stores the list size! */
-	for (i = 1, pos = 0; i <= list_size; i++) {
-		len = strlen(arr[i-1]);
-		if (!dm_pool_grow_object(rh->mem, arr[i-1], len) ||
-		    (i != list_size && !dm_pool_grow_object(rh->mem, delimiter, delimiter_len))) {
-			log_error(_string_list_grow_object_failed_msg);
-			goto out;
+	i = pos = len = 0;
+	dm_list_iterate_items(sl, data) {
+		arr[i].str = sl->str;
+		if (!sort) {
+			/* sorted outpud not required - report the list as it is */
+			len = strlen(sl->str);
+			if (!dm_pool_grow_object(rh->mem, arr[i].str, len) ||
+			    (i+1 != list_size && !dm_pool_grow_object(rh->mem, delimiter, delimiter_len))) {
+				log_error(_string_list_grow_object_failed_msg);
+				goto out;
+			}
+			arr[i].item.pos = pos;
+			arr[i].item.len = len;
+			pos = i+1 == list_size ? pos+len : pos+len+delimiter_len;
+		}
+		i++;
+	}
+
+	qsort(arr, i, sizeof(struct str_list_sort_item), _str_list_sort_item_cmp);
+
+	for (i = 0, pos = 0; i < list_size; i++) {
+		if (sort) {
+			/* sorted output required - report the list as sorted */
+			len = strlen(arr[i].str);
+			if (!dm_pool_grow_object(rh->mem, arr[i].str, len) ||
+			    (i+1 != list_size && !dm_pool_grow_object(rh->mem, delimiter, delimiter_len))) {
+				log_error(_string_list_grow_object_failed_msg);
+				goto out;
+			}
+			/*
+			 * Save position and length of the string
+			 * element in report_string for sort_value.
+			 * Use i+1 here since items[0] stores list size!!!
+			 */
+			sort_value->items[i+1].pos = pos;
+			sort_value->items[i+1].len = len;
+			pos = i+1 == list_size ? pos+len : pos+len+delimiter_len;
+		} else {
+			sort_value->items[i+1].pos = arr[i].item.pos;
+			sort_value->items[i+1].len = arr[i].item.len;
 		}
-		/*
-		 * save position and length of the string
-		 * element in report_string for sort_value
-		 */
-		sort_value->items[i].pos = pos;
-		sort_value->items[i].len = len;
-		pos = i == list_size ? pos+len : pos+len+delimiter_len;
 	}
 
 	if (!dm_pool_grow_object(rh->mem, "\0", 1)) {
@@ -445,6 +473,27 @@ out:
 	return r;
 }
 
+int dm_report_field_string_list(struct dm_report *rh,
+				struct dm_report_field *field,
+				const struct dm_list *data,
+				const char *delimiter)
+{
+	return _report_field_string_list(rh, field, data, delimiter, 1);
+}
+
+int dm_report_field_string_list_unsorted(struct dm_report *rh,
+					 struct dm_report_field *field,
+					 const struct dm_list *data,
+					 const char *delimiter)
+{
+	/*
+	 * The raw value is always sorted, just the string reported is unsorted.
+	 * Having the raw value always sorted helps when matching selection list
+	 * with selection criteria.
+	 */
+	return _report_field_string_list(rh, field, data, delimiter, 0);
+}
+
 int dm_report_field_int(struct dm_report *rh,
 			struct dm_report_field *field, const int *data)
 {


