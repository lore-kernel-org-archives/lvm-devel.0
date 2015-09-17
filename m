From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 17 Sep 2015 08:23:44 +0000 (UTC)
Subject: master - libdm: report: make it possible to use blank value as selection for string list report field
Message-ID: <20150917082344.7AE3F603AB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b5022102bbaf978cddd7ca9b27a1a12d5aeef44d
Commit:        b5022102bbaf978cddd7ca9b27a1a12d5aeef44d
Parent:        b7410c95cfbf53b2197611a0950450f7251643fc
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Sep 17 10:19:15 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Sep 17 10:19:15 2015 +0200

libdm: report: make it possible to use blank value as selection for string list report field

$ lvs -o name,tags vg
  LV    LV Tags
  lvol0
  lvol1 mytag

Before this patch:
$ lvs -o name,tags vg -S 'tags=""'
  Failed to parse string list value for selection field lv_tags.
  Selection syntax error at 'tags=""'.
  Use 'help' for selection to get more help.

(and the same for -S 'tags={}' and -S 'tags=[]')

With this patch applied:
$ lvs -o name,tags vg -S 'tags=""'
  LV    LV Tags
  lvol0

(and the same for -S 'tags={}' and -S 'tags=[]')
---
 WHATS_NEW_DM                |    1 +
 libdm/libdm-report.c        |   38 ++++++++++++++++++++++++++++----------
 test/shell/select-report.sh |    4 ++++
 3 files changed, 33 insertions(+), 10 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 31064e3..7f0e65e 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.109 - 
 ======================================
+  Make it possible to use blank value as selection for string list report field.
 
 Version 1.02.108 - 15th September 2015
 ======================================
diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 10ab7df..681ad04 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -1644,11 +1644,21 @@ static int _cmp_field_time(struct dm_report *rh,
 static int _cmp_field_string_list_strict_all(const struct str_list_sort_value *val,
 					     const struct selection_str_list *sel)
 {
+	unsigned int sel_list_size = dm_list_size(sel->list);
 	struct dm_str_list *sel_item;
 	unsigned int i = 1;
 
+	if (!val->items[0].len) {
+		if (sel_list_size == 1) {
+			/* match blank string list with selection defined as blank string only */
+			sel_item = dm_list_item(dm_list_first(sel->list), struct dm_str_list);
+			return !strcmp(sel_item->str, "");
+		}
+		return 0;
+	}
+
 	/* if item count differs, it's clear the lists do not match */
-	if (val->items[0].len != dm_list_size(sel->list))
+	if (val->items[0].len != sel_list_size)
 		return 0;
 
 	/* both lists are sorted so they either match 1:1 or not */
@@ -1666,15 +1676,21 @@ static int _cmp_field_string_list_strict_all(const struct str_list_sort_value *v
 static int _cmp_field_string_list_subset_all(const struct str_list_sort_value *val,
 					     const struct selection_str_list *sel)
 {
+	unsigned int sel_list_size = dm_list_size(sel->list);
 	struct dm_str_list *sel_item;
 	unsigned int i, last_found = 1;
 	int r = 0;
 
-	/* if value has no items and selection has at leas one, it's clear there's no match */
-	if ((val->items[0].len == 0) && dm_list_size(sel->list))
+	if (!val->items[0].len) {
+		if (sel_list_size == 1) {
+			/* match blank string list with selection defined as blank string only */
+			sel_item = dm_list_item(dm_list_first(sel->list), struct dm_str_list);
+			return !strcmp(sel_item->str, "");
+		}
 		return 0;
+	}
 
-	/* Check selection is a subset of the value. */
+	/* check selection is a subset of the value */
 	dm_list_iterate_items(sel_item, sel->list) {
 		r = 0;
 		for (i = last_found; i <= val->items[0].len; i++) {
@@ -1698,9 +1714,14 @@ static int _cmp_field_string_list_any(const struct str_list_sort_value *val,
 	struct dm_str_list *sel_item;
 	unsigned int i;
 
-	/* if value has no items and selection has at least one, it's clear there's no match */
-	if ((val->items[0].len == 0) && dm_list_size(sel->list))
+	/* match blank string list with selection that contains blank string */
+	if (!val->items[0].len) {
+		dm_list_iterate_items(sel_item, sel->list) {
+			if (!strcmp(sel_item->str, ""))
+				return 1;
+		}
 		return 0;
+	}
 
 	dm_list_iterate_items(sel_item, sel->list) {
 		/*
@@ -2460,11 +2481,8 @@ static int _add_item_to_string_list(struct dm_pool *mem, const char *begin,
 {
 	struct dm_str_list *item;
 
-	if (begin == end)
-		return_0;
-
 	if (!(item = dm_pool_zalloc(mem, sizeof(*item))) ||
-	    !(item->str = dm_pool_strndup(mem, begin, end - begin))) {
+	    !(item->str = begin == end ? "" : dm_pool_strndup(mem, begin, end - begin))) {
 		log_error("_add_item_to_string_list: memory allocation failed for string list item");
 		return 0;
 	}
diff --git a/test/shell/select-report.sh b/test/shell/select-report.sh
index fde7dc0..b859199 100644
--- a/test/shell/select-report.sh
+++ b/test/shell/select-report.sh
@@ -106,6 +106,10 @@ sel pv 'tags=["pv_tag4" || "pv_tag3"]' "$dev1" "$dev6"
 sel pv 'tags!=["pv_tag1"]' "$dev1" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6"
 # check mixture of && and || - this is not allowed
 not sel pv 'tags=["pv_tag1" && "pv_tag2" || "pv_tag3"]'
+# check selection with blank value
+sel lv 'tags=""' xyz orig snap
+sel lv 'tags={}' xyz orig snap
+sel lv 'tags=[]' xyz orig snap
 
 ##########################
 # NUMBER FIELD SELECTION #


