From: Joe Thornber <thornber@sourceware.org>
Date: Tue, 29 May 2018 13:16:19 -0400
Subject: master - radix-tree: call the value dtr when removing an entry.
Message-ID: <201805291716.w4THGJa6024011@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9b41efae826257ecfd9400d6a9d17d7e98e822dc
Commit:        9b41efae826257ecfd9400d6a9d17d7e98e822dc
Parent:        0181c77e3fe0fd4c82b10e283d4852a09ff78452
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Tue May 29 11:23:36 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Tue May 29 11:23:36 2018 +0100

radix-tree: call the value dtr when removing an entry.

---
 base/data-struct/radix-tree.c |   46 +++++++++++++++++++++++-----------------
 1 files changed, 26 insertions(+), 20 deletions(-)

diff --git a/base/data-struct/radix-tree.c b/base/data-struct/radix-tree.c
index 3df85e7..26748e3 100644
--- a/base/data-struct/radix-tree.c
+++ b/base/data-struct/radix-tree.c
@@ -95,7 +95,13 @@ struct radix_tree *radix_tree_create(radix_value_dtr dtr, void *dtr_context)
 	return rt;
 }
 
-static void _free_node(struct value v, radix_value_dtr dtr, void *context)
+static inline void _dtr(struct radix_tree *rt, union radix_value v)
+{
+	if (rt->dtr)
+        	rt->dtr(rt->dtr_context, v);
+}
+
+static void _free_node(struct radix_tree *rt, struct value v)
 {
 	unsigned i;
 	struct value_chain *vc;
@@ -110,49 +116,47 @@ static void _free_node(struct value v, radix_value_dtr dtr, void *context)
 		break;
 
 	case VALUE:
-		if (dtr)
-			dtr(context, v.value);
+        	_dtr(rt, v.value);
 		break;
 
 	case VALUE_CHAIN:
 		vc = v.value.ptr;
-		if (dtr)
-			dtr(context, vc->value);
-		_free_node(vc->child, dtr, context);
+		_dtr(rt, vc->value);
+		_free_node(rt, vc->child);
 		free(vc);
 		break;
 
 	case PREFIX_CHAIN:
 		pc = v.value.ptr;
-		_free_node(pc->child, dtr, context);
+		_free_node(rt, pc->child);
 		free(pc);
 		break;
 
 	case NODE4:
 		n4 = (struct node4 *) v.value.ptr;
 		for (i = 0; i < n4->nr_entries; i++)
-			_free_node(n4->values[i], dtr, context);
+			_free_node(rt, n4->values[i]);
 		free(n4);
 		break;
 
 	case NODE16:
 		n16 = (struct node16 *) v.value.ptr;
 		for (i = 0; i < n16->nr_entries; i++)
-			_free_node(n16->values[i], dtr, context);
+			_free_node(rt, n16->values[i]);
 		free(n16);
 		break;
 
 	case NODE48:
 		n48 = (struct node48 *) v.value.ptr;
 		for (i = 0; i < n48->nr_entries; i++)
-			_free_node(n48->values[i], dtr, context);
+			_free_node(rt, n48->values[i]);
 		free(n48);
 		break;
 
 	case NODE256:
 		n256 = (struct node256 *) v.value.ptr;
 		for (i = 0; i < 256; i++)
-			_free_node(n256->values[i], dtr, context);
+			_free_node(rt, n256->values[i]);
 		free(n256);
 		break;
 	}
@@ -160,7 +164,7 @@ static void _free_node(struct value v, radix_value_dtr dtr, void *context)
 
 void radix_tree_destroy(struct radix_tree *rt)
 {
-	_free_node(rt->root, rt->dtr, rt->dtr_context);
+	_free_node(rt, rt->root);
 	free(rt);
 }
 
@@ -593,7 +597,7 @@ static void _degrade_to_n48(struct node256 *n256, struct value *result)
 	result->value.ptr = n48;
 }
 
