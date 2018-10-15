From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 15 Oct 2018 11:55:16 -0400
Subject: master - cov: fix missing null allocation check
Message-ID: <201810151555.w9FFtGn6020572@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=eed8715e1d891665a6c9b8a39850e61f40ea453e
Commit:        eed8715e1d891665a6c9b8a39850e61f40ea453e
Parent:        20971f7034cbd329f873e08869bfb7acf3f1ac0e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 15 14:52:49 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 15 17:49:44 2018 +0200

cov: fix missing null allocation check

---
 base/data-struct/radix-tree-adaptive.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/base/data-struct/radix-tree-adaptive.c b/base/data-struct/radix-tree-adaptive.c
index cd53dd6..cbe8302 100644
--- a/base/data-struct/radix-tree-adaptive.c
+++ b/base/data-struct/radix-tree-adaptive.c
@@ -265,7 +265,8 @@ static bool _insert_prefix_chain(struct radix_tree *rt, struct value *v, uint8_t
 			if (kb[i] != pc->prefix[i])
 				break;
 
-		pc2 = zalloc(sizeof(*pc2) + pc->len - i);
+		if (!(pc2 = zalloc(sizeof(*pc2) + pc->len - i)))
+			return false;
 		pc2->len = pc->len - i;
 		memmove(pc2->prefix, pc->prefix + i, pc2->len);
 		pc2->child = pc->child;


