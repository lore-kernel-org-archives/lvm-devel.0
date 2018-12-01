From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 30 Nov 2018 19:08:02 -0500
Subject: master - gcc: avoid shadowing index
Message-ID: <201812010008.wB1082EI031213@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1aac59f82ac021afe8a0a7aa6059e068637db9ba
Commit:        1aac59f82ac021afe8a0a7aa6059e068637db9ba
Parent:        250e05a9656bf8888ac6e399791c46369e77d667
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 30 21:46:14 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Dec 1 01:06:51 2018 +0100

gcc: avoid shadowing index

Some older headers were declaring 'index' so avoid its usage.
/usr/include/string.h:489: warning: shadowed declaration is here
---
 base/data-struct/radix-tree-adaptive.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/base/data-struct/radix-tree-adaptive.c b/base/data-struct/radix-tree-adaptive.c
index 25dfbee..5e065b6 100644
--- a/base/data-struct/radix-tree-adaptive.c
+++ b/base/data-struct/radix-tree-adaptive.c
@@ -624,15 +624,15 @@ static void _degrade_to_n48(struct node256 *n256, struct value *result)
 }
 
 // Removes an entry in an array by sliding the values above it down.
-static void _erase_elt(void *array, size_t obj_size, unsigned count, unsigned index)
+static void _erase_elt(void *array, size_t obj_size, unsigned count, unsigned idx)
 {
-	if (index == (count - 1))
+	if (idx == (count - 1))
 		// The simple case
 		return;
 
-	memmove(((uint8_t *) array) + (obj_size * index),
-                ((uint8_t *) array) + (obj_size * (index + 1)),
-                obj_size * (count - index - 1));
+	memmove(((uint8_t *) array) + (obj_size * idx),
+                ((uint8_t *) array) + (obj_size * (idx + 1)),
+                obj_size * (count - idx - 1));
 
 	// Zero the now unused last elt (set's v.type to UNSET)
 	memset(((uint8_t *) array) + (count - 1) * obj_size, 0, obj_size);


