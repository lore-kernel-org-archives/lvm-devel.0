From: Joe Thornber <thornber@sourceware.org>
Date: Fri, 8 Jun 2018 09:25:55 -0400
Subject: master - device_mapper: move hash.[hc] to base/data-struct
Message-ID: <201806081325.w58DPtIQ015653@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=61e67e51e112a317886fcfc70b2d479d08cbda90
Commit:        61e67e51e112a317886fcfc70b2d479d08cbda90
Parent:        962a3eb3faced455b0a10f8e7d4575bed65b8dbd
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Fri Jun 8 13:54:19 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Fri Jun 8 13:54:19 2018 +0100

device_mapper: move hash.[hc] to base/data-struct

---
 base/Makefile                   |    1 +
 base/data-struct/hash.c         |  394 +++++++++++++++++++++++++++++++++++++++
 base/data-struct/hash.h         |   94 +++++++++
 device_mapper/Makefile          |    1 -
 device_mapper/all.h             |   89 +---------
 device_mapper/datastruct/hash.c |  393 --------------------------------------
 6 files changed, 490 insertions(+), 482 deletions(-)

diff --git a/base/Makefile b/base/Makefile
index 4dcb6b6..02c4236 100644
--- a/base/Makefile
+++ b/base/Makefile
@@ -12,6 +12,7 @@
 
 BASE_SOURCE=\
 	base/data-struct/radix-tree.c \
+	base/data-struct/hash.c \
 	base/data-struct/list.c
 
 BASE_DEPENDS=$(addprefix $(top_builddir)/,$(subst .c,.d,$(BASE_SOURCE)))
