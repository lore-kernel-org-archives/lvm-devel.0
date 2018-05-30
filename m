From: Joe Thornber <thornber@sourceware.org>
Date: Wed, 30 May 2018 09:25:39 -0400
Subject: master - radix-tree: fix some bugs in remove_prefix and iterate
Message-ID: <201805301325.w4UDPd6M004202@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=06c789eda19445d5e59a9c8044d91300fa1d2000
Commit:        06c789eda19445d5e59a9c8044d91300fa1d2000
Parent:        1924426ad1e8a569c168e3d85c368ed531f382fe
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Wed May 30 14:14:59 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Wed May 30 14:21:27 2018 +0100

radix-tree: fix some bugs in remove_prefix and iterate

These weren't working if the prefix key was part of a prefix_chain.
---
 base/data-struct/radix-tree.c |   22 ++++++++++++++-
 test/unit/radix_tree_t.c      |   56 +++++++++++++++++++++++++++++++++++++++++
 2 files changed, 76 insertions(+), 2 deletions(-)

diff --git a/base/data-struct/radix-tree.c b/base/data-struct/radix-tree.c
index 8e8ac90..222b350 100644
--- a/base/data-struct/radix-tree.c
+++ b/base/data-struct/radix-tree.c
@@ -736,11 +736,29 @@ bool radix_tree_remove(struct radix_tree *rt, uint8_t *key_begin, uint8_t *key_e
 	return false;
 }
 
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
 unsigned radix_tree_remove_prefix(struct radix_tree *rt, uint8_t *kb, uint8_t *ke)
 {
         unsigned count = 0;
 	struct lookup_result lr = _lookup_prefix(&rt->root, kb, ke);
-	if (lr.kb == ke) {
+	if (lr.kb == ke || _prefix_chain_matches(&lr, ke)) {
         	count = _free_node(rt, *lr.v);
         	lr.v->type = UNSET;
 	}
@@ -837,7 +855,7 @@ void radix_tree_iterate(struct radix_tree *rt, uint8_t *kb, uint8_t *ke,
                         struct radix_tree_iterator *it)
 {
 	struct lookup_result lr = _lookup_prefix(&rt->root, kb, ke);
-	if (lr.kb == ke)
+	if (lr.kb == ke || _prefix_chain_matches(&lr, ke))
         	_iterate(lr.v, it);
 }
 
diff --git a/test/unit/radix_tree_t.c b/test/unit/radix_tree_t.c
index ba0d5e1..7266a8a 100644
--- a/test/unit/radix_tree_t.c
+++ b/test/unit/radix_tree_t.c
@@ -289,6 +289,18 @@ static void test_remove_prefix(void *fixture)
 	T_ASSERT_EQUAL(radix_tree_remove_prefix(rt, k, k + 1), count);
 }
 
+static void test_remove_prefix_single(void *fixture)
+{
+	struct radix_tree *rt = fixture;
+	uint8_t k[4];
+	union radix_value v;
+
+	_gen_key(k, k + sizeof(k));
+	v.n = 1234;
+	T_ASSERT(radix_tree_insert(rt, k, k + sizeof(k), v));
+	T_ASSERT_EQUAL(radix_tree_remove_prefix(rt, k, k + 2), 1);
+}
+
 static void test_size(void *fixture)
 {
 	struct radix_tree *rt = fixture;
@@ -367,6 +379,47 @@ static void test_iterate_subset(void *fixture)
 	T_ASSERT_EQUAL(vt.count, subset_count);
 }
 
+static void test_iterate_single(void *fixture)
+{
+	struct radix_tree *rt = fixture;
+	uint8_t k[6];
+	union radix_value v;
+	struct visitor vt;
+
+	_gen_key(k, k + sizeof(k));
+	v.n = 1234;
+	T_ASSERT(radix_tree_insert(rt, k, k + sizeof(k), v));
+
+	vt.count = 0;
+	vt.it.visit = _visit;
+	radix_tree_iterate(rt, k, k + 3, &vt.it);
+	T_ASSERT_EQUAL(vt.count, 1);
+}
+
+static void test_iterate_vary_middle(void *fixture)
+{
+	struct radix_tree *rt = fixture;
+	unsigned i;
+	uint8_t k[6];
+	union radix_value v;
+	struct visitor vt;
+
+	_gen_key(k, k + sizeof(k));
+	for (i = 0; i < 16; i++) {
+        	k[3] = i;
+		v.n = i;
+		T_ASSERT(radix_tree_insert(rt, k, k + sizeof(k), v));
+	}
+
+	vt.it.visit = _visit;
+	for (i = 0; i < 16; i++) {
+        	vt.count = 0;
+        	k[3] = i;
+        	radix_tree_iterate(rt, k, k + 4, &vt.it);
+        	T_ASSERT_EQUAL(vt.count, 1);
+	}
+}
+
 //----------------------------------------------------------------
 
 #define T(path, desc, fn) register_test(ts, "/base/data-struct/radix-tree/" path, desc, fn)
@@ -392,9 +445,12 @@ void radix_tree_tests(struct dm_list *all_tests)
 	T("remove-prefix-keys", "remove a set of keys that have common prefixes", test_remove_prefix_keys);
 	T("remove-prefix-keys-reversed", "remove a set of keys that have common prefixes (reversed)", test_remove_prefix_keys_reversed);
 	T("remove-prefix", "remove a subrange", test_remove_prefix);
+	T("remove-prefix-single", "remove a subrange with a single entry", test_remove_prefix_single);
 	T("size-spots-duplicates", "duplicate entries aren't counted twice", test_size);
 	T("iterate-all", "iterate all entries in tree", test_iterate_all);
 	T("iterate-subset", "iterate a subset of entries in tree", test_iterate_subset);
+	T("iterate-single", "iterate a subset that contains a single entry", test_iterate_single);
+	T("iterate-vary-middle", "iterate keys that vary in the middle", test_iterate_vary_middle);
 
 	dm_list_add(all_tests, &ts->list);
 }