-static bool _remove(struct value *root, uint8_t *kb, uint8_t *ke)
+static bool _remove(struct radix_tree *rt, struct value *root, uint8_t *kb, uint8_t *ke)
 {
 	bool r;
 	unsigned i;
@@ -607,10 +611,12 @@ static bool _remove(struct value *root, uint8_t *kb, uint8_t *ke)
 	if (kb == ke) {
         	if (root->type == VALUE) {
                 	root->type = UNSET;
+                	_dtr(rt, root->value);
                 	return true;
 
                 } else if (root->type == VALUE_CHAIN) {
 			vc = root->value.ptr;
+			_dtr(rt, vc->value);
 			memcpy(root, &vc->child, sizeof(*root));
 			free(vc);
 			return true;
@@ -627,7 +633,7 @@ static bool _remove(struct value *root, uint8_t *kb, uint8_t *ke)
 
 	case VALUE_CHAIN:
 		vc = root->value.ptr;
-		r = _remove(&vc->child, kb, ke);
+		r = _remove(rt, &vc->child, kb, ke);
 		if (r && (vc->child.type == UNSET)) {
 			memcpy(root, &vc->child, sizeof(*root));
 			free(vc);
@@ -643,13 +649,13 @@ static bool _remove(struct value *root, uint8_t *kb, uint8_t *ke)
 			if (kb[i] != pc->prefix[i])
         			return false;
 
-		return _remove(&pc->child, kb + pc->len, ke);
+		return _remove(rt, &pc->child, kb + pc->len, ke);
 
 	case NODE4:
 		n4 = root->value.ptr;
 		for (i = 0; i < n4->nr_entries; i++) {
 			if (n4->keys[i] == *kb) {
-				r = _remove(n4->values + i, kb + 1, ke);
+				r = _remove(rt, n4->values + i, kb + 1, ke);
 				if (r && n4->values[i].type == UNSET) {
         				n4->nr_entries--;
         				if (i < n4->nr_entries)
@@ -668,7 +674,7 @@ static bool _remove(struct value *root, uint8_t *kb, uint8_t *ke)
         	n16 = root->value.ptr;
 		for (i = 0; i < n16->nr_entries; i++) {
 			if (n16->keys[i] == *kb) {
-				r = _remove(n16->values + i, kb + 1, ke);
+				r = _remove(rt, n16->values + i, kb + 1, ke);
 				if (r && n16->values[i].type == UNSET) {
         				n16->nr_entries--;
         				if (i < n16->nr_entries)
@@ -687,7 +693,7 @@ static bool _remove(struct value *root, uint8_t *kb, uint8_t *ke)
 		n48 = root->value.ptr;
 		i = n48->keys[*kb];
 		if (i < 48) {
-        		r = _remove(n48->values + i, kb + 1, ke);
+        		r = _remove(rt, n48->values + i, kb + 1, ke);
         		if (r && n48->values[i].type == UNSET) {
                 		n48->keys[*kb] = 48;
 				n48->nr_entries--;
@@ -700,7 +706,7 @@ static bool _remove(struct value *root, uint8_t *kb, uint8_t *ke)
 
 	case NODE256:
 		n256 = root->value.ptr;
-		r = _remove(n256->values + (*kb), kb + 1, ke);
+		r = _remove(rt, n256->values + (*kb), kb + 1, ke);
 		if (r && n256->values[*kb].type == UNSET) {
 			n256->nr_entries--;
 			if (n256->nr_entries <= 48)
@@ -714,7 +720,7 @@ static bool _remove(struct value *root, uint8_t *kb, uint8_t *ke)
 
 bool radix_tree_remove(struct radix_tree *rt, uint8_t *key_begin, uint8_t *key_end)
 {
-	if (_remove(&rt->root, key_begin, key_end)) {
+	if (_remove(rt, &rt->root, key_begin, key_end)) {
         	rt->nr_entries--;
         	return true;
 	}