diff --git a/base/data-struct/hash.c b/base/data-struct/hash.c
new file mode 100644
index 0000000..0a0541d
--- /dev/null
+++ b/base/data-struct/hash.c
@@ -0,0 +1,394 @@
+/*
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
+ * Copyright (C) 2004-2011 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of the device-mapper userspace tools.
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
+#include "device_mapper/misc/dmlib.h"
+#include "base/memory/zalloc.h"
+#include "hash.h"
+
+struct dm_hash_node {
+	struct dm_hash_node *next;
+	void *data;
+	unsigned data_len;
+	unsigned keylen;
+	char key[0];
+};
+
+struct dm_hash_table {
+	unsigned num_nodes;
+	unsigned num_slots;
+	struct dm_hash_node **slots;
+};
+
+/* Permutation of the Integers 0 through 255 */
+static unsigned char _nums[] = {
+	1, 14, 110, 25, 97, 174, 132, 119, 138, 170, 125, 118, 27, 233, 140, 51,
+	87, 197, 177, 107, 234, 169, 56, 68, 30, 7, 173, 73, 188, 40, 36, 65,
+	49, 213, 104, 190, 57, 211, 148, 223, 48, 115, 15, 2, 67, 186, 210, 28,
+	12, 181, 103, 70, 22, 58, 75, 78, 183, 167, 238, 157, 124, 147, 172,
+	144,
+	176, 161, 141, 86, 60, 66, 128, 83, 156, 241, 79, 46, 168, 198, 41, 254,
+	178, 85, 253, 237, 250, 154, 133, 88, 35, 206, 95, 116, 252, 192, 54,
+	221,
+	102, 218, 255, 240, 82, 106, 158, 201, 61, 3, 89, 9, 42, 155, 159, 93,
+	166, 80, 50, 34, 175, 195, 100, 99, 26, 150, 16, 145, 4, 33, 8, 189,
+	121, 64, 77, 72, 208, 245, 130, 122, 143, 55, 105, 134, 29, 164, 185,
+	194,
+	193, 239, 101, 242, 5, 171, 126, 11, 74, 59, 137, 228, 108, 191, 232,
+	139,
+	6, 24, 81, 20, 127, 17, 91, 92, 251, 151, 225, 207, 21, 98, 113, 112,
+	84, 226, 18, 214, 199, 187, 13, 32, 94, 220, 224, 212, 247, 204, 196,
+	43,
+	249, 236, 45, 244, 111, 182, 153, 136, 129, 90, 217, 202, 19, 165, 231,
+	71,
+	230, 142, 96, 227, 62, 179, 246, 114, 162, 53, 160, 215, 205, 180, 47,
+	109,
+	44, 38, 31, 149, 135, 0, 216, 52, 63, 23, 37, 69, 39, 117, 146, 184,
+	163, 200, 222, 235, 248, 243, 219, 10, 152, 131, 123, 229, 203, 76, 120,
+	209
+};
+
+static struct dm_hash_node *_create_node(const char *str, unsigned len)
+{
+	struct dm_hash_node *n = malloc(sizeof(*n) + len);
+
+	if (n) {
+		memcpy(n->key, str, len);
+		n->keylen = len;
+	}
+
+	return n;
+}
+
+static unsigned long _hash(const char *str, unsigned len)
+{
+	unsigned long h = 0, g;
+	unsigned i;
+
+	for (i = 0; i < len; i++) {
+		h <<= 4;
+		h += _nums[(unsigned char) *str++];
+		g = h & ((unsigned long) 0xf << 16u);
+		if (g) {
+			h ^= g >> 16u;
+			h ^= g >> 5u;
+		}
+	}
+
+	return h;
+}
+
+struct dm_hash_table *dm_hash_create(unsigned size_hint)
+{
+	size_t len;
+	unsigned new_size = 16u;
+	struct dm_hash_table *hc = zalloc(sizeof(*hc));
+
+	if (!hc)
+		return_0;
+
+	/* round size hint up to a power of two */
+	while (new_size < size_hint)
+		new_size = new_size << 1;
+
+	hc->num_slots = new_size;
+	len = sizeof(*(hc->slots)) * new_size;
+	if (!(hc->slots = zalloc(len)))
+		goto_bad;
+
+	return hc;
+
+      bad:
+	free(hc->slots);
+	free(hc);
+	return 0;
+}
+
+static void _free_nodes(struct dm_hash_table *t)
+{
+	struct dm_hash_node *c, *n;
+	unsigned i;
+
+	for (i = 0; i < t->num_slots; i++)
+		for (c = t->slots[i]; c; c = n) {
+			n = c->next;
+			free(c);
+		}
+}
+
+void dm_hash_destroy(struct dm_hash_table *t)
+{
+	_free_nodes(t);
+	free(t->slots);
+	free(t);
+}
+
+static struct dm_hash_node **_find(struct dm_hash_table *t, const void *key,
+				   uint32_t len)
+{
+	unsigned h = _hash(key, len) & (t->num_slots - 1);
+	struct dm_hash_node **c;
+
+	for (c = &t->slots[h]; *c; c = &((*c)->next)) {
+		if ((*c)->keylen != len)
+			continue;
+
+		if (!memcmp(key, (*c)->key, len))
+			break;
+	}
+
+	return c;
+}
+
+void *dm_hash_lookup_binary(struct dm_hash_table *t, const void *key,
+			    uint32_t len)
+{
+	struct dm_hash_node **c = _find(t, key, len);
+
+	return *c ? (*c)->data : 0;
+}
+
+int dm_hash_insert_binary(struct dm_hash_table *t, const void *key,
+			  uint32_t len, void *data)
+{
+	struct dm_hash_node **c = _find(t, key, len);
+
+	if (*c)
+		(*c)->data = data;
+	else {
+		struct dm_hash_node *n = _create_node(key, len);
+
+		if (!n)
+			return 0;
+
+		n->data = data;
+		n->next = 0;
+		*c = n;
+		t->num_nodes++;
+	}
+
+	return 1;
+}
+
+void dm_hash_remove_binary(struct dm_hash_table *t, const void *key,
+			uint32_t len)
+{
+	struct dm_hash_node **c = _find(t, key, len);
+
+	if (*c) {
+		struct dm_hash_node *old = *c;
+		*c = (*c)->next;
+		free(old);
+		t->num_nodes--;
+	}
+}
+
+void *dm_hash_lookup(struct dm_hash_table *t, const char *key)
+{
+	return dm_hash_lookup_binary(t, key, strlen(key) + 1);
+}
+
+int dm_hash_insert(struct dm_hash_table *t, const char *key, void *data)
+{
+	return dm_hash_insert_binary(t, key, strlen(key) + 1, data);
+}
+
+void dm_hash_remove(struct dm_hash_table *t, const char *key)
+{
+	dm_hash_remove_binary(t, key, strlen(key) + 1);
+}
+
+static struct dm_hash_node **_find_str_with_val(struct dm_hash_table *t,
+					        const void *key, const void *val,
+					        uint32_t len, uint32_t val_len)
+{
+	struct dm_hash_node **c;
+	unsigned h;
+       
+	h = _hash(key, len) & (t->num_slots - 1);
+
+	for (c = &t->slots[h]; *c; c = &((*c)->next)) {
+		if ((*c)->keylen != len)
+			continue;
+
+		if (!memcmp(key, (*c)->key, len) && (*c)->data) {
+			if (((*c)->data_len == val_len) &&
+			    !memcmp(val, (*c)->data, val_len))
+				return c;
+		}
+	}
+
+	return NULL;
+}
+
+int dm_hash_insert_allow_multiple(struct dm_hash_table *t, const char *key,
+				  const void *val, uint32_t val_len)
+{
+	struct dm_hash_node *n;
+	struct dm_hash_node *first;
+	int len = strlen(key) + 1;
+	unsigned h;
+
+	n = _create_node(key, len);
+	if (!n)
+		return 0;
+
+	n->data = (void *)val;
+	n->data_len = val_len;
+
+	h = _hash(key, len) & (t->num_slots - 1);
+
+	first = t->slots[h];
+
+	if (first)
+		n->next = first;
+	else
+		n->next = 0;
+	t->slots[h] = n;
+
+	t->num_nodes++;
+	return 1;
+}
+
+/*
+ * Look through multiple entries with the same key for one that has a
+ * matching val and return that.  If none have maching val, return NULL.
+ */
+void *dm_hash_lookup_with_val(struct dm_hash_table *t, const char *key,
+			      const void *val, uint32_t val_len)
+{
+	struct dm_hash_node **c;
+
+	c = _find_str_with_val(t, key, val, strlen(key) + 1, val_len);
+
+	return (c && *c) ? (*c)->data : 0;
+}
+
+/*
+ * Look through multiple entries with the same key for one that has a
+ * matching val and remove that.
+ */
+void dm_hash_remove_with_val(struct dm_hash_table *t, const char *key,
+			     const void *val, uint32_t val_len)
+{
+	struct dm_hash_node **c;
+
+	c = _find_str_with_val(t, key, val, strlen(key) + 1, val_len);
+
+	if (c && *c) {
+		struct dm_hash_node *old = *c;
+		*c = (*c)->next;
+		free(old);
+		t->num_nodes--;
+	}
+}
+
+/*
+ * Look up the value for a key and count how many
+ * entries have the same key.
+ *
+ * If no entries have key, return NULL and set count to 0.
+ *
+ * If one entry has the key, the function returns the val,
+ * and sets count to 1.
+ *
+ * If N entries have the key, the function returns the val
+ * from the first entry, and sets count to N.
+ */
+void *dm_hash_lookup_with_count(struct dm_hash_table *t, const char *key, int *count)
+{
+	struct dm_hash_node **c;
+	struct dm_hash_node **c1 = NULL;
+	uint32_t len = strlen(key) + 1;
+	unsigned h;
+
+	*count = 0;
+
+	h = _hash(key, len) & (t->num_slots - 1);
+
+	for (c = &t->slots[h]; *c; c = &((*c)->next)) {
+		if ((*c)->keylen != len)
+			continue;
+
+		if (!memcmp(key, (*c)->key, len)) {
+			(*count)++;
+			if (!c1)
+				c1 = c;
+		}
+	}
+
+	if (!c1)
+		return NULL;
+	else
+		return *c1 ? (*c1)->data : 0;
+}
+
+unsigned dm_hash_get_num_entries(struct dm_hash_table *t)
+{
+	return t->num_nodes;
+}
+
+void dm_hash_iter(struct dm_hash_table *t, dm_hash_iterate_fn f)
+{
+	struct dm_hash_node *c, *n;
+	unsigned i;
+
+	for (i = 0; i < t->num_slots; i++)
+		for (c = t->slots[i]; c; c = n) {
+			n = c->next;
+			f(c->data);
+		}
+}
+
+void dm_hash_wipe(struct dm_hash_table *t)
+{
+	_free_nodes(t);
+	memset(t->slots, 0, sizeof(struct dm_hash_node *) * t->num_slots);
+	t->num_nodes = 0u;
+}
+
+char *dm_hash_get_key(struct dm_hash_table *t __attribute__((unused)),
+		      struct dm_hash_node *n)
+{
+	return n->key;
+}
+
+void *dm_hash_get_data(struct dm_hash_table *t __attribute__((unused)),
+		       struct dm_hash_node *n)
+{
+	return n->data;
+}
+
+static struct dm_hash_node *_next_slot(struct dm_hash_table *t, unsigned s)
+{
+	struct dm_hash_node *c = NULL;
+	unsigned i;
+
+	for (i = s; i < t->num_slots && !c; i++)
+		c = t->slots[i];
+
+	return c;
+}
+
+struct dm_hash_node *dm_hash_get_first(struct dm_hash_table *t)
+{
+	return _next_slot(t, 0);
+}
+
+struct dm_hash_node *dm_hash_get_next(struct dm_hash_table *t, struct dm_hash_node *n)
+{
+	unsigned h = _hash(n->key, n->keylen) & (t->num_slots - 1);
+
+	return n->next ? n->next : _next_slot(t, h + 1);
+}
diff --git a/base/data-struct/hash.h b/base/data-struct/hash.h
new file mode 100644
index 0000000..217f5e2
--- /dev/null
+++ b/base/data-struct/hash.h
@@ -0,0 +1,94 @@
+#ifndef BASE_DATA_STRUCT_HASH_H
+#define BASE_DATA_STRUCT_HASH_H
+
+#include <stdint.h>
+
+//----------------------------------------------------------------
+
+struct dm_hash_table;
+struct dm_hash_node;
+
+typedef void (*dm_hash_iterate_fn) (void *data);
+
+struct dm_hash_table *dm_hash_create(unsigned size_hint)
+	__attribute__((__warn_unused_result__));
+void dm_hash_destroy(struct dm_hash_table *t);
+void dm_hash_wipe(struct dm_hash_table *t);
+
+void *dm_hash_lookup(struct dm_hash_table *t, const char *key);
+int dm_hash_insert(struct dm_hash_table *t, const char *key, void *data);
+void dm_hash_remove(struct dm_hash_table *t, const char *key);
+
+void *dm_hash_lookup_binary(struct dm_hash_table *t, const void *key, uint32_t len);
+int dm_hash_insert_binary(struct dm_hash_table *t, const void *key, uint32_t len,
+			  void *data);
+void dm_hash_remove_binary(struct dm_hash_table *t, const void *key, uint32_t len);
+
+unsigned dm_hash_get_num_entries(struct dm_hash_table *t);
+void dm_hash_iter(struct dm_hash_table *t, dm_hash_iterate_fn f);
+
+char *dm_hash_get_key(struct dm_hash_table *t, struct dm_hash_node *n);
+void *dm_hash_get_data(struct dm_hash_table *t, struct dm_hash_node *n);
+struct dm_hash_node *dm_hash_get_first(struct dm_hash_table *t);
+struct dm_hash_node *dm_hash_get_next(struct dm_hash_table *t, struct dm_hash_node *n);
+
+/*
+ * dm_hash_insert() replaces the value of an existing
+ * entry with a matching key if one exists.  Otherwise
+ * it adds a new entry.
+ *
+ * dm_hash_insert_with_val() inserts a new entry if
+ * another entry with the same key already exists.
+ * val_len is the size of the data being inserted.
+ *
+ * If two entries with the same key exist,
+ * (added using dm_hash_insert_allow_multiple), then:
+ * . dm_hash_lookup() returns the first one it finds, and
+ *   dm_hash_lookup_with_val() returns the one with a matching
+ *   val_len/val.
+ * . dm_hash_remove() removes the first one it finds, and
+ *   dm_hash_remove_with_val() removes the one with a matching
+ *   val_len/val.
+ *
+ * If a single entry with a given key exists, and it has
+ * zero val_len, then:
+ * . dm_hash_lookup() returns it
+ * . dm_hash_lookup_with_val(val_len=0) returns it
+ * . dm_hash_remove() removes it
+ * . dm_hash_remove_with_val(val_len=0) removes it
+ *
+ * dm_hash_lookup_with_count() is a single call that will
+ * both lookup a key's value and check if there is more
+ * than one entry with the given key.
+ *
+ * (It is not meant to retrieve all the entries with the
+ * given key.  In the common case where a single entry exists
+ * for the key, it is useful to have a single call that will
+ * both look up the value and indicate if multiple values
+ * exist for the key.)
+ *
+ * dm_hash_lookup_with_count:
+ * . If no entries exist, the function returns NULL, and
+ *   the count is set to 0.
+ * . If only one entry exists, the value of that entry is
+ *   returned and count is set to 1.
+ * . If N entries exists, the value of the first entry is
+ *   returned and count is set to N.
+ */
+
+void *dm_hash_lookup_with_val(struct dm_hash_table *t, const char *key,
+                              const void *val, uint32_t val_len);
+void dm_hash_remove_with_val(struct dm_hash_table *t, const char *key,
+                             const void *val, uint32_t val_len);
+int dm_hash_insert_allow_multiple(struct dm_hash_table *t, const char *key,
+                                  const void *val, uint32_t val_len);
+void *dm_hash_lookup_with_count(struct dm_hash_table *t, const char *key, int *count);
+
+
+#define dm_hash_iterate(v, h) \
+	for (v = dm_hash_get_first((h)); v; \
+	     v = dm_hash_get_next((h), v))
+
+//----------------------------------------------------------------
+
+#endif
diff --git a/device_mapper/Makefile b/device_mapper/Makefile
index da97675..3a1e415 100644
--- a/device_mapper/Makefile
+++ b/device_mapper/Makefile
@@ -12,7 +12,6 @@
 
 DEVICE_MAPPER_SOURCE=\
 	device_mapper/datastruct/bitset.c \
