From: Joe Thornber <thornber@sourceware.org>
Date: Mon, 20 Aug 2018 10:36:57 -0400
Subject: master - radix-tree: Fix bug in remove_prefix()
Message-ID: <201808201436.w7KEavgq012704@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8b05f1f230517aa42878aa160d94383ed0534c64
Commit:        8b05f1f230517aa42878aa160d94383ed0534c64
Parent:        54668feaabead997cdf099c970999af667bcf274
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Mon Aug 20 15:23:40 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Mon Aug 20 15:23:40 2018 +0100

radix-tree: Fix bug in remove_prefix()

Accidental decrement of the nr entries when a n256 didn't have the
entry in the first place.
---
 base/data-struct/radix-tree.c |    3 +
 test/unit/radix_tree_t.c      |  116 +++++++++++++++++++++++++++++++++++++++++
 2 files changed, 119 insertions(+), 0 deletions(-)

diff --git a/base/data-struct/radix-tree.c b/base/data-struct/radix-tree.c
index 1d24dad..1eef1f8 100644
--- a/base/data-struct/radix-tree.c
+++ b/base/data-struct/radix-tree.c
@@ -907,6 +907,9 @@ static bool _remove_subtree(struct radix_tree *rt, struct value *root, uint8_t *
 
 	case NODE256:
 		n256 = root->value.ptr;
+		if (n256->values[*kb].type == UNSET)
+			return true;  // No entries
+
 		r = _remove_subtree(rt, n256->values + (*kb), kb + 1, ke, count);
 		if (r && n256->values[*kb].type == UNSET) {
 			n256->nr_entries--;
diff --git a/test/unit/radix_tree_t.c b/test/unit/radix_tree_t.c
index e5d3e98..0dde6b7 100644
--- a/test/unit/radix_tree_t.c
+++ b/test/unit/radix_tree_t.c
@@ -635,6 +635,121 @@ static void test_bcache_scenario(void *fixture)
 
 //----------------------------------------------------------------
 
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
 #define T(path, desc, fn) register_test(ts, "/base/data-struct/radix-tree/" path, desc, fn)
 
 void radix_tree_tests(struct dm_list *all_tests)
@@ -668,6 +783,7 @@ void radix_tree_tests(struct dm_list *all_tests)
 	T("remove-calls-dtr", "remove should call the dtr for the value", test_remove_calls_dtr);
 	T("destroy-calls-dtr", "destroy should call the dtr for all values", test_destroy_calls_dtr);
 	T("bcache-scenario", "A specific series of keys from a bcache scenario", test_bcache_scenario);
+	T("bcache-scenario-2", "A second series of keys from a bcache scenario", test_bcache_scenario2);
 
 	dm_list_add(all_tests, &ts->list);
 }


