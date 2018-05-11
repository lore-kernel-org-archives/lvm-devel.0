From: Joe Thornber <thornber@sourceware.org>
Date: Fri, 11 May 2018 01:15:04 -0400
Subject: master - radix-tree: First drop of radix tree.
Message-ID: <201805110515.w4B5F40X027833@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=576dd1fc41259a9ed3d95b2385305fc035058618
Commit:        576dd1fc41259a9ed3d95b2385305fc035058618
Parent:        3b02b35c3eef04ddc62302328323d7874f6b9daa
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Fri May 11 06:10:01 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Fri May 11 06:10:01 2018 +0100

radix-tree: First drop of radix tree.

An implementation of an adaptive radix tree.  Has the following nice
properties:

  - At least as fast as the hash table
  - Uses less memory
  - You don't need to give an expected size when you create
  - It scales nicely (ie. no large reallocations like the hash table).
  - You can iterate the keys in lexicographical order.

Only insert and lookup are implemented so far.  Plus there's a lot
more performance to come.
---
 base/data-struct/radix-tree.c |  573 +++++++++++++++++++++++++++++++++++++++++
 base/data-struct/radix-tree.h |   43 +++
 base/memory/container_of.h    |   23 ++
 base/memory/zalloc.h          |   31 +++
 test/unit/Makefile.in         |    2 +
 test/unit/radix_tree_t.c      |  194 ++++++++++++++
 test/unit/units.h             |    7 +-
 7 files changed, 871 insertions(+), 2 deletions(-)

