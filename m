From: Joe Thornber <thornber@sourceware.org>
Date: Tue, 29 May 2018 13:16:21 -0400
Subject: master - radix-tree: radix_tree_remove_prefix()
Message-ID: <201805291716.w4THGLoI024023@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c2a8bbed3bc8c5c4f505a7cecc4db0b94e7243bc
Commit:        c2a8bbed3bc8c5c4f505a7cecc4db0b94e7243bc
Parent:        9b41efae826257ecfd9400d6a9d17d7e98e822dc
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Tue May 29 13:25:59 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Tue May 29 13:25:59 2018 +0100

radix-tree: radix_tree_remove_prefix()

---
 base/data-struct/radix-tree.c |   33 +++++++++++++++++++++++++--------
 base/data-struct/radix-tree.h |    4 ++++
 test/unit/radix_tree_t.c      |   22 ++++++++++++++++++++++
 3 files changed, 51 insertions(+), 8 deletions(-)

diff --git a/base/data-struct/radix-tree.c b/base/data-struct/radix-tree.c
index 26748e3..5688dec 100644
--- a/base/data-struct/radix-tree.c
+++ b/base/data-struct/radix-tree.c
@@ -101,9 +101,10 @@ static inline void _dtr(struct radix_tree *rt, union radix_value v)
         	rt->dtr(rt->dtr_context, v);
 }
 
-static void _free_node(struct radix_tree *rt, struct value v)
+// Returns the number of values removed
+static unsigned _free_node(struct radix_tree *rt, struct value v)
 {
-	unsigned i;
+	unsigned i, nr = 0;
 	struct value_chain *vc;
 	struct prefix_chain *pc;
 	struct node4 *n4;
@@ -117,49 +118,52 @@ static void _free_node(struct radix_tree *rt, struct value v)
 
 	case VALUE:
         	_dtr(rt, v.value);
+        	nr = 1;
 		break;
 
 	case VALUE_CHAIN:
 		vc = v.value.ptr;
 		_dtr(rt, vc->value);
-		_free_node(rt, vc->child);
+		nr = 1 + _free_node(rt, vc->child);
 		free(vc);
 		break;
 
 	case PREFIX_CHAIN:
 		pc = v.value.ptr;
-		_free_node(rt, pc->child);
+		nr = _free_node(rt, pc->child);
 		free(pc);
 		break;
 
 	case NODE4:
 		n4 = (struct node4 *) v.value.ptr;
 		for (i = 0; i < n4->nr_entries; i++)
-			_free_node(rt, n4->values[i]);
+			nr += _free_node(rt, n4->values[i]);
 		free(n4);
 		break;
 
 	case NODE16:
 		n16 = (struct node16 *) v.value.ptr;
 		for (i = 0; i < n16->nr_entries; i++)
-			_free_node(rt, n16->values[i]);
+			nr += _free_node(rt, n16->values[i]);
 		free(n16);
 		break;
 
 	case NODE48:
 		n48 = (struct node48 *) v.value.ptr;
 		for (i = 0; i < n48->nr_entries; i++)
-			_free_node(rt, n48->values[i]);
+			nr += _free_node(rt, n48->values[i]);
 		free(n48);
 		break;
 
 	case NODE256:
 		n256 = (struct node256 *) v.value.ptr;
 		for (i = 0; i < 256; i++)
-			_free_node(rt, n256->values[i]);
+			nr += _free_node(rt, n256->values[i]);
 		free(n256);
 		break;
 	}
+
+	return nr;
 }
 
 void radix_tree_destroy(struct radix_tree *rt)
@@ -728,6 +732,19 @@ bool radix_tree_remove(struct radix_tree *rt, uint8_t *key_begin, uint8_t *key_e
 	return false;
 }
 
+unsigned radix_tree_remove_prefix(struct radix_tree *rt, uint8_t *kb, uint8_t *ke)
+{
+        unsigned count = 0;
+	struct lookup_result lr = _lookup_prefix(&rt->root, kb, ke);
+	if (lr.kb == ke) {
+        	count = _free_node(rt, *lr.v);
+        	lr.v->type = UNSET;
+	}
+
+	rt->nr_entries -= count;
+	return count;
+}
+
 bool radix_tree_lookup(struct radix_tree *rt,
 		       uint8_t *kb, uint8_t *ke, union radix_value *result)
 {
diff --git a/base/data-struct/radix-tree.h b/base/data-struct/radix-tree.h
index 8560b34..ad8a952 100644
--- a/base/data-struct/radix-tree.h
+++ b/base/data-struct/radix-tree.h
@@ -34,6 +34,10 @@ void radix_tree_destroy(struct radix_tree *rt);
 unsigned radix_tree_size(struct radix_tree *rt);
 bool radix_tree_insert(struct radix_tree *rt, uint8_t *kb, uint8_t *ke, union radix_value v);
 bool radix_tree_remove(struct radix_tree *rt, uint8_t *kb, uint8_t *ke);
+
+// Returns the number of values removed
+unsigned radix_tree_remove_prefix(struct radix_tree *rt, uint8_t *prefix_b, uint8_t *prefix_e);
+
 bool radix_tree_lookup(struct radix_tree *rt,
 		       uint8_t *kb, uint8_t *ke, union radix_value *result);
 
diff --git a/test/unit/radix_tree_t.c b/test/unit/radix_tree_t.c
index d2b0adc..eb35773 100644
--- a/test/unit/radix_tree_t.c
+++ b/test/unit/radix_tree_t.c
@@ -267,6 +267,27 @@ static void test_remove_prefix_keys_reversed(void *fixture)
                 T_ASSERT(!radix_tree_lookup(rt, k, k + i, &v));
 }
 
+static void test_remove_prefix(void *fixture)
+{
+	struct radix_tree *rt = fixture;
+	unsigned i, count = 0;
+	uint8_t k[4];
+	union radix_value v;
+
+	// populate some random 32bit keys
+	for (i = 0; i < 100000; i++) {
+        	_gen_key(k, k + sizeof(k));
+        	if (k[0] == 21)
+                	count++;
+		v.n = i;
+		T_ASSERT(radix_tree_insert(rt, k, k + sizeof(k), v));
+	}
+
+	// remove keys in a sub range 
+	k[0] = 21;
+	T_ASSERT_EQUAL(radix_tree_remove_prefix(rt, k, k + 1), count);
+}
+
 //----------------------------------------------------------------
 
 #define T(path, desc, fn) register_test(ts, "/base/data-struct/radix-tree/" path, desc, fn)
@@ -291,6 +312,7 @@ void radix_tree_tests(struct dm_list *all_tests)
 	T("remove-one-byte-keys", "remove many one byte keys", test_remove_one_byte_keys);
 	T("remove-prefix-keys", "remove a set of keys that have common prefixes", test_remove_prefix_keys);
 	T("remove-prefix-keys-reversed", "remove a set of keys that have common prefixes (reversed)", test_remove_prefix_keys_reversed);
+	T("remove-prefix", "remove a subrange", test_remove_prefix);
 
 	dm_list_add(all_tests, &ts->list);
 }


