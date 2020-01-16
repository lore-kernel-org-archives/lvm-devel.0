From: Joe Thornber <thornber@sourceware.org>
Date: Thu, 16 Jan 2020 10:34:40 -0500
Subject: stable-2.02 - [radix-tree] Bring radix-tree up to date with the master branch
Message-ID: <27487.120011610343401761@us-mta-281.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e55210302787d063d3037835316ca06d5cd63bd5
Commit:        e55210302787d063d3037835316ca06d5cd63bd5
Parent:        846ae8d49d74ac61c2caed84c9720aedbe9867ae
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Thu Jan 16 14:03:42 2020 +0000
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Thu Jan 16 14:03:42 2020 +0000

[radix-tree] Bring radix-tree up to date with the master branch

---
 Makefile.in                            |   18 +-
 base/data-struct/radix-tree-adaptive.c | 1297 ++++++++++++++++++++++++++++++++
 base/data-struct/radix-tree-simple.c   |  256 +++++++
 base/data-struct/radix-tree.c          |  851 +--------------------
 base/data-struct/radix-tree.h          |    6 +
 make.tmpl.in                           |   12 +-
 test/unit/radix_tree_t.c               |  399 +++++++++-
 7 files changed, 1980 insertions(+), 859 deletions(-)

diff --git a/Makefile.in b/Makefile.in
index 29d5bed3c..3c8f8c8cf 100644
--- a/Makefile.in
+++ b/Makefile.in
@@ -51,18 +51,20 @@ DISTCLEAN_TARGETS += config.cache config.log config.status make.tmpl
 
 include make.tmpl
 
-libdm: include
-libdaemon: include
-lib: libdm libdaemon
-liblvm: lib
-daemons: lib libdaemon tools
-tools: lib libdaemon device-mapper
+include $(top_srcdir)/base/Makefile
+
+libdm: include $(top_builddir)/base/libbase.a
+libdaemon: include $(top_builddir)/base/libbase.a
+lib: libdm libdaemon $(top_builddir)/base/libbase.a
+liblvm: lib $(top_builddir)/base/libbase.a
+daemons: lib libdaemon tools $(top_builddir)/base/libbase.a
+tools: lib libdaemon device-mapper $(top_builddir)/base/libbase.a
 po: tools daemons
 man: tools
 all_man: tools
 scripts: liblvm libdm
-test: tools daemons
-unit-test: lib
+test: tools daemons $(top_builddir)/base/libbase.a
+unit-test: lib $(top_builddir)/base/libbase.a
 run-unit-test: unit-test
 
 lib.device-mapper: include.device-mapper
