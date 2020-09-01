From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue,  1 Sep 2020 17:02:13 +0000 (GMT)
Subject: master - cleanup: better expressing passing key arg to _hash
Message-ID: <20200901170213.4A66C39540BF@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1ff1e86debe29abc0ac706e5e7b89fc5192f191f
Commit:        1ff1e86debe29abc0ac706e5e7b89fc5192f191f
Parent:        4baedfc5787e5b87cfb3f4b0ea13a6ae9bc9c52e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Aug 29 22:37:17 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Sep 1 17:57:50 2020 +0200

cleanup: better expressing passing key arg to _hash

---
 base/data-struct/hash.c | 9 +++++----
 libdm/datastruct/hash.c | 9 +++++----
 2 files changed, 10 insertions(+), 8 deletions(-)

diff --git a/base/data-struct/hash.c b/base/data-struct/hash.c
index 5ef5ed276..d60f28a25 100644
--- a/base/data-struct/hash.c
+++ b/base/data-struct/hash.c
@@ -59,26 +59,27 @@ static unsigned char _nums[] = {
 	209
 };
 
-static struct dm_hash_node *_create_node(const char *str, unsigned len)
+static struct dm_hash_node *_create_node(const void *key, unsigned len)
 {
 	struct dm_hash_node *n = malloc(sizeof(*n) + len);
 
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
diff --git a/libdm/datastruct/hash.c b/libdm/datastruct/hash.c
index 726347ea2..67261f8da 100644
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


