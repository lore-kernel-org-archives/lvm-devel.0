From: Joe Thornber <thornber@sourceware.org>
Date: Thu, 10 May 2018 09:33:55 -0400
Subject: master - functional-tests/vdo: fix mem leak in test
Message-ID: <201805101333.w4ADXtcV015243@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3c0f5bdd089e5990c4d57ea7bee5e6d9a24d5d54
Commit:        3c0f5bdd089e5990c4d57ea7bee5e6d9a24d5d54
Parent:        ae5037481172da84d414ca047408d9fb13955886
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Thu May 10 14:31:16 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Thu May 10 14:31:16 2018 +0100

functional-tests/vdo: fix mem leak in test

---
 test/unit/vdo_t.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/test/unit/vdo_t.c b/test/unit/vdo_t.c
index aaa4d9c..21ecd1a 100644
--- a/test/unit/vdo_t.c
+++ b/test/unit/vdo_t.c
@@ -100,6 +100,7 @@ static void _check_good(struct example_good *es, unsigned count)
                 fprintf(stderr, "\n");
 #endif
                 T_ASSERT(_status_eq(&e->status, pr.status));
+                free(pr.status);
         }
 }
 