diff --git a/base/data-struct/radix-tree-adaptive.c b/base/data-struct/radix-tree-adaptive.c
new file mode 100644
index 000000000..b9ba4179f
--- /dev/null
+++ b/base/data-struct/radix-tree-adaptive.c
@@ -0,0 +1,1297 @@
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
+#include "base/memory/container_of.h"
+#include "base/memory/zalloc.h"
+
+#include <assert.h>
+#include <stdlib.h>
+#include <stdio.h>
+#include <string.h>
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
+        uint32_t nr_entries;
+	struct value values[256];
+};
+
+struct radix_tree {
+	unsigned nr_entries;
+	struct value root;
+	radix_value_dtr dtr;
+	void *dtr_context;
+};
+
+//----------------------------------------------------------------
+
+struct radix_tree *radix_tree_create(radix_value_dtr dtr, void *dtr_context)
+{
+	struct radix_tree *rt = malloc(sizeof(*rt));
+
+	if (rt) {
+		rt->nr_entries = 0;
+		rt->root.type = UNSET;
+		rt->dtr = dtr;
+		rt->dtr_context = dtr_context;
+	}
+
+	return rt;
+}
+
+static inline void _dtr(struct radix_tree *rt, union radix_value v)
+{
+	if (rt->dtr)
+        	rt->dtr(rt->dtr_context, v);
+}
+
+// Returns the number of values removed
+static unsigned _free_node(struct radix_tree *rt, struct value v)
+{
+	unsigned i, nr = 0;
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
+        	_dtr(rt, v.value);
+        	nr = 1;
+		break;
+
+	case VALUE_CHAIN:
+		vc = v.value.ptr;
+		_dtr(rt, vc->value);
+		nr = 1 + _free_node(rt, vc->child);
+		free(vc);
+		break;
+
+	case PREFIX_CHAIN:
+		pc = v.value.ptr;
+		nr = _free_node(rt, pc->child);
+		free(pc);
+		break;
+
+	case NODE4:
+		n4 = (struct node4 *) v.value.ptr;
+		for (i = 0; i < n4->nr_entries; i++)
+			nr += _free_node(rt, n4->values[i]);
+		free(n4);
+		break;
+
+	case NODE16:
+		n16 = (struct node16 *) v.value.ptr;
+		for (i = 0; i < n16->nr_entries; i++)
+			nr += _free_node(rt, n16->values[i]);
+		free(n16);
+		break;
+
+	case NODE48:
+		n48 = (struct node48 *) v.value.ptr;
+		for (i = 0; i < n48->nr_entries; i++)
+			nr += _free_node(rt, n48->values[i]);
+		free(n48);
+		break;
+
+	case NODE256:
+		n256 = (struct node256 *) v.value.ptr;
+		for (i = 0; i < 256; i++)
+			nr += _free_node(rt, n256->values[i]);
+		free(n256);
+		break;
+	}
+
+	return nr;
+}
+
+void radix_tree_destroy(struct radix_tree *rt)
+{
+	_free_node(rt, rt->root);
+	free(rt);
+}
+
+unsigned radix_tree_size(struct radix_tree *rt)
+{
+	return rt->nr_entries;
+}
+
+static bool _insert(struct radix_tree *rt, struct value *v, uint8_t *kb, uint8_t *ke, union radix_value rv);
+
+static bool _insert_unset(struct radix_tree *rt, struct value *v, uint8_t *kb, uint8_t *ke, union radix_value rv)
+{
+	unsigned len = ke - kb;
+
+	if (!len) {
+		// value
+		v->type = VALUE;
+		v->value = rv;
+		rt->nr_entries++;
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
+		rt->nr_entries++;
+	}
+
+	return true;
+}
+
+static bool _insert_value(struct radix_tree *rt, struct value *v, uint8_t *kb, uint8_t *ke, union radix_value rv)
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
+		if (!_insert(rt, &vc->child, kb, ke, rv)) {
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
+static bool _insert_value_chain(struct radix_tree *rt, struct value *v, uint8_t *kb, uint8_t *ke, union radix_value rv)
+{
+	struct value_chain *vc = v->value.ptr;
+	return _insert(rt, &vc->child, kb, ke, rv);
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
+static bool _insert_prefix_chain(struct radix_tree *rt, struct value *v, uint8_t *kb, uint8_t *ke, union radix_value rv)
+{
+	struct prefix_chain *pc = v->value.ptr;
+
+	if (!pc->len) {
+		v->type = VALUE;
+		v->value = rv;
+
+	} else if (*kb == pc->prefix[0]) {
+		// There's a common prefix let's split the chain into two and
+		// recurse.
+		struct prefix_chain *pc2;
+		unsigned i, len = min(pc->len, ke - kb);
+
+		for (i = 0; i < len; i++)
+			if (kb[i] != pc->prefix[i])
+				break;
+
+		if (!(pc2 = zalloc(sizeof(*pc2) + pc->len - i)))
+			return false;
+		pc2->len = pc->len - i;
+		memmove(pc2->prefix, pc->prefix + i, pc2->len);
+		pc2->child = pc->child;
+
+		// FIXME: this trashes pc so we can't back out
+		pc->child.type = PREFIX_CHAIN;
+		pc->child.value.ptr = pc2;
+		pc->len = i;
+
+		if (!_insert(rt, &pc->child, kb + i, ke, rv)) {
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
+		n4->keys[0] = pc->prefix[0];
+		if (pc->len == 1) {
+			n4->values[0] = pc->child;
+			free(pc);
+		} else {
+			memmove(pc->prefix, pc->prefix + 1, pc->len - 1);
+			pc->len--;
+			n4->values[0] = *v;
+		}
+
+		n4->keys[1] = *kb;
+		if (!_insert(rt, n4->values + 1, kb + 1, ke, rv)) {
+			free(n4);
+			return false;
+		}
+
+		n4->nr_entries = 2;
+
+		v->type = NODE4;
+		v->value.ptr = n4;
+	}
+
+	return true;
+}
+
+static bool _insert_node4(struct radix_tree *rt, struct value *v, uint8_t *kb, uint8_t *ke, union radix_value rv)
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
+		if (!_insert(rt, n16->values + 4, kb + 1, ke, rv)) {
+			free(n16);
+			return false;
+		}
+		free(n4);
+		v->type = NODE16;
+		v->value.ptr = n16;
+	} else {
+		if (!_insert(rt, n4->values + n4->nr_entries, kb + 1, ke, rv))
+			return false;
+
+		n4->keys[n4->nr_entries] = *kb;
+		n4->nr_entries++;
+	}
+	return true;
+}
+
+static bool _insert_node16(struct radix_tree *rt, struct value *v, uint8_t *kb, uint8_t *ke, union radix_value rv)
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
+		/* coverity[bad_memset] intentional use of '0' */
+		memset(n48->keys, 48, sizeof(n48->keys));
+
+		for (i = 0; i < 16; i++) {
+			n48->keys[n16->keys[i]] = i;
+			n48->values[i] = n16->values[i];
+		}
+
+		n48->keys[*kb] = 16;
+		if (!_insert(rt, n48->values + 16, kb + 1, ke, rv)) {
+			free(n48);
+			return false;
+		}
+
+		free(n16);
+		v->type = NODE48;
+		v->value.ptr = n48;
+	} else {
+		if (!_insert(rt, n16->values + n16->nr_entries, kb + 1, ke, rv))
+			return false;
+		n16->keys[n16->nr_entries] = *kb;
+		n16->nr_entries++;
+	}
+
+	return true;
+}
+
+static bool _insert_node48(struct radix_tree *rt, struct value *v, uint8_t *kb, uint8_t *ke, union radix_value rv)
+{
+	struct node48 *n48 = v->value.ptr;
+	if (n48->nr_entries == 48) {
+		unsigned i;
+		struct node256 *n256 = zalloc(sizeof(*n256));
+		if (!n256)
+			return false;
+
+		n256->nr_entries = 49;
+		for (i = 0; i < 256; i++) {
+			if (n48->keys[i] < 48)
+				n256->values[i] = n48->values[n48->keys[i]];
+		}
+
+		if (!_insert(rt, n256->values + *kb, kb + 1, ke, rv)) {
+			free(n256);
+			return false;
+		}
+
+		free(n48);
+		v->type = NODE256;
+		v->value.ptr = n256;
+
+	} else {
+		if (!_insert(rt, n48->values + n48->nr_entries, kb + 1, ke, rv))
+			return false;
+
+		n48->keys[*kb] = n48->nr_entries;
+		n48->nr_entries++;
+	}
+
+	return true;
+}
+
+static bool _insert_node256(struct radix_tree *rt, struct value *v, uint8_t *kb, uint8_t *ke, union radix_value rv)
+{
+	struct node256 *n256 = v->value.ptr;
+	bool r, was_unset = n256->values[*kb].type == UNSET;
+
+	r = _insert(rt, n256->values + *kb, kb + 1, ke, rv);
+	if (r && was_unset)
+        	n256->nr_entries++;
+
+	return r;
+}
+
+// FIXME: the tree should not be touched if insert fails (eg, OOM)
+static bool _insert(struct radix_tree *rt, struct value *v, uint8_t *kb, uint8_t *ke, union radix_value rv)
+{
+	if (kb == ke) {
+		if (v->type == UNSET) {
+			v->type = VALUE;
+			v->value = rv;
+			rt->nr_entries++;
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
+			rt->nr_entries++;
+		}
+		return true;
+	}
+
+	switch (v->type) {
+	case UNSET:
+		return _insert_unset(rt, v, kb, ke, rv);
+
+	case VALUE:
+		return _insert_value(rt, v, kb, ke, rv);
+
+	case VALUE_CHAIN:
+		return _insert_value_chain(rt, v, kb, ke, rv);
+
+	case PREFIX_CHAIN:
+		return _insert_prefix_chain(rt, v, kb, ke, rv);
+
+	case NODE4:
+		return _insert_node4(rt, v, kb, ke, rv);
+
+	case NODE16:
+		return _insert_node16(rt, v, kb, ke, rv);
+
+	case NODE48:
+		return _insert_node48(rt, v, kb, ke, rv);
+
+	case NODE256:
+		return _insert_node256(rt, v, kb, ke, rv);
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
+		if (n256->values[*kb].type != UNSET)
+			return _lookup_prefix(n256->values + *kb, kb + 1, ke);
+		break;
+	}
+
+	return (struct lookup_result) {.v = v, .kb = kb};
+}
+
+bool radix_tree_insert(struct radix_tree *rt, uint8_t *kb, uint8_t *ke, union radix_value rv)
+{
+	struct lookup_result lr = _lookup_prefix(&rt->root, kb, ke);
+	return _insert(rt, lr.v, lr.kb, ke, rv);
+}
+
+// Note the degrade functions also free the original node.
+static void _degrade_to_n4(struct node16 *n16, struct value *result)
+{
+        struct node4 *n4 = zalloc(sizeof(*n4));
+
+	assert(n4 != NULL);
+
+        n4->nr_entries = n16->nr_entries;
+        memcpy(n4->keys, n16->keys, n16->nr_entries * sizeof(*n4->keys));
+        memcpy(n4->values, n16->values, n16->nr_entries * sizeof(*n4->values));
+        free(n16);
+
+	result->type = NODE4;
+	result->value.ptr = n4;
+}
+
+static void _degrade_to_n16(struct node48 *n48, struct value *result)
+{
+	unsigned i, count = 0;
+        struct node16 *n16 = zalloc(sizeof(*n16));
+
+	assert(n16 != NULL);
+
+        n16->nr_entries = n48->nr_entries;
+        for (i = 0; i < 256; i++) {
+	        if (n48->keys[i] < 48) {
+		        n16->keys[count] = i;
+		        n16->values[count] = n48->values[n48->keys[i]];
+		        count++;
+	        }
+        }
+
+        free(n48);
+
+	result->type = NODE16;
+	result->value.ptr = n16;
+}
+
+static void _degrade_to_n48(struct node256 *n256, struct value *result)
+{
+        unsigned i, count = 0;
+        struct node48 *n48 = zalloc(sizeof(*n48));
+
+	assert(n48 != NULL);
+
+        n48->nr_entries = n256->nr_entries;
+        for (i = 0; i < 256; i++) {
+		if (n256->values[i].type == UNSET)
+			n48->keys[i] = 48;
+
+		else {
+			n48->keys[i] = count;
+			n48->values[count] = n256->values[i];
+			count++;
+		}
+        }
+
+        free(n256);
+
+	result->type = NODE48;
+	result->value.ptr = n48;
+}
+
+// Removes an entry in an array by sliding the values above it down.
+static void _erase_elt(void *array, size_t obj_size, unsigned count, unsigned idx)
+{
+	if (idx == (count - 1))
+		// The simple case
+		return;
+
+	memmove(((uint8_t *) array) + (obj_size * idx),
+                ((uint8_t *) array) + (obj_size * (idx + 1)),
+                obj_size * (count - idx - 1));
+
+	// Zero the now unused last elt (set's v.type to UNSET)
+	memset(((uint8_t *) array) + (count - 1) * obj_size, 0, obj_size);
+}
+
+static bool _remove(struct radix_tree *rt, struct value *root, uint8_t *kb, uint8_t *ke)
+{
+	bool r;
+	unsigned i, j;
+	struct value_chain *vc;
+	struct prefix_chain *pc;
+	struct node4 *n4;
+	struct node16 *n16;
+	struct node48 *n48;
+	struct node256 *n256;
+
+	if (kb == ke) {
+        	if (root->type == VALUE) {
+                	root->type = UNSET;
+                	_dtr(rt, root->value);
+                	return true;
+
+                } else if (root->type == VALUE_CHAIN) {
+			vc = root->value.ptr;
+			_dtr(rt, vc->value);
+			memcpy(root, &vc->child, sizeof(*root));
+			free(vc);
+			return true;
+
+                } else
+			return false;
+	}
+
+	switch (root->type) {
+	case UNSET:
+	case VALUE:
+        	// this is a value for a prefix of the key
+        	return false;
+
+	case VALUE_CHAIN:
+		vc = root->value.ptr;
+		r = _remove(rt, &vc->child, kb, ke);
+		if (r && (vc->child.type == UNSET)) {
+			root->type = VALUE;
+			root->value = vc->value;
+			free(vc);
+		}
+		return r;
+
+	case PREFIX_CHAIN:
+		pc = root->value.ptr;
+		if (ke - kb < pc->len)
+        		return false;
+
+		for (i = 0; i < pc->len; i++)
+			if (kb[i] != pc->prefix[i])
+        			return false;
+
+		r = _remove(rt, &pc->child, kb + pc->len, ke);
+		if (r && pc->child.type == UNSET) {
+			root->type = UNSET;
+			free(pc);
+		}
+		return r;
+
+	case NODE4:
+		n4 = root->value.ptr;
+		for (i = 0; i < n4->nr_entries; i++) {
+			if (n4->keys[i] == *kb) {
+				r = _remove(rt, n4->values + i, kb + 1, ke);
+				if (r && n4->values[i].type == UNSET) {
+        				if (i < n4->nr_entries) {
+	        				_erase_elt(n4->keys, sizeof(*n4->keys), n4->nr_entries, i);
+	        				_erase_elt(n4->values, sizeof(*n4->values), n4->nr_entries, i);
+        				}
+
+        				n4->nr_entries--;
+					if (!n4->nr_entries) {
+						free(n4);
+						root->type = UNSET;
+					}
+				}
+				return r;
+			}
+		}
+		return false;
+
+	case NODE16:
+        	n16 = root->value.ptr;
+		for (i = 0; i < n16->nr_entries; i++) {
+			if (n16->keys[i] == *kb) {
+				r = _remove(rt, n16->values + i, kb + 1, ke);
+				if (r && n16->values[i].type == UNSET) {
+        				if (i < n16->nr_entries) {
+	        				_erase_elt(n16->keys, sizeof(*n16->keys), n16->nr_entries, i);
+	        				_erase_elt(n16->values, sizeof(*n16->values), n16->nr_entries, i);
+        				}
+
+        				n16->nr_entries--;
+					if (n16->nr_entries <= 4) {
+        					_degrade_to_n4(n16, root);
+					}
+				}
+				return r;
+			}
+		}
+		return false;
+
+	case NODE48:
+		n48 = root->value.ptr;
+		i = n48->keys[*kb];
+		if (i < 48) {
+        		r = _remove(rt, n48->values + i, kb + 1, ke);
+        		if (r && n48->values[i].type == UNSET) {
+                		n48->keys[*kb] = 48;
+                		for (j = 0; j < 256; j++)
+	                		if (n48->keys[j] < 48 && n48->keys[j] > i)
+		                		n48->keys[j]--;
+				_erase_elt(n48->values, sizeof(*n48->values), n48->nr_entries, i);
+				n48->nr_entries--;
+				if (n48->nr_entries <= 16)
+        				_degrade_to_n16(n48, root);
+        		}
+        		return r;
+		}
+		return false;
+
+	case NODE256:
+		n256 = root->value.ptr;
+		r = _remove(rt, n256->values + (*kb), kb + 1, ke);
+		if (r && n256->values[*kb].type == UNSET) {
+			n256->nr_entries--;
+			if (n256->nr_entries <= 48)
+        			_degrade_to_n48(n256, root);
+		}
+		return r;
+	}
+
+	return false;
+}
+
+bool radix_tree_remove(struct radix_tree *rt, uint8_t *key_begin, uint8_t *key_end)
+{
+	if (_remove(rt, &rt->root, key_begin, key_end)) {
+        	rt->nr_entries--;
+        	return true;
+	}
+
+	return false;
+}
+
+//----------------------------------------------------------------
+
+static bool _prefix_chain_matches(struct lookup_result *lr, uint8_t *ke)
+{
+        // It's possible the top node is a prefix chain, and
+        // the remaining key matches part of it.
+        if (lr->v->type == PREFIX_CHAIN) {
+                unsigned i, rlen = ke - lr->kb;
+                struct prefix_chain *pc = lr->v->value.ptr;
+                if (rlen < pc->len) {
+                        for (i = 0; i < rlen; i++)
+                                if (pc->prefix[i] != lr->kb[i])
+                                        return false;
+                        return true;
+		}
+        }
+
+        return false;
+}
+
+static bool _remove_subtree(struct radix_tree *rt, struct value *root, uint8_t *kb, uint8_t *ke, unsigned *count)
+{
+	bool r;
+	unsigned i, j, len;
+	struct value_chain *vc;
+	struct prefix_chain *pc;
+	struct node4 *n4;
+	struct node16 *n16;
+	struct node48 *n48;
+	struct node256 *n256;
+
+	if (kb == ke) {
+		*count += _free_node(rt, *root);
+		root->type = UNSET;
+		return true;
+	}
+
+	switch (root->type) {
+	case UNSET:
+	case VALUE:
+		// No entries with the given prefix
+        	return true;
+
+	case VALUE_CHAIN:
+		vc = root->value.ptr;
+		r = _remove_subtree(rt, &vc->child, kb, ke, count);
+		if (r && (vc->child.type == UNSET)) {
+			root->type = VALUE;
+			root->value = vc->value;
+			free(vc);
+		}
+		return r;
+
+	case PREFIX_CHAIN:
+		pc = root->value.ptr;
+		len = min(pc->len, ke - kb);
+		for (i = 0; i < len; i++)
+			if (kb[i] != pc->prefix[i])
+        			return true;
+
+		r = _remove_subtree(rt, &pc->child, len < pc->len ? ke : (kb + pc->len), ke, count);
+		if (r && pc->child.type == UNSET) {
+			root->type = UNSET;
+			free(pc);
+		}
+		return r;
+
+	case NODE4:
+		n4 = root->value.ptr;
+		for (i = 0; i < n4->nr_entries; i++) {
+			if (n4->keys[i] == *kb) {
+				r = _remove_subtree(rt, n4->values + i, kb + 1, ke, count);
+				if (r && n4->values[i].type == UNSET) {
+        				if (i < n4->nr_entries) {
+	        				_erase_elt(n4->keys, sizeof(*n4->keys), n4->nr_entries, i);
+	        				_erase_elt(n4->values, sizeof(*n4->values), n4->nr_entries, i);
+        				}
+
+        				n4->nr_entries--;
+					if (!n4->nr_entries) {
+						free(n4);
+						root->type = UNSET;
+					}
+				}
+				return r;
+			}
+		}
+		return true;
+
+	case NODE16:
+        	n16 = root->value.ptr;
+		for (i = 0; i < n16->nr_entries; i++) {
+			if (n16->keys[i] == *kb) {
+				r = _remove_subtree(rt, n16->values + i, kb + 1, ke, count);
+				if (r && n16->values[i].type == UNSET) {
+        				if (i < n16->nr_entries) {
+	        				_erase_elt(n16->keys, sizeof(*n16->keys), n16->nr_entries, i);
+	        				_erase_elt(n16->values, sizeof(*n16->values), n16->nr_entries, i);
+        				}
+
+        				n16->nr_entries--;
+					if (n16->nr_entries <= 4)
+        					_degrade_to_n4(n16, root);
+				}
+				return r;
+			}
+		}
+		return true;
+
+	case NODE48:
+		n48 = root->value.ptr;
+		i = n48->keys[*kb];
+		if (i < 48) {
+        		r = _remove_subtree(rt, n48->values + i, kb + 1, ke, count);
+        		if (r && n48->values[i].type == UNSET) {
+                		n48->keys[*kb] = 48;
+                		for (j = 0; j < 256; j++)
+	                		if (n48->keys[j] < 48 && n48->keys[j] > i)
+		                		n48->keys[j]--;
+				_erase_elt(n48->values, sizeof(*n48->values), n48->nr_entries, i);
+				n48->nr_entries--;
+				if (n48->nr_entries <= 16)
+        				_degrade_to_n16(n48, root);
+        		}
+        		return r;
+		}
+		return true;
+
+	case NODE256:
+		n256 = root->value.ptr;
+		if (n256->values[*kb].type == UNSET)
+			return true;  // No entries
+
+		r = _remove_subtree(rt, n256->values + (*kb), kb + 1, ke, count);
+		if (r && n256->values[*kb].type == UNSET) {
+			n256->nr_entries--;
+			if (n256->nr_entries <= 48)
+        			_degrade_to_n48(n256, root);
+		}
+		return r;
+	}
+
+	// Shouldn't get here
+	return false;
+}
+
+unsigned radix_tree_remove_prefix(struct radix_tree *rt, uint8_t *kb, uint8_t *ke)
+{
+        unsigned count = 0;
+
+        if (_remove_subtree(rt, &rt->root, kb, ke, &count))
+		rt->nr_entries -= count;
+
+	return count;
+}
+
+//----------------------------------------------------------------
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
+// FIXME: build up the keys too
+static bool _iterate(struct value *v, struct radix_tree_iterator *it)
+{
+	unsigned i;
+	struct value_chain *vc;
+	struct prefix_chain *pc;
+	struct node4 *n4;
+	struct node16 *n16;
+	struct node48 *n48;
+	struct node256 *n256;
+
+	switch (v->type) {
+	case UNSET:
+        	// can't happen
+		break;
+
+	case VALUE:
+        	return it->visit(it, NULL, NULL, v->value);
+
+	case VALUE_CHAIN:
+		vc = v->value.ptr;
+		return it->visit(it, NULL, NULL, vc->value) && _iterate(&vc->child, it);
+
+	case PREFIX_CHAIN:
+		pc = v->value.ptr;
+		return _iterate(&pc->child, it);
+
+	case NODE4:
+		n4 = (struct node4 *) v->value.ptr;
+		for (i = 0; i < n4->nr_entries; i++)
+			if (!_iterate(n4->values + i, it))
+        			return false;
+        	return true;
+
+	case NODE16:
+		n16 = (struct node16 *) v->value.ptr;
+		for (i = 0; i < n16->nr_entries; i++)
+        		if (!_iterate(n16->values + i, it))
+        			return false;
+		return true;
+
+	case NODE48:
+		n48 = (struct node48 *) v->value.ptr;
+		for (i = 0; i < n48->nr_entries; i++)
+        		if (!_iterate(n48->values + i, it))
+        			return false;
+		return true;
+
+	case NODE256:
+		n256 = (struct node256 *) v->value.ptr;
+		for (i = 0; i < 256; i++)
+        		if (n256->values[i].type != UNSET && !_iterate(n256->values + i, it))
+        			return false;
+		return true;
+	}
+
+	// can't get here
+	return false;
+}
+
+void radix_tree_iterate(struct radix_tree *rt, uint8_t *kb, uint8_t *ke,
+                        struct radix_tree_iterator *it)
+{
+	struct lookup_result lr = _lookup_prefix(&rt->root, kb, ke);
+	if (lr.kb == ke || _prefix_chain_matches(&lr, ke))
+        	_iterate(lr.v, it);
+}
+
+//----------------------------------------------------------------
+// Checks:
+// 1) The number of entries matches rt->nr_entries
+// 2) The number of entries is correct in each node
+// 3) prefix chain len > 0
+// 4) all unused values are UNSET
+
+static bool _check_nodes(struct value *v, unsigned *count)
+{
+	uint64_t bits;
+	unsigned i, ncount;
+	struct value_chain *vc;
+	struct prefix_chain *pc;
+	struct node4 *n4;
+	struct node16 *n16;
+	struct node48 *n48;
+	struct node256 *n256;
+
+	switch (v->type) {
+	case UNSET:
+		return true;
+
+	case VALUE:
+		(*count)++;
+		return true;
+
+	case VALUE_CHAIN:
+		(*count)++;
+		vc = v->value.ptr;
+		return _check_nodes(&vc->child, count);
+
+	case PREFIX_CHAIN:
+		pc = v->value.ptr;
+		return _check_nodes(&pc->child, count);
+
+	case NODE4:
+		n4 = v->value.ptr;
+		for (i = 0; i < n4->nr_entries; i++)
+			if (!_check_nodes(n4->values + i, count))
+				return false;
+
+		for (i = n4->nr_entries; i < 4; i++)
+			if (n4->values[i].type != UNSET) {
+				fprintf(stderr, "unused value is not UNSET (n4)\n");
+				return false;
+			}
+
+		return true;
+
+	case NODE16:
+		n16 = v->value.ptr;
+		for (i = 0; i < n16->nr_entries; i++)
+			if (!_check_nodes(n16->values + i, count))
+				return false;
+
+		for (i = n16->nr_entries; i < 16; i++)
+			if (n16->values[i].type != UNSET) {
+				fprintf(stderr, "unused value is not UNSET (n16)\n");
+				return false;
+			}
+
+		return true;
+
+	case NODE48:
+		bits = 0;
+		n48 = v->value.ptr;
+		ncount = 0;
+		for (i = 0; i < 256; i++) {
+			if (n48->keys[i] < 48) {
+				if (n48->keys[i] >= n48->nr_entries) {
+					fprintf(stderr, "referencing value past nr_entries (n48)\n");
+					return false;
+				}
+
+				if (bits & (1ull << n48->keys[i])) {
+					fprintf(stderr, "duplicate entry (n48) %u\n", (unsigned) n48->keys[i]);
+					return false;
+				}
+				bits = bits | (1ull << n48->keys[i]);
+				ncount++;
+
+				if (!_check_nodes(n48->values + n48->keys[i], count))
+					return false;
+			}
+		}
+
+		for (i = 0; i < n48->nr_entries; i++) {
+			if (!(bits & (1ull << i))) {
+				fprintf(stderr, "not all values are referenced (n48)\n");
+				return false;
+			}
+		}
+
+		if (ncount != n48->nr_entries) {
+			fprintf(stderr, "incorrect number of entries in n48, n48->nr_entries = %u, actual = %u\n",
+                                n48->nr_entries, ncount);
+			return false;
+		}
+
+		for (i = 0; i < n48->nr_entries; i++)
+			if (n48->values[i].type == UNSET) {
+				fprintf(stderr, "value in UNSET (n48)\n");
+				return false;
+			}
+
+		for (i = n48->nr_entries; i < 48; i++)
+			if (n48->values[i].type != UNSET) {
+				fprintf(stderr, "unused value is not UNSET (n48)\n");
+				return false;
+			}
+
+		return true;
+
+	case NODE256:
+		n256 = v->value.ptr;
+
+		ncount = 0;
+		for (i = 0; i < 256; i++) {
+			struct value *v2 = n256->values + i;
+
+			if (v2->type == UNSET)
+				continue;
+
+			if (!_check_nodes(v2, count))
+				return false;
+
+			ncount++;
+		}
+
+		if (ncount != n256->nr_entries) {
+			fprintf(stderr, "incorrect number of entries in n256, n256->nr_entries = %u, actual = %u\n",
+                                n256->nr_entries, ncount);
+			return false;
+		}
+
+		return true;
+
+	default:
+		fprintf(stderr, "unknown value type: %u\n", v->type);
+	}
+
+	fprintf(stderr, "shouldn't get here\n");
+	return false;
+}
+
+bool radix_tree_is_well_formed(struct radix_tree *rt)
+{
+	unsigned count = 0;
+
+	if (!_check_nodes(&rt->root, &count))
+		return false;
+
+	if (rt->nr_entries != count) {
+		fprintf(stderr, "incorrect entry count: rt->nr_entries = %u, actual = %u\n",
+                        rt->nr_entries, count);
+		return false;
+	}
+
+	return true;
+}
+
+//----------------------------------------------------------------
+
+static void _dump(FILE *out, struct value v, unsigned indent)
+{
+	unsigned i;
+	struct value_chain *vc;
+	struct prefix_chain *pc;
+	struct node4 *n4;
+	struct node16 *n16;
+	struct node48 *n48;
+	struct node256 *n256;
+
+	if (v.type == UNSET)
+		return;
+
+	for (i = 0; i < 2 * indent; i++)
+		fprintf(out, " ");
+
+	switch (v.type) {
+	case UNSET:
+		// can't happen
+		break;
+
+	case VALUE:
+		fprintf(out, "<val: %llu>\n", (unsigned long long) v.value.n);
+		break;
+
+	case VALUE_CHAIN:
+		vc = v.value.ptr;
+		fprintf(out, "<val_chain: %llu>\n", (unsigned long long) vc->value.n);
+		_dump(out, vc->child, indent + 1);
+		break;
+
+	case PREFIX_CHAIN:
+		pc = v.value.ptr;
+		fprintf(out, "<prefix: ");
+		for (i = 0; i < pc->len; i++)
+			fprintf(out, "%x.", (unsigned) *(pc->prefix + i));
+		fprintf(out, ">\n");
+		_dump(out, pc->child, indent + 1);
+		break;
+
+	case NODE4:
+		n4 = v.value.ptr;
+		fprintf(out, "<n4: ");
+		for (i = 0; i < n4->nr_entries; i++)
+			fprintf(out, "%x ", (unsigned) n4->keys[i]);
+		fprintf(out, ">\n");
+
+		for (i = 0; i < n4->nr_entries; i++)
+			_dump(out, n4->values[i], indent + 1);
+		break;
+
+	case NODE16:
+		n16 = v.value.ptr;
+		fprintf(out, "<n16: ");
+		for (i = 0; i < n16->nr_entries; i++)
+			fprintf(out, "%x ", (unsigned) n16->keys[i]);
+		fprintf(out, ">\n");
+
+		for (i = 0; i < n16->nr_entries; i++)
+			_dump(out, n16->values[i], indent + 1);
+		break;
+
+	case NODE48:
+		n48 = v.value.ptr;
+		fprintf(out, "<n48: ");
+		for (i = 0; i < 256; i++)
+			if (n48->keys[i] < 48)
+				fprintf(out, "%x ", i);
+		fprintf(out, ">\n");
+
+		for (i = 0; i < n48->nr_entries; i++) {
+			assert(n48->values[i].type != UNSET);
+			_dump(out, n48->values[i], indent + 1);
+		}
+		break;
+
+	case NODE256:
+		n256 = v.value.ptr;
+		fprintf(out, "<n256: ");
+		for (i = 0; i < 256; i++)
+			if (n256->values[i].type != UNSET)
+				fprintf(out, "%x ", i);
+		fprintf(out, ">\n");
+
+		for (i = 0; i < 256; i++)
+			if (n256->values[i].type != UNSET)
+				_dump(out, n256->values[i], indent + 1);
+		break;
+	}
+}
+
+void radix_tree_dump(struct radix_tree *rt, FILE *out)
+{
+	_dump(out, rt->root, 0);
+}
+
+//----------------------------------------------------------------
diff --git a/base/data-struct/radix-tree-simple.c b/base/data-struct/radix-tree-simple.c
new file mode 100644
index 000000000..e8a2fddfa
--- /dev/null
+++ b/base/data-struct/radix-tree-simple.c
@@ -0,0 +1,256 @@
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
+#include "base/memory/container_of.h"
+#include "base/memory/zalloc.h"
+
+#include <assert.h>
+#include <stdlib.h>
+#include <stdio.h>
+
+//----------------------------------------------------------------
+// This implementation is based around nested binary trees.  Very
+// simple (and hopefully correct).
+
+struct node {
+	struct node *left;
+	struct node *right;
+
+	uint8_t key;
+	struct node *center;
+
+	bool has_value;
+	union radix_value value;
+};
+
+struct radix_tree {
+	radix_value_dtr dtr;
+	void *dtr_context;
+
+	struct node *root;
+};
+
+struct radix_tree *
+radix_tree_create(radix_value_dtr dtr, void *dtr_context)
+{
+	struct radix_tree *rt = zalloc(sizeof(*rt));
+
+	if (rt) {
+		rt->dtr = dtr;
+		rt->dtr_context = dtr_context;
+	}
+
+	return rt;
+}
+
+// Returns the number of entries in the tree
+static unsigned _destroy_tree(struct node *n, radix_value_dtr dtr, void *context)
+{
+	unsigned r;
+
+	if (!n)
+		return 0;
+
+	r = _destroy_tree(n->left, dtr, context);
+	r += _destroy_tree(n->right, dtr, context);
+	r += _destroy_tree(n->center, dtr, context);
+
+	if (n->has_value) {
+		if (dtr)
+			dtr(context, n->value);
+		r++;
+	}
+
+	free(n);
+
+	return r;
+}
+
+void radix_tree_destroy(struct radix_tree *rt)
+{
+	_destroy_tree(rt->root, rt->dtr, rt->dtr_context);
+	free(rt);
+}
+
+static unsigned _count(struct node *n)
+{
+	unsigned r;
+
+	if (!n)
+		return 0;
+
+	r = _count(n->left);
+	r += _count(n->right);
+	r += _count(n->center);
+
+	if (n->has_value)
+		r++;
+
+	return r;
+}
+
+unsigned radix_tree_size(struct radix_tree *rt)
+{
+	return _count(rt->root);
+}
+
+static struct node **_lookup(struct node **pn, uint8_t *kb, uint8_t *ke)
+{
+	struct node *n = *pn;
+
+	if (!n || (kb == ke))
+		return pn;
+
+	if (*kb < n->key)
+		return _lookup(&n->left, kb, ke);
+
+	else if (*kb > n->key)
+		return _lookup(&n->right, kb, ke);
+
+	else
+		return _lookup(&n->center, kb + 1, ke);
+}
+
+static bool _insert(struct node **pn, uint8_t *kb, uint8_t *ke, union radix_value v)
+{
+	struct node *n = *pn;
+
+	if (!n) {
+		n = zalloc(sizeof(*n));
+		if (!n)
+			return false;
+
+		n->key = *kb;
+		*pn = n;
+	}
+
+	if (kb == ke) {
+		n->has_value = true;
+		n->value = v;
+		return true;
+	}
+
+	if (*kb < n->key)
+		return _insert(&n->left, kb, ke, v);
+
+	else if (*kb > n->key)
+		return _insert(&n->right, kb, ke, v);
+
+	else
+		return _insert(&n->center, kb + 1, ke, v);
+}
+
+bool radix_tree_insert(struct radix_tree *rt, uint8_t *kb, uint8_t *ke, union radix_value v)
+{
+	return _insert(&rt->root, kb, ke, v);
+}
+
+bool radix_tree_remove(struct radix_tree *rt, uint8_t *kb, uint8_t *ke)
+{
+	struct node **pn = _lookup(&rt->root, kb, ke);
+	struct node *n = *pn;
+
+	if (!n || !n->has_value)
+		return false;
+
+	else {
+		if (rt->dtr)
+			rt->dtr(rt->dtr_context, n->value);
+
+		if (n->left || n->center || n->right) {
+			n->has_value = false;
+			return true;
+
+		} else {
+			// FIXME: delete parent if this was the last entry
+			free(n);
+			*pn = NULL;
+		}
+
+		return true;
+	}
+}
+
+unsigned radix_tree_remove_prefix(struct radix_tree *rt, uint8_t *kb, uint8_t *ke)
+{
+	struct node **pn;
+	unsigned count;
+
+	pn = _lookup(&rt->root, kb, ke);
+
+	if (*pn) {
+		count = _destroy_tree(*pn, rt->dtr, rt->dtr_context);
+		*pn = NULL;
+	}
+
+	return count;
+}
+
+bool
+radix_tree_lookup(struct radix_tree *rt, uint8_t *kb, uint8_t *ke, union radix_value *result)
+{
+	struct node **pn = _lookup(&rt->root, kb, ke);
+	struct node *n = *pn;
+
+	if (n && n->has_value) {
+		*result = n->value;
+		return true;
+	} else
+		return false;
+}
+
+static void _iterate(struct node *n, struct radix_tree_iterator *it)
+{
+	if (!n)
+		return;
+
+	_iterate(n->left, it);
+
+	if (n->has_value)
+		// FIXME: fill out the key
+		it->visit(it, NULL, NULL, n->value);
+
+	_iterate(n->center, it);
+	_iterate(n->right, it);
+}
+
+void radix_tree_iterate(struct radix_tree *rt, uint8_t *kb, uint8_t *ke,
+                        struct radix_tree_iterator *it)
+{
+	if (kb == ke)
+		_iterate(rt->root, it);
+
+	else {
+		struct node **pn = _lookup(&rt->root, kb, ke);
+		struct node *n = *pn;
+
+		if (n) {
+			if (n->has_value)
+				it->visit(it, NULL, NULL, n->value);
+			_iterate(n->center, it);
+		}
+	}
+}
+
+bool radix_tree_is_well_formed(struct radix_tree *rt)
+{
+	return true;
+}
+
+void radix_tree_dump(struct radix_tree *rt, FILE *out)
+{
+}
+
+//----------------------------------------------------------------
+
diff --git a/base/data-struct/radix-tree.c b/base/data-struct/radix-tree.c
index 222b35047..52a1a0540 100644
--- a/base/data-struct/radix-tree.c
+++ b/base/data-struct/radix-tree.c
@@ -10,853 +10,12 @@
 // along with this program; if not, write to the Free Software Foundation,
 // Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-#include "radix-tree.h"
