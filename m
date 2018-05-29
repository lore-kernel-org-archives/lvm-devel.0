From: Joe Thornber <thornber@sourceware.org>
Date: Tue, 29 May 2018 13:16:30 -0400
Subject: master - radix-tree: radix_tree_iterate()
Message-ID: <201805291716.w4THGUjL024047@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1924426ad1e8a569c168e3d85c368ed531f382fe
Commit:        1924426ad1e8a569c168e3d85c368ed531f382fe
Parent:        c2a8bbed3bc8c5c4f505a7cecc4db0b94e7243bc
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Tue May 29 17:58:58 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Tue May 29 17:58:58 2018 +0100

radix-tree: radix_tree_iterate()

---
 base/data-struct/radix-tree.c |  142 +++++++++++++++++++++++++++++++----------
 base/data-struct/radix-tree.h |   12 ++++
 test/unit/radix_tree_t.c      |   82 +++++++++++++++++++++++
 3 files changed, 201 insertions(+), 35 deletions(-)

diff --git a/base/data-struct/radix-tree.c b/base/data-struct/radix-tree.c
index 5688dec..8e8ac90 100644
--- a/base/data-struct/radix-tree.c
+++ b/base/data-struct/radix-tree.c
@@ -172,9 +172,14 @@ void radix_tree_destroy(struct radix_tree *rt)
 	free(rt);
 }
 
-static bool _insert(struct value *v, uint8_t *kb, uint8_t *ke, union radix_value rv);
+unsigned radix_tree_size(struct radix_tree *rt)
+{
+	return rt->nr_entries;
+}
 
