From: Joe Thornber <thornber@sourceware.org>
Date: Thu, 20 Sep 2018 09:48:03 -0400
Subject: master - [radix-tree] Add some extra checks to is_well_formed()
Message-ID: <201809201348.w8KDm3vm008544@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=abe2210c261223212435fbfd505842583ee1145a
Commit:        abe2210c261223212435fbfd505842583ee1145a
Parent:        fdb6ef8a85e9adc4805202b3200b17bd3b351982
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Thu Sep 20 14:18:10 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Thu Sep 20 14:18:10 2018 +0100

[radix-tree] Add some extra checks to is_well_formed()

---
 base/data-struct/radix-tree-adaptive.c |   26 ++++++++++++++++++++++++++
 1 files changed, 26 insertions(+), 0 deletions(-)

diff --git a/base/data-struct/radix-tree-adaptive.c b/base/data-struct/radix-tree-adaptive.c
index 1eef1f8..233bebd 100644
--- a/base/data-struct/radix-tree-adaptive.c
+++ b/base/data-struct/radix-tree-adaptive.c
@@ -1036,6 +1036,7 @@ void radix_tree_iterate(struct radix_tree *rt, uint8_t *kb, uint8_t *ke,
 
 static bool _check_nodes(struct value *v, unsigned *count)
 {
+	uint64_t bits;
 	unsigned i, ncount;
 	struct value_chain *vc;
 	struct prefix_chain *pc;
@@ -1090,22 +1091,47 @@ static bool _check_nodes(struct value *v, unsigned *count)
 		return true;
 
 	case NODE48:
+		bits = 0;
 		n48 = v->value.ptr;
 		ncount = 0;
 		for (i = 0; i < 256; i++) {
 			if (n48->keys[i] < 48) {
+				if (n48->keys[i] >= n48->nr_entries) {
+					fprintf(stderr, "referencing value past nr_entries (n48)\n");
+					return false;
+				}
+
+				if (bits & (1ull << n48->keys[i])) {
+					fprintf(stderr, "duplicate entry (n48) %u\n", (unsigned) n48->keys[i]);
+					return false;
+				}
+				bits = bits | (1ull << n48->keys[i]);
 				ncount++;
+
 				if (!_check_nodes(n48->values + n48->keys[i], count))
 					return false;
 			}
 		}
 
+		for (i = 0; i < n48->nr_entries; i++) {
+			if (!(bits & (1ull << i))) {
+				fprintf(stderr, "not all values are referenced (n48)\n");
+				return false;
+			}
+		}
+
 		if (ncount != n48->nr_entries) {
 			fprintf(stderr, "incorrect number of entries in n48, n48->nr_entries = %u, actual = %u\n",
                                 n48->nr_entries, ncount);
 			return false;
 		}
 
+		for (i = 0; i < n48->nr_entries; i++)
+			if (n48->values[i].type == UNSET) {
+				fprintf(stderr, "value in UNSET (n48)\n");
+				return false;
+			}
+
 		for (i = n48->nr_entries; i < 48; i++)
 			if (n48->values[i].type != UNSET) {
 				fprintf(stderr, "unused value is not UNSET (n48)\n");