-
-#include "base/memory/container_of.h"
-#include "base/memory/zalloc.h"
-
-#include <assert.h>
-#include <stdlib.h>
-#include <stdio.h>
-
 //----------------------------------------------------------------
 
-enum node_type {
-	UNSET = 0,
-	VALUE,
-	VALUE_CHAIN,
-	PREFIX_CHAIN,
-	NODE4,
-	NODE16,
-	NODE48,
-	NODE256
-};
-
-struct value {
-	enum node_type type;
-	union radix_value value;
-};
-
-// This is used for entries that have a key which is a prefix of another key.
-struct value_chain {
-	union radix_value value;
-	struct value child;
-};
-
-struct prefix_chain {
-	struct value child;
-	unsigned len;
-	uint8_t prefix[0];
-};
-
-struct node4 {
-	uint32_t nr_entries;
-	uint8_t keys[4];
-	struct value values[4];
-};
-
-struct node16 {
-	uint32_t nr_entries;
-	uint8_t keys[16];
-	struct value values[16];
-};
-
-struct node48 {
-	uint32_t nr_entries;
-	uint8_t keys[256];
-	struct value values[48];
-};
-
-struct node256 {
-        uint32_t nr_entries;
-	struct value values[256];
-};
-
-struct radix_tree {
-	unsigned nr_entries;
-	struct value root;
-	radix_value_dtr dtr;
-	void *dtr_context;
-};
-
-//----------------------------------------------------------------
-
-struct radix_tree *radix_tree_create(radix_value_dtr dtr, void *dtr_context)
-{
-	struct radix_tree *rt = malloc(sizeof(*rt));
-
-	if (rt) {
-		rt->nr_entries = 0;
-		rt->root.type = UNSET;
-		rt->dtr = dtr;
-		rt->dtr_context = dtr_context;
-	}
-
-	return rt;
-}
-
-static inline void _dtr(struct radix_tree *rt, union radix_value v)
-{
-	if (rt->dtr)
-        	rt->dtr(rt->dtr_context, v);
-}
-
-// Returns the number of values removed
-static unsigned _free_node(struct radix_tree *rt, struct value v)
-{
-	unsigned i, nr = 0;
-	struct value_chain *vc;
-	struct prefix_chain *pc;
-	struct node4 *n4;
-	struct node16 *n16;
-	struct node48 *n48;
-	struct node256 *n256;
-
-	switch (v.type) {
-	case UNSET:
-		break;
-
-	case VALUE:
-        	_dtr(rt, v.value);
-        	nr = 1;
-		break;
-
-	case VALUE_CHAIN:
-		vc = v.value.ptr;
-		_dtr(rt, vc->value);
-		nr = 1 + _free_node(rt, vc->child);
-		free(vc);
-		break;
-
-	case PREFIX_CHAIN:
-		pc = v.value.ptr;
-		nr = _free_node(rt, pc->child);
-		free(pc);
-		break;
-
-	case NODE4:
-		n4 = (struct node4 *) v.value.ptr;
-		for (i = 0; i < n4->nr_entries; i++)
-			nr += _free_node(rt, n4->values[i]);
-		free(n4);
-		break;
-
-	case NODE16:
-		n16 = (struct node16 *) v.value.ptr;
-		for (i = 0; i < n16->nr_entries; i++)
-			nr += _free_node(rt, n16->values[i]);
-		free(n16);
-		break;
-
-	case NODE48:
-		n48 = (struct node48 *) v.value.ptr;
-		for (i = 0; i < n48->nr_entries; i++)
-			nr += _free_node(rt, n48->values[i]);
-		free(n48);
-		break;
-
-	case NODE256:
-		n256 = (struct node256 *) v.value.ptr;
-		for (i = 0; i < 256; i++)
-			nr += _free_node(rt, n256->values[i]);
-		free(n256);
-		break;
-	}
-
-	return nr;
-}
-
-void radix_tree_destroy(struct radix_tree *rt)
-{
-	_free_node(rt, rt->root);
-	free(rt);
-}
-
-unsigned radix_tree_size(struct radix_tree *rt)
-{
-	return rt->nr_entries;
-}
-
-static bool _insert(struct radix_tree *rt, struct value *v, uint8_t *kb, uint8_t *ke, union radix_value rv);
-
-static bool _insert_unset(struct radix_tree *rt, struct value *v, uint8_t *kb, uint8_t *ke, union radix_value rv)
-{
-	unsigned len = ke - kb;
-
-	if (!len) {
-		// value
-		v->type = VALUE;
-		v->value = rv;
-		rt->nr_entries++;
-	} else {
-		// prefix -> value
-		struct prefix_chain *pc = zalloc(sizeof(*pc) + len);
-		if (!pc)
-			return false;
-
-		pc->child.type = VALUE;
-		pc->child.value = rv;
-		pc->len = len;
-		memcpy(pc->prefix, kb, len);
-		v->type = PREFIX_CHAIN;
-		v->value.ptr = pc;
-		rt->nr_entries++;
-	}
-
-	return true;
-}
-
-static bool _insert_value(struct radix_tree *rt, struct value *v, uint8_t *kb, uint8_t *ke, union radix_value rv)
-{
-	unsigned len = ke - kb;
-
-	if (!len)
-		// overwrite
-		v->value = rv;
-
-	else {
-		// value_chain -> value
-		struct value_chain *vc = zalloc(sizeof(*vc));
-		if (!vc)
-			return false;
-
-		vc->value = v->value;
-		if (!_insert(rt, &vc->child, kb, ke, rv)) {
-			free(vc);
-			return false;
-		}
-
-		v->type = VALUE_CHAIN;
-		v->value.ptr = vc;
-	}
-
-	return true;
-}
-
-static bool _insert_value_chain(struct radix_tree *rt, struct value *v, uint8_t *kb, uint8_t *ke, union radix_value rv)
-{
-	struct value_chain *vc = v->value.ptr;
-	return _insert(rt, &vc->child, kb, ke, rv);
-}
-
-static unsigned min(unsigned lhs, unsigned rhs)
-{
-	if (lhs <= rhs)
-		return lhs;
-	else
-		return rhs;
-}
-
-static bool _insert_prefix_chain(struct radix_tree *rt, struct value *v, uint8_t *kb, uint8_t *ke, union radix_value rv)
-{
-	struct prefix_chain *pc = v->value.ptr;
-
-	if (*kb == pc->prefix[0]) {
-		// There's a common prefix let's split the chain into two and
-		// recurse.
-		struct prefix_chain *pc2;
-		unsigned i, len = min(pc->len, ke - kb);
-
-		for (i = 0; i < len; i++)
-			if (kb[i] != pc->prefix[i])
-				break;
-
-		pc2 = zalloc(sizeof(*pc2) + pc->len - i);
-		pc2->len = pc->len - i;
-		memmove(pc2->prefix, pc->prefix + i, pc2->len);
-		pc2->child = pc->child;
-
-		// FIXME: this trashes pc so we can't back out
-		pc->child.type = PREFIX_CHAIN;
-		pc->child.value.ptr = pc2;
-		pc->len = i;
-
-		if (!_insert(rt, &pc->child, kb + i, ke, rv)) {
-			free(pc2);
-			return false;
-		}
-
-	} else {
-		// Stick an n4 in front.
-		struct node4 *n4 = zalloc(sizeof(*n4));
-		if (!n4)
-			return false;
-
-		n4->keys[0] = *kb;
-		if (!_insert(rt, n4->values, kb + 1, ke, rv)) {
-			free(n4);
-			return false;
-		}
-
-		if (pc->len) {
-			n4->keys[1] = pc->prefix[0];
-			if (pc->len == 1) {
-				n4->values[1] = pc->child;
-				free(pc);
-			} else {
-				memmove(pc->prefix, pc->prefix + 1, pc->len - 1);
-				pc->len--;
-				n4->values[1] = *v;
-			}
-			n4->nr_entries = 2;
-		} else
-			n4->nr_entries = 1;
-
-		v->type = NODE4;
-		v->value.ptr = n4;
-	}
-
-	return true;
-}
-
-static bool _insert_node4(struct radix_tree *rt, struct value *v, uint8_t *kb, uint8_t *ke, union radix_value rv)
-{
-	struct node4 *n4 = v->value.ptr;
-	if (n4->nr_entries == 4) {
-		struct node16 *n16 = zalloc(sizeof(*n16));
-		if (!n16)
-			return false;
-
-		n16->nr_entries = 5;
-		memcpy(n16->keys, n4->keys, sizeof(n4->keys));
-		memcpy(n16->values, n4->values, sizeof(n4->values));
-
-		n16->keys[4] = *kb;
-		if (!_insert(rt, n16->values + 4, kb + 1, ke, rv)) {
-			free(n16);
-			return false;
-		}
-		free(n4);
-		v->type = NODE16;
-		v->value.ptr = n16;
-	} else {
-		n4 = v->value.ptr;
-		if (!_insert(rt, n4->values + n4->nr_entries, kb + 1, ke, rv))
-			return false;
-
-		n4->keys[n4->nr_entries] = *kb;
-		n4->nr_entries++;
-	}
-	return true;
-}
-
-static bool _insert_node16(struct radix_tree *rt, struct value *v, uint8_t *kb, uint8_t *ke, union radix_value rv)
-{
-	struct node16 *n16 = v->value.ptr;
-
-	if (n16->nr_entries == 16) {
-		unsigned i;
-		struct node48 *n48 = zalloc(sizeof(*n48));
-
-		if (!n48)
-			return false;
-
-		n48->nr_entries = 17;
-		memset(n48->keys, 48, sizeof(n48->keys));
-
-		for (i = 0; i < 16; i++) {
-			n48->keys[n16->keys[i]] = i;
-			n48->values[i] = n16->values[i];
-		}
-
-		n48->keys[*kb] = 16;
-		if (!_insert(rt, n48->values + 16, kb + 1, ke, rv)) {
-			free(n48);
-			return false;
-		}
-
-		free(n16);
-		v->type = NODE48;
-		v->value.ptr = n48;
-	} else {
-		if (!_insert(rt, n16->values + n16->nr_entries, kb + 1, ke, rv))
-			return false;
-		n16->keys[n16->nr_entries] = *kb;
-		n16->nr_entries++;
-	}
-
-	return true;
-}
-
-static bool _insert_node48(struct radix_tree *rt, struct value *v, uint8_t *kb, uint8_t *ke, union radix_value rv)
-{
-	struct node48 *n48 = v->value.ptr;
-	if (n48->nr_entries == 48) {
-		unsigned i;
-		struct node256 *n256 = zalloc(sizeof(*n256));
-		if (!n256)
-			return false;
-
-		for (i = 0; i < 256; i++) {
-			if (n48->keys[i] >= 48)
-				continue;
-
-			n256->values[i] = n48->values[n48->keys[i]];
-		}
-
-		if (!_insert(rt, n256->values + *kb, kb + 1, ke, rv)) {
-			free(n256);
-			return false;
-		}
-
-		free(n48);
-		v->type = NODE256;
-		v->value.ptr = n256;
-
-	} else {
-		if (!_insert(rt, n48->values + n48->nr_entries, kb + 1, ke, rv))
-			return false;
-
-		n48->keys[*kb] = n48->nr_entries;
-		n48->nr_entries++;
-	}
-
-	return true;
-}
-
-static bool _insert_node256(struct radix_tree *rt, struct value *v, uint8_t *kb, uint8_t *ke, union radix_value rv)
-{
-	struct node256 *n256 = v->value.ptr;
-	bool was_unset = n256->values[*kb].type == UNSET;
-
-	if (!_insert(rt, n256->values + *kb, kb + 1, ke, rv))
-		return false;
-
-	if (was_unset)
-        	n256->nr_entries++;
-
-	return true;
-}
-
-// FIXME: the tree should not be touched if insert fails (eg, OOM)
-static bool _insert(struct radix_tree *rt, struct value *v, uint8_t *kb, uint8_t *ke, union radix_value rv)
-{
-	if (kb == ke) {
-		if (v->type == UNSET) {
-			v->type = VALUE;
-			v->value = rv;
-			rt->nr_entries++;
-
-		} else if (v->type == VALUE) {
-			v->value = rv;
-
-		} else {
-			struct value_chain *vc = zalloc(sizeof(*vc));
-			if (!vc)
-				return false;
-
-			vc->value = rv;
-			vc->child = *v;
-			v->type = VALUE_CHAIN;
-			v->value.ptr = vc;
-			rt->nr_entries++;
-		}
-		return true;
-	}
-
-	switch (v->type) {
-	case UNSET:
-		return _insert_unset(rt, v, kb, ke, rv);
-
-	case VALUE:
-		return _insert_value(rt, v, kb, ke, rv);
-
-	case VALUE_CHAIN:
-		return _insert_value_chain(rt, v, kb, ke, rv);
-
-	case PREFIX_CHAIN:
-		return _insert_prefix_chain(rt, v, kb, ke, rv);
-
-	case NODE4:
-		return _insert_node4(rt, v, kb, ke, rv);
-
-	case NODE16:
-		return _insert_node16(rt, v, kb, ke, rv);
-
-	case NODE48:
-		return _insert_node48(rt, v, kb, ke, rv);
-
-	case NODE256:
-		return _insert_node256(rt, v, kb, ke, rv);
-	}
-
-	// can't get here
-	return false;
-}
-
-struct lookup_result {
-	struct value *v;
-	uint8_t *kb;
-};
-
-static struct lookup_result _lookup_prefix(struct value *v, uint8_t *kb, uint8_t *ke)
-{
-	unsigned i;
-	struct value_chain *vc;
-	struct prefix_chain *pc;
-	struct node4 *n4;
-	struct node16 *n16;
-	struct node48 *n48;
-	struct node256 *n256;
-
-	if (kb == ke)
-		return (struct lookup_result) {.v = v, .kb = kb};
-
-	switch (v->type) {
-	case UNSET:
-	case VALUE:
-		break;
-
-	case VALUE_CHAIN:
-		vc = v->value.ptr;
-		return _lookup_prefix(&vc->child, kb, ke);
-
-	case PREFIX_CHAIN:
-		pc = v->value.ptr;
-		if (ke - kb < pc->len)
-			return (struct lookup_result) {.v = v, .kb = kb};
-
-		for (i = 0; i < pc->len; i++)
-			if (kb[i] != pc->prefix[i])
-				return (struct lookup_result) {.v = v, .kb = kb};
-
-		return _lookup_prefix(&pc->child, kb + pc->len, ke);
-
-	case NODE4:
-		n4 = v->value.ptr;
-		for (i = 0; i < n4->nr_entries; i++)
-			if (n4->keys[i] == *kb)
-				return _lookup_prefix(n4->values + i, kb + 1, ke);
-		break;
-
-	case NODE16:
-		// FIXME: use binary search or simd?
-		n16 = v->value.ptr;
-		for (i = 0; i < n16->nr_entries; i++)
-			if (n16->keys[i] == *kb)
-				return _lookup_prefix(n16->values + i, kb + 1, ke);
-		break;
-
-	case NODE48:
-		n48 = v->value.ptr;
-		i = n48->keys[*kb];
-		if (i < 48)
-			return _lookup_prefix(n48->values + i, kb + 1, ke);
-		break;
-
-	case NODE256:
-		n256 = v->value.ptr;
-		return _lookup_prefix(n256->values + *kb, kb + 1, ke);
-	}
-
-	return (struct lookup_result) {.v = v, .kb = kb};
-}
-
-bool radix_tree_insert(struct radix_tree *rt, uint8_t *kb, uint8_t *ke, union radix_value rv)
-{
-	struct lookup_result lr = _lookup_prefix(&rt->root, kb, ke);
-	return _insert(rt, lr.v, lr.kb, ke, rv);
-}
-
-// Note the degrade functions also free the original node.
-static void _degrade_to_n4(struct node16 *n16, struct value *result)
-{
-        struct node4 *n4 = zalloc(sizeof(*n4));
-
-        n4->nr_entries = n16->nr_entries;
-        memcpy(n4->keys, n16->keys, n16->nr_entries * sizeof(*n4->keys));
-        memcpy(n4->values, n16->values, n16->nr_entries * sizeof(*n4->values));
-        free(n16);
-
-	result->type = NODE4;
-	result->value.ptr = n4;
-}
-
-static void _degrade_to_n16(struct node48 *n48, struct value *result)
-{
-        struct node4 *n16 = zalloc(sizeof(*n16));
-
-        n16->nr_entries = n48->nr_entries;
-        memcpy(n16->keys, n48->keys, n48->nr_entries * sizeof(*n16->keys));
-        memcpy(n16->values, n48->values, n48->nr_entries * sizeof(*n16->values));
-        free(n48);
-
-	result->type = NODE16;
-	result->value.ptr = n16;
-}
-
-static void _degrade_to_n48(struct node256 *n256, struct value *result)
-{
-        unsigned i, count = 0;
-        struct node4 *n48 = zalloc(sizeof(*n48));
-
-        n48->nr_entries = n256->nr_entries;
-        for (i = 0; i < 256; i++) {
-		if (n256->values[i].type == UNSET)
-        		continue;
-
-		n48->keys[count] = i;
-		n48->values[count] = n256->values[i];
-		count++;
-        }
-        free(n256);
-
-	result->type = NODE48;
-	result->value.ptr = n48;
-}
-
-static bool _remove(struct radix_tree *rt, struct value *root, uint8_t *kb, uint8_t *ke)
-{
-	bool r;
-	unsigned i;
-	struct value_chain *vc;
-	struct prefix_chain *pc;
-	struct node4 *n4;
-	struct node16 *n16;
-	struct node48 *n48;
-	struct node256 *n256;
-
-	if (kb == ke) {
-        	if (root->type == VALUE) {
-                	root->type = UNSET;
-                	_dtr(rt, root->value);
-                	return true;
-
-                } else if (root->type == VALUE_CHAIN) {
-			vc = root->value.ptr;
-			_dtr(rt, vc->value);
-			memcpy(root, &vc->child, sizeof(*root));
-			free(vc);
-			return true;
-
-                } else
-			return false;
-	}
-
-	switch (root->type) {
-	case UNSET:
-	case VALUE:
-        	// this is a value for a prefix of the key
-        	return false;
-
-	case VALUE_CHAIN:
-		vc = root->value.ptr;
-		r = _remove(rt, &vc->child, kb, ke);
-		if (r && (vc->child.type == UNSET)) {
-			memcpy(root, &vc->child, sizeof(*root));
-			free(vc);
-		}
-		return r;
-
-	case PREFIX_CHAIN:
-		pc = root->value.ptr;
-		if (ke - kb < pc->len)
-        		return false;
-
-		for (i = 0; i < pc->len; i++)
-			if (kb[i] != pc->prefix[i])
-        			return false;
-
-		return _remove(rt, &pc->child, kb + pc->len, ke);
-
-	case NODE4:
-		n4 = root->value.ptr;
-		for (i = 0; i < n4->nr_entries; i++) {
-			if (n4->keys[i] == *kb) {
-				r = _remove(rt, n4->values + i, kb + 1, ke);
-				if (r && n4->values[i].type == UNSET) {
-        				n4->nr_entries--;
-        				if (i < n4->nr_entries)
-                				// slide the entries down
-        					memmove(n4->keys + i, n4->keys + i + 1,
-                                                       sizeof(*n4->keys) * (n4->nr_entries - i));
-					if (!n4->nr_entries)
-						root->type = UNSET;
-				}
-				return r;
-			}
-		}
-		return false;
-
-	case NODE16:
-        	n16 = root->value.ptr;
-		for (i = 0; i < n16->nr_entries; i++) {
-			if (n16->keys[i] == *kb) {
-				r = _remove(rt, n16->values + i, kb + 1, ke);
-				if (r && n16->values[i].type == UNSET) {
-        				n16->nr_entries--;
-        				if (i < n16->nr_entries)
-                				// slide the entries down
-        					memmove(n16->keys + i, n16->keys + i + 1,
-                                                        sizeof(*n16->keys) * (n16->nr_entries - i));
-					if (n16->nr_entries <= 4)
-        					_degrade_to_n4(n16, root);
-				}
-				return r;
-			}
-		}
-		return false;
-
-	case NODE48:
-		n48 = root->value.ptr;
-		i = n48->keys[*kb];
-		if (i < 48) {
-        		r = _remove(rt, n48->values + i, kb + 1, ke);
-        		if (r && n48->values[i].type == UNSET) {
-                		n48->keys[*kb] = 48;
-				n48->nr_entries--;
-				if (n48->nr_entries <= 16)
-        				_degrade_to_n16(n48, root);
-        		}
-        		return r;
-		}
-		return false;
-
-	case NODE256:
-		n256 = root->value.ptr;
-		r = _remove(rt, n256->values + (*kb), kb + 1, ke);
-		if (r && n256->values[*kb].type == UNSET) {
-			n256->nr_entries--;
-			if (n256->nr_entries <= 48)
-        			_degrade_to_n48(n256, root);
-		}
-		return r;
-	}
-
-	return false;
-}
-
-bool radix_tree_remove(struct radix_tree *rt, uint8_t *key_begin, uint8_t *key_end)
-{
-	if (_remove(rt, &rt->root, key_begin, key_end)) {
-        	rt->nr_entries--;
-        	return true;
-	}
-
-	return false;
-}
-
-static bool _prefix_chain_matches(struct lookup_result *lr, uint8_t *ke)
-{
-        // It's possible the top node is a prefix chain, and
-        // the remaining key matches part of it.
-        if (lr->v->type == PREFIX_CHAIN) {
-                unsigned i, rlen = ke - lr->kb;
-                struct prefix_chain *pc = lr->v->value.ptr;
-                if (rlen < pc->len) {
-                        for (i = 0; i < rlen; i++)
-                                if (pc->prefix[i] != lr->kb[i])
-                                        return false;
-                        return true;
-		}
-        }
-
-        return false;
-}
-
-unsigned radix_tree_remove_prefix(struct radix_tree *rt, uint8_t *kb, uint8_t *ke)
-{
-        unsigned count = 0;
-	struct lookup_result lr = _lookup_prefix(&rt->root, kb, ke);
-	if (lr.kb == ke || _prefix_chain_matches(&lr, ke)) {
-        	count = _free_node(rt, *lr.v);
-        	lr.v->type = UNSET;
-	}
-
-	rt->nr_entries -= count;
-	return count;
-}
-
-bool radix_tree_lookup(struct radix_tree *rt,
-		       uint8_t *kb, uint8_t *ke, union radix_value *result)
-{
-	struct value_chain *vc;
-	struct lookup_result lr = _lookup_prefix(&rt->root, kb, ke);
-	if (lr.kb == ke) {
-		switch (lr.v->type) {
-		case VALUE:
-			*result = lr.v->value;
-			return true;
-
-		case VALUE_CHAIN:
-			vc = lr.v->value.ptr;
-			*result = vc->value;
-			return true;
-
-		default:
-			return false;
-		}
-	}
-
-	return false;
-}
-
-// FIXME: build up the keys too
-static bool _iterate(struct value *v, struct radix_tree_iterator *it)
-{
-	unsigned i;
-	struct value_chain *vc;
-	struct prefix_chain *pc;
-	struct node4 *n4;
-	struct node16 *n16;
-	struct node48 *n48;
-	struct node256 *n256;
-
-	switch (v->type) {
-	case UNSET:
-        	// can't happen
-		break;
-
-	case VALUE:
-        	return it->visit(it, NULL, NULL, v->value);
-
-	case VALUE_CHAIN:
-		vc = v->value.ptr;
-		return it->visit(it, NULL, NULL, vc->value) && _iterate(&vc->child, it);
-
-	case PREFIX_CHAIN:
-		pc = v->value.ptr;
-		return _iterate(&pc->child, it);
-
-	case NODE4:
-		n4 = (struct node4 *) v->value.ptr;
-		for (i = 0; i < n4->nr_entries; i++)
-			if (!_iterate(n4->values + i, it))
-        			return false;
-        	return true;
-
-	case NODE16:
-		n16 = (struct node16 *) v->value.ptr;
-		for (i = 0; i < n16->nr_entries; i++)
-        		if (!_iterate(n16->values + i, it))
-        			return false;
-		return true;
-
-	case NODE48:
-		n48 = (struct node48 *) v->value.ptr;
-		for (i = 0; i < n48->nr_entries; i++)
-        		if (!_iterate(n48->values + i, it))
-        			return false;
-		return true;
-
-	case NODE256:
-		n256 = (struct node256 *) v->value.ptr;
-		for (i = 0; i < 256; i++)
-        		if (n256->values[i].type != UNSET && !_iterate(n256->values + i, it))
-        			return false;
-		return true;
-	}
-
-	// can't get here
-	return false;
-}
-
-void radix_tree_iterate(struct radix_tree *rt, uint8_t *kb, uint8_t *ke,
-                        struct radix_tree_iterator *it)
-{
-	struct lookup_result lr = _lookup_prefix(&rt->root, kb, ke);
-	if (lr.kb == ke || _prefix_chain_matches(&lr, ke))
-        	_iterate(lr.v, it);
-}
+#ifdef SIMPLE_RADIX_TREE
+#include "base/data-struct/radix-tree-simple.c"
+#else
+#include "base/data-struct/radix-tree-adaptive.c"
+#endif
 
 //----------------------------------------------------------------
