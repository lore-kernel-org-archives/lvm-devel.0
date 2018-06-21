From: Joe Thornber <thornber@sourceware.org>
Date: Thu, 21 Jun 2018 04:55:49 -0400
Subject: master - radix_tree: add new test case
Message-ID: <201806210855.w5L8tn0F025895@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c8cfbfa605ce6577c390cf940d51d872b3556c64
Commit:        c8cfbfa605ce6577c390cf940d51d872b3556c64
Parent:        20b9746c5d22de385e32f5be9a8f04754be2c706
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Tue Jun 19 13:38:13 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Thu Jun 21 09:49:25 2018 +0100

radix_tree: add new test case

Check that value destructors are called by radix_tree_destroy()
---
 test/unit/radix_tree_t.c |   42 ++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 42 insertions(+), 0 deletions(-)

diff --git a/test/unit/radix_tree_t.c b/test/unit/radix_tree_t.c
index e2d11e8..4ee22c1 100644
--- a/test/unit/radix_tree_t.c
+++ b/test/unit/radix_tree_t.c
@@ -562,6 +562,47 @@ static void test_remove_calls_dtr(void *fixture)
 	radix_tree_destroy(rt);
 }
 
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
 //----------------------------------------------------------------
 
 #define T(path, desc, fn) register_test(ts, "/base/data-struct/radix-tree/" path, desc, fn)
@@ -595,6 +636,7 @@ void radix_tree_tests(struct dm_list *all_tests)
 	T("iterate-single", "iterate a subset that contains a single entry", test_iterate_single);
 	T("iterate-vary-middle", "iterate keys that vary in the middle", test_iterate_vary_middle);
 	T("remove-calls-dtr", "remove should call the dtr for the value", test_remove_calls_dtr);
+	T("destroy-calls-dtr", "destroy should call the dtr for all values", test_destroy_calls_dtr);
 
 	dm_list_add(all_tests, &ts->list);
 }


