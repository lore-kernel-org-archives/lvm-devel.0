From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 16 Oct 2020 19:11:05 +0000 (GMT)
Subject: stable-2.02 - cleanup: better expressing passing key arg to _hash
Message-ID: <20201016191105.4FED3396EC06@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0bd9eb80c9037da729891ab1bee4d6026ac4a5ac
Commit:        0bd9eb80c9037da729891ab1bee4d6026ac4a5ac
Parent:        f0c281f9a94dead2e32737f69f5e42a757433900
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Aug 29 22:37:17 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 16 16:02:06 2020 +0200

cleanup: better expressing passing key arg to _hash

---
 libdm/datastruct/hash.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/libdm/datastruct/hash.c b/libdm/datastruct/hash.c
index 992f4fad9..3e4adfdc0 100644
--- a/libdm/datastruct/hash.c
+++ b/libdm/datastruct/hash.c
@@ -57,26 +57,27 @@ static unsigned char _nums[] = {
 	209
 };
 
-static struct dm_hash_node *_create_node(const char *str, unsigned len)
+static struct dm_hash_node *_create_node(const void *key, unsigned len)
 {
 	struct dm_hash_node *n = dm_malloc(sizeof(*n) + len);
 
 	if (n) {
-		memcpy(n->key, str, len);
+		memcpy(n->key, key, len);
 		n->keylen = len;
 	}
 
 	return n;
 }
 
-static unsigned long _hash(const char *str, unsigned len)
+static unsigned long _hash(const void *key, unsigned len)
 {
+	const unsigned char *str = key;
 	unsigned long h = 0, g;
 	unsigned i;
 
 	for (i = 0; i < len; i++) {
 		h <<= 4;
-		h += _nums[(unsigned char) *str++];
+		h += _nums[*str++];
 		g = h & ((unsigned long) 0xf << 16u);
 		if (g) {
 			h ^= g >> 16u;