diff --git a/base/data-struct/radix-tree.h b/base/data-struct/radix-tree.h
index 1b6aee8f0..5d4d04c63 100644
--- a/base/data-struct/radix-tree.h
+++ b/base/data-struct/radix-tree.h
@@ -15,6 +15,7 @@
 
 #include <stdbool.h>
 #include <stdint.h>
+#include <stdio.h>
 
 //----------------------------------------------------------------
 
@@ -53,6 +54,11 @@ struct radix_tree_iterator {
 void radix_tree_iterate(struct radix_tree *rt, uint8_t *kb, uint8_t *ke,
                         struct radix_tree_iterator *it);
 
+// Checks that some constraints on the shape of the tree are
+// being held.  For debug only.
+bool radix_tree_is_well_formed(struct radix_tree *rt);
+void radix_tree_dump(struct radix_tree *rt, FILE *out);
+
 //----------------------------------------------------------------
 
 #endif
diff --git a/make.tmpl.in b/make.tmpl.in
index c8e4f1440..e7780e8d4 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -68,7 +68,15 @@ CLDFLAGS += @CLDFLAGS@
 ELDFLAGS += @ELDFLAGS@
 LDDEPS += @LDDEPS@
 LIB_SUFFIX = @LIB_SUFFIX@
-LVMINTERNAL_LIBS = -llvm-internal $(DMEVENT_LIBS) $(DAEMON_LIBS) $(SYSTEMD_LIBS) $(UDEV_LIBS) $(DL_LIBS) $(BLKID_LIBS)
+LVMINTERNAL_LIBS =\
+	-llvm-internal \
+	$(top_builddir)/base/libbase.a \
+	$(DMEVENT_LIBS) \
+	$(DAEMON_LIBS) \
+	$(SYSTEMD_LIBS) \
+	$(UDEV_LIBS) \
+	$(DL_LIBS) \
+	$(BLKID_LIBS)
 DL_LIBS = @DL_LIBS@
 RT_LIBS = @RT_LIBS@
 M_LIBS = @M_LIBS@
@@ -306,7 +314,7 @@ LIB_VERSION_DM := $(shell $(AWK) -F '.' '{printf "%s.%s",$$1,$$2}' $(top_srcdir)
 
 LIB_VERSION_APP := $(shell $(AWK) -F '[(). ]' '{printf "%s.%s",$$1,$$4}' $(top_srcdir)/VERSION)
 
-INCLUDES += -I$(srcdir) -I$(top_builddir)/include
+INCLUDES += -I$(top_srcdir) -I$(srcdir) -I$(top_builddir)/include
 
 INC_LNS = $(top_builddir)/include/.symlinks_created
 
diff --git a/test/unit/radix_tree_t.c b/test/unit/radix_tree_t.c
index 7266a8a46..54bc40670 100644
--- a/test/unit/radix_tree_t.c
+++ b/test/unit/radix_tree_t.c
@@ -10,11 +10,10 @@
 // along with this program; if not, write to the Free Software Foundation,
 // Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  
+#include "units.h"
 #include "base/data-struct/radix-tree.h"
 #include "base/memory/container_of.h"
 
-#include "units.h"
-
 #include <stdio.h>
 #include <stdlib.h>
 
@@ -44,6 +43,7 @@ static void test_insert_one(void *fixture)
 	unsigned char k = 'a';
 	v.n = 65;
 	T_ASSERT(radix_tree_insert(rt, &k, &k + 1, v));
+	T_ASSERT(radix_tree_is_well_formed(rt));
 	v.n = 0;
 	T_ASSERT(radix_tree_lookup(rt, &k, &k + 1, &v));
 	T_ASSERT_EQUAL(v.n, 65);
@@ -62,6 +62,8 @@ static void test_single_byte_keys(void *fixture)
 		T_ASSERT(radix_tree_insert(rt, &k, &k + 1, v));
 	}
 
+	T_ASSERT(radix_tree_is_well_formed(rt));
+
 	for (i = 0; i < count; i++) {
 		k = i;
 		T_ASSERT(radix_tree_lookup(rt, &k, &k + 1, &v));
@@ -82,12 +84,16 @@ static void test_overwrite_single_byte_keys(void *fixture)
 		T_ASSERT(radix_tree_insert(rt, &k, &k + 1, v));
 	}
 
+	T_ASSERT(radix_tree_is_well_formed(rt));
+
 	for (i = 0; i < count; i++) {
 		k = i;
 		v.n = 1000 + i;
 		T_ASSERT(radix_tree_insert(rt, &k, &k + 1, v));
 	}
 
+	T_ASSERT(radix_tree_is_well_formed(rt));
+
 	for (i = 0; i < count; i++) {
 		k = i;
 		T_ASSERT(radix_tree_lookup(rt, &k, &k + 1, &v));
@@ -109,6 +115,8 @@ static void test_16_bit_keys(void *fixture)
 		T_ASSERT(radix_tree_insert(rt, k, k + sizeof(k), v));
 	}
 
+	T_ASSERT(radix_tree_is_well_formed(rt));
+
 	for (i = 0; i < count; i++) {
 		k[0] = i / 256;
 		k[1] = i % 256;
@@ -127,8 +135,10 @@ static void test_prefix_keys(void *fixture)
 	k[1] = 200;
 	v.n = 1024;
 	T_ASSERT(radix_tree_insert(rt, k, k + 1, v));
+	T_ASSERT(radix_tree_is_well_formed(rt));
 	v.n = 2345;
 	T_ASSERT(radix_tree_insert(rt, k, k + 2, v));
+	T_ASSERT(radix_tree_is_well_formed(rt));
 	T_ASSERT(radix_tree_lookup(rt, k, k + 1, &v));
 	T_ASSERT_EQUAL(v.n, 1024);
 	T_ASSERT(radix_tree_lookup(rt, k, k + 2, &v));
@@ -145,8 +155,10 @@ static void test_prefix_keys_reversed(void *fixture)
 	k[1] = 200;
 	v.n = 1024;
 	T_ASSERT(radix_tree_insert(rt, k, k + 2, v));
+	T_ASSERT(radix_tree_is_well_formed(rt));
 	v.n = 2345;
 	T_ASSERT(radix_tree_insert(rt, k, k + 1, v));
+	T_ASSERT(radix_tree_is_well_formed(rt));
 	T_ASSERT(radix_tree_lookup(rt, k, k + 2, &v));
 	T_ASSERT_EQUAL(v.n, 1024);
 	T_ASSERT(radix_tree_lookup(rt, k, k + 1, &v));
@@ -170,7 +182,10 @@ static void test_sparse_keys(void *fixture)
 		_gen_key(k, k + sizeof(k));
 		v.n = 1234;
 		T_ASSERT(radix_tree_insert(rt, k, k + 32, v));
+		// FIXME: remove
+		//T_ASSERT(radix_tree_is_well_formed(rt));
 	}
+	T_ASSERT(radix_tree_is_well_formed(rt));
 }
 
 static void test_remove_one(void *fixture)
