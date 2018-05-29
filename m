From: Joe Thornber <thornber@sourceware.org>
Date: Tue, 29 May 2018 13:16:11 -0400
Subject: master - data-struct/radix-tree: pass the value dtr into create.
Message-ID: <201805291716.w4THGBQN023689@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=033df741e2e771b3abda3e190ed9c359d579ce4a
Commit:        033df741e2e771b3abda3e190ed9c359d579ce4a
Parent:        28c8e95d197bf512a39b561281162ff4d93a598e
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Tue May 29 11:03:10 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Tue May 29 11:03:10 2018 +0100

data-struct/radix-tree: pass the value dtr into create.

Rather than having to pass it into every method that removes items.
---
 base/data-struct/radix-tree.c |   10 +++++++---
 base/data-struct/radix-tree.h |    7 +++----
 test/unit/radix_tree_t.c      |    4 ++--
 3 files changed, 12 insertions(+), 9 deletions(-)

diff --git a/base/data-struct/radix-tree.c b/base/data-struct/radix-tree.c
index b4b6791..c50bd43 100644
--- a/base/data-struct/radix-tree.c
+++ b/base/data-struct/radix-tree.c
@@ -74,17 +74,21 @@ struct node256 {
 struct radix_tree {
 	unsigned nr_entries;
 	struct value root;
+	radix_value_dtr dtr;
+	void *dtr_context;
 };
 
 //----------------------------------------------------------------
 
-struct radix_tree *radix_tree_create(void)
+struct radix_tree *radix_tree_create(radix_value_dtr dtr, void *dtr_context)
 {
 	struct radix_tree *rt = malloc(sizeof(*rt));
 
 	if (rt) {
 		rt->nr_entries = 0;
 		rt->root.type = UNSET;
+		rt->dtr = dtr;
+		rt->dtr_context = dtr_context;
 	}
 
 	return rt;
@@ -153,9 +157,9 @@ static void _free_node(struct value v, radix_value_dtr dtr, void *context)
 	}
 }
 
-void radix_tree_destroy(struct radix_tree *rt, radix_value_dtr dtr, void *context)
+void radix_tree_destroy(struct radix_tree *rt)
 {
-	_free_node(rt->root, dtr, context);
+	_free_node(rt->root, rt->dtr, rt->dtr_context);
 	free(rt);
 }
 
diff --git a/base/data-struct/radix-tree.h b/base/data-struct/radix-tree.h
index d84e3c5..13ab4cd 100644
--- a/base/data-struct/radix-tree.h
+++ b/base/data-struct/radix-tree.h
@@ -25,12 +25,11 @@ union radix_value {
 	uint64_t n;
 };
 
-struct radix_tree *radix_tree_create(void);
-
 typedef void (*radix_value_dtr)(void *context, union radix_value v);
 
-// dtr may be NULL
-void radix_tree_destroy(struct radix_tree *rt, radix_value_dtr dtr, void *context);
+// dtr will be called on any deleted entries.  dtr may be NULL.
+struct radix_tree *radix_tree_create(radix_value_dtr dtr, void *dtr_context);
+void radix_tree_destroy(struct radix_tree *rt);
 
 unsigned radix_tree_size(struct radix_tree *rt);
 bool radix_tree_insert(struct radix_tree *rt, uint8_t *kb, uint8_t *ke, union radix_value v);
diff --git a/test/unit/radix_tree_t.c b/test/unit/radix_tree_t.c
index 4455f2b..245ec8d 100644
--- a/test/unit/radix_tree_t.c
+++ b/test/unit/radix_tree_t.c
@@ -21,14 +21,14 @@
 
 static void *rt_init(void)
 {
-	struct radix_tree *rt = radix_tree_create();
+	struct radix_tree *rt = radix_tree_create(NULL, NULL);
 	T_ASSERT(rt);
 	return rt;
 }
 
 static void rt_exit(void *fixture)
 {
-	radix_tree_destroy(fixture, NULL, NULL);
+	radix_tree_destroy(fixture);
 }
 
 static void test_create_destroy(void *fixture)


