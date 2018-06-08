From: Joe Thornber <thornber@sourceware.org>
Date: Fri, 8 Jun 2018 09:25:14 -0400
Subject: master - base: Move list to base/data-struct
Message-ID: <201806081325.w58DPECW015593@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=88ae928ca3f950fa0ecb8b8e0aff118b7360a9d7
Commit:        88ae928ca3f950fa0ecb8b8e0aff118b7360a9d7
Parent:        9573ff3a3bbd61fb178ea73e24c689822b9aca85
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Fri Jun 8 11:24:18 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Fri Jun 8 11:24:18 2018 +0100

base: Move list to base/data-struct

---
 base/Makefile                   |    1 +
 base/data-struct/list.c         |  170 +++++++++++++++++++++++++++++++
 base/data-struct/list.h         |  209 +++++++++++++++++++++++++++++++++++++++
 device_mapper/Makefile          |    1 -
 device_mapper/datastruct/list.c |  168 -------------------------------
 device_mapper/libdevmapper.h    |  209 +--------------------------------------
 6 files changed, 384 insertions(+), 374 deletions(-)

diff --git a/base/Makefile b/base/Makefile
index 27f539f..4dcb6b6 100644
--- a/base/Makefile
+++ b/base/Makefile
@@ -12,6 +12,7 @@
 
 BASE_SOURCE=\
 	base/data-struct/radix-tree.c \
+	base/data-struct/list.c
 
 BASE_DEPENDS=$(addprefix $(top_builddir)/,$(subst .c,.d,$(BASE_SOURCE)))
 BASE_OBJECTS=$(addprefix $(top_builddir)/,$(subst .c,.o,$(BASE_SOURCE)))
