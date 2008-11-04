From: agk@sourceware.org <agk@sourceware.org>
Date: 4 Nov 2008 14:57:08 -0000
Subject: LVM2 ./make.tmpl.in include/.symlinks lib/data ...
Message-ID: <20081104145708.8778.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-11-04 14:57:07

Modified files:
	.              : make.tmpl.in 
	include        : .symlinks 
	lib/datastruct : lvm-types.h 
	libdm          : libdevmapper.h 
	tools          : tools.h 

Log message:
	more missing bits

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/make.tmpl.in.diff?cvsroot=lvm2&r1=1.60&r2=1.61
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/include/.symlinks.diff?cvsroot=lvm2&r1=1.53&r2=1.54
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/datastruct/lvm-types.h.diff?cvsroot=lvm2&r1=1.15&r2=1.16
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdevmapper.h.diff?cvsroot=lvm2&r1=1.84&r2=1.85
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/tools.h.diff?cvsroot=lvm2&r1=1.62&r2=1.63

--- LVM2/make.tmpl.in	2008/11/03 22:14:26	1.60
+++ LVM2/make.tmpl.in	2008/11/04 14:57:05	1.61
@@ -86,6 +86,14 @@
 LDFLAGS += -L$(top_srcdir)/libdm -L$(top_srcdir)/lib
 CLDFLAGS += -L$(top_srcdir)/libdm -L$(top_srcdir)/lib
 
+ifeq ("@DM_COMPAT@", "yes")
+  DEFS += -DDM_COMPAT
+endif
+
+ifeq ("@DM_IOCTLS@", "yes")
+  DEFS += -DDM_IOCTLS
+endif
+
 #DEFS += -DDEBUG_POOL
 #DEFS += -DBOUNDS_CHECK
 
@@ -103,7 +111,7 @@
 LIB_VERSION_DM := $(shell cat $(top_srcdir)/VERSION_DM | \
 		    awk -F '.' '{printf "%s.%s",$$1,$$2}')
 
-INCLUDES += -I$(top_srcdir)/include
+INCLUDES += -I. -I$(top_srcdir)/include
 
 ifdef DESTDIR
   INCLUDES += -I$(DESTDIR)/usr/include
--- LVM2/include/.symlinks	2008/11/03 18:59:58	1.53
+++ LVM2/include/.symlinks	2008/11/04 14:57:06	1.54
@@ -51,7 +51,6 @@
 ../lib/report/report.h
 ../lib/uuid/uuid.h
 ../libdm/libdevmapper.h
-../libdm/datastruct/list.h
 ../libdm/misc/dm-ioctl.h
 ../libdm/misc/dm-logging.h
 ../libdm/misc/dmlib.h
--- LVM2/lib/datastruct/lvm-types.h	2008/11/03 22:14:27	1.15
+++ LVM2/lib/datastruct/lvm-types.h	2008/11/04 14:57:06	1.16
@@ -16,8 +16,6 @@
 #ifndef _LVM_TYPES_H
 #define _LVM_TYPES_H
 
-#include "list.h"
-
 #include <sys/types.h>
 #include <inttypes.h>
 
--- LVM2/libdm/libdevmapper.h	2008/09/02 12:16:07	1.84
+++ LVM2/libdm/libdevmapper.h	2008/11/04 14:57:06	1.85
@@ -615,6 +615,197 @@
 	for (v = dm_hash_get_first(h); v; \
 	     v = dm_hash_get_next(h, v))
 
+/****************
+ * list functions
+ ****************/
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
+ * Initialise a list before use.
+ * The list head's next and previous pointers point back to itself.
+ */
+#define DM_LIST_INIT(name)	struct dm_list name = { &(name), &(name) }
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
+    ((t *)((uintptr_t)(v) - (uintptr_t)&((t *) 0)->head))
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
+	for (v = dm_list_struct_base((head)->n, typeof(*v), field); \
+	     &v->field != (head); \
+	     v = dm_list_struct_base(v->field.n, typeof(*v), field))
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
+	for (v = dm_list_struct_base((head)->n, typeof(*v), field), \
+	     t = dm_list_struct_base(v->field.n, typeof(*v), field); \
+	     &v->field != (head); \
+	     v = t, t = dm_list_struct_base(v->field.n, typeof(*v), field))
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
+	for (v = dm_list_struct_base((head)->p, typeof(*v), field); \
+	     &v->field != (head); \
+	     v = dm_list_struct_base(v->field.p, typeof(*v), field))
+
+/*
+ * Walk a list backwards, setting 'v' in turn to the containing structure 
+ * of each item.
+ * The containing structure should be the same type as 'v'.
+ * The list should be 'struct dm_list list' within the containing structure.
+ */
+#define dm_list_iterate_back_items(v, head) list_iterate_back_items_gen(v, (head), list)
+
+/*
+ * Return the number of elements in a list by walking it.
+ */
+unsigned int dm_list_size(const struct dm_list *head);
+
 /*********
  * selinux
  *********/
--- LVM2/tools/tools.h	2008/10/30 17:27:25	1.62
+++ LVM2/tools/tools.h	2008/11/04 14:57:06	1.63
@@ -39,7 +39,6 @@
 #include "filter-persistent.h"
 #include "filter-regex.h"
 #include "metadata-exported.h"
-#include "list.h"
 #include "locking.h"
 #include "lvm-exec.h"
 #include "lvm-file.h"


