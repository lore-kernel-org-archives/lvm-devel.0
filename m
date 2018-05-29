From: Joe Thornber <thornber@sourceware.org>
Date: Tue, 29 May 2018 13:16:09 -0400
Subject: master - radix_tree: add remove method
Message-ID: <201805291716.w4THG977023673@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b7fd8ac8ebf07f7a8119aae723f40ef6f85273ce
Commit:        b7fd8ac8ebf07f7a8119aae723f40ef6f85273ce
Parent:        87291a28328e6b786ea6674aa52003e7f4af0ac3
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Wed May 23 12:48:06 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Wed May 23 12:48:06 2018 +0100

radix_tree: add remove method

---
 base/data-struct/radix-tree.c |  185 +++++++++++++++++++++++++++++++++++++++-
 base/data-struct/radix-tree.h |    2 +-
 test/unit/radix_tree_t.c      |  112 ++++++++++++++++++++++++-
 3 files changed, 289 insertions(+), 10 deletions(-)

diff --git a/base/data-struct/radix-tree.c b/base/data-struct/radix-tree.c
index b4b6791..a359aaa 100644
--- a/base/data-struct/radix-tree.c
+++ b/base/data-struct/radix-tree.c
@@ -68,6 +68,7 @@ struct node48 {
 };
 
 struct node256 {
+        uint32_t nr_entries;
 	struct value values[256];
 };
 