@@ -182,7 +197,9 @@ static void test_remove_one(void *fixture)
 	_gen_key(k, k + sizeof(k));
 	v.n = 1234;
 	T_ASSERT(radix_tree_insert(rt, k, k + sizeof(k), v));
+	T_ASSERT(radix_tree_is_well_formed(rt));
 	T_ASSERT(radix_tree_remove(rt, k, k + sizeof(k)));
+	T_ASSERT(radix_tree_is_well_formed(rt));
 	T_ASSERT(!radix_tree_lookup(rt, k, k + sizeof(k), &v));
 }
 
@@ -199,14 +216,19 @@ static void test_remove_one_byte_keys(void *fixture)
 		T_ASSERT(radix_tree_insert(rt, k, k + 1, v));
 	}
 
+	T_ASSERT(radix_tree_is_well_formed(rt));
 	for (i = 0; i < 256; i++) {
         	k[0] = i;
 		T_ASSERT(radix_tree_remove(rt, k, k + 1));
+		T_ASSERT(radix_tree_is_well_formed(rt));
 
 		for (j = i + 1; j < 256; j++) {
         		k[0] = j;
 			T_ASSERT(radix_tree_lookup(rt, k, k + 1, &v));
-			T_ASSERT_EQUAL(v.n, j + 1000);
+			if (v.n != j + 1000)
+				test_fail("v.n (%u) != j + 1000 (%u)\n",
+                                          (unsigned) v.n,
+                                          (unsigned) j + 1000);
 		}
 	}
 