diff --git a/base/data-struct/list.c b/base/data-struct/list.c
new file mode 100644
index 0000000..894e273
--- /dev/null
+++ b/base/data-struct/list.c
@@ -0,0 +1,170 @@
+/*
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
+ * Copyright (C) 2004-2010 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+ */
+
+#include "list.h"
+
+#include <assert.h>
+#include <stdlib.h>
+
+/*
+ * Initialise a list before use.
+ * The list head's next and previous pointers point back to itself.
+ */
+void dm_list_init(struct dm_list *head)
+{
+	head->n = head->p = head;
+}
+
+/*
+ * Insert an element before 'head'.
+ * If 'head' is the list head, this adds an element to the end of the list.
+ */
+void dm_list_add(struct dm_list *head, struct dm_list *elem)
+{
+	assert(head->n);
+
+	elem->n = head;
+	elem->p = head->p;
+
+	head->p->n = elem;
+	head->p = elem;
+}
+
+/*
+ * Insert an element after 'head'.
+ * If 'head' is the list head, this adds an element to the front of the list.
+ */
+void dm_list_add_h(struct dm_list *head, struct dm_list *elem)
+{
+	assert(head->n);
+
+	elem->n = head->n;
+	elem->p = head;
+
+	head->n->p = elem;
+	head->n = elem;
+}
+
+/*
+ * Delete an element from its list.
+ * Note that this doesn't change the element itself - it may still be safe
+ * to follow its pointers.
+ */
+void dm_list_del(struct dm_list *elem)
+{
+	elem->n->p = elem->p;
+	elem->p->n = elem->n;
+}
+
+/*
+ * Remove an element from existing list and insert before 'head'.
+ */
+void dm_list_move(struct dm_list *head, struct dm_list *elem)
+{
+        dm_list_del(elem);
+        dm_list_add(head, elem);
+}
+
+/*
+ * Is the list empty?
+ */
+int dm_list_empty(const struct dm_list *head)
+{
+	return head->n == head;
+}
+
+/*
+ * Is this the first element of the list?
+ */
+int dm_list_start(const struct dm_list *head, const struct dm_list *elem)
+{
+	return elem->p == head;
+}
+
+/*
+ * Is this the last element of the list?
+ */
+int dm_list_end(const struct dm_list *head, const struct dm_list *elem)
+{
+	return elem->n == head;
+}
+
+/*
+ * Return first element of the list or NULL if empty
+ */
+struct dm_list *dm_list_first(const struct dm_list *head)
+{
+	return (dm_list_empty(head) ? NULL : head->n);
+}
+
+/*
+ * Return last element of the list or NULL if empty
+ */
+struct dm_list *dm_list_last(const struct dm_list *head)
+{
+	return (dm_list_empty(head) ? NULL : head->p);
+}
+
+/*
+ * Return the previous element of the list, or NULL if we've reached the start.
+ */
+struct dm_list *dm_list_prev(const struct dm_list *head, const struct dm_list *elem)
+{
+	return (dm_list_start(head, elem) ? NULL : elem->p);
+}
+
+/*
+ * Return the next element of the list, or NULL if we've reached the end.
+ */
+struct dm_list *dm_list_next(const struct dm_list *head, const struct dm_list *elem)
+{
+	return (dm_list_end(head, elem) ? NULL : elem->n);
+}
+
+/*
+ * Return the number of elements in a list by walking it.
+ */
+unsigned int dm_list_size(const struct dm_list *head)
+{
+	unsigned int s = 0;
+	const struct dm_list *v;
+
+	dm_list_iterate(v, head)
+	    s++;
+
+	return s;
+}
+
+/*
+ * Join two lists together.
+ * This moves all the elements of the list 'head1' to the end of the list
+ * 'head', leaving 'head1' empty.
+ */
+void dm_list_splice(struct dm_list *head, struct dm_list *head1)
+{
+	assert(head->n);
+	assert(head1->n);
+
+	if (dm_list_empty(head1))
+	    return;
+
+	head1->p->n = head;
+	head1->n->p = head->p;
+
+	head->p->n = head1->n;
+	head->p = head1->p;
+
+	dm_list_init(head1);
+}
diff --git a/base/data-struct/list.h b/base/data-struct/list.h
new file mode 100644
index 0000000..1a107d1
--- /dev/null
+++ b/base/data-struct/list.h
@@ -0,0 +1,209 @@
+#ifndef BASE_DATA_STRUCT_LIST_H
+#define BASE_DATA_STRUCT_LIST_H
+
+//----------------------------------------------------------------
+
+/*
+ * A list consists of a list head plus elements.
+ * Each element has 'next' and 'previous' pointers.
+ * The list head's pointers point to the first and the last element.
+ */
+
+struct dm_list {
+	struct dm_list *n, *p;
+};
+
+/*
+ * String list.
+ */
+struct dm_str_list {
+	struct dm_list list;
+	const char *str;
+};
+
+/*
+ * Initialise a list before use.
+ * The list head's next and previous pointers point back to itself.
+ */
+#define DM_LIST_HEAD_INIT(name)	 { &(name), &(name) }
+#define DM_LIST_INIT(name)	struct dm_list name = DM_LIST_HEAD_INIT(name)
+void dm_list_init(struct dm_list *head);
+
+/*
+ * Insert an element before 'head'.
+ * If 'head' is the list head, this adds an element to the end of the list.
+ */
+void dm_list_add(struct dm_list *head, struct dm_list *elem);
+
+/*
+ * Insert an element after 'head'.
+ * If 'head' is the list head, this adds an element to the front of the list.
+ */
+void dm_list_add_h(struct dm_list *head, struct dm_list *elem);
+
+/*
+ * Delete an element from its list.
+ * Note that this doesn't change the element itself - it may still be safe
+ * to follow its pointers.
+ */
+void dm_list_del(struct dm_list *elem);
+
+/*
+ * Remove an element from existing list and insert before 'head'.
+ */
+void dm_list_move(struct dm_list *head, struct dm_list *elem);
+
+/*
+ * Join 'head1' to the end of 'head'.
+ */
+void dm_list_splice(struct dm_list *head, struct dm_list *head1);
+
+/*
+ * Is the list empty?
+ */
+int dm_list_empty(const struct dm_list *head);
+
+/*
+ * Is this the first element of the list?
+ */
+int dm_list_start(const struct dm_list *head, const struct dm_list *elem);
+
+/*
+ * Is this the last element of the list?
+ */
+int dm_list_end(const struct dm_list *head, const struct dm_list *elem);
+
+/*
+ * Return first element of the list or NULL if empty
+ */
+struct dm_list *dm_list_first(const struct dm_list *head);
+
+/*
+ * Return last element of the list or NULL if empty
+ */
+struct dm_list *dm_list_last(const struct dm_list *head);
+
+/*
+ * Return the previous element of the list, or NULL if we've reached the start.
+ */
+struct dm_list *dm_list_prev(const struct dm_list *head, const struct dm_list *elem);
+
+/*
+ * Return the next element of the list, or NULL if we've reached the end.
+ */
+struct dm_list *dm_list_next(const struct dm_list *head, const struct dm_list *elem);
+
+/*
+ * Given the address v of an instance of 'struct dm_list' called 'head'
+ * contained in a structure of type t, return the containing structure.
+ */
+#define dm_list_struct_base(v, t, head) \
+    ((t *)((const char *)(v) - (const char *)&((t *) 0)->head))
+
+/*
+ * Given the address v of an instance of 'struct dm_list list' contained in
+ * a structure of type t, return the containing structure.
+ */
+#define dm_list_item(v, t) dm_list_struct_base((v), t, list)
+
+/*
+ * Given the address v of one known element e in a known structure of type t,
+ * return another element f.
+ */
+#define dm_struct_field(v, t, e, f) \
+    (((t *)((uintptr_t)(v) - (uintptr_t)&((t *) 0)->e))->f)
+
+/*
+ * Given the address v of a known element e in a known structure of type t,
+ * return the list head 'list'
+ */
+#define dm_list_head(v, t, e) dm_struct_field(v, t, e, list)
+
+/*
+ * Set v to each element of a list in turn.
+ */
+#define dm_list_iterate(v, head) \
+	for (v = (head)->n; v != head; v = v->n)
+
+/*
+ * Set v to each element in a list in turn, starting from the element
+ * in front of 'start'.
+ * You can use this to 'unwind' a list_iterate and back out actions on
+ * already-processed elements.
+ * If 'start' is 'head' it walks the list backwards.
+ */
+#define dm_list_uniterate(v, head, start) \
+	for (v = (start)->p; v != head; v = v->p)
+
+/*
+ * A safe way to walk a list and delete and free some elements along
+ * the way.
+ * t must be defined as a temporary variable of the same type as v.
+ */
+#define dm_list_iterate_safe(v, t, head) \
+	for (v = (head)->n, t = v->n; v != head; v = t, t = v->n)
+
+/*
+ * Walk a list, setting 'v' in turn to the containing structure of each item.
+ * The containing structure should be the same type as 'v'.
+ * The 'struct dm_list' variable within the containing structure is 'field'.
+ */
+#define dm_list_iterate_items_gen(v, head, field) \
+	for (v = dm_list_struct_base((head)->n, __typeof__(*v), field); \
+	     &v->field != (head); \
+	     v = dm_list_struct_base(v->field.n, __typeof__(*v), field))
+
+/*
+ * Walk a list, setting 'v' in turn to the containing structure of each item.
+ * The containing structure should be the same type as 'v'.
+ * The list should be 'struct dm_list list' within the containing structure.
+ */
+#define dm_list_iterate_items(v, head) dm_list_iterate_items_gen(v, (head), list)
+
+/*
+ * Walk a list, setting 'v' in turn to the containing structure of each item.
+ * The containing structure should be the same type as 'v'.
+ * The 'struct dm_list' variable within the containing structure is 'field'.
+ * t must be defined as a temporary variable of the same type as v.
+ */
+#define dm_list_iterate_items_gen_safe(v, t, head, field) \
+	for (v = dm_list_struct_base((head)->n, __typeof__(*v), field), \
+	     t = dm_list_struct_base(v->field.n, __typeof__(*v), field); \
+	     &v->field != (head); \
+	     v = t, t = dm_list_struct_base(v->field.n, __typeof__(*v), field))
+/*
+ * Walk a list, setting 'v' in turn to the containing structure of each item.
+ * The containing structure should be the same type as 'v'.
+ * The list should be 'struct dm_list list' within the containing structure.
+ * t must be defined as a temporary variable of the same type as v.
+ */
+#define dm_list_iterate_items_safe(v, t, head) \
+	dm_list_iterate_items_gen_safe(v, t, (head), list)
+
+/*
+ * Walk a list backwards, setting 'v' in turn to the containing structure
+ * of each item.
+ * The containing structure should be the same type as 'v'.
+ * The 'struct dm_list' variable within the containing structure is 'field'.
+ */
+#define dm_list_iterate_back_items_gen(v, head, field) \
+	for (v = dm_list_struct_base((head)->p, __typeof__(*v), field); \
+	     &v->field != (head); \
+	     v = dm_list_struct_base(v->field.p, __typeof__(*v), field))
+
+/*
+ * Walk a list backwards, setting 'v' in turn to the containing structure
+ * of each item.
+ * The containing structure should be the same type as 'v'.
+ * The list should be 'struct dm_list list' within the containing structure.
+ */
+#define dm_list_iterate_back_items(v, head) dm_list_iterate_back_items_gen(v, (head), list)
+
+/*
+ * Return the number of elements in a list by walking it.
+ */
+unsigned int dm_list_size(const struct dm_list *head);
+
+//----------------------------------------------------------------
+
+#endif
diff --git a/device_mapper/Makefile b/device_mapper/Makefile
index b246f82..4036cb4 100644
--- a/device_mapper/Makefile
+++ b/device_mapper/Makefile
@@ -13,7 +13,6 @@
 DEVICE_MAPPER_SOURCE=\
 	device_mapper/datastruct/bitset.c \
 	device_mapper/datastruct/hash.c \