-	device_mapper/datastruct/hash.c \
 	device_mapper/libdm-common.c \
 	device_mapper/libdm-config.c \
 	device_mapper/libdm-deptree.c \
diff --git a/device_mapper/all.h b/device_mapper/all.h
index ca0dbc7..c834f32 100644
--- a/device_mapper/all.h
+++ b/device_mapper/all.h
@@ -32,6 +32,7 @@
 #include <stdio.h>
 
 #include "base/data-struct/list.h"
+#include "base/data-struct/hash.h"
 
 #ifndef __GNUC__
 # define __typeof__ typeof
@@ -2248,94 +2249,6 @@ static inline unsigned hweight32(uint32_t i)
 	return (r & 0x0000FFFF) + ((r >> 16) & 0x0000FFFF);
 }
 
-/****************
- * hash functions
- ****************/
-
-struct dm_hash_table;
-struct dm_hash_node;
-
-typedef void (*dm_hash_iterate_fn) (void *data);
-
-struct dm_hash_table *dm_hash_create(unsigned size_hint)
-	__attribute__((__warn_unused_result__));
-void dm_hash_destroy(struct dm_hash_table *t);
-void dm_hash_wipe(struct dm_hash_table *t);
-
-void *dm_hash_lookup(struct dm_hash_table *t, const char *key);
-int dm_hash_insert(struct dm_hash_table *t, const char *key, void *data);
-void dm_hash_remove(struct dm_hash_table *t, const char *key);
-
-void *dm_hash_lookup_binary(struct dm_hash_table *t, const void *key, uint32_t len);
-int dm_hash_insert_binary(struct dm_hash_table *t, const void *key, uint32_t len,
-			  void *data);
-void dm_hash_remove_binary(struct dm_hash_table *t, const void *key, uint32_t len);
-
-unsigned dm_hash_get_num_entries(struct dm_hash_table *t);
-void dm_hash_iter(struct dm_hash_table *t, dm_hash_iterate_fn f);
-
-char *dm_hash_get_key(struct dm_hash_table *t, struct dm_hash_node *n);
-void *dm_hash_get_data(struct dm_hash_table *t, struct dm_hash_node *n);
-struct dm_hash_node *dm_hash_get_first(struct dm_hash_table *t);
-struct dm_hash_node *dm_hash_get_next(struct dm_hash_table *t, struct dm_hash_node *n);
-
-/*
- * dm_hash_insert() replaces the value of an existing
- * entry with a matching key if one exists.  Otherwise
- * it adds a new entry.
- *
- * dm_hash_insert_with_val() inserts a new entry if
- * another entry with the same key already exists.
- * val_len is the size of the data being inserted.
- *
- * If two entries with the same key exist,
- * (added using dm_hash_insert_allow_multiple), then:
- * . dm_hash_lookup() returns the first one it finds, and
- *   dm_hash_lookup_with_val() returns the one with a matching
- *   val_len/val.
- * . dm_hash_remove() removes the first one it finds, and
- *   dm_hash_remove_with_val() removes the one with a matching
- *   val_len/val.
- *
- * If a single entry with a given key exists, and it has
- * zero val_len, then:
- * . dm_hash_lookup() returns it
- * . dm_hash_lookup_with_val(val_len=0) returns it
- * . dm_hash_remove() removes it
- * . dm_hash_remove_with_val(val_len=0) removes it
- *
- * dm_hash_lookup_with_count() is a single call that will
- * both lookup a key's value and check if there is more
- * than one entry with the given key.
- *
- * (It is not meant to retrieve all the entries with the
- * given key.  In the common case where a single entry exists
- * for the key, it is useful to have a single call that will
- * both look up the value and indicate if multiple values
- * exist for the key.)
- *
- * dm_hash_lookup_with_count:
- * . If no entries exist, the function returns NULL, and
- *   the count is set to 0.
- * . If only one entry exists, the value of that entry is
- *   returned and count is set to 1.
- * . If N entries exists, the value of the first entry is
- *   returned and count is set to N.
- */
-
-void *dm_hash_lookup_with_val(struct dm_hash_table *t, const char *key,
-                              const void *val, uint32_t val_len);
-void dm_hash_remove_with_val(struct dm_hash_table *t, const char *key,
-                             const void *val, uint32_t val_len);
-int dm_hash_insert_allow_multiple(struct dm_hash_table *t, const char *key,
-                                  const void *val, uint32_t val_len);
-void *dm_hash_lookup_with_count(struct dm_hash_table *t, const char *key, int *count);
-
-
-#define dm_hash_iterate(v, h) \
-	for (v = dm_hash_get_first((h)); v; \
-	     v = dm_hash_get_next((h), v))
-
 /*********
  * selinux
  *********/
