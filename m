From: Joe Thornber <thornber@sourceware.org>
Date: Thu, 21 Jun 2018 04:55:45 -0400
Subject: master - radix-tree: FIx various bugs to do with removal
Message-ID: <201806210855.w5L8tj0W025879@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=20b9746c5d22de385e32f5be9a8f04754be2c706
Commit:        20b9746c5d22de385e32f5be9a8f04754be2c706
Parent:        42f7caf1c267a5b75ee38ea77a7e2fd7c582e704
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Tue Jun 19 10:19:06 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Thu Jun 21 09:49:08 2018 +0100

radix-tree: FIx various bugs to do with removal

Add radix_tree_is_well_formed() which does some sanity checking
of the tree.

Call the above a lot in the unit tests.

Fix revealed bugs.
---
 base/data-struct/radix-tree.c |  342 +++++++++++++++++++++++++++++++++++++----
 base/data-struct/radix-tree.h |    4 +
 test/unit/Makefile            |    1 -
 test/unit/radix_tree_t.c      |  146 +++++++++++++++++-
 4 files changed, 457 insertions(+), 36 deletions(-)

diff --git a/base/data-struct/radix-tree.c b/base/data-struct/radix-tree.c
index 222b350..24455e1 100644
--- a/base/data-struct/radix-tree.c
+++ b/base/data-struct/radix-tree.c
@@ -387,11 +387,10 @@ static bool _insert_node48(struct radix_tree *rt, struct value *v, uint8_t *kb,
 		if (!n256)
 			return false;
 
+		n256->nr_entries = 49;
 		for (i = 0; i < 256; i++) {
-			if (n48->keys[i] >= 48)
-				continue;
-
-			n256->values[i] = n48->values[n48->keys[i]];
+			if (n48->keys[i] < 48)
+				n256->values[i] = n48->values[n48->keys[i]];
 		}
 
 		if (!_insert(rt, n256->values + *kb, kb + 1, ke, rv)) {
@@ -417,15 +416,13 @@ static bool _insert_node48(struct radix_tree *rt, struct value *v, uint8_t *kb,
 static bool _insert_node256(struct radix_tree *rt, struct value *v, uint8_t *kb, uint8_t *ke, union radix_value rv)
 {
 	struct node256 *n256 = v->value.ptr;
-	bool was_unset = n256->values[*kb].type == UNSET;
-
-	if (!_insert(rt, n256->values + *kb, kb + 1, ke, rv))
-		return false;
+	bool r, was_unset = n256->values[*kb].type == UNSET;
 
-	if (was_unset)
+	r = _insert(rt, n256->values + *kb, kb + 1, ke, rv);
+	if (r && was_unset)
         	n256->nr_entries++;
 
-	return true;
+	return r;
 }
 
 // FIXME: the tree should not be touched if insert fails (eg, OOM)
@@ -546,7 +543,9 @@ static struct lookup_result _lookup_prefix(struct value *v, uint8_t *kb, uint8_t
 
 	case NODE256:
 		n256 = v->value.ptr;
-		return _lookup_prefix(n256->values + *kb, kb + 1, ke);
+		if (n256->values[*kb].type != UNSET)
+			return _lookup_prefix(n256->values + *kb, kb + 1, ke);
+		break;
 	}
 
 	return (struct lookup_result) {.v = v, .kb = kb};
@@ -574,11 +573,19 @@ static void _degrade_to_n4(struct node16 *n16, struct value *result)
 
 static void _degrade_to_n16(struct node48 *n48, struct value *result)
 {
-        struct node4 *n16 = zalloc(sizeof(*n16));
+	unsigned i, count = 0;
+        struct node16 *n16 = zalloc(sizeof(*n16));
 
         n16->nr_entries = n48->nr_entries;
-        memcpy(n16->keys, n48->keys, n48->nr_entries * sizeof(*n16->keys));
+        for (i = 0; i < 256; i++) {
+	        if (n48->keys[i] < 48) {
+		        n16->keys[count] = i;
+		        count++;
+	        }
+        }
+
         memcpy(n16->values, n48->values, n48->nr_entries * sizeof(*n16->values));
+
         free(n48);
 
 	result->type = NODE16;
@@ -588,27 +595,42 @@ static void _degrade_to_n16(struct node48 *n48, struct value *result)
 static void _degrade_to_n48(struct node256 *n256, struct value *result)
 {
         unsigned i, count = 0;
-        struct node4 *n48 = zalloc(sizeof(*n48));
+        struct node48 *n48 = zalloc(sizeof(*n48));
+
+	memset(n48->keys, 48, sizeof(n48->keys));
 
         n48->nr_entries = n256->nr_entries;
         for (i = 0; i < 256; i++) {
 		if (n256->values[i].type == UNSET)
         		continue;
 
-		n48->keys[count] = i;
+		n48->keys[i] = count;
 		n48->values[count] = n256->values[i];
 		count++;
         }
+
         free(n256);
 
 	result->type = NODE48;
 	result->value.ptr = n48;
 }
 
+// Removes an entry in an array by sliding the values above it down.
+static void _erase_elt(void *array, unsigned obj_size, unsigned count, unsigned index)
+{
+	if (index == (count - 1))
+		// The simple case
+		return;
+
+	memmove(((uint8_t *) array) + (obj_size * index),
+                ((uint8_t *) array) + (obj_size * (index + 1)),
+                obj_size * (count - index - 1));
+}
+
 static bool _remove(struct radix_tree *rt, struct value *root, uint8_t *kb, uint8_t *ke)
 {
 	bool r;
-	unsigned i;
+	unsigned i, j;
 	struct value_chain *vc;
 	struct prefix_chain *pc;
 	struct node4 *n4;
@@ -643,7 +665,8 @@ static bool _remove(struct radix_tree *rt, struct value *root, uint8_t *kb, uint
 		vc = root->value.ptr;
 		r = _remove(rt, &vc->child, kb, ke);
 		if (r && (vc->child.type == UNSET)) {
-			memcpy(root, &vc->child, sizeof(*root));
+			root->type = VALUE;
+			root->value = vc->value;
 			free(vc);
 		}
 		return r;
@@ -657,7 +680,12 @@ static bool _remove(struct radix_tree *rt, struct value *root, uint8_t *kb, uint
 			if (kb[i] != pc->prefix[i])
         			return false;
 
-		return _remove(rt, &pc->child, kb + pc->len, ke);
+		r = _remove(rt, &pc->child, kb + pc->len, ke);
+		if (r && pc->child.type == UNSET) {
+			root->type = UNSET;
+			free(pc);
+		}
+		return r;
 
 	case NODE4:
 		n4 = root->value.ptr;
@@ -665,13 +693,16 @@ static bool _remove(struct radix_tree *rt, struct value *root, uint8_t *kb, uint
 			if (n4->keys[i] == *kb) {
 				r = _remove(rt, n4->values + i, kb + 1, ke);
 				if (r && n4->values[i].type == UNSET) {
+        				if (i < n4->nr_entries) {
+	        				_erase_elt(n4->keys, sizeof(*n4->keys), n4->nr_entries, i);
+	        				_erase_elt(n4->values, sizeof(*n4->values), n4->nr_entries, i);
+        				}
+
         				n4->nr_entries--;
-        				if (i < n4->nr_entries)
-                				// slide the entries down
-        					memmove(n4->keys + i, n4->keys + i + 1,
-                                                       sizeof(*n4->keys) * (n4->nr_entries - i));
-					if (!n4->nr_entries)
+					if (!n4->nr_entries) {
+						free(n4);
 						root->type = UNSET;
+					}
 				}
 				return r;
 			}
@@ -684,13 +715,15 @@ static bool _remove(struct radix_tree *rt, struct value *root, uint8_t *kb, uint
 			if (n16->keys[i] == *kb) {
 				r = _remove(rt, n16->values + i, kb + 1, ke);
 				if (r && n16->values[i].type == UNSET) {
+        				if (i < n16->nr_entries) {
+	        				_erase_elt(n16->keys, sizeof(*n16->keys), n16->nr_entries, i);
+	        				_erase_elt(n16->values, sizeof(*n16->values), n16->nr_entries, i);
+        				}
+
         				n16->nr_entries--;
-        				if (i < n16->nr_entries)
-                				// slide the entries down
-        					memmove(n16->keys + i, n16->keys + i + 1,
-                                                        sizeof(*n16->keys) * (n16->nr_entries - i));
-					if (n16->nr_entries <= 4)
+					if (n16->nr_entries <= 4) {
         					_degrade_to_n4(n16, root);
+					}
 				}
 				return r;
 			}
@@ -704,6 +737,10 @@ static bool _remove(struct radix_tree *rt, struct value *root, uint8_t *kb, uint
         		r = _remove(rt, n48->values + i, kb + 1, ke);
         		if (r && n48->values[i].type == UNSET) {
                 		n48->keys[*kb] = 48;
+                		for (j = 0; j < 256; j++)
+	                		if (n48->keys[j] < 48 && n48->keys[j] > i)
+		                		n48->keys[j]--;
+				_erase_elt(n48->values, sizeof(*n48->values), n48->nr_entries, i);
 				n48->nr_entries--;
 				if (n48->nr_entries <= 16)
         				_degrade_to_n16(n48, root);
@@ -736,6 +773,8 @@ bool radix_tree_remove(struct radix_tree *rt, uint8_t *key_begin, uint8_t *key_e
 	return false;
 }
 
+//----------------------------------------------------------------
+
 static bool _prefix_chain_matches(struct lookup_result *lr, uint8_t *ke)
 {
         // It's possible the top node is a prefix chain, and
@@ -754,19 +793,141 @@ static bool _prefix_chain_matches(struct lookup_result *lr, uint8_t *ke)
         return false;
 }
 
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
 unsigned radix_tree_remove_prefix(struct radix_tree *rt, uint8_t *kb, uint8_t *ke)
 {
         unsigned count = 0;
-	struct lookup_result lr = _lookup_prefix(&rt->root, kb, ke);
-	if (lr.kb == ke || _prefix_chain_matches(&lr, ke)) {
-        	count = _free_node(rt, *lr.v);
-        	lr.v->type = UNSET;
-	}
 
-	rt->nr_entries -= count;
+        if (_remove_subtree(rt, &rt->root, kb, ke, &count))
+		rt->nr_entries -= count;
+
 	return count;
 }
 
+//----------------------------------------------------------------
+
 bool radix_tree_lookup(struct radix_tree *rt,
 		       uint8_t *kb, uint8_t *ke, union radix_value *result)
 {
@@ -860,3 +1021,116 @@ void radix_tree_iterate(struct radix_tree *rt, uint8_t *kb, uint8_t *ke,
 }
 
 //----------------------------------------------------------------
+// Checks:
+// 1) The number of entries matches rt->nr_entries
+// 2) The number of entries is correct in each node
+
+static bool _check_nodes(struct value *v, unsigned *count)
+{
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
+		return true;
+
+	case NODE16:
+		n16 = v->value.ptr;
+		for (i = 0; i < n16->nr_entries; i++)
+			if (!_check_nodes(n16->values + i, count))
+				return false;
+		return true;
+
+	case NODE48:
+		n48 = v->value.ptr;
+		ncount = 0;
+		for (i = 0; i < 256; i++) {
+			if (n48->keys[i] < 48) {
+				ncount++;
+				if (!_check_nodes(n48->values + n48->keys[i], count))
+					return false;
+			}
+		}
+
+		if (ncount != n48->nr_entries) {
+			fprintf(stderr, "incorrect number of entries in n48, n48->nr_entries = %u, actual = %u\n",
+                                n48->nr_entries, ncount);
+			return false;
+		}
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
diff --git a/base/data-struct/radix-tree.h b/base/data-struct/radix-tree.h
index 1b6aee8..2deaf9a 100644
--- a/base/data-struct/radix-tree.h
+++ b/base/data-struct/radix-tree.h
@@ -53,6 +53,10 @@ struct radix_tree_iterator {
 void radix_tree_iterate(struct radix_tree *rt, uint8_t *kb, uint8_t *ke,
                         struct radix_tree_iterator *it);
 
+// Checks that some constraints on the shape of the tree are
+// being held.  For debug only.
+bool radix_tree_is_well_formed(struct radix_tree *rt);
+
 //----------------------------------------------------------------
 
 #endif
diff --git a/test/unit/Makefile b/test/unit/Makefile
index e7cc852..9155c47 100644
--- a/test/unit/Makefile
+++ b/test/unit/Makefile
@@ -11,7 +11,6 @@
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
 UNIT_SOURCE=\
-	base/data-struct/radix-tree.c \
 	device_mapper/vdo/status.c \
 	\
 	test/unit/activation-generator_t.c \
diff --git a/test/unit/radix_tree_t.c b/test/unit/radix_tree_t.c
index 7266a8a..e2d11e8 100644
--- a/test/unit/radix_tree_t.c
+++ b/test/unit/radix_tree_t.c
@@ -44,6 +44,7 @@ static void test_insert_one(void *fixture)
 	unsigned char k = 'a';
 	v.n = 65;
 	T_ASSERT(radix_tree_insert(rt, &k, &k + 1, v));
+	T_ASSERT(radix_tree_is_well_formed(rt));
 	v.n = 0;
 	T_ASSERT(radix_tree_lookup(rt, &k, &k + 1, &v));
 	T_ASSERT_EQUAL(v.n, 65);
@@ -62,6 +63,8 @@ static void test_single_byte_keys(void *fixture)
 		T_ASSERT(radix_tree_insert(rt, &k, &k + 1, v));
 	}
 
+	T_ASSERT(radix_tree_is_well_formed(rt));
+
 	for (i = 0; i < count; i++) {
 		k = i;
 		T_ASSERT(radix_tree_lookup(rt, &k, &k + 1, &v));
@@ -82,12 +85,16 @@ static void test_overwrite_single_byte_keys(void *fixture)
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
@@ -109,6 +116,8 @@ static void test_16_bit_keys(void *fixture)
 		T_ASSERT(radix_tree_insert(rt, k, k + sizeof(k), v));
 	}
 
+	T_ASSERT(radix_tree_is_well_formed(rt));
+
 	for (i = 0; i < count; i++) {
 		k[0] = i / 256;
 		k[1] = i % 256;
@@ -127,8 +136,10 @@ static void test_prefix_keys(void *fixture)
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
@@ -145,8 +156,10 @@ static void test_prefix_keys_reversed(void *fixture)
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
@@ -170,7 +183,10 @@ static void test_sparse_keys(void *fixture)
 		_gen_key(k, k + sizeof(k));
 		v.n = 1234;
 		T_ASSERT(radix_tree_insert(rt, k, k + 32, v));
+		// FIXME: remove
+		//T_ASSERT(radix_tree_is_well_formed(rt));
 	}
+	T_ASSERT(radix_tree_is_well_formed(rt));
 }
 
 static void test_remove_one(void *fixture)
@@ -182,7 +198,9 @@ static void test_remove_one(void *fixture)
 	_gen_key(k, k + sizeof(k));
 	v.n = 1234;
 	T_ASSERT(radix_tree_insert(rt, k, k + sizeof(k), v));
+	T_ASSERT(radix_tree_is_well_formed(rt));
 	T_ASSERT(radix_tree_remove(rt, k, k + sizeof(k)));
+	T_ASSERT(radix_tree_is_well_formed(rt));
 	T_ASSERT(!radix_tree_lookup(rt, k, k + sizeof(k), &v));
 }
 
@@ -199,14 +217,19 @@ static void test_remove_one_byte_keys(void *fixture)
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
 
@@ -216,6 +239,40 @@ static void test_remove_one_byte_keys(void *fixture)
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
@@ -230,8 +287,10 @@ static void test_remove_prefix_keys(void *fixture)
 		T_ASSERT(radix_tree_insert(rt, k, k + i, v));
 	}
 
+	T_ASSERT(radix_tree_is_well_formed(rt));
 	for (i = 0; i < 32; i++) {
         	T_ASSERT(radix_tree_remove(rt, k, k + i));
+		T_ASSERT(radix_tree_is_well_formed(rt));
         	for (j = i + 1; j < 32; j++) {
                 	T_ASSERT(radix_tree_lookup(rt, k, k + j, &v));
                 	T_ASSERT_EQUAL(v.n, j);
@@ -256,8 +315,10 @@ static void test_remove_prefix_keys_reversed(void *fixture)
 		T_ASSERT(radix_tree_insert(rt, k, k + i, v));
 	}
 
+	T_ASSERT(radix_tree_is_well_formed(rt));
 	for (i = 0; i < 32; i++) {
         	T_ASSERT(radix_tree_remove(rt, k, k + (31 - i)));
+		T_ASSERT(radix_tree_is_well_formed(rt));
         	for (j = 0; j < 31 - i; j++) {
                 	T_ASSERT(radix_tree_lookup(rt, k, k + j, &v));
                 	T_ASSERT_EQUAL(v.n, j);
@@ -284,9 +345,12 @@ static void test_remove_prefix(void *fixture)
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
@@ -298,7 +362,9 @@ static void test_remove_prefix_single(void *fixture)
 	_gen_key(k, k + sizeof(k));
 	v.n = 1234;
 	T_ASSERT(radix_tree_insert(rt, k, k + sizeof(k), v));
+	T_ASSERT(radix_tree_is_well_formed(rt));
 	T_ASSERT_EQUAL(radix_tree_remove_prefix(rt, k, k + 2), 1);
+	T_ASSERT(radix_tree_is_well_formed(rt));
 }
 
 static void test_size(void *fixture)
@@ -318,6 +384,7 @@ static void test_size(void *fixture)
 	}
 
 	T_ASSERT_EQUAL(radix_tree_size(rt), 10000 - dup_count);
+	T_ASSERT(radix_tree_is_well_formed(rt));
 }
 
 struct visitor {
@@ -348,6 +415,7 @@ static void test_iterate_all(void *fixture)
 		T_ASSERT(radix_tree_insert(rt, k, k + sizeof(k), v));
 	}
 
+	T_ASSERT(radix_tree_is_well_formed(rt));
 	vt.count = 0;
 	vt.it.visit = _visit;
 	radix_tree_iterate(rt, NULL, NULL, &vt.it);
@@ -371,6 +439,7 @@ static void test_iterate_subset(void *fixture)
 		T_ASSERT(radix_tree_insert(rt, k, k + sizeof(k), v));
 	}
 
+	T_ASSERT(radix_tree_is_well_formed(rt));
 	vt.count = 0;
 	vt.it.visit = _visit;
 	k[0] = 21;
@@ -390,6 +459,7 @@ static void test_iterate_single(void *fixture)
 	v.n = 1234;
 	T_ASSERT(radix_tree_insert(rt, k, k + sizeof(k), v));
 
+	T_ASSERT(radix_tree_is_well_formed(rt));
 	vt.count = 0;
 	vt.it.visit = _visit;
 	radix_tree_iterate(rt, k, k + 3, &vt.it);
@@ -411,6 +481,7 @@ static void test_iterate_vary_middle(void *fixture)
 		T_ASSERT(radix_tree_insert(rt, k, k + sizeof(k), v));
 	}
 
+	T_ASSERT(radix_tree_is_well_formed(rt));
 	vt.it.visit = _visit;
 	for (i = 0; i < 16; i++) {
         	vt.count = 0;
@@ -422,6 +493,77 @@ static void test_iterate_vary_middle(void *fixture)
 
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
+//----------------------------------------------------------------
+
 #define T(path, desc, fn) register_test(ts, "/base/data-struct/radix-tree/" path, desc, fn)
 
 void radix_tree_tests(struct dm_list *all_tests)
@@ -442,6 +584,7 @@ void radix_tree_tests(struct dm_list *all_tests)
 	T("sparse-keys", "see what the memory usage is for sparsely distributed keys", test_sparse_keys);
 	T("remove-one", "remove one entry", test_remove_one);
 	T("remove-one-byte-keys", "remove many one byte keys", test_remove_one_byte_keys);
+	T("remove-one-byte-keys-reversed", "remove many one byte keys reversed", test_remove_one_byte_keys_reversed);
 	T("remove-prefix-keys", "remove a set of keys that have common prefixes", test_remove_prefix_keys);
 	T("remove-prefix-keys-reversed", "remove a set of keys that have common prefixes (reversed)", test_remove_prefix_keys_reversed);
 	T("remove-prefix", "remove a subrange", test_remove_prefix);
@@ -451,6 +594,7 @@ void radix_tree_tests(struct dm_list *all_tests)
 	T("iterate-subset", "iterate a subset of entries in tree", test_iterate_subset);
 	T("iterate-single", "iterate a subset that contains a single entry", test_iterate_single);
 	T("iterate-vary-middle", "iterate keys that vary in the middle", test_iterate_vary_middle);
+	T("remove-calls-dtr", "remove should call the dtr for the value", test_remove_calls_dtr);
 
 	dm_list_add(all_tests, &ts->list);
 }