-	device_mapper/datastruct/list.c \
 	device_mapper/libdm-common.c \
 	device_mapper/libdm-config.c \
 	device_mapper/libdm-deptree.c \
diff --git a/device_mapper/datastruct/list.c b/device_mapper/datastruct/list.c
deleted file mode 100644
index bda8027..0000000
--- a/device_mapper/datastruct/list.c
+++ /dev/null
@@ -1,168 +0,0 @@
-/*
- * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2010 Red Hat, Inc. All rights reserved.
- *
- * This file is part of LVM2.
- *
- * This copyrighted material is made available to anyone wishing to use,
- * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU Lesser General Public License v.2.1.
- *
- * You should have received a copy of the GNU Lesser General Public License
- * along with this program; if not, write to the Free Software Foundation,
- * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
- */
-
-#include "device_mapper/misc/dmlib.h"
-#include <assert.h>
-
-/*
- * Initialise a list before use.
- * The list head's next and previous pointers point back to itself.
- */
-void dm_list_init(struct dm_list *head)
-{
-	head->n = head->p = head;
-}
-
-/*
- * Insert an element before 'head'.
- * If 'head' is the list head, this adds an element to the end of the list.
- */
-void dm_list_add(struct dm_list *head, struct dm_list *elem)
-{
-	assert(head->n);
-
-	elem->n = head;
-	elem->p = head->p;
-
-	head->p->n = elem;
-	head->p = elem;
-}
-
-/*
- * Insert an element after 'head'.
- * If 'head' is the list head, this adds an element to the front of the list.
- */
-void dm_list_add_h(struct dm_list *head, struct dm_list *elem)
-{
-	assert(head->n);
-
-	elem->n = head->n;
-	elem->p = head;
-
-	head->n->p = elem;
-	head->n = elem;
-}
-
-/*
- * Delete an element from its list.
- * Note that this doesn't change the element itself - it may still be safe
- * to follow its pointers.
- */
-void dm_list_del(struct dm_list *elem)
-{
-	elem->n->p = elem->p;
-	elem->p->n = elem->n;
-}
-
-/*
- * Remove an element from existing list and insert before 'head'.
- */
-void dm_list_move(struct dm_list *head, struct dm_list *elem)
-{
-        dm_list_del(elem);
-        dm_list_add(head, elem);
-}
-
-/*
- * Is the list empty?
- */
-int dm_list_empty(const struct dm_list *head)
-{
-	return head->n == head;
-}
-
-/*
- * Is this the first element of the list?
- */
-int dm_list_start(const struct dm_list *head, const struct dm_list *elem)
-{
-	return elem->p == head;
-}
-
-/*
- * Is this the last element of the list?
- */
-int dm_list_end(const struct dm_list *head, const struct dm_list *elem)
-{
-	return elem->n == head;
-}
-
-/*
- * Return first element of the list or NULL if empty
- */
-struct dm_list *dm_list_first(const struct dm_list *head)
-{
-	return (dm_list_empty(head) ? NULL : head->n);
-}
-
-/*
- * Return last element of the list or NULL if empty
- */
-struct dm_list *dm_list_last(const struct dm_list *head)
-{
-	return (dm_list_empty(head) ? NULL : head->p);
-}
-
-/*
- * Return the previous element of the list, or NULL if we've reached the start.
- */
-struct dm_list *dm_list_prev(const struct dm_list *head, const struct dm_list *elem)
-{
-	return (dm_list_start(head, elem) ? NULL : elem->p);
-}
-
-/*
- * Return the next element of the list, or NULL if we've reached the end.
- */
-struct dm_list *dm_list_next(const struct dm_list *head, const struct dm_list *elem)
-{
-	return (dm_list_end(head, elem) ? NULL : elem->n);
-}
-
-/*
- * Return the number of elements in a list by walking it.
- */
-unsigned int dm_list_size(const struct dm_list *head)
-{
-	unsigned int s = 0;
-	const struct dm_list *v;
-
-	dm_list_iterate(v, head)
-	    s++;
-
-	return s;
-}
-
-/*
- * Join two lists together.
- * This moves all the elements of the list 'head1' to the end of the list
- * 'head', leaving 'head1' empty.
- */
-void dm_list_splice(struct dm_list *head, struct dm_list *head1)
-{
-	assert(head->n);
-	assert(head1->n);
-
-	if (dm_list_empty(head1))
-	    return;
-
-	head1->p->n = head;
-	head1->n->p = head->p;
-
-	head->p->n = head1->n;
-	head->p = head1->p;
-
-	dm_list_init(head1);
-}
diff --git a/device_mapper/libdevmapper.h b/device_mapper/libdevmapper.h
index 2438f74..f7ff4ce 100644
--- a/device_mapper/libdevmapper.h
+++ b/device_mapper/libdevmapper.h
@@ -31,6 +31,10 @@
 #include <stdlib.h>
 #include <stdio.h>
 