@@ -216,6 +238,40 @@ static void test_remove_one_byte_keys(void *fixture)
 	}
 }
 
+static void test_remove_one_byte_keys_reversed(void *fixture)
+{
+        struct radix_tree *rt = fixture;
+        unsigned i, j;
+	uint8_t k[1];
+	union radix_value v;
+
+	for (i = 0; i < 256; i++) {
+        	k[0] = i;
+        	v.n = i + 1000;
+		T_ASSERT(radix_tree_insert(rt, k, k + 1, v));
+	}
+
+	T_ASSERT(radix_tree_is_well_formed(rt));
+	for (i = 256; i; i--) {
+        	k[0] = i - 1;
+		T_ASSERT(radix_tree_remove(rt, k, k + 1));
+		T_ASSERT(radix_tree_is_well_formed(rt));
+
+		for (j = 0; j < i - 1; j++) {
+        		k[0] = j;
+			T_ASSERT(radix_tree_lookup(rt, k, k + 1, &v));
+			if (v.n != j + 1000)
+				test_fail("v.n (%u) != j + 1000 (%u)\n",
+                                          (unsigned) v.n,
+                                          (unsigned) j + 1000);
+		}
+	}
+
+	for (i = 0; i < 256; i++) {
+        	k[0] = i;
+		T_ASSERT(!radix_tree_lookup(rt, k, k + 1, &v));
+	}
+}
 static void test_remove_prefix_keys(void *fixture)
 {
 	struct radix_tree *rt = fixture;
@@ -230,8 +286,10 @@ static void test_remove_prefix_keys(void *fixture)
 		T_ASSERT(radix_tree_insert(rt, k, k + i, v));
 	}
 