diff --git a/base/data-struct/radix-tree.c b/base/data-struct/radix-tree.c
new file mode 100644
index 0000000..f2f53e9
--- /dev/null
+++ b/base/data-struct/radix-tree.c
@@ -0,0 +1,573 @@
+// Copyright (C) 2018 Red Hat, Inc. All rights reserved.
+// 
+// This file is part of LVM2.
+//
+// This copyrighted material is made available to anyone wishing to use,
+// modify, copy, or redistribute it subject to the terms and conditions
+// of the GNU Lesser General Public License v.2.1.
+//
+// You should have received a copy of the GNU Lesser General Public License
+// along with this program; if not, write to the Free Software Foundation,
+// Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+#include "radix-tree.h"
+
+#include "dm-logging.h"
+#include "log.h"
+
+#include "base/memory/container_of.h"
+#include "base/memory/zalloc.h"
+
+#include <assert.h>
+#include <stdlib.h>
+#include <stdio.h>
+
+//----------------------------------------------------------------
+
+enum node_type {
+	UNSET = 0,
+	VALUE,
+	VALUE_CHAIN,
+	PREFIX_CHAIN,
+	NODE4,
+	NODE16,
+	NODE48,
+	NODE256
+};
+
+struct value {
+	enum node_type type;
+	union radix_value value;
+};
+
+// This is used for entries that have a key which is a prefix of another key.
+struct value_chain {
+	union radix_value value;
+	struct value child;
+};
+
+struct prefix_chain {
+	struct value child;
+	unsigned len;
+	uint8_t prefix[0];
+};
+
+struct node4 {
+	uint32_t nr_entries;
+	uint8_t keys[4];
+	struct value values[4];
+};
+
+struct node16 {
+	uint32_t nr_entries;
+	uint8_t keys[16];
+	struct value values[16];
+};
+
+struct node48 {
+	uint32_t nr_entries;
+	uint8_t keys[256];
+	struct value values[48];
+};
+
+struct node256 {
+	struct value values[256];
+};
+
+struct radix_tree {
+	unsigned nr_entries;
+	struct value root;
+};
+
+//----------------------------------------------------------------
+
+struct radix_tree *radix_tree_create(void)
+{
+	struct radix_tree *rt = malloc(sizeof(*rt));
+
+	if (rt) {
+		rt->nr_entries = 0;
+		rt->root.type = UNSET;
+	}
+
+	return rt;
+}
+
+static void _free_node(struct value v, radix_value_dtr dtr, void *context)
+{
+	unsigned i;
+	struct value_chain *vc;
+	struct prefix_chain *pc;
+	struct node4 *n4;
+	struct node16 *n16;
+	struct node48 *n48;
+	struct node256 *n256;
+
+	switch (v.type) {
+	case UNSET:
+		break;
+
+	case VALUE:
+		if (dtr)
+			dtr(context, v.value);
+		break;
+
+	case VALUE_CHAIN:
+		vc = v.value.ptr;
+		if (dtr)
+			dtr(context, vc->value);
+		_free_node(vc->child, dtr, context);
+		free(vc);
+		break;
+
+	case PREFIX_CHAIN:
+		pc = v.value.ptr;
+		_free_node(pc->child, dtr, context);
+		free(pc);
+		break;
+
+	case NODE4:
+		n4 = (struct node4 *) v.value.ptr;
+		for (i = 0; i < n4->nr_entries; i++)
+			_free_node(n4->values[i], dtr, context);
+		free(n4);
+		break;
+
+	case NODE16:
+		n16 = (struct node16 *) v.value.ptr;
+		for (i = 0; i < n16->nr_entries; i++)
+			_free_node(n16->values[i], dtr, context);
+		free(n16);
+		break;
+
+	case NODE48:
+		n48 = (struct node48 *) v.value.ptr;
+		for (i = 0; i < n48->nr_entries; i++)
+			_free_node(n48->values[i], dtr, context);
+		free(n48);
+		break;
+
+	case NODE256:
+		n256 = (struct node256 *) v.value.ptr;
+		for (i = 0; i < 256; i++)
+			_free_node(n256->values[i], dtr, context);
+		free(n256);
+		break;
+	}
+}
+
+void radix_tree_destroy(struct radix_tree *rt, radix_value_dtr dtr, void *context)
+{
+	_free_node(rt->root, dtr, context);
+	free(rt);
+}
+
+static bool _insert(struct value *v, uint8_t *kb, uint8_t *ke, union radix_value rv);
+
+static bool _insert_unset(struct value *v, uint8_t *kb, uint8_t *ke, union radix_value rv)
+{
+	unsigned len = ke - kb;
+
+	if (!len) {
+		// value
+		v->type = VALUE;
+		v->value = rv;
+	} else {
+		// prefix -> value
+		struct prefix_chain *pc = zalloc(sizeof(*pc) + len);
+		if (!pc)
+			return false;
+
+		pc->child.type = VALUE;
+		pc->child.value = rv;
+		pc->len = len;
+		memcpy(pc->prefix, kb, len);
+		v->type = PREFIX_CHAIN;
+		v->value.ptr = pc;
+	}
+
+	return true;
+}
+
+static bool _insert_value(struct value *v, uint8_t *kb, uint8_t *ke, union radix_value rv)
+{
+	unsigned len = ke - kb;
+
+	if (!len)
+		// overwrite
+		v->value = rv;
+
+	else {
+		// value_chain -> value
+		struct value_chain *vc = zalloc(sizeof(*vc));
+		if (!vc)
+			return false;
+
+		vc->value = v->value;
+		if (!_insert(&vc->child, kb, ke, rv)) {
+			free(vc);
+			return false;
+		}
+
+		v->type = VALUE_CHAIN;
+		v->value.ptr = vc;
+	}
+
+	return true;
+}
+
+static bool _insert_value_chain(struct value *v, uint8_t *kb, uint8_t *ke, union radix_value rv)
+{
+	struct value_chain *vc = v->value.ptr;
+	return _insert(&vc->child, kb, ke, rv);
+}
+
+static unsigned min(unsigned lhs, unsigned rhs)
+{
+	if (lhs <= rhs)
+		return lhs;
+	else
+		return rhs;
+}
+
+static bool _insert_prefix_chain(struct value *v, uint8_t *kb, uint8_t *ke, union radix_value rv)
+{
+	struct prefix_chain *pc = v->value.ptr;
+
+	if (*kb == pc->prefix[0]) {
+		// There's a common prefix let's split the chain into two and
+		// recurse.
+		struct prefix_chain *pc2;
+		unsigned i, len = min(pc->len, ke - kb);
+
+		for (i = 0; i < len; i++)
+			if (kb[i] != pc->prefix[i])
+				break;
+
+		pc2 = zalloc(sizeof(*pc2) + pc->len - i);
+		pc2->len = pc->len - i;
+		memmove(pc2->prefix, pc->prefix + i, pc2->len);
+		pc2->child = pc->child;
+
+		// FIXME: this trashes pc so we can't back out
+		pc->child.type = PREFIX_CHAIN;
+		pc->child.value.ptr = pc2;
+		pc->len = i;
+
+		if (!_insert(&pc->child, kb + i, ke, rv)) {
+			free(pc2);
+			return false;
+		}
+
+	} else {
+		// Stick an n4 in front.
+		struct node4 *n4 = zalloc(sizeof(*n4));
+		if (!n4)
+			return false;
+
+		n4->keys[0] = *kb;
+		if (!_insert(n4->values, kb + 1, ke, rv)) {
+			free(n4);
+			return false;
+		}
+
+		if (pc->len) {
+			n4->keys[1] = pc->prefix[0];
+			if (pc->len == 1) {
+				n4->values[1] = pc->child;
+				free(pc);
+			} else {
+				memmove(pc->prefix, pc->prefix + 1, pc->len - 1);
+				pc->len--;
+				n4->values[1] = *v;
+			}
+			n4->nr_entries = 2;
+		} else
+			n4->nr_entries = 1;
+
+		v->type = NODE4;
+		v->value.ptr = n4;
+	}
+
+	return true;
+}
+
+static bool _insert_node4(struct value *v, uint8_t *kb, uint8_t *ke, union radix_value rv)
+{
+	struct node4 *n4 = v->value.ptr;
+	if (n4->nr_entries == 4) {
+		struct node16 *n16 = zalloc(sizeof(*n16));
+		if (!n16)
+			return false;
+
+		n16->nr_entries = 5;
+		memcpy(n16->keys, n4->keys, sizeof(n4->keys));
+		memcpy(n16->values, n4->values, sizeof(n4->values));
+
+		n16->keys[4] = *kb;
+		if (!_insert(n16->values + 4, kb + 1, ke, rv)) {
+			free(n16);
+			return false;
+		}
+		free(n4);
+		v->type = NODE16;
+		v->value.ptr = n16;
+	} else {
+		n4 = v->value.ptr;
+		if (!_insert(n4->values + n4->nr_entries, kb + 1, ke, rv))
+			return false;
+
+		n4->keys[n4->nr_entries] = *kb;
+		n4->nr_entries++;
+	}
+	return true;
+}
+
+static bool _insert_node16(struct value *v, uint8_t *kb, uint8_t *ke, union radix_value rv)
+{
+	struct node16 *n16 = v->value.ptr;
+
+	if (n16->nr_entries == 16) {
+		unsigned i;
+		struct node48 *n48 = zalloc(sizeof(*n48));
+
+		if (!n48)
+			return false;
+
+		n48->nr_entries = 17;
+		memset(n48->keys, 48, sizeof(n48->keys));
+
+		for (i = 0; i < 16; i++) {
+			n48->keys[n16->keys[i]] = i;
+			n48->values[i] = n16->values[i];
+		}
+
+		n48->keys[*kb] = 16;
+		if (!_insert(n48->values + 16, kb + 1, ke, rv)) {
+			free(n48);
+			return false;
+		}
+
+		free(n16);
+		v->type = NODE48;
+		v->value.ptr = n48;
+	} else {
+		if (!_insert(n16->values + n16->nr_entries, kb + 1, ke, rv))
+			return false;
+		n16->keys[n16->nr_entries] = *kb;
+		n16->nr_entries++;
+	}
+
+	return true;
+}
+
+static bool _insert_node48(struct value *v, uint8_t *kb, uint8_t *ke, union radix_value rv)
+{
+	struct node48 *n48 = v->value.ptr;
+	if (n48->nr_entries == 48) {
+		unsigned i;
+		struct node256 *n256 = zalloc(sizeof(*n256));
+		if (!n256)
+			return false;
+
+		for (i = 0; i < 256; i++) {
+			if (n48->keys[i] >= 48)
+				continue;
+
+			n256->values[i] = n48->values[n48->keys[i]];
+		}
+
+		if (!_insert(n256->values + *kb, kb + 1, ke, rv)) {
+			free(n256);
+			return false;
+		}
+
+		free(n48);
+		v->type = NODE256;
+		v->value.ptr = n256;
+
+	} else {
+		if (!_insert(n48->values + n48->nr_entries, kb + 1, ke, rv))
+			return false;
+
+		n48->keys[*kb] = n48->nr_entries;
+		n48->nr_entries++;
+	}
+
+	return true;
+}
+
+static bool _insert_node256(struct value *v, uint8_t *kb, uint8_t *ke, union radix_value rv)
+{
+	struct node256 *n256 = v->value.ptr;
+	if (!_insert(n256->values + *kb, kb + 1, ke, rv)) {
+		n256->values[*kb].type = UNSET;
+		return false;
+	}
+
+	return true;
+}
+
+// FIXME: the tree should not be touched if insert fails (eg, OOM)
+static bool _insert(struct value *v, uint8_t *kb, uint8_t *ke, union radix_value rv)
+{
+	if (kb == ke) {
+		if (v->type == UNSET) {
+			v->type = VALUE;
+			v->value = rv;
+
+		} else if (v->type == VALUE) {
+			v->value = rv;
+
+		} else {
+			struct value_chain *vc = zalloc(sizeof(*vc));
+			if (!vc)
+				return false;
+
+			vc->value = rv;
+			vc->child = *v;
+			v->type = VALUE_CHAIN;
+			v->value.ptr = vc;
+		}
+		return true;
+	}
+
+	switch (v->type) {
+	case UNSET:
+		return _insert_unset(v, kb, ke, rv);
+
+	case VALUE:
+		return _insert_value(v, kb, ke, rv);
+
+	case VALUE_CHAIN:
+		return _insert_value_chain(v, kb, ke, rv);
+
+	case PREFIX_CHAIN:
+		return _insert_prefix_chain(v, kb, ke, rv);
+
+	case NODE4:
+		return _insert_node4(v, kb, ke, rv);
+
+	case NODE16:
+		return _insert_node16(v, kb, ke, rv);
+
+	case NODE48:
+		return _insert_node48(v, kb, ke, rv);
+
+	case NODE256:
+		return _insert_node256(v, kb, ke, rv);
+	}
+
+	// can't get here
+	return false;
+}
+
+struct lookup_result {
+	struct value *v;
+	uint8_t *kb;
+};
+
+static struct lookup_result _lookup_prefix(struct value *v, uint8_t *kb, uint8_t *ke)
+{
+	unsigned i;
+	struct value_chain *vc;
+	struct prefix_chain *pc;
+	struct node4 *n4;
+	struct node16 *n16;
+	struct node48 *n48;
+	struct node256 *n256;
+
+	if (kb == ke)
+		return (struct lookup_result) {.v = v, .kb = kb};
+
+	switch (v->type) {
+	case UNSET:
+	case VALUE:
+		break;
+
+	case VALUE_CHAIN:
+		vc = v->value.ptr;
+		return _lookup_prefix(&vc->child, kb, ke);
+
+	case PREFIX_CHAIN:
+		pc = v->value.ptr;
+		if (ke - kb < pc->len)
+			return (struct lookup_result) {.v = v, .kb = kb};
+
+		for (i = 0; i < pc->len; i++)
+			if (kb[i] != pc->prefix[i])
+				return (struct lookup_result) {.v = v, .kb = kb};
+
+		return _lookup_prefix(&pc->child, kb + pc->len, ke);
+
+	case NODE4:
+		n4 = v->value.ptr;
+		for (i = 0; i < n4->nr_entries; i++)
+			if (n4->keys[i] == *kb)
+				return _lookup_prefix(n4->values + i, kb + 1, ke);
+		break;
+
+	case NODE16:
+		// FIXME: use binary search or simd?
+		n16 = v->value.ptr;
+		for (i = 0; i < n16->nr_entries; i++)
+			if (n16->keys[i] == *kb)
+				return _lookup_prefix(n16->values + i, kb + 1, ke);
+		break;
+
+	case NODE48:
+		n48 = v->value.ptr;
+		i = n48->keys[*kb];
+		if (i < 48)
+			return _lookup_prefix(n48->values + i, kb + 1, ke);
+		break;
+
+	case NODE256:
+		n256 = v->value.ptr;
+		return _lookup_prefix(n256->values + *kb, kb + 1, ke);
+	}
+
+	return (struct lookup_result) {.v = v, .kb = kb};
+}
+
+bool radix_tree_insert(struct radix_tree *rt, uint8_t *kb, uint8_t *ke, union radix_value rv)
+{
+	struct lookup_result lr = _lookup_prefix(&rt->root, kb, ke);
+	if (_insert(lr.v, lr.kb, ke, rv)) {
+		rt->nr_entries++;
+		return true;
+	}
+
+	return false;
+}
+
+void radix_tree_delete(struct radix_tree *rt, uint8_t *key_begin, uint8_t *key_end)
+{
+	assert(0);
+}
+
+bool radix_tree_lookup(struct radix_tree *rt,
+		       uint8_t *kb, uint8_t *ke, union radix_value *result)
+{
+	struct value_chain *vc;
+	struct lookup_result lr = _lookup_prefix(&rt->root, kb, ke);
+	if (lr.kb == ke) {
+		switch (lr.v->type) {
+		case VALUE:
+			*result = lr.v->value;
+			return true;
+
+		case VALUE_CHAIN:
+			vc = lr.v->value.ptr;
+			*result = vc->value;
+			return true;
+
+		default:
+			return false;
+		}
+	}
+
+	return false;
+}
+
+//----------------------------------------------------------------
diff --git a/base/data-struct/radix-tree.h b/base/data-struct/radix-tree.h
new file mode 100644
index 0000000..d84e3c5
--- /dev/null
+++ b/base/data-struct/radix-tree.h
@@ -0,0 +1,43 @@
+// Copyright (C) 2018 Red Hat, Inc. All rights reserved.
+// 
+// This file is part of LVM2.
+//
+// This copyrighted material is made available to anyone wishing to use,
+// modify, copy, or redistribute it subject to the terms and conditions
+// of the GNU Lesser General Public License v.2.1.
+//
+// You should have received a copy of the GNU Lesser General Public License
+// along with this program; if not, write to the Free Software Foundation,
+// Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+ 
+#ifndef BASE_DATA_STRUCT_RADIX_TREE_H
+#define BASE_DATA_STRUCT_RADIX_TREE_H
+
+#include <stdbool.h>
+#include <stdint.h>
+
+//----------------------------------------------------------------
+
+struct radix_tree;
+
+union radix_value {
+	void *ptr;
+	uint64_t n;
+};
+
+struct radix_tree *radix_tree_create(void);
+
+typedef void (*radix_value_dtr)(void *context, union radix_value v);
+
+// dtr may be NULL
+void radix_tree_destroy(struct radix_tree *rt, radix_value_dtr dtr, void *context);
+
+unsigned radix_tree_size(struct radix_tree *rt);
+bool radix_tree_insert(struct radix_tree *rt, uint8_t *kb, uint8_t *ke, union radix_value v);
+void radix_tree_delete(struct radix_tree *rt, uint8_t *kb, uint8_t *ke);
+bool radix_tree_lookup(struct radix_tree *rt,
+		       uint8_t *kb, uint8_t *ke, union radix_value *result);
+
+//----------------------------------------------------------------
+
+#endif
diff --git a/base/memory/container_of.h b/base/memory/container_of.h
new file mode 100644
index 0000000..4e4c662
--- /dev/null
+++ b/base/memory/container_of.h
@@ -0,0 +1,23 @@
+// Copyright (C) 2018 Red Hat, Inc. All rights reserved.
+// 
+// This file is part of LVM2.
+//
+// This copyrighted material is made available to anyone wishing to use,
+// modify, copy, or redistribute it subject to the terms and conditions
+// of the GNU Lesser General Public License v.2.1.
+//
+// You should have received a copy of the GNU Lesser General Public License
+// along with this program; if not, write to the Free Software Foundation,
+// Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+#ifndef BASE_MEMORY_CONTAINER_OF_H
+#define BASE_MEMORY_CONTAINER_OF_H
+
+//----------------------------------------------------------------
+
+#define container_of(v, t, head) \
+    ((t *)((const char *)(v) - (const char *)&((t *) 0)->head))
+
+//----------------------------------------------------------------
+
+#endif
diff --git a/base/memory/zalloc.h b/base/memory/zalloc.h
new file mode 100644
index 0000000..d2ef827
--- /dev/null
+++ b/base/memory/zalloc.h
@@ -0,0 +1,31 @@
+// Copyright (C) 2018 Red Hat, Inc. All rights reserved.
+// 
+// This file is part of LVM2.
+//
+// This copyrighted material is made available to anyone wishing to use,
+// modify, copy, or redistribute it subject to the terms and conditions
+// of the GNU Lesser General Public License v.2.1.
+//
+// You should have received a copy of the GNU Lesser General Public License
+// along with this program; if not, write to the Free Software Foundation,
+// Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+#ifndef BASE_MEMORY_ZALLOC_H
+#define BASE_MEMORY_ZALLOC_H
+
+#include <stdlib.h>
+#include <string.h>
+
+//----------------------------------------------------------------
+
+static inline void *zalloc(size_t len)
+{
+	void *ptr = malloc(len);
+	if (ptr)
+		memset(ptr, 0, len);
+	return ptr;
+}
+
+//----------------------------------------------------------------
+
+#endif
diff --git a/test/unit/Makefile.in b/test/unit/Makefile.in
index 0e1015c..9d18608 100644
--- a/test/unit/Makefile.in
+++ b/test/unit/Makefile.in
@@ -11,6 +11,7 @@
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
 UNIT_SOURCE=\