+#include "base/data-struct/list.h"
+
+#include "base/data-struct/list.h"
+
 #ifndef __GNUC__
 # define __typeof__ typeof
 #endif
@@ -2366,211 +2370,6 @@ void *dm_hash_lookup_with_count(struct dm_hash_table *t, const char *key, int *c
 	for (v = dm_hash_get_first((h)); v; \
 	     v = dm_hash_get_next((h), v))
 
-/****************
- * list functions
- ****************/
-
-/*
- * A list consists of a list head plus elements.
- * Each element has 'next' and 'previous' pointers.
- * The list head's pointers point to the first and the last element.
- */
-
-struct dm_list {
-	struct dm_list *n, *p;
-};
-
-/*
- * String list.
- */
-struct dm_str_list {
-	struct dm_list list;
-	const char *str;
-};
-
-/*
- * Initialise a list before use.
- * The list head's next and previous pointers point back to itself.
- */
-#define DM_LIST_HEAD_INIT(name)	 { &(name), &(name) }
-#define DM_LIST_INIT(name)	struct dm_list name = DM_LIST_HEAD_INIT(name)
-void dm_list_init(struct dm_list *head);
-
-/*
- * Insert an element before 'head'.
- * If 'head' is the list head, this adds an element to the end of the list.
- */
-void dm_list_add(struct dm_list *head, struct dm_list *elem);
-
-/*
- * Insert an element after 'head'.
- * If 'head' is the list head, this adds an element to the front of the list.
- */
-void dm_list_add_h(struct dm_list *head, struct dm_list *elem);
-
-/*
- * Delete an element from its list.
- * Note that this doesn't change the element itself - it may still be safe
- * to follow its pointers.
- */
-void dm_list_del(struct dm_list *elem);
-
-/*
- * Remove an element from existing list and insert before 'head'.
- */
-void dm_list_move(struct dm_list *head, struct dm_list *elem);
-
-/*
- * Join 'head1' to the end of 'head'.
- */
-void dm_list_splice(struct dm_list *head, struct dm_list *head1);
-
-/*
- * Is the list empty?
- */
-int dm_list_empty(const struct dm_list *head);
-
-/*
- * Is this the first element of the list?
- */
-int dm_list_start(const struct dm_list *head, const struct dm_list *elem);
-
-/*
- * Is this the last element of the list?
- */
-int dm_list_end(const struct dm_list *head, const struct dm_list *elem);
-
-/*
- * Return first element of the list or NULL if empty
- */
-struct dm_list *dm_list_first(const struct dm_list *head);
-
-/*
- * Return last element of the list or NULL if empty
- */
-struct dm_list *dm_list_last(const struct dm_list *head);
-
-/*
- * Return the previous element of the list, or NULL if we've reached the start.
- */
-struct dm_list *dm_list_prev(const struct dm_list *head, const struct dm_list *elem);
-
-/*
- * Return the next element of the list, or NULL if we've reached the end.
- */
-struct dm_list *dm_list_next(const struct dm_list *head, const struct dm_list *elem);
-
-/*
- * Given the address v of an instance of 'struct dm_list' called 'head'
- * contained in a structure of type t, return the containing structure.
- */
-#define dm_list_struct_base(v, t, head) \
-    ((t *)((const char *)(v) - (const char *)&((t *) 0)->head))
-
-/*
- * Given the address v of an instance of 'struct dm_list list' contained in
- * a structure of type t, return the containing structure.
- */
-#define dm_list_item(v, t) dm_list_struct_base((v), t, list)
-
-/*
- * Given the address v of one known element e in a known structure of type t,
- * return another element f.
- */
-#define dm_struct_field(v, t, e, f) \
-    (((t *)((uintptr_t)(v) - (uintptr_t)&((t *) 0)->e))->f)
-
-/*
- * Given the address v of a known element e in a known structure of type t,
- * return the list head 'list'
- */
-#define dm_list_head(v, t, e) dm_struct_field(v, t, e, list)
-
-/*
- * Set v to each element of a list in turn.
- */
-#define dm_list_iterate(v, head) \
-	for (v = (head)->n; v != head; v = v->n)
-
-/*
- * Set v to each element in a list in turn, starting from the element
- * in front of 'start'.
- * You can use this to 'unwind' a list_iterate and back out actions on
- * already-processed elements.
- * If 'start' is 'head' it walks the list backwards.
- */
-#define dm_list_uniterate(v, head, start) \
-	for (v = (start)->p; v != head; v = v->p)
-
-/*
- * A safe way to walk a list and delete and free some elements along
- * the way.
- * t must be defined as a temporary variable of the same type as v.
- */
-#define dm_list_iterate_safe(v, t, head) \
-	for (v = (head)->n, t = v->n; v != head; v = t, t = v->n)
-
-/*
- * Walk a list, setting 'v' in turn to the containing structure of each item.
- * The containing structure should be the same type as 'v'.
- * The 'struct dm_list' variable within the containing structure is 'field'.
- */
-#define dm_list_iterate_items_gen(v, head, field) \
-	for (v = dm_list_struct_base((head)->n, __typeof__(*v), field); \
-	     &v->field != (head); \
-	     v = dm_list_struct_base(v->field.n, __typeof__(*v), field))
-
-/*
- * Walk a list, setting 'v' in turn to the containing structure of each item.
- * The containing structure should be the same type as 'v'.
- * The list should be 'struct dm_list list' within the containing structure.
- */
-#define dm_list_iterate_items(v, head) dm_list_iterate_items_gen(v, (head), list)
-
-/*
- * Walk a list, setting 'v' in turn to the containing structure of each item.
- * The containing structure should be the same type as 'v'.
- * The 'struct dm_list' variable within the containing structure is 'field'.
- * t must be defined as a temporary variable of the same type as v.
- */
-#define dm_list_iterate_items_gen_safe(v, t, head, field) \
-	for (v = dm_list_struct_base((head)->n, __typeof__(*v), field), \
-	     t = dm_list_struct_base(v->field.n, __typeof__(*v), field); \
-	     &v->field != (head); \
-	     v = t, t = dm_list_struct_base(v->field.n, __typeof__(*v), field))
-/*
- * Walk a list, setting 'v' in turn to the containing structure of each item.
- * The containing structure should be the same type as 'v'.
- * The list should be 'struct dm_list list' within the containing structure.
- * t must be defined as a temporary variable of the same type as v.
- */
-#define dm_list_iterate_items_safe(v, t, head) \
-	dm_list_iterate_items_gen_safe(v, t, (head), list)
-
-/*
- * Walk a list backwards, setting 'v' in turn to the containing structure
- * of each item.
- * The containing structure should be the same type as 'v'.
- * The 'struct dm_list' variable within the containing structure is 'field'.
- */
-#define dm_list_iterate_back_items_gen(v, head, field) \
-	for (v = dm_list_struct_base((head)->p, __typeof__(*v), field); \
-	     &v->field != (head); \
-	     v = dm_list_struct_base(v->field.p, __typeof__(*v), field))
-
-/*
- * Walk a list backwards, setting 'v' in turn to the containing structure
- * of each item.
- * The containing structure should be the same type as 'v'.
- * The list should be 'struct dm_list list' within the containing structure.
- */
-#define dm_list_iterate_back_items(v, head) dm_list_iterate_back_items_gen(v, (head), list)
-
-/*
- * Return the number of elements in a list by walking it.
- */
-unsigned int dm_list_size(const struct dm_list *head);
-
 /*********
  * selinux
  *********/