-static bool _insert_unset(struct value *v, uint8_t *kb, uint8_t *ke, union radix_value rv)
+static bool _insert(struct radix_tree *rt, struct value *v, uint8_t *kb, uint8_t *ke, union radix_value rv);
+
+static bool _insert_unset(struct radix_tree *rt, struct value *v, uint8_t *kb, uint8_t *ke, union radix_value rv)
 {
 	unsigned len = ke - kb;
 
@@ -182,6 +187,7 @@ static bool _insert_unset(struct value *v, uint8_t *kb, uint8_t *ke, union radix
 		// value
 		v->type = VALUE;
 		v->value = rv;
+		rt->nr_entries++;
 	} else {
 		// prefix -> value
 		struct prefix_chain *pc = zalloc(sizeof(*pc) + len);
@@ -194,12 +200,13 @@ static bool _insert_unset(struct value *v, uint8_t *kb, uint8_t *ke, union radix
 		memcpy(pc->prefix, kb, len);
 		v->type = PREFIX_CHAIN;
 		v->value.ptr = pc;
+		rt->nr_entries++;
 	}
 
 	return true;
 }
 
-static bool _insert_value(struct value *v, uint8_t *kb, uint8_t *ke, union radix_value rv)
+static bool _insert_value(struct radix_tree *rt, struct value *v, uint8_t *kb, uint8_t *ke, union radix_value rv)
 {
 	unsigned len = ke - kb;
 
@@ -214,7 +221,7 @@ static bool _insert_value(struct value *v, uint8_t *kb, uint8_t *ke, union radix
 			return false;
 
 		vc->value = v->value;
-		if (!_insert(&vc->child, kb, ke, rv)) {
+		if (!_insert(rt, &vc->child, kb, ke, rv)) {
 			free(vc);
 			return false;
 		}
@@ -226,10 +233,10 @@ static bool _insert_value(struct value *v, uint8_t *kb, uint8_t *ke, union radix
 	return true;
 }
 
-static bool _insert_value_chain(struct value *v, uint8_t *kb, uint8_t *ke, union radix_value rv)
+static bool _insert_value_chain(struct radix_tree *rt, struct value *v, uint8_t *kb, uint8_t *ke, union radix_value rv)
 {
 	struct value_chain *vc = v->value.ptr;
-	return _insert(&vc->child, kb, ke, rv);
+	return _insert(rt, &vc->child, kb, ke, rv);
 }
 
 static unsigned min(unsigned lhs, unsigned rhs)
@@ -240,7 +247,7 @@ static unsigned min(unsigned lhs, unsigned rhs)
 		return rhs;
 }
 
-static bool _insert_prefix_chain(struct value *v, uint8_t *kb, uint8_t *ke, union radix_value rv)
+static bool _insert_prefix_chain(struct radix_tree *rt, struct value *v, uint8_t *kb, uint8_t *ke, union radix_value rv)
 {
 	struct prefix_chain *pc = v->value.ptr;
 
@@ -264,7 +271,7 @@ static bool _insert_prefix_chain(struct value *v, uint8_t *kb, uint8_t *ke, unio
 		pc->child.value.ptr = pc2;
 		pc->len = i;
 
-		if (!_insert(&pc->child, kb + i, ke, rv)) {
+		if (!_insert(rt, &pc->child, kb + i, ke, rv)) {
 			free(pc2);
 			return false;
 		}
@@ -276,7 +283,7 @@ static bool _insert_prefix_chain(struct value *v, uint8_t *kb, uint8_t *ke, unio
 			return false;
 
 		n4->keys[0] = *kb;
-		if (!_insert(n4->values, kb + 1, ke, rv)) {
+		if (!_insert(rt, n4->values, kb + 1, ke, rv)) {
 			free(n4);
 			return false;
 		}
@@ -302,7 +309,7 @@ static bool _insert_prefix_chain(struct value *v, uint8_t *kb, uint8_t *ke, unio
 	return true;
 }
 
-static bool _insert_node4(struct value *v, uint8_t *kb, uint8_t *ke, union radix_value rv)
+static bool _insert_node4(struct radix_tree *rt, struct value *v, uint8_t *kb, uint8_t *ke, union radix_value rv)
 {
 	struct node4 *n4 = v->value.ptr;
 	if (n4->nr_entries == 4) {
@@ -315,7 +322,7 @@ static bool _insert_node4(struct value *v, uint8_t *kb, uint8_t *ke, union radix
 		memcpy(n16->values, n4->values, sizeof(n4->values));
 
 		n16->keys[4] = *kb;
-		if (!_insert(n16->values + 4, kb + 1, ke, rv)) {
+		if (!_insert(rt, n16->values + 4, kb + 1, ke, rv)) {
 			free(n16);
 			return false;
 		}
@@ -324,7 +331,7 @@ static bool _insert_node4(struct value *v, uint8_t *kb, uint8_t *ke, union radix
 		v->value.ptr = n16;
 	} else {
 		n4 = v->value.ptr;
-		if (!_insert(n4->values + n4->nr_entries, kb + 1, ke, rv))
+		if (!_insert(rt, n4->values + n4->nr_entries, kb + 1, ke, rv))
 			return false;
 
 		n4->keys[n4->nr_entries] = *kb;
@@ -333,7 +340,7 @@ static bool _insert_node4(struct value *v, uint8_t *kb, uint8_t *ke, union radix
 	return true;
 }
 
-static bool _insert_node16(struct value *v, uint8_t *kb, uint8_t *ke, union radix_value rv)
+static bool _insert_node16(struct radix_tree *rt, struct value *v, uint8_t *kb, uint8_t *ke, union radix_value rv)
 {
 	struct node16 *n16 = v->value.ptr;
 
@@ -353,7 +360,7 @@ static bool _insert_node16(struct value *v, uint8_t *kb, uint8_t *ke, union radi
 		}
 
 		n48->keys[*kb] = 16;
-		if (!_insert(n48->values + 16, kb + 1, ke, rv)) {
+		if (!_insert(rt, n48->values + 16, kb + 1, ke, rv)) {
 			free(n48);
 			return false;
 		}
@@ -362,7 +369,7 @@ static bool _insert_node16(struct value *v, uint8_t *kb, uint8_t *ke, union radi
 		v->type = NODE48;
 		v->value.ptr = n48;
 	} else {
-		if (!_insert(n16->values + n16->nr_entries, kb + 1, ke, rv))
+		if (!_insert(rt, n16->values + n16->nr_entries, kb + 1, ke, rv))
 			return false;
 		n16->keys[n16->nr_entries] = *kb;
 		n16->nr_entries++;
@@ -371,7 +378,7 @@ static bool _insert_node16(struct value *v, uint8_t *kb, uint8_t *ke, union radi
 	return true;
 }
 
-static bool _insert_node48(struct value *v, uint8_t *kb, uint8_t *ke, union radix_value rv)
+static bool _insert_node48(struct radix_tree *rt, struct value *v, uint8_t *kb, uint8_t *ke, union radix_value rv)
 {
 	struct node48 *n48 = v->value.ptr;
 	if (n48->nr_entries == 48) {
@@ -387,7 +394,7 @@ static bool _insert_node48(struct value *v, uint8_t *kb, uint8_t *ke, union radi
 			n256->values[i] = n48->values[n48->keys[i]];
 		}
 
-		if (!_insert(n256->values + *kb, kb + 1, ke, rv)) {
+		if (!_insert(rt, n256->values + *kb, kb + 1, ke, rv)) {
 			free(n256);
 			return false;
 		}
@@ -397,7 +404,7 @@ static bool _insert_node48(struct value *v, uint8_t *kb, uint8_t *ke, union radi
 		v->value.ptr = n256;
 
 	} else {
-		if (!_insert(n48->values + n48->nr_entries, kb + 1, ke, rv))
+		if (!_insert(rt, n48->values + n48->nr_entries, kb + 1, ke, rv))
 			return false;
 
 		n48->keys[*kb] = n48->nr_entries;
@@ -407,12 +414,12 @@ static bool _insert_node48(struct value *v, uint8_t *kb, uint8_t *ke, union radi
 	return true;
 }
 
-static bool _insert_node256(struct value *v, uint8_t *kb, uint8_t *ke, union radix_value rv)
+static bool _insert_node256(struct radix_tree *rt, struct value *v, uint8_t *kb, uint8_t *ke, union radix_value rv)
 {
 	struct node256 *n256 = v->value.ptr;
 	bool was_unset = n256->values[*kb].type == UNSET;
 
-	if (!_insert(n256->values + *kb, kb + 1, ke, rv))
+	if (!_insert(rt, n256->values + *kb, kb + 1, ke, rv))
 		return false;
 
 	if (was_unset)
@@ -422,12 +429,13 @@ static bool _insert_node256(struct value *v, uint8_t *kb, uint8_t *ke, union rad
 }
 
 // FIXME: the tree should not be touched if insert fails (eg, OOM)
-static bool _insert(struct value *v, uint8_t *kb, uint8_t *ke, union radix_value rv)
+static bool _insert(struct radix_tree *rt, struct value *v, uint8_t *kb, uint8_t *ke, union radix_value rv)
 {
 	if (kb == ke) {
 		if (v->type == UNSET) {
 			v->type = VALUE;
 			v->value = rv;
+			rt->nr_entries++;
 
 		} else if (v->type == VALUE) {
 			v->value = rv;
@@ -441,34 +449,35 @@ static bool _insert(struct value *v, uint8_t *kb, uint8_t *ke, union radix_value
 			vc->child = *v;
 			v->type = VALUE_CHAIN;
 			v->value.ptr = vc;
+			rt->nr_entries++;
 		}
 		return true;
 	}
 
 	switch (v->type) {
 	case UNSET:
-		return _insert_unset(v, kb, ke, rv);
+		return _insert_unset(rt, v, kb, ke, rv);
 
 	case VALUE:
-		return _insert_value(v, kb, ke, rv);
+		return _insert_value(rt, v, kb, ke, rv);
 
 	case VALUE_CHAIN:
-		return _insert_value_chain(v, kb, ke, rv);
+		return _insert_value_chain(rt, v, kb, ke, rv);
 
 	case PREFIX_CHAIN:
-		return _insert_prefix_chain(v, kb, ke, rv);
+		return _insert_prefix_chain(rt, v, kb, ke, rv);
 
 	case NODE4:
-		return _insert_node4(v, kb, ke, rv);
+		return _insert_node4(rt, v, kb, ke, rv);
 
 	case NODE16:
-		return _insert_node16(v, kb, ke, rv);
+		return _insert_node16(rt, v, kb, ke, rv);
 
 	case NODE48:
-		return _insert_node48(v, kb, ke, rv);
+		return _insert_node48(rt, v, kb, ke, rv);
 
 	case NODE256:
-		return _insert_node256(v, kb, ke, rv);
+		return _insert_node256(rt, v, kb, ke, rv);
 	}
 
 	// can't get here
@@ -546,12 +555,7 @@ static struct lookup_result _lookup_prefix(struct value *v, uint8_t *kb, uint8_t
 bool radix_tree_insert(struct radix_tree *rt, uint8_t *kb, uint8_t *ke, union radix_value rv)
 {
 	struct lookup_result lr = _lookup_prefix(&rt->root, kb, ke);
-	if (_insert(lr.v, lr.kb, ke, rv)) {
-		rt->nr_entries++;
-		return true;
-	}
-
-	return false;
+	return _insert(rt, lr.v, lr.kb, ke, rv);
 }
 
 // Note the degrade functions also free the original node.
@@ -769,4 +773,72 @@ bool radix_tree_lookup(struct radix_tree *rt,
 	return false;
 }
 
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
+	if (lr.kb == ke)
+        	_iterate(lr.v, it);
+}
+
 //----------------------------------------------------------------
diff --git a/base/data-struct/radix-tree.h b/base/data-struct/radix-tree.h
index ad8a952..1b6aee8 100644
--- a/base/data-struct/radix-tree.h
+++ b/base/data-struct/radix-tree.h
@@ -41,6 +41,18 @@ unsigned radix_tree_remove_prefix(struct radix_tree *rt, uint8_t *prefix_b, uint
 bool radix_tree_lookup(struct radix_tree *rt,
 		       uint8_t *kb, uint8_t *ke, union radix_value *result);
 
+// The radix tree stores entries in lexicographical order.  Which means
+// we can iterate entries, in order.  Or iterate entries with a particular
+// prefix.
+struct radix_tree_iterator {
+        // Returns false if the iteration should end.
+	bool (*visit)(struct radix_tree_iterator *it,
+                      uint8_t *kb, uint8_t *ke, union radix_value v);
+};
+
+void radix_tree_iterate(struct radix_tree *rt, uint8_t *kb, uint8_t *ke,
+                        struct radix_tree_iterator *it);
+
 //----------------------------------------------------------------
 
 #endif
diff --git a/test/unit/radix_tree_t.c b/test/unit/radix_tree_t.c
index eb35773..ba0d5e1 100644
--- a/test/unit/radix_tree_t.c
+++ b/test/unit/radix_tree_t.c
@@ -11,6 +11,7 @@
 // Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  
 #include "base/data-struct/radix-tree.h"
+#include "base/memory/container_of.h"
 
 #include "units.h"
 
@@ -288,6 +289,84 @@ static void test_remove_prefix(void *fixture)
 	T_ASSERT_EQUAL(radix_tree_remove_prefix(rt, k, k + 1), count);
 }
 
+static void test_size(void *fixture)
+{
+	struct radix_tree *rt = fixture;
+	unsigned i, dup_count = 0;
+	uint8_t k[2];
+	union radix_value v;
+
+	// populate some random 16bit keys
+	for (i = 0; i < 10000; i++) {
+        	_gen_key(k, k + sizeof(k));
+        	if (radix_tree_lookup(rt, k, k + sizeof(k), &v))
+                	dup_count++;
+		v.n = i;
+		T_ASSERT(radix_tree_insert(rt, k, k + sizeof(k), v));
+	}
+
+	T_ASSERT_EQUAL(radix_tree_size(rt), 10000 - dup_count);
+}
+
+struct visitor {
+	struct radix_tree_iterator it;
+	unsigned count;
+};
+
+static bool _visit(struct radix_tree_iterator *it,
+                   uint8_t *kb, uint8_t *ke, union radix_value v)
+{
+	struct visitor *vt = container_of(it, struct visitor, it);
+	vt->count++;
+	return true;
+}
+
+static void test_iterate_all(void *fixture)
+{
+	struct radix_tree *rt = fixture;
+	unsigned i;
+	uint8_t k[4];
+	union radix_value v;
+	struct visitor vt;
+
+	// populate some random 32bit keys
+	for (i = 0; i < 100000; i++) {
+        	_gen_key(k, k + sizeof(k));
+		v.n = i;
+		T_ASSERT(radix_tree_insert(rt, k, k + sizeof(k), v));
+	}
+
+	vt.count = 0;
+	vt.it.visit = _visit;
+	radix_tree_iterate(rt, NULL, NULL, &vt.it);
+	T_ASSERT_EQUAL(vt.count, radix_tree_size(rt));
+}
+
+static void test_iterate_subset(void *fixture)
+{
+	struct radix_tree *rt = fixture;
+	unsigned i, subset_count = 0;
+	uint8_t k[3];
+	union radix_value v;
+	struct visitor vt;
+
+	// populate some random 32bit keys
+	for (i = 0; i < 100000; i++) {
+        	_gen_key(k, k + sizeof(k));
+        	if (k[0] == 21 && k[1] == 12)
+                	subset_count++;
+		v.n = i;
+		T_ASSERT(radix_tree_insert(rt, k, k + sizeof(k), v));
+	}
+
+	vt.count = 0;
+	vt.it.visit = _visit;
+	k[0] = 21;
+	k[1] = 12;
+	radix_tree_iterate(rt, k, k + 2, &vt.it);
+	T_ASSERT_EQUAL(vt.count, subset_count);
+}
+
 //----------------------------------------------------------------
 
 #define T(path, desc, fn) register_test(ts, "/base/data-struct/radix-tree/" path, desc, fn)
@@ -313,6 +392,9 @@ void radix_tree_tests(struct dm_list *all_tests)
 	T("remove-prefix-keys", "remove a set of keys that have common prefixes", test_remove_prefix_keys);
 	T("remove-prefix-keys-reversed", "remove a set of keys that have common prefixes (reversed)", test_remove_prefix_keys_reversed);
 	T("remove-prefix", "remove a subrange", test_remove_prefix);
+	T("size-spots-duplicates", "duplicate entries aren't counted twice", test_size);
+	T("iterate-all", "iterate all entries in tree", test_iterate_all);
+	T("iterate-subset", "iterate a subset of entries in tree", test_iterate_subset);
 
 	dm_list_add(all_tests, &ts->list);
 }


