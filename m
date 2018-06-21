From: Joe Thornber <thornber@sourceware.org>
Date: Thu, 21 Jun 2018 04:55:50 -0400
Subject: master - radix-tree: More debugging of remove
Message-ID: <201806210855.w5L8to3T025900@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=40c1f7889fd88ce4a2f2b42c594db3deb8f84593
Commit:        40c1f7889fd88ce4a2f2b42c594db3deb8f84593
Parent:        c8cfbfa605ce6577c390cf940d51d872b3556c64
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Wed Jun 20 10:04:59 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Thu Jun 21 09:49:43 2018 +0100

radix-tree: More debugging of remove

There's now a pretty printer called radix_tree_dump()

n4, n16, and n48 weren't UNSETting the last entry after
sliding values down.
---
 base/data-struct/radix-tree.c |  157 ++++++++++++++++++++++++++++++++++++-----
 base/data-struct/radix-tree.h |    2 +
 test/unit/radix_tree_t.c      |   32 ++++++++
 3 files changed, 174 insertions(+), 17 deletions(-)

diff --git a/base/data-struct/radix-tree.c b/base/data-struct/radix-tree.c
index 24455e1..202d463 100644
--- a/base/data-struct/radix-tree.c
+++ b/base/data-struct/radix-tree.c
@@ -251,7 +251,11 @@ static bool _insert_prefix_chain(struct radix_tree *rt, struct value *v, uint8_t
 {
 	struct prefix_chain *pc = v->value.ptr;
 
-	if (*kb == pc->prefix[0]) {
+	if (!pc->len) {
+		v->type = VALUE;
+		v->value = rv;
+
+	} else if (*kb == pc->prefix[0]) {
 		// There's a common prefix let's split the chain into two and
 		// recurse.
 		struct prefix_chain *pc2;
@@ -282,25 +286,23 @@ static bool _insert_prefix_chain(struct radix_tree *rt, struct value *v, uint8_t
 		if (!n4)
 			return false;
 
-		n4->keys[0] = *kb;
-		if (!_insert(rt, n4->values, kb + 1, ke, rv)) {
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
 			free(n4);
 			return false;
 		}
 
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
+		n4->nr_entries = 2;
 
 		v->type = NODE4;
 		v->value.ptr = n4;
@@ -330,7 +332,6 @@ static bool _insert_node4(struct radix_tree *rt, struct value *v, uint8_t *kb, u
 		v->type = NODE16;
 		v->value.ptr = n16;
 	} else {
-		n4 = v->value.ptr;
 		if (!_insert(rt, n4->values + n4->nr_entries, kb + 1, ke, rv))
 			return false;
 
@@ -699,6 +700,7 @@ static bool _remove(struct radix_tree *rt, struct value *root, uint8_t *kb, uint
         				}
 
         				n4->nr_entries--;
+        				n4->values[n4->nr_entries].type = UNSET;
 					if (!n4->nr_entries) {
 						free(n4);
 						root->type = UNSET;
@@ -721,6 +723,7 @@ static bool _remove(struct radix_tree *rt, struct value *root, uint8_t *kb, uint
         				}
 
         				n16->nr_entries--;
+        				n16->values[n16->nr_entries].type = UNSET;
 					if (n16->nr_entries <= 4) {
         					_degrade_to_n4(n16, root);
 					}
@@ -742,6 +745,7 @@ static bool _remove(struct radix_tree *rt, struct value *root, uint8_t *kb, uint
 		                		n48->keys[j]--;
 				_erase_elt(n48->values, sizeof(*n48->values), n48->nr_entries, i);
 				n48->nr_entries--;
+				n48->values[n48->nr_entries].type = UNSET;
 				if (n48->nr_entries <= 16)
         				_degrade_to_n16(n48, root);
         		}
@@ -1024,6 +1028,8 @@ void radix_tree_iterate(struct radix_tree *rt, uint8_t *kb, uint8_t *ke,
 // Checks:
 // 1) The number of entries matches rt->nr_entries
 // 2) The number of entries is correct in each node
+// 3) prefix chain len > 0
+// 4) all unused values are UNSET
 
 static bool _check_nodes(struct value *v, unsigned *count)
 {
@@ -1057,6 +1063,13 @@ static bool _check_nodes(struct value *v, unsigned *count)
 		for (i = 0; i < n4->nr_entries; i++)
 			if (!_check_nodes(n4->values + i, count))
 				return false;
+
+		for (i = n4->nr_entries; i < 4; i++)
+			if (n4->values[i].type != UNSET) {
+				fprintf(stderr, "unused value is not UNSET\n");
+				return false;
+			}
+
 		return true;
 
 	case NODE16:
@@ -1064,6 +1077,13 @@ static bool _check_nodes(struct value *v, unsigned *count)
 		for (i = 0; i < n16->nr_entries; i++)
 			if (!_check_nodes(n16->values + i, count))
 				return false;
+
+		for (i = n16->nr_entries; i < 16; i++)
+			if (n16->values[i].type != UNSET) {
+				fprintf(stderr, "unused value is not UNSET\n");
+				return false;
+			}
+
 		return true;
 
 	case NODE48:
@@ -1083,6 +1103,12 @@ static bool _check_nodes(struct value *v, unsigned *count)
 			return false;
 		}
 
+		for (i = n48->nr_entries; i < 48; i++)
+			if (n48->values[i].type != UNSET) {
+				fprintf(stderr, "unused value is not UNSET\n");
+				return false;
+			}
+
 		return true;
 
 	case NODE256:
@@ -1134,3 +1160,100 @@ bool radix_tree_is_well_formed(struct radix_tree *rt)
 }
 
 //----------------------------------------------------------------
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
+		for (i = 0; i < 256; i++)
+			if (n48->keys[i] < 48)
+				_dump(out, n48->values[i], indent + 1);
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
diff --git a/base/data-struct/radix-tree.h b/base/data-struct/radix-tree.h
index 2deaf9a..5d4d04c 100644
--- a/base/data-struct/radix-tree.h
+++ b/base/data-struct/radix-tree.h
@@ -15,6 +15,7 @@
 
 #include <stdbool.h>
 #include <stdint.h>
+#include <stdio.h>
 
 //----------------------------------------------------------------
 
@@ -56,6 +57,7 @@ void radix_tree_iterate(struct radix_tree *rt, uint8_t *kb, uint8_t *ke,
 // Checks that some constraints on the shape of the tree are
 // being held.  For debug only.
 bool radix_tree_is_well_formed(struct radix_tree *rt);
+void radix_tree_dump(struct radix_tree *rt, FILE *out);
 
 //----------------------------------------------------------------
 
diff --git a/test/unit/radix_tree_t.c b/test/unit/radix_tree_t.c
index 4ee22c1..2fba15f 100644
--- a/test/unit/radix_tree_t.c
+++ b/test/unit/radix_tree_t.c
@@ -605,6 +605,37 @@ static void test_destroy_calls_dtr(void *fixture)
 
 //----------------------------------------------------------------
 
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
 #define T(path, desc, fn) register_test(ts, "/base/data-struct/radix-tree/" path, desc, fn)
 
 void radix_tree_tests(struct dm_list *all_tests)
@@ -637,6 +668,7 @@ void radix_tree_tests(struct dm_list *all_tests)
 	T("iterate-vary-middle", "iterate keys that vary in the middle", test_iterate_vary_middle);
 	T("remove-calls-dtr", "remove should call the dtr for the value", test_remove_calls_dtr);
 	T("destroy-calls-dtr", "destroy should call the dtr for all values", test_destroy_calls_dtr);
+	T("bcache-scenario", "A specific series of keys from a bcache scenario", test_bcache_scenario);
 
 	dm_list_add(all_tests, &ts->list);
 }


