From: Joe Thornber <thornber@sourceware.org>
Date: Thu, 20 Sep 2018 09:48:53 -0400
Subject: master - [radix-tree] tidy up _degrade_to_n48
Message-ID: <201809201348.w8KDmrSS008576@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=bb17302084192bd06facc5f6501206c3ab21b3a1
Commit:        bb17302084192bd06facc5f6501206c3ab21b3a1
Parent:        ebd2d7773f2531bd5dddb97c061ddb74af117844
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Thu Sep 20 14:28:47 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Thu Sep 20 14:28:47 2018 +0100

[radix-tree] tidy up _degrade_to_n48

Shouldn't be any functional changes.
---
 base/data-struct/radix-tree-adaptive.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/base/data-struct/radix-tree-adaptive.c b/base/data-struct/radix-tree-adaptive.c
index 23e69f8..cd53dd6 100644
--- a/base/data-struct/radix-tree-adaptive.c
+++ b/base/data-struct/radix-tree-adaptive.c
@@ -597,16 +597,16 @@ static void _degrade_to_n48(struct node256 *n256, struct value *result)
         unsigned i, count = 0;
         struct node48 *n48 = zalloc(sizeof(*n48));
 
-	memset(n48->keys, 48, sizeof(n48->keys));
-
         n48->nr_entries = n256->nr_entries;
         for (i = 0; i < 256; i++) {
 		if (n256->values[i].type == UNSET)
-        		continue;
+			n48->keys[i] = 48;
 
-		n48->keys[i] = count;
-		n48->values[count] = n256->values[i];
-		count++;
+		else {
+			n48->keys[i] = count;
+			n48->values[count] = n256->values[i];
+			count++;
+		}
         }
 
         free(n256);