@@ -397,10 +398,13 @@ static bool _insert_node48(struct value *v, uint8_t *kb, uint8_t *ke, union radi
 static bool _insert_node256(struct value *v, uint8_t *kb, uint8_t *ke, union radix_value rv)
 {
 	struct node256 *n256 = v->value.ptr;
-	if (!_insert(n256->values + *kb, kb + 1, ke, rv)) {
-		n256->values[*kb].type = UNSET;
+	bool was_unset = n256->values[*kb].type == UNSET;
+
+	if (!_insert(n256->values + *kb, kb + 1, ke, rv))
 		return false;
-	}
+
+	if (was_unset)
+        	n256->nr_entries++;
 
 	return true;
 }
@@ -538,9 +542,180 @@ bool radix_tree_insert(struct radix_tree *rt, uint8_t *kb, uint8_t *ke, union ra
 	return false;
 }
 
-void radix_tree_delete(struct radix_tree *rt, uint8_t *key_begin, uint8_t *key_end)
+// Note the degrade functions also free the original node.
+static void _degrade_to_n4(struct node16 *n16, struct value *result)
+{
+        struct node4 *n4 = zalloc(sizeof(*n4));
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
+        struct node4 *n16 = zalloc(sizeof(*n16));
+
+        n16->nr_entries = n48->nr_entries;
+        memcpy(n16->keys, n48->keys, n48->nr_entries * sizeof(*n16->keys));
+        memcpy(n16->values, n48->values, n48->nr_entries * sizeof(*n16->values));
+        free(n48);
+
+	result->type = NODE16;
+	result->value.ptr = n16;
+}
+
+static void _degrade_to_n48(struct node256 *n256, struct value *result)
+{
+        unsigned i, count = 0;
+        struct node4 *n48 = zalloc(sizeof(*n48));
+
+        n48->nr_entries = n256->nr_entries;
+        for (i = 0; i < 256; i++) {
+		if (n256->values[i].type == UNSET)
+        		continue;
+
+		n48->keys[count] = i;
+		n48->values[count] = n256->values[i];
+		count++;
+        }
+        free(n256);
+
+	result->type = NODE48;
+	result->value.ptr = n48;
+}
+
+static bool _remove(struct value *root, uint8_t *kb, uint8_t *ke)
+{
+	bool r;
+	unsigned i;
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
+                	return true;
+
+                } else if (root->type == VALUE_CHAIN) {
+			vc = root->value.ptr;
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
+		r = _remove(&vc->child, kb, ke);
+		if (r && (vc->child.type == UNSET)) {
+			memcpy(root, &vc->child, sizeof(*root));
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
+		return _remove(&pc->child, kb + pc->len, ke);
+
+	case NODE4:
+		n4 = root->value.ptr;
+		for (i = 0; i < n4->nr_entries; i++) {
+			if (n4->keys[i] == *kb) {
+				r = _remove(n4->values + i, kb + 1, ke);
+				if (r && n4->values[i].type == UNSET) {
+        				n4->nr_entries--;
+        				if (i < n4->nr_entries)
+                				// slide the entries down
+        					memmove(n4->keys + i, n4->keys + i + 1,
+                                                       sizeof(*n4->keys) * (n4->nr_entries - i));
+					if (!n4->nr_entries)
+						root->type = UNSET;
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
+				r = _remove(n16->values + i, kb + 1, ke);
+				if (r && n16->values[i].type == UNSET) {
+        				n16->nr_entries--;
+        				if (i < n16->nr_entries)
+                				// slide the entries down
+        					memmove(n16->keys + i, n16->keys + i + 1,
+                                                        sizeof(*n16->keys) * (n16->nr_entries - i));
+					if (n16->nr_entries <= 4)
+        					_degrade_to_n4(n16, root);
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
+        		r = _remove(n48->values + i, kb + 1, ke);
+        		if (r && n48->values[i].type == UNSET) {
+                		n48->keys[*kb] = 48;
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
+		r = _remove(n256->values + (*kb), kb + 1, ke);
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
 {
-	assert(0);
+	if (_remove(&rt->root, key_begin, key_end)) {
+        	rt->nr_entries--;
+        	return true;
+	}
+
+	return false;
 }
 
 bool radix_tree_lookup(struct radix_tree *rt,
diff --git a/base/data-struct/radix-tree.h b/base/data-struct/radix-tree.h
index d84e3c5..983b5fa 100644
--- a/base/data-struct/radix-tree.h
+++ b/base/data-struct/radix-tree.h
@@ -34,7 +34,7 @@ void radix_tree_destroy(struct radix_tree *rt, radix_value_dtr dtr, void *contex
 
 unsigned radix_tree_size(struct radix_tree *rt);
 bool radix_tree_insert(struct radix_tree *rt, uint8_t *kb, uint8_t *ke, union radix_value v);
-void radix_tree_delete(struct radix_tree *rt, uint8_t *kb, uint8_t *ke);
+bool radix_tree_remove(struct radix_tree *rt, uint8_t *kb, uint8_t *ke);
 bool radix_tree_lookup(struct radix_tree *rt,
 		       uint8_t *kb, uint8_t *ke, union radix_value *result);
 
diff --git a/test/unit/radix_tree_t.c b/test/unit/radix_tree_t.c
index 4455f2b..9f2ba07 100644
--- a/test/unit/radix_tree_t.c
+++ b/test/unit/radix_tree_t.c
@@ -152,22 +152,122 @@ static void test_prefix_keys_reversed(void *fixture)
 	T_ASSERT_EQUAL(v.n, 2345);
 }
 
+static void _gen_key(uint8_t *b, uint8_t *e)
+{
+	for (; b != e; b++)
+		*b = rand() % 256;
+}
+
 static void test_sparse_keys(void *fixture)
 {
-	unsigned i, n;
+	unsigned n;
 	struct radix_tree *rt = fixture;
 	union radix_value v;
 	uint8_t k[32];
 
 	for (n = 0; n < 100000; n++) {
-		for (i = 0; i < 32; i++)
-			k[i] = rand() % 256;
-
+		_gen_key(k, k + sizeof(k));
 		v.n = 1234;
 		T_ASSERT(radix_tree_insert(rt, k, k + 32, v));
 	}
 }
 
+static void test_remove_one(void *fixture)
+{
+	struct radix_tree *rt = fixture;
+	uint8_t k[4];
+	union radix_value v;
+
+	_gen_key(k, k + sizeof(k));
+	v.n = 1234;
+	T_ASSERT(radix_tree_insert(rt, k, k + sizeof(k), v));
+	T_ASSERT(radix_tree_remove(rt, k, k + sizeof(k)));
+	T_ASSERT(!radix_tree_lookup(rt, k, k + sizeof(k), &v));
+}
+
+static void test_remove_one_byte_keys(void *fixture)
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
+	for (i = 0; i < 256; i++) {
+        	k[0] = i;
+		T_ASSERT(radix_tree_remove(rt, k, k + 1));
+
+		for (j = i + 1; j < 256; j++) {
+        		k[0] = j;
+			T_ASSERT(radix_tree_lookup(rt, k, k + 1, &v));
+			T_ASSERT_EQUAL(v.n, j + 1000);
+		}
+	}
+
+	for (i = 0; i < 256; i++) {
+        	k[0] = i;
+		T_ASSERT(!radix_tree_lookup(rt, k, k + 1, &v));
+	}
+}
+
+static void test_remove_prefix_keys(void *fixture)
+{
+	struct radix_tree *rt = fixture;
+	unsigned i, j;
+	uint8_t k[32];
+	union radix_value v;
+
+	_gen_key(k, k + sizeof(k));
+
+	for (i = 0; i < 32; i++) {
+		v.n = i;
+		T_ASSERT(radix_tree_insert(rt, k, k + i, v));
+	}
+
+	for (i = 0; i < 32; i++) {
+        	T_ASSERT(radix_tree_remove(rt, k, k + i));
+        	for (j = i + 1; j < 32; j++) {
+                	T_ASSERT(radix_tree_lookup(rt, k, k + j, &v));
+                	T_ASSERT_EQUAL(v.n, j);
+        	}
+	}
+
+        for (i = 0; i < 32; i++)
+                T_ASSERT(!radix_tree_lookup(rt, k, k + i, &v));
+}
+
+static void test_remove_prefix_keys_reversed(void *fixture)
+{
+	struct radix_tree *rt = fixture;
+	unsigned i, j;
+	uint8_t k[32];
+	union radix_value v;
+
+	_gen_key(k, k + sizeof(k));
+
+	for (i = 0; i < 32; i++) {
+		v.n = i;
+		T_ASSERT(radix_tree_insert(rt, k, k + i, v));
+	}
+
+	for (i = 0; i < 32; i++) {
+        	fprintf(stderr, "removing %u\n", i);
+        	T_ASSERT(radix_tree_remove(rt, k, k + (31 - i)));
+        	for (j = 0; j < 31 - i; j++) {
+                	T_ASSERT(radix_tree_lookup(rt, k, k + j, &v));
+                	T_ASSERT_EQUAL(v.n, j);
+        	}
+	}
+
+        for (i = 0; i < 32; i++)
+                T_ASSERT(!radix_tree_lookup(rt, k, k + i, &v));
+}
+
 //----------------------------------------------------------------
 
 #define T(path, desc, fn) register_test(ts, "/base/data-struct/radix-tree/" path, desc, fn)
@@ -188,6 +288,10 @@ void radix_tree_tests(struct dm_list *all_tests)
 	T("prefix-keys", "prefixes of other keys are valid keys", test_prefix_keys);
 	T("prefix-keys-reversed", "prefixes of other keys are valid keys", test_prefix_keys_reversed);
 	T("sparse-keys", "see what the memory usage is for sparsely distributed keys", test_sparse_keys);
+	T("remove-one", "remove one entry", test_remove_one);
+	T("remove-one-byte-keys", "remove many one byte keys", test_remove_one_byte_keys);
+	T("remove-prefix-keys", "remove a set of keys that have common prefixes", test_remove_prefix_keys);
+	T("remove-prefix-keys-reversed", "remove a set of keys that have common prefixes (reversed)", test_remove_prefix_keys_reversed);
 
 	dm_list_add(all_tests, &ts->list);
 }


