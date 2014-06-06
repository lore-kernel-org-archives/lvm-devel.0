From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri,  6 Jun 2014 12:04:02 +0000 (UTC)
Subject: dev-prajnoha-report-select - report: select: add support for comparing string lists with selection defined
Message-ID: <20140606120402.9BA0460CAD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7c6cc37a2a630c1d573b5fb5c01c4c448d1eac6c
Commit:        7c6cc37a2a630c1d573b5fb5c01c4c448d1eac6c
Parent:        a0c002b453ea75f618700936ee6d7d19502deb21
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu May 29 09:42:02 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Jun 6 11:40:36 2014 +0200

report: select: add support for comparing string lists with selection defined

---
 libdm/libdm-report.c |   68 ++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 68 insertions(+), 0 deletions(-)

diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 5db638c..001c7bc 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -998,6 +998,70 @@ static inline int _cmp_field_string(const char *field_id, const char *a, const c
 	return 0;
 }
 
+/* Matches if all items from selection string list match. */
+static int _cmp_field_string_list_all(const struct str_list_sort_value *val,
+				      const struct selection_str_list *sel)
+{
+	struct dm_str_list *sel_item;
+	unsigned int i = 1;
+
+	/* if item count differs, it's clear the lists do not match */
+	if (val->items[0].len != dm_list_size(sel->list))
+		return 0;
+
+	/* both lists are sorted so they either match 1:1 or not */
+	dm_list_iterate_items(sel_item, sel->list) {
+		if (strncmp(sel_item->str, val->value + val->items[i].pos, val->items[i].len))
+			return 0;
+		i++;
+	}
+
+	return 1;
+}
+
+/* Matches if any item from selection string list matches. */
+static int _cmp_field_string_list_any(const struct str_list_sort_value *val,
+				      const struct selection_str_list *sel)
+{
+	struct dm_str_list *sel_item;
+	unsigned int i;
+
+	/* if value has no items and selection has at least one, it's clear there's no match */
+	if ((val->items[0].len == 0) && dm_list_size(sel->list))
+		return 0;
+
+	dm_list_iterate_items(sel_item, sel->list) {
+		/*
+		 * TODO: Optimize this so we don't need to compare the whole lists' content.
+		 *       Make use of the fact that the lists are sorted!
+		 */
+		for (i = 1; i <= val->items[0].len; i++) {
+			if (!strncmp(sel_item->str, val->value + val->items[i].pos, val->items[i].len))
+				return 1;
+		}
+	}
+
+	return 0;
+}
+
+static int _cmp_field_string_list(const char *field_id,
+				  const struct str_list_sort_value *value,
+				  const struct selection_str_list *selection, uint32_t flags)
+{
+	switch (selection->type & SEL_MASK) {
+		case SEL_AND:
+			return _cmp_field_string_list_all(value, selection);
+		case SEL_OR:
+			return _cmp_field_string_list_any(value, selection);
+		default:
+			log_error(INTERNAL_ERROR "_cmp_field_string_list: unsupported string "
+				  "list type found, expecting either AND or OR list for "
+				  "selection field %s", field_id);
+	}
+
+	return 0;
+}
+
 static inline int _cmp_field_regex(const char *s, struct dm_regex *r, uint32_t flags)
 {
 	return (dm_regex_match(r, s) >= 0) ^ (flags & FLD_CMP_NOT);
@@ -1029,6 +1093,10 @@ static int _compare_selection_field(struct dm_report *rh,
 			case DM_REPORT_FIELD_TYPE_STRING:
 				r = _cmp_field_string(field_id, (const char *) f->sort_value, fs->v.s, fs->flags);
 				break;
+			case DM_REPORT_FIELD_TYPE_STRING_LIST:
+				r = _cmp_field_string_list(field_id, (const struct str_list_sort_value *) f->sort_value,
+							   fs->v.l, fs->flags);
+				break;
 			default:
 				log_error(INTERNAL_ERROR "_compare_selection_field: unknown field type for field %s", field_id);
 		}


