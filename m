From: Joe Thornber <thornber@sourceware.org>
Date: Fri, 11 May 2018 06:41:48 -0400
Subject: master - radix-tree: fix a function decl
Message-ID: <201805111041.w4BAfm3R011597@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=413488edc6dd077e79517e44a8d3b9a51c5138e5
Commit:        413488edc6dd077e79517e44a8d3b9a51c5138e5
Parent:        30a4c7988e790c16cea043b6b6743f0576c80c1e
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Fri May 11 11:40:47 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Fri May 11 11:40:47 2018 +0100

radix-tree: fix a function decl

---
 test/unit/radix_tree_t.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/unit/radix_tree_t.c b/test/unit/radix_tree_t.c
index 6a7ecac..4455f2b 100644
--- a/test/unit/radix_tree_t.c
+++ b/test/unit/radix_tree_t.c
@@ -19,7 +19,7 @@
 
 //----------------------------------------------------------------
 
-static void *rt_init()
+static void *rt_init(void)
 {
 	struct radix_tree *rt = radix_tree_create();
 	T_ASSERT(rt);