+	T_ASSERT(radix_tree_is_well_formed(rt));
 	for (i = 0; i < 32; i++) {
         	T_ASSERT(radix_tree_remove(rt, k, k + i));
+		T_ASSERT(radix_tree_is_well_formed(rt));
         	for (j = i + 1; j < 32; j++) {
                 	T_ASSERT(radix_tree_lookup(rt, k, k + j, &v));
                 	T_ASSERT_EQUAL(v.n, j);
@@ -256,8 +314,10 @@ static void test_remove_prefix_keys_reversed(void *fixture)
 		T_ASSERT(radix_tree_insert(rt, k, k + i, v));
 	}
 
+	T_ASSERT(radix_tree_is_well_formed(rt));
 	for (i = 0; i < 32; i++) {
         	T_ASSERT(radix_tree_remove(rt, k, k + (31 - i)));
+		T_ASSERT(radix_tree_is_well_formed(rt));
         	for (j = 0; j < 31 - i; j++) {
                 	T_ASSERT(radix_tree_lookup(rt, k, k + j, &v));
                 	T_ASSERT_EQUAL(v.n, j);
@@ -284,9 +344,12 @@ static void test_remove_prefix(void *fixture)
 		T_ASSERT(radix_tree_insert(rt, k, k + sizeof(k), v));
 	}
 
+	T_ASSERT(radix_tree_is_well_formed(rt));
+
 	// remove keys in a sub range 
 	k[0] = 21;
 	T_ASSERT_EQUAL(radix_tree_remove_prefix(rt, k, k + 1), count);
+	T_ASSERT(radix_tree_is_well_formed(rt));
 }
 
 static void test_remove_prefix_single(void *fixture)
@@ -298,7 +361,9 @@ static void test_remove_prefix_single(void *fixture)
 	_gen_key(k, k + sizeof(k));
 	v.n = 1234;
 	T_ASSERT(radix_tree_insert(rt, k, k + sizeof(k), v));
+	T_ASSERT(radix_tree_is_well_formed(rt));
 	T_ASSERT_EQUAL(radix_tree_remove_prefix(rt, k, k + 2), 1);
+	T_ASSERT(radix_tree_is_well_formed(rt));
 }
 
 static void test_size(void *fixture)
@@ -318,6 +383,7 @@ static void test_size(void *fixture)
 	}
 
 	T_ASSERT_EQUAL(radix_tree_size(rt), 10000 - dup_count);
+	T_ASSERT(radix_tree_is_well_formed(rt));
 }
 
 struct visitor {
@@ -348,6 +414,7 @@ static void test_iterate_all(void *fixture)
 		T_ASSERT(radix_tree_insert(rt, k, k + sizeof(k), v));
 	}
 
+	T_ASSERT(radix_tree_is_well_formed(rt));
 	vt.count = 0;
 	vt.it.visit = _visit;
 	radix_tree_iterate(rt, NULL, NULL, &vt.it);
@@ -371,6 +438,7 @@ static void test_iterate_subset(void *fixture)
 		T_ASSERT(radix_tree_insert(rt, k, k + sizeof(k), v));
 	}
 
+	T_ASSERT(radix_tree_is_well_formed(rt));
 	vt.count = 0;
 	vt.it.visit = _visit;
 	k[0] = 21;
@@ -390,6 +458,7 @@ static void test_iterate_single(void *fixture)
 	v.n = 1234;
 	T_ASSERT(radix_tree_insert(rt, k, k + sizeof(k), v));
 
+	T_ASSERT(radix_tree_is_well_formed(rt));
 	vt.count = 0;
 	vt.it.visit = _visit;
 	radix_tree_iterate(rt, k, k + 3, &vt.it);
@@ -411,6 +480,7 @@ static void test_iterate_vary_middle(void *fixture)
 		T_ASSERT(radix_tree_insert(rt, k, k + sizeof(k), v));
 	}
 
