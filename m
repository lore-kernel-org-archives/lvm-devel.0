From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 17 Nov 2015 18:01:46 +0000 (UTC)
Subject: master - cleanup: use embeded list
Message-ID: <20151117180146.7293B60D9C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=83661c8f7f954816284baf385fedfea4c4d57a88
Commit:        83661c8f7f954816284baf385fedfea4c4d57a88
Parent:        6e71d3fbde344c26f8301dbd9550a110d5bc7ac4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Nov 17 13:38:17 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Nov 17 19:01:25 2015 +0100

cleanup: use embeded list

Skip pointer and put list into selection_str_list.
---
 libdm/libdm-report.c |   36 ++++++++++++++++++------------------
 1 files changed, 18 insertions(+), 18 deletions(-)

diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 140a8d7..33a3010 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -176,7 +176,7 @@ static struct op_def _op_log[] = {
 
 struct selection_str_list {
 	unsigned type;			/* either SEL_AND or SEL_OR */
-	struct dm_list *list;
+	struct dm_list list;
 };
 
 struct field_selection_value {
@@ -1646,14 +1646,14 @@ static int _cmp_field_time(struct dm_report *rh,
 static int _cmp_field_string_list_strict_all(const struct str_list_sort_value *val,
 					     const struct selection_str_list *sel)
 {
-	unsigned int sel_list_size = dm_list_size(sel->list);
+	unsigned int sel_list_size = dm_list_size(&sel->list);
 	struct dm_str_list *sel_item;
 	unsigned int i = 1;
 
 	if (!val->items[0].len) {
 		if (sel_list_size == 1) {
 			/* match blank string list with selection defined as blank string only */
-			sel_item = dm_list_item(dm_list_first(sel->list), struct dm_str_list);
+			sel_item = dm_list_item(dm_list_first(&sel->list), struct dm_str_list);
 			return !strcmp(sel_item->str, "");
 		}
 		return 0;
@@ -1664,7 +1664,7 @@ static int _cmp_field_string_list_strict_all(const struct str_list_sort_value *v
 		return 0;
 
 	/* both lists are sorted so they either match 1:1 or not */
-	dm_list_iterate_items(sel_item, sel->list) {
+	dm_list_iterate_items(sel_item, &sel->list) {
 		if ((strlen(sel_item->str) != val->items[i].len) ||
 		    strncmp(sel_item->str, val->value + val->items[i].pos, val->items[i].len))
 			return 0;
@@ -1678,7 +1678,7 @@ static int _cmp_field_string_list_strict_all(const struct str_list_sort_value *v
 static int _cmp_field_string_list_subset_all(const struct str_list_sort_value *val,
 					     const struct selection_str_list *sel)
 {
-	unsigned int sel_list_size = dm_list_size(sel->list);
+	unsigned int sel_list_size = dm_list_size(&sel->list);
 	struct dm_str_list *sel_item;
 	unsigned int i, last_found = 1;
 	int r = 0;
@@ -1686,14 +1686,14 @@ static int _cmp_field_string_list_subset_all(const struct str_list_sort_value *v
 	if (!val->items[0].len) {
 		if (sel_list_size == 1) {
 			/* match blank string list with selection defined as blank string only */
-			sel_item = dm_list_item(dm_list_first(sel->list), struct dm_str_list);
+			sel_item = dm_list_item(dm_list_first(&sel->list), struct dm_str_list);
 			return !strcmp(sel_item->str, "");
 		}
 		return 0;
 	}
 
 	/* check selection is a subset of the value */
-	dm_list_iterate_items(sel_item, sel->list) {
+	dm_list_iterate_items(sel_item, &sel->list) {
 		r = 0;
 		for (i = last_found; i <= val->items[0].len; i++) {
 			if ((strlen(sel_item->str) == val->items[i].len) &&
@@ -1718,14 +1718,14 @@ static int _cmp_field_string_list_any(const struct str_list_sort_value *val,
 
 	/* match blank string list with selection that contains blank string */
 	if (!val->items[0].len) {
-		dm_list_iterate_items(sel_item, sel->list) {
+		dm_list_iterate_items(sel_item, &sel->list) {
 			if (!strcmp(sel_item->str, ""))
 				return 1;
 		}
 		return 0;
 	}
 
-	dm_list_iterate_items(sel_item, sel->list) {
+	dm_list_iterate_items(sel_item, &sel->list) {
 		/*
 		 * TODO: Optimize this so we don't need to compare the whole lists' content.
 		 *       Make use of the fact that the lists are sorted!
@@ -2577,12 +2577,11 @@ static const char *_tok_value_string_list(const struct dm_report_field_type *ft,
 	int list_end = 0;
 	char c;
 
-	if (!(ssl = dm_pool_alloc(mem, sizeof(*ssl))) ||
-	    !(ssl->list = dm_pool_alloc(mem, sizeof(*ssl->list)))) {
+	if (!(ssl = dm_pool_alloc(mem, sizeof(*ssl)))) {
 		log_error("_tok_value_string_list: memory allocation failed for selection list");
 		goto bad;
 	}
-	dm_list_init(ssl->list);
+	dm_list_init(&ssl->list);
 	ssl->type = 0;
 	*begin = s;
 
@@ -2593,7 +2592,7 @@ static const char *_tok_value_string_list(const struct dm_report_field_type *ft,
 			log_error(_str_list_item_parsing_failed, ft->id);
 			goto bad;
 		}
-		if (!_add_item_to_string_list(mem, begin_item, end_item, ssl->list))
+		if (!_add_item_to_string_list(mem, begin_item, end_item, &ssl->list))
 			goto_bad;
 		ssl->type = SEL_OR | SEL_LIST_LS;
 		goto out;
@@ -2650,7 +2649,7 @@ static const char *_tok_value_string_list(const struct dm_report_field_type *ft,
 				ssl->type = end_op_flag_hit;
 		}
 
-		if (!_add_item_to_string_list(mem, begin_item, end_item, ssl->list))
+		if (!_add_item_to_string_list(mem, begin_item, end_item, &ssl->list))
 			goto_bad;
 
 		s = tmp;
@@ -2671,7 +2670,7 @@ static const char *_tok_value_string_list(const struct dm_report_field_type *ft,
 		ssl->type |= SEL_LIST_SUBSET_LS;
 
 	/* Sort the list. */
-	if (!(list_size = dm_list_size(ssl->list))) {
+	if (!(list_size = dm_list_size(&ssl->list))) {
 		log_error(INTERNAL_ERROR "_tok_value_string_list: list has no items");
 		goto bad;
 	} else if (list_size == 1)
@@ -2682,18 +2681,19 @@ static const char *_tok_value_string_list(const struct dm_report_field_type *ft,
 	}
 
 	i = 0;
-	dm_list_iterate_items(item, ssl->list)
+	dm_list_iterate_items(item, &ssl->list)
 		arr[i++] = item;
 	qsort(arr, list_size, sizeof(item), _str_list_item_cmp);
-	dm_list_init(ssl->list);
+	dm_list_init(&ssl->list);
 	for (i = 0; i < list_size; i++)
-		dm_list_add(ssl->list, &arr[i]->list);
+		dm_list_add(&ssl->list, &arr[i]->list);
 
 	dm_free(arr);
 out:
 	*end = s;
         if (sel_str_list)
 		*sel_str_list = ssl;
+
 	return s;
 bad:
 	*end = s;


