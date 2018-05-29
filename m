From: Joe Thornber <thornber@sourceware.org>
Date: Tue, 29 May 2018 13:16:10 -0400
Subject: master - radix_tree_t: knock out some debug
Message-ID: <201805291716.w4THGAPd023683@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6cd798f556b34c4c4171d536298d8f718f8aef62
Commit:        6cd798f556b34c4c4171d536298d8f718f8aef62
Parent:        b7fd8ac8ebf07f7a8119aae723f40ef6f85273ce
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Wed May 23 12:54:02 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Wed May 23 12:54:02 2018 +0100

radix_tree_t: knock out some debug

---
 test/unit/radix_tree_t.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/test/unit/radix_tree_t.c b/test/unit/radix_tree_t.c
index 9f2ba07..4cf394f 100644
--- a/test/unit/radix_tree_t.c
+++ b/test/unit/radix_tree_t.c
@@ -256,7 +256,6 @@ static void test_remove_prefix_keys_reversed(void *fixture)
 	}
 
 	for (i = 0; i < 32; i++) {
-        	fprintf(stderr, "removing %u\n", i);
         	T_ASSERT(radix_tree_remove(rt, k, k + (31 - i)));
         	for (j = 0; j < 31 - i; j++) {
                 	T_ASSERT(radix_tree_lookup(rt, k, k + j, &v));


