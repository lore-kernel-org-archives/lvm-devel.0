From: Joe Thornber <thornber@sourceware.org>
Date: Thu, 20 Sep 2018 09:48:53 -0400
Subject: master - [radix-tree] Fix bug in _degrade_to_n16
Message-ID: <201809201348.w8KDmrZC008581@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ebd2d7773f2531bd5dddb97c061ddb74af117844
Commit:        ebd2d7773f2531bd5dddb97c061ddb74af117844
Parent:        0ac7913c6a43c5bcfbba735652041a0eae4180c6
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Thu Sep 20 14:20:16 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Thu Sep 20 14:20:16 2018 +0100

[radix-tree] Fix bug in _degrade_to_n16

Values were getting shuffled
---
 base/data-struct/radix-tree-adaptive.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/base/data-struct/radix-tree-adaptive.c b/base/data-struct/radix-tree-adaptive.c
index a657b2b..23e69f8 100644
--- a/base/data-struct/radix-tree-adaptive.c
+++ b/base/data-struct/radix-tree-adaptive.c
@@ -581,12 +581,11 @@ static void _degrade_to_n16(struct node48 *n48, struct value *result)
         for (i = 0; i < 256; i++) {
 	        if (n48->keys[i] < 48) {
 		        n16->keys[count] = i;
+		        n16->values[count] = n48->values[n48->keys[i]];
 		        count++;
 	        }
         }
 
-        memcpy(n16->values, n48->values, n48->nr_entries * sizeof(*n16->values));
-
         free(n48);
 
 	result->type = NODE16;