+	T_ASSERT(radix_tree_is_well_formed(rt));
 	vt.it.visit = _visit;
 	for (i = 0; i < 16; i++) {
         	vt.count = 0;
@@ -422,6 +492,323 @@ static void test_iterate_vary_middle(void *fixture)
 
 //----------------------------------------------------------------
 
+#define DTR_COUNT 100
+
+struct counter {
+	unsigned c;
+	uint8_t present[DTR_COUNT];
+};
+
+static void _counting_dtr(void *context, union radix_value v)
+{
+	struct counter *c = context;
+	c->c++;
+	T_ASSERT(v.n < DTR_COUNT);
+	c->present[v.n] = 0;
+}
+
+static void test_remove_calls_dtr(void *fixture)
+{
+	struct counter c;
+	struct radix_tree *rt = radix_tree_create(_counting_dtr, &c);
+	T_ASSERT(rt);
+
+	// Bug hunting, so I need the keys to be deterministic
+	srand(0);
+
+	c.c = 0;
+	memset(c.present, 1, sizeof(c.present));
+
+	{
+		unsigned i;
+		uint8_t keys[DTR_COUNT * 3];
+		union radix_value v;
+
+		// generate and insert a lot of keys
+		for (i = 0; i < DTR_COUNT; i++) {
+			bool found = false;
+			do {
+				v.n = i;
+				uint8_t *k = keys + (i * 3);
+				_gen_key(k, k + 3);
+				if (!radix_tree_lookup(rt, k, k + 3, &v)) {
+					T_ASSERT(radix_tree_insert(rt, k, k + 3, v));
+					found = true;
+				}
+
+			} while (!found);
+		}
+
+		T_ASSERT(radix_tree_is_well_formed(rt));
+		
+		// double check
+		for (i = 0; i < DTR_COUNT; i++) {
+			uint8_t *k = keys + (i * 3);
+			T_ASSERT(radix_tree_lookup(rt, k, k + 3, &v));
+		}
+
+		for (i = 0; i < DTR_COUNT; i++) {
+			uint8_t *k = keys + (i * 3);
+			// FIXME: check the values get passed to the dtr
+			T_ASSERT(radix_tree_remove(rt, k, k + 3));
+		}
+
+		T_ASSERT(c.c == DTR_COUNT);
+		for (i = 0; i < DTR_COUNT; i++)
+			T_ASSERT(!c.present[i]);
+	}
+
+	radix_tree_destroy(rt);
+}
+
+static void test_destroy_calls_dtr(void *fixture)
+{
+	unsigned i;
+	struct counter c;
+	struct radix_tree *rt = radix_tree_create(_counting_dtr, &c);
+	T_ASSERT(rt);
+
+	// Bug hunting, so I need the keys to be deterministic
+	srand(0);
+
+	c.c = 0;
+	memset(c.present, 1, sizeof(c.present));
+
+	{
+		uint8_t keys[DTR_COUNT * 3];
+		union radix_value v;
+
+		// generate and insert a lot of keys
+		for (i = 0; i < DTR_COUNT; i++) {
+			bool found = false;
+			do {
+				v.n = i;
+				uint8_t *k = keys + (i * 3);
+				_gen_key(k, k + 3);
+				if (!radix_tree_lookup(rt, k, k + 3, &v)) {
+					T_ASSERT(radix_tree_insert(rt, k, k + 3, v));
+					found = true;
+				}
+
+			} while (!found);
+		}
+
+		T_ASSERT(radix_tree_is_well_formed(rt));
+	}
+		
+	radix_tree_destroy(rt);
+	T_ASSERT(c.c == DTR_COUNT);
+	for (i = 0; i < DTR_COUNT; i++)
+		T_ASSERT(!c.present[i]);
+}
+
+//----------------------------------------------------------------
+
+static void test_bcache_scenario(void *fixture)
+{
+	struct radix_tree *rt = fixture;
+
+    	unsigned i;
+    	uint8_t k[6];
+	union radix_value v;
+
+    	memset(k, 0, sizeof(k));
+
+    	for (i = 0; i < 3; i++) {
+	    	// it has to be the 4th byte that varies to
+	    	// trigger the bug.
+	    	k[4] = i;
+	    	v.n = i;
+	    	T_ASSERT(radix_tree_insert(rt, k, k + sizeof(k), v));
+    	}
+	T_ASSERT(radix_tree_is_well_formed(rt));
+
+	k[4] = 0;
+    	T_ASSERT(radix_tree_remove(rt, k, k + sizeof(k)));
+	T_ASSERT(radix_tree_is_well_formed(rt));
+
+    	k[4] = i;
+    	v.n = i;
+    	T_ASSERT(radix_tree_insert(rt, k, k + sizeof(k), v));
+	T_ASSERT(radix_tree_is_well_formed(rt));
+}
+
+//----------------------------------------------------------------
+
+static void _bcs2_step1(struct radix_tree *rt)
+{
+	unsigned i;
+	uint8_t k[12];
+	union radix_value v;
+
+	memset(k, 0, sizeof(k));
+	for (i = 0x6; i < 0x69; i++) {
+		k[0] = i;
+		v.n = i;
+		T_ASSERT(radix_tree_insert(rt, k, k + sizeof(k), v));
+	}
+	T_ASSERT(radix_tree_is_well_formed(rt));
+}
+
+static void _bcs2_step2(struct radix_tree *rt)
+{
+	unsigned i;
+	uint8_t k[12];
+
+	memset(k, 0, sizeof(k));
+	for (i = 0x6; i < 0x69; i++) {
+		k[0] = i;
+		radix_tree_remove_prefix(rt, k, k + 4);
+	}
+	T_ASSERT(radix_tree_is_well_formed(rt));
+}
+
+static void test_bcache_scenario2(void *fixture)
+{
+	unsigned i;
+	struct radix_tree *rt = fixture;
+	uint8_t k[12];
+	union radix_value v;
+
+	_bcs2_step1(rt);
+	_bcs2_step2(rt);
+
+	memset(k, 0, sizeof(k));
+        for (i = 0; i < 50; i++) {
+	        k[0] = 0x6;
+	        v.n = 0x6;
+	        T_ASSERT(radix_tree_insert(rt, k, k + sizeof(k), v));
+	        radix_tree_remove_prefix(rt, k, k + 4);
+        }
+        T_ASSERT(radix_tree_is_well_formed(rt));
+
+	_bcs2_step1(rt);
+	_bcs2_step2(rt);
+	_bcs2_step1(rt);
+	_bcs2_step2(rt);
+
+	memset(k, 0, sizeof(k));
+	for(i = 0x6; i < 0x37; i++) {
+		k[0] = i;
+		k[4] = 0xf;
+		k[5] = 0x1;
+		T_ASSERT(radix_tree_insert(rt, k, k + sizeof(k), v));
+		k[4] = 0;
+		k[5] = 0;
+		T_ASSERT(radix_tree_insert(rt, k, k + sizeof(k), v));
+	}
+	T_ASSERT(radix_tree_is_well_formed(rt));
+
+	memset(k, 0, sizeof(k));
+	for (i = 0x38; i < 0x69; i++) {
+		k[0] = i - 0x32;
+		k[4] = 0xf;
+		k[5] = 1;
+		T_ASSERT(radix_tree_remove(rt, k, k + sizeof(k)));
+
+		k[0] = i;
+		T_ASSERT(radix_tree_insert(rt, k, k + sizeof(k), v));
+
+		k[0] = i - 0x32;
+		k[4] = 0;
+		k[5] = 0;
+		T_ASSERT(radix_tree_remove(rt, k, k + sizeof(k)));
+
+		k[0] = i;
+		T_ASSERT(radix_tree_insert(rt, k, k + sizeof(k), v));
+	}
+	T_ASSERT(radix_tree_is_well_formed(rt));
+
+	memset(k, 0, sizeof(k));
+	k[0] = 0x6;
+	radix_tree_remove_prefix(rt, k, k + 4);
+	T_ASSERT(radix_tree_is_well_formed(rt));
+
+	k[0] = 0x38;
+	k[4] = 0xf;
+	k[5] = 0x1;
+	T_ASSERT(radix_tree_remove(rt, k, k + sizeof(k)));
+	T_ASSERT(radix_tree_is_well_formed(rt));
+
+	memset(k, 0, sizeof(k));
+	k[0] = 0x6;
+	T_ASSERT(radix_tree_insert(rt, k, k + sizeof(k), v));
+	T_ASSERT(radix_tree_is_well_formed(rt));
+
+	k[0] = 0x7;
+	radix_tree_remove_prefix(rt, k, k + 4);
+	T_ASSERT(radix_tree_is_well_formed(rt));
+
+	k[0] = 0x38;
+	T_ASSERT(radix_tree_remove(rt, k, k + sizeof(k)));
+	T_ASSERT(radix_tree_is_well_formed(rt));
+
+	k[0] = 7;
+	T_ASSERT(radix_tree_insert(rt, k, k + sizeof(k), v));
+	T_ASSERT(radix_tree_is_well_formed(rt));
+}
+
+//----------------------------------------------------------------
+
+struct key_parts {
+	uint32_t fd;
+	uint64_t b;
+} __attribute__ ((packed));
+
+union key {
+	struct key_parts parts;
+        uint8_t bytes[12];
+};
+
+static void __lookup_matches(struct radix_tree *rt, int fd, uint64_t b, uint64_t expected)
+{
+	union key k;
+	union radix_value v;
+
+	k.parts.fd = fd;
+	k.parts.b = b;
+	T_ASSERT(radix_tree_lookup(rt, k.bytes, k.bytes + sizeof(k.bytes), &v));
+	T_ASSERT(v.n == expected);
+}
+
+static void __lookup_fails(struct radix_tree *rt, int fd, uint64_t b)
+{
+	union key k;
+	union radix_value v;
+
+	k.parts.fd = fd;
+	k.parts.b = b;
+	T_ASSERT(!radix_tree_lookup(rt, k.bytes, k.bytes + sizeof(k.bytes), &v));
+}
+
+static void __insert(struct radix_tree *rt, int fd, uint64_t b, uint64_t n)
+{
+	union key k;
+	union radix_value v;
+
+	k.parts.fd = fd;
+	k.parts.b = b;
+	v.n = n;
+	T_ASSERT(radix_tree_insert(rt, k.bytes, k.bytes + sizeof(k.bytes), v));
+}
+
+static void __invalidate(struct radix_tree *rt, int fd)
+{
+	union key k;
+
+	k.parts.fd = fd;
+	radix_tree_remove_prefix(rt, k.bytes, k.bytes + sizeof(k.parts.fd));
+	radix_tree_is_well_formed(rt);
+}
+
+static void test_bcache_scenario3(void *fixture)
+{
+	struct radix_tree *rt = fixture;
+
+	#include "test/unit/rt_case1.c"
+}
+
+//----------------------------------------------------------------
 #define T(path, desc, fn) register_test(ts, "/base/data-struct/radix-tree/" path, desc, fn)
 
 void radix_tree_tests(struct dm_list *all_tests)
@@ -442,6 +829,7 @@ void radix_tree_tests(struct dm_list *all_tests)
 	T("sparse-keys", "see what the memory usage is for sparsely distributed keys", test_sparse_keys);
 	T("remove-one", "remove one entry", test_remove_one);
 	T("remove-one-byte-keys", "remove many one byte keys", test_remove_one_byte_keys);
+	T("remove-one-byte-keys-reversed", "remove many one byte keys reversed", test_remove_one_byte_keys_reversed);
 	T("remove-prefix-keys", "remove a set of keys that have common prefixes", test_remove_prefix_keys);
 	T("remove-prefix-keys-reversed", "remove a set of keys that have common prefixes (reversed)", test_remove_prefix_keys_reversed);
 	T("remove-prefix", "remove a subrange", test_remove_prefix);
@@ -451,6 +839,11 @@ void radix_tree_tests(struct dm_list *all_tests)
 	T("iterate-subset", "iterate a subset of entries in tree", test_iterate_subset);
 	T("iterate-single", "iterate a subset that contains a single entry", test_iterate_single);
 	T("iterate-vary-middle", "iterate keys that vary in the middle", test_iterate_vary_middle);
+	T("remove-calls-dtr", "remove should call the dtr for the value", test_remove_calls_dtr);
+	T("destroy-calls-dtr", "destroy should call the dtr for all values", test_destroy_calls_dtr);
+	T("bcache-scenario", "A specific series of keys from a bcache scenario", test_bcache_scenario);
+	T("bcache-scenario-2", "A second series of keys from a bcache scenario", test_bcache_scenario2);
+	T("bcache-scenario-3", "A third series of keys from a bcache scenario", test_bcache_scenario3);
 
 	dm_list_add(all_tests, &ts->list);
 }