+	base/data-struct/radix-tree.c \
 	device-mapper/vdo/status.c \
 	\
 	test/unit/bcache_t.c \
@@ -20,6 +21,7 @@ UNIT_SOURCE=\
 	test/unit/dmlist_t.c \
 	test/unit/dmstatus_t.c \
 	test/unit/io_engine_t.c \
+	test/unit/radix_tree_t.c \
 	test/unit/matcher_t.c \
 	test/unit/framework.c \
 	test/unit/percent_t.c \
diff --git a/test/unit/radix_tree_t.c b/test/unit/radix_tree_t.c
new file mode 100644
index 0000000..6a7ecac
--- /dev/null
+++ b/test/unit/radix_tree_t.c
@@ -0,0 +1,194 @@
+// Copyright (C) 2018 Red Hat, Inc. All rights reserved.
+// 
+// This file is part of LVM2.
+//
+// This copyrighted material is made available to anyone wishing to use,
+// modify, copy, or redistribute it subject to the terms and conditions
+// of the GNU Lesser General Public License v.2.1.
+//
+// You should have received a copy of the GNU Lesser General Public License
+// along with this program; if not, write to the Free Software Foundation,
+// Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+ 
+#include "base/data-struct/radix-tree.h"
+
+#include "units.h"
+
+#include <stdio.h>
+#include <stdlib.h>
+
+//----------------------------------------------------------------
+
+static void *rt_init()
+{
+	struct radix_tree *rt = radix_tree_create();
+	T_ASSERT(rt);
+	return rt;
+}
+
+static void rt_exit(void *fixture)
+{
+	radix_tree_destroy(fixture, NULL, NULL);
+}
+
+static void test_create_destroy(void *fixture)
+{
+	T_ASSERT(fixture);
+}
+
+static void test_insert_one(void *fixture)
+{
+	struct radix_tree *rt = fixture;
+	union radix_value v;
+	unsigned char k = 'a';
+	v.n = 65;
+	T_ASSERT(radix_tree_insert(rt, &k, &k + 1, v));
+	v.n = 0;
+	T_ASSERT(radix_tree_lookup(rt, &k, &k + 1, &v));
+	T_ASSERT_EQUAL(v.n, 65);
+}
+
+static void test_single_byte_keys(void *fixture)
+{
+	unsigned i, count = 256;
+	struct radix_tree *rt = fixture;
+	union radix_value v;
+	uint8_t k;
+
+	for (i = 0; i < count; i++) {
+		k = i;
+		v.n = 100 + i;
+		T_ASSERT(radix_tree_insert(rt, &k, &k + 1, v));
+	}
+
+	for (i = 0; i < count; i++) {
+		k = i;
+		T_ASSERT(radix_tree_lookup(rt, &k, &k + 1, &v));
+		T_ASSERT_EQUAL(v.n, 100 + i);
+	}
+}
+
+static void test_overwrite_single_byte_keys(void *fixture)
+{
+	unsigned i, count = 256;
+	struct radix_tree *rt = fixture;
+	union radix_value v;
+	uint8_t k;
+
+	for (i = 0; i < count; i++) {
+		k = i;
+		v.n = 100 + i;
+		T_ASSERT(radix_tree_insert(rt, &k, &k + 1, v));
+	}
+
+	for (i = 0; i < count; i++) {
+		k = i;
+		v.n = 1000 + i;
+		T_ASSERT(radix_tree_insert(rt, &k, &k + 1, v));
+	}
+
+	for (i = 0; i < count; i++) {
+		k = i;
+		T_ASSERT(radix_tree_lookup(rt, &k, &k + 1, &v));
+		T_ASSERT_EQUAL(v.n, 1000 + i);
+	}
+}
+
+static void test_16_bit_keys(void *fixture)
+{
+	unsigned i, count = 1 << 16;
+	struct radix_tree *rt = fixture;
+	union radix_value v;
+	uint8_t k[2];
+
+	for (i = 0; i < count; i++) {
+		k[0] = i / 256;
+		k[1] = i % 256;
+		v.n = 100 + i;
+		T_ASSERT(radix_tree_insert(rt, k, k + sizeof(k), v));
+	}
+
+	for (i = 0; i < count; i++) {
+		k[0] = i / 256;
+		k[1] = i % 256;
+		T_ASSERT(radix_tree_lookup(rt, k, k + sizeof(k), &v));
+		T_ASSERT_EQUAL(v.n, 100 + i);
+	}
+}
+
+static void test_prefix_keys(void *fixture)
+{
+	struct radix_tree *rt = fixture;
+	union radix_value v;
+	uint8_t k[2];
+
+	k[0] = 100;
+	k[1] = 200;
+	v.n = 1024;
+	T_ASSERT(radix_tree_insert(rt, k, k + 1, v));
+	v.n = 2345;
+	T_ASSERT(radix_tree_insert(rt, k, k + 2, v));
+	T_ASSERT(radix_tree_lookup(rt, k, k + 1, &v));
+	T_ASSERT_EQUAL(v.n, 1024);
+	T_ASSERT(radix_tree_lookup(rt, k, k + 2, &v));
+	T_ASSERT_EQUAL(v.n, 2345);
+}
+
+static void test_prefix_keys_reversed(void *fixture)
+{
+	struct radix_tree *rt = fixture;
+	union radix_value v;
+	uint8_t k[2];
+
+	k[0] = 100;
+	k[1] = 200;
+	v.n = 1024;
+	T_ASSERT(radix_tree_insert(rt, k, k + 2, v));
+	v.n = 2345;
+	T_ASSERT(radix_tree_insert(rt, k, k + 1, v));
+	T_ASSERT(radix_tree_lookup(rt, k, k + 2, &v));
+	T_ASSERT_EQUAL(v.n, 1024);
+	T_ASSERT(radix_tree_lookup(rt, k, k + 1, &v));
+	T_ASSERT_EQUAL(v.n, 2345);
+}
+
+static void test_sparse_keys(void *fixture)
+{
+	unsigned i, n;
+	struct radix_tree *rt = fixture;
+	union radix_value v;
+	uint8_t k[32];
+
+	for (n = 0; n < 100000; n++) {
+		for (i = 0; i < 32; i++)
+			k[i] = rand() % 256;
+
+		v.n = 1234;
+		T_ASSERT(radix_tree_insert(rt, k, k + 32, v));
+	}
+}
+
+//----------------------------------------------------------------
+
+#define T(path, desc, fn) register_test(ts, "/base/data-struct/radix-tree/" path, desc, fn)
+
+void radix_tree_tests(struct dm_list *all_tests)
+{
+	struct test_suite *ts = test_suite_create(rt_init, rt_exit);
+	if (!ts) {
+		fprintf(stderr, "out of memory\n");
+		exit(1);
+	}
+
+	T("create-destroy", "create and destroy an empty tree", test_create_destroy);
+	T("insert-one", "insert one trivial trivial key", test_insert_one);
+	T("insert-single-byte-keys", "inserts many single byte keys", test_single_byte_keys);
+	T("overwrite-single-byte-keys", "overwrite many single byte keys", test_overwrite_single_byte_keys);
+	T("insert-16-bit-keys", "insert many 16bit keys", test_16_bit_keys);
+	T("prefix-keys", "prefixes of other keys are valid keys", test_prefix_keys);
+	T("prefix-keys-reversed", "prefixes of other keys are valid keys", test_prefix_keys_reversed);
+	T("sparse-keys", "see what the memory usage is for sparsely distributed keys", test_sparse_keys);
+
+	dm_list_add(all_tests, &ts->list);
+}
+//----------------------------------------------------------------
diff --git a/test/unit/units.h b/test/unit/units.h
index ec0cbbf..d7ac6ad 100644
--- a/test/unit/units.h
+++ b/test/unit/units.h
@@ -27,8 +27,9 @@ void config_tests(struct dm_list *suites);
 void dm_list_tests(struct dm_list *suites);
 void dm_status_tests(struct dm_list *suites);
 void io_engine_tests(struct dm_list *suites);
-void regex_tests(struct dm_list *suites);
 void percent_tests(struct dm_list *suites);
+void radix_tree_tests(struct dm_list *suites);
+void regex_tests(struct dm_list *suites);
 void string_tests(struct dm_list *suites);
 void vdo_tests(struct dm_list *suites);
 
@@ -42,11 +43,13 @@ static inline void register_all_tests(struct dm_list *suites)
 	dm_list_tests(suites);
 	dm_status_tests(suites);
 	io_engine_tests(suites);
-	regex_tests(suites);
 	percent_tests(suites);
+	radix_tree_tests(suites);
+	regex_tests(suites);
 	string_tests(suites);
 	vdo_tests(suites);
 }
 
 //-----------------------------------------------------------------
+
 #endif


