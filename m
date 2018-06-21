From: Joe Thornber <thornber@sourceware.org>
Date: Thu, 21 Jun 2018 12:42:28 -0400
Subject: master - radix-tree: squash a pointer arithmetic warning
Message-ID: <201806211642.w5LGgScf031595@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=254e5c5d119447bcb8b160a4b4e5b0c36e9af5ba
Commit:        254e5c5d119447bcb8b160a4b4e5b0c36e9af5ba
Parent:        18528180d9f588e265747f4710a8767756454b4c
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Thu Jun 21 17:41:56 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Thu Jun 21 17:41:56 2018 +0100

radix-tree: squash a pointer arithmetic warning

---
 base/data-struct/radix-tree.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/base/data-struct/radix-tree.c b/base/data-struct/radix-tree.c
index ffbf029..1d24dad 100644
--- a/base/data-struct/radix-tree.c
+++ b/base/data-struct/radix-tree.c
@@ -628,7 +628,7 @@ static void _erase_elt(void *array, unsigned obj_size, unsigned count, unsigned
                 obj_size * (count - index - 1));
 
 	// Zero the now unused last elt (set's v.type to UNSET)
-	memset(array + (count - 1) * obj_size, 0, obj_size);
+	memset(((uint8_t *) array) + (count - 1) * obj_size, 0, obj_size);
 }
 
 static bool _remove(struct radix_tree *rt, struct value *root, uint8_t *kb, uint8_t *ke)