diff --git a/device_mapper/datastruct/hash.c b/device_mapper/datastruct/hash.c
deleted file mode 100644
index f16508a..0000000
--- a/device_mapper/datastruct/hash.c
+++ /dev/null
@@ -1,393 +0,0 @@
-/*
- * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2011 Red Hat, Inc. All rights reserved.
- *
- * This file is part of the device-mapper userspace tools.
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
-#include "base/memory/zalloc.h"
-
-struct dm_hash_node {
-	struct dm_hash_node *next;
-	void *data;
-	unsigned data_len;
-	unsigned keylen;
-	char key[0];
-};
-
-struct dm_hash_table {
-	unsigned num_nodes;
-	unsigned num_slots;
-	struct dm_hash_node **slots;
-};
-
-/* Permutation of the Integers 0 through 255 */
-static unsigned char _nums[] = {
-	1, 14, 110, 25, 97, 174, 132, 119, 138, 170, 125, 118, 27, 233, 140, 51,
-	87, 197, 177, 107, 234, 169, 56, 68, 30, 7, 173, 73, 188, 40, 36, 65,
-	49, 213, 104, 190, 57, 211, 148, 223, 48, 115, 15, 2, 67, 186, 210, 28,
-	12, 181, 103, 70, 22, 58, 75, 78, 183, 167, 238, 157, 124, 147, 172,
-	144,
-	176, 161, 141, 86, 60, 66, 128, 83, 156, 241, 79, 46, 168, 198, 41, 254,
-	178, 85, 253, 237, 250, 154, 133, 88, 35, 206, 95, 116, 252, 192, 54,
-	221,
-	102, 218, 255, 240, 82, 106, 158, 201, 61, 3, 89, 9, 42, 155, 159, 93,
-	166, 80, 50, 34, 175, 195, 100, 99, 26, 150, 16, 145, 4, 33, 8, 189,
-	121, 64, 77, 72, 208, 245, 130, 122, 143, 55, 105, 134, 29, 164, 185,
-	194,
-	193, 239, 101, 242, 5, 171, 126, 11, 74, 59, 137, 228, 108, 191, 232,
-	139,
-	6, 24, 81, 20, 127, 17, 91, 92, 251, 151, 225, 207, 21, 98, 113, 112,
-	84, 226, 18, 214, 199, 187, 13, 32, 94, 220, 224, 212, 247, 204, 196,
-	43,
-	249, 236, 45, 244, 111, 182, 153, 136, 129, 90, 217, 202, 19, 165, 231,
-	71,
-	230, 142, 96, 227, 62, 179, 246, 114, 162, 53, 160, 215, 205, 180, 47,
-	109,
-	44, 38, 31, 149, 135, 0, 216, 52, 63, 23, 37, 69, 39, 117, 146, 184,
-	163, 200, 222, 235, 248, 243, 219, 10, 152, 131, 123, 229, 203, 76, 120,
-	209
-};
-
-static struct dm_hash_node *_create_node(const char *str, unsigned len)
-{
-	struct dm_hash_node *n = malloc(sizeof(*n) + len);
-
-	if (n) {
-		memcpy(n->key, str, len);
-		n->keylen = len;
-	}
-
-	return n;
-}
-
-static unsigned long _hash(const char *str, unsigned len)
-{
-	unsigned long h = 0, g;
-	unsigned i;
-
-	for (i = 0; i < len; i++) {
-		h <<= 4;
-		h += _nums[(unsigned char) *str++];
-		g = h & ((unsigned long) 0xf << 16u);
-		if (g) {
-			h ^= g >> 16u;
-			h ^= g >> 5u;
-		}
-	}
-
-	return h;
-}
-
-struct dm_hash_table *dm_hash_create(unsigned size_hint)
-{
-	size_t len;
-	unsigned new_size = 16u;
-	struct dm_hash_table *hc = zalloc(sizeof(*hc));
-
-	if (!hc)
-		return_0;
-
-	/* round size hint up to a power of two */
-	while (new_size < size_hint)
-		new_size = new_size << 1;
-
-	hc->num_slots = new_size;
-	len = sizeof(*(hc->slots)) * new_size;
-	if (!(hc->slots = zalloc(len)))
-		goto_bad;
-
-	return hc;
-
-      bad:
-	free(hc->slots);
-	free(hc);
-	return 0;
-}
-
-static void _free_nodes(struct dm_hash_table *t)
-{
-	struct dm_hash_node *c, *n;
-	unsigned i;
-
-	for (i = 0; i < t->num_slots; i++)
-		for (c = t->slots[i]; c; c = n) {
-			n = c->next;
-			free(c);
-		}
-}
-
-void dm_hash_destroy(struct dm_hash_table *t)
-{
-	_free_nodes(t);
-	free(t->slots);
-	free(t);
-}
-
-static struct dm_hash_node **_find(struct dm_hash_table *t, const void *key,
-				   uint32_t len)
-{
-	unsigned h = _hash(key, len) & (t->num_slots - 1);
-	struct dm_hash_node **c;
-
-	for (c = &t->slots[h]; *c; c = &((*c)->next)) {
-		if ((*c)->keylen != len)
-			continue;
-
-		if (!memcmp(key, (*c)->key, len))
-			break;
-	}
-
-	return c;
-}
-
-void *dm_hash_lookup_binary(struct dm_hash_table *t, const void *key,
-			    uint32_t len)
-{
-	struct dm_hash_node **c = _find(t, key, len);
-
-	return *c ? (*c)->data : 0;
-}
-
-int dm_hash_insert_binary(struct dm_hash_table *t, const void *key,
-			  uint32_t len, void *data)
-{
-	struct dm_hash_node **c = _find(t, key, len);
-
-	if (*c)
-		(*c)->data = data;
-	else {
-		struct dm_hash_node *n = _create_node(key, len);
-
-		if (!n)
-			return 0;
-
-		n->data = data;
-		n->next = 0;
-		*c = n;
-		t->num_nodes++;
-	}
-
-	return 1;
-}
-
-void dm_hash_remove_binary(struct dm_hash_table *t, const void *key,
-			uint32_t len)
-{
-	struct dm_hash_node **c = _find(t, key, len);
-
-	if (*c) {
-		struct dm_hash_node *old = *c;
-		*c = (*c)->next;
-		free(old);
-		t->num_nodes--;
-	}
-}
-
-void *dm_hash_lookup(struct dm_hash_table *t, const char *key)
-{
-	return dm_hash_lookup_binary(t, key, strlen(key) + 1);
-}
-
-int dm_hash_insert(struct dm_hash_table *t, const char *key, void *data)
-{
-	return dm_hash_insert_binary(t, key, strlen(key) + 1, data);
-}
-
-void dm_hash_remove(struct dm_hash_table *t, const char *key)
-{
-	dm_hash_remove_binary(t, key, strlen(key) + 1);
-}
-
-static struct dm_hash_node **_find_str_with_val(struct dm_hash_table *t,
-					        const void *key, const void *val,
-					        uint32_t len, uint32_t val_len)
-{
-	struct dm_hash_node **c;
-	unsigned h;
-       
-	h = _hash(key, len) & (t->num_slots - 1);
-
-	for (c = &t->slots[h]; *c; c = &((*c)->next)) {
-		if ((*c)->keylen != len)
-			continue;
-
-		if (!memcmp(key, (*c)->key, len) && (*c)->data) {
-			if (((*c)->data_len == val_len) &&
-			    !memcmp(val, (*c)->data, val_len))
-				return c;
-		}
-	}
-
-	return NULL;
-}
-
-int dm_hash_insert_allow_multiple(struct dm_hash_table *t, const char *key,
-				  const void *val, uint32_t val_len)
-{
-	struct dm_hash_node *n;
-	struct dm_hash_node *first;
-	int len = strlen(key) + 1;
-	unsigned h;
-
-	n = _create_node(key, len);
-	if (!n)
-		return 0;
-
-	n->data = (void *)val;
-	n->data_len = val_len;
-
-	h = _hash(key, len) & (t->num_slots - 1);
-
-	first = t->slots[h];
-
-	if (first)
-		n->next = first;
-	else
-		n->next = 0;
-	t->slots[h] = n;
-
-	t->num_nodes++;
-	return 1;
-}
-
-/*
- * Look through multiple entries with the same key for one that has a
- * matching val and return that.  If none have maching val, return NULL.
- */
-void *dm_hash_lookup_with_val(struct dm_hash_table *t, const char *key,
-			      const void *val, uint32_t val_len)
-{
-	struct dm_hash_node **c;
-
-	c = _find_str_with_val(t, key, val, strlen(key) + 1, val_len);
-
-	return (c && *c) ? (*c)->data : 0;
-}
-
-/*
- * Look through multiple entries with the same key for one that has a
- * matching val and remove that.
- */
-void dm_hash_remove_with_val(struct dm_hash_table *t, const char *key,
-			     const void *val, uint32_t val_len)
-{
-	struct dm_hash_node **c;
-
-	c = _find_str_with_val(t, key, val, strlen(key) + 1, val_len);
-
-	if (c && *c) {
-		struct dm_hash_node *old = *c;
-		*c = (*c)->next;
-		free(old);
-		t->num_nodes--;
-	}
-}
-
-/*
- * Look up the value for a key and count how many
- * entries have the same key.
- *
- * If no entries have key, return NULL and set count to 0.
- *
- * If one entry has the key, the function returns the val,
- * and sets count to 1.
- *
- * If N entries have the key, the function returns the val
- * from the first entry, and sets count to N.
- */
-void *dm_hash_lookup_with_count(struct dm_hash_table *t, const char *key, int *count)
-{
-	struct dm_hash_node **c;
-	struct dm_hash_node **c1 = NULL;
-	uint32_t len = strlen(key) + 1;
-	unsigned h;
-
-	*count = 0;
-
-	h = _hash(key, len) & (t->num_slots - 1);
-
-	for (c = &t->slots[h]; *c; c = &((*c)->next)) {
-		if ((*c)->keylen != len)
-			continue;
-
-		if (!memcmp(key, (*c)->key, len)) {
-			(*count)++;
-			if (!c1)
-				c1 = c;
-		}
-	}
-
-	if (!c1)
-		return NULL;
-	else
-		return *c1 ? (*c1)->data : 0;
-}
-
-unsigned dm_hash_get_num_entries(struct dm_hash_table *t)
-{
-	return t->num_nodes;
-}
-
-void dm_hash_iter(struct dm_hash_table *t, dm_hash_iterate_fn f)
-{
-	struct dm_hash_node *c, *n;
-	unsigned i;
-
-	for (i = 0; i < t->num_slots; i++)
-		for (c = t->slots[i]; c; c = n) {
-			n = c->next;
-			f(c->data);
-		}
-}
-
-void dm_hash_wipe(struct dm_hash_table *t)
-{
-	_free_nodes(t);
-	memset(t->slots, 0, sizeof(struct dm_hash_node *) * t->num_slots);
-	t->num_nodes = 0u;
-}
-
-char *dm_hash_get_key(struct dm_hash_table *t __attribute__((unused)),
-		      struct dm_hash_node *n)
-{
-	return n->key;
-}
-
-void *dm_hash_get_data(struct dm_hash_table *t __attribute__((unused)),
-		       struct dm_hash_node *n)
-{
-	return n->data;
-}
-
-static struct dm_hash_node *_next_slot(struct dm_hash_table *t, unsigned s)
-{
-	struct dm_hash_node *c = NULL;
-	unsigned i;
-
-	for (i = s; i < t->num_slots && !c; i++)
-		c = t->slots[i];
-
-	return c;
-}
-
-struct dm_hash_node *dm_hash_get_first(struct dm_hash_table *t)
-{
-	return _next_slot(t, 0);
-}
-
-struct dm_hash_node *dm_hash_get_next(struct dm_hash_table *t, struct dm_hash_node *n)
-{
-	unsigned h = _hash(n->key, n->keylen) & (t->num_slots - 1);
-
-	return n->next ? n->next : _next_slot(t, h + 1);
-}


