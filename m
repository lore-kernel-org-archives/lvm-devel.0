From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon,  8 Mar 2021 14:46:48 +0000 (GMT)
Subject: main - hash: use unsigned size
Message-ID: <20210308144648.CC19F3950400@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=84679d254ffdeab24cc2994d1ef3bc800ca736d7
Commit:        84679d254ffdeab24cc2994d1ef3bc800ca736d7
Parent:        2d64ffaee521222e64b5c0bdfec367617e503f05
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Mar 7 02:13:02 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 8 15:33:15 2021 +0100

hash: use unsigned size

There is not much point in using 64bit hash size, since we hash
with way less bits anyway. So keep size 32bit.
---
 base/data-struct/hash.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/base/data-struct/hash.c b/base/data-struct/hash.c
index d60f28a25..9f6322733 100644
--- a/base/data-struct/hash.c
+++ b/base/data-struct/hash.c
@@ -71,16 +71,16 @@ static struct dm_hash_node *_create_node(const void *key, unsigned len)
 	return n;
 }
 
-static unsigned long _hash(const void *key, unsigned len)
+static unsigned _hash(const void *key, unsigned len)
 {
 	const unsigned char *str = key;
-	unsigned long h = 0, g;
+	unsigned h = 0, g;
 	unsigned i;
 
 	for (i = 0; i < len; i++) {
 		h <<= 4;
 		h += _nums[*str++];
-		g = h & ((unsigned long) 0xf << 16u);
+		g = h & ((unsigned) 0xf << 16u);
 		if (g) {
 			h ^= g >> 16u;
 			h ^= g >> 5u;


