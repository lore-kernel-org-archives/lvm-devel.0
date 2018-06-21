From: Joe Thornber <thornber@sourceware.org>
Date: Thu, 21 Jun 2018 12:12:52 -0400
Subject: master - radix-tree: fix bug when erasing elts in remove_prefix
Message-ID: <201806211612.w5LGCqpJ026906@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=72e2e92f4c23b75efdf08ee5a4019b6beb86b9f1
Commit:        72e2e92f4c23b75efdf08ee5a4019b6beb86b9f1
Parent:        40c1f7889fd88ce4a2f2b42c594db3deb8f84593
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Thu Jun 21 17:10:05 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Thu Jun 21 17:10:05 2018 +0100

radix-tree: fix bug when erasing elts in remove_prefix

_erase_elt() now zeroes the last element of the array (ie. sets to
UNSET).  Previously remove() was doing this, but not remove_prefix().
---
 base/data-struct/radix-tree.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/base/data-struct/radix-tree.c b/base/data-struct/radix-tree.c
index 202d463..ffbf029 100644
--- a/base/data-struct/radix-tree.c
+++ b/base/data-struct/radix-tree.c
@@ -626,6 +626,9 @@ static void _erase_elt(void *array, unsigned obj_size, unsigned count, unsigned
 	memmove(((uint8_t *) array) + (obj_size * index),
                 ((uint8_t *) array) + (obj_size * (index + 1)),
                 obj_size * (count - index - 1));
+
+	// Zero the now unused last elt (set's v.type to UNSET)
+	memset(array + (count - 1) * obj_size, 0, obj_size);
 }
 
 static bool _remove(struct radix_tree *rt, struct value *root, uint8_t *kb, uint8_t *ke)
@@ -700,7 +703,6 @@ static bool _remove(struct radix_tree *rt, struct value *root, uint8_t *kb, uint
         				}
 
         				n4->nr_entries--;
-        				n4->values[n4->nr_entries].type = UNSET;
 					if (!n4->nr_entries) {
 						free(n4);
 						root->type = UNSET;
@@ -723,7 +725,6 @@ static bool _remove(struct radix_tree *rt, struct value *root, uint8_t *kb, uint
         				}
 
         				n16->nr_entries--;
-        				n16->values[n16->nr_entries].type = UNSET;
 					if (n16->nr_entries <= 4) {
         					_degrade_to_n4(n16, root);
 					}
@@ -745,7 +746,6 @@ static bool _remove(struct radix_tree *rt, struct value *root, uint8_t *kb, uint
 		                		n48->keys[j]--;
 				_erase_elt(n48->values, sizeof(*n48->values), n48->nr_entries, i);
 				n48->nr_entries--;
-				n48->values[n48->nr_entries].type = UNSET;
 				if (n48->nr_entries <= 16)
         				_degrade_to_n16(n48, root);
         		}
@@ -1066,7 +1066,7 @@ static bool _check_nodes(struct value *v, unsigned *count)
 
 		for (i = n4->nr_entries; i < 4; i++)
 			if (n4->values[i].type != UNSET) {
-				fprintf(stderr, "unused value is not UNSET\n");
+				fprintf(stderr, "unused value is not UNSET (n4)\n");
 				return false;
 			}
 
@@ -1080,7 +1080,7 @@ static bool _check_nodes(struct value *v, unsigned *count)
 
 		for (i = n16->nr_entries; i < 16; i++)
 			if (n16->values[i].type != UNSET) {
-				fprintf(stderr, "unused value is not UNSET\n");
+				fprintf(stderr, "unused value is not UNSET (n16)\n");
 				return false;
 			}
 
@@ -1105,7 +1105,7 @@ static bool _check_nodes(struct value *v, unsigned *count)
 
 		for (i = n48->nr_entries; i < 48; i++)
 			if (n48->values[i].type != UNSET) {
-				fprintf(stderr, "unused value is not UNSET\n");
+				fprintf(stderr, "unused value is not UNSET (n48)\n");
 				return false;
 			}
 


