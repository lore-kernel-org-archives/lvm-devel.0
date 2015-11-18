From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 18 Nov 2015 09:55:23 +0000 (UTC)
Subject: master - libdm: report: consolidate use of string list selection structures
Message-ID: <20151118095523.0BEB860D19@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0a2cadf6b87acd62151451cff8fd596715f00718
Commit:        0a2cadf6b87acd62151451cff8fd596715f00718
Parent:        7b11ef6de057e4a26e88792cf4dc966a79ac4ba0
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Nov 18 10:54:09 2015 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Nov 18 10:54:09 2015 +0100

libdm: report: consolidate use of string list selection structures

---
 libdm/libdm-report.c        |   32 ++++++++++++++++----------------
 test/shell/select-report.sh |    3 +++
 2 files changed, 19 insertions(+), 16 deletions(-)

diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 33a3010..8ca0dc0 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -175,8 +175,8 @@ static struct op_def _op_log[] = {
 };
 
 struct selection_str_list {
+	struct dm_str_list str_list;
 	unsigned type;			/* either SEL_AND or SEL_OR */
-	struct dm_list list;
 };
 
 struct field_selection_value {
@@ -1646,14 +1646,14 @@ static int _cmp_field_time(struct dm_report *rh,
 static int _cmp_field_string_list_strict_all(const struct str_list_sort_value *val,
 					     const struct selection_str_list *sel)
 {
-	unsigned int sel_list_size = dm_list_size(&sel->list);
+	unsigned int sel_list_size = dm_list_size(&sel->str_list.list);
 	struct dm_str_list *sel_item;
 	unsigned int i = 1;
 
 	if (!val->items[0].len) {
 		if (sel_list_size == 1) {
 			/* match blank string list with selection defined as blank string only */
-			sel_item = dm_list_item(dm_list_first(&sel->list), struct dm_str_list);
+			sel_item = dm_list_item(dm_list_first(&sel->str_list.list), struct dm_str_list);
 			return !strcmp(sel_item->str, "");
 		}
 		return 0;
@@ -1664,7 +1664,7 @@ static int _cmp_field_string_list_strict_all(const struct str_list_sort_value *v
 		return 0;
 
 	/* both lists are sorted so they either match 1:1 or not */
-	dm_list_iterate_items(sel_item, &sel->list) {
+	dm_list_iterate_items(sel_item, &sel->str_list.list) {
 		if ((strlen(sel_item->str) != val->items[i].len) ||
 		    strncmp(sel_item->str, val->value + val->items[i].pos, val->items[i].len))
 			return 0;
@@ -1678,7 +1678,7 @@ static int _cmp_field_string_list_strict_all(const struct str_list_sort_value *v
 static int _cmp_field_string_list_subset_all(const struct str_list_sort_value *val,
 					     const struct selection_str_list *sel)
 {
-	unsigned int sel_list_size = dm_list_size(&sel->list);
+	unsigned int sel_list_size = dm_list_size(&sel->str_list.list);
 	struct dm_str_list *sel_item;
 	unsigned int i, last_found = 1;
 	int r = 0;
@@ -1686,14 +1686,14 @@ static int _cmp_field_string_list_subset_all(const struct str_list_sort_value *v
 	if (!val->items[0].len) {
 		if (sel_list_size == 1) {
 			/* match blank string list with selection defined as blank string only */
-			sel_item = dm_list_item(dm_list_first(&sel->list), struct dm_str_list);
+			sel_item = dm_list_item(dm_list_first(&sel->str_list.list), struct dm_str_list);
 			return !strcmp(sel_item->str, "");
 		}
 		return 0;
 	}
 
 	/* check selection is a subset of the value */
-	dm_list_iterate_items(sel_item, &sel->list) {
+	dm_list_iterate_items(sel_item, &sel->str_list.list) {
 		r = 0;
 		for (i = last_found; i <= val->items[0].len; i++) {
 			if ((strlen(sel_item->str) == val->items[i].len) &&
@@ -1718,14 +1718,14 @@ static int _cmp_field_string_list_any(const struct str_list_sort_value *val,
 
 	/* match blank string list with selection that contains blank string */
 	if (!val->items[0].len) {
-		dm_list_iterate_items(sel_item, &sel->list) {
+		dm_list_iterate_items(sel_item, &sel->str_list.list) {
 			if (!strcmp(sel_item->str, ""))
 				return 1;
 		}
 		return 0;
 	}
 
-	dm_list_iterate_items(sel_item, &sel->list) {
+	dm_list_iterate_items(sel_item, &sel->str_list.list) {
 		/*
 		 * TODO: Optimize this so we don't need to compare the whole lists' content.
 		 *       Make use of the fact that the lists are sorted!
@@ -2581,7 +2581,7 @@ static const char *_tok_value_string_list(const struct dm_report_field_type *ft,
 		log_error("_tok_value_string_list: memory allocation failed for selection list");
 		goto bad;
 	}
-	dm_list_init(&ssl->list);
+	dm_list_init(&ssl->str_list.list);
 	ssl->type = 0;
 	*begin = s;
 
@@ -2592,7 +2592,7 @@ static const char *_tok_value_string_list(const struct dm_report_field_type *ft,
 			log_error(_str_list_item_parsing_failed, ft->id);
 			goto bad;
 		}
-		if (!_add_item_to_string_list(mem, begin_item, end_item, &ssl->list))
+		if (!_add_item_to_string_list(mem, begin_item, end_item, &ssl->str_list.list))
 			goto_bad;
 		ssl->type = SEL_OR | SEL_LIST_LS;
 		goto out;
@@ -2649,7 +2649,7 @@ static const char *_tok_value_string_list(const struct dm_report_field_type *ft,
 				ssl->type = end_op_flag_hit;
 		}
 
-		if (!_add_item_to_string_list(mem, begin_item, end_item, &ssl->list))
+		if (!_add_item_to_string_list(mem, begin_item, end_item, &ssl->str_list.list))
 			goto_bad;
 
 		s = tmp;
@@ -2670,7 +2670,7 @@ static const char *_tok_value_string_list(const struct dm_report_field_type *ft,
 		ssl->type |= SEL_LIST_SUBSET_LS;
 
 	/* Sort the list. */
-	if (!(list_size = dm_list_size(&ssl->list))) {
+	if (!(list_size = dm_list_size(&ssl->str_list.list))) {
 		log_error(INTERNAL_ERROR "_tok_value_string_list: list has no items");
 		goto bad;
 	} else if (list_size == 1)
@@ -2681,12 +2681,12 @@ static const char *_tok_value_string_list(const struct dm_report_field_type *ft,
 	}
 
 	i = 0;
-	dm_list_iterate_items(item, &ssl->list)
+	dm_list_iterate_items(item, &ssl->str_list.list)
 		arr[i++] = item;
 	qsort(arr, list_size, sizeof(item), _str_list_item_cmp);
-	dm_list_init(&ssl->list);
+	dm_list_init(&ssl->str_list.list);
 	for (i = 0; i < list_size; i++)
-		dm_list_add(&ssl->list, &arr[i]->list);
+		dm_list_add(&ssl->str_list.list, &arr[i]->list);
 
 	dm_free(arr);
 out:
diff --git a/test/shell/select-report.sh b/test/shell/select-report.sh
index 20d57c7..0ce48a9 100644
--- a/test/shell/select-report.sh
+++ b/test/shell/select-report.sh
@@ -110,6 +110,9 @@ not sel pv 'tags=["pv_tag1" && "pv_tag2" || "pv_tag3"]'
 sel lv 'tags=""' xyz orig snap
 sel lv 'tags={}' xyz orig snap
 sel lv 'tags=[]' xyz orig snap
+# check subset selection
+sel pv 'tags={"pv_tag1"}' "$dev1" "$dev6"
+sel pv 'tags={"pv_tag1" && "pv_tag2"}' "$dev1"
 
 ##########################
 # NUMBER FIELD SELECTION #


